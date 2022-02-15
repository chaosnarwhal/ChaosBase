--[[---------------------------------------------------------
	Name: SetIronsights and GetIronsights
	Desc: Allow the setting of IronSights.
-----------------------------------------------------------]]

--[[ 
Function Name:  AdjustMouseSensitivity
Syntax: Should not normally be called.
Returns:  SWEP sensitivity multiplier.
Purpose:  Standard SWEP Function
]]--

function SWEP:AdjustMouseSensitivity()
	local sensval=1
	if self:GetIronSights() then
		sensval = sensval * GetConVarNumber("cl_rev_scope_sensitivity",100)/100
		if GetConVarNumber("cl_rev_scope_sensitivity_autoscale",1)==1 then
			sensval =  sensval*(self.Owner:GetFOV()/self.DefaultFOV)
		else
			sensval = sensval
		end
		if GetConVarNumber("sv_rev_scope_gun_speed_scale",0)==1 then
			sensval = sensval * self.IronSightsMoveSpeed
		end
	end
	
	return sensval
end

--[[ 
Function Name:  TranslateFOV
Syntax: Should not normally be called.  Takes default FOV as parameter.
Returns:  New FOV.
Purpose:  Standard SWEP Function
]]--

function SWEP:TranslateFOV( fov )
	local nfov=Lerp(self.CLIronSightsProgress,fov,self.Secondary.IronFOV)
	return Lerp(self.CLRunSightsProgress,nfov,nfov+self.SprintFOVOffset)
end


--[[ 
Function Name:  IronsSprint
Syntax: self:IronsSprint().  This is called per-think.
Returns:  Nothing. 
Notes:  This corrects ironsights so that you can't sight and sprint at the same time, etc.
Purpose:  Feature.
]]--

function SWEP:IronsSprint()
	local is,oldis,spr, rld, dr, hl, nw, isbolttimer, insp
	spr=self:GetSprinting()
	is=self:GetIronSights()
	oldis=self.OldIronsights
	rld=self:GetReloading()
	dr=self:GetDrawing()
	hl=self:GetHolstering()
	insp = self:GetInspecting()
	ischangingsilence = self:GetChangingSilence()
	isbolttimer = self:GetBoltTimer()
	nw = false
	
	if self:Clip1() ==  0 and (GetConVarNumber("sv_rev_allow_dryfire",1)==0) then
		if self:GetBursting() then
			self:SetBursting(false)
			self:SetNextBurst(CurTime() - 1)
			self:SetBurstCount(0)
		end
	elseif self:Clip1() < 0 and IsValid(self.Owner) and self:GetAmmoReserve()<=0 and (GetConVarNumber("sv_rev_allow_dryfire",1)==0) then
		if self:GetBursting() then
			self:SetBursting(false)
			self:SetNextBurst(CurTime() - 1)
			self:SetBurstCount(0)
		end
	end
		
	if self:GetNearWallRatio()>0.01 then
		nw = true
	end
	
	if (isbolttimer) and (CurTime()>self:GetBoltTimerStart()) and (CurTime()<self:GetBoltTimerEnd()) then
		is=false	
	end
	
	if (spr) then
		is=false
		insp = false
		self:SetInspecting(false)
		self:SetBursting(false)
		self:SetNextBurst(CurTime() - 1)
		self:SetBurstCount(0)
	end
	
	if (insp) then
		is = false
	end
	
	if ( self:IsSafety() ) then
		is=false
		self:SetInspecting(false)
		self:SetBursting(false)
		self:SetNextBurst(CurTime() - 1)
		self:SetBurstCount(0)
	end
	
	if (ischangingsilence) then
		is=false
		self:SetBursting(false)
		self:SetNextBurst(CurTime() - 1)
		self:SetBurstCount(0)
	end
	
	if self.UnSightOnReload then
		if (rld) then
			is=false
			self:SetInspecting(false)
			self:SetInspectingRatio(0)
		end
	end
		
	if (dr) then
		if !self.SightWhileDraw then
			self:SetInspecting(false)
			self:SetInspectingRatio(0)
			is=false
		end
	end
		
	if (hl) then
		self:SetInspecting(false)
		self:SetInspectingRatio(0)
		self:SetBursting(false)
		if !self.SightWhileHolster then
			is=false
		end
	end
	
	if (nw) then
		is=false
		self:SetInspecting(false)
		self:SetBursting(false)
	end
	
	if (oldis!=is) and IsFirstTimePredicted() then
		if (is==false) then
			self:EmitSound("rev.IronOut")
		else
			self:EmitSound("rev.IronIn")
		end
	end
	
	self:SetIronSights(is)
	self:SetSprinting(spr)
	if ( (CLIENT and GetConVarNumber("cl_rev_ironsights_resight",0)==0) or ( SERVER and self.Owner:GetInfoNum("cl_rev_ironsights_resight",0)==0) ) then
		self:SetIronSightsRaw(is)
	end
end