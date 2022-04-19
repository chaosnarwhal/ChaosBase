AddCSLuaFile()

function SWEP:BulletCallback(attacker, tr, dmgInfo)
    if CLIENT then
        if not game.SinglePlayer() and not IsFirstTimePredicted() then return end
        if not self:IsCarriedByLocalPlayer() then return end

        --Custom Hitgroup Damage Setting
        local dmgtable = self.BodyDamageMults
        local hitpos, hitnormal = tr.HitPos, tr.HitNormal
        local trent = tr.Entity

        if dmgtable then
            local hg = tr.HitGroup
            local gam = ChaosBase.LimbCompensation[engine.ActiveGamemode()] or ChaosBase.LimbCompensation[1]
            if dmgtable[hg] then
                dmg:ScaleDamage(dmgtable[hg])
                if GetConVar("chaosbase_bodydamagemult_cancel"):GetBool() and gam[hg] then dmg:ScaleDamage(gam[hg]) end
            end
        end

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

    self:FireBullets({
            Attacker = self:GetOwner(),
            Src = self:GetOwner():EyePos(),
            Dir = dir,
            Spread = spread,
            Num = SERVER and 1 or self.Bullet.NumBullets,
            Damage = self.Bullet.Damage,
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
