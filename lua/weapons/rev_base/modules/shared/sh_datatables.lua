AddCSLuaFile()

--[[---------------------------------------------------------
	Name: SWEP:SetupDataTables()
	Desc: Initailize the Data Tables for the player.
-----------------------------------------------------------]]
function SWEP:SetupDataTables()
   self:NetworkVar("Bool", 3, "IronsightsPredicted")
   self:NetworkVar("Float", 3, "IronsightsTime")
   self:NetworkVar("Bool", 3, "Passive")
   self:NetworkVar("Bool", 3, "Inspecting")
   self:NetworkVar("Bool", 3, "Melee")
end
