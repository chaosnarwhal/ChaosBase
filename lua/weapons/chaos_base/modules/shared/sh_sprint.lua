AddCSLuaFile()
SWEP.Sighted = false
SWEP.Sprinted = false

function SWEP:GetSightTime()
    return self.SightTime
end

function SWEP:EnterSprint()
    if self:GetState() == ChaosBase.STATE_SPRINT then return end
    self:SetState(ChaosBase.STATE_SPRINT)
    self.Sighted = false
    self.Sprinted = true
    local ct = CurTime()

    local a,b,SprintShoot = self:IsHighTier()

    if not SprintShoot and self:GetNextPrimaryFire() <= ct then
        self:SetNextPrimaryFire(ct)
    end

    local anim = self:SelectAnimation("idle")

    if anim and self:GetNextSecondaryFire() <= ct then
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
    local delta = self.SprintProgressUnpredicted
    local ct = CurTime()
    self:SetState(ChaosBase.STATE_IDLE)
    self.Sighted = false
    self.Sprinted = false
    local a,b,SprintShoot = self:IsHighTier()

    if not SprintShoot and self:GetNextPrimaryFire() <= ct then
        self:SetNextPrimaryFire(ct)
    end

    local anim = self:SelectAnimation("idle")

    if anim and not SprintShoot and self:GetNextSecondaryFire() <= ct then
        self:PlayAnimation(anim, 0.1, true, nil, false, nil, false, false)
    elseif not anim and not SprintShoot then
        self:SetReloading(UnPredictedCurTime() + self:GetSprintTime() * delta)
    end
end

function SWEP:SprintBehaviour()
    local ply = self:GetOwner()
    local a,b,SprintShoot = self:IsHighTier()
    local walking = (ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT) or ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK)) and not ply:KeyDown(IN_SPEED)
    self:HoldTypeHandler()
    
    --Sprint Handler
    if not game.SinglePlayer() and IsFirstTimePredicted() then
        if self:InSprint() and (self:GetState() ~= ChaosBase.STATE_SPRINT) then
            self:EnterSprint()
            self:SetIsSprinting(true)
        elseif not self:InSprint() and (self:GetState() == ChaosBase.STATE_SPRINT) then
            self:ExitSprint()
            self:SetIsSprinting(false)
        end
    end

    if self:GetIsPumping() then return end

    if (not game.SinglePlayer() and IsFirstTimePredicted()) and not self:GetIsSprinting() then
        if walking and (self:GetState() ~= ChaosBase.STATE_WALK) then
            self:EnterWalk()
        elseif not walking and (self:GetState() == ChaosBase.STATE_WALK) then
            self:ExitWalk()
        end
    end
end

function SWEP:GetSprintTime()
    return self:GetSightTime()
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