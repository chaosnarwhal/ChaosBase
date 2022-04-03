AddCSLuaFile()


--Test that GIT shit
function SWEP:CanAim()
    local owner = self:GetOwner()

    return not self:GetIsSprinting() and (not owner:KeyDown(IN_USE) or (owner:KeyDown(IN_USE) and self:GetAimDelta() > 0))
end

function SWEP:AimBehaviourModule()
    if CLIENT and game.SinglePlayer() then return end
    if not IsFirstTimePredicted() then return end
    local speed = 1 / self.IronSightTime
    local ft = FrameTime()
    local owner = self:GetOwner()

    if owner:GetInfoNum("chaosbase_toggleads", 0) >= 1 then
        if owner:KeyPressed(IN_ATTACK2) then
            self:SetToggleAim(not self:GetToggleAim())
        end
    else
        self:SetToggleAim(self:GetOwner():KeyDown(IN_ATTACK2))
    end

    if self:CanAim() and self:GetToggleAim() then
        self:SetIsAiming(true)
        self:SetAimDelta(math.min(self:GetAimDelta() + speed * ft, 1))
    else
        self:SetIsAiming(false)
        self:SetAimDelta(math.max(self:GetAimDelta() - speed * ft, 0))
    end
end

function SWEP:SafetyHandlerModule()
    if CLIENT and game.SinglePlayer() then return end
    if not IsFirstTimePredicted() then return end
    local owner = self:GetOwner()

    if owner:KeyDown(IN_USE) and owner:KeyDown(IN_SPEED) and owner:KeyPressed(IN_RELOAD) then
        self:SetSafety(not self:GetSafety())
    end
end


SWEP.SightTable = {}
SWEP.SightMagnifications = {}


function SWEP:GetActiveSights()
    if (self.ActiveSight or 1) > table.Count(self.SightTable) then
        self.ActiveSight = 1
    end

    if table.Count(self.SightTable) == 0 then
        return self.IronSightStruct
    else
        return self.SightTable[self.ActiveSight or 1]
    end
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

    local app_vm = self.ViewModelFOV + self:GetOwner():GetInfoNum("arccw_vm_fov", 0) + 10

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