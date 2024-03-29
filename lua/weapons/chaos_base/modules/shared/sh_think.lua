AddCSLuaFile()

function SWEP:Think()
end

function SWEP:ChaosPlayerThink(plyv, is_working_out_prediction_errors)
    self:ChaosThink2(is_working_out_prediction_errors)
end

function SWEP:ChaosPlayerThinkCL(plyv)
    local speed = 1 / self.IronSightTime
    local sprintspeed = 1 / self.SprintTime
    local ft = FrameTime()

    if self.BlowbackEnabled then
        if self:Clip1() == 0 and self.Blowback_SlideLock and not self:GetIsReloading() then
            self.BlowbackCurrent = 1
        else
            self.BlowbackCurrent = math.Approach(self.BlowbackCurrent, 0, self.BlowbackCurrent * ft * 15)
        end
    end

    --Aim Behaviour Handles to pass through values to CL/Server
    --IronSight Pred Handling.
    local is = self:GetIsAiming()
    local ist = is and 1 or 0
    self.IronSightsProgressUnpredicted = math.Approach(self.IronSightsProgressUnpredicted or 0, ist, (ist - (self.IronSightsProgressUnpredicted or 0)) * ft * speed * 1.2)
    --Safety Pred handling.
    local issafety = self:GetSafety()
    local issafetyt = issafety and 1 or 0
    self.SafetyProgressUnpredicted = math.Approach(self.SafetyProgressUnpredicted or 0, issafetyt, (issafetyt - (self.SafetyProgressUnpredicted or 0)) * ft * 5)
    --Sprint Anim Handling
    local issprinting = self:InSprint() and not self:GetIsReloading()
    local issprintingt = issprinting and 1 or 0
    self.SprintProgressUnpredicted = math.Approach(self.SprintProgressUnpredicted or 0, issprintingt, (issprintingt - (self.SprintProgressUnpredicted or 0)) * ft * sprintspeed * 1.2)
    self:ChaosPlayerThinkCLCustom()
end

function SWEP:ChaosPlayerThinkCLCustom()
end

function SWEP:ChaosThink2(is_working_out_prediction_errors)
    local ct = CurTime()
    local owner = self:GetOwner()

    --Hi Tasteful. Hope u get manager
    if not is_working_out_prediction_errors then
        if CLIENT then
            self.CurTimePredictionAdvance = ct - UnPredictedCurTime()
        end

        self:IronSightSounds()
    end

    for i, v in ipairs(self.EventTable) do
        for ed, bz in pairs(v) do
            if ed <= CurTime() then
                self:PlayEvent(bz)
                self.EventTable[i][ed] = nil

                --print(CurTime(), "Event completed at " .. i, ed)
                --[[print(CurTime(), "No more events at " .. i .. ", killing")]]
                if table.IsEmpty(v) and i ~= 1 then
                    self.EventTable[i] = nil
                end
            end
        end
    end

    if not sp and SERVER then
        self:SafetyHandlerModule()
        local speed = 1 / self.IronSightTime

        if self:GetIsAiming() and not self:GetIsSprinting() then
            self:SetAimDelta(math.min(self:GetAimDelta() + speed * FrameTime(), 1))
        else
            self:SetAimDelta(math.max(self:GetAimDelta() - speed * FrameTime(), 0))
        end
    end

    self:BipodModule()
    --SprintBehaviour
    self:SprintBehaviour()

    if self.Primary.BurstRounds > 1 and self:GetBurstRounds() < self.Primary.BurstRounds and self:GetBurstRounds() > 0 then
        self:PrimaryAttack()
    end

    if self:GetIsAiming() then
        self:SetNextIdle(0)
    end

    --Idle Anim timer
    if self:GetNextIdle() ~= 0 and self:GetNextIdle() <= CurTime() then
        self:SetNextIdle(0)
        self:PlayIdleAnimation(true)
    end

    --Reloading Timer
    if self:GetMagUpIn() ~= 0 and CurTime() > self:GetMagUpIn() then
        self:ReloadTimed()
        self:SetMagUpIn(0)
    end

    --Shotgun Handling Timer.
    local sg = self:GetShotgunReloading()

    if (sg == 2 or sg == 4) and owner:KeyPressed(IN_ATTACK) then
        self:SetShotgunReloading(sg + 1)
    elseif (sg >= 2) and self:GetReloadingREAL() <= CurTime() then
        self:ReloadInsert((sg >= 4) and true or false)
    end

    --CalcSpray
    if CurTime() > self:GetNextPrimaryFire() + 0.15 then
        self:SetSprayRounds(0)
    end

    --cone
    local target = Lerp(self:GetAimDelta(), self.Cone.Hip, self.Cone.Ads)
    self:SetCone(math.Approach(self:GetCone(), target, (1 / self.Cone.Decrease) * FrameTime()))
    --Heat Handling
    self:DoHeat()
    --Handling Wacky Fungy Timers
    --self:ProcessTimers()
    self:ChaosCustomThink()
end

function SWEP:ChaosCustomThink()
end