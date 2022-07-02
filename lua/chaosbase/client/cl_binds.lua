ChaosBase.KEY_FIREMODE        = "+use"
ChaosBase.KEY_FIREMODE_ALT    = "chaosbase_firemode"
ChaosBase.KEY_ZOOMIN          = "invnext"
ChaosBase.KEY_ZOOMIN_ALT      = "chaosbase_zoom_in"
ChaosBase.KEY_ZOOMOUT         = "invprev"
ChaosBase.KEY_ZOOMOUT_ALT     = "chaosbase_zoom_out"
ChaosBase.KEY_SWITCHSCOPE     = "+zoom"
ChaosBase.KEY_SWITCHSCOPE_ALT = "chaosbase_switch_scope"
ChaosBase.KEY_MELEE           = "chaosbase_melee"

ChaosBase.BindToEffect = {
    [ChaosBase.KEY_FIREMODE]    = "firemode",
    [ChaosBase.KEY_ZOOMIN]      = "zoomin",
    [ChaosBase.KEY_ZOOMOUT]     = "zoomout",
    [ChaosBase.KEY_SWITCHSCOPE] = "switchscope_dtap",
}

ChaosBase.BindToEffect_Unique = {
    [ChaosBase.KEY_SWITCHSCOPE_ALT] = "switchscope",
    [ChaosBase.KEY_FIREMODE_ALT]    = "firemode",
    [ChaosBase.KEY_ZOOMIN_ALT]      = "zoomin",
    [ChaosBase.KEY_ZOOMOUT_ALT]     = "zoomout",
    [ChaosBase.KEY_MELEE]           = "melee",
}

local lastpressZ = 0
local lastpressE = 0

function ChaosBase:GetBind(bind)
    local button = input.LookupBinding(bind)

    return button == "no value" and bind .. " unbound" or button
end

local function SendNet(string, bool)
    net.Start(string)
    if bool != nil then net.WriteBool(bool) end
    net.SendToServer()
end

local function ChaosBase_TranslateBindToEffect(bind)
    local alt = GetConVar("chaosbase_altbindsonly"):GetBool()
    if alt then
        return ChaosBase.BindToEffect_Unique[bind], true
    else
        return ChaosBase.BindToEffect_Unique[bind] or ChaosBase.BindToEffect[bind] or bind, ChaosBase.BindToEffect_Unique[bind] != nil
    end
end

local function ChaosBase_PlayerBindPress(ply, bind, pressed)
	if not (ply:IsValid() and pressed) then return end

	local wep = ply:GetActiveWeapon()

	if not wep.ChaosBase then return end

	local block = false

	local alt

    bind, alt = ChaosBase_TranslateBindToEffect(bind)

    if wep:GetIsAiming() then
        if bind == "zoomin" then
            wep:Scroll(-1)
            block = true
        elseif bind == "zoomout" then
            wep:Scroll(1)
            block = true
        end
    end

    if block then return true end

end

local function ChaosCreateMove(move)
    ply = LocalPlayer()
    wep = ply:GetActiveWeapon()

    if IsValid(wep) and wep.ChaosBase then
        local ft = FrameTime()
        local ct = CurTime()

        if wep:GetBipodDeployed() and wep.DeployAngle then
            ang = move:GetViewAngles()

            local EA = ply:EyeAngles()
            dif = math.AngleDifference(EA.y, wep.DeployAngle.y)

            if dif >= wep.BipodAngleLimitYaw then
                ang.y = wep.DeployAngle.y + wep.BipodAngleLimitYaw
            elseif dif <= -wep.BipodAngleLimitYaw then
                ang.y = wep.DeployAngle.y - wep.BipodAngleLimitYaw
            end

            dif = math.AngleDifference(EA.p, wep.DeployAngle.p)

            if dif >= wep.BipodAngleLimitPitch then
                ang.p = wep.DeployAngle.p + wep.BipodAngleLimitPitch
            elseif dif <= -wep.BipodAngleLimitPitch then
                ang.p = wep.DeployAngle.p - wep.BipodAngleLimitPitch
            end

            move:SetViewAngles(ang)
        end
    end
end

hook.Add("CreateMove", "ChaosBaseCreateMove", ChaosCreateMove)

hook.Add("PlayerBindPress", "ChaosBase_PlayerBindPress", ChaosBase_PlayerBindPress)

--Register the Binds
for k, v in pairs(ChaosBase.BindToEffect_Unique) do
    concommand.Add(k, function(ply) ChaosBase_PlayerBindPress(ply, k, true) end, nil, v, 0)
end