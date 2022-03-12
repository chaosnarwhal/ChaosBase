function ChaosBase.StartCommand(ply, ucmd)
	if IsValid(wep) and wep.ChaosBase then
		if wep:GetHolster_Time() != 0 and wep:GetHolster_Time() <= CurTime() then
			if IsValid(wep:GetHolster_Entity()) then
				wep:SetHolster_Time(-math.huge)
				ucmd:SelectWeapon(wep:GetHolster_Entity())
			end
		end
	end
end

hook.Add("StartCommand", "ChaosBase_StartCommand", ChaosBase.StartCommand)