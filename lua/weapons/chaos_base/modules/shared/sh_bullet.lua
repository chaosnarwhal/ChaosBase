SWEP.lastbul = nil
SWEP.lastbulnoric = false

local bullet = {}
bullet.Num 		= 1
bullet.Src 		= Vector(0,0,0)		-- Source
bullet.Dir 		= Vector(0,0,0)		-- Dir of bullet
bullet.Spread 		= Vector(0,0,0)		-- Aim Cone
bullet.Tracer		= 0					-- Show a tracer on every x bullets
bullet.TracerName 	= "None"
bullet.Force		= 0.01
bullet.Damage		= 0.01

--[[ 
Function Name:  ShootBulletInformation
Syntax: self:ShootBulletInformation( ). 
Returns:   Nothing.
Notes:    Used to generate a bullet table which is then sent to self:ShootBullet, and also to call shooteffects.
Purpose:  Bullet
]]--

function SWEP:ShootBulletInformation()
	if (CLIENT and !game.SinglePlayer()) and !IsFirstTimePredicted() then return end


	local CurrentDamage
	local CurrentRecoil = self:CalculateConeRecoil()
	
	basedamage = self.Primary.Damage
	CurrentDamage = basedamage
	
	self:ShootEffects()
	
	self:ShootBullet(CurrentDamage, CurrentRecoil, self.Primary.NumShots, CurrentCone)
end

--[[ 
Function Name:  ShootBullet
Syntax: self:ShootBullet(damage, recoil, number of bullets, spray cone, disable ricochet, override the generated bullet table with this value if you send it). 
Returns:   Nothing.
Notes:    Used to shoot a bullet.
Purpose:  Bullet
]]--

function SWEP:ShootBullet(damage, recoil, num_bullets, aimcone, disablericochet, bulletoverride)

	if (CLIENT and !game.SinglePlayer()) and !IsFirstTimePredicted() then return end

	num_bullets 		= num_bullets or 1
	aimcone 			= aimcone or 0
	recoil 				= recoil or 0

	bullet.Num 		= num_bullets
	bullet.Src 		= self.Owner:GetShootPos()			-- Source
	bullet.Dir 		= self.Owner:GetAimVector()			-- Dir of bullet
	bullet.Spread.x 	= aimcone-- Aim Cone X
	bullet.Spread.y 	= aimcone-- Aim Cone Y
	bullet.Tracer		= 3							-- Show a tracer on every x bullets
	bullet.TracerName  = TracerName
	bullet.Force		= 0
	bullet.Damage		= damage
	bullet.HullSize 	= self.HullSize
	
	self.lastbul = bullet
	self.Owner:FireBullets(bullet)
	self:Recoil( recoil )
end

--[[ 
Function Name:  Recoil
Syntax: self:Recoil( recoil amount ). 
Returns:   Nothing.
Notes:    Used to add recoil to the player owner.
Purpose:  Bullet
]]--

function SWEP:Recoil( recoil )
	if !IsValid(self) or !IsValid(self.Owner) then return end
	
	local tmprecoilang = Angle(math.Rand(self.Primary.KickDown,self.Primary.KickUp) * recoil * -1, math.Rand(-self.Primary.KickHorizontal,self.Primary.KickHorizontal) * recoil, 0)
	
	local maxdist =   math.min(math.max(0,  89 + self.Owner:EyeAngles().p - math.abs(self.Owner:GetViewPunchAngles().p * 2)),88.5)
	local tmprecoilangclamped = Angle(math.Clamp(tmprecoilang.p,-maxdist,maxdist),tmprecoilang.y,0)
	self.Owner:ViewPunch(tmprecoilangclamped * (1 - self.Primary.StaticRecoilFactor))
	
	if SERVER and game.SinglePlayer() and !self.Owner:IsNPC()  then 
		local sp_eyes = self.Owner:EyeAngles()
		local vpa = self.Owner:GetViewPunchAngles()
		--sp_eyes:RotateAroundAxis(sp_eyes:Right(), tmprecoilang.p)
		--sp_eyes:Normalize()
		--sp_eyes:RotateAroundAxis(sp_eyes:Up(), tmprecoilang.y)
		sp_eyes.p = sp_eyes.p + tmprecoilang.p
		sp_eyes:Normalize()
		self.Owner:SetEyeAngles(sp_eyes)
	end
	
	if CLIENT and !game.SinglePlayer() and !self.Owner:IsNPC() then
		local tmprecoilang2 = Angle(math.Rand(self.Primary.KickDown,self.Primary.KickUp) * recoil * -1, math.Rand(-self.Primary.KickHorizontal,self.Primary.KickHorizontal) * recoil, 0)

		local eyes = self.Owner:EyeAngles()
		--local vpa = self.Owner:GetViewPunchAngles()
		--eyes:RotateAroundAxis(eyes:Right(), tmprecoilang2.p)
		--eyes:Normalize()
		--eyes:RotateAroundAxis(eyes:Up(), tmprecoilang2.y)
		eyes.p = eyes.p + tmprecoilang2.p
		eyes:Normalize()
		self.Owner:SetEyeAngles(eyes)
	end
	
	local nvpa = self.Owner:GetViewPunchAngles()
	local overamount = math.abs(self.Owner:EyeAngles().p + nvpa.p)-89
	
	self.Owner:SetViewPunchAngles( Angle(math.Approach(nvpa.p,0,overamount),nvpa.y,nvpa.r) )
	
end