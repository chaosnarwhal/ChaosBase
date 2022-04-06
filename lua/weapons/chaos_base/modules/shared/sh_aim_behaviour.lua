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