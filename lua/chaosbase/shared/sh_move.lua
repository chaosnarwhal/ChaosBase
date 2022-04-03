--[[
function ChaosBase.StartCommand(ply, ucmd)
	if IsValid(wep) and wep.ChaosBase then
		if wep:GetNextHolsterTime() != 0 and wep:GetNextHolsterTime() <= CurTime() then
			if IsValid(wep:GetHolster_Entity()) then
				wep:SetNextHolsterTime()(-math.huge)
				ucmd:SelectWeapon(wep:GetHolster_Entity())
			end
		end
	end
end

hook.Add("StartCommand", "ChaosBase_StartCommand", ChaosBase.StartCommand)
]]