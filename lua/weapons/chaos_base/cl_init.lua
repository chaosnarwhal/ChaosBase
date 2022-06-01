AddCSLuaFile()
   
--[[ Load up our shared code. ]]--

include('shared.lua')

SWEP.SwayScale			= 0					-- The scale of the viewmodel sway
SWEP.BobScale			= 0.1					-- The scale of the viewmodel bob

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

net.Receive("chaosbase_networktpanim", function()
        local ent = net.ReadEntity()
        local aseq = net.ReadInt(16)
        local starttime = net.ReadFloat()
        if ent ~= LocalPlayer() then
            ent:AddVCDSequenceToGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD, aseq, starttime, true)
        end
end)