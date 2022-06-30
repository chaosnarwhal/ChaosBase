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
    local a,b,SprintShoot = self:IsHighTier()
    if self:GetSafety() then
        self:SetHoldType(self.HoldtypeHolstered)
        return
    end

    if self:GetIsAiming() then
        if self.Augmented then
            self:SetHoldType(self.HoldtypeActive)
        elseif not a then
            self:SetHoldType(self.HoldtypeSights)
        end
    elseif self:GetIsSprinting() then
        if SprintShoot and not self:GetIsFiring() then
            self:SetHoldType(self.HoldtypeHolstered)
        elseif self:GetIsFiring() then
            self:SetHoldType(self.HoldtypeActive)
        else
            self:SetHoldType(self.HoldtypeHolstered)
        end
    else
        self:SetHoldType(self.HoldtypeActive)
    end

end

-- SCK
if CLIENT or game.SinglePlayer() then
    SWEP.vRenderOrder = nil
    function SWEP:ViewModelDrawn()

        local vm = self.Owner:GetViewModel()
        if !IsValid(vm) then return end
        
        if (!self.VElements) then return end
        
        self:UpdateBonePositions(vm)
        if (!self.vRenderOrder) then
            
            // we build a render order because sprites need to be drawn after models
            self.vRenderOrder = {}
            for k, v in pairs( self.VElements ) do
                if (v.type == "Model") then
                    table.insert(self.vRenderOrder, 1, k)
                elseif (v.type == "Sprite" or v.type == "Quad") then
                    table.insert(self.vRenderOrder, k)
                end
            end
            
        end
        for k, name in ipairs( self.vRenderOrder ) do
        
            local v = self.VElements[name]
            if (!v) then self.vRenderOrder = nil break end
            if (v.hide) then continue end
            
            local model = v.modelEnt
            local sprite = v.spriteMaterial
            
            if (!v.bone) then continue end
            
            local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
            
            if (!pos) then continue end
            
            if (v.type == "Model" and IsValid(model)) then
                model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
                ang:RotateAroundAxis(ang:Up(), v.angle.y)
                ang:RotateAroundAxis(ang:Right(), v.angle.p)
                ang:RotateAroundAxis(ang:Forward(), v.angle.r)
                model:SetAngles(ang)
                //model:SetModelScale(v.size)
                local matrix = Matrix()
                matrix:Scale(v.size)
                model:EnableMatrix( "RenderMultiply", matrix )
                
                if (v.material == "") then
                    model:SetMaterial("")
                elseif (model:GetMaterial() != v.material) then
                    model:SetMaterial( v.material )
                end
                
                if (v.skin and v.skin != model:GetSkin()) then
                    model:SetSkin(v.skin)
                end
                
                if (v.bodygroup) then
                    for k, v in pairs( v.bodygroup ) do
                        if (model:GetBodygroup(k) != v) then
                            model:SetBodygroup(k, v)
                        end
                    end
                end
                
                if (v.surpresslightning) then
                    render.SuppressEngineLighting(true)
                end
                
                render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
                render.SetBlend(v.color.a/255)
                model:DrawModel()
                render.SetBlend(1)
                render.SetColorModulation(1, 1, 1)
                
                if (v.surpresslightning) then
                    render.SuppressEngineLighting(false)
                end
                
            elseif (v.type == "Sprite" and sprite) then
                
                local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
                render.SetMaterial(sprite)
                render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
                
            elseif (v.type == "Quad" and v.draw_func) then
                
                local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
                ang:RotateAroundAxis(ang:Up(), v.angle.y)
                ang:RotateAroundAxis(ang:Right(), v.angle.p)
                ang:RotateAroundAxis(ang:Forward(), v.angle.r)
                
                cam.Start3D2D(drawpos, ang, v.size)
                    v.draw_func( self )
                cam.End3D2D()
            end
            
        end
        
    end

    SWEP.wRenderOrder = nil
    function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
        
        local bone, pos, ang
        if (tab.rel and tab.rel != "") then
            
            local v = basetab[tab.rel]
            
            if (!v) then return end
            
            // Technically, if there exists an element with the same name as a bone
            // you can get in an infinite loop. Let's just hope nobody's that stupid.
            pos, ang = self:GetBoneOrientation( basetab, v, ent )
            
            if (!pos) then return end
            
            pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
            ang:RotateAroundAxis(ang:Up(), v.angle.y)
            ang:RotateAroundAxis(ang:Right(), v.angle.p)
            ang:RotateAroundAxis(ang:Forward(), v.angle.r)
                
        else
        
            bone = ent:LookupBone(bone_override or tab.bone)
            if (!bone) then return end
            
            pos, ang = Vector(0,0,0), Angle(0,0,0)
            local m = ent:GetBoneMatrix(bone)
            if (m) then
                pos, ang = m:GetTranslation(), m:GetAngles()
            end
            
            if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
                ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
                ang.r = -ang.r // Fixes mirrored models
            end
        
        end
        
        return pos, ang
    end
function SWEP:CreateModels( tab )
        if (!tab) then return end
        for k, v in pairs( tab ) do
            if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
                    string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
                
                v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
                if (IsValid(v.modelEnt)) then
                    v.modelEnt:SetPos(self:GetPos())
                    v.modelEnt:SetAngles(self:GetAngles())
                    v.modelEnt:SetParent(self)
                    v.modelEnt:SetNoDraw(true)
                    v.createdModel = v.model
                else
                    v.modelEnt = nil
                end
                
            elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
                and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
                
                local name = v.sprite.."-"
                local params = { ["$basetexture"] = v.sprite }
                // make sure we create a unique name based on the selected options
                local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
                for i, j in pairs( tocheck ) do
                    if (v[j]) then
                        params["$"..j] = 1
                        name = name.."1"
                    else
                        name = name.."0"
                    end
                end

                v.createdSprite = v.sprite
                v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
                
            end
        end
        
    end
    
    local allbones
    local hasGarryFixedBoneScalingYet = false

    function SWEP:UpdateBonePositions(vm)
        
        if self.ViewModelBoneMods then
            
            if (!vm:GetBoneCount()) then return end
            
            // !! WORKAROUND !! //
            // We need to check all model names :/
            local loopthrough = self.ViewModelBoneMods
            if (!hasGarryFixedBoneScalingYet) then
                allbones = {}
                for i=0, vm:GetBoneCount() do
                    local bonename = vm:GetBoneName(i)
                    if (self.ViewModelBoneMods[bonename]) then 
                        allbones[bonename] = self.ViewModelBoneMods[bonename]
                    else
                        allbones[bonename] = { 
                            scale = Vector(1,1,1),
                            pos = Vector(0,0,0),
                            angle = Angle(0,0,0)
                        }
                    end
                end
                
                loopthrough = allbones
            end
            // !! ----------- !! //
            
            for k, v in pairs( loopthrough ) do
                local bone = vm:LookupBone(k)
                if (!bone) then continue end
                
                // !! WORKAROUND !! //
                local s = Vector(v.scale.x,v.scale.y,v.scale.z)
                local p = Vector(v.pos.x,v.pos.y,v.pos.z)
                local ms = Vector(1,1,1)
                if (!hasGarryFixedBoneScalingYet) then
                    local cur = vm:GetBoneParent(bone)
                    while(cur >= 0) do
                        local pscale = loopthrough[vm:GetBoneName(cur)].scale
                        ms = ms * pscale
                        cur = vm:GetBoneParent(cur)
                    end
                end
                
                s = s * ms
                // !! ----------- !! //
                
                if vm:GetManipulateBoneScale(bone) != s then
                    vm:ManipulateBoneScale( bone, s )
                end
                if vm:GetManipulateBoneAngles(bone) != v.angle then
                    vm:ManipulateBoneAngles( bone, v.angle )
                end
                if vm:GetManipulateBonePosition(bone) != p then
                    vm:ManipulateBonePosition( bone, p )
                end
            end
        else
            self:ResetBonePositions(vm)
        end
           
    end
     
    function SWEP:ResetBonePositions(vm)
        
        if (!vm:GetBoneCount()) then return end
        for i=0, vm:GetBoneCount() do
            vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
            vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
            vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
        end
        
    end

function table.FullCopy( tab )
        if (!tab) then return nil end
        
        local res = {}
        for k, v in pairs( tab ) do
            if (type(v) == "table") then
                res[k] = table.FullCopy(v) // recursion ho!
            elseif (type(v) == "Vector") then
                res[k] = Vector(v.x, v.y, v.z)
            elseif (type(v) == "Angle") then
                res[k] = Angle(v.p, v.y, v.r)
            else
                res[k] = v
            end
        end
        
        return res
        
    end
    
end