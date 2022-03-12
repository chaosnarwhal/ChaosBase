--[[ 
Function Name:  CanPrimaryAttack
Syntax: SWEP:CanPrimaryAttack().
Returns: If they are allowed to fire the weapon..
Notes: Checks for if they are allowed to fire or if they need to bash.
Purpose: Main SWEP function.
]]--

function SWEP:CanPrimaryAttack()
	local owner = self:GetOwner()

	--Holstering then dont fire.
	if IsValid(self:GetHolster_Entity()) then return end
	if self:GetHolster_Time() > 0 then return end

	--Reloading?
	if self:GetReloading() then return end

	--Burst resetting.
	if self:GetWeaponOpDelay() > CurTime() then return end

	--NPC Handling.
	if owner:IsNPC() then self:NPC_Shoot() return end

	--Delay Handling.
	if self:GetNextPrimaryFire() >= CurTime() then return end

	--Overheated.
	if self:GetHeatLocked() then return end

	--Bashing?
	if self:GetState() != ChaosBase.State_SIGHTS and owner:KeyDown(IN_USE) or self.PrimaryBash then self:Bash() return end

	--Are you throwing the weapon?
	if self.Throwing then self:PreThrow() return end

	--Sprinting ? (Check for Sprint Attack Value)
	if self:GetNWState() == ChaosBase.STATE_SPRINT and not self.ShootWhileSprint then return end

	--Passed all the checks! Shoot that thang.
	return true
end

--[[ 
Function Name:  TakePrimaryAmmo
Syntax: SWEP:TakePrimaryAmmo(num).
Returns: nothing.
Notes: Removes ammo from the clip from the passed num.
Purpose: Main SWEP function.
]]--

function SWEP:TakePrimaryAmmo(num)
	if self:Clip1() <= 0 then
		if self:Ammo1() <= 0 then return end
		self:GetOwner():RemoveAmmo(num, self:GetPrimaryAmmoType())
	end
	self:SetClip1(self:Clip1() - num)
end

--[[ 
Function Name:  ApplyRandomSpread
Syntax: SWEP:ApplyRandomSpread(dir, spread).
Returns: nothing.
Notes: Spread seed handling.
Purpose: Main SWEP function.
]]--
function SWEP:ApplyRandomSpread(dir, spread)
	local radius = math.Rand(0, 1)
	local theta = math.Rand(0, math.rad(360))
	local bulletang = dir:Angle()
	local forward, right, up = bulletang:Forward(), bulletang:Right(), bulletang:Up()
	local x = radius * math.sin(theta)
	local y = radius * math.cos(theta)

	dir:Set(dir + right * spread * x + up * spread * y)
end

--[[ 
Function Name:  PrimaryAttack
Syntax: SWEP:PrimaryAttack().
Returns: nothing.
Notes: Firing the weapon and creating the bullet.
Purpose: Main SWEP function.
]]--

function SWEP:PrimaryAttack()
	local owner = self:GetOwner()

	self.Primary.Automatic = true

	if not self:CanPrimaryAttack() then return end

	local clip = self:Clip1()
	local aps = self.Primary.AmmoPerShot

	if clip < aps then
		self:SetBurstCount(0)
		--self:DryFire()

		self.Primary.Automatic = false
		return
	end

	local dir = owner:EyeAngles():Forward()
	local src = self:GetOwner()

	self.Primary.Automatic = true

    local delay = 60 / self.Primary.RPM

    local curtime = CurTime()
    local curatt = self:GetNextPrimaryFire()
    local diff = curtime - curatt

    if diff > engine.TickInterval() or diff < 0 then
    	curatt = curtime
    end

    self:SetNextPrimaryFire(curatt + delay)
    --self:SetNextPrimaryFireSlowdown(curatt + delay) -- shadow for ONLY fire time

    self:TakePrimaryAmmo(self.Primary.NumShots)
	self:ShootBullet(self.Damage, CurrentRecoil, self.Primary.NumShots, CurrentCone, self.TracerNum, self.Tracer, self.HullSize)
	self:DoPrimaryAnim()
end

function SWEP:DoPrimaryAnim()
    local anim = "fire"

    local time = 1

    if anim then self:PlayAnimation(anim, time, true, 0, false) end
end

function SWEP:SecondaryAttack()
    return self.Melee2 and self:Bash(true)
end