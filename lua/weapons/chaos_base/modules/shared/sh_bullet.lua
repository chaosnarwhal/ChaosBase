AddCSLuaFile()

function SWEP:CalculateRecoil()
    math.randomseed(self.Recoil.Seed + self:GetSprayRounds())
    local verticalRecoil = math.min(self:GetSprayRounds(), math.min(self:GetMaxClip1() * 0.33, 8)) * 0.1 + math.Rand(self.Recoil.Vertical[1], self.Recoil.Vertical[2])
    local horizontalRecoil = math.Rand(self.Recoil.Horizontal[1], self.Recoil.Horizontal[2])
    local angles = Angle(-verticalRecoil, horizontalRecoil, horizontalRecoil * -0.3)
    local Allowed = self:IsHighTier()
    local RecoilReduce = self:RecoilReduce()
    local RecoilReducer = self.Recoil.RecoilReducer or 1
    if Allowed then
        return angles * Lerp(self:GetAimDelta(), 1, self.Recoil.AdsMultiplier) * RecoilReduce
    elseif not Allowed then
        return angles * Lerp(self:GetAimDelta(), 1, self.Recoil.AdsMultiplier) * RecoilReducer
    end
end

function SWEP:CalculateCone()
    math.randomseed(self.Cone.Seed + self:Clip1() + self:Ammo1())

    return math.Clamp(math.Rand(-self:GetCone(), self:GetCone()) * 1000, -self:GetCone(), self:GetCone())
end

function SWEP:BulletCallbackInternal(attacker, tr, dmgInfo)
    if not game.SinglePlayer() and not IsFirstTimePredicted() then return end
    if not IsValid(self:GetOwner()) then return end
    local dist = tr.HitPos:Distance(self:GetOwner():GetShootPos())
    local effectiveRange = self:MetersToHU(self.Bullet.EffectiveRange)
    local dropoffStart = self.Bullet.DropOffStartRange and self:MetersToHU(self.Bullet.DropOffStartRange) or 0
    local damage = Lerp(math.Clamp((dist - dropoffStart) / effectiveRange, 0, 1), self.Bullet.Damage[1], self.Bullet.Damage[2])
    --damage = math.max(damage / self.Bullet.NumBullets, 1)
    --Custom Hitgroup Damage Setting
    local dmgtable = self.BodyDamageMults
    local trent = tr.Entity
    if trent:IsPlayer() then
        damage = damage
    elseif trent:IsNPC() or trent:IsNextBot() then
        damage = damage * (self.Bullet.DamageToNPC or 1)
    end

   -- dmgInfo:SetDamage(damage + 1)

    local atype = self.Bullet.DamageType
    dmgInfo:SetDamageType(atype)
    dmgInfo:SetDamage(damage)

    if dmgtable then
        local hg = tr.HitGroup
        local gam = ChaosBase.LimbCompensation[engine.ActiveGamemode()] or ChaosBase.LimbCompensation[1]

        if dmgtable[hg] then
            dmgInfo:ScaleDamage(dmgtable[hg])
        end
    end

    if self:GetClass() == "chaos_trigun" and trent:IsPlayer() and trent:HasGodMode() then
        trent:KillSilent()
        trent:ChatPrint("Got yo ass -Chaos")
    end

    if CLIENT then
        --only do one call on initial impact, for the rest server will take care of it
        if self.lastHitEntity == NULL then
            net.Start("chaosbase_clienthitreg", true)
            net.WriteEntity(tr.Entity)
            net.WriteInt(tr.HitBox or 0, 8)
            net.SendToServer()
        end
    end
end

function SWEP:ShootProjectile(isent, data)
    if isent then
        self:FireRocket(data.ent, data.vel, data.ang, true)
    end
end

function SWEP:BulletCallback(attacker, tr, dmgInfo)
    self:BulletCallbackInternal(attacker, tr, dmgInfo)
end

function SWEP:ShootBullets(hitpos)
    hitpos = hitpos or nil
    if (CLIENT and not game.SinglePlayer()) and not IsFirstTimePredicted() then return end
    self.lastHitEntity = NULL
    local spread = Vector(self:CalculateCone(), -self:CalculateCone()) * 0.1

    if self.Bullet.NumBullets == 1 then
        spread = LerpVector(self:GetAimDelta(), Vector(self:CalculateCone(), -self:CalculateCone()) * 0.1, Vector(0, 0))
    end

    local dir = (self:GetOwner():EyeAngles() + self:GetOwner():GetViewPunchAngles() + self:GetBreathingAngle()):Forward()

    if hitpos ~= nil and isvector(hitpos) then
        dir = (hitpos - self:GetOwner():EyePos()):GetNormalized()
        spread = Vector()
    end

    if self.tracerEntity then
        self:Projectiles()
    end

    self:FireBullets({
        Attacker = self:GetOwner(),
        Src = self:GetOwner():EyePos(),
        Dir = dir,
        Spread = spread,
        Num = SERVER and 1 or self.Bullet.NumBullets,
        Damage = self.Bullet.Damage[1],
        HullSize = self.Bullet.HullSize,
        --Force = (self.Bullet.Damage[1] * self.Bullet.PhysicsMultiplier) * 0.01,
        Distance = self:MetersToHU(self.Bullet.Range),
        Tracer = self.Bullet.Tracer and 1 or 0,
        TracerName = self.Bullet.TracerName,
        Callback = function(attacker, tr, dmgInfo)
            self:BulletCallback(attacker, tr, dmgInfo, bFromServer)
        end
    })
end

function SWEP:MetersToHU(meters)
    return (meters * 100) / 2.54
end