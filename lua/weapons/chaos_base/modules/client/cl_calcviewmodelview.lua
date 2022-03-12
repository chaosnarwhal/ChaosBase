AddCSLuaFile()

local vector_origin = Vector()
local angle_zero = Angle()

local Vector = Vector
local Angle = Angle
local math = math
local LerpVector = LerpVector


--[[  Quadratic Interpolation Functions  ]]--

--[[ 
Function Name:  Power
Syntax: pow(number you want to take the power of, it's power)
Returns:  The number to the power you specify
Purpose:  Utility function
]]--
local function pow(num, power)
    return math.pow(num, power)
end

--[[ 
Function Name:  Qerp Inwards
Syntax: QerpIn(progress, your starting value, how much it should change, across what period)
Returns:  A number that you get when you quadratically fade into a value.  Kind of like a more advanced LERP.
Purpose:  Utility function / Animation
]]--

local function QerpIn(progress, startval, change, totaltime)
    if !totaltime then
        totaltime = 1
    end
    return startval + change * pow( progress/totaltime, 2)
end

--[[ 
Function Name:  Qerp Outwards
Syntax: QerpOut(progress, your starting value, how much it should change, across what period)
Returns:  A number that you get when you quadratically fade out of a value.  Kind of like a more advanced LERP.
Purpose:  Utility function / Animation
]]--

local function QerpOut(progress, startval, change, totaltime)
    if !totaltime then
        totaltime = 1
    end
    return startval - change * pow( progress/totaltime, 2)
end

--[[ 
Function Name:  Qerp
Syntax: Qerp(progress, starting value, ending value, period)
Note:  This is different syntax from QerpIn and QerpOut.  This uses a start and end value instead of a start value and change amount.
Returns:  A number that you get when you quadratically fade out of and into a value.  Kind of like a more advanced LERP.
Purpose:  Utility function / Animation
]]--

local function Qerp( progress, startval, endval, totaltime)
    change = endval - startval
    if !totaltime then
        totaltime = 1
    end
    if progress < totaltime / 2 then return QerpIn(progress, startval, change/2, totaltime/2) end
    return QerpOut(totaltime-progress, endval, change/2, totaltime/2)
end

--[[ 
Function Name:  QerpAngle
Syntax: QerpAngle(progress, starting value, ending value, period)
Returns:  The quadratically interpolated angle.
Purpose:  Utility function / Animation
]]--

local function QerpAngle( progress, startang, endang, totaltime )
    if !totaltime then
        totaltime = 1
    end
    return LerpAngle(Qerp(progress,0,1,totaltime),startang,endang)
end

--[[ 
Function Name:  QerpVector
Syntax: QerpVector(progress, starting value, ending value, period)
Returns:  The quadratically interpolated vector.
Purpose:  Utility function / Animation
]]--

local function QerpVector( progress, startang, endang, totaltime )
    if !totaltime then
        totaltime = 1
    end
    local startx, starty, startz, endx, endy, endz
    startx=startang.x
    starty=startang.y
    startz=startang.z
    endx=endang.x
    endy=endang.y
    endz=endang.z
    return Vector(Qerp(progress, startx, endx, totaltime),Qerp(progress, starty, endy, totaltime),Qerp(progress, startz, endz, totaltime))
end


local function Lerp(t, a, b)
    return a + (b - a) * t
end


--[[ 
Function Name:  GetViewModelPosition
Syntax: self:GetViewModelPosition(pos, ang ).
Returns:  New position and angle.
Notes:  This is used for calculating the swep viewmodel position.  However, don't put per-frame logic in this.  Instead do that in PlayerThinkClientFrame
Purpose:  Main SWEP function
]]--

local cl_rev_viewmodel_offset_x = GetConVar("cl_rev_vmoffset_x")
local cl_rev_viewmodel_offset_y = GetConVar("cl_rev_vmoffset_y")
local cl_rev_viewmodel_offset_z = GetConVar("cl_rev_vmoffset_z")

local cl_vm_flip_cv = GetConVar("cl_rev_vmflip")
local fovmod_add = GetConVar("cl_rev_vm_offset_fov")
local fovmod_mult = GetConVar("cl_rev_vm_multiplier_fov")


SWEP.OldPos = Vector(0, 0, 0)
SWEP.OldAng = Angle(0, 0, 0)

function SWEP:GetViewModelPosition(opos, oang, ...)

    if not self.pos_cached then return opos, oang end


    local npos, nang = opos * 1, oang * 1

    nang:RotateAroundAxis(nang:Right(),     self.ang_cached.p)
    nang:RotateAroundAxis(nang:Up(),        self.ang_cached.r)
    nang:RotateAroundAxis(nang:Forward(),   self.ang_cached.y)
    npos:Add(nang:Right() *                 self.pos_cached.x)
    npos:Add(nang:Forward() *               self.pos_cached.y)
    npos:Add(nang:Up() *                    self.pos_cached.z)

    if not pos or not ang then return npos, nang end

    local ofpos, ofang = WorldToLocal(npos, nang, opos, oang)

    self.OldPos = npos
    self.OldAng = nang

    if self.CLIronSightsProgress > 0.005 then
        local _opos, _oang = opos * 1, oang * 1

        --Rev base VM Offsets.
        local right, up, fwd = _oang:Right(), _oang:Up(), _oang:Forward()

        _opos = _opos - ofpos.y * right + ofpos.x * fwd + ofpos.z * up

        _oang:RotateAroundAxis(fwd,      ofang.r)
        _oang:RotateAroundAxis(right,   -ofang.p)
        _oang:RotateAroundAxis(up,       ofang.y)

        --Sights Offsets.

        _oang:RotateAroundAxis(_oang:Forward(),     -ang.r)
        _oang:RotateAroundAxis(_oang:Right(),        ang.p)
        _oang:RotateAroundAxis(_oang:Up(),          -ang.y)

        right, up, fwd = _oang:Right(), _oang:Up(), _oang:Forward()

        _opos = _opos - pos.x * fwd + pos.y * right - pos.z * up

        self.OldPos = LerpVector(self.CLIronSightsProgress, npos, _opos)
        self.OldAng = LerpAngle(self.CLIronSightsProgress, nang, _oang)
    end

    return self.OldPos, self.OldAng

end

function SWEP:CalculateViewModelOffset(delta)

    local target_pos, target_ang

    local additivePos = self.AdditiveViewModelPosition

    if additivePos then
        target_pos, target_ang = Vector(), Vector()
    else
        target_pos = self.ViewModelPosition
        target_ang = self.ViewModelAngle
    end

    local IronSightsPosition = self.IronSightsPos
    local IronSightsAngle = self.IronSightsAng


    if self.CLIronSightsProgress > 0.02 then
        local score = 1
        local getSightsPos = IronSightsPosition

        target_pos = LerpVector(self.CLIronSightsProgress, target_pos, getSightsPos)

        target_ang = LerpVector(self.CLIronSightsProgress, target_ang, IronSightsAngle)
    end

    target_pos.x = target_pos.x + cl_rev_viewmodel_offset_x:GetFloat() * (1 - self.CLIronSightsProgress)
    target_pos.y = target_pos.y + cl_rev_viewmodel_offset_y:GetFloat() * (1 - self.CLIronSightsProgress)
    target_pos.z = target_pos.z + cl_rev_viewmodel_offset_z:GetFloat() * (1 - self.CLIronSightsProgress)

    if additivePos then
        target_pos:Add(self.ViewModelPosition)
        target_ang:Add(self.ViewModelAngle)
    end


    self.pos_cached, self.ang_cached = Vector(target_pos), Angle(target_ang.x, target_ang.y, target_ang.z)

end


function SWEP:CalculateViewModelFlip()

    if self.ViewModelFlipDefault == nil then
        self.ViewModelFlipDefault = self.ViewModelFlip
    end

    local righthanded = true
    
    if cl_vm_flip_cv:GetBool() then
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
    
    self.ViewModelFOV = Lerp(self.CLIronSightsProgress, self.ViewModelFOV_OG, self.Secondary.ViewModelFOV) * fovmod_mult:GetFloat() + fovmod_add:GetFloat() + iron_add + self.CLIronSightsProgress

end