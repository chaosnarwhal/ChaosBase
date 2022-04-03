AddCSLuaFile()

SWEP.Base 					= "chaos_base"

SWEP.PrintName				= "M45 TestGun." -- 'Nice' Weapon name (Shown on HUD)
SWEP.Author					= "ChaosNarwhal"
SWEP.Contact				= ""
SWEP.Purpose				= "Testing"
SWEP.Instructions			= "Testing weapon. For Testing purposes"
SWEP.Category 				= "Revival Armory Revived."

SWEP.Spawnable				= true
SWEP.AdminOnly				= false

SWEP.ViewModelFOV			= 65
SWEP.ViewModelFlip			= false

SWEP.ViewModel          = "models/chaosnarwhal/halo/weapons/unsc/m45/v_unsc_m45.mdl"
SWEP.WorldModel         = "models/vuthakral/halo/weapons/w_m45.mdl"
SWEP.UseHands				= true
SWEP.HoldType 				= "ar2"
SWEP.MuzzleAttachment       = "muzzle"       -- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.Tracer                 = 2
SWEP.TracerName             = "rev_halo_ar_bullet" --Change to a string of your tracer name

SWEP.Primary.ShootSound          = Sound("chaosnarwhal/weapons/unsc/m45/gunfire/fire"..math.random(0,2)..".wav")
SWEP.Primary.DistantShootSound   = Sound("drc.ma5c_fire_dist")
SWEP.Primary.RPM                 = 60

SWEP.ShotgunReload = true

SWEP.Bullet = {
    Damage = 120, --first value is damage at 0 meters from impact, second value is damage at furthest point in effective range
    DropOffStartRange = 20, --in meters, damage will start dropping off after this range
    EffectiveRange = 65, --in meters, damage scales within this distance
    Range = 180, --in meters, after this distance the bullet stops existing
    Tracer = true, --show tracer
    TracerName = "rev_halo_ar_bullet",
    NumBullets = 15, --the amount of bullets to fire
    PhysicsMultiplier = 1, --damage is multiplied by this amount when pushing objects
}

SWEP.Recoil = {
    Vertical = {4, 6.5}, --random value between the 2
    Horizontal = {-0.5, 0.5}, --random value between the 2
    Shake = 4, --camera shake
    AdsMultiplier = 0.0001, --multiply the values by this amount while aiming
    Seed = 10922, --give this a random number until you like the current recoil pattern
    ViewModelMultiplier = 1.75
}

SWEP.Cone = {
    Hip = 1, --accuracy while hip
    Ads = 1, --accuracy while aiming
    Increase = 0, --increase cone size by this amount every time we shoot
    AdsMultiplier = 0.0001, --multiply the increase value by this amount while aiming
    Max = 1, --the cone size will not go beyond this size
    Decrease = 0.8, -- amount (in seconds) for the cone to completely reset (from max)
    Seed = 9523 --just give this a random number
}

SWEP.IronSightStruct = {
    Pos = Vector(-8.5, 0, 0),
    Ang = Angle(0, 0, 0),
    Magnification = 1,
    BlackBox = false,
    ScopeTexture = nil,
    SwitchToSound = "", -- sound that plays when switching to this sight
    SwitchFromSound = "",
    ScrollFunc = ChaosBase.SCROLL_NONE,
    CrosshairInSights = false,
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
SWEP.Primary.ClipSize		= 6			-- Size of a clip
SWEP.Primary.DefaultClip    = 6        -- Default number of bullets in a clip
SWEP.Primary.Automatic		= false		-- Automatic/Semi Auto
SWEP.Primary.Ammo			= "Pistol"

SWEP.Animations = {
    ["idle"] = {
        Source = "idle",
    },
    ["idle_sprint"] = {
        Source = "sprint",
    },
    ["idle_walk"] = {
        Source = "walk",
    },
    ["draw"] = {
        Source = "draw",
    },
    ["fire"] = {
        Source = {"fire1","fire2","fire3"},
    },
    ["sgreload_start"] = {
        Source = "reload_enter",
    },
    ["sgreload_insert"] = {
        Source = "reload_loop",
    },
    ["sgreload_finish"] = {
        Source = "reload_exit",
    },
    ["sgreload_finish_empty"] = {
        Source = "reload_exit",
    },
}