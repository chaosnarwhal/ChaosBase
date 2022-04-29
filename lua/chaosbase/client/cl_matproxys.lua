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

matproxy.Add( {
    name = "chaos_Compass",
    init = function( self, mat, values )
        self.ResultTo = values.resultvar
        self.SnapDegree = mat:GetFloat("$compassSnap")
    end,

    bind = function( self, mat, ent )
        if ( !IsValid( ent )) then return end
        local owner = ent:GetOwner()
        if ( !IsValid( owner ) or !owner:IsPlayer() ) then return end
        local ang = owner:EyeAngles()
        
        if self.SnapDegree == nil then self.SnapDegree = 0.01 end
        local antistupidity = math.Clamp(self.SnapDegree, 0.01, 360)
        
        local angmath = ang:SnapTo("y", antistupidity)

        mat:SetVector( self.ResultTo, Vector(-angmath.y, 0, 0) )
    end
} )

--[[
Hook: Tick
Function: Inspection mouse support
Used For: Enables and disables screen clicker
]]
--
if CLIENT then
    local st_old, host_ts, cheats, vec, ang
    host_ts = GetConVar("host_timescale")
    cheats = GetConVar("sv_cheats")
    vec = Vector()
    ang = Angle()

    local IsGameUIVisible = gui and gui.IsGameUIVisible

    hook.Add("Think", "ChaosPlayerThinkCL", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        local weapon = ply:GetActiveWeapon()

        if IsValid(weapon) and weapon.ChaosBase then
            if weapon.ChaosPlayerThinkCL then
                weapon:ChaosPlayerThinkCL(ply)
            end
        end
    end)

    --PreDrawViewModel

    hook.Add("PreDrawViewModel", "ChaosBasePreDrawViewModel", function(vm, plyv, wepv)
        if not IsValid(wepv) or not wepv.ChaosBase then return end

        local st = SysTime()
        st_old = st_old or st

        local delta = st - st_old
        st_old = st

        if sp and IsGameUIVisible and IsGameUIVisible() then return end

        delta = delta
        
        wepv:CalculateViewModelOffset(delta)
        wepv:CalculateViewModelFlip()

    end)
    
end