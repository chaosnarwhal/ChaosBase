AddCSLuaFile()

SWEP.Base 					= "rev_base"

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

SWEP.ViewModel 				= "models/chaosnarwhal/halo/weapons/unsc/ma37/v_unsc_ma37.mdl"
SWEP.WorldModel				= "models/chaosnarwhal/halo/weapons/unsc/ma37/w_unsc_ma37.mdl"
SWEP.UseHands				= true
SWEP.HoldType 				= "ar2"
SWEP.IronSightsPos  = Vector(9.49, 10.5, -12.371)
SWEP.IronSightsAng  = Vector(12, 65, -22.19)

SWEP.Primary.Sound          = Sound("chaosnarwhal/weapons/unsc/ma37/gunfire/rifle_fire_"..math.random(1,3)..".wav")
SWEP.Primary.Recoil         = 0
SWEP.Primary.Damage         = 20
SWEP.Primary.NumShots       = 1
SWEP.Primary.RPM          	= 600

SWEP.Primary.Spread         = 1
SWEP.Primary.SpreadDiv      = 40
SWEP.Primary.Kick           = 1

SWEP.AllowSprintShoot		= false

--Primary Fire
SWEP.Primary.ClipSize		= 32			-- Size of a clip
SWEP.Primary.DefaultClip	= 256		-- Default number of bullets in a clip
SWEP.Primary.Automatic		= true		-- Automatic/Semi Auto
SWEP.Primary.Ammo			= "Pistol"

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