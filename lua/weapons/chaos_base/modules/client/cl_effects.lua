function SWEP:RenderParticles(particles)
    for i, particle in pairs(particles) do
        if (!particle:IsValid()) then
            particles[i] = nil
            continue
        end
        
        particle:Render()
    end
end