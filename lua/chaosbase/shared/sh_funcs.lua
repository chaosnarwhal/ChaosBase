local sp = game.SinglePlayer()

function CTFK(tab, value)
	for i,v in ipairs(tab) do
		if v == value then return true end
	end
	return false
end

function CTFKV(tab, value)
	for i,v in ipairs(tab) do
		if i == value then return true end
	end
	return false
end

--[[
Hook: PlayerPostThink
Function: Weapon Logic
Used For: Main weapon "think" logic
]]
--
hook.Add("PlayerPostThink", "ChaosPlayerTick", function(plyv)
    local wepv = plyv:GetActiveWeapon()

    if IsValid(wepv) and wepv.ChaosPlayerThink and wepv.ChaosBase then
        wepv:ChaosPlayerThink(plyv, plyv.last_chaos_think == engine.TickCount())
        plyv.last_chaos_think = engine.TickCount()
    end
end)

if SERVER or not sp then
    hook.Add("FinishMove", "ChaosPlayerTick", function(plyv)
        local wepv = plyv:GetActiveWeapon()

        if IsValid(wepv) and wepv.ChaosBase and wepv.ChaosPlayerThink then
            wepv:ChaosPlayerThink(plyv, not IsFirstTimePredicted())
        end
    end)

    hook.Remove("PlayerPostThink", "ChaosPlayerTick")
end

hook.Add("AllowPlayerPickup", "ChaosPickupDisable", function(plyv, ent)
    plyv:SetNW2Entity("LastHeldEntity", ent)
end)

--[[
Hook: Tick
Function: Inspection mouse support
Used For: Enables and disables screen clicker
]]
--
if CLIENT then
    hook.Add("Think", "ChaosPlayerThinkCL", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        local weapon = ply:GetActiveWeapon()

        if IsValid(weapon) and weapon.ChaosBase and weapon.ChaosPlayerThinkCL then
            weapon:ChaosPlayerThinkCL(ply)
        end
    end)
end

if CLIENT then
    local st_old
    host_ts = GetConVar("host_timescale")
    cheats = GetConVar("sv_cheats")
    vec = Vector()
    ang = Angle()
    local IsGameUIVisible = gui and gui.IsGameUIVisible

    hook.Add("PreDrawViewModel", "ChaosBasePreDrawViewModel", function(vm, plyv, wepv)
        if not IsValid(wepv) or not wepv.ChaosBase then return end
        wepv:UpdateEngineBob()
        local st = SysTime()
        st_old = st_old or st
        local delta = st - st_old
        st_old = st
        if sp and IsGameUIVisible and IsGameUIVisible() then return end
        wepv:CalculateViewModelOffset(delta)
        wepv:CalculateViewModelFlip()
    end)
end

net.Receive("chaosbase_firemode", function(len, ply)
    local wpn = ply:GetActiveWeapon()
    if not wpn.ChaosBase then return end
    wpn:ChangeFiremode()
end)

ChaosBase.FrameTime = (function(ft)
    local a = Angle(0.015)
    if ft == a[1] then return 0.015 end

    --for r = 10, 100 do
    for r = math.floor(1 / ft), math.ceil(1 / ft) do
        a[1] = 1 / r
        if ft == a[1] then return 1 / r end
    end

    return ft
end)(engine.TickInterval())

-- Works around the 10 bodygroup limit on ENTITY:SetBodyGroups()
function ChaosBase.SetBodyGroups(mdl, bodygroups)
    mdl:SetBodyGroups(bodygroups)
    local len = string.len(bodygroups or "")

    for i = 10, len - 1 do
        mdl:SetBodygroup(i, tonumber(string.sub(bodygroups, i + 1, i + 2)))
    end
end

function ChaosBase:DLight(ent, pos, col, size, lifetime, emissive)
    local HDR = render.GetHDREnabled()

    if emissive == nil then
        emissive = false
    end

    if IsEntity(ent) then
        ent = ent:EntIndex()
    end

    local dl = DynamicLight(ent, emissive)
    dl.pos = pos
    dl.r = col.r
    dl.g = col.g
    dl.b = col.b
    dl.brightness = col.a
    dl.Decay = 1000 / lifetime
    dl.size = size
    dl.DieTime = CurTime() + lifetime

    if HDR == false and emissive == false then
        local el = DynamicLight(ent, true)
        el.pos = pos
        el.r = col.r
        el.g = col.g
        el.b = col.b
        el.brightness = col.a
        el.Decay = 1000 / lifetime
        el.size = size
        el.DieTime = CurTime() + lifetime
    end
end

CreateConVar("rev_killfeed", "true", FCVAR_ARCHIVE , "Enables or Disables the killfeed protection.")

local disablefeed = disablefeed or {}

disablefeed = {
	["Admin"] = true,
}

hook.Add("DrawDeathNotice", "DisableKills", function()
	local master_switch = GetConVar("rev_killfeed")

	if master_switch:GetBool() == true then
			return 0.85,0.04
		else

		local ply = LocalPlayer()

		if not IsValid(ply) then return end

		local plyjob = ply:getJobTable().category

		if not disablefeed[plyjob] then
			return 0,0
		end

	end


end)


timer.Simple(1,function()

	hook.Remove("PlayerDeath", "FAdmin_Log")

end)

--Adding a hook that all players run when taking damage. And overriding the base function with our own.
hook.Add( "GetFallDamage", "RevivalFallDMG", function( ply, speed ) 
	--Inside here is where we make the function. With the GetFallDamage hook their are two arguments as seen above inside of our function wrap. PLY and SPEED. These arguments are always found on the gmod wiki and will tell you what they do. ply in this case is our local player. and speed is our fall velocity.
	
	
	-- Declaring a local variable. Variables are wrote to store a value or complete a small function that doesn't need to pass arguments.
	-- Here I Declare JobFallDamage to equal ply:getJobTable().fallDamage. This broken down ask the hook to check the ply *local player in this function*, get their DarkRP jobtable and pull the fall damage value. We then make an or statement for 4 if there are not falldamage values set in the jobs.lua.
	local JobFallDamageVal = ply:getJobTable().fallDamage or 4
	
	
	-- Here we are declaring the calculation im going to be using. Math.Ceil is to round the value we are about to pass out. 
	local JobFallDamage = math.ceil(speed/16 * JobFallDamageVal)
	
	--Check if fallspeed is less than 900, if they are crouching, and have the climbswep out.
	if speed < 900 and ply:Crouching() and (ply:GetActiveWeapon():GetClass() == "climb_swep2") then
		--GetFallDamage passes falldamage to the player through the return value of the function. By Returning 0 we tell the hook to apply 0 damage to the player.
		return 0
	else --Else statements read as *Did they pass the above check? if so continue to end after return 0. If they failed the check continue past else than end.
		return JobFallDamage
	end
end )

--Remove the old climbswep hook.
hook.Remove("GetFallDamage", "ClimbRollPD")


--PLAYER ID RANGER.
local ConVars = {}
local HUDWidth
local HUDHeight

local Color = Color
local CurTime = CurTime
local cvars = cvars
local draw = draw
local GetConVar = GetConVar
local hook = hook
local IsValid = IsValid
local Lerp = Lerp
local math = math
local pairs = pairs
local ScrW, ScrH = ScrW, ScrH
local SortedPairs = SortedPairs
local string = string
local surface = surface
local table = table
local timer = timer
local tostring = tostring

local PMeta = FindMetaTable( "Player" )

local PlayerTrace = {
    mask = MASK_SOLID,
    dist = 1000,
}

function PMeta:GetCloaked()
    local Col = self:GetColor()
    if Col.a <= 0 then
        return true
    end
    if self:GetNoDraw() or self:IsDormant() then 
        return true 
    end
    return false
end

hook.Add( "HUDDrawTargetID", "RevivalIDSystem", function()

    local Ply = LocalPlayer()
	
	local text = "ERROR"

    local traced = table.Copy(PlayerTrace) -- copy the table to tracedata, or ,traced so it doens't get overridden
    traced.start = Ply:EyePos()
    traced.endpos = traced.start + Ply:EyeAngles():Forward() * traced.dist
    traced.owner = Ply
    traced.filter = Ply

    local htr = util.TraceLine(traced)
    local ent = htr.Entity
	
    if (htr.Hit and ent) and ent:IsPlayer() then	
        if not ent:GetCloaked() then
            local Bh,Th = ent:GetHull()
            local Pos = ent:GetPos() + ent:OBBCenter()
            local TeamCol = team.GetColor( ent:Team() )
            Pos.z = Pos.z + Th.z-25

            local PosToScreen = Pos:ToScreen()

            local Text = ent:GetName() or ent:GetNick()
            local font = "GModNotify"
            surface.SetFont( font )
			local w, h = surface.GetTextSize( Text )
            draw.SimpleTextOutlined( Text, font,PosToScreen.x-(w/2), PosToScreen.y+5, TeamCol,0,0,1,Color(0,0,0,255) )

            local Health = math.floor((ent:Health() / ent:GetMaxHealth()) * 100)
            local Text = "HP:" .. Health .. "%"
			local font = "DermaDefault"
			surface.SetFont( font )
            local w, h = surface.GetTextSize( Text )
            
            draw.SimpleTextOutlined( Text, font,PosToScreen.x-(w/2), PosToScreen.y+30, Color(255,255,255),0,0,1,Color(0,0,0,255) )
        end
    end
    return false
end)

local function JoinMessage(ply)

	JoinMessageTable  = {
	
	["STEAM_0:0:68228942"] = "They... Are my Kind.",
	["STEAM_0:1:59480742"] = "<translate=rand(-1,1), rand(-1,1)>Impending Doom Approaches.",
	["STEAM_0:0:77188080"] = "Impending Nerfs Approaches.",
    ["STEAM_0:1:59316751"] = "Watch out! A real nigga has joined the game."
	
	}

	local JoinSteamID = ply:SteamID()
	
	if JoinMessageTable[JoinSteamID] then
		PrintMessage(HUD_PRINTTALK, JoinMessageTable[JoinSteamID])
	end
	
end