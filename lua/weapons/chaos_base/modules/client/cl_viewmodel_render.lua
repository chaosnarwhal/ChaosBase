AddCSLuaFile()

function SWEP:PostDrawViewModel(vm, weapon, ply)
    --[[
    if not IsValid(self.c_ViewModel) then
        self:RecreateClientsideModels(true)
    end

    self:GetOwner():GetHands():SetParent(self.c_ViewModel)
    self:GetOwner():GetHands():AddEffects(EF_BONEMERGE)

    self:RenderModels(self.c_ViewModel)
    ]]

    --ThirdPerson Bolt Handling
    if not self.BlowbackBoneMods then
        self.BlowbackBoneMods = {}
        self.BlowbackCurrent = 0
    end
    if self.BlowbackBoneMods then
        for boltname, tbl in pairs(self.BlowbackBoneMods) do
            local bolt = vm:LookupBone(self.BoltViewModelBone)

            if bolt and bolt >= 0 then
                bpos = tbl.pos * self.BlowbackCurrent
                bang = tbl.angle * self.BlowbackCurrent
                vm:ManipulateBonePosition(bolt, bpos)
                vm:ManipulateBoneAngles(bolt, bang)
                if self.BoltViewModelBoneExtra then
                    local bolt2 = vm:LookupBone(self.BoltViewModelBoneExtra)
                    vm:ManipulateBonePosition(bolt2, bpos)
                    vm:ManipulateBoneAngles(bolt2, bang)
                end
            end
        end
    end
end

function SWEP:RenderModels(ent)

    local pos = EyePos()
    ent:SetSaveValue("m_vecOrigin", pos)
    ent:SetSaveValue("m_vecAbsOrigin", pos)

    ent:DrawModel()

    for i, child in pairs(ent:GetChildren()) do
        self:RenderModels(child)
    end
end