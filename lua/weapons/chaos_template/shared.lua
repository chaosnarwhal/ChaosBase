--Template File
AddCSLuaFile()
----------------- Basic Garry's Mod SWEP structure stats / Chaos Base properties
SWEP.Base 					= "chaos_base"
SWEP.Category 				= "ChaosBase Template"
SWEP.Author                 = "" -- Author Tooltip
SWEP.Contact                = "" -- Contact Info Tooltip
SWEP.Purpose                = "" -- Purpose Tooltip
SWEP.Instructions           = "" -- Instructions Tooltip
SWEP.Spawnable              = false -- Can you, as a normal user, spawn this?
SWEP.AdminSpawnable         = false -- Can an adminstrator spawn this?  Does not tie into your admin mod necessarily, unless its coded to allow for GMod's default ranks somewhere in its code.  Evolve and ULX should work, but try to use weapon restriction rather than these.


SWEP.PrintName				= "Your Weapons Print Name here." -- 'Nice' Weapon name (Shown on HUD)
SWEP.Slot                   = 2             -- Slot in the weapon selection menu.  Subtract 1, as this starts at 0.
SWEP.SlotPos                = 73            -- Position in the slot
SWEP.AutoSwitchTo           = true      -- Auto switch to if we pick it up
SWEP.AutoSwitchFrom         = true      -- Auto switch from if you pick up a better weapon
SWEP.Weight                 = 30            -- This controls how "good" the weapon is for autopickup.

--View Model and World Model Handling.
SWEP.ViewModelFOV			= 65
SWEP.ViewModelFlip			= false
SWEP.ViewModel              = "youe viewmodel here"
SWEP.WorldModel				= "your world model here"
SWEP.UseHands				= true
SWEP.HoldType 				= "ar2"
SWEP.MuzzleAttachment       = "muzzle"       -- Should be "1" for CSS models or "muzzle" for hl2 models

--MUZZLEFLASHES AC_muzzle_pistol, AC_muzzle_rifle, AC_muzzle_desert, AC_muzzle_shotgun
 
-- The viewmodel positional offset, constantly.
-- Subtract this from any other modifications to viewmodel position.
-- AKA VMPos (SWEP Construction Kit naming, VMPos is always checked for presence and it always override ViewModelPosition if present)
SWEP.ViewModelPosition  = Vector(0, 0, 0)
-- AKA VMAng (SWEP Construction Kit naming)
-- The viewmodel angular offset, constantly.
-- Subtract this from any other modifications to viewmodel angle.
SWEP.ViewModelAngle     = Vector(0, 0, 0)

--Position for Ironsights
SWEP.IronSightsPos      = Vector(-3.8,0,-2)
--Angle for Ironsights
SWEP.IronSightsAng      = Vector(0,0,0)

--Positon for safety/sprint without Viewmodel Animation
SWEP.SafetyPos          = Vector(0,0,-2)
--Angle for safety/sprint without Viewmodel Animation
SWEP.SafetyAng          = Vector(-10, -15, 25)


--Weapon Sounds
SWEP.Primary.ShootSound          = Sound("chaosnarwhal/weapons/unsc/ma37/gunfire/rifle_fire_"..math.random(1,3)..".wav")
SWEP.Primary.DistantShootSound   = Sound("drc.ma5c_fire_dist")

--Primary Fire
SWEP.Primary.RPM          	= 550
SWEP.Primary.ClipSize		= 32			-- Size of a clip
SWEP.Primary.DefaultClip	= 32		-- Default number of bullets in a clip
SWEP.Primary.Automatic		= true		-- Automatic/Semi Auto
SWEP.Primary.Ammo			= "Pistol"

--Burst Handlig
SWEP.Primary.BurstRounds         = 3 --How many shots to fire in a burst.
SWEP.Primary.BurstDelay          = 660 --RPM Delay between burst.
SWEP.OnlyBurstFire                = false -- No auto, only burst/single?

--Entity Firing weapon.
SWEP.Projectile = nil --Nil to fire regular bullets. Set to name of an entity to begin firing that entity.

--HoldType Handling.
SWEP.HoldtypeHolstered = "passive"
SWEP.HoldtypeActive = "ar2"
SWEP.HoldtypeSights = "rpg"
SWEP.HoldtypeSprintShoot = "ar2"
SWEP.HoldtypeNPC = nil

SWEP.IronSightsEnable   = true --Enable Ironsights?

SWEP.HighTierAllow = true --Enable Hightier Table.

SWEP.HighTier = {
    --["DarkRP Category or DarkRP Job or SteamID64"] = {
    --	Type = "SPARTAN", --Declaring What kind of Tier they are.
    --  RecoilReduce = 0.1, --Reduce all recoil by this ammount. 0.1 = 90%, 0.5 = 50%, 0.75 = 25% etc.
    --  SprintShoot = true --Allow the class to shoot while sprinting.
    --},
}

--Swep damage and tracer handling.
SWEP.Bullet = {
    Damage = 1, --first value is damage at 0 meters from impact, second value is damage at furthest point in effective range
    HullSize = 0, --Increase bullet hitscan size. *easier to hit*
    DropOffStartRange = 20, --in meters, damage will start dropping off after this range
    EffectiveRange = 65, --in meters, damage scales within this distance
    Range = 180, --in meters, after this distance the bullet stops existing
    Tracer = true, --show tracer
    TracerName = "rev_halo_ar_bullet",
    NumBullets = 1, --the amount of bullets to fire
    PhysicsMultiplier = 1, --damage is multiplied by this amount when pushing objects
}

--Swep Recoil handling.
SWEP.Recoil = {
    Vertical = {0.5, 1}, --random value between the 2
    Horizontal = {-0.3, 0.3}, --random value between the 2
    Shake = 1.1, --camera shake
    AdsMultiplier = 0.2, --multiply the values by this amount while aiming
    Seed = 10922 --give this a random number until you like the current recoil pattern
}

--Swep Viewmodel recoil tuneups.
SWEP.ViewModelOffsets = {
    RecoilMultiplier = 1.15,
    KickMultiplier = 2,
    AimKickMultiplier = 0.15
}

--Swep spread handling.
SWEP.Cone = {
    Hip = 0.08, --accuracy while hip
    Ads = 0.01, --accuracy while aiming
    Increase = 0.04, --increase cone size by this amount every time we shoot
    AdsMultiplier = 0.0001, --multiply the increase value by this amount while aiming
    Max = 1, --the cone size will not go beyond this size
    Decrease = 0.8, -- amount (in seconds) for the cone to completely reset (from max)
    Seed = 9523 --just give this a random number
}

SWEP.ViewModelOffsets = {
    Aim = {
        Angles = Angle(0, 0, 0),
        Pos = Vector(0, 0, 0)
    },
    Idle = {
        Angles = Angle(0, 0, 0),
        Pos = Vector(0, 0, 0)
    },
    RecoilMultiplier = 1.15,
    KickMultiplier = 2,
    AimKickMultiplier = 0.15
}

SWEP.IronSightTime = 0.1 --Swep Ironsight time. Clientside predicted value.

SWEP.Scope = {
    ScopeMagnification = 0.75, --Scope Magnification. Comment out if using Ironsights.
    ScopeMagnificationMax = 0.75, --Max the scope is allowed to scroll to.
    ScopeMagnificationMin = 0.55, --Min the scope is allowed to scroll to.
    ScopeColor = Color(0,0,0,255), --Scope Overlay color
    ScopeBGColor = Color(0,0,0,200), --Scope Background color
    ScopeYOffset = -1, --Scope overlay offset
    ScopeScale = 0.65, --Scope overlay scale.
    ScopeWidth = 1, --Scope Width in relation to players screen size
    ScopeHeight = 1, --Scope Height in relation to players screen size
    ScrollFunc = ChaosBase.SCROLL_ZOOM, --Declare it is a scope/ironsight that can be scrolled.
    CrosshairInSights = false, --Display the crosshair in the scope?
}

SWEP.AnimatedSprint = true --Is the swep using a idle_sprint to play a sprint animation to the viewmodel ? if false when sprinting the weapon will default to safety pos/ang

--Swep Viewmodel And Third Person Handling.
SWEP.Animations = {
    -- ["idle"] = {
    --     Source = "idle",
    --     Time = 10
    -- },
    -- ["idle_walk"] = {
    --		Source = "walk" --Animation to be played when player is walking around.
    -- }
    -- ["idle_sprint"] = {
    --		Source = "sprint" --Animation to be played when player is sprinting.
    -- }
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
    --     LastClip1OutTime = 0, -- when should the belt visually replenish on a belt fed
    --     MinProgress = 0, -- how much time in seconds must pass before the animation can be cancelled
    --     ForceEmpty = false, -- Used by empty shotgun reloads that load rounds to force consider the weapon to still be empty.
    -- }
}

--SWEP firemodes declaring.
SWEP.Firemodes = {
    [1] = {
        Name = "Semi Auto",
        OnSet = function(self)
            self.Primary.Automatic = false
            return "Firemode_Semi"
        end
    },

    [2] = {
        Name = "Full Auto",
        OnSet = function(self)
            self.Primary.Automatic = true
            return "Firemode_Auto"
        end
    },

}

--SWEP Viewmodel SCK elements
SWEP.VElements = {
	["ammo_counterV"] = { type = "Quad", bone = "b_gun", rel = "", pos = Vector(5.393, 0, 7.596), angle = Angle(180, 90, -116), size = 0.005, draw_func = nil}
}

--SWEP Worldmodel SCK elements
SWEP.WElements = {
    ["ammo_counterW"] = { type = "Quad", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(6.76, 1.25, -6.7), angle = Angle(0, 90, -100.362), size = 0.005, draw_func = nil}
}