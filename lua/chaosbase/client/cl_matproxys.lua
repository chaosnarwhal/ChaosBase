AddCSLuaFile()
if SERVER then return end

matproxy.Add({
    name = "ChaosBaseEnvMapTint",
    init = function(self, mat, values)
        self.min = values.min
        self.max = values.max
        self.envMapCount = #ents.FindByClass("env_cubemap")
    end,
    bind = function(self, mat, ent)
        if not IsValid(ent) then return end

        if ent.m_ChaosBaseEnvMapTint == nil then
            ent.m_ChaosBaseEnvMapTint = 0
        end

        local c = render.GetLightColor(ent:GetPos())
        local luminance = (c.x * 0.2126) + (c.y * 0.7152) + (c.z * 0.0722)
        local targetLuminance = luminance
        ent.m_ChaosBaseEnvMapTint = Lerp(10 * FrameTime(), ent.m_ChaosBaseEnvMapTint, targetLuminance)
        local tint = c * Lerp(ent.m_ChaosBaseEnvMapTint, self.min, self.max)
        mat:SetVector("$envmaptint", self.envMapCount <= 0 and tint * 1.5 or tint)
        mat:SetTexture("$envmap", self.envMapCount <= 0 and "chaosnarwhal/halo/shared/envmap_fallback" or "env_cubemap")
    end
})

matproxy.Add({
    name = "chaos_Compass",
    init = function(self, mat, values)
        self.ResultTo = values.resultvar
        self.SnapDegree = mat:GetFloat("$compassSnap")
    end,
    bind = function(self, mat, ent)
        if not IsValid(ent) then return end
        local owner = ent:GetOwner()
        if not IsValid(owner) or not owner:IsPlayer() then return end
        local ang = owner:EyeAngles()

        if self.SnapDegree == nil then
            self.SnapDegree = 0.01
        end

        local antistupidity = math.Clamp(self.SnapDegree, 0.01, 360)
        local angmath = ang:SnapTo("y", antistupidity)
        mat:SetVector(self.ResultTo, Vector(-angmath.y, 0, 0))
    end
})

matproxy.Add({
    name = "chaos_ScollPitch",
    init = function(self, mat, values)
        self.ResultTo = values.resultvar
        self.LerpPower = mat:GetFloat("$pitch_ls")
    end,
    bind = function(self, mat, ent)
        if not IsValid(ent) then
            ent = LocalPlayer()
        end

        if ent:IsWeapon() and ent:GetOwner():EntIndex() ~= 0 then
            ent = ent:GetOwner()
        end

        if not self.LerpPower then
            self.LerpPower = 1
        end

        local ea = ent:EyeAngles()

        self.chaos_scrollpitchlerp = Lerp(RealFrameTime() * (self.LerpPower * 2.5), self.chaos_scrollpitchlerp or ea.x, ea.x)
        mat:SetVector(self.ResultTo, Vector(0, self.chaos_scrollpitchlerp / 3.33333333))
    end
})