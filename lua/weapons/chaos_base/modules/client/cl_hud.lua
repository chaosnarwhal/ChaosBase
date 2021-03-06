local White, Black = Color(255, 255, 255, 255), Color(0, 0, 0, 255)
local x, y, x2, y2, lp, size, FT, CT, tr, x3, x4, y3, y4, UCT, sc1, sc2
local td = {}

local surface = surface
local math = math
local draw = draw
local dst = draw.SimpleText

function draw.ShadowText(text, font, x, y, colortext, colorshadow, dist, xalign, yalign)
    dst(text, font, x + dist, y + dist, colorshadow, xalign, yalign)
    dst(text, font, x, y, colortext, xalign, yalign)
end


function SWEP:DrawHUD()
    if not self:IsFirstPerson() then return end
    --self:Crosshair()
    self:BipodUse()
    self:ChaosCustomCrossHairElements()
end

function SWEP:ChaosCustomCrossHairElements()
end

function SWEP:BipodUse()
    FT, CT, x, y = FrameTime(), CurTime(), ScrW(), ScrH()
    UCT = UnPredictedCurTime()

    if not self.dt.BipodDeployed then 
        if self.BipodInstalled then
            if self:CanRestWeapon(self.BipodDeployHeightRequirement) then
                draw.ShadowText("[USE KEY]", DermaDefault, x / 2, y / 2 + 100, White, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        else
            if self:GetIsAiming() then
                if self.CanRestOnObjects then
                    if self:CanRestWeapon(self.WeaponRestHeightRequirement) then
                        draw.ShadowText("[RESTED]", DermaDefault, x / 2, y / 2 + 100, White, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                end
            end
        end
    else
        draw.ShadowText("[DEPLOYED]", DermaDefault, x / 2, y / 2 + 100, White, Black, 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

--[[
function SWEP:DrawCrosshairSticks(x, y)
    local aimDelta = 1 - self:GetAimDelta()
    local crosshairAlpha = 200

    --dot
    local c = self:GetCone()
    local m = self.Cone.Max
    local h = self.Cone.Hip
    local dotDelta = (c - h) / (m - h) 
    if (m - h <= 0) then
        dotDelta = 0
    end

    local color = Color(255,255,255)
    surface.SetDrawColor(color.r, color.g, color.b, 200)

    surface.SetAlphaMultiplier(aimDelta * (1 - dotDelta))
    surface.DrawRect(x - 1, y - 1, 2, 2)

    local cone = self:GetCone() * 100
        
    --right stick
    surface.DrawRect(x + cone + 3, y - 1, 10, 2)
        
    --left stick
    surface.DrawRect(x - cone - 9 - 3, y - 1, 10, 2)

    --down stick
    surface.DrawRect(x - 1, y + cone + 3, 2, 10)
        
    if (self.Primary.Automatic) then
        --up stick
        surface.DrawRect(x - 1, y - cone - 9 - 3, 2, 10)
    end

    surface.SetAlphaMultiplier(1)
    surface.SetDrawColor(255, 255, 255, 255)
end

function SWEP:Crosshair()
    if (self._eyeang == nil) then
        return
    end
    
    local x, y = ScrW() * 0.5, ScrH() * 0.5
    local pos = (EyePos() + self._eyeang:Forward() * 10):ToScreen()

    if (Vector(x, 0, y):Distance(Vector(pos.x, 0, pos.y)) > 1.5) then
        x,y = math.floor(pos.x), math.floor(pos.y)
    end

    --self:DrawCrosshairSticks(x, y)
    --self:halo_Crosshair(x,y)
end
]]
