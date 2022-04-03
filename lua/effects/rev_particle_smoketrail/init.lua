local smokepart = "smoke_trail_rev"

local function rvec(vec)
	vec.x=math.Round(vec.x)
	vec.y=math.Round(vec.y)
	vec.z=math.Round(vec.z)
	return vec
end

function EFFECT:Init( data )
	local serverside = false
	local entity = data:GetEntity()
	if IsValid(entity) then
		local ownerent = entity.Owner
		if math.Round(data:GetMagnitude())==1 then
			serverside = true
		end
	else
		return
	end
	
	if serverside then
		if IsValid(ownerent) then
			if LocalPlayer() == ownerent then
				return
			end
		end
	end
	
	local attachment = data:GetAttachment()
	
	if attachment and attachment!=0 then
		if ( GetConVarNumber("cl_rev_fx_muzzlesmoke",1)==1 ) then
			ParticleEffectAttach(smokepart,PATTACH_POINT_FOLLOW,entity,attachment)
		end
	end
end 

function EFFECT:Think( )
	return false
end

function EFFECT:Render()
end

 