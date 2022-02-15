AddCSLuaFile()

--Shared Functions
include("modules/shared/sh_functions.lua")
include("modules/shared/sh_primaryattack_behaviour.lua")
include("modules/shared/sh_think.lua")
include("modules/shared/sh_datatables.lua")

--Clientside Functions.
include("modules/client/cl_calcview.lua")
include("modules/client/cl_calcviewmodelview.lua")


SWEP.base           = "weapon_base"

SWEP.PrintName		= "Revival Weapons Base" -- 'Nice' Weapon name (Shown on HUD)
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""
SWEP.Category		= "Revival"


--ViewModels and WorldModels Defaults.
SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_pistol.mdl"
SWEP.WorldModel		= "models/weapons/w_357.mdl"


--Some Viewmodel shit I guess.
SWEP.VMPos = Vector(0, 0, 0)
SWEP.VMAng = Vector(0, 0, 0)

SWEP.IronSightsPos  = Vector(9.49, 10.5, -12.371)
SWEP.IronSightsAng  = Vector(12, 65, -22.19)


SWEP.Idle = 0
SWEP.IdleTimer = CurTime()
SWEP.PistolSlide = 0

SWEP.AllowSprintShoot = false

--Lmfao gmod be like ME WANT THESE.
SWEP.Spawnable		= false
SWEP.AdminOnly		= false

--Sounds,Recoil and fire delay.
SWEP.Primary.Sound          = Sound( "Weapon_Pistol.Empty" )
SWEP.Primary.Recoil         = 1.5
SWEP.Primary.Kick          	= 1
SWEP.Primary.Damage         = 1
SWEP.Primary.NumShots       = 1
SWEP.Primary.RPM          	= 1


SWEP.Primary.Spread			= 1
SWEP.Primary.SpreadDiv		= 90

--Primary Fire
SWEP.Primary.ClipSize		= 8			-- Size of a clip
SWEP.Primary.DefaultClip	= 32		-- Default number of bullets in a clip
SWEP.Primary.Automatic		= false		-- Automatic/Semi Auto
SWEP.Primary.Ammo			= "Pistol"
SWEP.Primary.Tracer         = 4

SWEP.VElements = {}
SWEP.WElements = {}


SWEP.PrimaryAnim = ACT_VM_PRIMARYATTACK
SWEP.ReloadAnim = ACT_VM_RELOAD

--Values Not For Touching.
SWEP.BloomValue 	= 0
SWEP.PrevBS 		= 0

--[[---------------------------------------------------------
	Name: SWEP:Initialize()
	Desc: Called when the weapon is first loaded
-----------------------------------------------------------]]
function SWEP:Initialize()
	local ply = self:GetOwner()

	self.Ready = false

	if self.SetHoldType then
      self:SetHoldType(self.HoldType or "pistol")
   end

	self:SetNWBool("Passive", false)
	self:SetNWBool("Inspecting", false)

-- SCK Stuff
	if CLIENT then
	
		-- Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )
		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels
		
		if IsValid(ply) && ply:IsPlayer() then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				
				-- Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					-- we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255,255,255,1))
					-- ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					-- however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")			
				end
			end
		end
		
	end
end

--[[---------------------------------------------------------
	Name: SWEP:SecondaryAttack()
	Desc: Reload is being pressed
-----------------------------------------------------------]]
function SWEP:SecondaryAttack()
   if self.NoSights or (not self.IronSightsPos) then return end

   self:SetIronsights(not self:GetIronsights())

   self:SetNextSecondaryFire(CurTime() + 0.3)
end

--[[---------------------------------------------------------
	Name: SWEP:Reload()
	Desc: Reload is being pressed
-----------------------------------------------------------]]
function SWEP:Reload()
	if game.SinglePlayer() then self:CallOnClient("Reload") end -- why
	local ply = self:GetOwner()
	local usekey = ply:KeyDown(IN_USE)
	local reloadkey = ply:KeyDown(IN_RELOAD)
	local walkkey = ply:KeyDown(IN_WALK)
	local sprintkey = ply:KeyDown(IN_SPEED)
	local reloadkeypressed = ply:KeyPressed(IN_RELOAD)
	local reloadkeyheld = ply:KeyDown(IN_RELOAD)

	self:DefaultReload( ACT_VM_RELOAD )
	self:CustomReload()

end
function SWEP:CustomReload()
end

--[[---------------------------------------------------------
	Name: SWEP:Rev_ManageAnims()
	Desc: Handles all things animated related.
-----------------------------------------------------------]]
function SWEP:Rev_ManageAnims()

	if !IsFirstTimePredicted() then return end

	local ply = self:GetOwner()
	local vm = ply:GetViewModel()
	local oa = self.OwnerActivity
	local cv = ply:Crouching()
	local slowvar = ply:Crouching() or ply:KeyDown(IN_WALK)
	local walking = (ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT) or ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK)) && !ply:KeyDown(IN_SPEED)
	local sprinting = (ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT) or ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK)) && ply:KeyDown(IN_SPEED)
	
		if self.ManuallyReloading == true or self.Loading == true or self.Idle == 0 then return end
	
		local idleanim = vm:SelectWeightedSequence( ACT_VM_IDLE )
		local walkanim = vm:SelectWeightedSequence( ACT_WALK )
		local sprintanim = vm:SelectWeightedSequence( ACT_RUN )
		local swimidleanim = vm:SelectWeightedSequence( ACT_SWIM_IDLE )
		local swimminganim = vm:SelectWeightedSequence( ACT_SWIM )
		
		local reloadanim = vm:SelectWeightedSequence( ACT_VM_RELOAD )
		local walkanim = vm:SelectWeightedSequence( ACT_WALK )
		
		local anim = vm:GetSequence()
		local animdata = vm:GetSequenceInfo(anim)
		
		if self.SightsDown then
			vm:SendViewModelMatchingSequence(idleanim)
		return end
		
				self.FPAnimMul = 1
		
		if !walking && !sprinting then
			self.AnimToPlay = idleanim
		elseif walking then
			vm:SetPlaybackRate(self.FPAnimMul)
			if walkanim == -1 then
				self.AnimToPlay = idleanim
			else
				self.AnimToPlay = walkanim
			end
		elseif sprinting && !cv then
			if sprintanim == -1 or self.AllowSprintShoot == true then
				self.AnimToPlay = idleanim
			else
				self.AnimToPlay = sprintanim
			end
		end
		
		if walking then
			if animdata.activityname == "ACT_VM_IDLE" or animdata.activityname == "ACT_RUN" then self.IdleTimer = CurTime() end
		elseif sprinting then
			if animdata.activityname == "ACT_WALK" or animdata.activityname == "ACT_VM_IDLE" then self.IdleTimer = CurTime() end
		elseif !walking or !sprinting then
			if animdata.activityname == "ACT_WALK" or animdata.activityname == "ACT_RUN" then self.IdleTimer = CurTime() end
		end
		
		if self.IdleTimer <= CurTime() then
			if idleanim == -1 then return end
			vm:SendViewModelMatchingSequence(self.AnimToPlay)
			if self.AnimToPlay == walkanim then
				if slowvar then
					self.IdleTimer = CurTime() + (vm:SequenceDuration(self.AnimToPlay) * 2)
				else
					self.IdleTimer = CurTime() + vm:SequenceDuration(self.AnimToPlay)
				end
			else
				self.IdleTimer = CurTime() + vm:SequenceDuration(self.AnimToPlay)
			end
		end

	if self.IdleTimer <= CurTime() then
		vm:ResetSequence(idleanim)
		vm:ResetSequence(reloadanim)
		vm:ResetSequence(walkanim)
	end
end
--[[---------------------------------------------------------
	Name: SWEP:Holster( weapon_to_swap_to )
	Desc: Weapon wants to holster
	RetV: Return true to allow the weapon to holster
-----------------------------------------------------------]]
function SWEP:Holster(wep)
	self.IdleTimer = CurTime()

	--Lets add a function that we can add custom stuff to so that we don't call this on SWEPS and overwrite goods that we need.
	self:CustomHolster()

	-- SCK
	if CLIENT and IsValid(self.Owner) && self:GetOwner():IsPlayer() then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end

	return true
end

--Create custom Holster function for devs to place custom code into the SWEP directly.
function SWEP:CustomHolster()
end

--[[---------------------------------------------------------
	Name: SWEP:Deploy()
	Desc: Deploy the weapon when swapped to the weapon. lol?
-----------------------------------------------------------]]
function SWEP:Deploy()

	--Lets set some variables I want to use with the deploy.
	local ply = self:GetOwner()
	if not IsValid(ply) then return end
	local cv = ply:Crouching()
	local vm = ply:GetViewModel()
	local drawanim = vm:SelectWeightedSequence( ACT_VM_DRAW )
	local drawanimintial = vm:SelectWeightedSequence( ACT_VM_DRAW_EMPTY )
	local drawanimdur = vm:SequenceDuration(drawanim)
	local drawanimintialdur = vm:SequenceDuration(drawanimintial)
	vm:SetPlaybackRate(1)
	self.SightsDown = false
	if self:GetNWBool("Passive") == true then self:TogglePassive() end
	self.Idle = 1
	self.Inspecting = false
	self.EmptyReload = 0
	self.Loading = false

	self:BloomScore()


	--Initial Draw and Regular Draw anim handling.
	if ply:IsPlayer() then
		self.Idle = 0
		if self.Ready == true or drawanimintial == -1 then
			self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
			timer.Simple(drawanimdur, function()
				self.Ready = true
				self.Idle = 1
			end)
			self.IdleTimer = CurTime() + drawanimdur
		else
			self.Weapon:SendWeaponAnim( ACT_VM_DRAW_EMPTY )
			self.IdleTimer = CurTime() + drawanimintialdur
			time.Simple(drawanimintialdur, function()
				self.Ready = true
				self:SetNWBool("Ready", true)
				self.Idle = 1
			end)
		end
	end

	--Are they in the passive firemode?
	if self.Passive == true then
		self:DoPassiveHoldtype()
	else

	--Make sure they cant shoot when pulling out the weapon.
	self:SetNextPrimaryFire( CurTime() + drawanimdur)

	--Lets add a function that we can add custom stuff to so that we don't call this on SWEPS and overwrite goods that we need.
	self:DoCustomDeploy()

	--Make sure to return true so that they CAN deploy the weapon.
	return true

	end

end
--Create custom Deploy function for devs to place custom code into the SWEP directly.
function SWEP:DoCustomDeploy()
end


--[[---------------------------------------------------------
	Name: OnRemove
	Desc: Called just before entity is deleted
-----------------------------------------------------------]]
function SWEP:OnRemove()
	local ply = self:GetOwner()
	self.IdleTimer = CurTime()


	if self.BloomScoreName != nil then
			timer.Remove( self.BloomScoreName )
	else end

	--Lets add a function that we can add custom stuff to so that we don't call this on SWEPS and overwrite goods that we need.
	self:DoCustomRemove()

	--SCK likes to see a Holster()? idk bro.
	self:Holster()
end

--Create custom Remove function for devs to place custom code into the SWEP directly.
function SWEP:DoCustomRemove()
end

--[[---------------------------------------------------------
	Name: SWEP:OnRestore()
	Desc: When the weapon exist again lol!
-----------------------------------------------------------]]
function SWEP:OnRestore()
   self.NextSecondaryAttack = 0
   self:SetIronsights( false )
end

--[[---------------------------------------------------------
	Name: SetIronsights and GetIronsights
	Desc: Allow the setting of IronSights.
-----------------------------------------------------------]]
function SWEP:SetIronsights(b)
   if (b ~= self:GetIronsights()) then
      self:SetIronsightsPredicted(b)
      self:SetIronsightsTime(CurTime())
      if CLIENT then
         self:CalcViewModel()
      end
   end
end

function SWEP:GetIronsights()
   return self:GetIronsightsPredicted()
end

function SWEP:CalcViewModel()
   if (not CLIENT) or (not IsFirstTimePredicted()) then return end
   self.bIron = self:GetIronsights()
   self.fIronTime = self:GetIronsightsTime()
   self.fCurrentTime = CurTime()
   self.fCurrentSysTime = SysTime()
end

--- Dummy functions that will be replaced when SetupDataTables runs. These are
--- here for when that does not happen (due to e.g. stacking base classes)
function SWEP:GetIronsightsTime() return -1 end
function SWEP:SetIronsightsTime() end
function SWEP:GetIronsightsPredicted() return false end
function SWEP:SetIronsightsPredicted() end


--[[---------------------------------------------------------
	Name: SWEP:Inspect()
	Desc: Inspect function to check your gun out like a 2012 Airsoft montage.
-----------------------------------------------------------]]
function SWEP:Inspect()
	self.Inspecting = true
	self:SetNWBool("InspectingWeapon", true)
	if game.SinglePlayer() && !IsFirstTimePredicted() then return end
	local inspectanim = self:SelectWeightedSequence( ACT_VM_FIDGET )
	local inspectdur = self:SequenceDuration(inspectanim)

	self.Weapon:SendWeaponAnim( ACT_VM_FIDGET )

	self.IdleTimer = CurTime() + inspectdur

	timer.Simple( inspectdur, function() self:EnableInspection() end)

end

--Allow them to spectate after the fact they're done inspecting their pretty weapon I made.
function SWEP:EnableInspection()
	self:SetNWBool("PlayingInspectAnim", false)
	self.Inspecting = false
end

--[[---------------------------------------------------------
	Name: DoPassiveHoldType and DoInspectHoldType
	Desc: Both are worldmodel anim handles for sending animations to a player to help dictate what they're seeing in first person to the rest of the players around them.
-----------------------------------------------------------]]

--Passive Hold type Handling.
function SWEP:DoPassiveHoldtype()
	if self.HoldType == "pistol" or self.HoldType == "revolver" or self.HoldType == "knife" or self.HoldType == "melee" or self.HoldType == "slam" or self.HoldType == "fist" or self.HoldType == "grenade" or self.HoldType == "duel" then
		self:SetHoldType("normal")
	elseif self.HoldType == "smg" or self.HoldType == "ar2" or self.HoldType == "rpg" or self.HoldType == "crossbow" or self.HoldType == "shotgun" or self.HoldType == "physgun" then
		self:SetHoldType("passive")
	elseif self.HoldType == "magic" or self.HoldType == "melee2" then
		self:SetHoldType("knife")
	end
end

--Inspecting HoldType handling.
function SWEP:DoInspectHoldtype()
	self:SetHoldType("slam")
end

--[[---------------------------------------------------------
	Checks the objects before any action is taken
	This is to make sure that the entities haven't been removed
-----------------------------------------------------------]]
function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )

	if isnumber(self.WepSelectIcon) then
		surface.SetTexture( self.WepSelectIcon )
	elseif isstring(self.WepSelectIcon) then
		surface.SetTexture( surface.GetTextureID( self.WepSelectIcon ) )
	end
	surface.SetDrawColor( 255, 255, 255, alpha )


	alpha = 150
	surface.DrawTexturedRect( x + (wide/4), y + (tall / 16),  (wide*0.5) , ( wide / 2 ) )
	
	self:PrintWeaponInfo( x + wide, y, alpha )
end
--[[---------------------------------------------------------
	This draws the weapon info box
-----------------------------------------------------------]]
function SWEP:PrintWeaponInfo( x, y, alpha )

	if ( self.DrawWeaponInfoBox == false ) then return end
	
	if (self.InfoMarkup == nil ) then
		local str
		local title_color = "<color=0,200,255,255>"
		local text_color = "<color=150,150,150,255>"
		
		str = "<font=HudSelectionText>"
		if ( self.Author != "" ) then str = str .. title_color .. "Author:</color>\t\n"..text_color..self.Author.."</color>\n" end
		if ( self.Contact != "" ) then str = str .. title_color .. "Contact:</color>\t\n"..text_color..self.Contact.."</color>\n\n" end
		if ( self.Purpose != "" ) then str = str .. title_color .. "Purpose:</color>\t\n"..text_color..self.Purpose.."</color>\n\n" end
		if ( self.Instructions != "" ) then str = str .. title_color .. "Instructions:</color>\t\n"..text_color..self.Instructions.."</color>\n" end
		str = str .. "</font>"
		
		self.InfoMarkup = markup.Parse( str, 250 )
	end
	
	surface.SetDrawColor( 60, 60, 60, alpha )
	surface.SetTexture( self.SpeechBubbleLid )

	draw.RoundedBox( 8, x, y, 250, self.InfoMarkup:GetHeight(), Color( 0, 0, 0, 50 ) )
	draw.RoundedBox( 0, x - 2, y, 2, self.InfoMarkup:GetHeight(), Color( 0, 200, 255, 255 ) )
	
	self.InfoMarkup:Draw( x+5, y, nil, nil, alpha )
	
end

function SWEP:DoPassiveHoldtype()
	if self.HoldType == "pistol" or self.HoldType == "revolver" or self.HoldType == "knife" or self.HoldType == "melee" or self.HoldType == "slam" or self.HoldType == "fist" or self.HoldType == "grenade" or self.HoldType == "duel" then
		self:SetHoldType("normal")
	elseif self.HoldType == "smg" or self.HoldType == "ar2" or self.HoldType == "rpg" or self.HoldType == "crossbow" or self.HoldType == "shotgun" or self.HoldType == "physgun" then
		self:SetHoldType("passive")
	elseif self.HoldType == "magic" or self.HoldType == "melee2" then
		self:SetHoldType("knife")
	end
end

function SWEP:GetViewModelPosition( pos, ang )
	local oa = self.OwnerActivity
	if oa == "sprinting" and self.AllowSprintShoot == false then
		self:DoPassiveHoldtype()
	else
		self:SetHoldType(self.HoldType)
	end
end

--[[---------------------------------------------------------
	Name: SWEP:PreDrawViewModel
	Desc:Calls before the ViewModel is drawn.
-----------------------------------------------------------]]
function SWEP:PreDrawViewModel(vm, wep, ply)
	if game.SinglePlayer() then return end -- Find the singleplayer compatible version inside of Think() because why.
	return false
end


--[[---------------------------------------------------------
	Name: DO NOT TOUCH THIS. SCK RELATED STUFF.
-----------------------------------------------------------]]

if CLIENT then
	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end
		
		self:UpdateBonePositions(vm)
		if (!self.vRenderOrder) then
			
			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}
			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end
		for k, name in ipairs( self.vRenderOrder ) do
		
			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
			
			if (!pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then
				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()
			end
			
		end
		
	end
	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		
		if (!self.WElements) then return end
		
		if (!self.wRenderOrder) then
			self.wRenderOrder = {}
			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end
		end
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then
				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()
			end
			
		end
		
	end
	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)
			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end
	function SWEP:CreateModels( tab )
		if (!tab) then return end
		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		
		if self.ViewModelBoneMods then
			
			if (!vm:GetBoneCount()) then return end
			
			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
			end
			// !! ----------- !! //
			
			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				
				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms
				// !! ----------- !! //
				
				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end
		   
	end
	 
	function SWEP:ResetBonePositions(vm)
		
		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end
		
	end

	/**************************
		Global utility code
	**************************/

	// Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	// Does not copy entities of course, only copies their reference.
	// WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
	function table.FullCopy( tab )
		if (!tab) then return nil end
		
		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		
		return res
		
	end
	
end