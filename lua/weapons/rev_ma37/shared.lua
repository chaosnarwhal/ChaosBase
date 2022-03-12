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

SWEP.ViewModelFOV			= 80
SWEP.ViewModelFlip			= false

SWEP.ViewModel 				= "models/chaosnarwhal/halo/weapons/unsc/ma37/v_unsc_ma37_v2.mdl"
SWEP.WorldModel				= "models/chaosnarwhal/halo/weapons/unsc/ma37/w_unsc_ma37.mdl"
SWEP.UseHands				= true
SWEP.HoldType 				= "ar2"
SWEP.MuzzleAttachment       = "muzzle"       -- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.Tracer                 = 2
SWEP.TracerName             = "rev_halo_ar_bullet" --Change to a string of your tracer name

--[[
SWEP.VMPos                  = Vector(4, 2, -2)
SWEP.VMAng                  = Vector(0, 0, 0)
]]--

SWEP.ViewModelPosition      = Vector(4,2,-2)
SWEP.ViewModelAngle         = Vector(0,0,0)

SWEP.IronSightsPos          = Vector(-7.6, 0, 0)
SWEP.IronSightsAng          = Vector(0, 0, 0)

SWEP.Secondary.IronFOV      = 60

SWEP.Primary.Sound          = Sound("chaosnarwhal/weapons/unsc/ma37/gunfire/rifle_fire_"..math.random(1,3)..".wav")
SWEP.Primary.Damage         = 20
SWEP.Primary.NumShots       = 1
SWEP.Primary.RPM          	= 550

SWEP.Primary.KickUp         = 0.1                 -- This is the maximum upwards recoil (rise)
SWEP.Primary.KickDown       = 0                 -- This is the maximum downwards recoil (skeet)
SWEP.Primary.KickHorizontal = 0 

SWEP.Primary.Spread         = 0.01                   --This is hip-fire acuracy.  Less is more (1 is horribly awful, .0001 is close to perfect)

SWEP.Primary.SpreadMultiplierMax = 5 --How far the spread can expand when you shoot.
SWEP.Primary.SpreadIncrement = 1/7.5 --What percentage of the modifier is added on, per shot.
SWEP.Primary.SpreadRecovery = 3 --How much the spread recovers, per second.


SWEP.AllowSprintShoot		= false

--Primary Fire
SWEP.Primary.ClipSize		= 32			-- Size of a clip
SWEP.Primary.DefaultClip	= 256		-- Default number of bullets in a clip
SWEP.Primary.Automatic		= true		-- Automatic/Semi Auto
SWEP.Primary.Ammo			= "Pistol"

SWEP.Animations = {
    ["idle"] = {
        Source = "idle",
        MinProgress = 0,
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
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
    },
    ["reload"] = {
        Source = "reload",
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
    },
    ["fire"] = {
        Source = {"fire_rand1","fire_rand2","fire_rand3"},
    },
    ["idle_walk"] = {
        Source = "walk",
        MinProgress = 0,
    },
}

SWEP.Firemodes = {
    {
        Mode = 2,
    },
    {
        Mode = 0
    }
}


SWEP.VElements = {
	["ammo_counterV"] = { type = "Quad", bone = "b_gun", rel = "", pos = Vector(5.393, 0, 7.596), angle = Angle(180, 90, -116), size = 0.005, draw_func = nil}
}

SWEP.WElements = {
    ["ammo_counterW"] = { type = "Quad", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(6.76, 1.25, -6.7), angle = Angle(0, 90, -100.362), size = 0.005, draw_func = nil}
}

DEFINE_BASECLASS(SWEP.Base) -- If you have multiple overriden functions, place this line only over the first one

--Draw the ammo counter
function SWEP:Initialize()
    BaseClass.Initialize( self )
    
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
