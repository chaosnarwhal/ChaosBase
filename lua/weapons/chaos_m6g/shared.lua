AddCSLuaFile()

SWEP.Base 					= "chaos_base"

SWEP.PrintName				= "M6h2" -- 'Nice' Weapon name (Shown on HUD)
SWEP.Author					= "ChaosNarwhal"
SWEP.Contact				= ""
SWEP.Purpose				= "Testing"
SWEP.Instructions			= "Testing weapon. For Testing purposes"
SWEP.Category 				= "Revival Armory Revived."

SWEP.Spawnable				= true
SWEP.AdminOnly				= false

SWEP.ViewModelFOV			= 65
SWEP.ViewModelFlip			= false

SWEP.ViewModel 				= "models/chaosnarwhal/halo/weapons/unsc/m6h2/v_unsc_m6h2.mdl"
SWEP.WorldModel				= "models/chaosnarwhal/halo/weapons/unsc/m6h2/w_unsc_m6h2.mdl"
SWEP.UseHands				= true
SWEP.HoldType 				= "ar2"
SWEP.MuzzleAttachment       = "muzzle"       -- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.Tracer                 = 2
SWEP.TracerName             = "rev_halo_ar_bullet" --Change to a string of your tracer name

SWEP.Primary.ShootSound          = Sound("chaosnarwhal/weapons/unsc/m6h2/gunfire/pistol_fire.wav")
SWEP.Primary.DistantShootSound   = Sound("drc.ma5c_fire_dist")
SWEP.Primary.RPM          	     = 550

--HoldType Handling.
SWEP.HoldtypeHolstered = "passive"
SWEP.HoldtypeActive = "revolver"
SWEP.HoldtypeSights = "revolver"
SWEP.HoldtypeSprintShoot = "shotgun"
SWEP.HoldtypeNPC = nil

SWEP.Bullet = {
    Damage = 250, --first value is damage at 0 meters from impact, second value is damage at furthest point in effective range
    HullSize = 2,
    DropOffStartRange = 60, --in meters, damage will start dropping off after this range
    EffectiveRange = 65, --in meters, damage scales within this distance
    Range = 180, --in meters, after this distance the bullet stops existing
    Tracer = true, --show tracer
    TracerName = "rev_halo_ar_bullet",
    NumBullets = 1, --the amount of bullets to fire
    PhysicsMultiplier = 1, --damage is multiplied by this amount when pushing objects
}

SWEP.Recoil = {
    Vertical = {0.5, 1}, --random value between the 2
    Horizontal = {-0.5, 0.5}, --random value between the 2
    Shake = 1.1, --camera shake
    AdsMultiplier = 0.0001, --multiply the values by this amount while aiming
    Seed = 10922 --give this a random number until you like the current recoil pattern
}

SWEP.Cone = {
    Hip = 0.03, --accuracy while hip
    Ads = 0.03, --accuracy while aiming
    Increase = 0.04, --increase cone size by this amount every time we shoot
    AdsMultiplier = 0.0001, --multiply the increase value by this amount while aiming
    Max = 1, --the cone size will not go beyond this size
    Decrease = 0.8, -- amount (in seconds) for the cone to completely reset (from max)
    Seed = 9523 --just give this a random number
}

SWEP.SightTime = 0.1

SWEP.Scope = {
    --Magnification = 0.75,
    ScopeMagnification = 0.75,
    ScopeMagnificationMax = 0.75,
    ScopeMagnificationMin = 0.55,
    ScopeColor = Color(0,0,0,255),
    ScopeBGColor = Color(0,0,0,200),
    ScopeYOffset = -1,
    ScopeScale = 0.65,
    ScopeWidth = 1,
    ScopeHeight = 1,
    SwitchToSound = "", -- sound that plays when switching to this sight
    SwitchFromSound = "",
    ScrollFunc = ChaosBase.SCROLL_ZOOM,
    CrosshairInSights = false,
}

SWEP.Zoom = {
    FovMultiplier = 0.85,
    ViewModelFovMultiplier = 0.9,
    Blur = {
        EyeFocusDistance = 7
    }
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

SWEP.AllowSprintShoot		= false

--Primary Fire
SWEP.Primary.ClipSize		= 12			-- Size of a clip
SWEP.Primary.DefaultClip	= 12		-- Default number of bullets in a clip
SWEP.Primary.Automatic		= false		-- Automatic/Semi Auto
SWEP.Primary.Ammo			= "Pistol"

SWEP.Animations = {
    ["idle"] = {
        Source = "idle",
    },
     ["idle_sprint"] = {
        Source = "sprint",
    },
    ["draw"] = {
        Source = "deploy",
    },
    ["ready"] = {
        Source = "deploy",
    },
    ["reload_empty"] = {
        Source = "reload_empty",
    },
    ["reload"] = {
        Source = "reload",
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_PISTOL
    },
    ["fire"] = {
        Source = {"fire"},
        TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
    },
    ["fire_empty"] = {
    	Source = {"fire_last"}
    }
}

SWEP.Firemodes = {
    [1] = {
        Name = "Semi Auto",
        OnSet = function(self)
            self.Primary.Automatic = false
            return "Firemode_Semi"
        end
    },

}