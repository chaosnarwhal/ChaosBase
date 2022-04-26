AddCSLuaFile()

--[[ 
Function Name: SelectAnimation
Syntax: self:SelectAnimation(anim). 
Returns: Returns the selected animation.
Notes: Selects compound animations when checks are met.
Purpose: SWEP Animation.
]]
--
function SWEP:SelectAnimation(anim)
    if self:GetNWState() == ChaosBase.STATE_SPRINT and self.Animations[anim .. "_sprint"] then
        anim = anim .. "_sprint"
    end

    if self:Clip1() == 0 and self.Animations[anim .. "_empty"] then
        anim = anim .. "_empty"
    end

    if self:GetNWState() == ChaosBase.STATE_WALK and self.Animations[anim .. "_walk"] then
        anim = anim .. "_walk"
    end

    if not self.Animations[anim] then return end

    return anim
end

SWEP.LastAnimStartTime = 0
SWEP.LastAnimFinishTime = 0

--[[ 
Function Name: PlayAnimationEZ,
Syntax: self:PlayAnimationEZ(key, mult, ignorereload).
Returns: Returns animation to be played with preset values.
Notes: quick play animation system.
Purpose: SWEP Animation.
]]
--
function SWEP:PlayAnimationEZ(key, mult, ignorereload)
    return self:PlayAnimation(key, mult, true, 0, false, fdalse, ignorereload, false)
end

--[[ 
Function Name: PlayAnimation,
Syntax: self:PlayAnimation(key, mult, pred, startfrom, tt, skipholster, ignorereload, absolute).
Returns: nothing.
Notes: Plays animation and sends the animation to clients for NW purposes and prediction purposes.
Purpose: SWEP Animation.
]]
--
function SWEP:PlayAnimation(key, mult, pred, startfrom, tt, skipholster, ignorereload, absolute)
    mult = mult or 1
    pred = pred or false
    startfrom = startfrom or 0
    tt = tt or false
    ignorereload = ignorereload or false
    absolute = absolute or false
    
    if not key then return end
    local ct = CurTime()
    if self:GetReloading() and not ignorereload then return end
    local anim = self.Animations[key]
    if not anim then return end
    if not self:GetOwner() then return end
    if not self:GetOwner().GetViewModel then return end
    local vm = self:GetOwner():GetViewModel()
    if not vm then return end
    if not IsValid(vm) then return end
    local seq = anim.Source

    if istable(seq) then
        seq["BaseClass"] = nil
        seq = seq[math.Round(util.SharedRandom("randomseq" .. CurTime(), 1, #seq))]
    end

    if isstring(seq) then
        seq = vm:LookupSequence(seq)
    end

    local time = absolute and 1 or self:GetAnimKeyTime(key)
    local ttime = (time * mult) - startfrom
    if startfrom > (time * mult) then return end

    if tt then
        self:SetNextPrimaryFire(ct + ((anim.MinProgress or time) * mult) - startfrom)
    end

    if anim.TPAnim then
        local aseq = self:GetOwner():SelectWeightedSequence(anim.TPAnim)

        if aseq then
            self:GetOwner():AddVCDSequenceToGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD, aseq, anim.TPAnimStartTime or 0, true)

            if not game.SinglePlayer() and SERVER then
                net.Start("chaosbase_networktpanim")
                net.WriteEntity(self:GetOwner())
                net.WriteUInt(aseq, 16)
                net.WriteFloat(anim.TPAnimStartTime or 0)
                net.SendPVS(self:GetOwner():GetPos())
            end
        end
    end

    if not (game.SinglePlayer() and CLIENT) then
    	self.EventTable = {}
    	self:PlaySoundTable(anim.SoundTable or {}, 1 / mult, startfrom)
    end

    if seq then
        vm:SendViewModelMatchingSequence(seq)
        local dur = vm:SequenceDuration()
        vm:SetPlaybackRate(math.Clamp(dur / (ttime + startfrom), -4, 12))
        self.LastAnimStartTime = ct
        self.LastAnimFinishTime = ct + dur
        self.LastAnimKey = key
    end

    self:SetNextIdle(CurTime() + ttime)
end

--[[ 
Function Name: PlayIdleAnimation.
Syntax: self:PlayIdleAnimation(pred).
Returns: nothing.
Notes: Idle anim Think.
Purpose: SWEP Animation.
]]
--
function SWEP:PlayIdleAnimation(pred)
    local ianim = self:SelectAnimation("idle")
    if self:GetIsAiming() then return end

    if (self:Clip1() == 0 or self:GetNeedCycle()) and self.Animations.idle_empty then
        ianim = ianim or "idle_empty"
    else
        ianim = ianim or "idle"
    end

    if self.LastAnimKey ~= ianim then
        ianim = ianim
    end

    self:PlayAnimation(ianim, 1, pred, nil, nil, nil, true)
end

--[[ 
Function Name: GetAnimKeyTime.
Syntax: self:GetAnimKeyTime(key, min).
Returns: returns anim time.
Notes: Get animation sequence duration.
Purpose: SWEP Animation.
]]
--
function SWEP:GetAnimKeyTime(key, min)
    if not self:GetOwner() then return 1 end
    local anim = self.Animations[key]
    if not anim then return 1 end
    if self:GetOwner():IsNPC() then return anim.Time or 1 end
    local vm = self:GetOwner():GetViewModel()
    local t = anim.Time

    if not t then
        local tseq = anim.Source

        if istable(tseq) then
            tseq["BaseClass"] = nil --Lua Inheritance
            tseq = tseq[1]
        end

        if not tseq then return 1 end
        tseq = vm:LookupSequence(tseq)
        t = vm:SequenceDuration(tseq) or 1
    end

    if min and anim.MinProgress then
        t = anim.MinProgress
    end

    if anim.Mult then
        t = t * anim.Mult
    end

    return t
end

function SWEP:PlaySoundTable(soundtable, mult, start)
    --if CLIENT and game.SinglePlayer() then return end

    local owner = self:GetOwner()

    start = start or 0
    mult  = 1 / (mult or 1)

    for _, v in pairs(soundtable) do
        if table.IsEmpty(v) then continue end

        local ttime
        if v.t then
            ttime = (v.t * mult) - start
        else
            continue
        end
        if ttime < 0 then continue end
        if !(IsValid(self) and IsValid(owner)) then continue end

        local jhon = CurTime() + ttime

        --[[if game.SinglePlayer() then
            if SERVER then
                net.Start("arccw_networksound")
                v.ntttime = ttime
                net.WriteTable(v)
                net.WriteEntity(self)
                net.Send(owner)
            end
        end]]

        -- i may go fucking insane
        if !self.EventTable[1] then self.EventTable[1] = {} end

        for i, de in ipairs(self.EventTable) do
            if de[jhon] then
                if !self.EventTable[i + 1] then
                    --[[print(CurTime(), "Occupier at " .. i .. ", creating " .. i+1)]]
                    self.EventTable[i + 1] = {}
                    continue
                end
            else
                self.EventTable[i][jhon] = v
                --print(CurTime(), "Clean at " .. i)
            end
        end
    end
end

function SWEP:PlayEvent(v)
    if !v or !istable(v) then error("no event to play") end
    if v.e and IsFirstTimePredicted() then
        DoShell(self, v)
    end

    if v.s then
        if v.s_km then
            self:StopSound(v.s)
        end
        self:ChaosEmitSound(v.s, v.l, v.p, v.v, v.c or CHAN_AUTO)
    end

    if v.bg then
        self:SetBodygroupTr(v.ind or 0, v.bg)
    end

    if v.pp then
        local vm = self:GetOwner():GetViewModel()

        vm:SetPoseParameter(pp, ppv)
    end
end


if CLIENT then
    net.Receive("chaosbase_networktpanim", function()
        local ent = net.ReadEntity()
        local aseq = net.ReadUInt(16)
        local starttime = net.ReadFloat()

        if ent ~= LocalPlayer() then
            ent:AddVCDSequenceToGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD, aseq, starttime, true)
        end
    end)
end

function SWEP:QueueAnimation()
end

function SWEP:NextAnimation()
end