AddCSLuaFile()
--[[ 
Function Name: DrawWorldModelTranslucent,
Syntax: self:DrawWorldModelTranslucent(flags)
Returns: nothing.
Notes: Draws the Worldmodel with Translucent Flags (aka fuck you garry).
Purpose: SWEP Rendering.
]]--
function SWEP:DrawWorldModelTranslucent(flags)
	if not IsValid(self.m_WorldModel) then
		self:RecreateClientsideModels()
	end

	render.SetBlend(0)
	self:DrawModel()
	render.SetBlend(1)

	local ply = self:GetOwner()

	if IsValid(ply) then
            local offsetVec = Vector(self.WorldModelOffsetPos)
            local offsetAng = Angle(self.WorldModelOffsetAng)

            local ModelScale = self.WepScale

            local HighTierTable = self.HighTier
            local index = ply:getJobTable().category or ply:getJobTable().name

            if HighTierTable[index] then
                ModelScale = ply:GetNW2Float("Chaos.PlayerScale")
                if HighTierTable[index].Type == "SPARTAN" then
                    offsetVec = Vector(self.SparWorldModelOffsetPos)
                    offsetAng = Angle(self.SparWorldModelOffsetAng)
                end
            end

            local boneid = ply:LookupBone("ValveBiped.Bip01_R_Hand")
            if not boneid then return end

            local matrix = ply:GetBoneMatrix(boneid)
            if not matrix then return end

            local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

			self.m_WorldModel:SetPos(newPos)
			self.m_WorldModel:SetAngles(newAng)

			self.m_WorldModel:SetupBones()

			self:RenderModelsWorld(self.m_WorldModel, 0)

            self.m_WorldModel:SetModelScale(ModelScale)

            --ThirdPerson Bolt Handling
            if not self.BlowbackBoneMods then
            	self.BlowbackBoneMods = {}
            	self.BlowbackCurrent = 0
            end

            self.BlowbackCurrent = math.Approach(self.BlowbackCurrent, 0, self.BlowbackCurrent * FrameTime() * 30)

            if self.BlowbackBoneMods then
            	for boltname, tbl in pairs(self.BlowbackBoneMods) do
            		local bolt = self.m_WorldModel:LookupBone(self.BoltWorldModelBone)

            		if bolt and bolt >= 0 then
            			bpos = tbl.pos * self.BlowbackCurrent
            			self.m_WorldModel:ManipulateBonePosition(bolt,bpos)
            		end
            	end
        	end
            
        else
            self.m_WorldModel:SetPos(self:GetPos())
            self.m_WorldModel:SetAngles(self:GetAngles())
        end

end


--[[ 
Function Name: RenderModelsWorld
Syntax: self:RenderModelsWorld(ent)
Returns: nothing.
Notes: Draws the Worldmodel with Translucent Flags (aka fuck you garry).
Purpose: SWEP Rendering.
]]--
function SWEP:RenderModelsWorld(ent)
	ent:DrawModel()

	for i, child in pairs(ent:GetChildren()) do
		self:RenderModelsWorld(child)
	end
end