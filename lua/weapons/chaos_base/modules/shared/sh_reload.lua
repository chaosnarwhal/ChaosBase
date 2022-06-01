function SWEP:CanReload()
    if CurTime() < self:GetNextPrimaryFire() then return false end
    if self:GetIsReloading() then return false end
    if self:Ammo1() <= 0 then return false end
    if self:Clip1() >= self.Primary.ClipSize then return false end
    if self:GetOwner():KeyDown(IN_USE) then return false end
    if self:GetSafety() then return false end

    return true
end

function SWEP:CanInspect()
    if CurTime() < self:GetNextPrimaryFire() then return false end
    if self:GetIsReloading() then return false end
    if self:GetOwner():KeyDown(IN_USE) then return false end
    if self.IronSightsProgressUnpredicted > 0 then return false end
    return true
end

function SWEP:GetReloadTime()
    local mult = self.ReloadTime
    local anim = self:SelectReloadAnimation()
    if not self.Animations[anim] then return false end
    local full = self:GetAnimKeyTime(anim) * mult
    local magin = self:GetAnimKeyTime(anim, true) * mult

    return {full, magin}
end

function SWEP:Reload()
    if self:Ammo1() <= 0 or self:Clip1() >= self.Primary.ClipSize then
        if (CurTime() > self:GetNextInspectTime()) and self:CanInspect() then
            self:PlayAnimationEZ("inspect", 1, false)
            self:SetNextInspectTime(CurTime() + self:GetAnimKeyTime("inspect"))
        end

        return
    end

    if not self:CanReload() then return end
    self.LastClip1 = self:Clip1()
    local reserve = self:Ammo1()
    reserve = reserve + self:Clip1()

    if self:GetNeedCycle() then
        chamber = 0
    end

    self:SetBurstRounds(0)
    --Shotgun Reloading Handles.
    local shouldshotgunreload = self.ShotgunReload
    if shouldshotgunreload and self:GetShotgunReloading() > 0 then return end
    local mult = self.ReloadTime

    if shouldshotgunreload then
        local anim = "sgreload_start"
        local insertcount = 0
        local empty = self:Clip1() == 0

        if self.Animations.sgreload_start_empty and empty then
            anim = "sgreload_start_empty"
            empty = false

            if (self.Animations.sgreload_start_empty or {}).ForceEmpty == true then
                empty = true
            end

            insertcount = (self.Animations.sgreload_start_empty or {}).RestoreAmmo or 1
        else
            insertcount = (self.Animations.sgreload_start or {}).RestoreAmmo or 0
        end

        local time = self:GetAnimKeyTime(anim)
        local time2 = self:GetAnimKeyTime(anim, true)

        if time2 >= time then
            time2 = 0
        end

        if insertcount > 0 then
            self:SetMagUpCount(insertcount)
            self:SetMagUpIn(CurTime() + time2 * mult)
        end

        self:PlayAnimation(anim, mult, true, 0, true, nil, true)
        self:SetReloading(CurTime() + time * mult)
        self:SetShotgunReloading(empty and 4 or 2)
    else
        local anim = self:SelectReloadAnimation()

        if not self.Animations[anim] then
            print("Invalid animation /" .. anim .. "/")

            return
        end

        self:SetIsReloading(true)
        self:PlayAnimation(anim, mult, true, 0, false, nil, true)
        local reloadtime = self:GetAnimKeyTime(anim, true) * mult
        local reloadtime2 = self:GetAnimKeyTime(anim, false) * mult
        --self:SetNextPrimaryFire(CurTime() + reloadtime2)
        self:SetReloading(CurTime() + reloadtime2)
        self:SetMagUpCount(0)
        self:SetBurstRounds(0)
        self:SetMagUpIn(CurTime() + reloadtime)
    end
end

function SWEP:ReloadTimed()
    -- yeah my function names are COOL and QUIRKY and you can't say a DAMN thing about it.
    self:RestoreAmmo(self:GetMagUpCount() ~= 0 and self:GetMagUpCount())
    self:SetMagUpCount(0)
    self:SetLastLoad(self:Clip1())
    self:SetNthReload(self:GetNthReload() + 1)
    self:SetIsReloading(false)
end

function SWEP:RestoreAmmo(count)
    if self:GetOwner():IsNPC() then return end

    local chamber = math.Clamp(self:Clip1(), 0, 1)
    if self:GetNeedCycle() then
        chamber = 0
    end

    local clip = self:GetCapacity()
    count = count or (clip)
    local reserve = self:Ammo1() or math.huge
    local load = math.Clamp(self:Clip1() + count, 0, reserve)
    load = math.Clamp(load, 0, clip + 1)
    reserve = reserve - load
    self:GetOwner():SetAmmo(reserve, self.Primary.Ammo, true)
    self:SetClip1(load)
end

SWEP.LastClipOutTime = 0

function SWEP:SelectReloadAnimation()
    local ret

    if self.Animations.reload_empty and self:Clip1() == 0 then
        ret = "reload_empty"
    else
        ret = "reload"
    end

    return ret
end

function SWEP:ReloadInsert(empty)
    local total = self:GetCapacity()

    -- if !game.SinglePlayer() and !IsFirstTimePredicted() then return end
    if not empty and not self:GetNeedCycle() then
        total = total + self:GetChamberSize()
    else
        total = total
    end

    local mult = self.ReloadTime

    if self:Clip1() >= total or (self:Ammo1() == 0 or ((self:GetShotgunReloading() == 3 or self:GetShotgunReloading() == 5) and self:Clip1() > 0)) then
        local ret = "sgreload_finish"

        if empty then
            if self.Animations.sgreload_finish_empty then
                ret = "sgreload_finish_empty"
            end

            if self:GetNeedCycle() then
                self:SetNeedCycle(false)
            end
        end

        self:PlayAnimation(ret, mult, true, 0, true, nil, true)
        self:SetReloading(CurTime() + (self:GetAnimKeyTime(ret, true) * mult))
        self:SetShotgunReloading(0)
    else
        local insertcount = 1
        local insertanim = "sgreload_insert"
        local load = self:GetCapacity() + math.min(self:Clip1(), self:GetChamberSize())

        if load - self:Clip1() > self:Ammo1() then
            load = self:Clip1() + self:Ammo1()
        end

        local time = self:GetAnimKeyTime(insertanim, false)
        local time2 = self:GetAnimKeyTime(insertanim, true)

        if time2 >= time then
            time2 = 0
        end

        self:SetMagUpCount(insertcount)
        self:SetMagUpIn(CurTime() + time2 * mult)
        self:SetReloading(CurTime() + time * mult)
        self:PlayAnimation(insertanim, mult, true, 0, true, nil, true)
        self:SetShotgunReloading(empty and 4 or 2)
    end
end

function SWEP:GetCapacity()
    local clip = self.RegularClipSize or self.Primary.ClipSize

    if not self.RegularClipSize then
        self.RegularClipSize = self.Primary.ClipSize
    end

    clip = math.Clamp(math.Round(clip), 0, math.huge)
    self.Primary.ClipSize = clip

    return clip
end

function SWEP:GetChamberSize()
    return self.ChamberSize
end