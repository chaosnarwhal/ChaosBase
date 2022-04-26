AddCSLuaFile()

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

    self._fov = fov
    
    return pos, ang, fov

end