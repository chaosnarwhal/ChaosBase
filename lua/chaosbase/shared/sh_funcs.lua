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

	hook.Add("PreDrawViewModel", "DrawThatViewModelThang", function(vm)
		local ply = LocalPlayer()
		if not IsValid(ply) then return end

		local weapon = ply:GetActiveWeapon()

		local st = SysTime()
		st_old = st_old or st

		local delta = st - st_old
		st_old = st

		if sp and IsGameUIVisible and IsGameUIVisible() then return end

		delta = delta * game.GetTimeScale() * (cheats:GetBool() and host_ts:GetFloat() or 1)	

		if IsValid(weapon) and weapon.ChaosBase then
    		weapon:CalculateViewModelOffset(delta)
    		weapon:CalculateViewModelFlip()
		end

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