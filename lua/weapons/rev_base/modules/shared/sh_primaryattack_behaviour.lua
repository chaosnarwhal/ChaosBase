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

function SWEP:MetersToHU(meters)
    return (meters * 100) / 2.54
end

function SWEP:PrimaryAttack(worldsnd)

	--If they can't attack do to our previous function than dont let them attack.
	if not self:CanPrimaryAttack() then return end



	--LowTick rate RPM fix.
	local delay = 60 / self.Primary.RPM

	local curtime = CurTime()
	local curatt = self:GetNextPrimaryFire()
	local diff = curtime - curatt

	if diff > engine.TickInterval() or diff < 0 then
		curatt = curtime
	end

	self:SetNextPrimaryFire(curatt + delay)

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







