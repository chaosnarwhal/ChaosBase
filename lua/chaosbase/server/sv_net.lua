util.AddNetworkString("chaosbase_networktpanim")
util.AddNetworkString("chaosbase_firemode")
util.AddNetworkString("chaosbase_sendconvar")

util.AddNetworkString("chaosbase_anim")
util.AddNetworkString("chaosbase_tpanim")

if SERVER then
	net.Receive("ChaosBase_muzzle_mp", function(length, ply)
		local wep = net.ReadEntity()

		if IsValid(wep) and wep.ShootEffectsCustom then
			wep:ShootEffectsCustom(true)
		end
	end)
end