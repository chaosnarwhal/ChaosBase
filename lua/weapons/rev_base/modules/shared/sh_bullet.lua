
SWEP.lastbul = nil
SWEP.lastbulnoric = false

--[[ 
Function Name:  cpbullet
Syntax: self:cpbullet( bullet table 1, bullet table 2 ). 
Returns:   Nothing.
Notes:    Copies bullet 2's properties to bullet 1, reducing table count.
Purpose:  Utility
]]--

function cpbullet(tb1, tb2)
	tb1.Num = tb2.Num
	tb1.Src = tb2.Src
	tb1.Dir = tb2.Dir
	tb1.Spread = tb2.Spread
	tb1.Tracer = tb2.Tracer
	tb1.TracerName = tb2.TracerName
	tb1.Force = tb2.Force
	tb1.Damage = tb2.Damage
end

local mainbul = {}

mainbul.Num 		= 1
mainbul.Src 		= Vector(0,0,0)		-- Source
mainbul.Dir 		= Vector(0,0,0)			-- Dir of bullet
mainbul.Spread 		= Vector(0,0,0)			-- Aim Cone
mainbul.Tracer		= 0							-- Show a tracer on every x bullets
mainbul.TracerName 	= "None"
mainbul.Force		= 0.01
mainbul.Damage		= 0.01

--[[ 
Function Name:  ShootBulletInformation
Syntax: self:ShootBulletInformation( ). 
Returns:   Nothing.
Notes:    Used to generate a bullet table which is then sent to self:ShootBullet, and also to call shooteffects.
Purpose:  Bullet
]]--

function SWEP:ShootBulletInformation()
	self.lastbul = nil
	self.lastbulnoric = false
	
	if (CLIENT and !game.SinglePlayer()) and !IsFirstTimePredicted() then return end


	local CurrentDamage
	local CurrentCone, CurrentRecoil = self:CalculateConeRecoil()
	
	local tmpranddamage = math.Rand(GetConVarNumber("sv_rev_damage_mult_min",0.95),GetConVarNumber("sv_rev_damage_mult_max",1.05))
	
	basedamage = self.Primary.Damage
	CurrentDamage = basedamage * tmpranddamage
	
	if self.DoMuzzleFlash and ( (SERVER) or ( CLIENT and !self.AutoDetectMuzzleAttachment ) or (CLIENT and !self:IsFirstPerson() )  )then
		self:ShootEffects()
	end
	
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

	local TracerName
	
	if self.Tracer == 1 then
		TracerName = "Ar2Tracer"
	elseif self.Tracer == 2 then
		TracerName = "AirboatGunHeavyTracer"
	else
		TracerName = "Tracer"
	end
	if self.TracerName then
		TracerName = self.TracerName
	end
	mainbul.Num 		= num_bullets
	mainbul.Src 		= self.Owner:GetShootPos()			-- Source
	mainbul.Dir 		= self.Owner:GetAimVector()			-- Dir of bullet
	mainbul.Spread.x=aimcone-- Aim Cone X
	mainbul.Spread.y=aimcone-- Aim Cone Y
	mainbul.Tracer	= 3							-- Show a tracer on every x bullets
	mainbul.TracerName = TracerName
	mainbul.Force	= damage/3 * math.sqrt((self.Primary.KickUp+self.Primary.KickDown+self.Primary.KickHorizontal )) -- Amount of force to give to phys objects
	mainbul.Damage	= damage
	
	if bulletoverride then
		cpbullet(mainbul,bulletoverride)
	end
	
	self.lastbul = mainbul
	self.lastbulnoric = disablericochet
	self.Owner:FireBullets(mainbul)
	self:Recoil( recoil )
end

--[[ 
Function Name:  revCheckRicochetGateway
Syntax: revCheckRicochetGateway(self, bullet table, traceres). 
Returns:   Nothing.
Notes:    Used to pick up the proper weapon entitity and bullet table and do the ricochet check on it.
Purpose:  Bullet
]]--

--[[ 
Function Name:  CheckRicochet
Syntax: self:CheckRicochet(bullet table, traceres). 
Returns:   Nothing.
Notes:    Used to test ricochet and call the penetration function.
Purpose:  Bullet
]]--

function SWEP:CheckRicochet(bullet, tr)
	if ( CLIENT and !SERVER) and !IsFirstTimePredicted() then return false end
	
	if !tr.Hit or tr.HitSky then return false end
	
	self.PenetrationCounter = self.PenetrationCounter + 1
	if self.PenetrationCounter > self.MaxPenetrationCounter then
		self.PenetrationCounter = 0
		return
	end
		
	local bulletdistance =  ( ( tr.HitPos - tr.StartPos ):Length( ) )
	local damagescale = bulletdistance / self.Primary.Range
	damagescale = math.Clamp(damagescale - self.Primary.RangeFalloff,0,1)
	damagescale = math.Clamp(damagescale / math.max(1-self.Primary.RangeFalloff,0.01),0,1)
	damagescale = ( 1-GetConVarNumber("sv_rev_range_modifier",0.5) ) + ( math.Clamp(1-damagescale,0,1) * GetConVarNumber("sv_rev_range_modifier",0.5) )
	
	bullet.Damage = bullet.Damage * damagescale
	bullet.Force = bullet.Force * damagescale
	
	local matname = self:GetMaterialConcise( tr.MatType )
	local ricochetchance = 1
	local dir = (tr.HitPos-tr.StartPos)
	dir:Normalize()
	local dp =  dir:Dot(tr.HitNormal*-1)
	if matname == "glass" then
		ricochetchance = 0
	elseif matname == "plastic" then
		ricochetchance = 0.01
	elseif matname == "dirt" then
		ricochetchance = 0.01
	elseif matname == "grass" then
		ricochetchance = 0.01
	elseif matname == "sand" then
		ricochetchance = 0.01
	elseif matname == "ceramic" then
		ricochetchance = 0.15
	elseif matname == "metal" then
		ricochetchance = 0.7
	elseif matname == "default" then
		ricochetchance = 0.5
	else
		ricochetchance = 0
	end
	
	ricochetchance = ricochetchance * 0.5 * self:GetAmmoRicochetMultiplier()
	
	local riccbak = ricochetchance / 0.7
	local ricothreshold = 0.6
	ricochetchance = math.Clamp(ricochetchance + ricochetchance * math.Clamp(1-(dp+ricothreshold),0,1) * 0.5,0,1)
	if dp<=ricothreshold then
		if math.Rand(0,1)<ricochetchance then
			cpbullet(ricbul,bullet)
			ricbul.Damage = ricbul.Damage * 0.5
			ricbul.Force = ricbul.Force * 0.5
			ricbul.Num = 1
			ricbul.Spread = vector_origin
			ricbul.Src=tr.HitPos
			ricbul.Dir=((2 * tr.HitNormal * dp) + tr.Normal) + (VectorRand() * 0.02)
			ricbul.Tracer=0
			ricbul.TracerName = "None"
			
			if GetConVarNumber("cl_rev_fx_impact_ricochet_enabled",1) == 1 and GetConVarNumber("cl_rev_fx_impact_enabled",1)==1 then
				local fx = EffectData()
				fx:SetOrigin(ricbul.Src)
				fx:SetNormal(ricbul.Dir)
				fx:SetMagnitude(riccbak)
				util.Effect("rev_ricochet",fx)
			end
			
			if IsValid(self) then
				self:ShootBullet(0,0,0,vector_origin,false,ricbul)
			end
			
			return true
		end
	end
	
	return false
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