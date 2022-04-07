 ENT.Type 								= "anim"  
 ENT.PrintName							= "Halo M41 Rocket"  
 ENT.Author								= "Ishi"  
 
ENT.Spawnable							= false
ENT.AdminSpawnable						= false

if SERVER then

	AddCSLuaFile( "shared.lua" )

	function ENT:Initialize()   

		self.flightvector = self.Entity:GetForward() * self.Owner:GetActiveWeapon().Projectile.Speed
		self.timeleft = CurTime() + 15
		self.Owner = self:GetOwner()
		self.Entity:SetModel( "models/ishi/halo_rebirth/weapons/unsc/proj_m41_rocket.mdl" )
		self.Entity:PhysicsInit( SOLID_VPHYSICS )	
		self.Entity:SetMoveType( MOVETYPE_NONE ) 	
		self.Entity:SetSolid( SOLID_VPHYSICS )       
	
		util.SpriteTrail(self.Entity, 0, Color(155, 155, 155, 155), true, 20, 20, 0.5, 5 / ((2 + 10) * 10), "trails/smoke.vmt")
		
		Glow = ents.Create("env_sprite")
		Glow:SetKeyValue("model","orangecore2.vmt")
		Glow:SetKeyValue("rendercolor","255 255 255")
		Glow:SetKeyValue("scale","0.3")
		Glow:SetPos(self.Entity:GetPos())
		Glow:SetParent(self.Entity)
		Glow:Spawn()
		Glow:Activate()
	end   

	function ENT:Think()

		if self.timeleft < CurTime() then
			self.Entity:Remove()				
		end

		Table							={} 			--Table name is table name
		Table[1]						=self.Owner 		--The person holding the gat
		Table[2]						=self.Entity 		--The cap

		local trace = {}
		trace.start = self.Entity:GetPos()
		trace.endpos = self.Entity:GetPos() + self.flightvector
		trace.filter = Table
		local tr = util.TraceLine( trace )
	
	
		if tr.Hit then
			local effectdata = EffectData()
			effectdata:SetOrigin(tr.HitPos)			-- Where is hits
			effectdata:SetNormal(tr.HitNormal)		-- Direction of particles
			effectdata:SetEntity(self.Entity)		-- Who done it?
			effectdata:SetScale(10)				-- Size of explosion
			effectdata:SetRadius(tr.MatType)		-- What texture it hits
			effectdata:SetMagnitude(2)				-- Length of explosion trails
			util.Effect( "env_explosion", effectdata )
			util.BlastDamage(self.Entity, self:OwnerGet(), tr.HitPos, 500, 8000)
			util.Decal("Scorch", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
					
			self:Explosion()
			self.Entity:Remove()	
		end
	
		self.Entity:SetPos(self.Entity:GetPos() + self.flightvector)
		self.flightvector = self.flightvector - (self.flightvector/10000000)  + Vector(math.Rand(-0.03,0.03), math.Rand(-0.03,0.03),math.Rand(-0.03,0.03)) + Vector(0,0,-0.004)
		self.Entity:SetAngles(self.flightvector:Angle() + Angle(0,0,0))
		self.Entity:NextThink( CurTime() )
		return true	
	end
 
	function ENT:Explosion()
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		util.Effect("halo_rocket_explosion", effectdata)
		self.Entity:EmitSound("ishi/rebirth/rocket/rocket_expl"..math.random(1,6)..".wav", SNDLVL_110dB, 100, 0.8)

		local shake = ents.Create("env_shake")
		shake:SetOwner(self.Owner)
		shake:SetPos(self.Entity:GetPos())
		shake:SetKeyValue("amplitude", "1000")	-- Power of the shake
		shake:SetKeyValue("radius", "900")		-- Radius of the shake
		shake:SetKeyValue("duration", "2.5")	-- Time of shake
		shake:SetKeyValue("frequency", "255")	-- How har should the screenshake be
		shake:SetKeyValue("spawnflags", "6")	-- Spawnflags(In Air)
		shake:Spawn()
		shake:Activate()
		shake:Fire("StartShake", "", 0)
	end

	function ENT:OwnerGet()
		if IsValid(self.Owner) then
			return self.Owner
		else
			return self.Entity
		end
	end
end
