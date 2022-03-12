AddCSLuaFile()

function SWEP:PostDrawViewModel(vm, weapon, ply)
	if (ply == NULL) then return end

	if not IsValid(self.m_ViewModel) then
		self:RecreateClientsideModels(true)
	end

	if ply:InVehicle() then
        return
    end

    if self.m_seqIndex == "INIT" then end

     if (self.m_drawWorkaround) then
        self.m_ViewModel:FrameAdvance()
        self.m_ViewModel:SetCycle(0)

        self.m_drawWorkaround = false

        return
    end

end