AddCSLuaFile()

--[[ 
Function Name:  IconFix
Syntax: self:IconFix().  Call only once.  Hopefully you call this only once on like SWEP:Initialize() or something.
Returns:  Nothing.
Notes:  Fixes the icon.  Call this if you give it a texture path, or just nothing.
Purpose:  Autodetection
]]--

function SWEP:IconFix()
	local ff = file.Find(self.WepSelectIcon,"GAME")
	if !ff or #ff<=0 then
		local tstr = "materials/"..self.WepSelectIcon.."*"
		local ff2=file.Find(tstr,"GAME")
		if ff2 and #ff2>1 then
			self.WepSelectIcon = tstr
		else
			local tstr2 =  "materials/vgui/hud/"..self.ClassName.."*"
			local ff3 = file.Find(tstr2,"GAME")
			if ff3 and #ff3>=1 then
				self.WepSelectIcon = "vgui/hud/"..self.ClassName
			else
				local tstr3 =  "materials/vgui/entities/"..self.ClassName.."*"
				local ff4 = file.Find(tstr3,"GAME")
				if ff4 and #ff4>=1 then
					self.WepSelectIcon = "vgui/entities/"..self.ClassName
				else
					self.WepSelectIcon = "entities/"..self.ClassName
				end
			end
		end
	end
	self.WepSelectIcon = surface.GetTextureID(self.WepSelectIcon)
end

--[[ 
Function Name:  CorrectScopeFOV
Syntax: self:CorrectScopeFOV( fov ).  Call only once.  Hopefully you call this only once on like SWEP:Initialize() or something.
Returns:  Nothing.
Notes:  If you're using scopezoom instead of FOV, this translates it.
Purpose:  Autodetection
]]--
function SWEP:CorrectScopeFOV( fov )
	if !self.Secondary.IronFOV or self.Secondary.IronFOV==0 then
		if self.Scoped then
			self.Secondary.IronFOV = fov / (self.Secondary.ScopeZoom and self.Secondary.ScopeZoom or 2)
		else
			self.Secondary.IronFOV = 32
		end
	end
end

--[[ 
Function Name:  ResetSightsProgress
Syntax: self:ResetSightsProgress( ). 
Returns:   Nothing.
Notes:    Used to reset the progress of some stuff , idk, can you read?
Purpose:  Utility
]]--
function SWEP:ResetSightsProgress()
	self.RunSightsProgress=0
	if CLIENT then
		self.CLNearWallProgress=0 --BASE DEPENDENT VALUE.  DO NOT CHANGE OR THINGS MAY BREAK.  NO USE TO YOU.
		self.CLRunSightsProgress=0 --BASE DEPENDENT VALUE.  DO NOT CHANGE OR THINGS MAY BREAK.  NO USE TO YOU.
		self.CLIronSightsProgress=0 --BASE DEPENDENT VALUE.  DO NOT CHANGE OR THINGS MAY BREAK.  NO USE TO YOU.
		self.CLCrouchProgress=0 --BASE DEPENDENT VALUE.  DO NOT CHANGE OR THINGS MAY BREAK.  NO USE TO YOU.
		self.CLJumpProgress=0 --BASE DEPENDENT VALUE.  DO NOT CHANGE OR THINGS MAY BREAK.  NO USE TO YOU.
		self.CLSpreadRatio=0 --BASE DEPENDENT VALUE.  DO NOT CHANGE OR THINGS MAY BREAK.  NO USE TO YOU.
		self.CLAmmoHUDProgress=0 --BASE DEPENDENT VALUE.  DO NOT CHANGE OR THINGS MAY BREAK.  NO USE TO YOU.
		self.ShouldDrawAmmoHUD=false
	end
	
	self:SetIronSightsRatio(0)	
	self:SetRunSightsRatio(0)
end

--[[ 
Function Name:  DoAmmoCheck
Syntax: self:DoAmmoCheck( ). 
Returns:   Nothing.
Notes:    Used to strip the weapon depending on convars set.
Purpose:  Utility
]]--

function SWEP:DoAmmoCheck()
	if IsValid(self) then
		if SERVER and (GetConVar("sv_rev_weapon_strip"):GetBool()) then 
			if self:Clip1() == 0 && self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) == 0 then
				timer.Simple(.1, function()
					if SERVER then
						if IsValid(self) then
							if IsValid(self.Owner) then
								self.Owner:StripWeapon(self.Gun)
							end
						end
					end
				end)
			end
		end
	end
end
--[[ 
Function Name:  GetFireModeName
Syntax: self:GetFireModeName( ). 
Returns:   Firemode name.
Notes:    Returns either the custom name you force or the autodetected one.
Purpose:  Utility
]]--

function SWEP:GetFireModeName()
	
	local fm = self:GetFireMode()
	local fmn = string.lower(self.FireModes[fm])
	
	if string.find(fmn,"safe") or string.find(fmn,"holster") then
		return "Safety"
	end
	
	if self.FireModeName then
		return self.FireModeName
	end
	
	if string.find(fmn,"auto") then
		return "Full-Auto"
	end
	if string.find(fmn,"single") then
		if (self.Revolver or ( (self.DefaultHoldType and self.DefaultHoldType or self.HoldType) == "revolver" ) ) then
			if (self.BoltAction) then
				return "Single-Action"
			else
				return "Double-Action"
			end
		else
			if (self.BoltAction) then
				return "Bolt-Action"
			else
				if (self.Shotgun and self.Primary.RPM<250) then
					return "Pump-Action"
				else
					return "Semi-Auto"
				end
			end
		end
	end
	local bpos = string.find(fmn,"burst")
	if bpos then
		return string.sub(fmn,1,bpos-1) .. " Round Burst"
	end
end

--[[ 
Function Name:  IsSafety
Syntax: self:IsSafety( ). 
Returns:   Are we in safety firemode.
Notes:    Non.
Purpose:  Utility
]]--

function SWEP:IsSafety()
	local fm = self.FireModes[self:GetFireMode()]
	local fmn = string.lower(fm and fm or self.FireModes[1] )
	
	if ( string.find(fmn,"safe") or string.find(fmn,"holster") ) then
		return true
	else
		return false
	end
end

--[[ 
Function Name:  FindEvenBurstNumber
Syntax: self:FindEvenBurstNumber( ). 
Returns:   The ideal burst count.
Notes:    This will result in a two round burst on guns like the glock.  Please check out the autodetect code for how to do things like three round burst in a 20 round clip.
Purpose:  Utility
]]--

function SWEP:FindEvenBurstNumber()
	if (self.Primary.ClipSize % 3 ==0 ) then
		return 3
	elseif (self.Primary.ClipSize % 2 == 0 ) then
		return 2
	else
		local i=4
		while i<=7 do
			if self.Primary.ClipSize % i == 0 then
				return i
			end
			i=i+1
		end
	end
	return nil
end

--[[ 
Function Name:  GetAmmoReserve
Syntax: self:GetAmmoReserve( ). 
Returns:   How much ammo the owner has in reserve.
Notes:    Returns -1 if the owner isn't valid.
Purpose:  Utility
]]--

function SWEP:GetAmmoReserve()

	local wep = self
	if ( !IsValid( wep ) ) then return -1 end
	
	local ply = self.Owner
	if ( !IsValid( ply ) ) then return -1 end
 
	return ply:GetAmmoCount( wep:GetPrimaryAmmoType() )
end

--[[ 
Function Name:  GetRPM
Syntax: self:GetRPM( ). 
Returns:   How many RPM.
Notes:    Returns 600 as default.
Purpose:  Utility
]]--

function SWEP:GetRPM()
	
	if !self.Primary.Automatic then
		if self.Primary.RPM_Semi then
			return self.Primary.RPM_Semi 
		end
	end
	
	if self.Primary.RPM then
		return self.Primary.RPM
	end
	
	return 600
end

--[[ 
Function Name:  IsCurrentlyScoped
Syntax: self:IsCurrentlyScoped( ). 
Returns:   Is the player scoped in enough to display the overlay?  true/false, returns a boolean.
Notes:    Change SWEP.ScopeOverlayThreshold to change when the overlay is displayed.
Purpose:  Utility
]]--

function SWEP:IsCurrentlyScoped()
	if CLIENT then
		return ( (self.CLIronSightsProgress > self.ScopeOverlayThreshold)  and self.Scoped)
	else
		return ( (self:GetIronSightsRatio() > self.ScopeOverlayThreshold)  and self.Scoped)
	end
end

--[[ 
Function Name:  IsFirstPerson
Syntax: self:IsFirstPerson( ). 
Returns:   Is the owner in first person.
Notes:    Broken in singplayer because gary.
Purpose:  Utility
]]--

function SWEP:IsFirstPerson()
	
	if !IsValid(self) or !self:OwnerIsValid() then return false end
	
	local gmsdlp
	
	if LocalPlayer then
		gmsldp = hook.Call("ShouldDrawLocalPlayer", GAMEMODE, self.Owner) 
	else
		gmsldp = false
	end
	
	if gmsdlp then return false end
	
	local vm = self.Owner:GetViewModel()
	
	if IsValid(vm) then
		if vm:GetNoDraw() or vm:IsEffectActive(EF_NODRAW) then
			return false
		end
	end
	
	if !self:IsWeaponVisible() then
		return false
	end
	
	if self.Owner.ShouldDrawLocalPlayer and self.Owner:ShouldDrawLocalPlayer() then
		return false
	end
	
	if !IsValid(self.Owner:GetViewModel()) then return false end
	
	return true
end

--[[ 
Function Name:  GetFPMuzzleAttachment
Syntax: self:GetFPMuzzleAttachment( ). 
Returns:   The firstperson/viewmodel muzzle attachment id.
Notes:    Defaults to the first attachment.
Purpose:  Utility
]]--

function SWEP:GetFPMuzzleAttachment( )
	if !IsValid(self) then return nil end
	if !IsValid(self.Owner) then return nil end
	local ply=self.Owner
	local vm = ply:GetViewModel()
	local obj = vm:LookupAttachment( self.MuzzleAttachment and self.MuzzleAttachment or "1")
	
	if self:GetSilenced() then
		if self.MuzzleAttachmentSilenced then
			obj = vm:LookupAttachment( self.MuzzleAttachmentSilenced and self.MuzzleAttachmentSilenced or "1")
		else
			obj = vm:LookupAttachment( "muzzle_silenced")
		end
		if obj==0 then
			obj = 1
		end
	end
	
	if self.MuzzleAttachmentRaw then
		obj=self.MuzzleAttachmentRaw
	end
	
	return obj 
end

--[[ 
Function Name:  GetMuzzlePos
Syntax: self:GetMuzzlePos( hacky workaround that doesn't work anyways ). 
Returns:   The AngPos for the muzzle attachment.
Notes:    Defaults to the first attachment, and uses GetFPMuzzleAttachment
Purpose:  Utility
]]--

function SWEP:GetMuzzlePos( ignorepos )
	if !IsValid(self.Owner) then return nil end
	local ply=self.Owner
	local fp = self:IsFirstPerson()
	local vm = ply:GetViewModel()
	local obj = 0--vm:LookupAttachment( self.MuzzleAttachment and self.MuzzleAttachment or "1")
	
	if fp then
		obj=self:GetFPMuzzleAttachment()
	else
		obj = self:LookupAttachment( self.MuzzleAttachment and self.MuzzleAttachment or "1")
		if !obj or obj==0 then
			obj = 1
		end
	end
	
	local muzzlepos
	
	if fp then
		local pos = vm:GetPos()
		local ang = vm:GetAngles()
		local rpos = vm:GetRenderOrigin()
		local rang = vm:GetRenderAngles()
		if ignorepos then
			vm:SetPos(ply:GetShootPos())
			vm:SetAngles(ply:EyeAngles())
			vm:SetRenderOrigin(ply:GetShootPos())
			vm:SetRenderAngles(ply:EyeAngles())
		end
		muzzlepos = vm:GetAttachment( obj )
		vm:SetPos(pos)
		vm:SetAngles(ang)
		vm:SetRenderOrigin(rpos)
		vm:SetRenderAngles(rang)
	else
		muzzlepos = self:GetAttachment(obj)
	end
	
	return muzzlepos 
end

--[[ 
Function Name:  OwnerIsValid
Syntax: self:OwnerIsValid( ). 
Returns:  Is our owner valid and alive?
Notes:    Use this when possible.  Seems to work better than just IsValid(self.Owner).
Purpose:  Utility
]]--

function SWEP:OwnerIsValid()
	if !IsValid(self.Owner) then return false end
	if !self.Owner:IsPlayer() then return false end
	if !self.Owner:Alive() then return false end
	if ! (self.Owner:GetActiveWeapon() == self) then return end
	return true
end

--[[ 
Function Name:  CalculateConeRecoil
Syntax: self:CalculateConeRecoil().
Returns:  Spray cone, Recoil
Notes:  This is serverside/shared.  For per-frame, like used for the HUD, use ClientCalculateConeRecoil
Purpose:  Main SWEP function
]]--

function SWEP:CalculateConeRecoil()
	if !IsValid(self) then return 0, 0 end
	if !IsValid(self.Owner) then return 0, 0 end
	local CurrentRecoil
	local CurrentCone
	local basedamage
	local tmpiron=self:GetIronSights()
	local dynacc = false 
	local isr=self:GetIronSightsRatio()
	
	if GetConVarNumber("sv_rev_dynamicaccuracy",1)==1 and ( !(self.Primary.NumShots>1) ) then
		dynacc=true
	end
	
	local isr_1=math.Clamp(isr*2,0,1)
	local isr_2=math.Clamp((isr-0.5)*2,0,1)
	
	local acv = self.Primary.Spread or self.Primary.Accuracy
	local recv = self.Primary.Recoil * 5
	
	if dynacc then
		CurrentCone = Lerp( isr_2, Lerp(isr_1, acv, acv*self.ChangeStateAccuracyMultiplier) , self.Primary.IronAccuracy)
		CurrentRecoil = Lerp( isr_2, Lerp(isr_1, recv, recv*self.ChangeStateRecoilMultiplier) , recv*self.IronRecoilMultiplier)
	else
		CurrentCone = Lerp(isr,acv,self.Primary.IronAccuracy)
		CurrentRecoil = Lerp(isr,recv,recv*self.IronRecoilMultiplier)
	end
	
	local crc_1=math.Clamp(self:GetCrouchingRatio()*2,0,1)
	local crc_2=math.Clamp((self:GetCrouchingRatio()-0.5)*2,0,1)
	
	if dynacc then
		CurrentCone = Lerp( crc_2, Lerp(crc_1, CurrentCone, CurrentCone*self.ChangeStateAccuracyMultiplier) , CurrentCone * self.CrouchAccuracyMultiplier)
		CurrentRecoil = Lerp( crc_2, Lerp(crc_1, CurrentRecoil, self.Primary.Recoil*self.ChangeStateRecoilMultiplier) , CurrentRecoil * self.CrouchRecoilMultiplier)
	end
	
	local ovel = self.Owner:GetVelocity():Length()
	local vfc_1 = math.Clamp(ovel/180,0,1)
	
	if dynacc then
		CurrentCone = Lerp( vfc_1, CurrentCone, CurrentCone * self.WalkAccuracyMultiplier )
		CurrentRecoil = Lerp( vfc_1, CurrentRecoil, CurrentRecoil * self.WallRecoilMultiplier )
	end
	
	local jr = self:GetJumpingRatio()
	
	if dynacc then
		CurrentCone = Lerp(jr, CurrentCone, CurrentCone * self.JumpAccuracyMultiplier)
		CurrentRecoil = Lerp(jr, CurrentRecoil, CurrentRecoil * self.JumpRecoilMultiplier)
	end
	
	CurrentCone = CurrentCone * self:GetSpreadRatio()
	
	return CurrentCone, CurrentRecoil
end

--[[ 
Function Name:  ClientCalculateConeRecoil
Syntax: self:ClientCalculateConeRecoil().
Returns:  Spray cone, Recoil
Notes:  This is clientside and should only be called there.
Purpose:  Main SWEP function
]]--

function SWEP:ClientCalculateConeRecoil()
	if !IsValid(self) then return 0, 0 end
	if !IsValid(self.Owner) then return 0, 0 end
	local CurrentRecoil
	local CurrentCone
	local basedamage
	local tmpiron=self:GetIronSights()
	local dynacc = false 
	local isr=self.CLIronSightsProgress
	
	if GetConVarNumber("sv_rev_dynamicaccuracy",1)==1 and ( !(self.Primary.NumShots>1) ) then
		dynacc=true
	end
	
	local isr_1=math.Clamp(isr*2,0,1)
	local isr_2=math.Clamp((isr-0.5)*2,0,1)
	
	local acv = self.Primary.Spread or self.Primary.Accuracy
	local recv = self.Primary.Recoil * 5
	
	if dynacc then
		CurrentCone = Lerp( isr_2, Lerp(isr_1, acv, acv*self.ChangeStateAccuracyMultiplier) , self.Primary.IronAccuracy)
		CurrentRecoil = Lerp( isr_2, Lerp(isr_1, recv, recv*self.ChangeStateRecoilMultiplier) , recv*self.IronRecoilMultiplier)
	else
		CurrentCone = Lerp(isr,acv,self.Primary.IronAccuracy)
		CurrentRecoil = Lerp(isr,recv,recv*self.IronRecoilMultiplier)
	end
	
	local crc_1=math.Clamp(self.CLCrouchProgress*2,0,1)
	local crc_2=math.Clamp((self.CLCrouchProgress-0.5)*2,0,1)
	
	if dynacc then
		CurrentCone = Lerp( crc_2, Lerp(crc_1, CurrentCone, CurrentCone*self.ChangeStateAccuracyMultiplier) , CurrentCone * self.CrouchAccuracyMultiplier)
		CurrentRecoil = Lerp( crc_2, Lerp(crc_1, CurrentRecoil, self.Primary.Recoil*self.ChangeStateRecoilMultiplier) , CurrentCone * self.CrouchRecoilMultiplier)
	end
	
	local ovel = self.Owner:GetVelocity():Length()
	local vfc_1 = math.Clamp(ovel/180,0,1)
	
	if dynacc then
		CurrentCone = Lerp( vfc_1, CurrentCone, CurrentCone * self.WalkAccuracyMultiplier )
		CurrentRecoil = Lerp( vfc_1, CurrentRecoil, CurrentRecoil * self.WallRecoilMultiplier )
	end
	
	local jr = self.CLJumpProgress
	
	if dynacc then
		CurrentCone = Lerp(jr, CurrentCone, CurrentCone * self.JumpAccuracyMultiplier)
		CurrentRecoil = Lerp(jr, CurrentRecoil, CurrentRecoil * self.JumpRecoilMultiplier)
	end
	
	CurrentCone = CurrentCone * self.CLSpreadRatio
	
	return CurrentCone, CurrentRecoil
end

--[[ 
Function Name:  CalculateNearWallSH
Syntax: self:CalculateNearWallSH().
Returns:  Nothing.  However, calculates nearwall for the server.
Notes:  This is the server/shared equivalent of CalculateNearWallCLF.
Purpose:  Feature
]]--

function SWEP:CalculateNearWallSH()

	if !IsValid(self.Owner) then return end
	
	local vnearwall
	
	vnearwall=false
	
	local tracedata = {}
	tracedata.start=self.Owner:GetShootPos()
	tracedata.endpos=tracedata.start+self.Owner:EyeAngles():Forward()*self.WeaponLength
	tracedata.mask=MASK_SHOT
	tracedata.ignoreworld=false
	tracedata.filter=self.Owner
	local traceres=util.TraceLine(tracedata)
	if traceres.Hit then
		if traceres.Fraction>0 and traceres.Fraction<1 then
			if traceres.MatType!=MAT_FLESH and traceres.MatType!=MAT_GLASS then
				vnearwall = true
			end
		end
	end
	
	if GetConVarNumber("sv_rev_near_wall",1)==0 then
		vnearwall = false
	end
	
	self:SetNearWallRatio( math.Approach( self:GetNearWallRatio(), vnearwall and 1 or 0 , FrameTime() / self.NearWallTime ) )
	
end

--[[ 
Function Name:  CalculateNearWallCLF
Syntax: self:CalculateNearWallCLF().  This is called per-frame.
Returns:  Nothing.  However, calculates nearwall for the client.
Notes:  This is clientside only.
Purpose:  Feature
]]--

function SWEP:CalculateNearWallCLF()

	if !( CLIENT or game.SinglePlayer() ) then return end
	if !IsValid(self.Owner) then return end
	
	local vnearwall
	
	vnearwall=false
	local tracedata = {}
	tracedata.start=self.Owner:GetShootPos()
	tracedata.endpos=tracedata.start+self.Owner:EyeAngles():Forward()*self.WeaponLength
	tracedata.mask=MASK_SHOT
	tracedata.ignoreworld=false
	tracedata.filter=self.Owner
	local traceres=util.TraceLine(tracedata)
	if traceres.Hit then
		if traceres.Fraction>0 and traceres.Fraction<1 then
			if traceres.MatType!=MAT_FLESH and traceres.MatType!=MAT_GLASS then
				vnearwall = true
			end
		end
	end
	
	if GetConVarNumber("sv_rev_near_wall",1)==0 then
		vnearwall = false
	end
	
	self.CLNearWallProgress =  math.Approach( self.CLNearWallProgress, vnearwall and 1 or 0 , FrameTime() / self.NearWallTime )
end

--[[ 
Function Name:  ProcessHoldType
Syntax: self:ProcessHoldType().  This is called per-think.
Returns:  Nothing. 
Notes:  This calculates your holdtype.
Purpose:  Feature.
]]--

function SWEP:ProcessHoldType()
	local dholdt, sprintholdtype
	dholdt = self.DefaultHoldType and self.DefaultHoldType or self.HoldType
	
	if GetConVarNumber("sv_rev_holdtype_dynamic",1)!=1 then
		self:SetHoldType(dholdt)
	end
	
	sprintholdtype = self.SprintHoldTypes[ dholdt ]
	
	if self.SprintHoldTypeOverride then
		if self.SprintHoldTypeOverride!="" then
			sprintholdtype = self.SprintHoldTypeOverride
		end
	end
	
	if !sprintholdtype or sprintholdtype == "" then
		sprintholdtype = dholdt
	end
	
	ironholdtype = self.IronSightHoldTypes[ dholdt ]
	
	if self.IronSightHoldTypeOverride then
		if self.IronSightHoldTypeOverride!="" then
			ironholdtype = self.IronSightHoldTypeOverride
		end
	end
	
	if !ironholdtype or ironholdtype == "" then
		ironholdtype = dholdt
	end
	
	if ( !self:GetIronSights() and !self:GetSprinting() and !self:IsSafety() and self:GetHoldType() != dholdt ) then
		self:SetHoldType(dholdt)
	end
	
	if ( self:GetIronSights() and !self:GetSprinting() and !self:IsSafety() and self:GetHoldType() != ironholdtype ) then
		self:SetHoldType(ironholdtype)
	end
	
	if ( self:GetSprinting() and !self:IsSafety() and self:GetHoldType() != sprintholdtype ) then
		self:SetHoldType(sprintholdtype)
	end
	
	if ( self:IsSafety() and self:GetHoldType() != sprintholdtype ) then
		self:SetHoldType(sprintholdtype)
	end
end

--[[ 
Function Name:  AutoDetectRange
Syntax: self:AutoDetectRange().  Really only necessary to call once, but w/e.
Returns:  Nothing.
Notes:  Autodetects weapon range.  This is further affect in the shoot code by a convar.  See sh_bullet.lua.
Purpose:  Autodetection
]]--

function SWEP:AutoDetectRange()
	if self.Primary.Range == -1 then
		self.Primary.Range = 18240 * self.Primary.Damage/30 * ( math.abs(self.Primary.KickUp)+math.abs(self.Primary.KickDown)+math.abs(self.Primary.KickHorizontal) ) * 0.888
		self.Primary.Range = (self.Primary.Range * 3 + self.Primary.Range / (self.Primary.RPM/400) )/4
		local ht = self.DefaultHoldType and self.DefaultHoldType or self.HoldType
		if ht == "pistol" then
			self.Primary.Range = self.Primary.Range*0.3
		end
		if ht == "revolver" or ht == "357" then
			self.Primary.Range = self.Primary.Range*0.35
		end
		if ht == "smg" or ht == "smg" then
			self.Primary.Range = self.Primary.Range*0.9
		end
		if self.Shotgun or ht=="shotgun" or ht=="crossbow" or string.find(string.lower(self.ViewModel),"shotgun")  or string.find(string.lower(self.Base),"shotgun")   or string.find(string.lower(self.Category),"shotgun")then
			self.Primary.Range = self.Primary.Range*1.2
		end
		if self.Scoped then
			self.Primary.Range = self.Primary.Range*1.5
		end
		self.Primary.Range = self.Primary.Range / self.Primary.NumShots
	end
	if self.Primary.RangeFalloff == -1 then
		self.Primary.RangeFalloff = math.Clamp(math.pow( math.abs(self.Primary.KickUp)+math.abs(self.Primary.KickDown)+math.abs(self.Primary.KickHorizontal), 2)/3,0.3,0.9)
	end
end

--[[ 
Function Name:  SetUpSpread
Syntax: self:SetUpSpread().  Really only necessary to call once, but w/e.
Returns:  Nothing.
Notes:  Autodetects weapon spraycone.  Does nothing after you set them, either in SWEP code or by calling this function once.
Purpose:  Autodetection
]]--

function SWEP:SetUpSpread()
	local ht = self.DefaultHoldType and self.DefaultHoldType or self.HoldType
	
	if !self.Primary.SpreadMultiplierMax or self.AutoDetectSpreadMultiplierMax then
		self.Primary.SpreadMultiplierMax = 2.5 * math.max(self.Primary.RPM,400)/600 * math.sqrt(self.Primary.Damage/30*self.Primary.NumShots)--How far the spread can expand when you shoot.
		if ht =="smg" then
			self.Primary.SpreadMultiplierMax = self.Primary.SpreadMultiplierMax*0.8
		end
		if ht =="revolver" then
			self.Primary.SpreadMultiplierMax = self.Primary.SpreadMultiplierMax*2
		end
		if self.Scoped then
			self.Primary.SpreadMultiplierMax = self.Primary.SpreadMultiplierMax*1.5
		end
		self.AutoDetectSpreadMultiplierMax = true
	end
	
	if !self.Primary.SpreadIncrement or self.AutoDetectSpreadIncrement then
		self.AutoDetectSpreadIncrement = true
		self.Primary.SpreadIncrement = 1*(math.Clamp(math.sqrt(self.Primary.RPM)/24.5,0.7,3)) * math.sqrt(self.Primary.Damage/30*self.Primary.NumShots)--What percentage of the modifier is added on, per shot.
		if (ht) == "revolver" then
			self.Primary.SpreadIncrement = self.Primary.SpreadIncrement*2
		end
		
		if ht =="pistol" then
			self.Primary.SpreadIncrement = self.Primary.SpreadIncrement*1.35
		end
		
		if ht =="ar2" or ht=="rpg" then
			self.Primary.SpreadIncrement = self.Primary.SpreadIncrement*0.65
		end
		
		if ht =="smg" then
			self.Primary.SpreadIncrement = self.Primary.SpreadIncrement*1.75
			self.Primary.SpreadIncrement = self.Primary.SpreadIncrement*( math.Clamp( (self.Primary.RPM-650)/150,0,1) + 1)
		end
		
		if ht =="pistol" and self.Primary.Automatic == true then
			self.Primary.SpreadIncrement = self.Primary.SpreadIncrement*1.5
		end
		if self.Scoped then
			self.Primary.SpreadIncrement = self.Primary.SpreadIncrement*1.25
		end
		self.Primary.SpreadIncrement = self.Primary.SpreadIncrement * math.sqrt(self.Primary.Recoil * (self.Primary.KickUp + self.Primary.KickDown + self.Primary.KickHorizontal))*0.8
	end
	
	if !self.Primary.SpreadRecovery or self.AutoDetectSpreadRecovery then
		self.AutoDetectSpreadRecovery = true
		self.Primary.SpreadRecovery = math.sqrt(math.max(self.Primary.RPM,300))/29*4 --How much the spread recovers, per second.
		if ht=="smg" then
			self.Primary.SpreadRecovery = self.Primary.SpreadRecovery*( 1- math.Clamp( (self.Primary.RPM-600)/200,0,1)*0.33 )		
		end
	end
end

--[[ 
Function Name:  CPTbl
Syntax: self:CPTbl( input table). 
Returns:  Unique output table.
Notes:    Always lowercase.
Purpose:  Utility
]]--

function SWEP:CPTbl( tabl )
	if (tabl == nil) then return end
	if (!tabl) then return end 
	
	local result = {}
	
	for k, v in pairs( tabl ) do
		if (type(v) == "table") then
			if v != tabl then
				result[k] = self:CPTbl(v) --Recursion, without the stack overflow.
			end
		elseif (type(v) == "Vector") then
			result[k] = Vector(v.x, v.y, v.z)
		elseif (type(v) == "Angle") then
			result[k] = Angle(v.p, v.y, v.r)
		else
			result[k] = v
		end
	end
	
	return result
end