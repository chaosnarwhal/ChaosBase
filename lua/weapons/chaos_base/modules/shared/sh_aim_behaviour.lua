AddCSLuaFile()

--Test that GIT shit
function SWEP:CanAim()
    local owner = self:GetOwner()

    return not self:GetIsSprinting() and (not owner:KeyDown(IN_USE) or (owner:KeyDown(IN_USE) and self:GetAimDelta() > 0))
end

function SWEP:AimBehaviourModule()
    local speed = 1 / self.IronSightTime

    if self:CanAim() and self:GetIsAiming() and not self:GetIsSprinting() then
        self:SetAimDelta(math.min(self:GetAimDelta() + speed * FrameTime(), 1))
    else
        self:SetAimDelta(math.max(self:GetAimDelta() - speed * FrameTime(), 0))
    end
end

function SWEP:IronSightSounds()
    local is = self:GetIsAiming()

    if SERVER or IsFirstTimePredicted() and self:CanAim() then
        if is ~= self.is_sndcache_old and self.IronSightsInSound then
            if is then
                self:EmitSound(self.IronSightsInSound)
            else
                self:EmitSound(self.IronSightsOutSound)
            end
        end

        self.is_sndcache_old = is
    end
end

function SWEP:SafetyHandlerModule()
    if self:GetIsSprinting() then return end
    local owner = self:GetOwner()

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
    self.ApproachFOV = fov
    self.CurrentFOV = math.Approach(self.CurrentFOV, self.ApproachFOV, timed * 10 * (self.CurrentFOV - self.ApproachFOV))

    return self.CurrentFOV
end