
AddCSLuaFile()
local Vector = Vector
local Angle = Angle
local math = math
local LerpVector = LerpVector

local TAU = math.pi * 2
local rateScaleFac = 2
local walkIntensitySmooth, breathIntensitySmooth = 0, 0
local walkRate = 160 / 60 * TAU / 1.085 / 2 * rateScaleFac
local walkVec = Vector()
local ownerVelocity, ownerVelocityMod = Vector(), Vector()
local zVelocity, zVelocitySmooth = 0,0
local xVelocity, xVelocitySmooth, rightVec = 0, 0, Vector()
local flatVec = Vector(1,1,0)

--[[ 
Function Name:  GetViewModelPosition
Syntax: self:GetViewModelPosition(pos, ang ).
Returns:  New position and angle.
Notes:  This is used for calculating the swep viewmodel position.  However, don't put per-frame logic in this.  Instead do that in PlayerThinkClientFrame
Purpose:  Main SWEP function
]]
--
local chaosbase_vmoffset_x = GetConVar("chaosbase_vmoffset_x")
local chaosbase_vmoffset_y = GetConVar("chaosbase_vmoffset_y")
local chaosbase_vmoffset_z = GetConVar("chaosbase_vmoffset_z")
local chaosbase_flip_cv = GetConVar("chaosbase_vmflip")
local cv_fov = GetConVar("fov_desired")
local fovmod_add = GetConVar("chaosbase_vm_offset_fov")
local fovmod_mult = GetConVar("chaosbase_vm_multiplier_fov")
SWEP.OldPos = Vector(0, 0, 0)
SWEP.OldAng = Angle(0, 0, 0)
SWEP.CrouchVector = Vector(-1, -1, -1)

function SWEP:GetViewModelPosition(opos, oang, ...)
    if not self.pos_cached then return opos, oang end

    local npos, nang = opos * 1, oang * 1

    nang:RotateAroundAxis(nang:Right(), self.ang_cached.p)
    nang:RotateAroundAxis(nang:Up(), self.ang_cached.r)
    nang:RotateAroundAxis(nang:Forward(), self.ang_cached.y)

    npos:Add(nang:Right() * self.pos_cached.x)
    npos:Add(nang:Forward() * self.pos_cached.y)
    npos:Add(nang:Up() * self.pos_cached.z)

    npos, nang = self:SprintBob(npos, nang, Lerp(self.SprintProgressUnpredicted, 0, self.SprintBobMult))

    if not pos or not ang then return npos, nang end
    local ofpos, ofang = WorldToLocal(npos, nang, opos, oang)

    self.OldPos = npos
    self.OldAng = nang

    local AimDelta = self.IronSightsProgressUnpredicted

    if AimDelta > 0.005 then
        local _opos, _oang = opos * 1, oang * 1
        --Rev base VM Offsets.
        local right, up, fwd = _oang:Right(), _oang:Up(), _oang:Forward()
        _opos = _opos - ofpos.y * right + ofpos.x * fwd + ofpos.z * up
        _oang:RotateAroundAxis(fwd, ofang.r)
        _oang:RotateAroundAxis(right, -ofang.p)
        _oang:RotateAroundAxis(up, ofang.y)
        --Sights Offsets.
        _oang:RotateAroundAxis(_oang:Forward(), -ang.r)
        _oang:RotateAroundAxis(_oang:Right(), ang.p)
        _oang:RotateAroundAxis(_oang:Up(), -ang.y)
        right, up, fwd = _oang:Right(), _oang:Up(), _oang:Forward()
        _opos = _opos - pos.x * fwd + pos.y * right - pos.z * up
        self.OldPos = LerpVector(AimDelta, npos, _opos)
        self.OldAng = LerpVector(AimDelta, nang, _oang)
    end

    return self.OldPos, self.OldAng
end

--[[ 
Function Name:  CalculateViewModelOffset
Syntax: CalculateViewModelOffset(delta)
Returns:  Calculates Viewmodel offsets from VM settings from player and adds it to base VM offsets in Shared Weapon lua.
Purpose:  Utility function / Animation
]]
--
function SWEP:CalculateViewModelOffset(delta)
    local target_pos, target_ang
    --IronSights Offset
    local additivePos = self.AdditiveViewModelPosition

    local a,b,SprintShoot = self:IsHighTier()

    if additivePos then
        target_pos, target_ang = Vector(), Vector()
    else
        target_pos = self.ViewModelPosition
        target_ang = self.ViewModelAngle
    end

    local AimDelta = self.IronSightsProgressUnpredicted
    local IronSightsPosition = self.IronSightsPos
    local IronSightsAngle = self.IronSightsAng

    if AimDelta > 0.002 then
        self:SafeLerpVector(AimDelta, target_pos, IronSightsPosition)
        self:SafeLerpVector(AimDelta, target_ang, IronSightsAngle)
    end

    --Safety Offset
    local SafetyDelta = self.SafetyProgressUnpredicted
    local SafetyPos = self.SafetyPos
    local SafetyAng = self.SafetyAng

    if SafetyDelta > 0.005 then
        self:SafeLerpVector(SafetyDelta, target_pos, SafetyPos)
        self:SafeLerpVector(SafetyDelta, target_ang, SafetyAng)
    end

    --Sprint Offset
    local SprintDelta = self.SprintProgressUnpredicted
    local SprintPos = self.RunPos
    local SprintAng = self.RunAng


    if SprintDelta > 0.005 and self.SafetyProgressUnpredicted < 1 and !self:GetIsReloading() and not SprintShoot then
        if self.AnimatedSprint then return end
        self:SafeLerpVector(self.SprintProgressUnpredicted, target_pos, SprintPos)
        self:SafeLerpVector(self.SprintProgressUnpredicted, target_ang, SprintAng)
    end

    if additivePos then
        target_pos:Add(self.ViewModelPosition)
        target_ang:Add(self.ViewModelAngle)
    end

    target_pos.x = target_pos.x + chaosbase_vmoffset_x:GetFloat() * (1 - AimDelta)
    target_pos.y = target_pos.y + chaosbase_vmoffset_y:GetFloat() * (1 - AimDelta)
    target_pos.z = target_pos.z + chaosbase_vmoffset_z:GetFloat() * (1 - AimDelta)

    local intensityWalk = math.min(self:GetOwner():GetVelocity():Length2D() / self:GetOwner():GetWalkSpeed(), 1) * self:SafeLerp(AimDelta, self.WalkBobMult, self.WalkBobMult_Iron or self.WalkBobMult) * 0.5
    local intensityBreath = self:SafeLerp(AimDelta, self.BreathScale, intensityWalk)
    intensityWalk = (1 - AimDelta) * intensityWalk
    local intensityRun = self:SafeLerp(self.SprintProgressUnpredicted, 0, self.SprintBobMult)
    local velocity = math.max(self:GetOwner():GetVelocity():Length2D() - self:GetOwner():GetVelocity().z * 0.5, 0)
    local rate = math.min(math.max(0.15, math.sqrt(velocity / self:GetOwner():GetRunSpeed()) * 1.75), self:GetIsSprinting() and 5 or 3)

    self.pos_cached, self.ang_cached = self:ChaosWalkBob(
        target_pos,
        Angle(target_ang.x, target_ang.y, target_ang.z),
        math.max(intensityBreath - intensityWalk - intensityRun, 0),
        math.max(intensityWalk - intensityRun, 0), rate, delta)

end

--[[ 
Function Name:  CalculateViewModelFlip
Syntax: CalculateViewModelFlip()
Returns: Flips the viewmodel FOV from an option inside clients.
Purpose:  Utility function / Animation
]]
--
function SWEP:CalculateViewModelFlip()
    if self.ViewModelFlipDefault == nil then
        self.ViewModelFlipDefault = self.ViewModelFlip
    end

    local righthanded = true

    if chaosbase_flip_cv:GetBool() then
        righthanded = false
    end

    local shouldflip = self.ViewModelFlipDefault

    if not righthanded then
        shouldflip = not self.ViewModelFlipDefault
    end

    if self.ViewModelFLip ~= shouldflip then
        self.ViewModelFlip = shouldflip
    end
    self.ViewModelFOV_OG = self.ViewModelFOV

    local cam_fov = 90
    local iron_add = cam_fov * (1 - 90 / cam_fov) * math.max(1 - self.Secondary.OwnerFOV / 90, 0)

    self.ViewModelFOV = Lerp(self.IronSightsProgressUnpredicted, self.ViewModelFOV_OG, self.Secondary.ViewModelFOV) * fovmod_mult:GetFloat() + fovmod_add:GetFloat() + iron_add + self.IronSightsProgressUnpredicted
end

--[[ 
Function Name:  CalcViewModel
Syntax: CalcViewModel(ViewModel, EyePos, EyeAng)
Returns: Calculations and Applying viewmodel values for Recoil, Sway and Movement. Adds virtual weight to guns.
Purpose:  Utility function / Animation
]]
--
function SWEP:CalcViewModel(ViewModel, EyePos, EyeAng)
    local ironprogress = self.IronSightsProgressUnpredicted
    local owner = self:GetOwner()
    local vm = owner:GetViewModel()
    if not IsValid(owner) then return end
    local vars = self.ViewModelVars
    vars.LerpAimDelta = self:SafeLerp(10 * FrameTime(), vars.LerpAimDelta, ironprogress)
    --jump
    self:CalcViewModelJump()

    --movement sway
    self:CalcMovementSway()

    --fake recoil
    self:CalcRecoil()
    local recoilPos, recoilAng = vars.Recoil.Translation, vars.Recoil.Rotation
    --sway

    self:CalcSway(EyeAng)

    --idle and aim offsets
    local aimPos, aimAng = self:GetAvailableAimOffsets()
    aimAng = aimAng * 1
    aimAng:Mul(self:SafeLerp(ironprogress, 0, 1))
    local idleAng = self.ViewModelOffsets.Idle.Angles * self:SafeLerp(self:GetAimDelta(), 1, 0)
    self:SafeLerpAngle(50 * FrameTime(), vars.LerpAimAngles, aimAng)
    EyeAng:Add(vars.LerpAimAngles)
    EyeAng:Add(idleAng)
    --end idle and aim offsets

    --viewpunch
    local vpAngles = self:GetOwner():GetViewPunchAngles()
    vpAngles:Mul(self:SafeLerp(ironprogress, 0.2, 0.01))
    EyeAng:Add(vpAngles)
    --end viewpunch

    --jump
    local jumpAngles = Angle(vars.Jump.Lerp, 0, 0)
    jumpAngles:Mul(self:SafeLerp(vars.LerpAimDelta, 0.2, 0.05))
    EyeAng:Add(jumpAngles)
    --end jump

    --sway
    local swayAngles = Angle(vars.Sway.Y.Lerp, vars.Sway.X.Lerp, 0)
    swayAngles:Mul(self:SafeLerp(vars.LerpAimDelta, 0.1, 0.05))
    EyeAng:Add(swayAngles)
    --end sway

    --fake recoil
    EyeAng:Add(recoilAng*0.2)
    --end fake recoil

    local forward = EyeAng:Forward()
    local right = EyeAng:Right()
    local up = EyeAng:Up()
    --recoil

    local intensity = (math.Clamp(self:GetOwner():GetViewPunchAngles().p / 90, -1, 1) * 20) * self:SafeLerp(ironprogress, 0.3 * self.ViewModelOffsets.RecoilMultiplier, 0.01 * self.ViewModelOffsets.RecoilMultiplier)
    self:VectorAddAndMul(EyePos, up, intensity * 0.3)
    self:VectorAddAndMul(EyePos, forward, intensity)
    self:VectorAddAndMul(EyePos, forward, -self.Camera.Shake * self:SafeLerp(ironprogress, 0.7, 1.3) * self:SafeLerp(ironprogress, self.ViewModelOffsets.KickMultiplier or 1, self.ViewModelOffsets.AimKickMultiplier or 1))
    --end recoil

    --movement
    self:VectorAddAndMul(EyePos, up, vars.Jump.LerpZ * -0.05 * self:SafeLerp(vars.LerpAimDelta, 1, 0.1))
    self:VectorAddAndMul(EyePos, forward, -vars.LerpForward * self:SafeLerp(vars.LerpAimDelta, 2, 0.3))
    self:VectorAddAndMul(EyePos, right, -vars.LerpRight * self:SafeLerp(vars.LerpAimDelta, 1, 0.05))
    --end movement

    --idle
    self:VectorAddAndMul(EyePos, up, math.cos(CurTime() * 2) * math.cos(CurTime()) * 0.1 * self:SafeLerp(vars.LerpAimDelta, 1, 0))
    self:VectorAddAndMul(EyePos, right, math.cos(CurTime() * 2) * math.sin(CurTime()) * 0.1 * self:SafeLerp(vars.LerpAimDelta, 1, 0))
    -- end of idle

    --sway
    self:VectorAddAndMul(EyePos, up, (vars.Sway.PosY.Lerp * 0.25) * self:SafeLerp(vars.LerpAimDelta, 1, 0.1))
    self:VectorAddAndMul(EyePos, forward, (vars.Sway.PosForward.Lerp * 0.1) * self:SafeLerp(vars.LerpAimDelta, 1, 0.1))
    self:VectorAddAndMul(EyePos, right, (vars.Sway.PosX.Lerp * 0.25) * self:SafeLerp(vars.LerpAimDelta, 1, 0.1))
    --end sway

    --offsets
    self:SafeLerpVector(50 * FrameTime(), vars.LerpAimPos, aimPos)
    local idleOffset = self:CalcOffset(self.ViewModelOffsets.Idle.Pos, EyeAng * 1)
    idleOffset:Mul(self:SafeLerp(ironprogress, 1, 0))
    EyePos:Add(idleOffset)
    --end offsets

    --crouch
    self:SafeLerpVector(10 * FrameTime(), vars.LerpCrouch, self:CalcCrouchOffset())
    vars.LerpCrouch:Mul(1 - ironprogress)
    self:VectorAddAndMul(EyePos, up, vars.LerpCrouch.z)
    self:VectorAddAndMul(EyePos, forward, vars.LerpCrouch.y)
    self:VectorAddAndMul(EyePos, right, vars.LerpCrouch.x)
    --end crouch

    --fake recoil
    self:VectorAddAndMul(EyePos, up, recoilPos.z)
    self:VectorAddAndMul(EyePos, forward, recoilPos.y)
    self:VectorAddAndMul(EyePos, right, recoilPos.x)
    --end fake recoil

    CalcVMViewHookBypass = true
    EyePos, EyeAng = hook.Run("CalcViewModelView", self, vm, vm:GetPos(), vm:GetAngles(), EyePos * 1, EyeAng * 1)
    CalcVMViewHookBypass = false
    vm:SetPos(EyePos)
    vm:SetAngles(EyeAng)
    --self.ViewModelFOV = self:SafeLerp(self.Camera.Fov, self.m_OriginalViewModelFOV, self.m_OriginalViewModelFOV * self.Zoom.ViewModelFovMultiplier)
end

--[[ 
Function Name:  CalcViewModelJump()
Syntax: CalcViewModelJump()
Returns: Caculation for jumping and adding Lerp to the guns VModel.
Purpose:  Utility function / Animation
]]
--
function SWEP:CalcViewModelJump()
    local owner = self:GetOwner()
    local vars = self.ViewModelVars
    if not IsValid(owner) then return end

    if vars.Jump.bWasOnGround ~= owner:OnGround() then
        if owner:OnGround() then
            vars.Jump.Force = math.min(vars.Jump.Velocity * -0.075, 30)
            vars.Jump.ForceZ = vars.Jump.Force
            vars.Jump.Time = 0
            vars.Jump.Shake = vars.Jump.Force * 0.3
        else
            timer.Simple(0, function()
                vars.Jump.Force = owner:GetVelocity().z * 0.15
                vars.Jump.ForceZ = vars.Jump.Force
                vars.Jump.Time = 0
            end)
        end

        vars.Jump.bWasOnGround = owner:IsOnGround()
    end

    vars.Jump.Velocity = owner:GetVelocity().z
    vars.Jump.Time = vars.Jump.Time + FrameTime()
    vars.Jump.Force = self:SafeLerp(6 * FrameTime(), vars.Jump.Force, 0)
    vars.Jump.ForceZ = self:SafeLerp(3 * FrameTime(), vars.Jump.ForceZ, 0)
    vars.Jump.Lerp = self:SafeLerp(10 * FrameTime(), vars.Jump.Lerp, math.sin(vars.Jump.Time * 10) * vars.Jump.Force)
    vars.Jump.LerpZ = self:SafeLerp(6 * FrameTime(), vars.Jump.LerpZ, math.sin(vars.Jump.Time * 7) * vars.Jump.ForceZ)
end

function SWEP:GetAvailableAimOffsets()
    local posoffset, angoffset = self.ViewModelOffsets.Aim.Pos, self.ViewModelOffsets.Aim.Angles

    return LerpVector(self:GetAimDelta(), self.ViewModelOffsets.Aim.Pos, posoffset), LerpAngle(self:GetAimDelta(), self.ViewModelOffsets.Aim.Angles, angoffset)
end

--[[ 
Function Name: CalcMovementSway()
Syntax: CalcMovementSway()
Returns: Caculation for movement and adding Lerp to the guns VModel.
Purpose:  Utility function / Animation
]]
--
function SWEP:CalcMovementSway()
    if self:GetIsAiming() then return end
    local owner = self:GetOwner()
    local velVector = Vector(owner:GetVelocity().x, owner:GetVelocity().y, 0)
    local forward = Angle(0, owner:EyeAngles().yaw, 0):Forward():Dot(velVector) / owner:GetWalkSpeed()
    local right = Angle(0, owner:EyeAngles().yaw, 0):Right():Dot(velVector) / owner:GetWalkSpeed()

    if self:GetIsSprinting() then
        forward = 0
        right = 0
    end

    forward = math.Clamp(forward, -1, 1)
    right = math.Clamp(right, -1, 1)
    local vars = self.ViewModelVars
    vars.LerpForward = self:SafeLerp(10 * FrameTime(), vars.LerpForward, math.max(forward, 0))
    vars.LerpRight = self:SafeLerp(10 * FrameTime(), vars.LerpRight, right)
end

--[[ 
Function Name: CalcSway()
Syntax: CalcSway(ang)
Returns: Caculation for base sway and adding Lerp to the guns VModel.
Purpose:  Utility function / Animation
]]
--
function SWEP:CalcSway(angsway)
    --if self:GetIsAiming() then return end
    --if self.DisableSway then return end
    local x = angsway.yaw
    local y = angsway.pitch
    local vars = self.ViewModelVars.Sway
    self:CalcSwayAxis(vars.X, x, 10, 0.035)
    self:CalcSwayAxis(vars.Y, y, 10, 0.035)
    self:CalcSwayAxis(vars.PosX, x, 7.5, 0.035)
    self:CalcSwayAxis(vars.PosY, y, 7.5, 0.035)
    self:CalcSwayAxis(vars.PosForward, x, 10, 0.1)
end

--[[ 
Function Name: CalcSwayAxis()
Syntax: CalcSwayAxis(swayObject, angle, speed, bounce)
Returns: Pass calc for using the VModels angle and limiting it to an axis to keep it clean.
Purpose:  Utility function / Animation
]]
--
function SWEP:CalcSwayAxis(swayObject, angle, speed, bounce)
    local vel = self:GetOwner():GetVelocity():Length()
    local limit = 4 + (vel * 0.015)

    if swayObject.Ang ~= angle then
        swayObject.Sway = math.Clamp(swayObject.Sway + math.AngleDifference(angle, swayObject.Ang) * 0.3, -limit, limit)
    end

    swayObject.Ang = angle
    swayObject.Direction = self:SafeLerp(math.min(speed * FrameTime(), speed), swayObject.Direction, (0 - swayObject.Sway) * bounce)
    swayObject.Sway = swayObject.Sway + (swayObject.Direction * math.min(FrameTime() * 250, speed))
    swayObject.Lerp = self:SafeLerp(math.min(speed * 2 * FrameTime(), speed), swayObject.Lerp, swayObject.Sway)
end

--[[ 
Function Name: CalcOffset()
Syntax: CalcOffset(offset, ang)
Returns: Caculate any offset from weapon code defined in a table and add it to all other values used in functions.
Purpose:  Utility function / Animation
]]
--
function SWEP:CalcOffset(offset, angoffset)
    local result = Vector(0, 0, 0)
    local forward = angoffset:Forward()
    local right = angoffset:Right()
    local up = angoffset:Up()
    forward:Mul(offset.y)
    right:Mul(offset.x)
    up:Mul(offset.z)
    result:Add(forward)
    result:Add(right)
    result:Add(up)

    return result
end

--[[ 
Function Name: CalcCrouchOffset()
Syntax: CalcCrouchOffset()
Returns: Calculate VM crouch offset to pass off to other functions.
Purpose:  Utility function / Animation
]]
--
function SWEP:CalcCrouchOffset()
    local owner = self:GetOwner()
    if owner:Crouching() and owner:IsOnGround() then return self.CrouchVector end

    return self.ZeroVector
end

--[[ 
Function Name: CalcRecoil()
Syntax: CalcRecoil()
Returns: Calculate recoil from SWEP Recoil Table and pass it to CalcViewModel.
Purpose:  Utility function / Animation
]]
--
function SWEP:CalcRecoil()
    local owner = self:GetOwner()
    local aimDelta = self:SafeLerp(self.IronSightsProgressUnpredicted, 0.75, 0.2)

    if self.Primary.Automatic then
        local speed = 25
        local verticalTrans = math.sin(CurTime() * speed * 0.5) * 0.05
        local verticalRot = math.cos(CurTime() * speed * 0.5) * 0.25
        local horizRecoil = math.max(math.abs(self.Recoil.Horizontal[1]), math.abs(self.Recoil.Horizontal[2]))

        if self.Recoil.ViewModelMultiplier ~= nil then
            horizRecoil = horizRecoil * self.Recoil.ViewModelMultiplier
        end

        local horizontalTrans = math.cos(CurTime() * speed) * horizRecoil * 0.1
        local horizontalRot = math.sin(CurTime() * speed) * horizRecoil * 0.5
        local delta = math.min(self:GetSprayRounds() / 10, 1)

        if owner:KeyDown(IN_ATTACK) and self:Clip1() > 0 then
            local pos1 = Vector(horizontalTrans, 0, verticalTrans)
            pos1:Mul(delta)
            local pos2 = self:GetSprayRounds() > 1 and Vector(0, -1, 0.3) or Vector(0, 0, 0) --avoid editing zerovector
            pos2:Add(pos1)
            pos2:Mul(aimDelta)
            self:SafeLerpVector(math.min(30 * FrameTime(), 1), self.ViewModelVars.Recoil.Translation, pos2)
            local ang1 = Angle(verticalRot, -horizontalRot, horizontalRot * 2)
            ang1:Mul(delta)
            local ang2 = self:GetSprayRounds() > 1 and Angle(0, 0, -5) or Angle(0, 0, 0) --avoid editing zeroangle
            ang2:Add(ang1)
            ang2:Mul(aimDelta)
            self.ViewModelVars.Recoil.Rotation = LerpAngle(math.min(30 * FrameTime(), 1), self.ViewModelVars.Recoil.Rotation, ang2)
        else
            self:SafeLerpVector(math.min(10 * FrameTime(), 1), self.ViewModelVars.Recoil.Translation, self.ZeroVector)
            self.ViewModelVars.Recoil.Rotation = LerpAngle(math.min(10 * FrameTime(), 1), self.ViewModelVars.Recoil.Rotation, self.ZeroAngle)
        end
    end
    --haha :).
end