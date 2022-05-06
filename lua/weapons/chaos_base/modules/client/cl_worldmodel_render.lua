AddCSLuaFile()

function SWEP:DrawWorldModelTranslucent(flags)
	if not IsValid(self.m_WorldModel) then
		self:RecreateClientsideModels()
	end

	render.SetBlend(0)
	self:DrawModel()
	render.SetBlend(1)

	local pos, ang = self:GetBonePosition(0)
	local wPos = self:GetPos()
	self.m_WorldModel:SetPos(wPos + (pos - wPos))

	local wAng = self:GetAngles()
	self.m_WorldModel:SetAngles(wAng + (ang - wAng))

	local bone = self:LookupBoneCached(self.m_WorldModel, self.WorldModelOffsets.Bone)

	self:RenderParticles(self.TpParticles)

	self.m_WorldModel:SetupBones()

	self:RenderModelsWorld(self.m_WorldModel, 0)

end

function SWEP:RenderModelsWorld(ent)
	ent:DrawModel()

	for i, child in pairs(ent:GetChildren()) do
		self:RenderModelsWorld(child)
	end
end