AddCSLuaFile()

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

--[[modules]]--

--ClientSideModules
AddCSLuaFile("modules/client/cl_calcview.lua")
AddCSLuaFile("modules/client/cl_calcviewmodelview.lua")

--Shared Modules
AddCSLuaFile("modules/shared/sh_functions.lua")
AddCSLuaFile("modules/shared/sh_primaryattack_behaviour.lua")
AddCSLuaFile("modules/shared/sh_think.lua")
AddCSLuaFile("modules/shared/sh_datatables.lua")