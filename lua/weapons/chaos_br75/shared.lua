AddCSLuaFile()

SWEP.Base 					= "chaos_base"

SWEP.PrintName				= "BR75" -- 'Nice' Weapon name (Shown on HUD)
SWEP.Author					= "ChaosNarwhal"
SWEP.Contact				= ""
SWEP.Purpose				= "Testing"
SWEP.Instructions			= "Testing weapon. For Testing purposes"
SWEP.Category 				= "Revival Armory Revived."

SWEP.Spawnable				= true
SWEP.AdminOnly				= false

SWEP.ViewModelFOV			= 70
SWEP.ViewModelFlip			= false

SWEP.ViewModel              = "models/chaosnarwhal/halo/weapons/unsc/br75/v_unsc_br75.mdl"
SWEP.WorldModel				= "models/chaosnarwhal/halo/weapons/unsc/br75/w_unsc_br75.mdl"
SWEP.UseHands				= true
SWEP.HoldType 				= "ar2"
SWEP.MuzzleAttachment       = "muzzle"       -- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.Tracer                 = 2
SWEP.TracerName             = "rev_halo_ar_bullet" --Change to a string of your tracer name

SWEP.Primary.ShootSound          = Sound("chaosnarwhal/weapons/unsc/br75/gunfire/rifle_fire_1.wav")
SWEP.Primary.DistantShootSound   = Sound("drc.ma5c_fire_dist")
SWEP.Primary.RPM          	     = 900

--Burst Handlig
SWEP.Primary.BurstRounds         = 3
SWEP.Primary.BurstDelay          = 0.25
SWEP.OnlyBurstFire                = false -- No auto, only burst/single?

SWEP.ViewModelPosition  = Vector(0, -4, 0)
SWEP.ViewModelAngle     = Vector(0, 0, 0)

SWEP.IronSightsPos      = Vector(-3.8,-20,-3)
SWEP.IronSightsAng      = Vector(0,0,0)

SWEP.SafetyPos          = Vector(0,0,-2)
SWEP.SafetyAng          = Vector(-10, -15, 25)

--HoldType Handling.
SWEP.HoldtypeHolstered = "passive"
SWEP.HoldtypeActive = "ar2"
SWEP.HoldtypeSights = "ar2"
SWEP.HoldtypeSprintShoot = "shotgun"
SWEP.HoldtypeNPC = nil

SWEP.Bullet = {
    Damage = 150, --first value is damage at 0 meters from impact, second value is damage at furthest point in effective range
    DropOffStartRange = 20, --in meters, damage will start dropping off after this range
    EffectiveRange = 65, --in meters, damage scales within this distance
    Range = 180, --in meters, after this distance the bullet stops existing
    Tracer = true, --show tracer
    TracerName = "rev_halo_ar_bullet",
    NumBullets = 1, --the amount of bullets to fire
    PhysicsMultiplier = 1, --damage is multiplied by this amount when pushing objects
}

SWEP.Recoil = {
    Vertical = {0, 0.3}, --random value between the 2
    Horizontal = {0, 0}, --random value between the 2
    Shake = 1, --camera shake
    AdsMultiplier = 0.0001, --multiply the values by this amount while aiming
    Seed = 10922 --give this a random number until you like the current recoil pattern
}

SWEP.Cone = {
    Hip = 0.2, --accuracy while hip
    Ads = 0.003, --accuracy while aiming
    Increase = 0.001, --increase cone size by this amount every time we shoot
    AdsMultiplier = 0.0001, --multiply the increase value by this amount while aiming
    Max = 1, --the cone size will not go beyond this size
    Decrease = 0.8, -- amount (in seconds) for the cone to completely reset (from max)
    Seed = 9523 --just give this a random number
}

SWEP.IronSightTime = 0.05
--Scopes
SWEP.Scoped = true  --Draw a scope overlay?
SWEP.ScopeOverlayThreshold = 0.875

SWEP.Scope = {
    --Magnification = 0.75,
    ScopeMagnification = 0.75,
    ScopeMagnificationMax = 0.75,
    ScopeMagnificationMin = 0.2,
    ScopeTexture = "chaosnarwhal/halo/HUD/scope_rifle.png",
    Q2Mat = nil,
    Q3Mat = nil,
    Q4Mat = nil,
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
    FovMultiplier = 1,
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
SWEP.Primary.ClipSize		= 32			-- Size of a clip
SWEP.Primary.DefaultClip	= 32		-- Default number of bullets in a clip
SWEP.Primary.Automatic		= true		-- Automatic/Semi Auto
SWEP.Primary.Ammo			= "Pistol"

SWEP.Animations = {
    ["idle"] = {
        Source = "idle",
    },
    ["draw"] = {
        Source = "deploy",
    },
    ["reload"] = {
        Source = "reload",
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_SMG1
    },
    ["fire"] = {
        Source = "fire",
        TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2
    },
}

SWEP.Firemodes = {
    [1] = {
        Name = "Burst Fire",
        OnSet = function(self)
            return "Firemode_Burst"
        end
    },
}

function SWEP:ChaosDrawCustom2DScopeElements()
    local w = ScrW()
    local h = ScrH()
    
    local ratio = w/h

    local scopetable = self.Scope
    
    local ss = 4 * scopetable.ScopeScale
    local sw = scopetable.ScopeWidth
    local sh = scopetable.ScopeHeight
    
    local wi = w / 10 * ss
    local hi = h / 10 * ss
    
    surface.SetDrawColor(Color(0, 0, 0, 255))
    surface.SetMaterial(Material("chaosnarwhal/halo/HUD/scope_elements/br_e1"))
    surface.DrawTexturedRectUV( wi * 1.4, h/2 * 1.1, hi * sw, hi / 2, 0, 0, 1, 1 )
    
    surface.SetMaterial(Material("chaosnarwhal/halo/HUD/scope_elements/br_e2"))
    surface.DrawTexturedRectUV( w/2 - hi / 2 * 1.65, h/2 - (hi / 2 * 0.2), hi * sw, hi / 2 * 0.4, 0, 0, 1, 1 )
    surface.DrawTexturedRectUV( w/2 - hi / 6, h/2 - (hi / 2 * 0.2), hi * sw, hi / 2 * 0.4, 1, 0, 0, 1 )
    
    surface.SetMaterial(Material("chaosnarwhal/halo/HUD/scope_elements/br_e3"))
    surface.DrawTexturedRectUV( w/2 - hi / 16, hi * 1.775, wi / 14, hi, 0, 1, 1, 0 )
    surface.DrawTexturedRectUV( w/2 - hi / 17, hi * 1.1, wi / 14, hi, 1, 0, 0, 1 )
end