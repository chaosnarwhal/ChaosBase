--ClassScaler
AddCSLuaFile()

ChaosBase.scalethesesteamidsextra = {
    ["76561198079227213"] = 1.34,
}

ChaosBase.scalethesewhitelist = {
    --Alien Scaling
    ["SoS Elite"] = 1.24,
    ["SoS Helios"] = 1.24,
    ["SoS High Command"] = 1.24,
    ["SoS Honor Guard"] = 1.24,
    ["SoS Low Command"] = 1.24,
    ["SoS Officer"] = 1.24,
    ["SoS Ranger"] = 1.24,
    ["SoS Senior Command"] = 1.24,
    ["SoS Spec-Ops"] = 1.24,
    ["SoS Arbiter"] = 1.24,
    ["Ascetic"] = 1.24,
    ["SoS Berserker"] = 1.3,
    ["SoS Bloodstars"] = 1.3,
    ["SoS Mgalekgolo"] = 1.27,
    ["SoS Grunt"] = 1.24,
    --Spartans
    ["Xerxes"] = 1.28,
    ["Spartan Command Staff"] = 1.28,
    ["Echo"] = 1.28,
    ["Invicta"] = 1.28,
    ["Nexus"] = 1.28,
    ["Nomad"] = 1.28,
    ["Eclipse"] = 1.28,
    ["Warden"] = 1.28,
    ["Praetor"] = 1.28,
    ["ONI Spartan"] = 1.28,
    ["AI"] = 0.25,
}

hook.Add("PlayerSpawn", "ScaleThatPlayer", function(ply)
    if not IsValid(ply) then return end
    --if not scalethesewhitelist[ply:getJobTable().category] then return end
    local key = ChaosBase.scalethesewhitelist[ply:getJobTable().name] or ChaosBase.scalethesewhitelist[ply:getJobTable().category]

    if ChaosBase.scalethesesteamidsextra[ply:SteamID64()] and (ChaosBase.scalethesewhitelist[ply:getJobTable().category] or ChaosBase.scalethesewhitelist[ply:getJobTable().name]) then
        key = ChaosBase.scalethesesteamidsextra[ply:SteamID64()]
    end

    if key then
        timer.Simple(1, function()
            ply:SetModelScale(ply:GetModelScale() * key, 1)
            ply:SetViewOffset(Vector(0, 0, 62 * key))
            ply:SetViewOffsetDucked(Vector(0, 0, 28 * key))
            ply:SetHull(Vector(-16, -16, 0), Vector(16, 16, 64))
            ply:ChatPrint("SCALED" .. key)
            ply:SetNW2Float("Chaos.PlayerScale", key)
        end)
    else
        ply:SetModelScale(1, 1)
        ply:SetViewOffset(Vector(0, 0, 64))
        ply:SetViewOffsetDucked(Vector(0, 0, 28))
        ply:ResetHull()
        ply:ChatPrint("SCALED BACK")
        ply:SetNW2Float("Chaos.PlayerScale", 1)
    end
end)