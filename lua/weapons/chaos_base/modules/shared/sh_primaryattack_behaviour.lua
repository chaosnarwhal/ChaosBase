--[[ 
Function Name:  CanPrimaryAttack
Syntax: SWEP:CanPrimaryAttack().
Returns: If they are allowed to fire the weapon..
Notes: Checks for if they are allowed to fire or if they need to bash.
Purpose: Main SWEP function.
]]
--
function SWEP:CanPrimaryAttack()
    local owner = self:GetOwner()
    if self:Clip1() <= 0 then return false end
    if CurTime() < self:GetNextPrimaryFire() then return false end
    if CurTime() < self:GetNextFiremodeTime() then return false end
    --Reloading?
    if self:GetReloading() then return end
    if self:GetOwner():KeyDown(IN_USE) then return false end

    --NPC Handling.
    if owner:IsNPC() then
        self:NPC_Shoot()

        return
    end

    --Overheated.
    if self:GetHeatLocked() then return end

    --Bashing?
    if self:GetState() ~= ChaosBase.State_SIGHTS and owner:KeyDown(IN_USE) or self.PrimaryBash then
        self:Bash()

        return
    end

    --Are you throwing the weapon?
    if self.Throwing then
        self:PreThrow()

        return
    end

    --Sprinting ? (Check for Sprint Attack Value)
    if (self:GetIsSprinting() == true) then
        if self.AllowSprintShoot then
            return true
        else
            return false
        end
    end
    
    --Passed all the checks! Shoot that thang.

    return true
end

function SWEP:MakeLight(pos, color, brightness, dieTime)
    if SERVER and game.SinglePlayer() then
        local args = "Vector(" .. pos.x .. ", " .. pos.y .. ", " .. pos.z .. "), Color(" .. color.r .. ", " .. color.g .. ", " .. color.b .. "), " .. brightness .. ", " .. dieTime
        self:GetOwner():SendLua("Entity(" .. self:EntIndex() .. "):MakeLight(" .. args .. ")")
    end

    if CLIENT then
        local dlight = DynamicLight(-1)

        if dlight then
            dlight.pos = pos
            dlight.r = color.r
            dlight.g = color.g
            dlight.b = color.b
            dlight.brightness = brightness
            dlight.Decay = 1000
            dlight.Size = 256
            dlight.DieTime = dieTime
        end
    end
end

--[[ 
Function Name:  PrimaryAttack
Syntax: SWEP:PrimaryAttack().
Returns: nothing.
Notes: Firing the weapon and creating the bullet.
Purpose: Main SWEP function.
]]
--
function SWEP:PrimaryAttack()
    self:SetSafety(false)
    if not self:CanPrimaryAttack() then return end
    local delay = 60 / self.Primary.RPM
    local curtime = CurTime()
    local curatt = self:GetNextPrimaryFire()
    local diff = curtime - curatt

    if diff > engine.TickInterval() or diff < 0 then
        curatt = curtime
    end

    if self.ShotgunReload then
        if self:GetShotgunReloading() then
            self:SetIsPumping(true)
        elseif delay > 0 then
            self:SetIsPumping(false)
        end
    end

    --AddingSpray
    self:SetClip1(self:Clip1() - 1)
    self:SetSprayRounds(self:GetSprayRounds() + 1)
    self:SetNextPrimaryFire(curatt + delay)
    self:SetBurstRounds(self:GetBurstRounds() + 1)

    if self:GetBurstRounds() >= self.Primary.BurstRounds and self.Primary.BurstRounds > 1 then
        self:SetNextPrimaryFire(CurTime() + self.Primary.BurstDelay)
        self:SetBurstRounds(0)
    end

    self:DoShootSound()
    self.lastHitEntity = NULL

    if not self.Projectile then
        if CLIENT then
            self:ShootBullets()
        elseif game.SinglePlayer() then
            self:CallOnClient("ShootBullets")
        end
    else
        self:Projectiles()
    end

    self:DoPrimaryAnim()
    self:GetOwner():ViewPunch(self:CalculateRecoil())
    self:SetCone(math.min(self:GetCone() + self.Cone.Increase * 10 * Lerp(self:GetAimDelta(), 1, self.Cone.AdsMultiplier), self.Cone.Max))

    if CLIENT and IsFirstTimePredicted() then
        self.Camera.Shake = self.Recoil.Shake --* Lerp(self:GetAimDelta(), 1, self.Recoil.AdsMultiplier)
    end
end

--[[ 
Function Name:  TakePrimaryAmmo
Syntax: SWEP:TakePrimaryAmmo(num).
Returns: nothing.
Notes: Removes ammo from the clip from the passed num.
Purpose: Main SWEP function.
]]
--
function SWEP:TakePrimaryAmmo(num)
    if self:Clip1() <= 0 then
        if self:Ammo1() <= 0 then return end
        self:GetOwner():RemoveAmmo(num, self:GetPrimaryAmmoType())
    end

    self:SetClip1(self:Clip1() - num)
end

function SWEP:MetersToHU(meters)
    return (meters * 100) / 2.54
end

function SWEP:DoShootSound(sndoverride, dsndoverride, voloverride, pitchoverride)
    local fsound = self.Primary.ShootSound
    local distancesound = self.Primary.DistantShootSound
    local spv = self.ShootPitchVariation
    local volume = self.ShootVol
    local pitch = self.ShootPitch * math.Rand(1 - spv, 1 + spv)
    volume = math.Clamp(volume, 51, 149)
    pitch = math.Clamp(pitch, 0, 255)

    if sndoverride then
        fsound = sndoverride
    end

    if dsndoverride then
        distancesound = dsndoverride
    end

    if voloverride then
        volume = voloverride
    end

    if pitchoverride then
        pitch = pitchoverride
    end

    if distancesound then
        self:ChaosEmitSound(distancesound, 149, pitch, 0.5, CHAN_WEAPON + 1)
    end

    if fsound then
        self:ChaosEmitSound(fsound, volume, pitch, 1, CHAN_WEAPON)
    end
end

function SWEP:DoPrimaryAnim()
    local anim = "fire"
    local time = 1

    if anim then
        self:PlayAnimation(anim, time, true, 0, false)
    end
end

function SWEP:SecondaryAttack()
    return self.Melee2 and self:Bash(true)
end

function SWEP:CalculateRecoil()
    math.randomseed(self.Recoil.Seed + self:GetSprayRounds())
    local verticalRecoil = math.min(self:GetSprayRounds(), math.min(self:GetMaxClip1() * 0.33, 20)) * 0.1 + math.Rand(self.Recoil.Vertical[1], self.Recoil.Vertical[2])
    local horizontalRecoil = math.Rand(self.Recoil.Horizontal[1], self.Recoil.Horizontal[2])
    local angles = Angle(-verticalRecoil, horizontalRecoil, horizontalRecoil * -0.3)

    return angles * Lerp(self:GetAimDelta(), 1, self.Recoil.AdsMultiplier)
end

function SWEP:CalculateCone()
    math.randomseed(self.Cone.Seed + self:Clip1() + self:Ammo1())

    return math.Clamp(math.Rand(-self:GetCone(), self:GetCone()) * 1000, -self:GetCone(), self:GetCone())
end