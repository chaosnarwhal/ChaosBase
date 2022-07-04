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
local IN_RELOAD = IN_RELOAD

local function FinishMove(ply, cmovedata)
    if ply:InVehicle() then return end
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or not wep.ChaosBase then return end
    local impulse = cmovedata:GetImpulseCommand()
    local lastButtons = wep:GetDownButtons()
    local buttons = cmovedata:GetButtons()
    local stillPressed = band(lastButtons, buttons)
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

--Movement Rework
AddCSLuaFile()

local mat_speeds = {
    [MAT_DIRT] = 0.8,
    [MAT_FLESH] = 0.8,
    [MAT_SNOW] = 0.7,
    [MAT_SAND] = 0.8,
    [MAT_SLOSH] = 0.7,
    [MAT_GRASS] = 0.9,
}

local CMoveData = FindMetaTable("CMoveData")

function CMoveData:RemoveKeys(keys)
    local newbuttons = bit.band(self:GetButtons(), bit.bnot(keys))
    self:SetButtons(newbuttons)
end

local meta = FindMetaTable("Player")

function meta:GetNewSpeed()
    return self:GetNW2Float("new_speed")
end

function meta:GetNewSpeedLerp()
    return self:GetNW2Float("new_speed_lerp")
end

function meta:GetLerpTime()
    return self:GetNW2Float("lerptime")
end

function meta:GetCrouchSpeed()
    return self:GetNW2Float("crouch_speed")
end

function meta:GetCrouchSpeedLerp()
    return self:GetNW2Float("crouch_speed_lerp")
end

function meta:GetOldZ()
    return self:GetNW2Float("old_z")
end

function meta:GetInAir()
    return self:GetNW2Bool("in_air")
end

function meta:GetInNoclip()
    return self:GetNW2Bool("in_noclip")
end

local bhop_kill = true
local min_speed = 200
local min_speed_mult = 0.6
local side_speed_mult = 1
local speed_change = 0.5
local crouching_speed = 0.35

hook.Add("PlayerSpawn", "InitiateMoveSpeeds", function(ply)
    ply:SetNW2Float("new_speed", 170)
    ply:SetNW2Float("new_speed_lerp", 170)
    ply:SetNW2Float("lerptime", 0.1)
    ply:SetNW2Float("crouch_speed", 0.3)
    ply:SetNW2Float("crouch_speed_lerp", 0.3)
    ply:SetNW2Float("old_z", 0)
    ply:SetNW2Bool("in_air", 0)
    ply:SetNW2Bool("in_noclip", 0)
end)

hook.Add("OnEntityCreated", "Offset", function(ent)
    if not ent:IsPlayer() then return end
    offset_origin = ent:GetViewOffset()
end)

hook.Add("PlayerNoClip", "isInNoClip", function(ply, desiredNoClipState)
    if desiredNoClipState then
        ply:SetNW2Bool("in_noclip", true)
    else
        ply:SetNW2Bool("in_noclip", false)
    end
end)

hook.Add("SetupMove", "Movement", function(ply, mv, cmd)
    local ct = CurTime()
    local max_speed = ply:getJobTable().RunSpeed or 250
    if ply:GetInNoclip() then return end

    if ply:OnGround() and ply:GetInAir() then
        ply:SetNW2Bool("in_air", false)
        ply:SetNW2Float("new_speed_lerp", ply:GetNewSpeedLerp() + ply:GetVelocity():Length() / 3)
    end

    ply:SetNW2Float("new_z", mv:GetOrigin()[3])

    local tr = util.TraceLine({
        start = ply:GetPos(),
        endpos = ply:GetPos() - Vector(0, 0, 20),
        filter = function(ent) return ent:GetClass() == "prop_physics" end
    })

    mv:SetMaxClientSpeed(ply:GetNewSpeedLerp())
    mv:SetMaxSpeed(ply:GetNewSpeedLerp())
    ply:SetCrouchedWalkSpeed(ply:GetCrouchSpeedLerp())
    ply:SetDuckSpeed(crouching_speed)
    ply:SetUnDuckSpeed(crouching_speed)
    ply:SetLadderClimbSpeed(100)
    ply:SetRunSpeed(300 * 1.5)

    -----------------------speed
    if not cmd:KeyDown(IN_DUCK) then
        if ply:IsSprinting() and cmd:GetForwardMove() > 0 and (ply:OnGround() or ply:WaterLevel() >= 1) then
            ply:SetNW2Float("new_speed", max_speed)
            ply:SetNW2Float("lerptime", 0.01)
        elseif not cmd:KeyDown(IN_WALK) and (cmd:GetForwardMove() > 0) and (ply:OnGround() or ply:WaterLevel() >= 1) then
            ply:SetNW2Float("new_speed", min_speed)
            ply:SetNW2Float("lerptime", 0.01)
        elseif not cmd:KeyDown(IN_WALK) and (not (cmd:GetSideMove() == 0) or (cmd:GetForwardMove() < 0)) and (ply:OnGround() or ply:WaterLevel() >= 1) then
            ply:SetNW2Float("new_speed", min_speed * side_speed_mult)
            ply:SetNW2Float("lerptime", 0.01)
        elseif cmd:KeyDown(IN_WALK) and (ply:OnGround() or ply:WaterLevel() >= 1) and (not (cmd:GetForwardMove() == 0) or not (cmd:GetSideMove() == 0)) then
            ply:SetNW2Float("new_speed", min_speed * min_speed_mult)
            ply:SetNW2Float("lerptime", 0.02)
        elseif not bhop_kill then
            ply:SetNW2Float("new_speed", min_speed)
            ply:SetNW2Float("lerptime", 0.05)
        else
            ply:SetNW2Float("new_speed", 30)
            ply:SetNW2Float("lerptime", 0.05)
        end
    end

    ----------------------- slope system
    if mv:GetOrigin()[3] > ply:GetOldZ() then
        ply:SetNW2Float("new_speed", ply:GetNewSpeed() * (1.1 - math.max(math.abs(tr.HitNormal[1]), math.abs(tr.HitNormal[2]))))
    elseif mv:GetOrigin()[3] < ply:GetOldZ() then
        ply:SetNW2Float("new_speed", ply:GetNewSpeed() * (0.9 + math.max(math.abs(tr.HitNormal[1]), math.abs(tr.HitNormal[2]))))
        ply:SetNW2Float("new_speed_lerp", ply:GetNewSpeedLerp() + (ply:GetVelocity():Length() / 300) * math.max(math.abs(tr.HitNormal[1]), math.abs(tr.HitNormal[2])))
    end

    -----------------------ducking speed
    if cmd:KeyDown(IN_DUCK) then
        if cmd:KeyDown(IN_SPEED) and cmd:KeyDown(IN_FORWARD) and ply:OnGround() and ply:GetVelocity():Length() >= 30 then
            ply:SetNW2Float("new_speed", min_speed * 0.5)
            ply:SetNW2Float("crouch_speed", 0.5)
            ply:SetNW2Float("lerptime", 0.05)
        else
            ply:SetNW2Float("new_speed", min_speed * 0.5)
            ply:SetNW2Float("crouch_speed", 0.5)
            ply:SetNW2Float("lerptime", 0.05)
        end
    end

    if ply:WaterLevel() > 0 and ply:WaterLevel() <= 2 and not ply:OnGround() then
        mv:RemoveKeys(IN_JUMP)
    end

    -----------------------lerps
    ply:SetNW2Float("crouch_speed_lerp", Lerp(math.ease.OutExpo(0.002 / ply:GetCrouchSpeed()), ply:GetCrouchSpeedLerp(), ply:GetCrouchSpeed()))
    ply:SetNW2Float("new_speed_lerp", Lerp(math.ease.OutExpo(ply:GetLerpTime()), ply:GetNewSpeedLerp(), ply:GetNewSpeed()))
    -----------------------old z 
    ply:SetNW2Float("old_z", mv:GetOrigin()[3])

    if not ply:OnGround() then
        ply:SetNW2Bool("in_air", true)
    end
end)

local jump_enabled = true

hook.Add("SetupMove", "JumpHeight", function(ply, mv, cmd)
    local jump_height = 200 * (ply:GetNW2Float("Chaos.PlayerScale") or 1)
    local jump_power = 5
    ply:SetJumpPower(jump_height)
    if not jump_enabled then return end
    if ply:KeyDown(IN_JUMP) and not ply:OnGround() and mv:GetVelocity()[3] > 0 then
        mv:SetVelocity(mv:GetVelocity() + Vector(0, 0, jump_power))
    end
end)

hook.Add("PlayerStepSoundTime", "StepTime", function(ply, type, walking)
    local speed = ply:GetVelocity():Length()
    local perc = speed / min_speed or ply:GetWalkSpeed()
    local speed_new = math.Clamp(660 - (330 * perc * 0.75), 200, 1000) * 1

    return speed_new
end)

hook.Add("StartCommand", "Prevent_Duck_Spam", function(ply, cmd)
    if ply:GetInNoclip() then return end

    if ply:GetNWInt("allowduck") == 0 then
        if not ply:IsOnGround() then
            cmd:SetButtons(IN_DUCK)
        end
    end

    if ply:KeyReleased(IN_DUCK) then
        ply:SetNWInt("allowduck", 0)
    end
end)

hook.Add("OnPlayerHitGround", "OnPlayerHitGround-anti-duck-crouch-spam", function(player)
    if player:GetInNoclip() then return end

    --If the player is on the ground.
    if player:IsOnGround() then
        --Allow the player to duck again.
        if player:GetNWInt("allowduck") == 0 then end
        player:SetNWInt("allowduck", 1)
    end

    player:SetVelocity(-player:GetVelocity() * 0.1321)
end)

--When player joins the server create the network var to allow them to duck or not.
hook.Add("PlayerInitialSpawn", "PlayerInitialSpawn-anti-duck-crouch-spam", function(player)
    player:SetNWInt("allowduck", 1)
end)

hook.Add("FinishMove", "ChaosFinishMove", FinishMove)