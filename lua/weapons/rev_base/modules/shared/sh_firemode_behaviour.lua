--[[ 
Function Name:  CreateFireModes
Syntax: self:CreateFireModes( is first draw).  Call as much as you like.  isfirstdraw controls whether the default fire mode is set.
Returns:  Nothing.
Notes:  Autodetects fire modes depending on what params you set up.
Purpose:  Autodetection
]]--

function SWEP:CreateFireModes( isfirstdraw )
	local thasbeencreated = false
	if !self.FireModes then
		self.FireModes = {}
		local burstcnt = self:FindEvenBurstNumber()
		if self.SelectiveFire then
			if self.OnlyBurstFire then
				if burstcnt then
					self.FireModes[1]=burstcnt.."Burst"
					self.FireModes[2]="Single"
				else
					self.FireModes[1]="Single"
				end
			else
				self.FireModes[1]="Automatic"
				if self.DisableBurstFire then
					self.FireModes[2]="Single"
				else
					if burstcnt then
						self.FireModes[2]=burstcnt.."Burst"
						self.FireModes[3]="Single"
					else
						self.FireModes[2]="Single"
					end
				end
			end
		else
			if self.Primary.Automatic then
				self.FireModes[1]="Automatic"
				if self.OnlyBurstFire then
					if burstcnt then
						self.FireModes[1]=burstcnt.."Burst"
					end
				end
			else
				self.FireModes[1]="Single"
			end
		end
		thasbeencreated = true
	end
	
	if isfirstdraw or thasbeencreated then
		if self.DefaultFireMode then
			for k,v in ipairs(self.FireModes) do
				if v == self.DefaultFireMode then
					self:SetFireMode(k)
				end
			end
		end
	end
	
	if !self:GetFireMode() or self:GetFireMode() == 0 then
		if self.Primary.Automatic then
			self:SetFireMode(1)
		else
			self:SetFireMode(#self.FireModes)
		end
	end
	
	if !table.HasValue(self.FireModes,"Safe") then
		table.insert(self.FireModes,#self.FireModes+1,"Safe")
	end
	
end

--[[ 
Function Name:  ProcessFireMode
Syntax: self:ProcessFireMode()
Returns:  Nothing.
Notes: Processes fire mode changing and whether the swep is auto or not.
Purpose:  Feature
]]--

function SWEP:ProcessFireMode()
	if self.Owner:KeyPressed(IN_RELOAD) and self.Owner:KeyDown(IN_USE) and !(CLIENT and !IsFirstTimePredicted() ) then
		if  self.SelectiveFire then
			local fm = self:GetFireMode()
			fm = fm + 1
			if fm>#self.FireModes then
				fm = 1
			end
			
			self:SetFireMode(fm)
			
			self.Weapon:EmitSound("Weapon_AR2.Empty")
			
			self.Weapon:SetNextBurst( CurTime()+math.max( 1/(self:GetRPM()/60), 0.25 ) )
			self.Weapon:SetNextPrimaryFire( CurTime()+math.max( 1/(self:GetRPM()/60), 0.25 ) )

			self:SetFireModeChanging( true )
			
			self:SetFireModeChangeEnd( CurTime() + math.max( 1/(self:GetRPM()/60), 0.25 ) )
		else
			local fm = self:GetFireMode()
			if fm == 1 then
				self:SetFireMode(#self.FireModes)
			else
				self:SetFireMode(1)
			end
			
			self.Weapon:EmitSound("Weapon_AR2.Empty")
			
			self.Weapon:SetNextBurst( CurTime()+math.max( 1/(self:GetRPM()/60), 0.25 ) )
			self.Weapon:SetNextPrimaryFire( CurTime()+math.max( 1/(self:GetRPM()/60), 0.25 ) )

			self:SetFireModeChanging( true )
			
			self:SetFireModeChangeEnd( CurTime() + math.max( 1/(self:GetRPM()/60), 0.25 ) )
		end
	end
	
	if string.find(string.lower(self.FireModes[self:GetFireMode()]),"auto") then
		self.Primary.Automatic = true
	else
		self.Primary.Automatic = false
	end
end