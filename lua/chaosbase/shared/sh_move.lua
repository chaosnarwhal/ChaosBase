--[[
Hook: PlayerBindPress
Function: Intercept Keybinds
Used For:  Alternate attack, inspection, shotgun interrupts, and more
]]
--

local sv_cheats = GetConVar("sv_cheats")
local host_timescale = GetConVar("host_timescale")
local band = bit.band
local bxor = bit.bxor
local bnot = bit.bnot
local GetTimeScale = game.GetTimeScale
local IN_ATTACK2 = IN_ATTACK2

local function FinishMove(ply, cmovedata)
    if ply:InVehicle() then return end
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or not wep.ChaosBase then return end
    local lastButtons = wep:GetDownButtons()
    local buttons = cmovedata:GetButtons()
    local changed = bxor(lastButtons, buttons)
    local pressed = band(changed, bnot(lastButtons), buttons)
    local depressed = band(changed, lastButtons, bnot(buttons))
    wep:SetDownButtons(buttons)
    wep:SetLastPressedButtons(pressed)
    local time = CurTime()
    local chaosbase_ironsights_toggle = (ply:GetInfoNum("chaosbase_ironsights_toggle", 0) or 0) >= 1
    local chaosbase_ironsights_resight = (ply:GetInfoNum("chaosbase_ironsights_resight", 0) or 0) >= 1
    local chaosbase_ironsights_responsive = (ply:GetInfoNum("chaosbase_ironsights_responsive", 0) or 0) >= 1
    local chaosbase_ironsights_responsive_timer = ply:GetInfoNum("chaosbase_ironsights_responsive_timer", 0.175) or 0.175
    local scale_dividier = GetTimeScale() * (sv_cheats:GetBool() and host_timescale:GetFloat() or 1)

    if not wep:GetSafety() then
        if band(changed, IN_ATTACK2) == IN_ATTACK2 then
            local deltaPress = (time - wep:GetLastIronSightsPressed()) / scale_dividier

            -- Pressed the Ironsights the first time.
            if not wep:GetIsAiming() and band(pressed, IN_ATTACK2) == IN_ATTACK2 then
                wep:SetIsAiming(true)
                wep:SetLastIronSightsPressed(time)
            elseif wep:GetIsAiming() and ((chaosbase_ironsights_toggle or chaosbase_ironsights_responsive) and band(pressed, IN_ATTACK2) == IN_ATTACK2 or not chaosbase_ironsights_toggle and not chaosbase_ironsights_responsive and band(depressed, IN_ATTACK2) == IN_ATTACK2) then
                -- Get out of Ironsights
                wep:SetIsAiming(false)
                wep:SetLastIronSightsPressed(-1)
            elseif wep:GetIsAiming() and chaosbase_ironsights_responsive and band(depressed, IN_ATTACK2) == IN_ATTACK2 and deltaPress > chaosbase_ironsights_responsive_timer then
                -- We depressed In_ATTACK2 if it were being held down.
                wep:SetIsAiming(false)
                wep:SetLastIronSightsPressed(-1)
            end
        elseif wep:GetIsAiming() and not chaosbase_ironsights_resight and (not wep:GetIsAiming() and wep:GetIsSprinting()) then
            wep:SetIsAiming(true)
            wep:SetLastIronSightsPressed(-1)
        end
    end
end

hook.Add("FinishMove", "ChaosFinishMove", FinishMove)