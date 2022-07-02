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

    if owner:KeyPressed(IN_ATTACK) and self:Clip1() <= 0 and not self:GetSafety() then
        self:ChaosEmitSound(self.DryFireSound, 0.1, self.ShootPitch, 1, CHAN_WEAPON)

        return false
    end

    -- Gun is locked from heat.
    if self:GetHeatLocked() then return end

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

    --[[
    --Bashing?
    if self:GetState() ~= ChaosBase.State_SIGHTS and owner:KeyDown(IN_USE) or self.PrimaryBash then
        self:Bash()

        return
    end
    ]]

    --Sprinting ? (Check for Sprint Attack Value)
    if self:GetIsSprinting() == true then
        if self:GetCanSprintShoot() then
            return true
        else
            return false
        end
    end

    if self:GetSafety() then return false end
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
    if not self:CanPrimaryAttack() then return end

    local delay = 60 / self.Primary.RPM
    local curtime = CurTime()
    local curatt = self:GetNextPrimaryFire()
    local diff = curtime - curatt

    if diff > engine.TickInterval() or diff < 0 then
        curatt = curtime
    end

    self:SetNextPrimaryFire(curatt + delay)

    if self.ShotgunReload then
        if self:GetShotgunReloading() then
            self:SetIsPumping(true)
        elseif delay > 0 then
            self:SetIsPumping(false)
        end
    end
 


    if self:GetCanSprintShoot() then
        self:SetIsFiring(true)
    end

    if self.BatteryBased then
        self:AddHeat(self.HeatPerSecond)
    end

    --AddingSpray
    self:SetClip1(self:Clip1() - 1)
    self:SetSprayRounds(self:GetSprayRounds() + 1)
    local BurstDelay = 60 / self.Primary.BurstDelay
    self:SetBurstRounds(self:GetBurstRounds() + 1)

    if self:GetBurstRounds() >= self.Primary.BurstRounds and self.Primary.BurstRounds > 1 then
        self:SetNextPrimaryFire(CurTime() + BurstDelay)
        self:SetIsFiring(false)
        self:SetBurstRounds(0)
    end

    self:DoShootSound()
    self.lastHitEntity = NULL

    --ClientSide Blood fix
    if not self.Projectile then
        if CLIENT then
            self:ShootBullets()
        end
    else
        self:Projectiles()
    end

    --Primary Shoot animations
    self:DoPrimaryAnim()
    local shouldBlowback = self.BlowbackEnabled

    --Blowback
    if shouldBlowback and IsFirstTimePredicted() then
        self:BlowbackFull(ifp)
    end

    --MuzzleFlash
    self:ShootEffectsCustom()
    --Start Punching view to Recoil and add to the Cone of spray.
    self:GetOwner():ViewPunch(self:CalculateRecoil())
    self:SetCone(math.min(self:GetCone() + self.Cone.Increase * 10 * Lerp(self:GetAimDelta(), 1, self.Cone.AdsMultiplier), self.Cone.Max))

    if CLIENT and IsFirstTimePredicted() then
        self.Camera.Shake = self.Recoil.Shake --* Lerp(self:GetAimDelta(), 1, self.Recoil.AdsMultiplier)
    end

    if self:Clip1() == 1 then
        self:EmitSound("chaos.m6s.SlideBack")
    end

    --HighTier code for setting shootsprint anim to cancel.
    if self:GetIsHighTier() and self:GetCanSprintShoot() then
        timer.Simple(2, function()
            if not self:IsValid() then return end
            self:SetIsFiring(false)
        end)
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

function SWEP:DoShootSound(sndoverride, dsndoverride, voloverride, pitchoverride)
    local fsound = self.Primary.ShootSound
    local distancesound = self.Primary.DistantShootSound
    local spv = self.ShootPitchVariation
    local volume = self.ShootVol
    local pitch = self.ShootPitch * math.Rand(1 - spv, 1 + spv)
    local level = self.ShootLevel
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
        self:ChaosEmitSound(fsound, level, pitch, volume, CHAN_WEAPON, false)
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

function SWEP:Projectiles()
    if CLIENT then return end
    local proj = ents.Create(self.Projectile)
    local angles = self:GetOwner():EyeAngles()
    local src = self:GetOwner():GetShootPos()
    proj.Weapon = self
    proj:SetPos(src)
    proj:SetAngles(angles)
    proj:SetOwner(self:GetOwner())
    proj:Spawn()
end