AddCSLuaFile()

--Shared Functions
include("modules/shared/sh_anims.lua")
include("modules/shared/sh_bullet.lua")
include("modules/shared/sh_common.lua")
include("modules/shared/sh_deploy.lua")
include("modules/shared/sh_firemode_behaviour.lua")
include("modules/shared/sh_primaryattack_behaviour.lua")
include("modules/shared/sh_reload.lua")
include("modules/shared/sh_sights.lua")
include("modules/shared/sh_think.lua")

--Clientside Functions.
include("modules/client/cl_calcviewmodelview.lua")
include("modules/client/cl_hud.lua")
include("modules/client/cl_sck.lua")

--START GUN CODE.
SWEP.Gun = "chaos_base"

--Some Defaults for later.
SWEP.ChaosBase = true
SWEP.BurstCount = 0
SWEP.AnimQueue = {}
SWEP.FiremodeIndex = 1
SWEP.UnReady = true

--Flavor Text and The name/category of the weapon.
SWEP.PrintName = "Revival Weapons Base" -- 'Nice' Weapon name (Shown on HUD)
SWEP.Author	= ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "Revival"

--WorldModels Defaults.
SWEP.WorldModel = "models/your/path/here.mdl" -- WorldModel Path

--ViewModel Defaults.
SWEP.ViewModel        = "models/your/path/here.mdl" -- Viewmodel path
SWEP.ViewModelFOV     = 65 -- This controls how big the viewmodel looks.  Less is more.
SWEP.ViewModelFlip    = false -- Set this to true for CSS models, or false for everything else (with a righthanded viewmodel.)
SWEP.UseHands 	   	  = false -- Use gmod c_arms system.
SWEP.MuzzleAttachment = "1" -- Should be "1" for CSS models or "muzzle" for hl2 models
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

--HoldType Handling.
SWEP.HoldtypeHolstered   = "passive"
SWEP.HoldtypeActive 	 = "shotgun"
SWEP.HoldtypeSights 	 = "smg"
SWEP.HoldtypeCustomize   = "slam"
SWEP.HoldtypeSprintShoot = nil
SWEP.HoldtypeNPC 		 = nil

--Spread weapon defaults
SWEP.Primary.SpreadMultiplierMax = 2.5 --How far the spread can expand when you shoot.
SWEP.Primary.SpreadIncrement = 1/3.5 --What percentage of the modifier is added on, per shot.
SWEP.Primary.SpreadRecovery = 3 --How much the spread recovers, per second.

--Weapon Sound Defaults
SWEP.Primary.Sound       = Sound("")
SWEP.ShootVol 			 = 125 -- volume of shoot sound
SWEP.ShootPitch 		 = 100 -- pitch of shoot sound
SWEP.ShootPitchVariation = 0.05

--Standard weapon defaults.
SWEP.Primary.NumShots 			= 1 --The number of shots the gun/bow fires.  
SWEP.Primary.RPM				= 600 -- This is in Rounds Per Minute / RPM
SWEP.Primary.RPM_Semi			= nil -- RPM for semi-automatic or burst fire.  This is in Rounds Per Minute / RPM
SWEP.ChamberSize 				= 1 -- how many rounds can be chambered.
SWEP.Primary.ClipSize			= 0	-- This is the size of a clip
SWEP.Primary.DefaultClip		= 0	-- This is the number of bullets the gun gives you, counting a clip as defined directly above.
SWEP.Primary.Automatic			= true -- Automatic/Semi Auto
SWEP.Primary.Ammo				= "none" -- What kind of ammo
SWEP.Primary.AmmoPerShot        = 1
SWEP.Primary.Range 				= -1 -- The distance the bullet can travel in source units.  Set to -1 to autodetect based on damage/rpm.
SWEP.Primary.RangeFalloff 		= -1 -- The percentage of the range the bullet damage starts to fall off at.  Set to 0.8, for example, to start falling off after 80% of the range.
SWEP.DrawTime 					= 1


--Firemode handling
SWEP.Firemode 					= 1 -- 0: safe, 1: semi, 2: auto, negative: burst
SWEP.Firemodes = {
    -- {
    --     Mode = 1,
    --     CustomBars = "---_#!",
--[[
                Custom bar setup
        Colored variants        Classic
        'a' Filled              '-' Filled
        'b' Outline             '_' Outline
        'd' CLR w Outline       '!' Red w Outline
                    '#' Empty
]]
    --     PrintName = "PUMP",
    --     RunAwayBurst = false,
    --     AutoBurst = false, -- hold fire to continue firing bursts
    --     PostBurstDelay = 0,
    --     ActivateElements = {}
    -- }
}

--Tracer Defaults
SWEP.TracerNum = 1 -- tracer every X
SWEP.TracerFinalMag = 0 -- the last X bullets in a magazine are all tracers
SWEP.Tracer = "rev_halo_ar_bullet" -- override tracer (hitscan) effect
SWEP.TracerCol = Color(255, 255, 255)
SWEP.HullSize = 0 -- HullSize used by FireBullets

--Shooting Entites "aka Rockets"
SWEP.ShootEntity = nil -- entity to fire, if any
SWEP.MuzzleVelocity = 400 -- projectile muzzle velocity in m/s

--Shotgun Defaults
SWEP.IsShotgun = false -- weapon receives shotgun ammo types
SWEP.ShotgunReload = false -- reloads like shotgun instead of magazines
SWEP.ManualAction = false -- pump/bolt action
SWEP.ShotgunSpreadPattern = nil
SWEP.ReloadTime = 1

--Swep Damage Defaults
SWEP.Damage = 26
SWEP.DamageType = DMG_BULLET
SWEP.DamageTypeHandled = false -- set to true to have the base not do anything with damage types
-- this includes: igniting if type has DMG_BURN; adding DMG_AIRBOAT when hitting helicopter; adding DMG_BULLET to DMG_BUCKSHOT


--Custom Body Part Damage
SWEP.BodyDamageMults = nil
-- if a limb is not set the damage multiplier will default to 1
-- that means gmod's stupid default limb mults will **NOT** apply
-- {
--     [HITGROUP_HEAD] = 1.25,
--     [HITGROUP_CHEST] = 1,
--     [HITGROUP_LEFTARM] = 0.9,
--     [HITGROUP_RIGHTARM] = 0.9,
-- }

--Recoil Defaults.
SWEP.Primary.KickUp				= 0	-- This is the maximum upwards recoil (rise)
SWEP.Primary.KickDown			= 0	-- This is the maximum downwards recoil (skeet)
SWEP.Primary.KickHorizontal		= 0	-- This is the maximum sideways recoil (no real term)
SWEP.Primary.StaticRecoilFactor = 0 --Amount of recoil to directly apply to EyeAngles.  Enter what fraction or percentage (in decimal form) you want.  This is also affected by a convar that defaults to 0.5.

--Setup Bashing
SWEP.CanBash = true -- Can Melee?
SWEP.PrimaryBash = false -- primary attack triggers melee attack (energy Sword or Grav Hammer)
SWEP.Lunge = nil -- Whether to allow the bash/melee to lunge a short distance
SWEP.LungeLength = 64 -- Maximum distance for lunging
SWEP.MeleeDamage = 25
SWEP.MeleeRange = 16
SWEP.MeleeDamageType = DMG_CLUB
SWEP.MeleeTime = 0.5
SWEP.MeleeGesture = nil
SWEP.MeleeAttackTime = 0.2

SWEP.Melee2 = false
SWEP.Melee2Damage = 25
SWEP.Melee2Range = 16
SWEP.Melee2Time = 0.5
SWEP.Melee2Gesture = nil
SWEP.Melee2AttackTime = 0.2



--Ironsight handling.
SWEP.Secondary.IronSightsEnabled = true
-- Controls Field of View when scoping in.
-- Default FoV of Garry's Mod is 75, most of players prefer 90
-- Lesser FoV value means stronger "zoom"
-- Good value to begin experimenting with is 70
-- AKA Secondary.IronFOV
SWEP.Secondary.OwnerFOV = 70
-- AKA IronViewModelFOV
SWEP.Secondary.ViewModelFOV = 65 -- Defaults to 65. Target viewmodel FOV when aiming down the sights.
-- Time needed to enter / leave the ironsight in seconds
SWEP.SightTime = 0.25
-- The position offset applied when entering the ironsight
SWEP.IronSightsPos = Vector(0, 0, 0)
-- The rotational offset applied when entering the ironsight
SWEP.IronSightsAng = Vector(0, 0, 0)


-- If Jamming is enabled, a heat meter will gradually build up until it reaches HeatCapacity.
-- Once that happens, the gun will overheat, playing an animation. If HeatLockout is true, it cannot be fired until heat is 0 again.
SWEP.Heat = false
SWEP.HeatCapacity = 200 -- rounds that can be fired non-stop before the gun jams, playing the "fix" animation
SWEP.HeatDissipation = 2 -- rounds' worth of heat lost per second
SWEP.HeatLockout = false -- overheating means you cannot fire until heat has been fully depleted
SWEP.HeatDelayTime = 0.5
SWEP.HeatFix = false -- when the "fix" animation is played, all heat is restored.
SWEP.HeatOverflow = nil -- if true, heat is allowed to exceed capacity (this only applies when the default overheat handling is overridden)

--Active Pos
SWEP.ActivePos = Vector(0, 0, 0)
SWEP.ActiveAng = Angle(0, 0, 0)

-- When using custom sprint animations, set this to the same as ActivePos and ActiveAng
SWEP.SprintPos = nil
SWEP.SprintAng = nil

--Sprint Attack?
SWEP.ShootWhileSprint = false

--SCK KIT integration.
SWEP.VElements 				= {}
SWEP.WElements 				= {}




--BASE VALUES DONT TOUCH.
SWEP.CLIronSightsProgress  = 0

function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "NWState")
	self:NetworkVar("Int", 1, "FireMode")
	self:NetworkVar("Int", 2, "BurstCountUM")
	self:NetworkVar("Int", 3, "LastLoad")
	self:NetworkVar("Int", 4, "NthReload")
	self:NetworkVar("Int", 5, "NthShot")

	-- 2 = insert
    -- 3 = cancelling
    -- 4 = insert empty
    -- 5 = cancelling empty
    self:NetworkVar("Int", 6, "ShotgunReloading")
    self:NetworkVar("Int", 7, "MagUpCount")

    self:NetworkVar("Bool", 0, "HeatLocked")
    self:NetworkVar("Bool", 1, "NeedCycle")
    self:NetworkVar("Bool", 2, "IronSights")
    self:NetworkVar("Bool", 3, "IronSightsRaw")


    self:NetworkVar("Float", 0, "Heat")
    self:NetworkVar("Float", 1, "ReloadingREAL")
    self:NetworkVar("Float", 2, "NextIdle")
    self:NetworkVar("Float", 3, "Holster_Time")
    self:NetworkVar("Float", 4, "NWSightDelta")
    self:NetworkVar("Float", 5, "NWSprintDelta")
    self:NetworkVar("Float", 6, "WeaponOpDelay")
    self:NetworkVar("Float", 7, "MagUpIn")
    self:NetworkVar("Float", 8, "IronSightsRatio")

    self:NetworkVar("Entity", 0, "Holster_Entity")
    self:NetworkVar("Entity", 1, "SwapTarget")

end

function SWEP:OnRestore()
	self:SetNthReload(0)
	self:SetNthShot(0)
    self:SetBurstCountUM(0)
    self:SetReloadingREAL(0)
    self:SetWeaponOpDelay(0)
    self:SetMagUpIn(0)

    self:KillTimers()
    self:Initialize()

    self.UnReady = false
end

function SWEP:SetBurstCount(b)
    self:SetBurstCountUM(b)
end

function SWEP:GetBurstCount()
    return self:GetBurstCountUM() or 0
end

function SWEP:SetReloading( v )
    if isbool(v) then
        if v then
            self:SetReloadingREAL(math.huge)
        else
            self:SetReloadingREAL(-math.huge)
        end
    elseif isnumber(v) and v > self:GetReloadingREAL() then
        self:SetReloadingREAL( v )
    end
end

function SWEP:GetReloading()
    local decide

    if self:GetReloadingREAL() > CurTime() then
        decide = true
    else
        decide = false
    end

    return decide
end

function SWEP:SetState(v)
    self:SetNWState(v)
    if !game.SinglePlayer() and CLIENT then self.State = v end
end

function SWEP:GetState(v)
    if !game.SinglePlayer() and CLIENT and self.State then return self.State end
    return self:GetNWState(v)
end

SWEP.CL_SightDelta = 0
function SWEP:SetSightDelta(d)
    if !game.SinglePlayer() and CLIENT then self.CL_SightDelta = d end
    self:SetNWSightDelta(d)
end

function SWEP:GetSightDelta()
    if !game.SinglePlayer() and CLIENT then return self.CL_SightDelta end
    return self:GetNWSightDelta()
end

SWEP.CL_SprintDelta = 0
function SWEP:SetSprintDelta(d)
    if !game.SinglePlayer() and CLIENT then self.CL_SprintDelta = d end
    self:SetNWSprintDelta(d)
end

function SWEP:GetSprintDelta()
    if !game.SinglePlayer() and CLIENT then return self.CL_SprintDelta end
    return self:GetNWSprintDelta()
end


SWEP.Animations = {
    -- ["idle"] = {
    --     Source = "idle",
    --     Time = 10
    -- },
    -- ["draw"] = {
    --     RestoreAmmo = 1, -- only used by shotgun empty insert reload
    --     Source = "deploy",
    --     RareSource = "", -- 1/RareSourceChance of playing this animation instead
    --     RareSourceChance = 100, -- Chance the rapper
    --     Time = 0.5, -- Overwrites the duration of the animation (changes speed). Don't set to use sequence length
    --     Mult = 1, -- Multiplies the rate of animation.
    --     TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2, -- third person animation to play when this animation is played
    --     TPAnimStartTime = 0, -- when to start it from
    --     Checkpoints = {}, -- time checkpoints. If weapon is unequipped, the animation will continue to play from these checkpoints when reequipped.
    --     ShellEjectAt = 0, -- animation includes a shell eject at these times
    --     LHIKIn = 0.25, -- In/Out controls how long it takes to switch to regular animation.
    --     LHIKOut = 0.25, -- (not actually inverse kinematics)
    --     LHIKEaseIn = 0.1, -- how long LHIK eases in.
    --     LHIKEaseOut = 0.1, -- if no value is specified then ease = lhikin
    --     LHIKTimeline = { -- allows arbitrary LHIK values to be interpolated between
    --         {
    --             t = 0.1,
    --             lhik = 0,
    --         },
    --         {
    --             t = 0.25,
    --             lhik = 1
    --         }
    --     },
    --     LHIK = true, -- basically disable foregrips on this anim
    --     SoundTable = {
    --         {
    --             s = "", -- sound; can be string or table
    --             p = 100, -- pitch
    --             v = 75, -- volume
    --             t = 1, -- time at which to play relative to Animations.Time
    --             c = CHAN_ITEM, -- channel to play the sound

    --             -- Can also play an effect at the same time
    --             e = "", -- effect name
    --             att = nil, -- attachment, defaults to shell attachment
    --             mag = 100, -- magnitude
    --             -- also capable of modifying bodygroups
    --             ind = 0,
    --             bg = 0,
    --             -- and poseparams
    --             pp = "pose",
    --             ppv = 0.25,
    --         }
    --     },
    --     ViewPunchTable = {
    --         {
    --             p = Vector(0, 0, 0),
    --             t = 1
    --         }
    --     },
    --     ProcDraw = false, -- for draw/deploy animations, always procedurally draw in addition to playing animation
    --     ProcHolster = false, -- procedural holster weapon, THEN play animation
    --     LastClip1OutTime = 0, -- when should the belt visually replenish on a belt fed
    --     MinProgress = 0, -- how much time in seconds must pass before the animation can be cancelled
    --     ForceEmpty = false, -- Used by empty shotgun reloads that load rounds to force consider the weapon to still be empty.
    -- }
}

function SWEP:Initialize()

end