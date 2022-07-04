AddCSLuaFile()
local sp = game.SinglePlayer()

function SWEP:MuzzleFlashCustom(spv)
    local att = self.c_WorldModel:LookupAttachment(self.MuzzleAttachment) or self:LookupAttachment(self.MuzzleAttachment) or nil


    if self.MuzzleFlashParticle and IsValid(self.c_WorldModel) then
        ParticleEffectAttach(self.MuzzleFlashParticle, PATTACH_POINT_FOLLOW, self.c_WorldModel, att)
    end
end

--[[
Function Name:  ShootEffectsCustom
Syntax: self:ShootEffectsCustom().
Returns:  Nothing.
Notes:  Calls the proper muzzleflash, muzzle smoke, muzzle light code.
Purpose:  FX
]]
--
function SWEP:ShootEffectsCustom(ifp)
    if not self.MuzzleFlashEnabled then return end
    if self:IsFirstPerson() and not self:VMIV() then return end
    --if not self:GetOwner().GetShootPos then return end
    ifp = ifp or IsFirstTimePredicted()

    if (SERVER and sp) or (SERVER and not sp) then
        net.Start("ChaosBase_muzzle_mp", true)
        net.WriteEntity(self)

        if sp or not self:GetOwner():IsPlayer() then
            net.SendPVS(self:GetPos())
        else
            net.SendOmit(self:GetOwner())
        end

        return
    end

    self:GetOwner():MuzzleFlash()

    if CLIENT and ifp and not self:IsFirstPerson() then
        self:MuzzleFlashCustom()
    end
end