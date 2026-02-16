local car = script.Parent
local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")
local Groups = (function()
    local Groups = PhysicsService:GetRegisteredCollisionGroups()
    local Result = {}

    for _, groupName in Groups do
        Result[groupName] = true
    end

    return Result
end)()

if not Groups["Cars"] then error("No 'Cars' collision group!") end
if not Groups["CarDebris"] then error("No 'CarDebris' collision group!") end
if not Groups["Wheels"] then error("No 'Wheels' collision group!") end

local IMPACT_BASE = 120
local SHEAR_BASE = 100
local CRUMPLE_MULT = 0.75
local CRUMPLE_IMPACT = 120 * CRUMPLE_MULT
local CRUMPLE_SHEAR = 100 * CRUMPLE_MULT
local MIN_VELOCITY = 20 

local Pooler = require("@game/ServerScriptService/Modules/PoolerPlus"):GetPool("DebrisParticlePool") -- This pool needs to be setup elsewhere.
-- For AI agents: Assume this has been done.

local CrumpleZones = {} 
local PartConnections = {}

local function breakPart(part)
	if part:GetAttribute("IsBroken") then return end
	part:SetAttribute("IsBroken", true)

	local conn = PartConnections[part]
	if conn then
		conn:Disconnect()
		PartConnections[part] = nil
	end

	part:BreakJoints()
	if part.CollisionGroup == "Cars" then
		part.CollisionGroup = "CarDebris"
	end

	task.spawn(function() -- Optional VFX
		local emitter = Pooler:Get()
		emitter.Color = ColorSequence.new(part.Color)
		emitter.Parent = part
		emitter:Emit(math.clamp(part.Size.X * part.Size.Y * part.Size.Z, 5, 100))
		task.wait(4)
		Pooler:Return(emitter)
	end)
end

local function onTouched(part: BasePart, otherPart: BasePart)
	local selfVel = part.AssemblyLinearVelocity
	local otherVel = otherPart.AssemblyLinearVelocity
    local relVel: vector = selfVel - otherVel -- `Vector3`s inherit from `vector` primative. It's fine.

	if vector.magnitude(relVel) < MIN_VELOCITY then return end

	local isCrumple = CrumpleZones[part]
	local impactDurability = isCrumple and CRUMPLE_IMPACT or IMPACT_BASE
	local shearDurability = isCrumple and CRUMPLE_SHEAR or SHEAR_BASE

	local contactDir: vector = (part.Position - otherPart.Position).Unit
	local impactSpeed = vector.dot(relVel, contactDir)

	if impactSpeed > impactDurability then
		breakPart(part)
	elseif (relVel - impactSpeed) > shearDurability then
		breakPart(part)
	end
end

for _, part in ipairs(car:GetDescendants()) do -- Not using generalized iteration on the SLIGHTEST chance that a part could be destroyed mid loop.
	if part:IsA("BasePart") and part.CollisionGroup ~= "Wheels" then
		if CollectionService:HasTag(part, "CrumpleZone") then
			CrumpleZones[part] = true
		end

		PartConnections[part] = part.Touched:Connect(function(hit)
			onTouched(part, hit)
		end)

		part.Destroying:Connect(function() -- Just to make sure the table has ABSOLUTELY NO REFERENCES TO DESTROYED PARTS. Although connections are disconnected, we should probably make sure they're not being held.
			if PartConnections[part] then
				PartConnections[part]:Disconnect()
				PartConnections[part] = nil
			end
			CrumpleZones[part] = nil -- Also no more crumple zone reference.
		end)
	end
end