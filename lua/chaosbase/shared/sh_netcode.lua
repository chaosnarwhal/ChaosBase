if SERVER then
	util.AddNetworkString("ChaosBase_muzzle_mp")
	util.AddNetworkString("ChaosBase_TracerSP")
else
	--Receive muzzleflashes on client
	net.Receive("ChaosBase_muzzle_mp", function(length, ply)
		local wep = net.ReadEntity()

		if IsValid(wep) and wep.ShootEffectsCustom and IsVaid(wep.c_WorldModel) then
			wep:ShootEffectsCustom(true)
		end
	end)
end