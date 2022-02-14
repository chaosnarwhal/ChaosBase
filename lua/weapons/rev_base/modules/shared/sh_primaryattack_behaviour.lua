AddCSLuaFile()
--[[---------------------------------------------------------
	Name: SWEP:CanPrimaryAttack()
	Desc: Helper function for checking for no ammo
-----------------------------------------------------------]]
function SWEP:CanPrimaryAttack()

	local ply = self:GetOwner()

	if ( self:Clip1() <= 0 ) then

		self:EmitSound( "Weapon_Pistol.Empty" )
		self:SetNextPrimaryFire(CurTime() + 0.3)
		return false

	end

	if self.Weapon:GetNWBool("Inspecting") == true then
		return false
	end

	if self.Weapon:GetNWBool("Passive") == true then
		self:TogglePassive()
		self:SetNextPrimaryFire(CurTime() + 0.3)
		return false
	end

	if ply:IsSprinting() and self.AllowSprintShoot == false then
		return false
	elseif self.AllowSprintShoot == true then
		return true
	end

	return true

end

--[[---------------------------------------------------------
	Name: SWEP:CanSecondaryAttack()
	Desc: Disabling Secondary Attack all together kek
-----------------------------------------------------------]]
function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:CalculateRecoil()
    math.randomseed(self.Recoil.Seed + self:GetSprayRounds())

    local verticalRecoil = math.min(self:GetSprayRounds(), math.min(self:GetMaxClip1() * 0.33, 20)) * 0.1 + math.Rand(self.Recoil.Vertical[1], self.Recoil.Vertical[2]) * GetConVar("mgbase_sv_recoil"):GetFloat()
    local horizontalRecoil = math.Rand(self.Recoil.Horizontal[1], self.Recoil.Horizontal[2]) * GetConVar("mgbase_sv_recoil"):GetFloat()
    local angles = Angle(-verticalRecoil, horizontalRecoil, horizontalRecoil * -0.3)

    return angles * Lerp(self:GetAimDelta(), 1, self.Recoil.AdsMultiplier)
end

function SWEP:CalculateCone()
    math.randomseed(self.Cone.Seed + self:Clip1() + self:Ammo1())
    return math.Clamp(math.Rand(-self:GetCone(), self:GetCone()) * 1000, -self:GetCone(), self:GetCone())

    --local verticalCone = math.random(self.Cone.Vertical[1], self.Recoil.Vertical[2])
    --local horizontalRecoil = math.random(self.Recoil.Horizontal[1], self.Recoil.Horizontal[2])
    --local angles = Angle(verticalRecoil, horizontalRecoil, horizontalRecoil * -0.3)

    --return angles * Lerp(1, self.Recoil.AdsMultiplier, self:GetAimDelta())
end

function SWEP:MetersToHU(meters)
    return (meters * 100) / 2.54
end

function SWEP:PrimaryAttack(worldsnd)

	--If they can't attack do to our previous function than dont let them attack.
	if not self:CanPrimaryAttack() then return end

	--LowTick rate RPM fix.
	local curtime = CurTime()
	local curatt = self:GetNextPrimaryFire()
	local diff = curtime - curatt

	if diff > engine.TickInterval() or diff < 0 then
		curatt = curtime
	end

	self:SetNextPrimaryFire(curatt + self.Primary.Delay)

	--Are we Inspecting the weapon? If so do not allow the user to fire their weapon.
    if self.Weapon:GetNWBool("Inspecting") == true then
		return false
	end

	--Unsued as of the moment. Possible Reverb calculations in bound.
    if not worldsnd then
       self:EmitSound( self.Primary.Sound, self.Primary.SoundLevel )
    elseif SERVER then
       sound.Play(self.Primary.Sound, self:GetPos(), self.Primary.SoundLevel)
    end

    --Pass off to the function to fire the bullet at what ever unlucky bastard is being shot at.
    self:ShootBullet( self.Primary.Damage, self.Primary.NumShots, self:CalculateSpread(), self.Primary.Tracer )

    --Take the ammo from the full when they fire. This function needs to be re-wrote to include multi firing weapons.
    self:TakePrimaryAmmo( 1 )

end







