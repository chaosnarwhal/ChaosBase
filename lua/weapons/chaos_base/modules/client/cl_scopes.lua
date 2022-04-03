function SWEP:ChaosDrawCustom2DScopeElements()
end


function SWEP:chaos_scope()
    if GetConVar("cl_drawhud"):GetFloat() == 0 then return end
    if not self.ChaosBase then return end

    local scopetable = self.Scope

    local w, h = ScrW(), ScrH()
    local ss = 4 * scopetable.ScopeScale
    local sw = scopetable.ScopeWidth
    local sh = scopetable.ScopeHeight
    local wi = w / 10 * ss
    local hi = h / 10 * ss
    local Q1Mat = scopetable.ScopeTexture
    local Q2Mat = scopetable.Q2Mat
    local Q3Mat = scopetable.Q3Mat
    local Q4Mat = scopetable.Q4Mat
    local YOffset = -scopetable.ScopeYOffset


        surface.SetDrawColor(scopetable.ScopeBGColor)
        surface.DrawRect(0, (h / 2 - hi * sh) * YOffset, w / 2 - hi / 2 * sw * 2, hi * 2)
        surface.DrawRect(w / 2 + hi * sw, (h / 2 - hi * sh) * YOffset, w / 2 + wi * sw, hi * 2)
        surface.DrawRect(0, 0, w * ss, h / 2 - hi * sh)
        surface.DrawRect(0, (h / 2 + hi * sh) * YOffset, w * ss, h / 1.99 - hi * sh)

        if scopetable.ScopeColor ~= nil then
            surface.SetDrawColor(scopetable.ScopeColor)
        else
            surface.SetDrawColor(Color(0, 0, 0, 255))
        end

        if Q1Mat == nil then
            surface.SetMaterial(Material("sprites/scope_arc"))
        else
            surface.SetMaterial(Material(Q1Mat))
        end

        surface.DrawTexturedRectUV(w / 2 - hi / 2 * sw * 2, (h / 2 - hi) * YOffset, hi * sw, hi * sh, 1, 1, 0, 0)

        if Q2Mat == nil then
            if Q1Mat == nil then
                surface.SetMaterial(Material("sprites/scope_arc"))
            else
                surface.SetMaterial(Material(Q1Mat))
            end
        else
            surface.SetMaterial(Material(Q2Mat))
        end

        surface.DrawTexturedRectUV(w / 2, (h / 2 - hi) * YOffset, hi * sw, hi * sh, 0, 1, 1, 0)

        if Q3Mat == nil then
            if Q1Mat == nil then
                surface.SetMaterial(Material("sprites/scope_arc"))
            else
                surface.SetMaterial(Material(Q1Mat))
            end
        else
            surface.SetMaterial(Material(Q3Mat))
        end

        surface.DrawTexturedRectUV(w / 2 - hi / 2 * sw * 2, h / 2, hi * sw, hi * sh, 1, 0, 0, 1)

        if Q4Mat == nil then
            if Q1Mat == nil then
                surface.SetMaterial(Material("sprites/scope_arc"))
            else
                surface.SetMaterial(Material(Q1Mat))
            end
        else
            surface.SetMaterial(Material(Q4Mat))
        end

        surface.DrawTexturedRectUV(w / 2, h / 2, hi * sw, hi * sh, 0, 0, 1, 1)
end

function SWEP:DrawHUDBackground()
	if not self.Scoped then return end
    --Scope Overlay Handle
    if self.IronSightsProgressUnpredicted > self.ScopeOverlayThreshold then
        self:chaos_scope()
        self:ChaosDrawCustom2DScopeElements()
    end
end

local w, h = ScrW(), ScrH()

function SWEP:DrawScopeOverlay()
    local ScopeTable = self.IronSightStruct
    local ScopeTexture = ScopeTable.ScopeTexture

    if ScopeTexture then
        local dimension = h

        local quad = {
            texture = ScopeTexture,
            color = Color(255, 255, 255, 255),
            x = w / 2 - dimension / 2,
            y = (h - dimension) / 2,
            w = dimension,
            h = dimension,
        }

        draw.TexturedQuad(quad)
    end
end
--[[
--RT SCOPE CODE TO FINISH. NEED TO FORMAT ATTACHMENTS FOR SCOPED WEAPONS TO DRAW RT/CHEAP SCOPE.
function SWEP:ShouldFlatScope()
    return false -- this system was removed, but we need to keep this function
end

local rtsize = ScrH()

local rtmat = GetRenderTarget("chaosbase_rtmat", rtsize, rtsize, false)
local rtmat_cheap = GetRenderTarget("chaosbase_rtmat_cheap", ScrW(), ScrH(), false)
local rtmat_spare = GetRenderTarget("chaosbase_rtmat_spare", ScrW(), ScrH(), false)


local thermal = Material("models/debug/debugwhite")
local colormod = Material("pp/colour")
local coldtime = 30

local additionalFOVconvar = GetConVar("chaosbase_vm_add_ads")

local matRefract = Material("pp/chaosbase/refract_rt")
local matRefract_cheap = Material("pp/chaosbase/refract_cs") -- cheap scopes stretches square overlays so i need to make it 16x9

matRefract:SetTexture("$fbtexture", render.GetScreenEffectTexture())
matRefract_cheap:SetTexture("$fbtexture", render.GetScreenEffectTexture())

timer.Create("ihategmod", 5, 0, function() -- i really dont know what the fucking problem with cheap scopes they dont want to set texture as not cheap ones
    matRefract_cheap:SetTexture("$fbtexture", render.GetScreenEffectTexture())
    matRefract:SetTexture("$fbtexture", render.GetScreenEffectTexture()) -- not cheap scope here why not
end)

local pp_ca_base, pp_ca_r, pp_ca_g, pp_ca_b = Material("pp/chaosbase/ca_base"), Material("pp/chaosbase/ca_r"), Material("pp/chaosbase/ca_g"), Material("pp/chaosbase/ca_b")
local pp_ca_r_thermal, pp_ca_g_thermal, pp_ca_b_thermal = Material("pp/chaosbase/ca_r_thermal"), Material("pp/chaosbase/ca_g_thermal"), Material("pp/chaosbase/ca_b_thermal")

pp_ca_r:SetTexture("$basetexture", render.GetScreenEffectTexture())
pp_ca_g:SetTexture("$basetexture", render.GetScreenEffectTexture())
pp_ca_b:SetTexture("$basetexture", render.GetScreenEffectTexture())

pp_ca_r_thermal:SetTexture("$basetexture", render.GetScreenEffectTexture())
pp_ca_g_thermal:SetTexture("$basetexture", render.GetScreenEffectTexture())
pp_ca_b_thermal:SetTexture("$basetexture", render.GetScreenEffectTexture())

local greenColor = Color(0, 255, 0)  -- optimized +10000fps
local whiteColor = Color(255, 255, 255)
local blackColor = Color(0, 0, 0)

local ang0 = Angle(0, 0, 0)

SWEP.ViewPunchAngle = Angle(ang0)
SWEP.ViewPunchVelocity = Angle(ang0)

function SWEP:GetOurViewPunchAngles()
    return self:GetOwner():GetViewPunchAngles()
end

local function DrawTexturedRectRotatedPoint( x, y, w, h, rot, x0, y0 ) -- stolen from gmod wiki
    local c = math.cos( math.rad( rot ) )
    local s = math.sin( math.rad( rot ) )

    local newx = y0 * s - x0 * c
    local newy = y0 * c + x0 * s

    surface.DrawTexturedRectRotated( x + newx, y + newy, w, h, rot )
end

local pp_cc_tab = {
    ["$pp_colour_addr"] = 0,
    ["$pp_colour_addg"] = 0,
    ["$pp_colour_addb"] = 0,
    ["$pp_colour_brightness"] = 0, -- why nothing works hh
    ["$pp_colour_contrast"] = 0.9,  -- but same time chroma dont work without calling it
    ["$pp_colour_colour"] = 1,
    ["$pp_colour_mulr"] = 0,
    ["$pp_colour_mulg"] = 0,
    ["$pp_colour_mulb"] = 0
}

function SWEP:FormPP(tex)
	if !render.SupportsPixelShaders_2_0 then return end

	local asight = self:GetActiveSights()

	if asight.Thermal then return end

	local cs = GetConVar("chaosbase_cheapscopes"):GetBool()
	local refract = GetConvar("chaosbase_scopepp_refract"):GetBool()
	local pp = GetConVar("chaosbase_scopepp"):GetBool()

	if refract or pp then
		if !cs then render.PushRenderTraget(tex) end

		if pp then
			render.SetMaterial(pp_ca_base)
			render.DrawScreenQuad()
			render.SetMaterial(pp_ca_r)
			render.DrawScreenQuad()
			render.SetMaterial(pp_ca_g)
			render.DrawScreenQuad()
			render.SetMaterial(pp_ca_b)
			render.DrawScreenQuad()

			DrawColorModify(pp_cc_tab)
			DrawSharpen(-0.1, 5)
		end

		if refract then
			local addads = math.Clamp(additionalFOVconvar:GetFloat(), -2, 14)
			local refractratio = GetConVar("chaosbase_scopepp_refract_ratio"):GetFloat() or 0
			local refractamount = (-0.6 + addads / 30) * refractratio

			refractmat:SetFloat( "$refractamount", refractamount)

			render.SetMaterial(refractmat)
			render.DrawScreenQuad()
		end

		if !cs then render.PopRenderTarget() end
	end
end



function SWEP:FormCheapScope()
	local screen = render.GetRenderTarget()

	render.CopyTexture(sreen, rtmat_spare)

	render.PushRenderTarget(screen)
	cam.Start3D(EyePos(), EyeAngles(), nil, nil, nil, nil, nil, 0, nil)
	cam.End3D()

	self:FormPP(screen)

	render.PopRenderTarget()

	local asight = self:GetActiveSights()

	if asight.Thermal then return end

	if asight.SpecialScopeFunction then
		asight.SpecialScopeFunction(screen)
	end

	render.CopyTexture(screen, rtmat_cheap)

	render.DrawTextureToScreen(rtmat_spare)

	render.UpdateFullScreenDepthTexture()

end

function SWEP:FormRTScope()
	local asight = self:GetActiveSights()

	if !asight then return end

	if !asight.MagnifiedOptic then return end

	local mag = asight.ScopeMagnification

	cam.Start3D()

	ChaosBase.Overdraw = true
	ChaosBase.LaserBehavior = true
	ChaosBase.VMInRT = true

	local rtangles, rtpos, rtdrawvm

	if GetConVar("chaosbase_drawbarrel"):GetBool() and asight.Slot and asight.Slot == 1 then
		rtangles = self.ViewModelAngle - self.ang_cached - (self:GetOurViewPunchAngles() * mag * 0.1)
		rtangles.x = rtangles.x - self.pos_cached.z * 10
        rtangles.y = rtangles.y + self.pos_cached.y * 10

        rtpos = self.ViewModelPos + self.ViewModelAngle:Forward() * (asight.EVPos.y + 7 + (asight.ScopeMagnificationMax and asight.ScopeMagnificationMax / 3))
        rtdrawvm = true
    else
    	rtangles = EyeAngles()
    	rtpos = EyePos()
    	rtdrawvm = false
    end

    local addads = math.Clamp(additionalFOVconvar:GetFloat(), -2, 14)

    local rt = {
    	w = rtsize,
    	h = rtsize,
    	angles = rtangles,
    	origin = rtpos,
    	drawviewmodel = rtdrawvm,
    	fov = self:GetOwner():GetFOV() / mg / 1.2 - (addads or 0) / 4,
    }

    rtsize = ScrH()

    if ScrH() > ScrW() then rtsize = ScrW() end

    local rtres = asight.ForceLowRes and ScrH()*0.6 or ScrH()

    rtmat = GetRenderTarget("chaosbase_rtmat"..rtres, rtres, rtres, false)

    render.PushRenderTarget(rtmat, 0, 0, rtsize, rtsize)

    render.ClearRenderTarget(rt, blackColor)

    if self:GetState() == ChaosBase.STATE_SIGHTS then
    	render.RenderView(rt)
    	cam.Start3D(EyePos(), EyeAngles(), rt.fov, 0, 0, nil, nil, 0, nil)
    	cam.End3D()
    end

    ChaosBase.Overdraw = false
    ChaosBase.VMInRT = false

    self:FormPP(rtmat)

    render.PopRenderTarget()

    cam.End3D()

end

hook.Add("RenderScene", "ChaosBase", function()
	if GetConVar("chaosbase_cheapscopes"):GetBool() then return end

	local wpn = LocalPlayer():GetActiveWeapon()

	if !wpn.ChaosBase then return end

	wpn:FormRTScope()
end)
]]