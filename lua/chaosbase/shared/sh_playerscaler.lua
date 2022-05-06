--ClassScaler
AddCSLuaFile()

local scaletheseniggasextra = {
	["STEAM_0:1:59480742"] = {
		Scale = 1.4
	},
}

local scalethesewhitelist = {
	["Xerxes"] = true,
	["Spartan Command Staff"] = true,
	["Echo"] = true,
	["Invicta"] = true,
	["Nexus"] = true,
	["Nomad"] = true,
	["Eclipse"] = true,
	["Warden"] = true,
}

hook.Add("PlayerSpawn", "ScaleThatSpartan",function(ply)
	local value = 1.3

	if scaletheseniggasextra[ply:SteamID()] then
		value = scaletheseniggasextra[ply:SteamID()].Scale
	end

	if not IsValid(ply) then return end
	
	if not scalethesewhitelist[ply:getJobTable().category] then return end

	ply:SetNW2Float("Chaos.PlayerScale", 1)
	
	timer.Simple(1,function()
		if scalethesewhitelist[ply:getJobTable().category] then
			ply:SetModelScale(ply:GetModelScale() * value, 0.1)
			ply:SetViewOffset(Vector(0, 0, 62*value))
			ply:SetViewOffsetDucked(Vector(0, 0, 28*value))
			ply:SetHull(Vector(-16,-16,0),Vector(16,16,64))
			ply:ChatPrint("SCALED"..value)
			ply:SetNW2Float("Chaos.PlayerScale", value)
		elseif not scalethesewhitelist[ply:getJobTable().category] then
			ply:SetModelScale(1, 0.1)
			ply:SetViewOffset(Vector(0, 0, 64))
			ply:SetViewOffsetDucked(Vector(0, 0, 28))
			ply:ResetHull()
			ply:ChatPrint("SCALED BACK")
			ply:SetNW2Float("Chaos.PlayerScale", 1)
		end
	end)
end)