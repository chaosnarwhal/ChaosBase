AddCSLuaFile()

--[[---------------------------------------------------------
	Name: SWEP:Think()
	Desc: Called every frame
-----------------------------------------------------------]]
function SWEP:Think()
	local ply = self:GetOwner()
	if !IsValid(ply) or !ply:Alive() then return end
	local cv = ply:Crouching()
	local vm = ply:GetViewModel()
	local hands = ply:GetHands()
	local reloadkeyheld = ply:KeyDown(IN_RELOAD)

	if self.Loading == false && self.Inspecting == false then
		self:Rev_ManageAnims()
	end

	self:CustomThink()

	if CLIENT then
		local wl = ply:WaterLevel()
		local oa = self.OwnerActivity
		
		if (ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT) or ply:KeyDown(IN_BACK) or ply:KeyDown(IN_FORWARD)) && cv == false && wl <= 2 then
			if ply:KeyDown(IN_SPEED) then self.OwnerActivity = "sprinting"
			else self.OwnerActivity = "running" end
		elseif (ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT) or ply:KeyDown(IN_BACK) or ply:KeyDown(IN_FORWARD)) && cv == true && wl <= 2 then
			if ply:KeyDown(IN_SPEED) then self.OwnerActivity = "crouchsprinting"
			else self.OwnerActivity = "crouchrunning" end
		elseif (!ply:KeyDown(IN_MOVELEFT) or !ply:KeyDown(IN_MOVERIGHT) or !ply:KeyDown(IN_BACK) or !ply:KeyDown(IN_FORWARD)) && cv == false && wl <= 2 then
			self.OwnerActivity = "standidle"
		elseif (!ply:KeyDown(IN_MOVELEFT) or !ply:KeyDown(IN_MOVERIGHT) or !ply:KeyDown(IN_BACK) or !ply:KeyDown(IN_FORWARD)) && cv == true && wl <= 2 then
			self.OwnerActivity = "crouchidle"
		elseif (ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT) or ply:KeyDown(IN_BACK) or ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_JUMP)) && wl > 2 then
			if ply:KeyDown(IN_SPEED) then self.OwnerActivity = "fastswimming"
			else self.OwnerActivity = "swimming" end
		elseif (!ply:KeyDown(IN_MOVELEFT) or !ply:KeyDown(IN_MOVERIGHT) or !ply:KeyDown(IN_BACK) or !ply:KeyDown(IN_FORWARD)) && wl > 2 then
			self.OwnerActivity = "swimidle"
		end
	end

end

function SWEP:CustomThink()
end