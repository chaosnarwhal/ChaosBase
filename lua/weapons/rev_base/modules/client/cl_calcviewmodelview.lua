AddCSLuaFile()
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
--[[ 
Function Name:  GetViewModelPosition
Syntax: self:GetViewModelPosition(pos, ang ).
Returns:  New position and angle.
Notes:  This is used for calculating the swep viewmodel position.  However, don't put per-frame logic in this.  Instead do that in PlayerThinkClientFrame
Purpose:  Main SWEP function
]]--

function SWEP:GetViewModelPosition(pos, ang)

    local isp=math.Clamp(self.CLIronSightsProgress,0,1)--self:GetIronSightsRatio()
    local rsp=math.Clamp(self.CLRunSightsProgress,0,1)--self:GetRunSightsRatio()
    local nwp=math.Clamp(self.CLNearWallProgress,0,1)--self:GetNearWallRatio()
    local inspectrat=math.Clamp(self.CLInspectingProgress,0,1)--self:GetInspectingRatio()
    local tmp_ispos = self.SightsPos and self.SightsPos or self.IronSightsPos
    local tmp_isa = self.SightsAng and self.SightsAng or self.IronSightsAng
    local tmp_rspos = self.RunSightsPos and self.RunSightsPos or tmp_ispos
    local tmp_rsa  = self.RunSightsAng and self.RunSightsAng or tmp_isa
    
    local RevGlobalVMOffset = Vector(GetConVar("cl_rev_vmoffset_x"):GetFloat(),GetConVar("cl_rev_vmoffset_y"):GetFloat(),GetConVar("cl_rev_vmoffset_z"):GetFloat())

    if !self.InspectPos then
        self.InspectPos = self.InspectPosDef * 1
        if self.ViewModelFlip then
            self.InspectPos.x= self.InspectPos.x * -1
        end
    end
    
    if ! self.InspectAng then
        self.InspectAng = self.InspectAngDef * 1
        
        if self.ViewModelFlip then
            self.InspectAng.x= self.InspectAngDef.x * 1
            self.InspectAng.y= self.InspectAngDef.y * -1
            self.InspectAng.z= self.InspectAngDef.z * -1
        end
        
    end
    
    local tmp_inspectpos = self.InspectPos
    
    local tmp_inspecta  = self.InspectAng
    
    local opos=pos*1
    
    if tmp_isa==nil then 
        return
    end
     --The viewmodel angular offset, constantly.
    ang:RotateAroundAxis(ang:Right(),       self.VMAng.x) 
    ang:RotateAroundAxis(ang:Up(),          self.VMAng.y)
    ang:RotateAroundAxis(ang:Forward(),     self.VMAng.z)
     
    local ang2=Angle(ang.p,ang.y,ang.r)
    local ang3=Angle(ang.p,ang.y,ang.r) 
    local ang4=Angle(ang.p,ang.y,ang.r) 
    local ang5=Angle(ang.p,ang.y,ang.r) 
    
    self.SwayScale  = Lerp(isp,1,self.IronBobMult)
    self.SwayScale  = Lerp(rsp,self.SwayScale,self.SprintBobMult)
    
    --self.BobScale     = Lerp(isp,1,self.IronBobMult)
    --self.BobScale  = Lerp(rsp,self.BobScale,self.SprintBobMult)
    self.BobScale = 0 
    self.BobScaleCustom     = Lerp(isp,1,self.IronBobMult)
    self.BobScaleCustom     = Lerp(rsp,self.BobScaleCustom,self.SprintBobMult)
    
    ang2:RotateAroundAxis(ang2:Right(),         tmp_isa.x)
    ang2:RotateAroundAxis(ang2:Up(),            tmp_isa.y)
    ang2:RotateAroundAxis(ang2:Forward(),       tmp_isa.z)
    
    ang=QerpAngle(isp, ang, ang2)
    
    ang3:RotateAroundAxis(ang3:Right(),         tmp_rsa.x)
    ang3:RotateAroundAxis(ang3:Up(),            tmp_rsa.y)
    ang3:RotateAroundAxis(ang3:Forward(),       tmp_rsa.z)
    
    ang=QerpAngle(rsp, ang, ang3)
    
    local tmp_nwsightsang = tmp_rsa
    if self.NearWallSightsAng then
        tmp_nwsightsang = self.NearWallSightsAng
    end
    
    ang4:RotateAroundAxis(ang4:Right(),         tmp_nwsightsang.x)
    ang4:RotateAroundAxis(ang4:Up(),            tmp_nwsightsang.y)
    ang4:RotateAroundAxis(ang4:Forward(),       tmp_nwsightsang.z)
    
    ang=QerpAngle(nwp, ang, ang4)
    
    ang5:RotateAroundAxis(ang5:Right(),         tmp_inspecta.x)
    ang5:RotateAroundAxis(ang5:Up(),            tmp_inspecta.y)
    ang5:RotateAroundAxis(ang5:Forward(),       tmp_inspecta.z)
    
    ang=QerpAngle(inspectrat, ang, ang5)
    
    opos:Add( ang:Right() * (self.VMPos.x) )
    opos:Add( ang:Forward() * (self.VMPos.y) )
    opos:Add( ang:Up() * (self.VMPos.z) )
    
    pos:Add( ang:Right() * (self.VMPos.x + RevGlobalVMOffset.x) )
    pos:Add( ang:Forward() * (self.VMPos.y + RevGlobalVMOffset.y) )
    pos:Add( ang:Up() * (self.VMPos.z + RevGlobalVMOffset.z) )
    
    target = pos * 1 -- Copy pos to target
    target:Add( ang:Right() * (tmp_ispos.x) )
    target:Add( ang:Forward() * (tmp_ispos.y) )
    target:Add( ang:Up() * (tmp_ispos.z) )
        
    pos=QerpVector( isp, pos, target)
    
    target = pos * 1 -- Copy pos to target
    target:Add( ang:Right() * (tmp_rspos.x) )
    target:Add( ang:Forward() * (tmp_rspos.y) )
    target:Add( ang:Up() * (tmp_rspos.z) )
        
    pos=QerpVector( rsp, pos, target)
    
    local tmp_nwsightspos = tmp_rspos
    if self.NearWallSightsPos then
        tmp_nwsightspos = self.NearWallSightsPos
    end
    
    target = opos * 1 -- Copy pos to target
    target:Add( ang:Right() * (tmp_nwsightspos.x) )
    target:Add( ang:Forward() * (tmp_nwsightspos.y) )
    target:Add( ang:Up() * (tmp_nwsightspos.z) )
        
    pos=QerpVector( nwp, pos, target)
    
    target = opos * 1 -- Copy pos to target
    target:Add( ang:Right() * (tmp_inspectpos.x) )
    target:Add( ang:Forward() * (tmp_inspectpos.y) )
    target:Add( ang:Up() * (tmp_inspectpos.z) )
        
    pos=QerpVector( inspectrat, pos, target)
    
    --Start viewbob code
    
    --local gunbobintensity = GetConVarNumber("sv_rev_gunbob_intensity",1) * 0.65 * 0.66
    
    --pos, ang = self:CalculateBob( pos, ang, gunbobintensity)
    
    --End viewbob code
    
    --Start scope compensation code
    
    --if self.CLIronSightsProgress > self.ScopeOverlayThreshold and self.Scoped then
        --pos:Add( ang:Up() * (-10) )
    --end
    
    return pos, ang 
end