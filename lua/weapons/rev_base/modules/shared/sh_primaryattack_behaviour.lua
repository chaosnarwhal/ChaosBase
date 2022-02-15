AddCSLuaFile()
--[[ 
Function Name:  PrimaryAttack
Syntax: self:PrimaryAttack().  However, to shoot a bullet, ShootBulletInformation or ShootBullet should be called.  This is really only for when the player or the burst fire mechanism willingly fires.
Returns:  Nothing.
Notes: Called when you try to primaryattack.
Purpose:  Main SWEP function
]]--

function SWEP:PrimaryAttack()
	

	--Low TickRate RPM Fix.
	local delay = 60 / self.Primary.RPM

	local curtime = CurTime()
	local curatt = self:GetNextPrimaryFire()
	local diff = curtime - curatt

	if diff > engine.TickInterval() or diff < 0 then
		curatt = curtime
	end

	--Are we holster? Than don't shoot.
	if ( self:GetHolstering() ) then
		if (self.ShootWhileHolster==false) then
			return
		else
			self:SetHolsteringEnd(CurTime()-0.1)
			self:SetHolstering(false)
		end
	end
	
	--If the weapon is saftey you cant shoot either.
	if self:IsSafety() then self.Weapon:EmitSound("Weapon_AR2.Empty") return end
	
	--Are you too close to a wall? how would you shoot that close anyways..
	if (self:GetNearWallRatio()>0.05) then
		return
	end
	
	--Are you valid? do you exist? we'll find out here. If you don't exist than how are you even holding this weapon.
	if !self:OwnerIsValid() then return end
	
	--Underwater weapon handling. As firing underwater SHOULD change how the weapon handles.
	if self.FiresUnderwater == false and self.Owner:WaterLevel()>=3 then
		if self:CanPrimaryAttack() then
			self:SetNextPrimaryFire(CurTime()+0.5)
			self.Weapon:EmitSound("Weapon_AR2.Empty")
		end
		return
	end
	
	--Shotgun Handling.
	if (self:GetReloading() and self.Shotgun and !self:GetShotgunPumping() and !self:GetShotgunNeedsPump()) then
		self:SetShotgunCancel( true )
		--[[
		self:SetShotgunInsertingShell(true)
		self:SetShotgunPumping(false)
		self:SetShotgunNeedsPump(true)
		self:SetReloadingEnd(CurTime()-1)
		]]--
	end
	
	--Can the man truly attack? if he does lets start running some fun times stuff.
	if self:CanPrimaryAttack() and self.Owner:IsPlayer() then
		if self:GetReloading()==false and self:GetSprinting()==false then
			self:SetInspecting(false)
			self:SetInspectingRatio(0)
			self:SetInspectingRatio(0)
			self:SendWeaponAnim(0)
			self:ShootBulletInformation()
			local success, tanim = self:ChooseShootAnim( ) -- View model animation
			if self:OwnerIsValid() and self.Owner.SetAnimation then
				self.Owner:SetAnimation( PLAYER_ATTACK1 ) -- 3rd Person Animation
			end
			self:TakePrimaryAmmo(1)
			self:SetShooting(true)
			local vm = self.Owner:GetViewModel()
			if tanim then
				local seq = vm:SelectWeightedSequence(tanim)
				self:SetShootingEnd(CurTime()+vm:SequenceDuration( seq ))
			else
				self:SetShootingEnd(CurTime()+vm:SequenceDuration( ))
			end
			if self.BoltAction then
				self:SetBoltTimer(true)
				local t1, t2
				t1=CurTime()+self.BoltTimerOffset
				t2=CurTime()+vm:SequenceDuration( seq )
				if t1<t2 then
					self:SetBoltTimerStart(t1)
					self:SetBoltTimerEnd(t2)
				else
					self:SetBoltTimerStart(t2)
					self:SetBoltTimerEnd(t1)
				end
			end
			
			--Lets start setting spread when they are firing.
			self:SetSpreadRatio(math.Clamp(self:GetSpreadRatio() + self.Primary.SpreadIncrement, 1, self.Primary.SpreadMultiplierMax))
			if ( CLIENT or game.SinglePlayer() ) and ( IsFirstTimePredicted() ) then
				self.CLSpreadRatio = math.Clamp(self.CLSpreadRatio + self.Primary.SpreadIncrement, 1, self.Primary.SpreadMultiplierMax)
			end

			--Are they a Burst Weapon? Lets start our burst timer handles.
			self:SetBursting(true)
	
			self:SetNextBurst(CurTime()+1/(self:GetRPM()/60))
			self:SetBurstCount(self:GetBurstCount()+1)
			
			--The actual value that dictates RPM. Or generally when you can actually fire the weapon again.
			self:SetNextPrimaryFire(curatt + delay)
			
			--Play the sound that is associated with the weapon.
			if self.Primary.Sound then
				self:EmitSound(self.Primary.Sound)
			end
			
			--Check their ammo.
			self:DoAmmoCheck()
		end
	end
end







