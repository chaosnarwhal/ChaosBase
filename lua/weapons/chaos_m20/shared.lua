AddCSLuaFile()

SWEP.Base 					= "chaos_base"

SWEP.PrintName				= "M20" -- 'Nice' Weapon name (Shown on HUD)
SWEP.Author					= "ChaosNarwhal"
SWEP.Contact				= ""
SWEP.Purpose				= "Testing"
SWEP.Instructions			= "Testing weapon. For Testing purposes"
SWEP.Category 				= "Revival Armory Revived."

SWEP.Spawnable				= true
SWEP.AdminOnly				= false

SWEP.ViewModelFOV			= 65
SWEP.ViewModelFlip			= false

SWEP.ViewModel              = "models/chaosnarwhal/halo/weapons/unsc/m20/v_unsc_m20.mdl"
SWEP.WorldModel				= "models/vuthakral/halo/weapons/w_m7s.mdl"
SWEP.UseHands				= true
SWEP.MuzzleAttachment       = "muzzle_flash"       -- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.Tracer                 = 2
SWEP.TracerName             = "rev_halo_ar_bullet" --Change to a string of your tracer name
 
local ShootSound            = Sound("chaos.m20_fire")
SWEP.Primary.Sound          = "chaos.m20_fire"
SWEP.Primary.RPM          	= 900

SWEP.ViewModelPosition  = Vector(0, 0, 0)
SWEP.ViewModelAngle     = Vector(0, 1, 0)

SWEP.IronSightsPos      = Vector(-2.15, -8, 0.75)
SWEP.IronSightsAng      = Vector(0, 0, -1)

SWEP.SafetyPos          = Vector(0,0,-2)
SWEP.SafetyAng          = Vector(-10, -15, 25)

SWEP.RunPos             = Vector(0, 0, 1)
SWEP.RunAng             = Vector(-10, -15, 25)

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
    HullSize = 1,
    DropOffStartRange = 20, --in meters, damage will start dropping off after this range
    EffectiveRange = 65, --in meters, damage scales within this distance
    Range = 180, --in meters, after this distance the bullet stops existing
    Tracer = true, --show tracer
    TracerName = "rev_halo_ar_bullet",
    NumBullets = 1, --the amount of bullets to fire
    PhysicsMultiplier = 1, --damage is multiplied by this amount when pushing objects
}

SWEP.Recoil = {
    Vertical = {-0.2, 0.5}, --random value between the 2
    Horizontal = {-0.1, 0.1}, --random value between the 2
    Shake = 1.1, --camera shake
    AdsMultiplier = 1, --multiply the values by this amount while aiming
    RecoilReducer = 0.3, --multiply base recoil by this value. aka 0.5 = %50 less recoil
    Seed = 5512 --give this a random number until you like the current recoil pattern
}

SWEP.Cone = {
    Hip = 0.2, --accuracy while hip
    Ads = 0.01, --accuracy while aiming
    Increase = 0.01, --increase cone size by this amount every time we shoot
    AdsMultiplier = 0.0001, --multiply the increase value by this amount while aiming
    Max = 0.75, --the cone size will not go beyond this size
    Decrease = 0.005, -- amount (in seconds) for the cone to completely reset (from max)
    Seed = 72018 --just give this a random number
}

SWEP.IronSightTime = 0.1

SWEP.Scope = {
    --Magnification = 0.75,
    ScopeMagnification = 0.70,
    ScopeMagnificationMax = 0.70,
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
    RecoilMultiplier = 1.5,
    KickMultiplier = 2,
    AimKickMultiplier = 0.15
}

--Primary Fire
SWEP.Primary.ClipSize		= 60			-- Size of a clip
SWEP.Primary.DefaultClip	= 60		-- Default number of bullets in a clip
SWEP.Primary.Automatic		= true		-- Automatic/Semi Auto
SWEP.Primary.Ammo			= "Pistol"

SWEP.AnimatedSprint = false

SWEP.Animations = {
    ["idle"] = {
        Source = "idle",
    },
    ["draw"] = {
        Source = "draw",
    },
    ["ready"] = {
        Source = "draw_initial",
    },
    ["reload"] = {
        Source = "reload",
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_SMG1
    },
    ["fire"] = {
        Source = {"fire_rand1","fire_rand2"},
        TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2
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

function SWEP:Think() -- We're overriding Think2 without touching the main think function, which is called from there anyway
    local ViewModel = self:GetOwner():GetViewModel()
    if CLIENT then
        if self:IsCarriedByLocalPlayer() == false then
            ViewModel:SetSubMaterial( 4, "" )
        end
    end
 
    local ammoString = tostring( self:Clip1() )
    local ammoOnes = string.Right( ammoString, 1 )
    local ammoTens = string.Left( ammoString, 1 )
   
    if self:Clip1() < 10 then
        ammoTens = "0"
    end

    ViewModel:SetBodygroup(10,tonumber(ammoTens))
    ViewModel:SetBodygroup(11,tonumber(ammoOnes))

    if CLIENT then
            local ViewModel = self:GetOwner():GetViewModel()          
            if(self:GetIsAiming()) then
                    ViewModel:SetBodygroup(9,0)
                    self.Weapon:EmitSound("chaos.m20.Zoom_In")
            elseif (!self:GetIsAiming()) then
                    ViewModel:SetBodygroup(9,1)
                    self.Weapon:EmitSound("chaos.m20.Zoom_Out")
            end
    end
        
end