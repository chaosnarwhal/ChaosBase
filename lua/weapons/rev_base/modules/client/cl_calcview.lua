--[[ 
Function Name:  CalcView
Syntax: Don't ever call this manually.
Returns:  Nothing.
Notes:  Used to calculate view angles.
Purpose:  Feature
local blankvecbak = Vector(0,0,0)
local blankvec = Vector(0,0,0)
local blankang = Angle(0,0,0)
SWEP.AttachmentViewOffset = Angle(0,0,0)

function SWEP:CalcView(ply, pos, ang, fov)
        if !ang then return end
        
        if ply != LocalPlayer() then return end
        
        if !CLIENT then return end
        local viewbobintensity = 0.2 * GetConVarNumber("sv_rev_viewbob_intensity",1)
        
        pos, ang = self:CalculateBob( pos, ang, -viewbobintensity )
        
        local vb_d, vb_r
        
        vb_d = GetConVarNumber("cl_rev_viewbob_drawing",1)
        vb_r = GetConVarNumber("cl_rev_viewbob_reloading",1)
        
        if ( ( ( vb_d==1 and self:GetDrawing() ) or ( vb_r==1 and self:GetReloading() ) ) and self.AllowViewAttachment ) then
        
                local vm = ply:GetViewModel()
                local threshold = 0.325 --Time before the animation actually finishes, that we start reverting.
                local spd = 260
                local attpos,attang
                attpos = blankvec
                attang = blankang
                
                if IsValid(vm) then
                        local att = vm:GetAttachment(self:GetFPMuzzleAttachment())
                        if att and att.Pos and ( (self:GetReloading() and self:GetReloadingEnd()-CurTime()>threshold and vb_r==1) or (self:GetDrawing() and self:GetDrawingEnd()-CurTime()>threshold and vb_d==1) ) then
                                if self.DefaultAtt and self.DefaultAtt.Pos then
                                        attpos,attang = WorldToLocal(att.Pos,att.Ang,self.DefaultAtt.Pos,self.DefaultAtt.Ang)
                                else
                                        attpos,attang = WorldToLocal(att.Pos,att.Ang,self.Owner:GetShootPos(),self.Owner:EyeAngles())
                                end
                                --ang:RotateAroundAxis(ang:Forward(),attang.r/10)
                        end
                end
                
                self.AttachmentViewOffset.p=math.ApproachAngle(self.AttachmentViewOffset.p,attang.p,FrameTime()*spd)
                self.AttachmentViewOffset.y=math.ApproachAngle(self.AttachmentViewOffset.y,attang.y,FrameTime()*spd)
                self.AttachmentViewOffset.y=math.ApproachAngle(self.AttachmentViewOffset.r,attang.r,FrameTime()*spd)
                
                ang:RotateAroundAxis(ang:Right(),-self.AttachmentViewOffset.p/5*viewbobintensity)
                ang:RotateAroundAxis(ang:Up(),-self.AttachmentViewOffset.y/10*viewbobintensity)
                ang:RotateAroundAxis(ang:Up(),-self.AttachmentViewOffset.r/20*viewbobintensity)
        
        end
        
        return pos, ang , fov
        
end
]]