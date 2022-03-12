SWEP.Sighted = false
SWEP.Sprinted = false

local function linearlerp(a, b, c)
    return b + (c - b) * a
end

function SWEP:GetSightTime()
    return self.SightTime
end

function SWEP:EnterSprint()
	if self:GetState() == ChaosBase.STATE_SPRINT then return end
    self:SetState(ChaosBase.STATE_SPRINT)
    self.Sighted = false
    self.Sprinted = true

    local ct = CurTime()

    self:SetShouldHoldType()

    local s = self.ShootWhileSprint

    if not s and self:GetNextPrimaryFire() <= ct then
    	self:SetNextPrimaryFire(ct)
    end

    local anim = self:SelectAnimation("idle")
    if anim and not s and self:GetNextSecondaryFire() <= ct then
    	self:PlayAnimation(anim, 1, true, nil, false, nil, false, true)
    end
end

function SWEP:EnterWalk()
	if self:GetState() == ChaosBase.STATE_WALK then return end
	if self:GetState() == ChaosBase.STATE_SPRINT then return end
	
	self:SetState(ChaosBase.STATE_WALK)

	local anim = self:SelectAnimation("idle")
	if anim then
		self:PlayAnimation(anim, 1, true, nil, false, nil, false, true)
	end
end

function SWEP:ExitWalk()
	if self:GetState() == ChaosBase.STATE_IDLE then return end

	self:SetState(ChaosBase.STATE_IDLE)

	local anim = self:SelectAnimation("idle")
	if anim then
		self:PlayAnimationEZ(anim, 1, false)
	end
end

function SWEP:ExitSprint()
	if self:GetState() == ChaosBase.STATE_IDLE then return end

	local delta = self:GetNWSprintDelta()
	local ct = CurTime()

	self:SetState(ChaosBase.STATE_IDLE)
	self.Sighted = false
	self.Sprinted = false

	self:SetShouldHoldType()

	local s = self.ShootWhileSprint

	if not s and self:GetNextPrimaryFire() <= ct then
		self:SetNextPrimaryFire(ct)
	end

	if self:GetOwner():KeyDown(IN_ATTACK2) then
		self:EnterSights()
	end

	local anim = self:SelectAnimation("idle")
    if anim and not s and self:GetNextSecondaryFire() <= ct then
        self:PlayAnimation(anim, 0.1, true, nil, false, nil, false, false)
    elseif not anim and not s then
        self:SetReloading(UnPredictedCurTime() + self:GetSprintTime() * delta)
    end

end

function SWEP:EnterSights()
	local asight = self:GetActiveSights()
	if not asight then return end
	if self:GetState() != ChaosBase.STATE_IDLE then return end
	if self:GetCurrentFiremode().Mode == 0 then return end
	if not self.ReloadInSights and (self:GetReload() or self:GetOwner():KeyDown(IN_RELOAD)) then return end
	if self.ShouldNotSight then return end
	if (not game.SinglePlayer() and not IsFirstTimePredicted()) then return end

	self:SetupActiveSights()

	self:SetState(ChaosBase.STATE_SIGHTS)
	self.Sighted = true
	self.Sprinted = false

	self:SetShouldHoldType()

	 local anim = self:SelectAnimation("enter_sight")
    if anim then
        self:PlayAnimation(anim, self:GetSightTime(), true, nil, nil, nil, false, true)
    end

    self.SightToggle = true
end

function SWEP:ExitSights()
    local asight = self:GetActiveSights()
    if self:GetState() != ChaosBase.STATE_SIGHTS then return end
    if self.LockSightsInReload and self:GetReloading() then return end
    if (not game.SinglePlayer() and !IsFirstTimePredicted()) then return end

    self:SetState(ChaosBase.STATE_IDLE)
    self.Sighted = false
    self.Sprinted = false

    self:SetShouldHoldType()

    if self:InSprint() then
        self:EnterSprint()
    end

    local anim = self:SelectAnimation("exit_sight")
    if anim then
        self:PlayAnimation(anim, self:GetSightTime(), true, nil, nil, nil, false, true)
    end

    self.SightToggle = false
end

function SWEP:GetSprintTime()
    return self:GetSightTime()
end

function SWEP:SetupActiveSights()
	if not self.IronSightStruct then return end
    if self.ShouldNotSight then return false end

    if not self:GetOwner():IsPlayer() then return end

    local vm = self:GetOwner():GetViewModel()

    if not vm or not vm:IsValid() then return end

 end


 function SWEP:GetActiveSights()

end


SWEP.LastTranslateFOV = 0
function SWEP:TranslateFOV(fov)
    local irons = self:GetActiveSights()

    self.ApproachFOV = self.ApproachFOV or fov
    self.CurrentFOV = self.CurrentFOV or fov

    -- Only update every tick (this function is called multiple times per tick)
    if self.LastTranslateFOV == UnPredictedCurTime() then return self.CurrentFOV end
    local timed = UnPredictedCurTime() - self.LastTranslateFOV
    self.LastTranslateFOV = UnPredictedCurTime()

    local app_vm = self.ViewModelFOV + self:GetOwner():GetInfoNum("chaosbase_vm_fov", 0) + 10

    if self:GetState() == ChaosBase.STATE_SIGHTS then
        local asight = self:GetActiveSights()
        local mag = asight and asight.ScopeMagnification or 1

        local delta = math.pow(self:GetSightDelta(), 2)

        if CLIENT then
            local addads = math.Clamp(GetConVar("chaosbase_vm_add_ads"):GetFloat() or 0, -2, 14)
            local csratio = math.Clamp(GetConVar("chaosbase_cheapscopesv2_ratio"):GetFloat() or 0, 0, 1)

            if GetConVar("chaosbase_cheapscopes"):GetBool() and mag > 1 then
                fov = 75 / (mag / (1 + csratio * mag) + (addads or 0) / 3)
            else
                fov = math.Clamp( (75 * (1 - delta)) + (GetConVar("fov_desired"):GetInt() * delta), 75, 100)
            end

            app_vm = irons.ViewModelFOV or 45

            app_vm = app_vm - (asight.MagnifiedOptic and (addads or 0) * 3 or 0)
        end
    end

    self.ApproachFOV = fov

    -- magic number? multiplier of 10 seems similar to previous behavior
    self.CurrentFOV = math.Approach(self.CurrentFOV, self.ApproachFOV, timed * 10 * (self.CurrentFOV - self.ApproachFOV))

    self.CurrentViewModelFOV = self.CurrentViewModelFOV or self.ViewModelFOV
    self.CurrentViewModelFOV = math.Approach(self.CurrentViewModelFOV, app_vm, timed * 10 * (self.CurrentViewModelFOV - app_vm))

    return self.CurrentFOV
end

function SWEP:SetShouldHoldType()
    if self:GetState() == ChaosBase.STATE_SIGHTS then
        self:SetHoldType(self.HoldtypeSights)
    elseif self:GetState() == ChaosBase.STATE_SPRINT then
        self:SetHoldType(self.HoldtypeHolstered)
    else
        self:SetHoldType(self.HoldtypeActive)
    end
end