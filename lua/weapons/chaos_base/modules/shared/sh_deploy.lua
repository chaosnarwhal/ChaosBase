AddCSLuaFile()

--[[ 
Function Name: Deploy.
Syntax: self:Deploy().
Returns: nothing.
Notes: Code to play when pulling the swep out.
Purpose: SWEP Main function.
]]
--
function SWEP:Deploy(fromFallback)
    fromFallback = fromFallback or false
    if not IsValid(self:GetOwner()) or self:GetOwner():IsNPC() then return end
    self:IsAuthorizedToUse()
    self:HoldTypeHandler()
    self:IsHighTier()
    self:ChaosCustomDeploy()
    --Reset NW Values when weapon is pulled out.
    self:SetReloading(false)
    self:SetState(0)
    self:SetMagUpCount(0)
    self:SetMagUpIn(0)
    self:SetShotgunReloading(0)
    self:SetNextHolsterTime(0)
    self:SetIsReloading(false)
    self:SetNextWeapon(NULL)
    self:SetIsPumping(false)
    self.OwnerViewModel = nil
    self:SetBurstRounds(0)
    self:SetSafety(false)
    self:SetIsFiring(false)
    self:SetHoldType(self.HoldtypeActive)
    self:SetIsSprinting(false)

    if not self:GetOwner():InVehicle() then
        local prd = false
        local r_anim = self:SelectAnimation("ready")
        local d_anim = self:SelectAnimation("draw")

        if self.Animations[r_anim] and self.UnReady then
            self:PlayAnimation(r_anim, 1, true, 0, false)
            prd = self.Animations[r_anim].ProcDraw
            self:SetReloading(CurTime() + (prd and 0.5 or self:GetAnimKeyTime(r_anim, true)))
        elseif self.Animations[d_anim] then
            self:PlayAnimation(d_anim, self.DrawTime, true, 0, false)
            prd = self.Animations[d_anim].ProcDraw
            self:SetReloading(CurTime() + (prd and 0.5 or (self:GetAnimKeyTime(d_anim, true) * self.DrawTime)))
        end

        if self.UnReady then
            if SERVER then
                self:initialDefaultClip()
            end

            self.UnReady = false
        end
    end

    return true
end

function SWEP:ChaosCustomDeploy()
end

--[[ 
Function Name: initialDefaultClip.
Syntax: self:initialDefaultClip().
Returns: nothing.
Notes: Code to play when pulling the swep out.
Purpose: SWEP Main function.
]]
--
function SWEP:initialDefaultClip()
    if not self.Primary.Ammo then return end
    if engine.ActiveGamemode() == "darkrp" then return end -- DarkRP is god's second biggest mistake after gmod
end

--[[ 
Function Name: Initialize.
Syntax: self:Initialize().
Returns: nothing.
Notes: Code to play when the SWEP is initialized by the server.
Purpose: SWEP Main function.
]]
--
function SWEP:Initialize()
    if (not IsValid(self:GetOwner()) or self:GetOwner():IsNPC()) and self:IsValid() and self.NPC_Initialize and SERVER then
        self:NPC_Initialize()
    end

    if game.SinglePlayer() and self:GetOwner():IsValid() and SERVER then
        self:CallOnClient("Initialize")
    end

    self:ChaosCustomInitialize()
    self:SetState(0)
    self:SetClip2(0)
    self:SetLastLoad(self:Clip1())
    self:SetHoldType(self.HoldtypeActive)
    self:SetFireMode(1)
    self:SetIsSprinting(false)
    self:SetIsPumping(false)
    --m_Funcs
    self.m_bHolstered = false
    self.m_bDrawn = false
    self:SetIsHolstering(false)
    self:SetNextHolsterTime(0)
    self:SetBreathingDelta(1)
    self.w_Model = self.WorldModel
    self:SetIsFiring(false)
    local og = weapons.Get(self:GetClass())
    self.RegularClipSize = og.Primary.ClipSize
    self.OldPrintName = self.PrintName
    self.m_OriginalViewModelFOV = self.ViewModelFOV

    if CLIENT then
        self.Camera = {
            Shake = 0,
            Fov = 0,
            LerpReloadFov = 0,
            LerpReloadBlur = 0,
            LerpCustomization = 0,
            LerpBreathing = Angle(0, 0, 0)
        }

        self.Particles = {}

        self.ViewModelVars = {
            LerpAimDelta = 0,
            LerpAimPos = Vector(0, 0, 0),
            LerpAimAngles = Angle(0, 0, 0),
            LerpJogOffset = 0,
            LerpJog = 0,
            LerpWalk = 0,
            bWasJogging = false,
            bJogging = false,
            bWasCrouching = false,
            LerpForward = 0,
            LerpRight = 0,
            LerpCustomizationPlayback = 1,
            bWasOnGroundAnim = false,
            Sway = {
                X = {
                    Sway = 0,
                    Direction = 0,
                    Ang = 0,
                    Lerp = 0
                },
                PosX = {
                    Sway = 0,
                    Direction = 0,
                    Ang = 0,
                    Lerp = 0
                },
                Y = {
                    Sway = 0,
                    Direction = 0,
                    Ang = 0,
                    Lerp = 0
                },
                PosY = {
                    Sway = 0,
                    Direction = 0,
                    Ang = 0,
                    Lerp = 0
                },
                PosForward = {
                    Sway = 0,
                    Direction = 0,
                    Ang = 0,
                    Lerp = 0
                }
            },
            Jump = {
                Velocity = 0,
                bWasOnGround = true,
                Force = 0,
                ForceZ = 0,
                Time = 0,
                Lerp = 0,
                LerpZ = 0
            },
            Recoil = {
                Translation = Vector(0, 0, 0),
                Rotation = Angle(0, 0, 0)
            },
            LerpCrouch = Vector(0, 0, 0)
        }
    end
end

function SWEP:ChaosCustomInitialize()
end

--[[ 
Function Name: Holster.
Syntax: self:Holster(wep).
Returns: returns if allowed to swap weapons or not.
Notes: Code when ran to allow swapping of weapon and to what weapon?.
Purpose: SWEP Main function.
]]
--
function SWEP:Holster(weapon, fromFallback)
    if not IsValid(self:GetOwner()) then return end

    if not self:GetIsHolstering() and fromFallback then
        self:SetIsHolstering(true)
        self:SetIsReloading(false)
        self:SetIsPumping(false)
        self:SetBurstRounds(0)
        self:SetNextHolsterTime(CurTime())
    end

    self:SetNextWeapon(weapon)
    if self:GetOwner():GetMoveType() == MOVETYPE_LADDER then return false end

    return CurTime() >= self:GetNextHolsterTime() or self:IsDrawing() or not IsValid(weapon)
end

--[[ 
Function Name: IsAuthorizedToUse.
Syntax: self:IsAuthorizedToUse().
Returns: returns if allowed to Use a Protected Weapon.
Purpose: SWEP Aux function.
]]
--
function SWEP:IsAuthorizedToUse()
    if not self.AuthorizedUserEnable then return end
    if not IsValid(self) then return end
    local AuthorizedToUse = self.AuthorizedUser
    local ply = self:GetOwner()

    if AuthorizedToUse[ply:SteamID64() or ply:getJobTable().category or ply:getJobTable().name] then
        return true
    else
        timer.Simple(0.1, function()
            ply:StripWeapon(self:GetClass())
        end)

        return false
    end
end

--[[ 
Function Name: IsHighTier.
Syntax: self:IsHighTier(Allowed, RecoilReduce, SprintShoot).
Returns: Returns Some Values from a HighTier Table. Only if the player is Allowed the HighTier Values.
Purpose: SWEP Aux function.
]]
--
function SWEP:IsHighTier(Allowed)
    if not self.HighTierAllow then return end
    local HighTierTable = self.HighTier
    local ply = self:GetOwner()
    local index = ply:getJobTable().category or ply:getJobTable().name

    if HighTierTable[index] then
        Allowed = HighTierTable[index]
        return Allowed
    else
        return false
    end
end

function SWEP:IsSpartan()
    if not self.HighTierAllow then return end
    local HighTeirTable = self.HighTier
    local ply = self:GetOwner()
    local index = ply:getJobTable().category or ply:getJobTable().name

    if HighTierTable[index] == "SPARTAN" then
        return true
    else
        return nil
    end
end

function SWEP:RecoilReduce()
    if not self.HighTierAllow then return end
    local HighTeirTable = self.HighTier
    local ply = self:GetOwner()
    local index = ply:getJobTable().category or ply:getJobTable().name

    if HighTeirTable[index] then
        return HighTeirTable[index].RecoilReduce or 1
    else
        return 1
    end
end

function SWEP:CanSprintShoot()
    if not self.HighTierAllow then return end
    local HighTeirTable = self.HighTier
    local ply = self:GetOwner()
    local index = ply:getJobTable().category or ply:getJobTable().name

    if HighTierTable[index] then
        return HighTierTable[index].SprintShoot
    else
        return false
    end
end