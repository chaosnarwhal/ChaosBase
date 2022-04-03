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
	
	hook.Add("PreDrawViewModel", "RevCalculateViewmodel", function(vm, plyv, wepv)
		if not wepv:IsValid() or not (wepv.Base == "chaos_base") then return end

		local st = SysTime()
		st_old = st_old or st

		local delta = st - st_old
		st_old = st

		if game.SinglePlayer() and IsGameUIVisible and IsGameUIVisible() then return end

		delta = delta * game.GetTimeScale() * 1

		--Weapon SWAY code does not work, needs re-write.
		wepv:CalculateViewModelOffset(delta)
		wepv:CalculateViewModelFlip()

	end)
	
end

net.Receive("chaosbase_firemode", function(len, ply)
    local wpn = ply:GetActiveWeapon()

    if not wpn.ChaosBase then return end

    wpn:ChangeFiremode()
end)