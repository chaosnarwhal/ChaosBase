--[[Define Modules]]--
SWEP.SV_MODULES = {
    
}
SWEP.SH_MODULES = {
    "modules/shared/sh_aim_behaviour.lua",
    "modules/shared/sh_anims.lua",
    "modules/shared/sh_bullet.lua",
    "modules/shared/sh_common.lua",
    "modules/shared/sh_deploy.lua",
    "modules/shared/sh_effects.lua",
    "modules/shared/sh_firemode_behaviour.lua",
    "modules/shared/sh_heat.lua",
    "modules/shared/sh_primaryattack_behaviour.lua",
    "modules/shared/sh_reload.lua",
    "modules/shared/sh_sprint.lua",
    "modules/shared/sh_think.lua"
}
SWEP.CLSIDE_MODULES = {
    "modules/client/cl_bob.lua",
    "modules/client/cl_calcview.lua",
    "modules/client/cl_calcviewmodelview.lua",
    "modules/client/cl_hud.lua",
    "modules/client/cl_sck.lua",
    "modules/client/cl_scopes.lua",
    "modules/client/cl_viewmodel_render.lua",
    "modules/client/cl_worldmodel_render.lua"
}

game.AddParticles("particles/ac_mw_handguns.pcf")

--START GUN CODE.
SWEP.Gun = "chaos_base"
SWEP.Base = "weapon_base"

--Some Defaults for later.
SWEP.ChaosBase = true
SWEP.BurstCount = 0
SWEP.AnimQueue = {}
SWEP.FiremodeIndex = 1
SWEP.UnReady = true

SWEP.RenderGroup = RENDERGROUP_TRANSLUCENT
SWEP.RenderMode = RENDERMODE_ENVIROMENTAL

--Flavor Text and The name/category of the weapon.
SWEP.PrintName = "Revival Weapons Base" -- 'Nice' Weapon name (Shown on HUD)
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Category = "Revival"
--WorldModels Defaults.
SWEP.WorldModel = "models/your/path/here.mdl" -- WorldModel Path
--ViewModel Defaults.
SWEP.ViewModel = "models/weapons/c_arms.mdl" -- Viewmodel path
SWEP.VModel    = ""
SWEP.ViewModelFOV = 65 -- This controls how big the viewmodel looks.  Less is more.
SWEP.ViewModelFlip = false -- Set this to true for CSS models, or false for everything else (with a righthanded viewmodel.)
SWEP.UseHands = false -- Use gmod c_arms system.

SWEP.MuzzleAttachment = "muzzle"
SWEP.MuzzleFlashEnabled = true
SWEP.MuzzleFlashEffect = nil
SWEP.CustomMuzzleFlash = true

SWEP.VMPos = Vector(0, 0, 0) -- The viewmodel positional offset, constantly.  Subtract this from any other modifications to viewmodel position.
SWEP.VMAng = Vector(0, 0, 0) -- The viewmodel angular offset, constantly.   Subtract this from any other modifications to viewmodel angle.
SWEP.VMPos_Additive = true -- Set to false for an easier time using VMPos. If true, VMPos will act as a constant delta ON TOP OF ironsights, run, whateverelse
SWEP.AdditiveViewModelPosition = true
SWEP.FovMultiplier = 0

SWEP.ShowWorldModel = true

SWEP.WorldModelOffset = {
    Pos = {
        Up = 0,
        Right = 0,
        Forward = 0
    },

    Ang = {
        Up = 0,
        Right = 0,
        Forward = 0
    },

    Scale = 1
}

--Scopes
SWEP.Scoped = false  --Draw a scope overlay?
SWEP.ScopeOverlayThreshold = 0.875

SWEP.Scope = {
    Magnification = 0,
    ScopeTexture = nil,
    Q2Mat = nil,
    Q3Mat = nil,
    Q4Mat = nil,
    ScopeColor = Color(0,0,0,255),
    ScopeBGColor = Color(0,0,0,200),
    ScopeYOffset = -1,
    ScopeScale = 1,
    ScopeWidth = 0,
    ScopeHeight = 0,
    SwitchToSound = "", -- sound that plays when switching to this sight
    SwitchFromSound = "",
    ScrollFunc = ChaosBase.SCROLL_NONE,
    CrosshairInSights = false,
}

--Passed to CalcView
SWEP.Zoom = {
    FovMultiplier = 0.85,
    ViewModelFovMultiplier = 0.9,
    Blur = {
        EyeFocusDistance = 7
    }
}

-- The viewmodel positional offset, constantly.
SWEP.ViewModelPosition = Vector(0, 0, 0)
SWEP.ViewModelAngle = Vector(0, 0, 0)

SWEP.IronSightsPos = Vector(0, 0, 0)
SWEP.IronSightsAng = Vector(0, 0, 0)

SWEP.SafetyPos = Vector(0, 0, -2)
SWEP.SafetyAng = Vector(-10, -15, 25)

SWEP.RunPos = Vector(0, 0, -2)
SWEP.RunAng = Vector(-10, -15, 25)

SWEP.IronSightsEnable = true

--HoldType Handling.
SWEP.HoldtypeHolstered = "passive"
SWEP.HoldtypeActive = "shotgun"
SWEP.HoldtypeSights = "smg"
SWEP.HoldtypeCustomize = "slam"
SWEP.HoldtypeSprintShoot = nil
SWEP.HoldtypeNPC = nil

SWEP.SprintBobMult = 1.1 -- More is more bobbing, proportionally.  This is multiplication, not addition.  You want to make this > 1 probably for sprinting.
SWEP.IronBobMult = 0 -- More is more bobbing, proportionally.  This is multiplication, not addition.  You want to make this < 1 for sighting, 0 to outright disable.
SWEP.IronBobMultWalk = 0 -- More is more bobbing, proportionally.  This is multiplication, not addition.  You want to make this < 1 for sighting, 0 to outright disable.
SWEP.WalkBobMult = 3 -- More is more bobbing, proportionally.  This is multiplication, not addition.  You may want to disable it when using animated walk.
SWEP.SprintViewBobMult = 1
SWEP.BreathScale = 0.1

SWEP.ViewbobIntensity = 1

SWEP.ViewModelFlip = 0

SWEP.AnimatedSprint = false
SWEP.SprintStyle = nil
SWEP.SprintTime = 0.15

SWEP.HighTierAllow = false

SWEP.HighTier = {
    --["Xerxes"] = "SPARTAN"
    --["ODST"] = "ODST"
    --["Freelancer"] = "ODST"
}

--Spread weapon defaults
--SWEP.Primary.SpreadMultiplierMax = 2.5 --How far the spread can expand when you shoot.
--SWEP.Primary.SpreadIncrement = 1/3.5 --What percentage of the modifier is added on, per shot.
--SWEP.Primary.SpreadRecovery = 3 --How much the spread recovers, per second.
SWEP.Cone = {
    Hip = 0.57, --accuracy while hip
    Ads = 0.03, --accuracy while aiming
    Increase = 0.12, --increase cone size by this amount every time we shoot
    AdsMultiplier = 0.075, --multiply the increase value by this amount while aiming
    Max = 2.2, --the cone size will not go beyond this size
    Decrease = 0.8, -- amount (in seconds) for the cone to completely reset (from max)
    Seed = 95235 --just give this a random number 
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

--Weapon Sound Defaults
SWEP.Primary.Sound = Sound("")
SWEP.ShootVol = 125 -- volume of shoot sound
SWEP.ShootPitch = 100 -- pitch of shoot sound
SWEP.ShootPitchVariation = 0.1
--Standard weapon defaults.
SWEP.Primary.NumShots = 1 --The number of shots the gun/bow fires.  
SWEP.Primary.RPM = 600 -- This is in Rounds Per Minute / RPM
SWEP.ChamberSize = 1 -- how many rounds can be chambered.
SWEP.Primary.ClipSize = 0 -- This is the size of a clip
SWEP.Primary.DefaultClip = 0 -- This is the number of bullets the gun gives you, counting a clip as defined directly above.
SWEP.Primary.Automatic = true -- Automatic/Semi Auto
SWEP.Primary.Ammo = "none" -- What kind of ammo
SWEP.DrawTime = 1
SWEP.Primary.BurstRounds = 1
SWEP.Primary.BurstDelay = 1

SWEP.DryFireSound = Sound("Weapon_AR2.Empty2")

SWEP.ReloadTime = 1

-- this includes: igniting if type has DMG_BURN; adding DMG_AIRBOAT when hitting helicopter; adding DMG_BULLET to DMG_BUCKSHOT
SWEP.Bullet = {
    Damage = {50, 20}, --first value is damage at 0 meters from impact, second value is damage at furthest point in effective range
    DropOffStartRange = 20, --in meters, damage will start dropping off after this range
    EffectiveRange = 65, --in meters, damage scales within this distance
    Range = 180, --in meters, after this distance the bullet stops existing
    Tracer = false, --show tracer
    TracerName = nil,
    HullSize = 0,
    NumBullets = 1, --the amount of bullets to fire
    PhysicsMultiplier = 1, --damage is multiplied by this amount when pushing objects 
    DamageType = DMG_BULLET
}

SWEP.Projectile = nil

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

SWEP.Recoil = {
    Vertical = {1, 3.5}, --random value between the 2
    Horizontal = {-2, 2}, --random value between the 2
    Shake = 1.5, --camera shake
    AdsMultiplier = 0.25, --multiply the values by this amount while aiming
    Seed = 67498 --give this a random number until you like the current recoil pattern 
}

SWEP.CrosshairColor     = Color(127, 220, 255, 255)
SWEP.CrosshairNoIronFade = true

SWEP.Secondary.OwnerFOV = 70
-- AKA IronViewModelFOV
SWEP.Secondary.ViewModelFOV = 65 -- Defaults to 65. Target viewmodel FOV when aiming down the sights.
-- Time needed to enter / leave the ironsight in seconds
SWEP.IronSightTime = 0.1

-- If Jamming is enabled, a heat meter will gradually build up until it reaches HeatCapacity.
-- Once that happens, the gun will overheat, playing an animation. If HeatLockout is true, it cannot be fired until heat is 0 again.
SWEP.FixTime = 1
SWEP.BatteryBased = false
SWEP.Heat = false
SWEP.HeatCapacity = 200 -- rounds that can be fired non-stop before the gun jams, playing the "fix" animation
SWEP.HeatDissipation = 2 -- rounds' worth of heat lost per second
SWEP.HeatLockout = false -- overheating means you cannot fire until heat has been fully depleted
SWEP.HeatDelayTime = 0.5
SWEP.HeatFix = false -- when the "fix" animation is played, all heat is restored.
SWEP.HeatOverflow = nil -- if true, heat is allowed to exceed capacity (this only applies when the default overheat handling is overridden)
-- When using custom sprint animations, set this to the same as ActivePos and ActiveAng

--SCK KIT integration.
SWEP.VElements = {}
SWEP.WElements = {}

SWEP.Bodygroups = {}

SWEP.BlowbackEnabled        = false -- Enable Blowback?
SWEP.BlowbackVector         = Vector(0, -1, 0) -- Vector to move bone <or root> relative to bone <or view> orientation.
SWEP.BlowbackAngle          = nil -- Angle(0, 0, 0)
SWEP.BlowbackCurrentRoot    = 0 -- Amount of blowback currently, for root
SWEP.BlowbackCurrent        = 0 -- Amount of blowback currently, for bones
SWEP.BlowbackBoneMods       = nil -- Viewmodel bone mods via SWEP Creation Kit
SWEP.Blowback_Only_Iron     = true -- Only do blowback on ironsights
SWEP.Blowback_SlideLock    = false -- Do we recover from blowback when empty?
SWEP.Blowback_Shell_Enabled = true -- Shoot shells through blowback animations
SWEP.Blowback_Shell_Effect  = "ShellEject" -- Which shell effect to use
SWEP.BlowbackAllowAnimation = nil -- Allow playing shoot animation with blowback?
SWEP.BoltWorldModelBone = "nil"
SWEP.BoltViewModelBone = "nil"

SWEP.SparWepScale = 1.3

SWEP.WepScale = 1

SWEP.ShotgunReload = false

SWEP.MuzzleFlashParticle = nil

--Bipod Shit
SWEP.BipodDelay = 0
SWEP.BipodDeployTime = 0.25
SWEP.BipodUndeployTime = 0.25
SWEP.BipodAngleLimitYaw = 30
SWEP.BipodAngleLimitPitch = 10
SWEP.BipodSensitivity = {x = -0.3, z = -0.3, p = 0.1, r = 0.1}
SWEP.BipodInstalled = true 
SWEP.BipodDeployHeightRequirement = -1
SWEP.WeaponRestHeightRequirement = -0.6
SWEP.CanRestOnObjects = false

--BASE VALUES DONT TOUCH.
SWEP.IronSightsProgressUnpredicted = 0
SWEP.CLIronSightsProgress = 0
SWEP.BurstCount = 0
SWEP.SafetyProgressUnpredicted = 0
SWEP.SprintProgressUnpredicted = 0

function SWEP:SetupDataTables()
    self:NetworkVar("Int", 0, "NWState")
    self:NetworkVar("Int", 1, "FireMode")
    self:NetworkVar("Int", 2, "BurstRounds")
    self:NetworkVar("Int", 3, "LastLoad")
    self:NetworkVar("Int", 4, "NthReload")
    self:NetworkVar("Int", 5, "NthShot")
    --Am I using this? V
    self:NetworkVar("Int", 6, "AimMode")
    -- 2 = insert
    -- 3 = cancelling
    -- 4 = insert empty
    -- 5 = cancelling empty
    self:NetworkVar("Int", 7, "ShotgunReloading")
    self:NetworkVar("Int", 8, "MagUpCount")
    self:NetworkVar("Int", 9, "SprayRounds")
    self:NetworkVar("Int", 10, "Charge")

    self:NetworkVar("Int", 11, "DownButtons")
    self:NetworkVar("Int", 12, "LastPressedButtons")
    
    self:NetworkVar("Bool", 0, "HeatLocked")
    self:NetworkVar("Bool", 1, "NeedCycle")
    self:NetworkVar("Bool", 2, "ToggleAim")
    self:NetworkVar("Bool", 5, "IsReloading")
    self:NetworkVar("Bool", 6, "IsSprinting")
    self:NetworkVar("Bool", 7, "IsAiming")
    self:NetworkVar("Bool", 8, "IsHolstering")
    self:NetworkVar("Bool", 9, "IsPumping")
    self:NetworkVar("Bool", 11, "Safety")
    self:NetworkVar("Bool", 12, "ToggleSafety")
    self:NetworkVar("Bool", 13, "IsFiring")
    self:NetworkVar("Bool", 14, "IsCharging")
    self:NetworkVar("Bool", 15, "BipodDeployed")
    self:NetworkVar("Bool", 16, "CanSprintShoot")
    self:NetworkVar("Bool", 17, "IsHighTier")
    self:NetworkVar("Bool", 18, "FiredSplazor")

    self:NetworkVar("String", 1, "ClassType")

    self:NetworkVar("Float", 0, "Heat")
    self:NetworkVar("Float", 1, "ReloadingREAL")
    self:NetworkVar("Float", 2, "NextIdle")
    self:NetworkVar("Float", 3, "NextHolsterTime")
    self:NetworkVar("Float", 6, "WeaponOpDelay")
    self:NetworkVar("Float", 7, "MagUpIn")
    self:NetworkVar("Float", 8, "IronSightsRatio")
    self:NetworkVar("Float", 9, "NextFiremodeTime")
    self:NetworkVar("Float", 10, "AimDelta")
    self:NetworkVar("Float", 11, "Cone")
    self:NetworkVar("Float", 12, "BreathingDelta")
    self:NetworkVar("Float", 13, "SafetyDelta")
    self:NetworkVar("Float", 14, "NextInspectTime")
    self:NetworkVar("Float", 15, "RecoilReduce")
    self:NetworkVar("Float", 16, "LastReloadPressed")
    self:NetworkVar("Float", 17, "LastIronSightsPressed")

    self:NetworkVar("Entity", 0, "NextWeapon")
    self:NetworkVar("Angle", 0, "BreathingAngle")
end

function SWEP:LookupBoneCached(model, name)
    if model.cachedBones == nil then
        model.cachedBones = {}
    end

    if model.cachedBones[name] == nil then
        model.cachedBones[name] = model:LookupBone(name)
    end

    return model.cachedBones[name]

end

function SWEP:RecreateClientsideModels()
    if not IsValid(self.c_WorldModel) then
        self.c_WorldModel = ClientsideModel(self.WorldModel, self.RenderGroup)
        self.c_WorldModel:SetRenderMode(self.RenderMode)
        self.c_WorldModel.swep = self
    end
end

function SWEP:OnRestore()
    self:SetNthReload(0)
    self:SetNthShot(0)
    self:SetReloadingREAL(0)
    self:SetMagUpIn(0)
    self.UnReady = false
end

function SWEP:SetReloading(v)
    if isbool(v) then
        if v then
            self:SetReloadingREAL(math.huge)
        else
            self:SetReloadingREAL(-math.huge)
        end
    elseif isnumber(v) and v > self:GetReloadingREAL() then
        self:SetReloadingREAL(v)
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

    if not game.SinglePlayer() and CLIENT then
        self.State = v
    end
end

function SWEP:GetState(v)
    if not game.SinglePlayer() and CLIENT and self.State then return self.State end

    return self:GetNWState(v)
end

SWEP.CL_SightDelta = 0

function SWEP:SetSightDelta(d)
    if not game.SinglePlayer() and CLIENT then
        self.CL_SightDelta = d
    end

    self:SetNWSightDelta(d)
end

function SWEP:GetSightDelta()
    if not game.SinglePlayer() and CLIENT then return self.CL_SightDelta end

    return self:GetNWSightDelta()
end

SWEP.CL_SprintDelta = 0

function SWEP:SetSprintDelta(d)
    if not game.SinglePlayer() and CLIENT then
        self.CL_SprintDelta = d
    end

    self:SetNWSprintDelta(d)
end

function SWEP:GetSprintDelta()
    if not game.SinglePlayer() and CLIENT then return self.CL_SprintDelta end

    return self:GetNWSprintDelta()
end

SWEP.Animations = {}

SWEP.EventTable = {
    [1] = {} -- for every overlapping one, a new one is made -- checked to be removed afterwards, except 1
}

SWEP.AuthorizedUserEnable = false

SWEP.AuthorizedUser = {
    --["Category"] = true,
    --["JobName"] = true,
    --["STEAMID64"] = true,
}