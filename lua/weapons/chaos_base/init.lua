--[[ AddCSLua our other essential functions. ]]--

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

--[[ Load up our shared code. ]]--

include('shared.lua')

--[[ Include these modules]]--

for k,v in pairs(SWEP.SV_MODULES) do
    include(v)
end

--[[ Include these modules, and AddCSLua them, since they're shared.]]--

for k,v in pairs(SWEP.SH_MODULES) do
    AddCSLuaFile(v)
    include(v)
end

--[[ Include these modules if singleplayer, and AddCSLua them, since they're clientside.]]--

for k,v in pairs(SWEP.CLSIDE_MODULES) do
    AddCSLuaFile(v)
end
if game.SinglePlayer() then
    for k,v in pairs(SWEP.CLSIDE_MODULES) do
        include(v)
    end
end


util.AddNetworkString("chaosbase_clienthitreg")

net.Receive("chaosbase_clienthitreg", function(len, ply)
    if not IsValid(ply:GetActiveWeapon()) or not weapons.IsBasedOn(ply:GetActiveWeapon():GetClass(), "chaos_base") then return end
    if ply:GetActiveWeapon().Projectile ~= nil then return end
    local ent = net.ReadEntity()
    local hb = net.ReadInt(8)

    if IsValid(ent) or ent:IsWorld() then
        local hitpos = nil
        local hbSet = ent:GetHitboxSet()

        if ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() then
            local bone = ent:GetHitBoxBone(hb, hbSet)

            if bone ~= nil then
                local matrix = ent:GetBoneMatrix(bone)
                hitpos = matrix:GetTranslation()
                --hitpos = hitpos + matrix:GetAngles():Forward() * (ent:BoneLength(bone + 1) * 0.5)
            end
        end

        local w = ply:GetActiveWeapon()
        SuppressHostEvents(ply)
        local cone = w:GetCone()
        w:SetCone(Lerp(w:GetAimDelta(), w.Cone.Hip, w.Cone.Ads))
        w:ShootBullets(hitpos)
        w:SetCone(cone)
    end
end)