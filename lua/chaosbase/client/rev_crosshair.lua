--[[
local widthpos, heightpos = 0, 0

function rev_Crosshair()
	if GetConVar("cl_drawhud"):GetFloat() == 0 then return end
	
	local ply = LocalPlayer()
	if !IsValid(ply) or !ply:Alive() then return end
	local curswep = ply:GetActiveWeapon()
	if !IsValid(curswep) then return end
	if curswep.Base != "rev_base" then return end
	
	local centercrosshair = ply:GetEyeTrace()
	local pos = centercrosshair.HitPos:ToScreen()
	
	widthpos = math.Round(pos.x)
	heightpos = math.Round(pos.y)
	
	if curswep.SightsDown == false then
		alphach = Lerp(0, 0, 255)
		alphalerpch = Lerp(FrameTime() * 25, alphalerpch or 0, 0)
	else
		alphach = Lerp(0, 255, 0)
		alphalerpch = Lerp(FrameTime() * 25, alphalerpch or alphach or 0, alphach or 0)
	end
		
	local modspread = 0.1
	local modspreaddiv = 1.5
	
	local spread = (curswep.Primary.SpreadBiasPitch * modspread)
	local spreaddiv = (curswep.Primary.SpreadBiasYaw * modspreaddiv)
	local artificial = 1
	local cx = 1
	local cy = 1
	local smath = (spread/spreaddiv)
	local smathoffset = smath * 150
	
	local b = math.Clamp(curswep.BloomValue * 100 or 0, 0, 100) * smath * 10
	
	LerpC = Lerp(FrameTime() * 2, LerpC or b, b)
	
	if curswep.CrosshairStatic != nil then
		if curswep.CrosshairShadow == true then
			if curswep.CrosshairNoIronFade == false then
				surface.SetDrawColor( curswep.CrosshairColor.r/2, curswep.CrosshairColor.g/2, curswep.CrosshairColor.b/2, alphalerpch * 1.5 )
			else
				surface.SetDrawColor( curswep.CrosshairColor.r/2, curswep.CrosshairColor.g/2, curswep.CrosshairColor.b/2, 150 )
			end
			surface.SetMaterial( Material(curswep.CrosshairStatic) )
			surface.DrawTexturedRect(widthpos - smathoffset * 3.3775 * artificial * cx, heightpos - smathoffset * 3.3775 * artificial * cy, smathoffset * 6.75 * artificial, smathoffset * 6.75 * artificial)
			surface.DrawTexturedRect(widthpos - smathoffset * 3.1275 * artificial * cx, heightpos - smathoffset * 3.1275 * artificial * cy, smathoffset * 6.25 * artificial, smathoffset * 6.25 * artificial)
		end
	
		if curswep.CrosshairNoIronFade == false then
			surface.SetDrawColor( curswep.CrosshairColor.r, curswep.CrosshairColor.g, curswep.CrosshairColor.b, alphalerpch )
		else
			surface.SetDrawColor( curswep.CrosshairColor.r, curswep.CrosshairColor.g, curswep.CrosshairColor.b, 255 )
		end
		surface.SetMaterial( Material(curswep.CrosshairStatic) )
		surface.DrawTexturedRect(widthpos - smathoffset * 3.25 * artificial * cx, heightpos - smathoffset * 3.25 * artificial * cy, smathoffset * 6.5 * artificial, smathoffset * 6.5 * artificial)
	end
	
	if curswep.CrosshairDynamic != nil then
		if curswep.CrosshairShadow == true then
			if curswep.CrosshairNoIronFade == false then
				surface.SetDrawColor( curswep.CrosshairColor.r/2, curswep.CrosshairColor.g/2, curswep.CrosshairColor.b/2, alphalerpch * 1.5 )
			else
				surface.SetDrawColor( curswep.CrosshairColor.r/2, curswep.CrosshairColor.g/2, curswep.CrosshairColor.b/2, 150 )
			end
			surface.SetMaterial( Material(curswep.CrosshairDynamic) )
			surface.DrawTexturedRect(widthpos - smathoffset * 3.1275 * artificial - LerpC / 2 * cx, heightpos - smathoffset * 3.1275 * artificial - LerpC / 2 * cy, smathoffset * 6.25 * artificial + LerpC, smathoffset * 6.25 * artificial + LerpC)
			surface.DrawTexturedRect(widthpos - smathoffset * 3.3775 * artificial - LerpC / 2 * cx, heightpos - smathoffset * 3.3775 * artificial - LerpC / 2 * cy, smathoffset * 6.75 * artificial + LerpC, smathoffset * 6.75 * artificial + LerpC)
		end
	
		if curswep.CrosshairNoIronFade == false then
			surface.SetDrawColor( curswep.CrosshairColor.r, curswep.CrosshairColor.g, curswep.CrosshairColor.b, alphalerpch )
		else
			surface.SetDrawColor( curswep.CrosshairColor.r, curswep.CrosshairColor.g, curswep.CrosshairColor.b, 255 )
		end
		surface.SetMaterial( Material(curswep.CrosshairDynamic) )
		surface.DrawTexturedRect(widthpos - smathoffset * 3.25 * artificial - LerpC / 2 * cx, heightpos - smathoffset * 3.25 * artificial - LerpC / 2 * cy, smathoffset * 6.5 * artificial + LerpC, smathoffset * 6.5 * artificial + LerpC)
	end
	
	if curswep.CrosshairStatic != nil or curswep.CrosshairDynamic != nil then return end
	
	draw.RoundedBox( 0, widthpos + LerpC + smath + smathoffset, heightpos -2, 22, 3, Color(0, 0, 0, 200 * alphalerpch))
	draw.RoundedBox( 0, widthpos + LerpC + 1 + smath + smathoffset, heightpos -1, 20, 1, Color(255, 255, 255, 255 * alphalerpch))
	
	draw.RoundedBox( 0, widthpos - LerpC - 20 - smath - smathoffset, heightpos -2, 22, 3, Color(0, 0, 0, 200 * alphalerpch))
	draw.RoundedBox( 0, widthpos - LerpC - 19 - smath - smathoffset, heightpos -1, 20, 1, Color(255, 255, 255, 255 * alphalerpch))
	
	draw.RoundedBox( 0, widthpos -1, heightpos + LerpC + smath + smathoffset -1, 3, 22, Color(0, 0, 0, 200 * alphalerpch))
	draw.RoundedBox( 0, widthpos, heightpos + LerpC + smath + smathoffset, 1, 20, Color(255, 255, 255, 255 * alphalerpch))
	
	surface.DrawCircle((widthpos), (heightpos), 64 * LerpC / 50, LerpC * 5, LerpC * 5, LerpC * 5, LerpC * 2.5)
	
	surface.DrawCircle((widthpos), (heightpos), 1, 255, 255, 255, 255 * alphalerpch)
	surface.DrawCircle((widthpos), (heightpos), 2, 0, 0, 0, 10 * alphalerpch)
end

hook.Add("HUDPaint","rev_Crosshair",rev_Crosshair)
--]]