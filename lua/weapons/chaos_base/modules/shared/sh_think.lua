AddCSLuaFile()

function SWEP:Think()
end

function SWEP:ChaosPlayerThink(plyv, is_working_out_prediction_errors)
    self:ChaosThink2(is_working_out_prediction_errors)
end

function SWEP:ChaosPlayerThinkCL(plyv)
    --IronSight Pred Handling.
    local ft = FrameTime()
    local is = self:GetIsAiming()
    local ist = is and 1 or 0
    local speed = 1 / self.IronSightTime
    self.IronSightsProgressUnpredicted = math.Approach(self.IronSightsProgressUnpredicted or 0, ist, (ist - (self.IronSightsProgressUnpredicted or 0)) * ft * speed * 1.2)
    --Safety Pred handling.
    local issafety = self:GetSafety()
    local issafetyt = issafety and 1 or 0
    self.SafetyProgressUnpredicted = math.Approach(self.SafetyProgressUnpredicted or 0, issafetyt, (issafetyt - (self.SafetyProgressUnpredicted or 0)) * ft * speed * 1.2)
end

function SWEP:ChaosThink2(is_working_out_prediction_errors)
    local ct = CurTime()
    local owner = self:GetOwner()

    if not is_working_out_prediction_errors and CLIENT then
        self.CurTimePredictionAdvance = ct - UnPredictedCurTime()
    end

    for i, v in ipairs(self.EventTable) do
        for ed, bz in pairs(v) do
            if ed <= CurTime() then
                self:PlayEvent(bz)
                self.EventTable[i][ed] = nil
                --print(CurTime(), "Event completed at " .. i, ed)
                if table.IsEmpty(v) and i != 1 then self.EventTable[i] = nil --[[print(CurTime(), "No more events at " .. i .. ", killing")]] end
            end
        end
    end

    --SprintBehaviour
    self:SprintBehaviour()

    --Aim Behaviour Handles to pass through values to CL/Server
    if not sp or SERVER then
        self:AimBehaviourModule()
        self:SafetyHandlerModule()
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
    self:SetCone(math.Approach(self:GetCone(), target, 4 * FrameTime()))
end