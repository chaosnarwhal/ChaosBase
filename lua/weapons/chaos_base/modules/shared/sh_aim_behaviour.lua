AddCSLuaFile()


--Test that GIT shit
function SWEP:CanAim()
    local owner = self:GetOwner()

    return not self:GetIsSprinting() and (not owner:KeyDown(IN_USE) or (owner:KeyDown(IN_USE) and self:GetAimDelta() > 0))
end

function SWEP:AimBehaviourModule()
    local owner = self:GetOwner()
    local speed = 1 / self.IronSightTime

    if owner:GetInfoNum("chaosbase_toggleads", 0) >= 1 then
        if owner:KeyPressed(IN_ATTACK2) then
            self:SetToggleAim(not self:GetToggleAim())
        end
    else
        self:SetToggleAim(self:GetOwner():KeyDown(IN_ATTACK2))
    end

    if self:CanAim() and self:GetToggleAim() then
        self:SetIsAiming(true)
        self:SetAimDelta(math.min(self:GetAimDelta() + speed * FrameTime(), 1))
    else
        self:SetIsAiming(false)
        self:SetAimDelta(math.max(self:GetAimDelta() - speed * FrameTime(), 0))
    end

end

function SWEP:SafetyHandlerModule()
    if self:GetIsSprinting() then return end
    local owner = self:GetOwner()
    local togglesafety = true

    if owner:KeyDown(IN_USE) and owner:KeyDown(IN_SPEED) and owner:KeyPressed(IN_RELOAD) then
        self:SetSafety(not self:GetSafety())
    end

    self:HoldTypeHandler()
end

SWEP.LastTranslateFOV = 0
function SWEP:TranslateFOV(fov)
    self.ApproachFOV = self.ApproachFOV or fov
    self.CurrentFOV = self.CurrentFOV or fov

    if self.LastTranslateFOV == UnPredictedCurTime() then return self.CurrentFOV end
    local timed = UnPredictedCurTime() - self.LastTranslateFOV
    self.LastTranslateFOV = UnPredictedCurTime()

    local app_vm = self.ViewModelFOV + self:GetOwner():GetInfoNum("chaosbase_vm_offset_fov", 0) + 10

    self.ApproachFOV = fov

    self.CurrentFOV = math.Approach(self.CurrentFOV, self.ApproachFOV, timed * 10 * (self.CurrentFOV - self.ApproachFOV))

    return self.CurrentFOV
end