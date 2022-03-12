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

--[[
SWEP.VMPos                  = Vector(4, 2, -2)
SWEP.VMAng                  = Vector(0, 0, 0)
]]--

SWEP.ViewModelPosition      = Vector(4,2,-2)
SWEP.ViewModelAngle         = Vector(0,0,0)

SWEP.IronSightsPos          = Vector(-7.6, 0, 0)
SWEP.IronSightsAng          = Vector(0, 0, 0)

SWEP.Secondary.IronFOV      = 60

SWEP.Primary.Sound          = Sound("drc.m90_fire") 
SWEP.Primary.Damage         = 20
SWEP.Primary.NumShots       = 1
SWEP.Primary.RPM          	= 85

SWEP.IsShotgun              = true -- weapon receives shotgun ammo types
SWEP.ShotgunReload          = true -- reloads like shotgun instead of magazines

SWEP.Primary.KickUp         = 0.06                 -- This is the maximum upwards recoil (rise)
SWEP.Primary.KickDown       = 0                 -- This is the maximum downwards recoil (skeet)
SWEP.Primary.KickHorizontal = 0 

SWEP.Primary.Spread         = 0.05                   --This is hip-fire acuracy.  Less is more (1 is horribly awful, .0001 is close to perfect)

SWEP.Primary.SpreadMultiplierMax = 5 --How far the spread can expand when you shoot.
SWEP.Primary.SpreadIncrement = 1/7.5 --What percentage of the modifier is added on, per shot.
SWEP.Primary.SpreadRecovery = 3 --How much the spread recovers, per second.


SWEP.AllowSprintShoot		= false

--Primary Fire
SWEP.Primary.ClipSize		= 8			-- Size of a clip
SWEP.Primary.DefaultClip	= 256		-- Default number of bullets in a clip
SWEP.Primary.Automatic		= false		-- Automatic/Semi Auto
SWEP.Primary.Ammo			= "Pistol"


SWEP.Animations = {
    ["idle"] = {
        Source = "idle",
        Time = 99/30
    },
    ["draw"] = {
        Source = "draw",
        time = 18/30
    },
    ["fire"] = {
        Source = {"fire1","fire2","fire3"},
        time = 5/30
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

SWEP.Firemodes = {
    {
        Mode = 2,
    },
    {
        Mode = 0
    }
}