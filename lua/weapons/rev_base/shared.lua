AddCSLuaFile()

--Shared Functions
include("modules/shared/sh_anims.lua")
include("modules/shared/sh_bobcode.lua")
include("modules/shared/sh_bullet.lua")
include("modules/shared/sh_datatables.lua")
include("modules/shared/sh_effects.lua")
include("modules/shared/sh_firemode_behaviour.lua")
include("modules/shared/sh_functions.lua")
include("modules/shared/sh_ironsights_behaviour.lua")
include("modules/shared/sh_primaryattack_behaviour.lua")
include("modules/shared/sh_think.lua")

--Clientside Functions.
include("modules/client/cl_calcview.lua")
include("modules/client/cl_calcviewmodelview.lua")
include("modules/client/cl_effects.lua")
include("modules/client/cl_sck.lua")

--Define the base GMOD base because we want to make sure we keep functions I don't declear intact.
SWEP.base = "weapon_base"
DEFINE_BASECLASS("weapon_base")

--Define the SWEP name for the base.
SWEP.Gun = "rev_base"

--Flavor Text and The name/category of the weapon.
SWEP.PrintName = "Revival Weapons Base" -- 'Nice' Weapon name (Shown on HUD)
SWEP.Author	= ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "Revival"

--WorldModels Defaults.
SWEP.WorldModel = "models/weapons/w_357.mdl"
SWEP.SightsDown = false
SWEP.MuzzleAttachment = "1" 		-- Should be "1" for CSS models or "muzzle" for hl2 models



--Some Viewmodel shit I guess.
SWEP.ViewModel = "models/your/path/here.mdl" -- Viewmodel path
SWEP.ViewModelFOV = 65        -- This controls how big the viewmodel looks.  Less is more.
SWEP.ViewModelFlip = false     -- Set this to true for CSS models, or false for everything else (with a righthanded viewmodel.)
SWEP.UseHands = false -- Use gmod c_arms system.
SWEP.VMPos = Vector(0, 0, 0) -- The viewmodel positional offset, constantly.  Subtract this from any other modifications to viewmodel position.
SWEP.VMAng = Vector(0, 0, 0) -- The viewmodel angular offset, constantly.   Subtract this from any other modifications to viewmodel angle.
SWEP.VMPos_Additive = true -- Set to false for an easier time using VMPos. If true, VMPos will act as a constant delta ON TOP OF ironsights, run, whateverelse
SWEP.AdditiveViewModelPosition = true

-- The viewmodel positional offset, constantly.
-- Subtract this from any other modifications to viewmodel position.
-- AKA VMPos (SWEP Construction Kit naming, VMPos is always checked for presence and it always override ViewModelPosition if present)
SWEP.ViewModelPosition  = Vector(0, 0, 0)
-- AKA VMAng (SWEP Construction Kit naming)
-- The viewmodel angular offset, constantly.
-- Subtract this from any other modifications to viewmodel angle.
SWEP.ViewModelAngle     = Vector(0, 0, 0)

SWEP.AllowSprintShoot = false

--Lmfao gmod be like ME WANT THESE.
SWEP.Spawnable = false
SWEP.AdminOnly = false

SWEP.Primary.Sound 	= Sound("")				-- This is the sound of the gun/bow, when you shoot.
SWEP.Primary.DistSound 	= Sound("")				--The Distant Sound to play.
SWEP.Primary.Round 	= ("")					-- What kind of bullet does it shoot?
SWEP.Primary.Cone = 0.2					-- This is the accuracy of NPCs.  Not necessary in almost all cases, since I don't even think this base is compatible with NPCs.
SWEP.Primary.Recoil	= 1						-- This is the recoil multiplier.  Really, you should keep this at 1 and change the KickUp, KickDown, and KickHorizontal variables.  However, you can change this as a multiplier too.
SWEP.Primary.Damage = 0.01					-- Damage, in standard damage points.
SWEP.Primary.Spread	= .01					--This is hip-fire acuracy.  Less is more (1 is horribly awful, .0001 is close to perfect)
SWEP.FiresUnderwater = false

SWEP.Primary.SpreadMultiplierMax = 2.5 --How far the spread can expand when you shoot.
SWEP.Primary.SpreadIncrement = 1/3.5 --What percentage of the modifier is added on, per shot.
SWEP.Primary.SpreadRecovery = 3 --How much the spread recovers, per second.

SWEP.Primary.NumShots 			= 1 --The number of shots the gun/bow fires.  
SWEP.Primary.RPM				= 600					-- This is in Rounds Per Minute / RPM
SWEP.Primary.RPM_Semi			= nil					-- RPM for semi-automatic or burst fire.  This is in Rounds Per Minute / RPM
SWEP.Primary.ClipSize			= 0					-- This is the size of a clip
SWEP.Primary.DefaultClip		= 0					-- This is the number of bullets the gun gives you, counting a clip as defined directly above.
SWEP.Primary.KickUp				= 0					-- This is the maximum upwards recoil (rise)
SWEP.Primary.KickDown			= 0					-- This is the maximum downwards recoil (skeet)
SWEP.Primary.KickHorizontal		= 0					-- This is the maximum sideways recoil (no real term)
SWEP.Primary.StaticRecoilFactor = 0.5 	--Amount of recoil to directly apply to EyeAngles.  Enter what fraction or percentage (in decimal form) you want.  This is also affected by a convar that defaults to 0.5.
SWEP.Primary.Automatic			= true					-- Automatic/Semi Auto
SWEP.Primary.Ammo				= "none"					-- What kind of ammo
SWEP.Primary.Range 				= -1 -- The distance the bullet can travel in source units.  Set to -1 to autodetect based on damage/rpm.
SWEP.Primary.RangeFalloff 		= -1 -- The percentage of the range the bullet damage starts to fall off at.  Set to 0.8, for example, to start falling off after 80% of the range.

SWEP.Secondary.ClipSize			= 0					-- Size of a clip
SWEP.Secondary.DefaultClip		= 0					-- Default number of bullets in a clip
SWEP.Secondary.Automatic		= false					-- Automatic/Semi Auto
SWEP.Secondary.Ammo				= "none"
SWEP.Secondary.IronFOV			= 0					-- How much you 'zoom' in. Less is more!  Don't have this be <= 0 
SWEP.SprintFOVOffset 			= 3.75 --Add this onto the FOV when we're sprinting.

--Scoped vars.

SWEP.BoltAction			= false  --Unscope/sight after you shoot?
SWEP.Scoped				= false  --Draw a scope overlay?

SWEP.ScopeOverlayThreshold = 0.875 --Percentage you have to be sighted in to see the scope.
SWEP.BoltTimerOffset = 0.25 --How long you stay sighted in after shooting, with a bolt action.

--Shotgun Vars

SWEP.Shotgun = false

SWEP.ShellTime			= .35 -- For shotguns.  How long it takes to insert a shell.

SWEP.SelectiveFire		= false --Allow selecting your firemode?
SWEP.DisableBurstFire	= false --Only bursting?
SWEP.OnlyBurstFire		= false --No auto, only burst?
SWEP.DefaultFireMode 	= "" --Default to auto or whatev

SWEP.VElements 				= {}
SWEP.WElements 				= {}

SWEP.SprintFOVOffset 		= 3.75 --Add this onto the FOV when we're sprinting.
SWEP.Secondary.IronFOV		= 0	

--Inspection Pos/Ang.
SWEP.InspectPosDef 			= Vector(0,0,0)
SWEP.InspectAngDef 			= Vector(0,0,0)





--Sighting Code
SWEP.CLRunSightsProgress=0 --BASE DEPENDENT VALUE.  DO NOT CHANGE OR THINGS MAY BREAK.  NO USE TO YOU.
SWEP.CLIronSightsProgress=0 --BASE DEPENDENT VALUE.  DO NOT CHANGE OR THINGS MAY BREAK.  NO USE TO YOU.
SWEP.CLCrouchProgress=0 --BASE DEPENDENT VALUE.  DO NOT CHANGE OR THINGS MAY BREAK.  NO USE TO YOU.
SWEP.CLJumpProgress=0 --BASE DEPENDENT VALUE.  DO NOT CHANGE OR THINGS MAY BREAK.  NO USE TO YOU.
SWEP.CLInspectingProgress=0
SWEP.CLSpreadRatio=1--BASE DEPENDENT VALUE.  DO NOT CHANGE OR THINGS MAY BREAK.  NO USE TO YOU.
SWEP.CLAmmoHUDProgress=0--BASE DEPENDENT VALUE.  DO NOT CHANGE OR THINGS MAY BREAK.  NO USE TO YOU.
SWEP.ShouldDrawAmmoHUD=false--THIS IS PROCEDURALLY CHANGED AND SHOULD NOT BE TWEAKED.  BASE DEPENDENT VALUE.  DO NOT CHANGE OR THINGS MAY BREAK.  NO USE TO YOU.
SWEP.IronRecoilMultiplier=0.5 --Multiply recoil by this factor when we're in ironsights.  This is proportional, not inversely.
SWEP.CrouchRecoilMultiplier=0.65  --Multiply recoil by this factor when we're crouching.  This is proportional, not inversely.
SWEP.JumpRecoilMultiplier=1.3  --Multiply recoil by this factor when we're crouching.  This is proportional, not inversely.
SWEP.WallRecoilMultiplier=1.1  --Multiply recoil by this factor when we're changing state e.g. not completely ironsighted.  This is proportional, not inversely.
SWEP.ChangeStateRecoilMultiplier=1.3  --Multiply recoil by this factor when we're crouching.  This is proportional, not inversely.
SWEP.CrouchAccuracyMultiplier=0.5--Less is more.  Accuracy * 0.5 = Twice as accurate, Accuracy * 0.1 = Ten times as accurate
SWEP.ChangeStateAccuracyMultiplier=1.5 --Less is more.  A change of state is when we're in the progress of doing something, like crouching or ironsighting.  Accuracy * 2 = Half as accurate.  Accuracy * 5 = 1/5 as accurate
SWEP.JumpAccuracyMultiplier=2--Less is more.  Accuracy * 2 = Half as accurate.  Accuracy * 5 = 1/5 as accurate
SWEP.WalkAccuracyMultiplier=1.35--Less is more.  Accuracy * 2 = Half as accurate.  Accuracy * 5 = 1/5 as accurate
SWEP.ToCrouchTime = 0.05 --The time it takes to enter crouching state
SWEP.DefaultFOV=90 --BASE DEPENDENT VALUE.  DO NOT CHANGE OR THINGS MAY BREAK.  NO USE TO YOU.
SWEP.MoveSpeed = 1 --Multiply the player's movespeed by this.
SWEP.IronSightsMoveSpeed = 0.8 --Multiply the player's movespeed by this when sighting.
--VAnimation Support
SWEP.ShootWhileDraw=false --Can you shoot while draw anim plays?
SWEP.AllowReloadWhileDraw=false --Can you reload while draw anim plays?
SWEP.SightWhileDraw=false --Can we sight in while the weapon is drawing / the draw anim plays?
SWEP.AllowReloadWhileHolster=true --Can we interrupt holstering for reloading?
SWEP.ShootWhileHolster=true --Cam we interrupt holstering for shooting?
SWEP.SightWhileHolster=false --Cancel out "iron"sights when we holster?
SWEP.UnSightOnReload=true --Cancel out ironsights for reloading.
SWEP.AllowReloadWhileSprinting=false --Can you reload when close to a wall and facing it?
SWEP.SprintBobMult=1.5 -- More is more bobbing, proportionally.  This is multiplication, not addition.  You want to make this > 1 probably for sprinting.
SWEP.IronBobMult=0  -- More is more bobbing, proportionally.  This is multiplication, not addition.  You want to make this < 1 for sighting, 0 to outright disable.
--These holdtypes are used in ironsights.  Syntax:  DefaultHoldType=NewHoldType
SWEP.IronSightHoldTypes = { pistol = "revolver",
	smg = "rpg",
	grenade = "melee",
	ar2 = "rpg",
	shotgun = "ar2",
	rpg = "rpg",
	physgun = "physgun",
	crossbow = "ar2",
	melee = "melee2",
	slam = "camera",
	normal = "fist",
	melee2 = "magic",
	knife = "fist",
	duel = "duel",
	camera = "camera",
	magic = "magic",
	revolver = "revolver"
}
--These holdtypes are used while sprinting.  Syntax:  DefaultHoldType=NewHoldType
SWEP.SprintHoldTypes = { pistol = "normal",
	smg = "passive",
	grenade = "normal",
	ar2 = "passive",
	shotgun = "passive",
	rpg = "passive",
	physgun = "normal",
	crossbow = "passive",
	melee = "normal",
	slam = "normal",
	normal = "normal",
	melee2 = "melee",
	knife = "fist",
	duel = "normal",
	camera = "slam",
	magic = "normal",
	revolver = "normal"
}

SWEP.IronSightHoldTypeOverride=""  --This variable overrides the ironsights holdtype, choosing it instead of something from the above tables.  Change it to "" to disable.
SWEP.SprintHoldTypeOverride=""  --This variable overrides the sprint holdtype, choosing it instead of something from the above tables.  Change it to "" to disable.
--Override allowed VAnimations.  Necessary for lazy modelers/animators.
SWEP.ForceDryFireOff = true
SWEP.DisableIdleAnimations = true
SWEP.ForceEmptyFireOff = true
--Allowed VAnimations.  These are autodetected, so not really needed except as an extra precaution.  Don't change these until you get to the next category.
SWEP.CanDrawAnimate=true
SWEP.CanDrawAnimateEmpty=false
SWEP.CanDrawAnimateSilenced=false
SWEP.CanHolsterAnimate=true
SWEP.CanHolsterAnimateEmpty=false
SWEP.CanIdleAnimate=true
SWEP.CanIdleAnimateEmpty=false
SWEP.CanIdleAnimateSilenced=false
SWEP.CanShootAnimate=true
SWEP.CanShootAnimateSilenced=false
SWEP.CanReloadAnimate=true
SWEP.CanReloadAnimateEmpty=false
SWEP.CanReloadAnimateSilenced=false
SWEP.CanDryFireAnimate=false
SWEP.CanDryFireAnimateSilenced=false
SWEP.CanSilencerAttachAnimate=false
SWEP.CanSilencerDetachAnimate=false
SWEP.actlist = {
	ACT_VM_DRAW,
	ACT_VM_DRAW_EMPTY,
	ACT_VM_DRAW_SILENCED,
	ACT_VM_HOLSTER,
	ACT_VM_HOLSTER_EMPTY,
	ACT_VM_IDLE,
	ACT_VM_IDLE_EMPTY,
	ACT_VM_IDLE_SILENCED,
	ACT_VM_PRIMARYATTACK,
	ACT_VM_PRIMARYATTACK_EMPTY,
	ACT_VM_PRIMARYATTACK_SILENCED,
	ACT_VM_SECONDARYATTACK,
	ACT_VM_RELOAD,
	ACT_VM_RELOAD_EMPTY,
	ACT_VM_RELOAD_SILENCED,
	ACT_VM_ATTACH_SILENCER,
	ACT_VM_DETACH_SILENCER,
	ACT_VM_FIDGET,
	ACT_VM_DRAW_DEPLOYED,
	ACT_WALK,
	ACT_RUN
}
 --If you really want, you can remove things from SWEP.actlist and manually enable animations and set their lengths.
SWEP.SequenceEnabled = {}
SWEP.SequenceLength = {}

--WAnim Support
SWEP.ThirdPersonReloadDisable=false --Disable third person reload?  True disables.

--FX Stuff.
--These are particle effects, not PCF files, that are played when you shoot.
SWEP.SmokeParticles = { 
	pistol = "smoke_trail_controlled",
	smg = "smoke_trail_rev",
	grenade = "smoke_trail_rev",
	ar2 = "smoke_trail_rev",
	shotgun = "smoke_trail_wild",
	rpg = "smoke_trail_rev",
	physgun = "smoke_trail_rev",
	crossbow = "smoke_trail_rev",
	melee = "smoke_trail_rev",
	slam = "smoke_trail_rev",
	normal = "smoke_trail_rev",
	melee2 = "smoke_trail_rev",
	knife = "smoke_trail_rev",
	duel = "smoke_trail_rev",
	camera = "smoke_trail_rev",
	magic = "smoke_trail_rev",
	revolver = "smoke_trail_rev",
	silenced = "smoke_trail_controlled"
}
SWEP.DoMuzzleFlash = true --Do a muzzle flash?
SWEP.CustomMuzzleFlash = true --Disable muzzle anim events and use our custom flashes?
SWEP.AutoDetectMuzzleAttachment = false --For multi-barrel weapons, detect the proper attachment?
SWEP.Tracer				= 0 --Bullet tracer.  TracerName overrides this.
SWEP.TracerName = nil --Change to a string of your tracer name
SWEP.MuzzleFlashEffect = nil --Change to a string of your muzzle flash effect
SWEP.DisableChambering = false --Disable round-in-the-chamber

--Stuff you shouldn't touch after this 
SWEP.PenetrationCounter = 0 --BASE DEPENDENT VALUE.  DO NOT CHANGE OR THINGS MAY BREAK.  NO USE TO YOU.
SWEP.DrawTime = 1  --BASE DEPENDENT VALUE.  DO NOT CHANGE OR THINGS MAY BREAK.  NO USE TO YOU.
SWEP.TextCol = Color(255,255,255,255) --Primary text color
SWEP.TextColContrast = Color(32,32,32,255) --Secondary Text Color (used for shadow)
SWEP.AttachmentCache = {} -- Caches Attachments
SWEP.ScopeScale = 0.5
SWEP.ReticleScale = 0.7

SWEP.AnimCycle = 1

SWEP.IdleTimer = CurTime()


for k,v in pairs(SWEP.SmokeParticles) do
	PrecacheParticleSystem(v)
end


--[[---------------------------------------------------------
	Name: SWEP:SetupDataTables()
	Desc: Initailize the Data Tables for the player.
-----------------------------------------------------------]]

function SWEP:SetupDataTables()
   self:NetworkVar("Bool", 0, "IronSights")
   self:NetworkVar("Bool", 1, "IronSightsRaw")
   self:NetworkVar("Bool", 2, "Holstering")
   self:NetworkVar("Bool", 3, "Sprinting")
   self:NetworkVar("Bool", 4, "Drawing")
   self:NetworkVar("Bool", 5, "Reloading")
   self:NetworkVar("Bool", 6, "Shooting")
   self:NetworkVar("Bool", 8, "Silenced")
   self:NetworkVar("Bool", 9, "Bursting")
   self:NetworkVar("Bool", 10, "ChangingSilence")
   self:NetworkVar("Bool", 11, "FireModeChanging")
   self:NetworkVar("Bool", 12, "HUDThreshold")
   self:NetworkVar("Bool", 13, "ShotgunInsertingShell")
   self:NetworkVar("Bool", 14, "ShotgunPumping")
   self:NetworkVar("Bool", 15, "ShotgunNeedsPump")
   self:NetworkVar("Bool", 16, "ShotgunCancel")
   self:NetworkVar("Bool", 17, "BoltTimer")
   self:NetworkVar("Bool", 18, "CanHolster")
   self:NetworkVar("Bool", 19, "Inspecting")
   self:NetworkVar("Float",0, "DrawingEnd")
   self:NetworkVar("Float",1, "HolsteringEnd")
   self:NetworkVar("Float",2, "ReloadingEnd")
   self:NetworkVar("Float",3, "ShootingEnd")
   self:NetworkVar("Float",4, "NextIdleAnim")
   self:NetworkVar("Float",5, "NextBurst")
   self:NetworkVar("Float",6, "NextSilenceChange")
   self:NetworkVar("Float",7, "FireModeChangeEnd")
   self:NetworkVar("Float",8, "HUDThresholdEnd")
   self:NetworkVar("Float",9, "BoltTimerStart")
   self:NetworkVar("Float",10, "BoltTimerEnd")
   self:NetworkVar("Float",11, "IronSightsRatio")
   self:NetworkVar("Float",12, "RunSightsRatio")
   self:NetworkVar("Float",13, "CrouchingRatio")
   self:NetworkVar("Float",14, "JumpingRatio")
   self:NetworkVar("Float",16, "SpreadRatio")
   self:NetworkVar("Float",17, "InspectingRatio")
   self:NetworkVar("Int",0, "FireMode")
   self:NetworkVar("Int",1, "BurstCount")
end

function SWEP:InitDrawCode( instr )

	if CLIENT then
		local t=string.Explode(",",instr,false)
		if t[1] then
			self.SequenceEnabled[ACT_VM_DRAW]=false
			if t[1]==1 then
				self.SequenceEnabled[ACT_VM_DRAW]=true
			end
		end
		if t[2] then
			self.SequenceEnabled[ACT_VM_DRAW_EMPTY]=false
			if t[2]==1 then
				self.SequenceEnabled[ACT_VM_DRAW_EMPTY]=true
			end
		end
	end	
	
	if (CurTime()<self:GetReloadingEnd()) then
		self:SetReloading(false)
		self:SetReloadingEnd(CurTime()-1)
	end

	
	if (CurTime()<self:GetHolsteringEnd()) then
		self:SetHolstering(false)
		self:SetHolsteringEnd(CurTime()-1)
	end
	
	
	local tmpact=self:GetActivity()
	if !self.LastDrawAnimTime then
		self.LastDrawAnimTime=-1
	end
	
	local success, anim
	if ( tmpact==0 or !(act==ACT_VM_DRAW or act==ACT_VM_DRAW_EMPTY or act==ACT_VM_DRAW_SILENCED) ) and ( CurTime()-self.LastDrawAnimTime > 0.2 )then
		self.LastDrawAnimTime = CurTime()
		success, anim = self:ChooseDrawAnim()
	end
	
	self:SetDrawing(success)
	
	if success then
		local vm = self.Owner:GetViewModel()
		local seq = vm:SelectWeightedSequence( anim )
		local seqtime=vm:SequenceDuration( seq )
		if self.ShootWhileDraw==false then
			self:SetNextPrimaryFire(CurTime()+seqtime)
		end
		
		self:SetDrawingEnd(CurTime()+seqtime)
		local myhangtimev = 1
		if self:OwnerIsValid() then
			if SERVER then
				myhangtimev = self.Owner:GetInfoNum("cl_rev_hud_hangtime",1)
			else
				myhangtimev = GetConVarNumber("cl_rev_hud_hangtime",1)
			end
		end
		self:SetHUDThresholdEnd(CurTime()+seqtime+myhangtimev)
	end
end

--[[ 
Function Name:  InitHolsterCode
Syntax: self:InitHolsterCode("1 or 0, 1 or 0")
Notes:  the instr parameter is deprecated since client autodetection has been improved and is actually better than the server.
Returns:  Nothing
Purpose:  Standard SWEP Function
]]--

function SWEP:InitHolsterCode( instr )

	self.LastDrawAnimTime=-1

	if CLIENT then
		local t=string.Explode(",",instr,false)
		if t[1] then
			self.SequenceEnabled[ACT_VM_DRAW]=false
			if t[1]==1 then
				self.SequenceEnabled[ACT_VM_HOLSTER]=true
			end
		end
		if t[2] then
			self.SequenceEnabled[ACT_VM_HOLSTER_EMPTY]=false
			if t[2]==1 then
				self.SequenceEnabled[ACT_VM_HOLSTER_EMPTY]=true
			end
		end
	end	
	
	if SERVER or ( CLIENT and IsFirstTimePredicted() )then
		local ha, tact=self:ChooseHolsterAnim()
		local vm = self.Owner:GetViewModel()
		if (!ha) then
			self:SetCanHolster(true)
			self:Holster(self:GetNWEntity("SwitchToWep",nil))
			self:SetHolstering(false)
			return
		end
		
		local seqtime=self.SequenceLength[tact]
	
		if self.ShootWhileHolster==false then
			self:SetNextPrimaryFire(CurTime()+seqtime)
		end
	
		self:SetHolstering(true)
	
		self:SetHolsteringEnd(CurTime()+seqtime)
	end
end

--[[ 
Function Name:  Precache
Syntax: Should not be normally called.
Returns:  Nothing.  Simply precaches models/sound.
Purpose:  Standard SWEP Function
]]--

function SWEP:Precache()
	if self.Primary.Sound then
		util.PrecacheSound(self.Primary.Sound)
	end
	util.PrecacheModel(self.ViewModel)
	util.PrecacheModel(self.WorldModel)
end

--[[ 
Function Name:  Initialize
Syntax: Should not be normally called.
Notes:   Called after actual SWEP code, but before deploy, and only once.
Returns:  Nothing.  Sets the intial values for the SWEP when it's created. 
Purpose:  Standard SWEP Function
]]--

function SWEP:Initialize()
	
	if (!self.Primary.Damage) or (self.Primary.Damage<=0.01) then
		self:AutoDetectDamage()
	end
	
	if !self.Primary.Accuracy then
		if self.Primary.ConeSpray then
			self.Primary.Accuracy  = ( 5 / self.Primary.ConeSpray) / 90
		else
			self.Primary.Accuracy = 0.01
		end
	end
	
	if !self.Primary.IronAccuracy then
		self.Primary.IronAccuracy = self.Primary.Accuracy * 0.2
	end
	
	if self.MuzzleAttachment == "1" then
		self.CSMuzzleFlashes = true
	end
	
	self:CreateFireModes()
	
	self:AutoDetectRange()
	
	self.DefaultHoldType = self.HoldType
	self.ViewModelFOVDefault = self.ViewModelFOV
	
	self.DrawCrosshairDefault = self.DrawCrosshair
	
	self:SetUpSpread()
	
	self:CorrectScopeFOV( self.DefaultFOV and self.DefaultFOV or self.Owner:GetFOV() )
	
	if CLIENT then
		self:InitMods()
		self:IconFix()
	end
	self.drawcount=0
	self.drawcount2=0
	self.canholster=false
	
	self:SetDeploySpeed(self.SequenceLength[ACT_VM_DRAW])
	
	if !self.Primary.ClipMax then
		self.Primary.ClipMax = self.Primary.ClipSize * 3
	end
end

--[[ 
Function Name:  Deploy
Syntax: self:Deploy()
Notes:  Called after self:Initialize().  Called each time you draw the gun.  This is also essential to clearing out old networked vars and resetting them.
Returns:  True/False to allow quickswitch.  Why not?  You should really return true.
Purpose:  Standard SWEP Function
]]--

function SWEP:Deploy()

	if (!self.Primary.Damage) or (self.Primary.Damage<=0.01) then
		self:AutoDetectDamage()
	end
	
	if !self.Primary.Accuracy then
		if self.Primary.ConeSpray then
			self.Primary.Accuracy  = ( 5 / self.Primary.ConeSpray) / 90
		else
			self.Primary.Accuracy = 0.01
		end
	end
	
	if !self.Primary.IronAccuracy then
		self.Primary.IronAccuracy = self.Primary.Accuracy * 0.2
	end
	
	if self.MuzzleAttachment == "1" then
		self.CSMuzzleFlashes = true
	end
	
	self:CreateFireModes()

	self.ViewModelFOVDefault = self.ViewModelFOV
	self.DefaultFOV=self.Owner:GetFOV()
	
	if self.DrawCrosshairDefault==nil then
		self.DrawCrosshairDefault = self.DrawCrosshair
	end
	
	self:ResetSightsProgress()
	
	self:AutoDetectRange()
	
	
	self.isfirstdraw=false
	if !self.hasdrawnbefore then
		self.hasdrawnbefore = true
		self.isfirstdraw=true
		--self.Primary.DefaultClip = 0
	end
	
	if self.isfirstdraw then
		self:SetDeploySpeed(self.SequenceLength[ACT_VM_DRAW])
	end
	
	
	timer.Simple(0, function()
		if IsValid(self) then
			self:ChooseDrawAnim()
		end
	end)
	
	if self.Owner:KeyDown(IN_ATTACK2) and self.SightWhileDraw then
		self:SetIronSights(true)
	end
	
	if self.Owner:KeyDown(IN_SPEED) and self.Owner:GetVelocity():Length()>self.Owner:GetWalkSpeed() then
		self:SetSprinting(true)
	end
	
	self:SetHoldType(self.HoldType)
	
	self.OldIronsights=(false)
	self:SetIronSights(false)
	self:SetIronSightsRaw(false)
	self.OldSprinting=(false)
	self.OldSafety=(false)
	self:SetSprinting(false)
	self:SetShooting(false)
	self:SetChangingSilence(false)
	self:SetCanHolster(false)
	self:SetReloading(false)
	self:SetShotgunInsertingShell(false)
	self:SetShotgunCancel( false )
	self:SetShotgunPumping(false)
	self:SetShotgunNeedsPump(false )
	self:SetFireModeChanging( false ) 
	self:SetBoltTimer( false )
	self:SetReloadingEnd(CurTime()-1)
	self:SetShootingEnd(CurTime()-1)
	self:SetDrawingEnd(CurTime()-1)
	self:SetHolsteringEnd(CurTime()-1)
	self:SetNextSilenceChange(CurTime()-1)
	self:SetFireModeChangeEnd(CurTime()-1)
	self:SetHUDThreshold(true)
	self:SetHUDThresholdEnd(CurTime()+0.2)
	self:SetBoltTimerStart(CurTime()-1)
	self:SetBoltTimerEnd(CurTime()-1)
	self:SetDrawing(true)
	self:SetHolstering(false)
	self:SetInspecting(false)
	if self:GetSilenced()==nil then
		self:SetSilenced(self.Silenced and self.Silenced or 0)
	end
	self:SetIronSightsRatio(0)
	self:SetRunSightsRatio(0)
	self:SetCrouchingRatio(0)
	self:SetJumpingRatio(0)
	self:SetSpreadRatio(0)
	self:SetBurstCount(0)
	self:SetInspectingRatio(0)
	self:SetBursting(false)
	self:SetUpSpread()
	self.PenetrationCounter = 0
	if CLIENT or game.SinglePlayer() then
		self.CLSpreadRatio=1
		self.CLIronSightsProgress = 0
		self.CLRunSightsProgress = 0
		self.CLCrouchProgress = 0
		self.CLInspectingProgress = 0
	end
	self:SetNextIdleAnim(CurTime()-1)
	local vm = self.Owner:GetViewModel()
	if IsValid(vm) then
		self:SendWeaponAnim(0)
		self.DefaultAtt = vm:GetAttachment(self:GetFPMuzzleAttachment())
	end
	local drawtimerstring=(self.SequenceEnabled[ACT_VM_DRAW] and 1 or 0)..","..(self.SequenceEnabled[ACT_VM_DRAW_EMPTY] and 1 or 0)
	
	self:InitDrawCode(drawtimerstring)
	
	self:CorrectScopeFOV( self.DefaultFOV and self.DefaultFOV or self.Owner:GetFOV() )
	
	self.customboboffset=Vector(0,0,0)
	
	return true
end

--[[ 
Function Name:  Holster
Syntax: self:Holster( weapon entity to switch to )
Notes:  This is kind of broken.  I had to manually select the new weapon using ply:ConCommand.  Returning true is simply not enough.  This is also essential to clearing out old networked vars and resetting them.
Returns:  True/False to allow holster.  Useful for animations.
Purpose:  Standard SWEP Function
]]--


function SWEP:Holster( switchtowep )

	self:SetShotgunCancel( true )
	
	self:CleanParticles()
	
	if SERVER then
		self:CallOnClient("CleanParticles","")
	end
	
	if IsValid(self.Owner:GetViewModel()) then
		self.Owner:GetViewModel():StopParticles()
	end
		
	self.PenetrationCounter = 0

	if self==switchtowep then
		return
	end
	
	if switchtowep then
		self:SetNWEntity("SwitchToWep",switchtowep)
	end
	
	self:SetReloading(false)
	self:SetDrawing(false)
	
	self:SetInspecting(false)
	
	if (CurTime()<self:GetDrawingEnd()) then
		self:SetDrawingEnd(CurTime()-1)
	end
	
	if (CurTime()<self:GetReloadingEnd()) then
		self:SetReloadingEnd(CurTime()-1)
	end
	local hasholsteringanim = self.SequenceEnabled[ACT_VM_HOLSTER] or self.SequenceEnabled[ACT_VM_HOLSTER_EMPTY]
	if self:GetCanHolster()==false and hasholsteringanim then
		if !( self:GetHolstering() and CurTime()<self:GetHolsteringEnd() ) then
			local holstertimerstring=(self.SequenceEnabled[ACT_VM_HOLSTER] and 1 or 0)..","..(self.SequenceEnabled[ACT_VM_HOLSTER_EMPTY] and 1 or 0)
			self:InitHolsterCode(holstertimerstring)
		else
			if self:GetHolsteringEnd()-CurTime()<0.05 and self:GetHolstering() then
				self:SetCanHolster(true)
				self:Holster(self:GetNWEntity("SwitchToWep",switchtowep))
				return true
			end
		end
	else
		self.DrawCrosshair = self.DrawCrosshairDefault or self.DrawCrosshair
		self:SendWeaponAnim( 0 )
		dholdt = self.DefaultHoldType and self.DefaultHoldType or self.HoldType
		self:SetHoldType( dholdt )
		self:SetHolstering(false)
		self:SetHolsteringEnd(CurTime()-0.1)
		local wep=self:GetNWEntity("SwitchToWep",switchtowep)
		if IsValid( wep ) and IsValid(self.Owner) and self.Owner:HasWeapon( wep:GetClass() ) then
			if CLIENT then
				self.Owner:ConCommand("use " .. wep:GetClass())
			end
		end
		return true
	end
end

--[[ 
Function Name:  SecondaryAttack
Syntax: self:SecondaryAttack( ).
Returns:  Not sure that it returns anything.
Notes: Unused.  We process ironsights elsewhere.
Purpose:  Main SWEP function
]]--

function SWEP:SecondaryAttack()
	return false
end

--[[ 
Function Name:  Reload
Syntax: self:Reload( ).
Returns:  Not sure that it returns anything.
Notes:  This reloads the gun, and the way it does so is slightly hacky and depends on holdtype.  Revolvers should be the only guns using revolver holdtype for this to properly function.
Purpose:  Main SWEP function
]]--

function SWEP:Reload()
	
	self:SetBurstCount(0)
	self:SetBursting(false)
	self:SetNextBurst(CurTime()-1)
	
	if self:GetReloading() then return end
	
	if not ( self.Owner:KeyDown(IN_RELOAD) or self.Owner:KeyPressed(IN_ATTACK) ) then
		return
	end
	
	
	if (self:GetBursting()) then
		return
	end
	
	--if self.SelectiveFire then
		if IsValid(self.Owner) and self.Owner:KeyDown(IN_USE) then
			return
		end
	--end
	
	if (self:GetDrawing() ) and self.AllowReloadWhileDraw==false then
		return
	end
	
	if (self:GetSprinting() ) and !self.AllowReloadWhileSprinting then
		return
	end
	
	if (CurTime()<self:GetReloadingEnd()) then
		self:SetReloadingEnd(CurTime()-1)
	end
 
	if ( self:Clip1() < (self.Primary.ClipSize + ( (not self.DisableChambering and not self.BoltAction and not self.Shotgun and not (self.Revolver) and not ( (self.DefaultHoldType and self.DefaultHoldType or self.HoldType) == "revolver" ) ) and 1 or 0 )  ) and self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 ) then
	
		self:SetReloading(true)
		
		--self:ProcessTimers()
	
		if self.UnSightOnReload then
			self:SetIronSights(false)
		end
		
		self:ProcessHoldType()
		
		self:SetInspecting(false)
		--self:SetInspectingRatio(0)
		
		--self:DefaultReload( ACT_VM_RELOAD )
		if !self.Shotgun then
			--self:ChooseReloadAnim()
			if self:Clip1() == 0 then
				self:DefaultReload( ACT_VM_RELOAD_EMPTY )
			else
				self:DefaultReload( ACT_VM_RELOAD )
			end
		else
			self:SendWeaponAnim( ACT_SHOTGUN_RELOAD_START )
			self:SetShotgunInsertingShell(false)
			self:SetShotgunPumping(false)
		end
		
		self:SetHoldType(self.DefaultHoldType and self.DefaultHoldType or self.HoldType)
		if !self.ThirdPersonReloadDisable then
			self.Owner:SetAnimation( PLAYER_RELOAD ) -- 3rd Person Animation
		end

		if (CLIENT) then
			timer.Simple(0, function()
				if !IsValid(self) then return end
				if !IsValid(self.Owner) then return end
				if !self.ThirdPersonReloadDisable then
					self.Owner:SetAnimation( PLAYER_RELOAD ) -- 3rd Person Animation
				end
			end)
		end
		local AnimationTime = self.Owner:GetViewModel():SequenceDuration()
		self.prevdrawcount=self.drawcount

		self:SetReloadingEnd(CurTime()+AnimationTime)
        self.ReloadingTime = CurTime() + AnimationTime
        self:SetNextPrimaryFire(CurTime() + AnimationTime)
        self:SetNextSecondaryFire(CurTime() + AnimationTime)
		
	end 
end

--[[ 
Function Name:  ProcessTimers
Syntax: self:ProcessTimers().  This is called per-think.
Returns:  Nothing.  However, calculates OMG so much stuff what is this horrible hacky code that allows you to use bolt action snipers, shotguns, and normal guns all in the same base?!!!111oneoneone
Notes:  This is essential.
Purpose:  Don't remove this, seriously.
]]--

function SWEP:ProcessTimers()
	local isreloading,isshooting,isdrawing,isholstering, issighting, issprinting, htv, hudhangtime, isbolttimer, isinspecting
	
	isreloading=self:GetReloading()
	isshooting=self:GetShooting()
	isdrawing=self:GetDrawing()
	isholstering=self:GetHolstering()
	issighting=self:GetIronSights()
	issprinting=self:GetSprinting()
	isbursting = self:GetBursting()
	ischangingsilence = self:GetChangingSilence()
	isfiremodechanging = self:GetFireModeChanging()
	isinspecting = self:GetInspecting()
	htv = self:GetHUDThreshold()
	hudhangtime = 1
	--[[
	if self.DisableIdleAnimations and !isinspecting then
		self:SetNextIdleAnim(CurTime()+30)
	end
	]]--
	if self:OwnerIsValid() then
		if SERVER then
			hudhangtime = self.Owner:GetInfoNum("cl_rev_hud_hangtime",1)
		else
			hudhangtime = GetConVarNumber("cl_rev_hud_hangtime",1)
		end
	end
	isbolttimer = self:GetBoltTimer()
	if isdrawing and CurTime()>self:GetDrawingEnd() then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self.DefaultAtt = vm:GetAttachment(self:GetFPMuzzleAttachment())
		end
		self:SetDrawing(false)
		isdrawing=false
	end
	if isbolttimer and CurTime()>self:GetBoltTimerEnd() then
		self:SetBoltTimer(false)
		self:SetBoltTimerStart(CurTime()-1)
		self:SetBoltTimerEnd(CurTime()-1)
	end
	
	if isreloading and CurTime()>self:GetReloadingEnd() then
		if !self.Shotgun then
			if IsValid(self.Owner) then
				local maxclip=self.Primary.ClipSize
				local curclip = self:Clip1()
				local amounttoreplace=math.min(maxclip-curclip+( ( (self:Clip1()>0) and not self.DisableChambering and not self.BoltAction and not (self.Revolver) and not ( (self.DefaultHoldType and self.DefaultHoldType or self.HoldType) == "revolver" ) and 1 or 0 ) ),self.Owner:GetAmmoCount(self.Primary.Ammo))
				self:SetClip1(curclip+amounttoreplace)
				self.Owner:RemoveAmmo(amounttoreplace, self.Primary.Ammo)
			end
			self:SetReloading(false)
			self:SetBurstCount(0)
			self:SetBursting(false)
			isreloading=false
			self:SetHUDThreshold(true)
			self:SetHUDThresholdEnd(CurTime() + hudhangtime)
		else
			if (self:GetShotgunInsertingShell() == false) then
				if !self:GetShotgunPumping() then
					self:SetShotgunInsertingShell(true)
					self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
					if IsValid(self.Owner) then
						local vm = self.Owner:GetViewModel()
						if !self.ShellTime and IsValid(vm) then
							self:SetReloadingEnd(CurTime()+vm:SequenceDuration( vm:SelectWeightedSequence(ACT_VM_RELOAD) ) )
						else
							self:SetReloadingEnd(CurTime()+self.ShellTime)
						end
					else
						self:SetReloadingEnd(CurTime()+self.ShellTime)
					end
					self:SetReloading(true)
					isreloading=true
				else
					self:SetReloading(false)
					self:SetShotgunPumping(false)
					self:SetReloadingEnd(CurTime()-1)
					isreloading=false
					self:SetHUDThreshold(true)
					self:SetHUDThresholdEnd(CurTime() + hudhangtime)
				end
			else
				local maxclip=self.Primary.ClipSize
				local curclip = self:Clip1()
				local ammopool = self:GetAmmoReserve()
				if curclip>=maxclip or ammopool<=0 or self:GetShotgunNeedsPump() then
					self:SetShotgunInsertingShell(false)
					self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
					if IsValid(self.Owner) then
						local vm = self.Owner:GetViewModel()
						if IsValid(vm) then
							self:SetReloadingEnd(CurTime()+vm:SequenceDuration( vm:SelectWeightedSequence(ACT_SHOTGUN_RELOAD_FINISH) ) )
						else
							self:SetReloadingEnd(CurTime()+self.ShellTime)
						end
					else
						self:SetReloadingEnd(CurTime()+self.ShellTime)
					end
					self:SetReloading(true)
					self:SetShotgunPumping(true)
					self:SetShotgunNeedsPump(false)
				else
					local amounttoreplace=1
					self:SetClip1(curclip+amounttoreplace)
					self.Owner:RemoveAmmo(amounttoreplace, self.Primary.Ammo)
					curclip = self:Clip1()
					if (curclip<maxclip) then
						self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
						self:SetReloading(true)
						self:SetShotgunInsertingShell(true)
						if IsValid(self.Owner) then
							local vm = self.Owner:GetViewModel()
							if !self.ShellTime and IsValid(vm) then
								self:SetReloadingEnd(CurTime()+vm:SequenceDuration( vm:SelectWeightedSequence(ACT_VM_RELOAD) ) )
							else
								self:SetReloadingEnd(CurTime()+self.ShellTime)
							end
						else
							self:SetReloadingEnd(CurTime()+self.ShellTime)
						end
					else
						self:SetReloadingEnd(CurTime()-1)
						self:SetReloading(true)
						self:SetShotgunInsertingShell(true)
					end
					if self:GetShotgunCancel() then
						self:SetShotgunCancel( false )
						self:SetReloading(true)
						self:SetShotgunNeedsPump( true )
						self:SetReloadingEnd(CurTime()-1)
					end
				end
			end
		end
	end
	if isholstering and CurTime()>self:GetHolsteringEnd() then
		self:SetCanHolster(true)
		self:Holster(self:GetNWEntity("SwitchToWep",nil))
		self:SetHolstering(false)
		isholstering=false
	end
	if isbursting then
		if CurTime()>self:GetNextBurst() then
			local maxbursts = 1
			local firemode = self.FireModes[self:GetFireMode()]
			local bpos = string.find(firemode,"Burst")
			if bpos then
				maxbursts = tonumber(string.sub(firemode,1,bpos-1)) or 3
			end
			if self:GetBurstCount() >= maxbursts then
				self:SetBursting(false)
				self:SetBurstCount(0)
			else
				self:PrimaryAttack()
			end
		end
	end
	if isshooting and CurTime()>self:GetShootingEnd() then
		self:SetShooting(false)
		isshooting=false
	end
	if isfiremodechanging and CurTime() > self:GetFireModeChangeEnd() then
		self:SetFireModeChanging(false)
		self:SetFireModeChangeEnd(CurTime() - 1)
		self:SetHUDThreshold(true)
		self:SetHUDThresholdEnd(CurTime() + hudhangtime)
	end
	if ischangingsilence and CurTime()>self:GetNextSilenceChange() then
		self:SetSilenced(!self:GetSilenced())
		self:SetChangingSilence(false)
		self:SetNextSilenceChange(CurTime() - 1)
	end
	if htv and CurTime()>self:GetHUDThresholdEnd() then
		self:SetHUDThreshold(false)
		self:SetHUDThresholdEnd(CurTime() - 1)
	end
	
end

function SWEP:ToggleInspect()
	local oldinsp = self:GetInspecting()
	self:SetInspecting(!oldinsp)
	if CLIENT then
		net.Start("revInspect")
		net.WriteBool(!oldinsp)
		net.SendToServer()
	end
	self:SetNextIdleAnim( CurTime() - 1)
end