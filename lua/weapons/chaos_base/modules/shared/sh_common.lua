AddCSLuaFile()

function SWEP:TableRandom(table)
    return table[math.random(#table)]
end

function SWEP:ChaosEmitSound(fsound, level, pitch, vol, chan, useWorld)
    fsound = fsound or ""

    if istable(fsound) then
        fsound = self:TableRandom(fsound)
    end

    if fsound and fsound ~= "" then
        if useWorld then
            sound.Play(fsound, self:GetOwner():GetShootPos(), level, pitch, vol)
        else
            self:EmitSound(fsound, level, pitch, vol, chan or CHAN_AUTO)
        end
    end
end

--[[
Function Name:  GetMuzzlePos
Syntax: self:GetMuzzlePos( hacky workaround that doesn't work anyways ).
Returns:   The AngPos for the muzzle attachment.
Notes:  Defaults to the first attachment, and uses GetFPMuzzleAttachment
Purpose:  Utility
]]
--
local fp

function SWEP:GetMuzzleAttachment()
    local vmod = self.OwnerViewModel
    local att = math.max(1, self.MuzzleAttachmentRaw or (sp and vmod or self):LookupAttachment(self.MuzzleAttachment))

    return att
end

function SWEP:GetMuzzlePos(ignorepos)
    fp = self:IsFirstPerson()
    local vm = self.OwnerViewModel

    if not IsValid(vm) then
        vm = self
    end

    -- Avoid returning strings inside MuzzleAttachmentMod, since this would decrease performance
    -- Better call :UpdateMuzzleAttachment() or return number in MuzzleAttachmentMod
    local obj = self.MuzzleAttachmentRaw or vm:LookupAttachment(self.MuzzleAttachment)

    if type(obj) == "string" then
        obj = tonumber(obj) or vm:LookupAttachment(obj)
    end

    local muzzlepos
    obj = math.Clamp(obj or 1, 1, 128)

    if fp then
        muzzlepos = vm:GetAttachment(obj)
    else
        muzzlepos = self:GetAttachment(obj)
    end

    return muzzlepos
end

function SWEP:UpdateMuzzleAttachment()
    if not self:VMIV() then return end
    local vm = self.OwnerViewModel
    if not IsValid(vm) then return end
    self.MuzzleAttachmentRaw = nil

    if not self.MuzzleAttachmentRaw and self.MuzzleAttachment then
        self.MuzzleAttachmentRaw = vm:LookupAttachment(self.MuzzleAttachment)

        if not self.MuzzleAttachmentRaw or self.MuzzleAttachmentRaw <= 0 then
            self.MuzzleAttachmentRaw = 1
        end
    end
end

--[[
Function Name:  IsFirstPerson
Syntax: self:IsFirstPerson().
Returns:   Is the owner in first person.
Notes:  Broken in singplayer because gary.
Purpose:  Utility
]]--
function SWEP:IsFirstPerson()
    if not IsValid(self) or not IsValid(self:GetOwner()) then return false end
    if self:GetOwner():IsNPC() then return false end
    if CLIENT and (not game.SinglePlayer()) and self:GetOwner() ~= GetViewEntity() then return false end
    if self:GetOwner().ShouldDrawLocalPlayer and self:GetOwner():ShouldDrawLocalPlayer() then return false end
    if LocalPlayer and hook.Call("ShouldDrawLocalPlayer", GAMEMODE, self:GetOwner()) then return false end

    return true
end

function ChaosBase.Cubic(t)
    return -2 * t * t * t + 3 * t * t
end


--[[
Function Name:  Sound Handling
Purpose:  Utility
]]--
function SWEP:TableRandom(table)
    return table[math.random(#table)]
end

function SWEP:ChaosEmitSound(fsound, level, pitch, vol, chan, useWorld)
    fsound = fsound

    if istable(fsound) then fsound = self:TableRandom(fsound) end

    if fsound and fsound != "" then
        if useWorld then
            sound.Play(fsound, self:GetOwner():GetShootPos(), level, pitch, vol)
        else
            self:EmitSound(fsound, level, pitch, vol, chan or CHAN_AUTO)
        end
    end
end

--[[
Function Name:  HoldTypeHandling
Purpose:  Utility
]]--

function SWEP:HoldTypeHandler()
    if self:GetSafety() then
        self:SetHoldType(self.HoldtypeHolstered)
        return
    end

    if self:GetIsAiming() then
        self:SetHoldType(self.HoldtypeSights)
    elseif self:GetIsSprinting() then
        if self.AllowSprintShoot then
            self:SetHoldType(self.HoldtypeSprintShoot or self.HoldtypeActive)
        else
            self:SetHoldType(self.HoldtypeHolstered)
        end
    else
        self:SetHoldType(self.HoldtypeActive)
    end

end