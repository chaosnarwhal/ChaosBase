AddCSLuaFile()

SWEP.ViewHolProg = 0
SWEP.AttachmentViewOffset = Angle(0, 0, 0)
SWEP.ProceduralViewOffset = Angle(0, 0, 0)
--local procedural_fadeout = 0.6
local procedural_vellimit = 5
local l_Lerp = Lerp
local l_mathApproach = math.Approach
local l_mathClamp = math.Clamp
local viewbob_animated = 1
local oldangtmp
local mzang_fixed
local mzang_fixed_last
local mzang_velocity = Angle()
local progress = 0
local targint, targbool

function SWEP:GetCameraAttachment()
    local vm = self:GetOwner():GetViewModel()
    return vm:GetAttachment(vm:LookupAttachment("camera"))
end

function SWEP:SafeLerp(rate, current, target)
    if (math.abs(current - target) < 0.001) then
        return target
    end

    return Lerp(rate, current, target)
end

function SWEP:VectorAddAndMul(current, add, mul)
    current.x = current.x + (add.x * mul)
    current.y = current.y + (add.y * mul)
    current.z = current.z + (add.z * mul)
end

function SWEP:SafeLerpVector(rate, current, target)
    current.x = self:SafeLerp(rate, current.x, target.x)
    current.y = self:SafeLerp(rate, current.y, target.y)
    current.z = self:SafeLerp(rate, current.z, target.z)
end

function SWEP:SafeLerpAngle(rate, current, target)
    current.p = self:SafeLerp(rate, current.p, target.p)
    current.y = self:SafeLerp(rate, current.y, target.y)
    current.r = self:SafeLerp(rate, current.r, target.r)
end

SWEP.ZeroVector = Vector(0, 0, 0)
SWEP.ZeroAngle = Angle(0, 0, 0)

function SWEP:CalcView(ply, pos, ang, fov)
    local vm = self:GetOwner():GetViewModel()

    if !IsValid(vm) then
        return pos, ang, fov
    end

    ang.p = math.Clamp(ang.p, -89, 90)

    local rpm = math.Clamp(self.Primary.RPM / 10, 55, 90)
    local rate = 60 / (rpm * 10)
    rate = 20 - (rate * 100)
    self.Camera.Shake = self:SafeLerp(rate * FrameTime(), self.Camera.Shake, 0)

    self._eyeang = ang * 1
    
    local camAtt = self:GetCameraAttachment()

    if (camAtt != nil) then
        local cameraAttAngles = camAtt.Ang
        cameraAttAngles:Sub(self:GetOwner():GetViewModel():GetAngles())
        
        ang:Add(cameraAttAngles)
    end

    local pitch = (math.cos(CurTime() * rpm) * (self.Camera.Shake * 0.5)) * self:SafeLerp(self:GetAimDelta(), 1, 0.4)

    local recoilAndShakeAngles = Angle(pitch, 0, math.sin(CurTime() * rpm))
    recoilAndShakeAngles:Mul(self.Camera.Shake)

    ang:Add(recoilAndShakeAngles)

    local vpAngles = self:GetOwner():GetViewPunchAngles()
    vpAngles:Mul(self:SafeLerp(self:GetAimDelta(), 0.2, 0.01))

    ang:Sub(vpAngles)

    --breathing
    self.Camera.LerpBreathing = LerpAngle(10 * FrameTime(), self.Camera.LerpBreathing, self:GetBreathingAngle())

    ang:Add(self.Camera.LerpBreathing)
    --end breathing

    self:VectorAddAndMul(pos, ang:Forward(), -self.Camera.Shake)
    
    self.Camera.Fov = self:SafeLerp(10 * FrameTime(), self.Camera.Fov, self:GetAimDelta())

    local diff = 0

    if (self:GetIsReloading()) then
        diff = (1 - self.Zoom.FovMultiplier) * 0.25
    end

    self.Camera.LerpReloadFov = self:SafeLerp(4 * FrameTime(), self.Camera.LerpReloadFov, diff)

    local fovMultiplier = self:SafeLerp(self.Camera.Fov, 1, self.Scope.ScopeMagnification or self.Scope.Magnification)

    fov = (fov * fovMultiplier) + (self.Camera.Shake * 1.5)

    --VIEWMODEL

    self:CalcViewModel(self:GetOwner():GetViewModel(), pos, ang)

    if not ang then return end
    if ply ~= LocalPlayer() then return end
    local vm = ply:GetViewModel()

    local ftv = math.max(FrameTime(), 0.001)
    local viewbobintensity = self.ViewbobIntensity * 0.5
    local holprog = self:GetIsHolstering() and 1 or 0
    self.ViewHolProg = math.Approach(self.ViewHolProg, holprog, ftv / 5)

    oldangtmp = ang * 1

    if self.CameraAngCache and viewbob_animated then
        self.CameraAttachmentScale = self.CameraAttachmentScale or 1
        ang:RotateAroundAxis(ang:Right(), (self.CameraAngCache.p + self.CameraOffset.p) * viewbobintensity * -self.CameraAttachmentScale)
        ang:RotateAroundAxis(ang:Up(), (self.CameraAngCache.y + self.CameraOffset.y) * viewbobintensity * self.CameraAttachmentScale)
        ang:RotateAroundAxis(ang:Forward(), (self.CameraAngCache.r + self.CameraOffset.r) * viewbobintensity * self.CameraAttachmentScale)
    else
        local vb_r, irelaod
        ireload = self:GetIsReloading() or self:GetShotgunReloading()
        vb_r = viewbob_animated
        targbool = (vb_r and ireload)
        targint = targbool and 1 or 0

        if ireload then
            targint = math.min(targint, 1 - math.pow(math.max(vm:GetCycle() - 0.5, 0) * 2, 2))
        end

        progress = self:SafeLerp(ftv * 15, progress, targint)
        local att = self.MuzzleAttachmentRaw or vm:LookupAttachment(self.MuzzleAttachment)

        if not att then
            att = 1
        end

        local angpos = vm:GetAttachment(att)

        if angpos then
            mzang_fixed = vm:WorldToLocalAngles(angpos.Ang)
            mzang_fixed:Normalize()
        end

        self.ProceduralViewOffset:Normalize()

        if mzang_fixed_last then
            local delta = mzang_fixed - mzang_fixed_last
            delta:Normalize()
            mzang_velocity = mzang_velocity + delta * (2 * (1 - self.ViewHolProg))
            mzang_velocity.p = l_mathApproach(mzang_velocity.p, -self.ProceduralViewOffset.p * 2, ftv * 20)
            mzang_velocity.p = l_mathClamp(mzang_velocity.p, -procedural_vellimit, procedural_vellimit)
            self.ProceduralViewOffset.p = self.ProceduralViewOffset.p + mzang_velocity.p * ftv
            self.ProceduralViewOffset.p = l_mathClamp(self.ProceduralViewOffset.p, -90, 90)
            mzang_velocity.y = l_mathApproach(mzang_velocity.y, -self.ProceduralViewOffset.y * 2, ftv * 20)
            mzang_velocity.y = l_mathClamp(mzang_velocity.y, -procedural_vellimit, procedural_vellimit)
            self.ProceduralViewOffset.y = self.ProceduralViewOffset.y + mzang_velocity.y * ftv
            self.ProceduralViewOffset.y = l_mathClamp(self.ProceduralViewOffset.y, -90, 90)
            mzang_velocity.r = l_mathApproach(mzang_velocity.r, -self.ProceduralViewOffset.r * 2, ftv * 20)
            mzang_velocity.r = l_mathClamp(mzang_velocity.r, -procedural_vellimit, procedural_vellimit)
            self.ProceduralViewOffset.r = self.ProceduralViewOffset.r + mzang_velocity.r * ftv
            self.ProceduralViewOffset.r = l_mathClamp(self.ProceduralViewOffset.r, -90, 90)
        end

        self.ProceduralViewOffset.p = l_mathApproach(self.ProceduralViewOffset.p, 0, (1 - progress) * ftv * -self.ProceduralViewOffset.p)
        self.ProceduralViewOffset.y = l_mathApproach(self.ProceduralViewOffset.y, 0, (1 - progress) * ftv * -self.ProceduralViewOffset.y)
        self.ProceduralViewOffset.r = l_mathApproach(self.ProceduralViewOffset.r, 0, (1 - progress) * ftv * -self.ProceduralViewOffset.r)
        mzang_fixed_last = mzang_fixed
        local ints = self.ViewbobIntensity * 1.25
        ang:RotateAroundAxis(ang:Right(), l_Lerp(progress, 0, -self.ProceduralViewOffset.p) * ints)
        ang:RotateAroundAxis(ang:Up(), l_Lerp(progress, 0, self.ProceduralViewOffset.y / 2) * ints)
        ang:RotateAroundAxis(ang:Forward(), Lerp(progress, 0, self.ProceduralViewOffset.r / 3) * ints)
    end
    self._fov = fov
    return pos, LerpAngle(math.pow(self.ViewHolProg, 2), ang, oldangtmp), fov

end