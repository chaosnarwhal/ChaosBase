function SWEP:Deploy()
	if not IsValid(self:GetOwner()) or self:GetOwner():IsNPC() then
    	return
    end

    self:InitTimers()

	self:SetReloading(false)
    self:SetState(0)
    self:SetMagUpCount(0)
    self:SetMagUpIn(0)
    self:SetShotgunReloading(0)
    self:SetHolster_Time(0)
    self:SetHolster_Entity(NULL)

    self:SetBurstCount(0)

    if self.Owner:KeyDown(IN_ATTACK2) and self.SightWhileDraw then
		self:SetIronSights(true)
	end

    if not self:GetOwner():InVehicle() then
    	local prd = false

    	local r_anim = self:SelectAnimation("ready")
    	local d_anim = self:SelectAnimation("draw")

    	if self.Animations[r_anim] and self.UnReady then
    		self:PlayAnimation(r_anim, 1, true, 0, false)
    		prd = self.Animations[r_anim].ProcDraw

    		self:SetReloading(CurTime() + ( prd and 0.5 or self:GetAnimKeyTime(r_anim, true)))
    	elseif self.Animations[d_anim] then
    		self:PlayAnimation(d_anim, self.DrawTime, true, 0, false)
    		prd = self.Animations[d_anim].ProcDraw

    		self:SetReloading(CurTime() + (prd and 0.5 or (self:GetAnimKeyTime(d_anim,true) * self.DrawTime) ) )
    	end

    	if self.UnReady then
    		if SERVER then
    			self:initialDefaultClip()
    		end
    		self.UnReady = false
    	end
	end
end

function SWEP:initialDefaultClip()
    if not self.Primary.Ammo then return end
    if engine.ActiveGamemode() == "darkrp" then return end -- DarkRP is god's second biggest mistake after gmod
end

function SWEP:Initialize()
	if (not IsValid(self:GetOwner()) or self:GetOwner():IsNPC()) and self:IsValid() and self.NPC_Initialize and SERVER then
        self:NPC_Initialize()
    end

    if game.SinglePlayer() and self:GetOwner():IsValid() and SERVER then
        self:CallOnClient("Initialize")
    end

    self:SetState(0)
    self:SetClip2(0)
    self:SetLastLoad(self:Clip1())
    self:SetHoldType(self.HoldtypeActive)

    local og = weapons.Get(self:GetClass())

    self.RegularClipSize = og.Primary.ClipSize

    self.OldPrintName = self.PrintName

    if CLIENT then
    	self:InitMods()
    end

    self:InitTimers()
end

function SWEP:Holster(wep)
	if not IsFirstTimePredicted() then return end
    if self:GetOwner():IsNPC() then return end

     if self:GetBurstCount() > 0 and self:Clip1() > 0 then return false end

    if CLIENT and LocalPlayer() != self:GetOwner() then
        return
    end

    self:FinishHolster()

    if self:GetHolster_Time() > CurTime() then return false end

    if (self:GetHolster_Time() != 0 and self:GetHolster_Time() <= CurTime()) or not IsValid(wep) then
        self:SetHolster_Time(0)
        self:SetHolster_Entity(NULL)
        self:FinishHolster()
        return true

    else

    	self.Sighted = false
        self.Sprinted = false
        self:SetShotgunReloading(0)
        self:SetMagUpCount(0)
        self:SetMagUpIn(0)

    	local time = 0.25
    	self:SetHolster_Time(CurTime() + time * self.DrawTime)
    	self:SetReloading(CurTime() + time * self.DrawTime)
        self:SetWeaponOpDelay(CurTime() + time * self.DrawTime)
    end

end

function SWEP:FinishHolster()
	self:KillTimers()

	if self:GetOwner():IsNPC() then return end
end