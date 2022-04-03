AddCSLuaFile()

local lst2 = SysTime()
function SWEP:PreDrawViewModel(vm)
    if ChaosBase.VM_OverDraw then return end
    if not vm then return end

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