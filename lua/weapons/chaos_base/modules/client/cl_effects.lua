--[[
function SWEP:RenderParticles(particles)
    for i, particle in pairs(particles) do
        if (!particle:IsValid()) then
            particles[i] = nil
            continue
        end
        
        particle:Render()
    end
end

function SWEP:DoTPParticle(particleName, attName)
    particleName = self.MuzzleFlashEffect

    self.TpParticles[#self.TpParticles + 1] = effect

end
]]