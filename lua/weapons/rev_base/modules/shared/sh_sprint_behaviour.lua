AddCSLuaFile()

function SWEP:CanSprint()
    return !self:IsDrawing() 
        && !self:GetIsHolstering() 
        && CurTime() > self:GetNextPrimaryFire()
        && (self:GetSafety() || self:GetOwner():WaterLevel() > 2 || self:GetOwner():KeyDown(IN_FORWARD) || self:GetOwner():KeyDown(IN_BACK) || self:GetOwner():KeyDown(IN_MOVERIGHT) || self:GetOwner():KeyDown(IN_MOVELEFT)) --checking velocity can sometimes cause desyncs (touching server entities while sprinting)
        --&& self:GetOwner():GetVelocity():LengthSqr() > 0
        --&& self:GetOwner():EyeAngles():Forward():Dot(self:GetOwner():GetVelocity())--(!game.SinglePlayer() && self:GetOwner():GetCurrentCommand():GetForwardMove() > 0 || self:GetOwner():KeyDown(IN_FORWARD))
        --&& self:GetOwner():GetVelocity():Length() > 30 
        && (self:GetOwner():WaterLevel() > 2 || (!self:GetOwner():Crouching() || self:GetSafety()))
        && CurTime() > self:GetNextFiremodeTime()
        && CurTime() > self:GetNextMeleeTime()
        --&& !self:IsCustomizing()
end

--[[ 
Function Name:  SprintModule
Syntax: self:SprintModule().  This is called per-think.
Returns:  Nothing. 
Notes:  This corrects ironsights so that you can't sight and sprint at the same time, etc.
Purpose:  Feature.
]]--

function SWEP:SprintModule()
	if CLIENT && game.SinglePlayer() then return end

	if self:GetOwner():KeyDown(IN_SPEED) || self:GetOwner():WaterLevel() > 2 || self:CanSprint() then

		if not self:GetIsSprinting() then
			if IsFirstTimePredicted() then self:PlayViewModelAnimation("Sprint") end
		end

		self:SetIsSprinting(true)
		self:SetIsReloading(false)

	else
		
		self:SetIsSprinting(false)
	end	
end