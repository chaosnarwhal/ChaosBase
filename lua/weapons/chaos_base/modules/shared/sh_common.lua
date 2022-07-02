AddCSLuaFile()
--[[
Function Name:  GetMuzzlePos
Syntax: self:GetMuzzlePos( hacky workaround that doesn't work anyways ).
Returns:   The AngPos for the muzzle attachment.
Notes:  Defaults to the first attachment, and uses GetFPMuzzleAttachment
Purpose:  Utility
]]
--
local fp

local reg = debug.getregistry()
local GetVelocity = reg.Entity.GetVelocity
local Length = reg.Vector.Length
local GetAimVector = reg.Player.GetAimVector

ChaosBase.LimbCompensation = {
    [1] = {
        [HITGROUP_HEAD]     = 1 / 2,
        [HITGROUP_LEFTARM]  = 1 / 0.25,
        [HITGROUP_RIGHTARM] = 1 / 0.25,
        [HITGROUP_LEFTLEG]  = 1 / 0.25,
        [HITGROUP_RIGHTLEG] = 1 / 0.25,
        [HITGROUP_GEAR]     = 1 / 0.25,
    },
}

function SWEP:GetMuzzleAttachment()
    local vmod = self:GetOwner():GetViewModel()
    local att = math.max(1, self.MuzzleAttachmentRaw or (sp and vmod or self):LookupAttachment(self.MuzzleAttachment))

    return att
end

function SWEP:GetMuzzlePos(ignorepos)
    fp = self:IsFirstPerson()
    local vm = self:GetOwner():GetViewModel()

    if not IsValid(vm) then
        vm = self
    end

    -- Avoid returning strings inside MuzzleAttachmentMod, since this would decrease performance
    -- Better call :UpdateMuzzleAttachment() or return number in MuzzleAttachmentMod
    local obj = self.MuzzleAttachmentRaw or vm:LookupAttachment(self.MuzzleAttachment)

    if type(obj) == "string" then
        obj = tonumber(obj) or vm:LookupAttachment(obj)
    end

    local muzzlepos
    obj = math.Clamp(obj or 1, 1, 128)

    if fp then
        muzzlepos = vm:GetAttachment(obj)
    else
        muzzlepos = self:GetAttachment(obj)
    end

    return muzzlepos
end

function SWEP:UpdateMuzzleAttachment()
    local vm = self.OwnerViewModel
    if not IsValid(vm) then return end
    self.MuzzleAttachmentRaw = nil

    if not self.MuzzleAttachmentRaw and self.MuzzleAttachment then
        self.MuzzleAttachmentRaw = vm:LookupAttachment(self.MuzzleAttachment)

        if not self.MuzzleAttachmentRaw or self.MuzzleAttachmentRaw <= 0 then
            self.MuzzleAttachmentRaw = 1
        end
    end
end

--[[
Function Name:  IsFirstPerson
Syntax: self:IsFirstPerson().
Returns:   Is the owner in first person.
Notes:  Broken in singplayer because gary.
Purpose:  Utility
]]--
function SWEP:IsFirstPerson()
    if not IsValid(self) or not IsValid(self:GetOwner()) then return false end
    if self:GetOwner():IsNPC() then return false end
    if CLIENT and (not game.SinglePlayer()) and self:GetOwner() ~= GetViewEntity() then return false end
    if self:GetOwner().ShouldDrawLocalPlayer and self:GetOwner():ShouldDrawLocalPlayer() then return false end
    if LocalPlayer and hook.Call("ShouldDrawLocalPlayer", GAMEMODE, self:GetOwner()) then return false end

    return true
end

function SWEP:VMIV()
    local owent = self:GetOwner()

    if not IsValid(self.OwnerViewModel) then
        if IsValid(owent) and owent.GetViewModel then
            self.OwnerViewModel = owent:GetViewModel()
        end

        return false
    else
        if not IsValid(owent) or not owent.GetViewModel then
            self.OwnerViewModel = nil

            return false
        end

        return self.OwnerViewModel
    end
end

function ChaosBase.Cubic(t)
    return -2 * t * t * t + 3 * t * t
end

local mins, maxs = Vector(-8, -8, -1), Vector(8, 8, 1)
local td = {}
td.mins = mins
td.maxs = maxs

function SWEP:CanRestWeapon(height)
    height = height or -1
    local vel = Length(GetVelocity(self:GetOwner()))
    local pitch = self:GetOwner():EyeAngles().p
    
    if vel == 0 and pitch <= 60 and pitch >= -20 then
        local sp = self:GetOwner():GetShootPos()
        local aim = self:GetOwner():GetAimVector()
        
        td.start = sp
        td.endpos = td.start + aim * 35
        td.filter = self:GetOwner()
                
        local tr = util.TraceHull(td)

        -- fire first trace to check whether there is anything IN FRONT OF US
        if tr.Hit then
            -- if there is, don't allow us to deploy
            return false
        end
        
        aim.z = height
        
        td.start = sp
        td.endpos = td.start + aim * 25
        td.filter = self:GetOwner()
                
        tr = util.TraceHull(td)
        
        if tr.Hit then
            local ent = tr.Entity
            
            -- if the second trace passes, we can deploy
            if not ent:IsPlayer() and not ent:IsNPC() then
                return true
            end
        end
        
        return false
    end
    
    return false
end

function SWEP:setupBipodVars()
    -- network/predict bipod angles
    
    self.DeployAngle = self:GetOwner():EyeAngles()
    
    -- delay all actions
    self:performBipodDelay()
end

function SWEP:performBipodDelay(time)
    time = time or self.BipodDeployTime
    local CT = CurTime()
    
    self.BipodDelay = CT + time
    self:SetNextPrimaryFire(CT + time)
    self:SetNextSecondaryFire(CT + time)
    self.ReloadWait = CT + time
end

function SWEP:BipodModule()
    local CT = CurTime()
    if (SP and SERVER) or not SP then
        if self:GetBipodDeployed() or self.DeployAngle then
            --Check whether the bipid can be placed on the current surface (so we don't end up placing on nothing)
            if not self:CanRestWeapon(self.BipodDeployHeightRequirement) then
                self:SetBipodDeployed(false)
                self.DeployAngle = nil

                if not self.ReloadDelay then
                    if CT > self.BipodDelay then
                        self:performBipodDelay(self.BipodUndeployTime)
                    else
                        self.BipodUndeployPost = true
                    end
                else
                    self.BipodUnDeployPost = true
                end
            end
        end

        if not self.ReloadDelay then
            if self.BipodUnDeployPost then
                if CT > self.BipodDelay then
                    if not self:CanRestWeapon(self.BipodDeployHeightRequirement) then
                        self:performBipodDelay(self.BipodUndeployTime)
                        self.BipodUnDeployPost = false
                    else
                        self:SetBipodDeployed(true)
                        self:setupBipodVars()
                        self.BipodUnDeployPost = false
                    end
                end
            end

            if self:GetOwner():KeyPressed(IN_USE) then
                if CT > self.BipodDelay then
                    if self.BipodInstalled then
                        if self:GetBipodDeployed() then
                            self:SetBipodDeployed(false)
                            self.DeployAngle = nil

                            self:performBipodDelay(self.BipodUndeployTime)
                        else
                            self:SetBipodDeployed(self:CanRestWeapon(self.BipodDeployHeightRequirement))

                            if self:GetBipodDeployed() then
                                self:performBipodDelay(self.BipodDeployTime)
                                self:setupBipodVars()
                            end
                        end
                    end
                end
            end
        end
    end
end

--[[
Function Name:  Sound Handling
Purpose:  Utility
]]--
function SWEP:TableRandom(table)
    return table[math.random(#table)]
end

function SWEP:ChaosEmitSound(fsound, level, pitch, vol, chan, useWorld)
    fsound = fsound

    if istable(fsound) then fsound = self:TableRandom(fsound) end

    if fsound and fsound != "" then
        if useWorld then
            sound.Play(fsound, self:GetOwner():GetShootPos(), level, pitch, vol)
        else
            self:EmitSound(fsound, level, pitch, vol, chan or CHAN_AUTO)
        end
    end
end

--[[
Function Name:  HoldTypeHandling
Purpose:  Utility
]]--

function SWEP:HoldTypeHandler()
    if self:GetSafety() then
        self:SetHoldType(self.HoldtypeHolstered)
        return
    end

    if self:GetIsAiming() then
        if self:GetClassType() == "SPARTAN" then
            self:SetHoldType(self.HoldtypeActive)
        elseif not self:GetIsHighTier() then
            self:SetHoldType(self.HoldtypeSights)
        end
    elseif self:GetIsSprinting() then
        if self:GetCanSprintShoot() and not self:GetOwner():KeyDown(IN_ATTACK) then
            self:SetHoldType(self.HoldtypeHolstered)
        elseif self:GetOwner():KeyDown(IN_ATTACK) then
            self:SetHoldType(self.HoldtypeActive)
        else
            self:SetHoldType(self.HoldtypeHolstered)
        end
    else
        self:SetHoldType(self.HoldtypeActive)
    end

end

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )

    if isnumber(self.WepSelectIcon) then
        surface.SetTexture( self.WepSelectIcon )
    elseif isstring(self.WepSelectIcon) then
        surface.SetTexture( surface.GetTextureID( self.WepSelectIcon ) )
    end
    surface.SetDrawColor( 255, 255, 255, alpha )


    alpha = 150
    surface.DrawTexturedRect( x + (wide/4), y + (tall / 16),  (wide*0.5) , ( wide / 2 ) )
    
    self:PrintWeaponInfo( x + wide, y + tall/2, alpha )
end

function SWEP:PrintWeaponInfo( x, y, alpha )

    if ( self.DrawWeaponInfoBox == false ) then return end
    
    if (self.InfoMarkup == nil ) then
        local str
        local title_color = "<color=200,50,50,255>"
        local text_color = "<color=200,200,200,255>"
        
        str = "<font=HudSelectionText>"
        if ( self.Author != "" ) then str = str .. title_color .. "Author:</color>\t\n"..text_color..self.Author.."</color>\n" end
        if ( self.Contact != "" ) then str = str .. title_color .. "Manufacturer:</color>\t\n"..text_color..self.Contact.."</color>\n\n" end
        if ( self.Purpose != "" ) then str = str .. title_color .. "Ammunition:</color>\t\n"..text_color..self.Purpose.."</color>\n\n" end
        if ( self.Instructions != "" ) then str = str .. title_color .. "Purpose:</color>\t\n"..text_color..self.Instructions.."</color>\n" end
        str = str .. "</font>"
        
        self.InfoMarkup = markup.Parse( str, 250 )
    end
    
--  y = y - self.InfoMarkup:GetHeight()
    
    surface.SetDrawColor( 60, 60, 60, alpha )
    surface.SetTexture( self.SpeechBubbleLid )
    
--  surface.DrawTexturedRect( x, y - 64, 128, 64 ) 

    draw.RoundedBox( 8, x, y, 250, self.InfoMarkup:GetHeight(), Color( 0, 0, 0, 50 ) )
    draw.RoundedBox( 0, x - 2, y, 2, self.InfoMarkup:GetHeight(), Color( 200, 50, 50, 255 ) )
    
    self.InfoMarkup:Draw( x+5, y, nil, nil, alpha )
    
end