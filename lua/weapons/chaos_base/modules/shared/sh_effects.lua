AddCSLuaFile()

local fx, sp = nil, game.SinglePlayer()

function SWEP:MuzzleFlashCustom(spv)
    local att = self:GetMuzzleAttachment()
    
    fx = EffectData()
    fx:SetOrigin(self:GetOwner():GetShootPos())
    fx:SetNormal(self:GetOwner():EyeAngles():Forward())
    fx:SetEntity(self)
    fx:SetAttachment(att)

    print(att)

    util.Effect((self.MuzzleFlashEffect or ""), fx, false, true)

end

function SWEP:ShootEffectsCustom(ifp)
    local owner = self:GetOwner()

    if not self.MuzzleFlashEnabled then return end
    if self:IsFirstPerson() then return end
    if not owner.GetShootPos then return end
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

    if (CLIENT and ifp and not sp) or (sp and SERVER) then
        self:UpdateMuzzleAttachment()
        self:MuzzleFlashCustom(sp)
    end
end

