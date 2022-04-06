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