function SWEP:ChangeFiremode(pred)
    pred = pred or true
    local fmt = self:GetBuff_Override("Override_Firemodes") or self.Firemodes

    fmt["BaseClass"] = nil

    if table.Count(fmt) == 1 then return end

    local fmi = self:GetFireMode()
    local lastfmi = fmi

    fmi = fmi + 1

    if fmi > table.Count(fmt) then
       fmi = 1
    end

    local altsafety = true
    if altsafety and !self:GetOwner():KeyDown(IN_WALK) and fmt[fmi] and fmt[fmi].Mode == 0 then
        -- Skip safety when walk key is not down
        fmi = (fmi + 1 > table.Count(fmt)) and 1 or (fmi + 1)
    elseif altsafety and self:GetOwner():KeyDown(IN_WALK) then
        if fmt[lastfmi] and fmt[lastfmi].Mode == 0 then
            -- Find the first non-safety firemode
            local nonsafe_fmi = nil
            for i, fm in pairs(fmt) do
                if fm.Mode != 0 then nonsafe_fmi = i break end
            end
            fmi = nonsafe_fmi or fmi
        else
            -- Find the safety firemode
            local safety_fmi = nil
            for i, fm in pairs(fmt) do
                if fm.Mode == 0 then safety_fmi = i break end
            end
            fmi = safety_fmi or fmi
        end
    end

    if !fmt[fmi] then fmi = 1 end

    self:SetFireMode(fmi)
    --timer.Simple(0, function() self:RecalcAllBuffs() end)
    -- Absolutely, totally, completely ENSURE client has changed the value before attempting recalculation
    -- Waiting one tick will not work on dedicated servers
    local id = "ArcCW_RecalcWait_" .. self:EntIndex()
    timer.Create(id, 0.01, 0, function()
        if !IsValid(self) then timer.Remove(id) return end
        if self:GetFireMode() == fmi then
            self:RecalcAllBuffs()
            timer.Remove(id)
        end
    end)

    if lastfmi != fmi then
        if SERVER then
            if pred then
                SuppressHostEvents(self:GetOwner())
            end
            self:MyEmitSound(self.FiremodeSound, 75, 100, 1, CHAN_ITEM + 2)
            if pred then
                SuppressHostEvents(NULL)
            end
        else
           self:MyEmitSound(self.FiremodeSound, 75, 100, 1, CHAN_ITEM + 2)
        end
    end

    local a = tostring(lastfmi) .. "_to_" .. tostring(fmi)

    self:SetShouldHoldType()

    --[[if CLIENT then
        if !ArcCW:ShouldDrawHUDElement("CHudAmmo") then
            self:GetOwner():ChatPrint(self:GetFiremodeName() .. "|" .. self:GetFiremodeBars())
        end
    end]]

    if self.Animations[a] then
        self:PlayAnimation(a)
    elseif self.Animations.changefiremode then
        self:PlayAnimation("changefiremode")
    end
    if self:GetCurrentFiremode().Mode == 0 then
        self:ExitSights()
    end
end

function SWEP:GetCurrentFiremode()
    local fmt = self.Firemodes

    if self:GetFireMode() > table.Count(fmt) then
        self:SetFireMode(1)
    end

    return fmt[self:GetFireMode()]
end

function SWEP:GetBurstLength()
    local clip = self:Clip1()

    if clip == 0 then return 1 end

    local len = self:GetCurrentFiremode().Mode

    if !len then return self:GetBurstCount() + 10 end

    if len == 1 then return 1 end
    if len >= 2 then return self:GetBurstCount() + 10 end

    if len < 0 then return -len end

    return self:GetBurstCount() + 10
end