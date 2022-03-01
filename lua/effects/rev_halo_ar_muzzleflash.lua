function EFFECT:Init( data )
	local Pos = data:GetOrigin()
	
	self.Position = data:GetStart()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	
	local emitter = ParticleEmitter( Pos )
	
	for i = 1,7 do

		local particle = emitter:Add( "sprites/rico1", Pos + Vector( math.random(0,0),math.random(0,0),math.random(0,0) ) ) 
		 
		if particle == nil then particle = emitter:Add( "sprites/rico1", Pos + Vector(   math.random(0,0),math.random(0,0),math.random(0,0) ) ) end
		
		if (particle) then
			particle:SetVelocity(Vector(math.random(-4,4),math.random(-4,4),math.random(0,0)))
			particle:SetLifeTime(0) 
			particle:SetDieTime(0.025) 
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(4.5, 7.5)) 
			particle:SetEndSize(math.Rand(0.5, 1))
			particle:SetAngles( Angle(21.424716258016,3.5762036133102,5.6347174018494) )
			particle:SetAngleVelocity( Angle(15) ) 
			particle:SetRoll(math.Rand( 0, 360 ))
			particle:SetColor(255, 255, 255)
			particle:SetGravity( Vector(0,0,0) ) 
			particle:SetAirResistance(-68.167394537726 )  
			particle:SetCollide(true)
			particle:SetBounce(0.1419790559388)
		end
	end
	

	emitter:Finish()
		
end

function EFFECT:Think()	
	return false
end

function EFFECT:Render()
end

