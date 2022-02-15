AddCSLuaFile()

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

--[[modules]]--

--ClientSideModules
AddCSLuaFile("modules/client/cl_calcview.lua")
AddCSLuaFile("modules/client/cl_calcviewmodelview.lua")
AddCSLuaFile("modules/client/cl_effects.lua")
AddCSLuaFile("modules/client/cl_sck.lua")


--Shared Modules
AddCSLuaFile("modules/shared/sh_anims.lua")
AddCSLuaFile("modules/shared/sh_bobcode.lua")
AddCSLuaFile("modules/shared/sh_bullet.lua")
AddCSLuaFile("modules/shared/sh_datatables.lua")
AddCSLuaFile("modules/shared/sh_effects.lua")
AddCSLuaFile("modules/shared/sh_firemode_behaviour.lua")
AddCSLuaFile("modules/shared/sh_functions.lua")
AddCSLuaFile("modules/shared/sh_ironsights_behaviour.lua")
AddCSLuaFile("modules/shared/sh_primaryattack_behaviour.lua")
AddCSLuaFile("modules/shared/sh_think.lua")

SWEP.Weight					= 60		// Decides whether we should switch from/to this
SWEP.AutoSwitchTo			= true		// Auto switch to 
SWEP.AutoSwitchFrom			= true		// Auto switch from