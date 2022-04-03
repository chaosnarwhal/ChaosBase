AddCSLuaFile()

function SWEP:PreDrawViewModel(vm)

    --Weapon SWAY code does not work, needs re-write.
    self:CalculateViewModelOffset(delta)
    self:CalculateViewModelFlip()

    --[[
    local asight = self:GetActiveSights()

    if asight then
        if GetConVar("chaosbase_cheapscopes"):GetBool() and self:GetAimDelta() < 1 and asight.MagnifiedOptic then
            self:FormCheapScope()
        end

        if self:GetAimDelta() < 1 and asight.ScopeTexture then
            self:FormCheapScope()
        end
    end
    ]]
end