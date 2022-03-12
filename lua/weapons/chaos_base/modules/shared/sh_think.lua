local tbl     = table
local tbl_ins = tbl.insert

local tick = 0

function SWEP:InitTimers()
    self.ActiveTimers = {} -- { { time, id, func } }
end

function SWEP:SetTimer(time, callback, id)
    if !IsFirstTimePredicted() then return end

    tbl_ins(self.ActiveTimers, { time + CurTime(), id or "", callback })
end

function SWEP:TimerExists(id)
    for _, v in pairs(self.ActiveTimers) do
        if v[2] == id then return true end
    end

    return false
end

function SWEP:KillTimer(id)
    local keeptimers = {}

    for _, v in pairs(self.ActiveTimers) do
        if v[2] != id then tbl_ins(keeptimers, v) end
    end

    self.ActiveTimers = keeptimers
end

function SWEP:KillTimers()
    self.ActiveTimers = {}
end

function SWEP:ProcessTimers()
    local keeptimers, UCT = {}, CurTime()

    if CLIENT and UCT == tick then return end

    if not self.ActiveTimers then self:InitTimers() end

    for _, v in pairs(self.ActiveTimers) do
        if v[1] <= UCT then v[3]() end
    end

    for _, v in pairs(self.ActiveTimers) do
        if v[1] > UCT then tbl_ins(keeptimers, v) end
    end

    self.ActiveTimers = keeptimers
end

function SWEP:InSprint()
    local owner = self:GetOwner()

    local sprintspeed = owner:GetRunSpeed()
    local walkspeed = owner:GetWalkSpeed()

    local curspeed = owner:GetVelocity():Length()

    if not owner:KeyDown(IN_SPEED) then return false end
    if curspeed < Lerp(0.5, walkspeed, sprintspeed) then return false end
    if not owner:OnGround() then return false end
    if owner:Crouching() then return false end

    return true
end

function SWEP:Think()

	--Checks
	if IsValid(self:GetOwner()) and self:GetClass() == "chaos_base" then
        self:Remove()
        return
    end

    local owner = self:GetOwner()

    if not IsValid(owner) or owner:IsNPC() then return end


    --Idle Anim timer
	if self:GetNextIdle() != 0 and self:GetNextIdle() <= CurTime() then
		self:SetNextIdle(0)
		self:PlayIdleAnimation(true)
	end

	--Reloading Timer
	 if self:GetMagUpIn() != 0 and CurTime() > self:GetMagUpIn() then
        self:ReloadTimed()
        self:SetMagUpIn( 0 )
    end

    --Shotgun Handling Timer.
    local sg = self:GetShotgunReloading()
    if (sg == 2 or sg == 4) and owner:KeyPressed(IN_ATTACK) then
        self:SetShotgunReloading(sg + 1)
    elseif (sg >= 2) and self:GetReloadingREAL() <= CurTime() then
        self:ReloadInsert((sg >= 4) and true or false)
    end

    --Ironsight Handling.
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

	local ply = self:GetOwner()

	local walking = (ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT) or ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK)) && not ply:KeyDown(IN_SPEED)

	--Sprint Handler
	if (not game.SinglePlayer() and IsFirstTimePredicted()) or (game.SinglePlayer() and true) then
        if self:InSprint() and (self:GetState() != ChaosBase.STATE_SPRINT) then
            self:EnterSprint()
        elseif not self:InSprint() and (self:GetState() == ChaosBase.STATE_SPRINT) then
            self:ExitSprint()
        end
    end

    if (not game.SinglePlayer() and IsFirstTimePredicted()) and not self:InSprint() then
    	if walking and (self:GetState() != ChaosBase.STATE_WALK) then
    		self:EnterWalk()
    	elseif not walking and (self:GetState() == ChaosBase.STATE_WALK) then
    		self:ExitWalk()
    	end
    end

    --Process Event Timers
    self:ProcessTimers()

end