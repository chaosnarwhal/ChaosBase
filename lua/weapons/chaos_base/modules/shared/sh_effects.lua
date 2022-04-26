AddCSLuaFile()

--[[
local fx, sp = nil, game.SinglePlayer()

function SWEP:MuzzleFlashCustom(spv)
    local att = self:GetMuzzleAttachment()
    fx = EffectData()
    fx:SetOrigin(self:GetOwner():GetShootPos())
    fx:SetNormal(self:GetOwner():EyeAngles():Forward())
    fx:SetEntity(self)
    fx:SetAttachment(att)

    util.Effect((self.MuzzleFlashEffect or ""), fx)

end

function SWEP:ShootEffectsCustom(ifp)
    local owner = self:GetOwner()
    if self.DoMuzzleFlash ~= nil then
        self.MuzzleFlashEnable = self.DoMuzzleFlash
        self.DoMuzzleFlash = nil
    end

    if not self.MuzzleFlashEnabled then return end

    if self:IsFirstPerson() and not self:VMIV() then return end
    if not owner.GetShootPos then return end
    ifp = IsFirstTimePredicted()

    if (SERVER and sp and self.ParticleMuzzleFlash) or (SERVER and not sp) then
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
]]
function SWEP:DoParticle(particleName, attName)
    local vm = self:GetOwner():GetViewModel()
    local wm = self:GetWeaponWorldModel()

    if self.ParticleEffects ~= nil and self.ParticleEffects[particleName] ~= nil then
        particleName = self.ParticleEffects[particleName]
    end

    if self:GetOwner():GetInfoNum("chaosbase_fx_cheap_particles", 0) > 0 and self.Particles[particleName] ~= nil then
        self.Particles[particleName]:StopEmissionAndDestroyImmediately()
        self.Particles[particleName] = nil
    end

    if IsValid(self:GetOwner()) then
        if vm:LookupAttachment(attName) <= 0 then return end
        local ent, attid = self:FindAttachmentInChildren(vm, attName)
        local effect = CreateParticleSystem(ent, particleName, PATTACH_POINT_FOLLOW, attid)
        effect:StartEmission()
        effect:SetIsViewModelEffect(true)
        effect:SetShouldDraw(false)

        if self:GetOwner():GetInfoNum("chaosbase_fx_cheap_particles", 0) > 0 then
            self.Particles[particleName] = effect
        else
            self.Particles[#self.Particles + 1] = effect
        end
    end

    if self:GetOwner():ShouldDrawLocalPlayer() or not self:IsCarriedByLocalPlayer() then
        if wm:LookupAttachment(attName) <= 0 then return end
        ParticleEffectAttach(particleName, PATTACH_POINT_FOLLOW, wm, wm:LookupAttachment(attName))
    end
end