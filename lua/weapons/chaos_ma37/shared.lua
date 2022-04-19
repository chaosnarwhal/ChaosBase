AddCSLuaFile()

SWEP.Base 					= "chaos_base"

SWEP.PrintName				= "MA37 TEST GUN." -- 'Nice' Weapon name (Shown on HUD)
SWEP.Author					= "ChaosNarwhal"
SWEP.Contact				= ""
SWEP.Purpose				= "Testing"
SWEP.Instructions			= "Testing weapon. For Testing purposes"
SWEP.Category 				= "Revival Armory Revived."

SWEP.Spawnable				= true
SWEP.AdminOnly				= false

SWEP.ViewModelFOV			= 65
SWEP.ViewModelFlip			= false

SWEP.ViewModel              = "models/chaosnarwhal/halo/weapons/unsc/ma37/v_unsc_ma37_v2.mdl"
SWEP.WorldModel				= "models/chaosnarwhal/halo/weapons/unsc/ma37/w_unsc_ma37.mdl"
SWEP.UseHands				= true
SWEP.HoldType 				= "ar2"
SWEP.MuzzleAttachment       = "muzzle"       -- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.Tracer                 = 2
SWEP.TracerName             = "rev_halo_ar_bullet" --Change to a string of your tracer name
 
SWEP.Primary.ShootSound          = Sound("chaosnarwhal/weapons/unsc/ma37/gunfire/rifle_fire_"..math.random(1,3)..".wav")
SWEP.Primary.DistantShootSound   = Sound("drc.ma5c_fire_dist")
SWEP.Primary.RPM          	     = 550

SWEP.ViewModelPosition  = Vector(0, 0, 0)
SWEP.ViewModelAngle     = Vector(0, 0, 0)

SWEP.IronSightsPos      = Vector(-3.8,0,-2)
SWEP.IronSightsAng      = Vector(0,0,0)

SWEP.SafetyPos          = Vector(0,0,-2)
SWEP.SafetyAng          = Vector(-10, -15, 25)

--HoldType Handling.
SWEP.HoldtypeHolstered = "passive"
SWEP.HoldtypeActive = "ar2"
SWEP.HoldtypeSights = "rpg"
SWEP.HoldtypeSprintShoot = "ar2"
SWEP.HoldtypeNPC = nil

SWEP.IronSightsEnable   = true


SWEP.HighTierAllow = true

SWEP.HighTier = {
    ["Xerxes"] = {
        Type = "SPARTAN",
        RecoilReduce = 0.1,
        SprintShoot = true
    },
    ["Nexus"] = {
        Type = "SPARTAN",
        RecoilReduce = 0.1,
        SprintShoot = true
    },
    ["Warden"] = {
        Type = "SPARTAN",
        RecoilReduce = 0.1,
        SprintShoot = true
    },
    ["ONI Spartan"] = {
        Type = "SPARTAN",
        RecoilReduce = 0.1,
        SprintShoot = true
    },
    ["Bullfrogs"] = {
        Type = "ODST",
        RecoilReduce = 1,
        SprintShoot = true

    }
    --["Freelancer"] = "ODST"
}

--Custom Muzzle Flashes to Code in.
SWEP.ParticleEffects = {
    ["MuzzleFlash"] = "AC_muzzle_pistol",
}

SWEP.Bullet = {
    Damage = 65, --first value is damage at 0 meters from impact, second value is damage at furthest point in effective range
    HullSize = 3,
    DropOffStartRange = 20, --in meters, damage will start dropping off after this range
    EffectiveRange = 65, --in meters, damage scales within this distance
    Range = 180, --in meters, after this distance the bullet stops existing
    Tracer = true, --show tracer
    TracerName = "rev_halo_ar_bullet",
    NumBullets = 1, --the amount of bullets to fire
    PhysicsMultiplier = 1, --damage is multiplied by this amount when pushing objects
}

SWEP.Recoil = {
    Vertical = {0.5, 1}, --random value between the 2
    Horizontal = {-0.3, 0.3}, --random value between the 2
    Shake = 1.1, --camera shake
    AdsMultiplier = 0.2, --multiply the values by this amount while aiming
    Seed = 10922 --give this a random number until you like the current recoil pattern
}

SWEP.Cone = {
    Hip = 0.08, --accuracy while hip
    Ads = 0.01, --accuracy while aiming
    Increase = 0.04, --increase cone size by this amount every time we shoot
    AdsMultiplier = 0.0001, --multiply the increase value by this amount while aiming
    Max = 1, --the cone size will not go beyond this size
    Decrease = 0.8, -- amount (in seconds) for the cone to completely reset (from max)
    Seed = 9523 --just give this a random number
}

SWEP.IronSightTime = 0.1

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

SWEP.ViewModelOffsets = {
    RecoilMultiplier = 1.15,
    KickMultiplier = 2,
    AimKickMultiplier = 0.15
}

--Primary Fire
SWEP.Primary.ClipSize		= 32			-- Size of a clip
SWEP.Primary.DefaultClip	= 32		-- Default number of bullets in a clip
SWEP.Primary.Automatic		= true		-- Automatic/Semi Auto
SWEP.Primary.Ammo			= "Pistol"

SWEP.AnimatedSprint = true

SWEP.Animations = {
    ["idle"] = {
        Source = "idle",
    },
     ["idle_sprint"] = {
        Source = "sprint",
    },
    ["draw"] = {
        Source = "draw",
    },
    ["ready"] = {
        Source = "draw_initial",
    },
    ["reload_empty"] = {
        Source = "reload_empty",
    },
    ["reload"] = {
        Source = "reload",
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_SMG1
    },
    ["fire"] = {
        Source = {"fire_rand1","fire_rand2","fire_rand3"},
        TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2
    },
    ["idle_walk"] = {
        Source = "walk",
    },
}

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


SWEP.VElements = {
	["ammo_counterV"] = { type = "Quad", bone = "b_gun", rel = "", pos = Vector(5.393, 0, 7.596), angle = Angle(180, 90, -116), size = 0.005, draw_func = nil}
}

SWEP.WElements = {
    ["ammo_counterW"] = { type = "Quad", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(6.76, 1.25, -6.7), angle = Angle(0, 90, -100.362), size = 0.005, draw_func = nil}
}

--Draw the ammo counter
function SWEP:ChaosCustomInitialize()
    if CLIENT then
        self.VElements["ammo_counterV"].draw_func = function( weapon )
            if self:Clip1() < 10 then
                draw.SimpleTextOutlined("0".. self:Clip1() .."", "reach_ammocounter", 0, 12.5, Color(37,141,170,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(16, 60, 80))
            else
                draw.SimpleTextOutlined(self:Clip1(), "reach_ammocounter", 0, 12.5, Color(37,141,170,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(16, 60, 80))
            end
        end
    
        self.WElements["ammo_counterW"].draw_func = function( weapon )
            if self:Clip1() < 10 then
                draw.SimpleTextOutlined("0".. self:Clip1() .."", "reach_ammocounter", 0, 12.5, Color(37,141,170,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color(16, 60, 80))
            else
                draw.SimpleTextOutlined(self:Clip1(), "reach_ammocounter", 0, 12.5, Color(37,141,170,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color(16, 60, 80))
            end
        end
    end
end


function SWEP:DrawHUD()
    if not self:IsFirstPerson() then return end
    self:Crosshair()
end

function SWEP:DrawCrosshairSticks(x, y)
    local aimDelta = 1 - self:GetAimDelta()

    surface.SetAlphaMultiplier(aimDelta)

    local crosshairAlpha = 200

    --dot
    local c = self:GetCone()
    local m = self.Cone.Max
    local h = self.Cone.Hip
    local dotDelta = (c - h) / (m - h) 
    if (m - h <= 0) then
        dotDelta = 0
    end

    local color = Color(255,255,255)
    surface.SetDrawColor(color.r, color.g, color.b, 200)

    surface.SetAlphaMultiplier(aimDelta * (1 - dotDelta))
    surface.DrawRect(x - 1, y - 1, 2, 2)
    surface.SetAlphaMultiplier(aimDelta)

    local cone = self:GetCone() * 100
        
    --right stick
    surface.DrawRect(x + cone + 3, y - 1, 10, 2)
        
    --left stick
    surface.DrawRect(x - cone - 9 - 3, y - 1, 10, 2)

    --down stick
    surface.DrawRect(x - 1, y + cone + 3, 2, 10)
        
    if (self.Primary.Automatic) then
        --up stick
        surface.DrawRect(x - 1, y - cone - 9 - 3, 2, 10)
    end

    surface.SetAlphaMultiplier(1)
    surface.SetDrawColor(255, 255, 255, 255)
end

function SWEP:Crosshair()
    if (self._eyeang == nil) then
        return
    end
    
    local x, y = ScrW() * 0.5, ScrH() * 0.5
    local pos = (EyePos() + self._eyeang:Forward() * 10):ToScreen()

    if (Vector(x, 0, y):Distance(Vector(pos.x, 0, pos.y)) > 1.5) then
        x,y = math.floor(pos.x), math.floor(pos.y)
    end

    self:DrawCrosshairSticks(x, y)
end
