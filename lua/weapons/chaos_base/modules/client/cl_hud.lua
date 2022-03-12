local function ScreenScaleMulti(input)
    return ScreenScale(input)
end

local mr = math.Round

local t_states = {
    [0] = "STATE_IDLE",
    [1] = "STATE_SIGHTS",
    [2] = "STATE_SPRINT",
    [3] = "STATE_DISABLE",
    [4] = "STATE_WALK",
}

function SWEP:DrawHUD()
	if GetConVar("chaosbase_dev_shootinfo"):GetBool() then
		local reloadtime = self:GetReloadTime()
        local s = ScreenScaleMulti(1)
        local thestate = self:GetState()
        local ecksy = s * 64

        surface.SetFont("reach_ammocounter")
        surface.SetTextColor(255, 255, 255, 255)
        surface.SetDrawColor(0, 0, 0, 150)

        if reloadtime then
            surface.SetTextPos(ecksy, 26 * s*1)
            surface.DrawText(reloadtime[1])

            surface.SetTextPos(ecksy, 26 * s*2)
            surface.DrawText(reloadtime[2])

            surface.SetTextPos(ecksy, 26 * s*3)
            if self:GetMagUpIn()-CurTime() > 0 then
                surface.SetTextColor(255, 127, 127, 255)
            end
            surface.DrawText( mr( math.max( self:GetMagUpIn() - CurTime(), 0 ), 2) )
        else
            surface.SetFont("reach_ammocounter")
            surface.SetTextPos(ecksy, 26 * s*2)
            surface.DrawText("NO RELOAD ANIMATION")

            surface.SetFont("reach_ammocounter")
            surface.SetTextPos(ecksy, 26 * s*2.66)
            surface.DrawText("not a mag fed one, at least...")
        end
        surface.SetFont("reach_ammocounter")
        surface.SetTextColor(255, 255, 255, 255)

        if self:GetReloadingREAL()-CurTime() > 0 then
            surface.SetTextColor(255, 127, 127, 255)
        end
        surface.SetTextPos(ecksy, 26 * s*4)
        surface.DrawText( mr( math.max( self:GetReloadingREAL() - CurTime(), 0 ), 2 ) )
        surface.SetTextColor(255, 255, 255, 255)

        if self:GetWeaponOpDelay()-CurTime() > 0 then
            surface.SetTextColor(255, 127, 127, 255)
        end
        surface.SetTextPos(ecksy, 26 * s*5)
        surface.DrawText( mr( math.max( self:GetWeaponOpDelay() - CurTime(), 0 ), 2 ) )
        surface.SetTextColor(255, 255, 255, 255)

        if self:GetNextPrimaryFire() - CurTime() > 0 then
            surface.SetTextColor(255, 127, 127, 255)
        end
        surface.SetTextPos(ecksy, 26 * s*6)
        surface.DrawText( mr( math.max( self:GetNextPrimaryFire()*1000 - CurTime()*1000, 0 ), 0 ) .. "ms" )
        surface.SetTextColor(255, 255, 255, 255)

        local seq = self:GetSequenceInfo( self:GetOwner():GetViewModel():GetSequence() )
        local seq2 = self:GetOwner():GetViewModel():GetSequence()
        local seq3 = self:GetOwner():GetViewModel()
        surface.SetTextPos(ecksy+1650, 26 * s*7)
        surface.SetFont("Trebuchet24")
        surface.DrawText( seq2 .. ", " .. seq.label )

        local proggers = 1 - ( self.LastAnimFinishTime - CurTime() ) / seq3:SequenceDuration()

        surface.SetTextPos(ecksy+1600, 26 * s*7.6)
        surface.SetFont("Trebuchet24")
        surface.DrawText( mr( seq3:SequenceDuration()*proggers, 2 ) )

        surface.SetTextPos(ecksy + s*30, 26 * s*8)
        surface.DrawText( "-" )

        surface.SetTextPos(ecksy + s*48, 26 * s*8)
        surface.DrawText( mr( self:SequenceDuration( seq2 ), 2 ) )

        surface.SetTextPos(ecksy+2000, 26 * s*7.6)
        surface.DrawText( mr(proggers*100) .. "%" )

        -- welcome to the bar
        surface.DrawOutlinedRect(ecksy+1600, 25 * s*7.7, s*128, s*8, s)
        surface.DrawRect(ecksy+1600, 25 * s*7.7+s*2, s*128*math.Clamp(proggers, 0, 1), s*8-s*4, s)

        surface.SetFont("Trebuchet24")
        surface.SetTextPos(ecksy+1650, 18 * s*8.5)
        surface.DrawText( t_states[thestate] )

        surface.SetTextPos(ecksy, 26 * s*9.25)
        surface.DrawText( mr(self:GetSightDelta()*100) .. "%" )

        surface.DrawOutlinedRect(ecksy, 26 * s*10, s*64, s*4, s/2)
        surface.DrawRect(ecksy, 26 * s*10+s*1, s*64*self:GetSightDelta(), s*4-s*2)

        surface.DrawOutlinedRect(ecksy, 26 * s*10.25, s*64, s*4, s/2)
        surface.DrawRect(ecksy, 26 * s*10.25+s*1, s*64*self:GetSprintDelta(), s*4-s*2)

        
        surface.SetTextPos(ecksy, 26 * s*11)
        surface.DrawText( mr(self:GetHolster_Time(), 1) )

        surface.SetTextPos(ecksy, 26 * s*12)
        surface.DrawText( tostring(self:GetHolster_Entity()) )

        -- Labels
        surface.SetTextColor(255, 255, 255, 255)
        surface.SetFont("reach_ammocounter")

        surface.SetTextPos(ecksy+150, 26 * s*4)
        surface.DrawText("| RELOAD DELAY")

        surface.SetTextPos(ecksy+75, 26 * s*5)
        surface.DrawText("WEAPON OPERATION DELAY")

        surface.SetTextPos(ecksy+275, 26 * s*6)
        surface.DrawText("| NEXT PRIMARY FIRE")

        surface.SetTextPos(ecksy+1500, s)
        surface.DrawText("CURRENT ANIMATION")

        surface.SetTextPos(ecksy+75, 26 * s*8.5)
        surface.DrawText("WEAPON STATE")

        surface.SetTextPos(ecksy+75, 26 * s*9.25)
        surface.DrawText("SIGHT DELTA")

        surface.SetTextPos(ecksy+75, 26 * s*11)
        surface.DrawText("HOLSTER TIME")

        surface.SetTextPos(ecksy+75, 26 * s*12)
        surface.DrawText("HOLSTER ENT")

        local texy = math.Round(CurTime(),1)
        local a, b = surface.GetTextSize(texy)
        surface.SetTextPos((ScrW()/2) - (a/2), (s*16) - (b/2))
        surface.DrawText(texy)

        surface.SetDrawColor(255, 255, 255, 255)

    end
end