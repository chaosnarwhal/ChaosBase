AddCSLuaFile()
--[[---------------------------------------------------------
	Name: SWEP:TakePrimaryAmmo()
	Desc: A convenience function to remove ammo
-----------------------------------------------------------]]
function SWEP:TakePrimaryAmmo( num )

	-- Doesn't use clips
	if ( self:Clip1() <= 0 ) then

		if ( self:Ammo1() <= 0 ) then return end

		self.Owner:RemoveAmmo( num, self:GetPrimaryAmmoType() )

	return end

	self:SetClip1( self:Clip1() - num )

end
--[[---------------------------------------------------------
	Name: SWEP:ShootEffects()
	Desc: A convenience function to remove ammo
-----------------------------------------------------------]]
function SWEP:ShootEffects()
	local vm = self:GetOwner():GetViewModel()
	--self:SendWeaponAnim(self.PrimaryAnim)
	local firetime = 0
	local fireseq = self:SelectWeightedSequence(ACT_VM_PRIMARYATTACK)

	firetime = self:SequenceDuration(fireseq)

   	self.IdleTimer = CurTime() + firetime

   	vm:SendViewModelMatchingSequence(fireseq)

   	self:GetOwner():MuzzleFlash()
   	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
end

--[[---------------------------------------------------------
	Name: SWEP:ShootBullet()
	Desc: Function to handle Viewpunch,Recoil,and spread. As well sling some funny little bullets at who ever is the poor sucker on the other end of the trace.
-----------------------------------------------------------]]
function SWEP:ShootBullet( damage, num, cone, tracer )

	self:ShootEffects()

   	num = num or 1
   	cone = cone or vector(0,0,0)
   	damage = damage or 1
   	tracer = tracer or 4

   	local bullet = {}
   	bullet.Num    = num
   	bullet.Src    = self:GetOwner():GetShootPos()
   	bullet.Dir    = self:GetOwner():GetAimVector()
   	bullet.Spread = cone
   	bullet.Tracer = tracer
   	bullet.TracerName = self.Tracer or "Tracer"
   	bullet.Force  = 10
   	bullet.Damage = damage

   	-- Owner can die after firebullets
   	if (not IsValid(self:GetOwner())) or (not self:GetOwner():Alive()) or self:GetOwner():IsNPC() then return end

   	 --FireBullets is by default a lag Compped function. By calling FireBullets inside of Shoot bullets it *Shouldn't Break*
   	self:GetOwner():FireBullets( bullet )

   	self:UpdateBloom()
end

--[[---------------------------------------------------------
	Name: SWEP:BloomScore()
	Desc: Update the bloom of the weapon from accurate to inaccurate after sustained fire.
-----------------------------------------------------------]]
function SWEP:BloomScore()
	if self.Base != "rev_base" then
		local ply = self:GetOwner()
		local cv = ply:Crouching()
		local sk = ply:KeyDown(IN_SPEED)
		local mk = (ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT) or ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK))
		local plidle = (!mk && !sk && !cv)
		local issprinting = sk && mk

		self.BloomScoreName = "BloomScore_".. ply:Name()
		
		timer.Create(self.BloomScoreName, (60 / self.Primary.RPM) * 3, 0, function() 
			if !self:IsValid() then return end
			if self.BloomValue == 0 then return end
			
			local bs = self.BloomValue
			local pbs = self.PrevBS
			if self.SightsDown == false then
				if plidle then
					self.PrevBS = math.Clamp( bs, 0, 1.7)
					self.BloomValue = math.Clamp( bs - (self.Primary.Kick * 1.5), 0, 1)
				elseif cv then
					self.PrevBS = math.Clamp( bs, 0, 1.7)
					self.BloomValue = math.Clamp( bs - (self.Primary.Kick * 1.75), 0, 1)
				elseif mk then
					self.PrevBS = math.Clamp( bs, 0, 1.7)
					self.BloomValue = math.Clamp( bs - self.Primary.Kick * 2 +0.1, 0, 1.3)
				elseif issprinting then
					self.PrevBS = math.Clamp( bs, 0, 1.7)
					self.BloomValue = math.Clamp( bs - self.Primary.Kick * 2 +0.3, 0, 1.7)
				end
			else
				if plidle then
					self.PrevBS = math.Clamp( bs, 0, 1.7)
					self.BloomValue = math.Clamp( bs - ((self.Primary.Kick * 2) / 1.5), 0, 1)
				elseif cv then
					self.PrevBS = math.Clamp( bs, 0, 1.7)
					self.BloomValue = math.Clamp( bs - ((self.Primary.Kick * 2) / 3), 0, 1)
				elseif mk then
					self.PrevBS = math.Clamp( bs, 0, 1.7)
					self.BloomValue = math.Clamp( bs - (self.Primary.Kick +0.1) /2, 0, 1)
				elseif issprinting then
					self.PrevBS = math.Clamp( bs, 0, 1.7)
					self.BloomValue = math.Clamp( bs - (self.Primary.Kick +0.3) /2, 0, 1)
				end
			end
		--	print(self.BloomValue)
		end)
		
	repeat until timer.Exists(self.BloomScoreName)
	end
end

--[[---------------------------------------------------------
	Name: SWEP:UpdateBloom()
	Desc: Update the bloom of the weapon from accurate to inaccurate after sustained fire.
-----------------------------------------------------------]]
function SWEP:UpdateBloom()
	local ply = self:GetOwner()
	if !ply:IsPlayer() then return end
	local cv = ply:Crouching()
	local sk = ply:KeyDown(IN_SPEED)
	local mk = (ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT) or ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK))
	local plidle = (!mk && !sk && !cv)
	local issprinting = sk && mk
	
	self.Kick = self.Primary.Kick
	
	local bs = self.BloomValue
	local pbs = self.PrevBS
	if bs == nil then bs = 0 end
	if pbs == nil then pbs = 0 end
	if self.SightsDown == false then
		if plidle or sk then
			self.PrevBS = math.Clamp( bs, 0, 1.7)
			self.BloomValue = math.Clamp( self.BloomValue + self.Kick, 0, 1)
		elseif cv then
			self.PrevBS = math.Clamp( bs, 0, 1.7)
			self.BloomValue = math.Clamp( self.BloomValue + self.Kick / 1.25, 0, 1)
		elseif mk then
			self.PrevBS = math.Clamp( bs, 0, 1.7)
			self.BloomValue = math.Clamp( self.BloomValue + self.Kick +0.1, 0, 1.3)
		elseif issprinting then
			self.PrevBS = math.Clamp( bs, 0, 1.7)
			self.BloomValue = math.Clamp( self.BloomValue + self.Kick +0.3, 0, 1.7)
		end
	else
		if plidle or sk then
			self.PrevBS = math.Clamp( bs, 0, 1.7)
			self.BloomValue = math.Clamp( self.BloomValue + self.Primary.Kick /2, 0, 1)
		elseif cv then
			self.PrevBS = math.Clamp( bs, 0, 1.7)
			self.BloomValue = math.Clamp( self.BloomValue + (self.Primary.Kick /1.25) /2, 0, 1)
		elseif mk then
			self.PrevBS = math.Clamp( bs, 0, 1.7)
			self.BloomValue = math.Clamp( self.BloomValue + (self.Primary.Kick +0.1) /2, 0, 1)
		elseif issprinting then
			self.PrevBS = math.Clamp( bs, 0, 1.7)
			self.BloomValue = math.Clamp( self.BloomValue + (self.Primary.Kick +0.3) /2, 0, 1)
		end
	end
	
	ply:SetNWInt("PrevBS", self.BloomValue * 10)
end

--[[---------------------------------------------------------
	Name: SWEP:GetBS()
	Desc: A convenience function to check our bloom value.
-----------------------------------------------------------]]
function SWEP:GetBS()
	return self.BloomValue
end

--[[---------------------------------------------------------
	Name: SWEP:GetPBS()
	Desc: A convenience function to check our bloom value.
-----------------------------------------------------------]]
function SWEP:GetPBS()
	return self.PrevBS
end

--[[---------------------------------------------------------
	Name: SWEP:CalculateSpread()
	Desc: Calculate the bloom and spread of the weapon.
	RetV: Are we firing an entitiy out of this gun? if so change some of the bloom values.
-----------------------------------------------------------]]
function SWEP:CalculateSpread()
	if not IsValid(self) then return end
	local ply = self:GetOwner()
	
	local calc = self.Primary.Spread / self.Primary.SpreadDiv

	if ply:IsPlayer() then 
		return Vector( calc, calc, 0 ) * self.BloomValue
	end

end
