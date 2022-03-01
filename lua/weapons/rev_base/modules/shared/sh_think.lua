AddCSLuaFile()
--[[ 
Function Name:  Think
Syntax: self:Think()
Returns:  Nothing.
Notes:  This is blank.
Purpose:  Standard SWEP Function
]]--

function SWEP:Think()
end

--[[ 
Function Name:  Think2
Syntax: self:Think2().  Called from PlayerThink.
Returns:  Nothing.
Notes:  Essential for calling other important functions.  This is called from PlayerThink.  It's used because SWEP:Think() isn't always called.
Purpose:  Standard SWEP Function
]]--

function SWEP:Think2()
	if !self:OwnerIsValid() then return end
	self:ProcessFireMode()
	self:ProcessTimers()
	self:UserInput()
	self:IronsSprint()
	self:ProcessHoldType()
	self:RevManageAnims()
end

--[[ 
Function Name:  UserInput
Syntax: self:UserInput().  Call each think on client/server.
Returns:  Nothing.
Notes: Processes raw ironsights, sprinting, etc. before they're corrected in SWEP:IronsSprint()
Purpose:  Main SWEP function
]]--

function SWEP:UserInput()
	self.OldIronsights=(self:GetIronSights())
	local is=false
	if IsValid(self.Owner) then
		if ( (CLIENT and GetConVarNumber("cl_rev_ironsights_toggle",0)==0) or ( SERVER and self.Owner:GetInfoNum("cl_rev_ironsights_toggle",0)==0) ) then
			if self.Owner:KeyDown(IN_ATTACK2) then
				is=true
			end
		else
			is=self:GetIronSightsRaw()
			if self.Owner:KeyPressed(IN_ATTACK2) then
				is=!is
			end
		end
	end
	
	if self.data and self.data.ironsights == 0 then
		is=false
	end
	
	self:SetIronSightsRaw(is)
	self:SetIronSights(is)
	self.OldSprinting=(self:GetSprinting())
	local spr=false
	if IsValid(self.Owner) then
		local isnumber = (is and 1 or 0)
		if self.Owner:KeyDown(IN_SPEED) and self.Owner:GetVelocity():Length()>self.Owner:GetWalkSpeed()*(self.MoveSpeed*(1-isnumber)+self.IronSightsMoveSpeed*(isnumber)) then
			spr=true
		end
	end
	
	self:SetSprinting(spr)
end

--[[ 
Function Name:  PlayerThink
Syntax: self:PlayerThink( player ).  Shouldn't be called manually usually, just on each think tick.
Returns:  Nothing.
Notes: Critical to processing the ironsights progress and stuff.
Purpose:  Main SWEP function
]]--

function SWEP:PlayerThink( ply )
	
	self:Think2()
	
	if SERVER then
		if self.PlayerThinkServer then
			self:PlayerThinkServer(ply)
		end
	end
	
	if CLIENT then
		self:PlayerThinkClient(ply)
	end

	if ply != self:GetOwner() then return end
	
	local is = 0
	local isr=self:GetIronSightsRatio()
	local rs = 0
	local rsr=self:GetRunSightsRatio()
	local tsv = GetConVarNumber("host_timescale", 1)
	local insp = 0
	local inspr = self:GetInspectingRatio()
	
	if self:GetIronSights() then
		is = 1
	end
	
	if self:IsSafety() then
		rs = 1
	end	
	
	if self:GetSprinting() then
		rs = 1
	end
	
	if self:GetInspecting() then
		insp = 1
	end
	
	local val1,val2
	val1=isr
	local newratio=math.Approach( isr, is, FrameTime() / self.IronSightTime)
	self:SetIronSightsRatio( newratio )
	val2=self:GetIronSightsRatio()
	
	self:SetRunSightsRatio( math.Approach( rsr, rs, FrameTime() / self.IronSightTime) )
	
	self:SetInspectingRatio( math.Approach( inspr, insp, FrameTime() / self.IronSightTime) )
	
	self:SetCrouchingRatio( math.Approach( self:GetCrouchingRatio(), (self.Owner:Crouching() and 1 or 0), FrameTime() / self.ToCrouchTime) )
	
	local jv = !self.Owner:IsOnGround()
	
	self:SetJumpingRatio( math.Approach( self:GetJumpingRatio(), (jv and 1 or 0), FrameTime() / self.ToCrouchTime) )
	
	if self.Primary.SpreadRecovery then
		self:SetSpreadRatio( math.Clamp( self:GetSpreadRatio() - self.Primary.SpreadRecovery*FrameTime(), 1, self.Primary.SpreadMultiplierMax) )
	end
	
end

--[[ 
Function Name:  PlayerThinkServer
Syntax: self:PlayerThinkServer( player ).  Shouldn't be called manually, since it's called by SWEP:PlayerThink().
Returns:  Nothing.
Notes: Unused ATM.
Purpose:  Main SWEP function
]]--

function SWEP:PlayerThinkServer( ply )
	
end

--[[ 
Function Name:  PlayerThinkClient
Syntax: self:PlayerThinkClient( player ).  Shouldn't be called manually, since it's called by SWEP:PlayerThink().
Returns:  Nothing.
Notes: Unused ATM.
Purpose:  Main SWEP function
]]--

function SWEP:PlayerThinkClient( ply )
end

--[[ 
Function Name:  PlayerThinkClientFrame
Syntax: self:PlayerThinkClientFrame( player ).  Shouldn't be called manually, since it's called by before each frame.
Returns:  Nothing.
Notes: Critical for the clientside/predicted ironsights.
Purpose:  Main SWEP function
]]--

function SWEP:PlayerThinkClientFrame( ply )
	if ply != self:GetOwner() then return end
	
	if !(CLIENT or game.SinglePlayer()) then
		return
	end

	self.ShouldDrawAmmoHUD=( ply:KeyDown(IN_USE) and ply:KeyDown(IN_RELOAD) ) or self:GetReloading() or self:GetFireModeChanging() or self:GetHUDThreshold() or (self:GetBoltTimer() and CurTime()>self:GetBoltTimerStart() and CurTime()<self:GetBoltTimerEnd() )
	
	local is = 0
	local isr=self.CLIronSightsProgress
	local rs = 0
	local rsr=self.CLRunSightsProgress
	local insp = 0
	local inspr = self:GetInspectingRatio()
	local tsv = GetConVarNumber("host_timescale", 1)
	local crouchr=self.CLCrouchProgress
	local jumpr=self.CLJumpProgress
	local ftv = math.max( FrameTime(), 1/GetConVarNumber("fps_max",120))
	local ftvc = tsv*ftv
	local vm = self.Owner:GetViewModel()
	
	if self:GetIronSights() then
		is = 1
	end
	
	if self:GetInspecting() then
		insp = 1
	end	
	
	if self:IsSafety() then
		rs = 1
	end	
	
	if self:GetSprinting() then
		rs = 1
	end
	
	local compensatedft = ftv / self.IronSightTime
	local compensatedft_cr = ftv / self.ToCrouchTime
	
	local newratio=math.Approach( isr, is, compensatedft)
	self.CLIronSightsProgress = newratio 
	newratio=math.Approach( rsr, rs, compensatedft)
	self.CLRunSightsProgress = newratio 
	newratio=math.Approach( crouchr, self.Owner:Crouching() and 1 or 0, compensatedft_cr)
	self.CLCrouchProgress = newratio 
	newratio=math.Approach( inspr, insp, compensatedft)
	self.CLInspectingProgress = newratio 
	newratio=math.Approach( jumpr, 1 - (self.Owner:IsOnGround() and 1 or 0 ), compensatedft_cr)
	self.CLJumpProgress = newratio
	self.CLSpreadRatio = math.Clamp(self.CLSpreadRatio - self.Primary.SpreadRecovery * ftv, 1, self.Primary.SpreadMultiplierMax)
	self.CLAmmoHUDProgress = math.Approach( self.CLAmmoHUDProgress, (self.ShouldDrawAmmoHUD  or self:GetInspecting()) and 1 or 0, FrameTime() / GetConVarNumber("cl_rev_hud_ammodata_fadein",0.2) )
	self:DoBobFrame()
	
	local tmptable = {}
	tmptable.Ang = self.Owner:EyeAngles()
	tmptable.Pos = self.Owner:GetShootPos()
	
	self.pre_vm_muzzlepos=self:GetMuzzlePos( true ) or tmptable
	
	if self:IsCurrentlyScoped() then
		self.Owner:DrawViewModel(false)
		local vmod= self.Owner:GetViewModel()
		if IsValid(vmod) then
			vmod:StopParticles()
		end
	else
		self.Owner:DrawViewModel(true)	
	end
end