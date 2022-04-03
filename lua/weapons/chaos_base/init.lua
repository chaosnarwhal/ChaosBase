AddCSLuaFile()
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
--Modules
--Shared Functions
AddCSLuaFile("modules/shared/sh_aim_behaviour.lua")
AddCSLuaFile("modules/shared/sh_anims.lua")
AddCSLuaFile("modules/shared/sh_bullet.lua")
AddCSLuaFile("modules/shared/sh_common.lua")
AddCSLuaFile("modules/shared/sh_deploy.lua")
AddCSLuaFile("modules/shared/sh_effects.lua")
AddCSLuaFile("modules/shared/sh_firemode_behaviour.lua")
AddCSLuaFile("modules/shared/sh_primaryattack_behaviour.lua")
AddCSLuaFile("modules/shared/sh_reload.lua")
AddCSLuaFile("modules/shared/sh_sprint.lua")
AddCSLuaFile("modules/shared/sh_think.lua")
--Clientside Functions.
AddCSLuaFile("modules/client/cl_calcview.lua")
AddCSLuaFile("modules/client/cl_calcviewmodelview.lua")
AddCSLuaFile("modules/client/cl_effects.lua")
AddCSLuaFile("modules/client/cl_hud.lua")
AddCSLuaFile("modules/client/cl_sck.lua")
AddCSLuaFile("modules/client/cl_scopes.lua")
AddCSLuaFile("modules/client/cl_viewmodel_render.lua")


include("shared.lua")
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