AddCSLuaFile()
   
--[[ Load up our shared code. ]]--

include('shared.lua')

SWEP.SwayScale			= 0					-- The scale of the viewmodel sway
SWEP.BobScale			= 0					-- The scale of the viewmodel bob

--[[ Include these modules, because they're clientside.]]--

if CLIENT then
	for k,v in pairs(SWEP.CLSIDE_MODULES) do
		include(v)
	end
end

--[[ Include these modules, because they're shared.]]--

if CLIENT then
	for k,v in pairs(SWEP.SH_MODULES) do
		include(v)
	end
end