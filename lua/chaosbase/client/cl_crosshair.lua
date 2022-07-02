local widthpos, heightpos = 0, 0

function ChaosBase:halo_Crosshair()
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()
    if not IsValid(ply) or not ply:Alive() then return end
    if not IsValid(wep) then return end
    if not wep.ChaosBase then return end
    if GetConVar("cl_drawhud"):GetFloat() == 0 then return end

    if (wep._eyeang == nil) then
        return
    end
    
    local widthpos, heightpos = ScrW() * 0.5, ScrH() * 0.5
    local pos = (EyePos() + wep._eyeang:Forward() * 10):ToScreen()

    if (Vector(widthpos, 0, heightpos):Distance(Vector(pos.x, 0, pos.y)) > 1.5) then
        widthpos,heightpos = math.floor(pos.x), math.floor(pos.y)
    end

    if wep:GetIsAiming() == true then
        alphach = Lerp(0, 0, 255)
        alphalerpch = Lerp(FrameTime() * 25, alphalerpch or 0, 0)
    else
        alphach = Lerp(0, 255, 0)
        alphalerpch = Lerp(FrameTime() * 25, alphalerpch or alphach or 0, alphach or 0)
    end

    local cone = wep:GetCone() * 100

    local modspread = 1
    local modspreaddiv = 20
    local spread = cone * modspread
    local spreaddiv = cone * modspreaddiv
    local artificial = wep.CrosshairSizeMul
    local cx = 1
    local cy = 1
    local smath = spread / spreaddiv
    local smathoffset = smath * 150
    local b = math.Clamp(cone or 0, 0, 100) * smath * (cone / 4)
    LerpC = Lerp(FrameTime() * 2, LerpC or b, b)

    local tr = util.TraceLine({
        start = ply:EyePos(),
        endpos = ply:EyePos() + EyeAngles():Forward() * 1000000,
        filter = function(ent)
            if ent == ply then return false end

            return true
        end
    })

    local crosshairColorTrace = Color(127,220,255,255)

    if tr.Entity and tr.Entity:IsNPC() or tr.Entity:IsPlayer() then
        crosshairColorTrace.r = 255
        crosshairColorTrace.g = 0
        crosshairColorTrace.b = 0
    else
        crosshairColorTrace.r = 127
        crosshairColorTrace.g = 220
        crosshairColorTrace.b = 255
    end

    if wep.CrosshairStatic ~= nil then
        if wep.CrosshairShadow == true then
            if wep.CrosshairNoIronFade == false then
                surface.SetDrawColor(crosshairColorTrace.r / 2, crosshairColorTrace.g / 2, crosshairColorTrace.b / 2, alphalerpch * 1.5)
            else
                surface.SetDrawColor(crosshairColorTrace.r / 2, crosshairColorTrace.g / 2, crosshairColorTrace.b / 2, 150)
            end

            surface.SetMaterial(Material(wep.CrosshairStatic))
            surface.DrawTexturedRect(widthpos - smathoffset * 3.3775 * artificial * cx, heightpos - smathoffset * 3.3775 * artificial * cy, smathoffset * 6.75 * artificial, smathoffset * 6.75 * artificial)
            surface.DrawTexturedRect(widthpos - smathoffset * 3.1275 * artificial * cx, heightpos - smathoffset * 3.1275 * artificial * cy, smathoffset * 6.25 * artificial, smathoffset * 6.25 * artificial)
        end

        if wep.CrosshairNoIronFade == false then
            surface.SetDrawColor(crosshairColorTrace.r, crosshairColorTrace.g, crosshairColorTrace.b, 255)
        else
            surface.SetDrawColor(crosshairColorTrace.r, crosshairColorTrace.g, crosshairColorTrace.b, alphalerpch)
        end

        surface.SetMaterial(Material(wep.CrosshairStatic))
        surface.DrawTexturedRect(widthpos - smathoffset * 3.25 * artificial * cx, heightpos - smathoffset * 3.25 * artificial * cy, smathoffset * 6.5 * artificial, smathoffset * 6.5 * artificial)
    end

    if wep.CrosshairDynamic ~= nil then
        if wep.CrosshairShadow == true then
            if wep.CrosshairNoIronFade == false then
                surface.SetDrawColor(crosshairColorTrace.r / 2, crosshairColorTrace.g / 2, crosshairColorTrace.b / 2, alphalerpch * 1.5)
            else
                surface.SetDrawColor(crosshairColorTrace.r / 2, crosshairColorTrace.g / 2, crosshairColorTrace.b / 2, 150)
            end

            surface.SetMaterial(Material(wep.CrosshairDynamic))
            surface.DrawTexturedRect(widthpos - smathoffset * 3.1275 * artificial - LerpC / 2 * cx, heightpos - smathoffset * 3.1275 * artificial - LerpC / 2 * cy, smathoffset * 6.25 * artificial + LerpC, smathoffset * 6.25 * artificial + LerpC)
            surface.DrawTexturedRect(widthpos - smathoffset * 3.3775 * artificial - LerpC / 2 * cx, heightpos - smathoffset * 3.3775 * artificial - LerpC / 2 * cy, smathoffset * 6.75 * artificial + LerpC, smathoffset * 6.75 * artificial + LerpC)
        end

        if wep.CrosshairNoIronFade == false then
            surface.SetDrawColor(crosshairColorTrace.r, crosshairColorTrace.g, crosshairColorTrace.b, alphalerpch)
        else
            surface.SetDrawColor(crosshairColorTrace.r, crosshairColorTrace.g, crosshairColorTrace.b, 255)
        end

        surface.SetMaterial(Material(wep.CrosshairDynamic))
        surface.DrawTexturedRect(widthpos - smathoffset * 3.25 * artificial - LerpC / 2 * cx, heightpos - smathoffset * 3.25 * artificial - LerpC / 2 * cy, smathoffset * 6.5 * artificial + LerpC, smathoffset * 6.5 * artificial + LerpC)
    end

    if wep.CrosshairStatic ~= nil or wep.CrosshairDynamic ~= nil then return end
    draw.RoundedBox(0, widthpos + LerpC + smath + smathoffset, heightpos - 2, 22, 3, Color(0, 0, 0, 200 * alphalerpch))
    draw.RoundedBox(0, widthpos + LerpC + 1 + smath + smathoffset, heightpos - 1, 20, 1, Color(255, 255, 255, 255 * alphalerpch))
    draw.RoundedBox(0, widthpos - LerpC - 20 - smath - smathoffset, heightpos - 2, 22, 3, Color(0, 0, 0, 200 * alphalerpch))
    draw.RoundedBox(0, widthpos - LerpC - 19 - smath - smathoffset, heightpos - 1, 20, 1, Color(255, 255, 255, 255 * alphalerpch))
    draw.RoundedBox(0, widthpos - 1, heightpos + LerpC + smath + smathoffset - 1, 3, 22, Color(0, 0, 0, 200 * alphalerpch))
    draw.RoundedBox(0, widthpos, heightpos + LerpC + smath + smathoffset, 1, 20, Color(255, 255, 255, 255 * alphalerpch))
    surface.DrawCircle(widthpos, heightpos, 64 * LerpC / 50, LerpC * 5, LerpC * 5, LerpC * 5, LerpC * 2.5)
    surface.DrawCircle(widthpos, heightpos, 1, 255, 255, 255, 255 * alphalerpch)
    surface.DrawCircle(widthpos, heightpos, 2, 0, 0, 0, 10 * alphalerpch)
end

hook.Add("HUDPaint", "ChaosBase_Crosshair", ChaosBase.halo_Crosshair)