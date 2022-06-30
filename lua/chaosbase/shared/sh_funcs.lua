local sp = game.SinglePlayer()

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

		if IsValid(weapon) and weapon.ChaosBase then
			if weapon.ChaosPlayerThinkCL then
				weapon:ChaosPlayerThinkCL(ply)
			end
		end
	end)
	
end

if CLIENT then
	local st_old, host_ts, cheats, vec, ang
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

    if ft == a[1] then
        return 0.015
    end

    --for r = 10, 100 do
    for r = math.floor(1 / ft), math.ceil(1 / ft) do
        a[1] = 1 / r

        if ft == a[1] then
            return 1 / r
        end
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

ChaosBaseAmmoTypes = {}
function ChaosBase:AddAmmoType(tbl)
	table.Add(ChaosBaseAmmoTypes, tbl)
end

local batteryammo = {{
	Name = "ammo_chaos_battery",
	Text = "Don't give yourself this ammo. It will only break your weapons.",
	DMG = DMG_BULLET,
	DamagePlayer = 0,
	DamageNPC = 0,
	Tracer = TRACER_LINE_AND_WHIZ,
	Force = 500,
	SplashMin = 5,
	SplashMax = 10,
	MaxCarry = 100,
}}
ChaosBase:AddAmmoType(batteryammo)

hook.Add("Initialize", "chaos_SetupAmmoTypes", function()
	for k,v in pairs(ChaosBaseAmmoTypes) do
		if CLIENT then
			language.Add(""..v.Name.."_ammo", v.Text)
		end

		game.AddAmmoType({
		name = v.Name,
		dmgtype = v.DMG,
		tracer = v.Tracer,
		plydmg = v.DamagePlayer,
		npcdmg = v.DamageNPC,
		force = v.Force,
		minsplash = v.SplashMin,
		maxsplash = v.SplashMax,
		maxcarry = v.MaxCarry
		})
	end
end)

function ChaosBase:DLight(ent, pos, col, size, lifetime, emissive)
	local HDR = render.GetHDREnabled()

	if emissive == nil then emissive = false end
	if IsEntity(ent) then ent = ent:EntIndex() end
	local dl = DynamicLight(ent, emissive)
	dl.pos = pos
	dl.r = col.r
	dl.g = col.g
	dl.b = col.b
	dl.brightness = col.a
	dl.Decay = (1000 / lifetime)
	dl.size = size
	dl.DieTime = CurTime() + lifetime
	
	if HDR == false && emissive == false then
		local el = DynamicLight(ent, true)
		el.pos = pos
		el.r = col.r
		el.g = col.g
		el.b = col.b
		el.brightness = col.a
		el.Decay = (1000 / lifetime)
		el.size = size
		el.DieTime = CurTime() + lifetime
	end
end