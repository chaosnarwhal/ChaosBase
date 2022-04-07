AddCSLuaFile()

function SWEP:CanChangeFiremode()
    return not self:GetReloading()
        && (not self:GetNWState() == ChaosBase.STATE_SPRINT)
        && CurTime() > self:GetNextPrimaryFire()
end

function SWEP:FiremodeBehaviourModule()
    if (CLIENT && game.SinglePlayer()) then
        return
    end

    if (self:GetOwner():KeyDown(IN_USE) && self:GetOwner():KeyDown(IN_RELOAD)) then
        if (CurTime() > self:GetNextFiremodeTime()) then
            local index = self:GetFireMode()

            if (self.Firemodes[index + 1]) then
                index = index + 1
            else
                index = 1
            end

            if (self:GetFireMode() != index) then
                local seqIndex = self:ApplyFiremode(index)

                local length = 0.5

                self:SetNextFiremodeTime(CurTime() + length)
                self:SetBurstRounds(0)
            end
        end
    end
    
    if (self.Primary.BurstRounds > 1 && self:GetBurstRounds() < self.Primary.BurstRounds && self:GetBurstRounds() > 0) then
        self:PrimaryAttack()
    end
    
end

function SWEP:ApplyFiremodeStats()
    if (index == 1) then
        seqIndex = self.Firemodes[self:GetFireMode()].OnSet() --prevent giving reference to weapon so user doesn't change defaults
    else
        seqIndex = self.Firemodes[self:GetFireMode()].OnSet(self)
    end

    return seqIndex
end

function SWEP:ApplyFiremode(index)
    local seqIndex = "Idle"

    if (type(index) == "string") then
        index = tonumber(index)
    end

    self:SetFireMode(index)

    self:HoldTypeHandler()

    if (game.SinglePlayer() && SERVER) then
        self:CallOnClient("ApplyFiremode", index)
    end
    return self:ApplyFiremodeStats()

end