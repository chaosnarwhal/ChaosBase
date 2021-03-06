--WalkBob
SWEP.ti = 0
SWEP.LastCalcBob = 0
SWEP.tiView = 0
SWEP.LastCalcViewBob = 0
local TAU = math.pi * 2
local rateScaleFac = 2
local rate_up = 6 * rateScaleFac
local scale_up = 0.5
local rate_right = 3 * rateScaleFac
local scale_right = -0.5
local rate_forward_view = 3 * rateScaleFac
local scale_forward_view = 0.35
local rate_right_view = 3 * rateScaleFac
local scale_right_view = -1
local rate_p = 6 * rateScaleFac
local scale_p = 3
local rate_y = 3 * rateScaleFac
local scale_y = 3
local rate_r = 3 * rateScaleFac
local scale_r = -6
local pist_rate = 3 * rateScaleFac
local pist_scale = 9
local rate_clamp = 2 * rateScaleFac
local walkIntensitySmooth, breathIntensitySmooth = 0, 0
local walkRate = 160 / 60 * TAU / 1.085 / 2 * rateScaleFac
local walkVec = Vector()
local ownerVelocity, ownerVelocityMod = Vector(), Vector()
local zVelocity = 0
local xVelocity, xVelocitySmooth, rightVec = 0, 0, Vector()
local flatVec = Vector(1, 1, 0)
local WalkPos = Vector()
local WalkPosLagged = Vector()
local gunbob_intensity = 0
SWEP.VMOffsetWalk = Vector(0.5, -0.5, -0.5)
SWEP.footstepTotal = 0
SWEP.footstepTotalTarget = 0
SWEP.bobRateCached = 0
local upVec, riVec, fwVec = Vector(0, 0, 1), Vector(1, 0, 0), Vector(0, 1, 0)

local function l_Lerp(t, a, b)
    if t <= 0 then return a end
    if t >= 1 then return b end

    return a + (b - a) * t
end

function SWEP:ChaosWalkBob(pos, ang, breathIntensity, walkIntensity, rate, ftv)
    if not IsValid(self:GetOwner()) then return end
    rate = math.min(rate or 0.5, rate_clamp)
    gunbob_intensity = 1
    local ea = self:GetOwner():EyeAngles()
    local up = ang:Up()
    local ri = ang:Right()
    local fw = ang:Forward()
    local upLocal = upVec
    local riLocal = riVec
    local fwLocal = fwVec
    local delta = ftv
    local flip_v = self.ViewModelFlip and -1 or 1
    self.bobRateCached = rate
    self.ti = self.ti + delta * rate

    if self.SprintStyle == nil then
        if self.SprintViewModelAngle and self.SprintViewModelAngle.x > 5 then
            self.SprintStyle = 1
        else
            self.SprintStyle = 0
        end
    end

    --Calcs for ViewModel Bobbing.
    walkIntesnsitySmooth = l_Lerp(delta * 10 * rateScaleFac, walkIntensitySmooth, walkIntensity)
    breathIntensitySmooth = l_Lerp(delta * 10 * rateScaleFac, breathIntensitySmooth, breathIntensity)
    --walkVec = LerpVector(walkIntesnsitySmooth, vector_origin, self.VMOffsetWalk)
    ownerVelocity = self:GetOwner():GetVelocity()
    zVelocity = ownerVelocity.z
    zVelocitySmooth = l_Lerp(delta * 7 * rateScaleFac, zVelocity, zVelocity)
    ownerVelocityMod = ownerVelocity * flatVec
    ownerVelocityMod:Normalize()
    rightVec = ea:Right() * flatVec
    rightVec:Normalize()
    xVelocity = ownerVelocity:Length2D() * ownerVelocityMod:Dot(rightVec)
    xVelocitySmooth = l_Lerp(delta * 5 * rateScaleFac, xVelocitySmooth, xVelocity)
    --Mults
    breathIntensity = breathIntensitySmooth * gunbob_intensity * 1.5
    walkIntesnsity = walkIntesnsitySmooth * gunbob_intensity * 1.5
    --Breathing/Walking while ADS
    local breatheMult2 = math.Clamp(self.IronSightsProgressUnpredicted, 0, 1)
    local breatheMult1 = 1 - breatheMult2
    pos:Add(riLocal * (math.sin(self.ti * walkRate) - math.cos(self.ti * walkRate)) * flip_v * breathIntensity * 0.2 * breatheMult1)
    pos:Add(upLocal * math.sin(self.ti * walkRate) * breathIntensity * 0.5 * breatheMult1)
    pos:Add(riLocal * math.cos(self.ti * walkRate / 2) * flip_v * breathIntensity * 0.6 * breatheMult2 * (1 - self.IronSightsProgressUnpredicted))
    --WalkAnims
    self.WalkTI = (self.walkTI or 0) + delta * 120 / 60 * self:GetOwner():GetVelocity():Length2D() / self:GetOwner():GetWalkSpeed()
    WalkPos.x = l_Lerp(delta * 5 * rateScaleFac, WalkPos.x, -math.sin(self.ti * walkRate * 0.5) * gunbob_intensity * walkIntesnsity)
    WalkPos.y = l_Lerp(delta * 5 * rateScaleFac, WalkPos.y, math.sin(self.ti * walkRate) / 1.5 * gunbob_intensity * walkIntesnsity)
    WalkPosLagged.x = l_Lerp(delta * 5 * rateScaleFac, WalkPosLagged.x, -math.sin((self.ti * walkRate * 0.5) + math.pi / 3) * gunbob_intensity * walkIntesnsity)
    WalkPosLagged.y = l_Lerp(delta * 5 * rateScaleFac, WalkPosLagged.y, math.sin(self.ti * walkRate + math.pi / 3) / 1.5 * gunbob_intensity * walkIntesnsity)
    pos:Add(WalkPos.x * delta * riLocal)
    pos:Add(WalkPos.y * delta * upLocal)
    ang:RotateAroundAxis(ri, -WalkPosLagged.y)
    ang:RotateAroundAxis(up, WalkPosLagged.x)
    ang:RotateAroundAxis(fw, WalkPos.x)
    --Constant Offsets
    pos:Add(riLocal * walkVec.x * flip_v)
    pos:Add(fwLocal * walkVec.y)
    pos:Add(upLocal * walkVec.z)
    --Rolling with horizontal motion
    local xVelocityClamped = xVelocitySmooth

    if math.abs(xVelocityClamped) > 200 then
        local sign = (xVelocityClamped < 0) and -1 or 1
        xVelocityClamped = (math.sqrt((math.abs(xVelocityClamped) - 200) / 50) * 50 + 200) * sign
    end

    ang:RotateAroundAxis(ang:Up(), xVelocityClamped * 0.04 * (1 - self.IronSightsProgressUnpredicted) * (1 - self.SprintProgressUnpredicted))

    return pos, ang
end

function SWEP:SprintBob(pos, ang, intensity, origPos, origAng)
    if not IsValid(self:GetOwner()) or not gunbob_intensity then return pos, ang end
    if self.AnimatedSprint then return pos, ang end
    local flip_v = self.ViewModelFlip and -1 or 1
    local eyeAngles = self:GetOwner():EyeAngles()
    local localUp = ang:Up()
    local localRight = ang:Right()
    local localForward = ang:Forward()
    intensity = intensity * gunbob_intensity * 1.5
    gunbob_intensity = 1

    if self:GetIsHighTier() then
        intensity = intensity * 0.2
    end

    if intensity > 0.005 then
        if self.SprintStyle == 1 then
            local intensity3 = math.max(intensity - 0.3, 0) / (1 - 0.3)
            ang:RotateAroundAxis(ang:Up(), math.sin(self.ti * pist_rate) * pist_scale * intensity3 * 0.33 * 0.75)
            ang:RotateAroundAxis(ang:Forward(), math.sin(self.ti * pist_rate) * pist_scale * intensity3 * 0.33 * -0.25)
            pos:Add(ang:Forward() * math.sin(self.ti * pist_rate * 2 + math.pi) * pist_scale * -0.1 * intensity3 * 0.4)
            pos:Add(ang:Right() * math.sin(self.ti * pist_rate) * pist_scale * 0.15 * intensity3 * 0.33 * 0.2)
        else
            pos:Add(localUp * math.sin(self.ti * rate_up + math.pi) * scale_up * intensity * 0.33)
            pos:Add(localRight * math.sin(self.ti * rate_right) * scale_right * intensity * flip_v * 0.33)
            pos:Add(eyeAngles:Forward() * math.max(math.sin(self.ti * rate_forward_view), 0) * scale_forward_view * intensity * 0.33)
            pos:Add(eyeAngles:Right() * math.sin(self.ti * rate_right_view) * scale_right_view * intensity * flip_v * 0.33)
            ang:RotateAroundAxis(localRight, math.sin(self.ti * rate_p + math.pi) * scale_p * intensity * 0.33)
            pos:Add(-localUp * math.sin(self.ti * rate_p + math.pi) * scale_p * 0.1 * intensity * 0.33)
            ang:RotateAroundAxis(localUp, math.sin(self.ti * rate_y) * scale_y * intensity * flip_v * 0.33)
            pos:Add(localRight * math.sin(self.ti * rate_y) * scale_y * 0.1 * intensity * flip_v * 0.33)
            ang:RotateAroundAxis(localForward, math.sin(self.ti * rate_r) * scale_r * intensity * flip_v * 0.33)
            pos:Add(localRight * math.sin(self.ti * rate_r) * scale_r * 0.05 * intensity * flip_v * 0.33)
            pos:Add(localUp * math.sin(self.ti * rate_r) * scale_r * 0.1 * intensity * 0.33)
        end
    end

    return pos, ang
end

local fac, bscale

function SWEP:UpdateEngineBob()
    local isp = self.IronSightsProgressUnpredicted or self:GetIronSightsProgress()
    local wpr = 1
    local spr = self.SprintProgressUnpredicted
    fac = 0.5 * ((1 - isp) * 0.85 + 0.15)
    bscale = fac

    if spr > 0.005 then
        bscale = bscale * l_Lerp(spr, 1, self.SprintBobMult)
    elseif wpr > 0.005 then
        bscale = bscale * l_Lerp(wpr, 1, l_Lerp(isp, self.WalkBobMult, self.WalkBobMult_Iron or self.WalkBobMult))
    end

    self.BobScale = bscale
    self.SwayScale = fac
end