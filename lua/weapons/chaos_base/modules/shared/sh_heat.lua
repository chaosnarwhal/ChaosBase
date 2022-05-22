--HeatHandling
SWEP.NextHeatDissipateTime = 0
SWEP.Heat = 0

function SWEP:GetMaxHeat()
    return self.HeatCapacity
end

function SWEP:AddHeat(a)
    local sp = game.SinglePlayer()
    a = tonumber(a)
    if not self.BatteryBased then return end
    local max = self.HeatCapacity
    local mult = 1 * self.FixTime
    local heat = self:GetHeat()
    local anim = "fix"
    local amount = a or 1
    self.Heat = heat + amount
    self.NextHeatDissipateTime = CurTime() + self.HeatDelayTime
    local overheat = self.Heat >= max

    if overheat then
        local h = self.Heat

        if h == true then
            overheat = false
        end
    end

    if overheat then
        self.Heat = math.min(self.Heat, max)

        if self.HeatFix then
            self.NextHeatDissipateTime = CurTime() + self:GetAnimKeyTime(anim) * mult
        elseif self.HeatLockout then
            self.NextHeatDissipateTime = CurTime() + (self:GetAnimKeyTime(anim) or 1) * mult
        end
    elseif not self.HeatOverflow then
        self.Heat = math.min(self.Heat, max)
    end

    if sp and CLIENT then return end
    self:SetHeat(self.Heat)

    if overheat then
        if self.HeatFix then
            timer.Simple(self:GetAnimKeyTime(anim)+1, function()
                self:SetHeat(0)
            end)
        end

        if self.HeatLockout then
            self:SetHeatLocked(true)
        end
    end
end

function SWEP:DoHeat()
    if not self.BatteryBased then return end
    if self.NextHeatDissipateTime > CurTime() then return end
    local startime = self.HeatCapacity
    local mult = 1 * self.FixTime

    if self:GetHeat() >= startime then
        print("Fix_Start")
        self:PlayAnimationEZ("fix_start", mult, true)
    end

    --self:GetOwner():SetAmmo(self:GetHeat(), 100)

    local diss = self.HeatDissipation or 2
    local ft = FrameTime()
    self.Heat = self:GetHeat() - (ft * diss)
    self.Heat = math.max(self.Heat, 0)
    self:SetHeat(self.Heat)

    if self.Heat <= 0 and self:GetHeatLocked() then
        self:SetHeatLocked(false)
    end
end