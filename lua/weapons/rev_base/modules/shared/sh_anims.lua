--[[ 
Function Name:  RevManageAnims
Syntax: self:RevManageAnims().  Call as much as you like.
Returns:  Nothing.
Notes:  This is the main bulkhead for handling Anims. I do not LUA bob code so anims are hardcoded to events.
Purpose:  Autodetection
]]--

function SWEP:RevManageAnims()

	if not IsFirstTimePredicted() then return end

	local ply = self:GetOwner()
	local vm = ply:GetViewModel()
	local oa = self.OwnerActivity
	local cv = ply:Crouching()
	local walking = (ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT) or ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK)) && not ply:KeyDown(IN_SPEED)
	local sprinting = self:GetSprinting()

	if self:GetDrawing() then return end

	if self:GetReloading() then return end

	if not self.HasDetectedValidAnimations then
		self:DetectValidAnimations()
	end

	if not walking && not sprinting then
		self:ChooseIdleAnim()
	elseif walking then
		local success = self:ChooseWalkAnim()
		if not success then
			self:ChooseIdleAnim()
		else
			self:ChooseWalkAnim()
		end
	elseif sprinting && not cv then
		local success = self:ChooseSprintAnim()
		if not success then
			self:ChooseIdleAnim()
		else
			self:ChooseSprintAnim()
		end
	end
end


--WIP SYSTEM TO CACHE ANIMATIONS INSTEAD OF RUNNING IT PER TICK.

--[[
Function Name:  CacheAnimations
Syntax: self:CacheAnimations( ).  Call as much as you like.
Returns:  Nothing.
Notes:  This is what autodetects animations for the SWEP.SequenceEnabled and SWEP.SequenceLength tables.
Purpose:  Autodetection
]]--


--[[
SWEP.actlist = {ACT_VM_DRAW, ACT_VM_DRAW_EMPTY, ACT_VM_DRAW_SILENCED, ACT_VM_DRAW_DEPLOYED, ACT_VM_HOLSTER, ACT_VM_HOLSTER_EMPTY, ACT_VM_IDLE, ACT_VM_IDLE_EMPTY, ACT_VM_IDLE_SILENCED, ACT_VM_PRIMARYATTACK, ACT_VM_PRIMARYATTACK_1, ACT_VM_PRIMARYATTACK_EMPTY, ACT_VM_PRIMARYATTACK_SILENCED, ACT_VM_SECONDARYATTACK, ACT_VM_RELOAD, ACT_VM_RELOAD_EMPTY, ACT_VM_RELOAD_SILENCED, ACT_VM_ATTACH_SILENCER, ACT_VM_RELEASE, ACT_VM_DETACH_SILENCER, ACT_VM_FIDGET, ACT_VM_FIDGET_EMPTY, ACT_SHOTGUN_RELOAD_START}
--If you really want, you can remove things from SWEP.actlist and manually enable animations and set their lengths.
SWEP.SequenceEnabled = {}
SWEP.SequenceLength = {}
SWEP.SequenceLengthOverride = {} --Override this if you want to change the length of a sequence but not the next idle

SWEP.ActCache = {}

local vm,seq

function SWEP:CacheAnimations()

	table.Empty(self.ActCache)

	if self.CanBeSilenced and self.SequenceEnabled[ACT_VM_IDLE_SILENCED] == nil then
		self.SequenceEnabled[ACT_VM_IDLE_SILENCED] = true
	end

	if not self:VMIV() then return end
	vm = self.OwnerViewModel

	if IsValid(vm) then

		for k, v in ipairs(self.actlist) do
			seq = vm:SelectWeightedSequence(v)

			if seq ~= -1 and vm:GetSequenceActivity(seq) == v and not self.ActCache[seq] then
				self.SequenceEnabled[v] = true
				self.SequenceLength[v] = vm:SequenceDuration(seq)
				self.ActCache[seq] = v
			else
				self.SequenceEnabled[v] = false
				self.SequenceLength[v] = 0.0
			end
		end
	else
		return false
	end

	if self.ProceduralHolsterEnabled == nil then
		if self.SequenceEnabled[ACT_VM_HOLSTER] then
			self.ProceduralHolsterEnabled = false
		else
			self.ProceduralHolsterEnabled = true
		end
	end

	if string.find(self:GetClass(),"nmrih") then
		self.ShotgunEmptyAnim = false
	end

	self.HasDetectedValidAnimations = true

	return true
end

--]]


--[[
Function Name:  DetectValidAnimations
Syntax: self:DetectValidAnimations( ).  Call as much as you like.
Returns:  Nothing.
Notes:  This is what autodetects animations for the SWEP.SequenceEnabled and SWEP.SequenceLength tables.
Purpose:  Autodetection
]]--

function SWEP:DetectValidAnimations()
	if !IsValid(self) then
		return
	end
	
	if self.CanBeSilenced then
		if self.SequenceEnabled[ACT_VM_IDLE_SILENCED] == nil then
			self.SequenceEnabled[ACT_VM_IDLE_SILENCED] = true
		end
	end
	
	if !IsValid(self.Owner) then return end
	
	local vm=self.Owner:GetViewModel()
	if IsValid(vm) then
		local seq
		
		for k,v in pairs(self.actlist) do
			seq=vm:SelectWeightedSequence(v)
			
			if seq!=-1 then
				self.SequenceEnabled[v]=true
				self.SequenceLength[v] = vm:SequenceDuration( seq )
			else
				self.SequenceEnabled[v]=false
				self.SequenceLength[v] = 0.3
			end
			
			if (v == ACT_VM_IDLE_SILENCED or v == ACT_VM_RELOAD_SILENCED or v == ACT_VM_PRIMARYATTACK_SILENCED) and self.CanBeSilenced then
				self.SequenceEnabled[v]=true
				self.SequenceLength[v] = vm:SequenceDuration( seq )
				if !self.SequenceLength[v] or self.SequenceLength[v]<=0.01 then
					self.SequenceLength[v]=0.3
				end
			end
				
			
		end
		
		seq=vm:SelectWeightedSequence(ACT_VM_DRYFIRE)
		
		if seq!=-1 and seq != vm:SelectWeightedSequence(ACT_VM_PRIMARYATTACK) then
			self.SequenceEnabled[ACT_VM_DRYFIRE]=true
		end
		
		seq=vm:SelectWeightedSequence(ACT_VM_DRYFIRE_SILENCED)
		
		if seq!=-1 and seq != vm:SelectWeightedSequence(ACT_VM_PRIMARYATTACK_SILENCED) then
			self.SequenceEnabled[ACT_VM_DRYFIRE_SILENCED]=true
		end
		
	else
		return false
	end
	
	if self.CanBeSilenced then
		if self.SequenceEnabled[ACT_VM_IDLE_SILENCED] == nil then
			self.SequenceEnabled[ACT_VM_IDLE_SILENCED] = true
		end
	end
	
	self.HasDetectedValidAnimations = true

	return true
	
end

--[[ 
Function Name:  ChooseSprintAnim
Syntax: self:ChooseSprintAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.
Purpose:  Animation / Utility
]]--

function SWEP:ChooseSprintAnim()
	if !self:OwnerIsValid() then return end
	local tanim = ACT_RUN
	local success = true
		
	if self.SequenceEnabled[ACT_RUN] then
		if self:GetSprinting() then
			self:SendWeaponAnim(ACT_RUN)
			tanim=ACT_RUN
		end
	else
		local _,tanim2 = self:ChooseIdleAnim()
		tanim = tanim2
		success=false
	end
	
	self.lastact = tanim
	return success, tanim
end

function SWEP:ChooseWalkAnim()
	if !self:OwnerIsValid() then return end
	local tanim = ACT_WALK
	local success = true
		
	if self.SequenceEnabled[ACT_WALK] then
		self:SendWeaponAnim(ACT_WALK)
		tanim=ACT_WALK
	else
		local _,tanim2 = self:ChooseIdleAnim()
		tanim = tanim2
		success=false
	end
	
	self.lastact = tanim
	return success, tanim
end

--[[ 
Function Name:  ChooseDrawAnim
Syntax: self:ChooseDrawAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.
Purpose:  Animation / Utility
]]--

function SWEP:ChooseDrawAnim()
	if !self:OwnerIsValid() then return end
	local tanim = ACT_VM_DRAW
	local success = true
	if self.SequenceEnabled[ACT_VM_DRAW_SILENCED] and self:GetSilenced() then
		self:SendWeaponAnim(ACT_VM_DRAW_SILENCED)
		tanim=ACT_VM_DRAW_SILENCED
	else
		if self.SequenceEnabled[ACT_VM_DRAW_DEPLOYED] then
			if (self.isfirstdraw == true) then
				self:SendWeaponAnim(ACT_VM_DRAW_DEPLOYED)
				tanim=ACT_VM_DRAW_DEPLOYED
			else
				if self.SequenceEnabled[ACT_VM_DRAW] then
					self:SendWeaponAnim(ACT_VM_DRAW)
				else
					local _,tanim2 = self:ChooseIdleAnim()
					tanim = tanim2
					success=false
				end
			end
		else
			if self.SequenceEnabled[ACT_VM_DRAW] then
				self:SendWeaponAnim(ACT_VM_DRAW)
			else
				local _,tanim2 = self:ChooseIdleAnim()
				tanim = tanim2
				success=false
			end
		end
	end
	self.lastact = tanim
	return success, tanim
end
--[[ 
Function Name:  ChooseInspectAnim
Syntax: self:ChooseInspectAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.
Purpose:  Animation / Utility
]]--

function SWEP:ChooseInspectAnim()
	if !self:OwnerIsValid() then return end
	local tanim = ACT_VM_FIDGET
	local success = true
	if self.SequenceEnabled[ACT_VM_FIDGET] then
		--[[
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			vm:SetSequence(vm:SelectWeightedSequence(ACT_VM_FIDGET))
			print(vm:SelectWeightedSequence(ACT_VM_FIDGET))
		end
		]]--
		self:SendWeaponAnim(ACT_VM_FIDGET)
		tanim=ACT_VM_FIDGET
	else
		local _,tanim2 = self:ChooseIdleAnim()
		tanim = tanim2
		success=false
	end
	self.lastact = tanim
	
	return success, tanim
end

--[[ 
Function Name:  ChooseHolsterAnim
Syntax: self:ChooseHolsterAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.
Purpose:  Animation / Utility
]]--

function SWEP:ChooseHolsterAnim()
	if !self:OwnerIsValid() then return end
	local tanim = ACT_VM_HOLSTER
	local success = true
	if !self:GetSilenced() then
		if self.SequenceEnabled[ACT_VM_HOLSTER_EMPTY] then
			if ( self:Clip1()==0 ) then
				self:SendWeaponAnim(ACT_VM_HOLSTER_EMPTY)
				tanim = ACT_VM_HOLSTER_EMPTY
			else
				if self.SequenceEnabled[ACT_VM_HOLSTER] then
					self:SendWeaponAnim(ACT_VM_HOLSTER)
				else
					self:SendWeaponAnim(ACT_VM_HOLSTER_EMPTY)
					tanim = ACT_VM_HOLSTER_EMPTY
				end	
			end
		else
			if self.SequenceEnabled[ACT_VM_HOLSTER] then
				self:SendWeaponAnim(ACT_VM_HOLSTER)
			else
				local _,tanim2 = self:ChooseIdleAnim()
				tanim=tanim2
				success=false
			end
		end
	else
		local _,tanim2 = self:ChooseIdleAnim()
		tanim=tanim2
		success=false
	end
	self.lastact = tanim
	
	return success, tanim
end

--[[ 
Function Name:  ChooseReloadAnim
Syntax: self:ChooseReloadAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.
Purpose:  Animation / Utility
]]--

function SWEP:ChooseReloadAnim()
	if !self:OwnerIsValid() then return end
	local tanim = ACT_VM_RELOAD
	local success = true
	if self.SequenceEnabled[ACT_VM_RELOAD_SILENCED] and self:GetSilenced() then
		self:SendWeaponAnim(ACT_VM_RELOAD_SILENCED)
		tanim=ACT_VM_RELOAD_SILENCED
	else
		if self.SequenceEnabled[ACT_VM_RELOAD_EMPTY] then
			if (self:Clip1()==0) then
				self:SendWeaponAnim(ACT_VM_RELOAD_EMPTY)
				tanim=ACT_VM_RELOAD_EMPTY
			else
				if self.SequenceEnabled[ACT_VM_RELOAD] then
					self:SendWeaponAnim(ACT_VM_RELOAD)
				else
					local _,tanim2 = self:ChooseIdleAnim()
					tanim = tanim2
					success=false
				end
			end
		else
			if self.SequenceEnabled[ACT_VM_RELOAD] then
				self:SendWeaponAnim(ACT_VM_RELOAD)
			else
				local _,tanim2 = self:ChooseIdleAnim()
				tanim = tanim2
				success=false
			end
		end
	end
	self.lastact = tanim
	return success, tanim
end

--[[ 
Function Name:  ChooseIdleAnim
Syntax: self:ChooseIdleAnim().
Returns:  True,  Which action?
Notes:  Requires autodetection for full features.
Purpose:  Animation / Utility
]]--

function SWEP:ChooseIdleAnim()
	if !self:OwnerIsValid() then return end
	local tanim=ACT_VM_IDLE

	if self.SequenceEnabled[ACT_VM_IDLE_EMPTY] then
		self:SendWeaponAnim(ACT_VM_IDLE)
	end

	self.lastact = tanim
	return true, tanim
end

--[[ 
Function Name:  ChooseShootAnim
Syntax: self:ChooseShootAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.
Purpose:  Animation / Utility
]]--

function SWEP:ChooseShootAnim()
	if !self:OwnerIsValid() then return end
	local tanim=ACT_VM_PRIMARYATTACK
	local success = true
	if self.SequenceEnabled[ACT_VM_PRIMARYATTACK_SILENCED]  and self:GetSilenced() then
		if self.SequenceEnabled[ACT_VM_DRYFIRE_SILENCED] and !self.ForceDryFireOff then
			if (self:Clip1()==0) then
				self:SendWeaponAnim(ACT_VM_DRYFIRE_SILENCED)
				tanim=ACT_VM_DRYFIRE_SILENCED
			else
				self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_SILENCED)
				tanim=ACT_VM_PRIMARYATTACK_SILENCED
			end
		else
			if (self:Clip1()==0) then
				success=false
				local _
				_, tanim = self:ChooseIdleAnim()
			else
				self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_SILENCED)
				tanim=ACT_VM_PRIMARYATTACK_SILENCED
			end
		end			
	else
		if ( self.SequenceEnabled[ACT_VM_DRYFIRE] or self.SequenceEnabled[ACT_VM_PRIMARYATTACK_EMPTY] ) then
			if (self:Clip1()==0 and  self.SequenceEnabled[ACT_VM_DRYFIRE] and !self.ForceDryFireOff ) then
				self:SendWeaponAnim(ACT_VM_DRYFIRE)
				tanim=ACT_VM_DRYFIRE
			elseif (self:Clip1()==1 and self.SequenceEnabled[ACT_VM_PRIMARYATTACK_EMPTY]  and !self.ForceEmptyFireOff ) then
				if self.SequenceEnabled[ACT_VM_PRIMARYATTACK_EMPTY] then
					self:SendWeaponAnim(ACT_VM_PRIMARYATTACK_EMPTY)
					success=true
					tanim = ACT_VM_PRIMARYATTACK_EMPTY
				else
					success=true
					tanim = ACT_VM_PRIMARYATTACK
					self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
				end			
			else
				if self.SequenceEnabled[ACT_VM_PRIMARYATTACK] then
					self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
				else
					success=false
					local _
					_, tanim = self:ChooseIdleAnim()
				end
			end
		else
			if self.SequenceEnabled[ACT_VM_PRIMARYATTACK] then
				self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
			else
				success=false
				local _
				_, tanim = self:ChooseIdleAnim()
			end
		end
	end
	
	if self.Akimbo then
		if self.SequenceEnabled[ACT_VM_SECONDARYATTACK] and self.AnimCycle==1 then
			self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
		end
		self.AnimCycle = 1 - self.AnimCycle
	end	
	
	self.lastact = tanim
	return success, tanim
end

--[[ 
Function Name:  ChooseSilenceAnim
Syntax: self:ChooseSilenceAnim( true if we're silencing, false for detaching the silencer).
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.  This is played when you silence or unsilence a gun.  
Purpose:  Animation / Utility
]]--

function SWEP:ChooseSilenceAnim( val )
	if !self:OwnerIsValid() then return end
	local tanim=ACT_VM_PRIMARYATTACK
	local success = false
	if val then
		if self.SequenceEnabled[ACT_VM_ATTACH_SILENCER] then
			self:SendWeaponAnim(ACT_VM_ATTACH_SILENCER)
			tanim=ACT_VM_ATTACH_SILENCER
			success=true
		end
	else
		if self.SequenceEnabled[ACT_VM_DETACH_SILENCER] then
			self:SendWeaponAnim(ACT_VM_DETACH_SILENCER)
			tanim=ACT_VM_DETACH_SILENCER
			success=true
		end
	end
	if !success then
		local _
		_, tanim = self:ChooseIdleAnim()
	end
	self.lastact = tanim
	return success, tanim
	
end

--[[ 
Function Name:  ChooseDryFireAnim
Syntax: self:ChooseDryFireAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.  set SWEP.ForceDryFireOff to false to properly use.
Purpose:  Animation / Utility
]]--

function SWEP:ChooseDryFireAnim()
	if !self:OwnerIsValid() then return end
	local tanim=ACT_VM_DRYFIRE
	local success = true
	if self.SequenceEnabled[ACT_VM_DRYFIRE_SILENCED] and self:GetSilenced() and !self.ForceDryFireOff then
		self:SendWeaponAnim(ACT_VM_DRYFIRE_SILENCED)
		tanim=ACT_VM_DRYFIRE_SILENCED
	else
		if self.SequenceEnabled[ACT_VM_DRYFIRE] and !self.ForceDryFireOff then
			self:SendWeaponAnim(ACT_VM_DRYFIRE)
			tanim=ACT_VM_DRYFIRE
		else
			success=false
			local _
			_, tanim = self:ChooseIdleAnim()
		end
	end
	self.lastact = tanim
	return success, tanim
end