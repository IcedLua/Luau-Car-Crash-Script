local pooler = require(path.to.poolerplus)

pooler:CreatePool("DebrisParticlePool", function()
    return yourparticleclone
end, function(p)
    p.Parent = nil -- or any container
end)