AddCSLuaFile()

--[[ 
Function Name: DrawWorldModelTranslucent,
Syntax: self:DrawWorldModelTranslucent(flags)
Returns: nothing.
Notes: Draws the Worldmodel with Translucent Flags (aka fuck you garry).
Purpose: SWEP Rendering.
]]
--
function SWEP:DrawWorldModelTranslucent(flags)
    if not IsValid(self.c_WorldModel) then
        self:RecreateClientsideModels()
    end

    render.SetBlend(0)
    self:DrawModel()
    render.SetBlend(1)
    local ply = self:GetOwner()

    local offsetVec = Vector(self.WorldModelOffsetPos)
    local offsetAng = Angle(self.WorldModelOffsetAng)
    local ModelScale = self.WepScale
    local HighTierTable = self.HighTier
    local elementOffsetVec = Vector(0,0,0)

    if IsValid(ply) then
        local index = ply:getJobTable().category or ply:getJobTable().name or nil
    end

    if IsValid(ply) then
        if self:GetClassType() == "SPARTAN" then
            ModelScale = ply:GetNW2Float("Chaos.PlayerScale")
            offsetVec = Vector(self.SparWorldModelOffsetPos)
            offsetAng = Angle(self.SparWorldModelOffsetAng)
            elementOffsetVec = Vector(1.5,0.15,2)
        end

        local boneid = ply:LookupBone("ValveBiped.Bip01_R_Hand")
        if not boneid then return end
        local matrix = ply:GetBoneMatrix(boneid)
        if not matrix then return end
        local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
        self.c_WorldModel:SetPos(newPos)
        self.c_WorldModel:SetAngles(newAng)
        self.c_WorldModel:SetupBones()
        self:RenderModelsWorld(self.c_WorldModel, 0)
        self.c_WorldModel:SetModelScale(ModelScale)

        --ThirdPerson Bolt Handling
        if not self.BlowbackBoneModsWorldModel then
            self.BlowbackBoneModsWorldModel = {}
            self.BlowbackCurrent = 0
        end

        if self.BlowbackBoneModsWorldModel then
            for boltname, tbl in pairs(self.BlowbackBoneModsWorldModel or self.BlowbackBoneMods) do
                local bolt = self.c_WorldModel:LookupBone(self.BoltWorldModelBone)

                if bolt and bolt >= 0 then
                    bpos = tbl.pos * self.BlowbackCurrent
                    self.c_WorldModel:ManipulateBonePosition(bolt, bpos)
                end
            end
        end
    else
        self.c_WorldModel:SetPos(self:GetPos())
        self.c_WorldModel:SetAngles(self:GetAngles())
    end

    if not self.WElements then return end

    if not self.wRenderOrder then
        self.wRenderOrder = {}

        for k, v in pairs(self.WElements) do
            if v.type == "Model" then
                table.insert(self.wRenderOrder, 1, k)
            elseif v.type == "Sprite" or v.type == "Quad" then
                table.insert(self.wRenderOrder, k)
            end
        end
    end

    if IsValid(self:GetOwner()) then
        bone_ent = self:GetOwner()
    else
        -- when the weapon is dropped
        bone_ent = self
    end

    for k, name in pairs(self.wRenderOrder) do
        local v = self.WElements[name]

        if not v then
            self.wRenderOrder = nil
            break
        end

        if v.hide then continue end
        local pos, ang

        if v.bone then
            pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent)
        else
            pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent, "Bip01_R_Hand")
        end

        if self.WElementsPosAdd and self.WElementsPosScale then
            if self:IsHighTier() then
                v.pos = self.WElementPosAdd
                v.size = self.WelemntPosScale
            end
        end

        if not pos then continue end
        local model = v.modelEnt
        local sprite = v.spriteMaterial

        if v.type == "Model" and IsValid(model) then
            model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
            ang:RotateAroundAxis(ang:Up(), v.angle.y)
            ang:RotateAroundAxis(ang:Right(), v.angle.p)
            ang:RotateAroundAxis(ang:Forward(), v.angle.r)
            model:SetAngles(ang)
            --model:SetModelScale(v.size)
            local matrix = Matrix()
            matrix:Scale(v.size)
            model:EnableMatrix("RenderMultiply", matrix)

            if v.material == "" then
                model:SetMaterial("")
            elseif model:GetMaterial() ~= v.material then
                model:SetMaterial(v.material)
            end

            if v.skin and v.skin ~= model:GetSkin() then
                model:SetSkin(v.skin)
            end

            if v.bodygroup then
                for k, v in pairs(v.bodygroup) do
                    if model:GetBodygroup(k) ~= v then
                        model:SetBodygroup(k, v)
                    end
                end
            end

            if v.surpresslightning then
                render.SuppressEngineLighting(true)
            end

            render.SetColorModulation(v.color.r / 255, v.color.g / 255, v.color.b / 255)
            render.SetBlend(v.color.a / 255)
            model:DrawModel()
            render.SetBlend(1)
            render.SetColorModulation(1, 1, 1)

            if v.surpresslightning then
                render.SuppressEngineLighting(false)
            end
        elseif v.type == "Sprite" and sprite then
            local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
            render.SetMaterial(sprite)
            render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
        elseif v.type == "Quad" and v.draw_func then
            local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
            ang:RotateAroundAxis(ang:Up(), v.angle.y)
            ang:RotateAroundAxis(ang:Right(), v.angle.p)
            ang:RotateAroundAxis(ang:Forward(), v.angle.r)
            cam.Start3D2D(drawpos, ang, v.size * ( 1 or ply:GetNW2Float("Chaos.PlayerScale") ) )
            v.draw_func(self)
            cam.End3D2D()
        end
    end
    self:RenderModelsWorld(self.c_WorldModel, 0)
end

--[[ 
Function Name: RenderModelsWorld
Syntax: self:RenderModelsWorld(ent)
Returns: nothing.
Notes: Draws the Worldmodel with Translucent Flags (aka fuck you garry).
Purpose: SWEP Rendering.
]]
--
function SWEP:RenderModelsWorld(ent)
    ent:DrawModel()

    for i, child in pairs(ent:GetChildren()) do
        self:RenderModelsWorld(child)
    end
end