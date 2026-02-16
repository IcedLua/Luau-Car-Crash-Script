local car = script.Parent
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 1. Pre-calculate EVERY possible constant
-- This avoids doing any multiplication or lookups inside the high-frequency event.
local IMPACT_BASE_SQ = 120^2
local SHEAR_BASE_SQ = 100^2
local CRUMPLE_MULT = 0.75
local CRUMPLE_IMPACT_SQ = (120 * CRUMPLE_MULT)^2
local CRUMPLE_SHEAR_SQ = (100 * CRUMPLE_MULT)^2
local MIN_VELOCITY_SQ = 2500 

-- 2. Services and Modules
local Pooler = require("@game/ServerScriptService/Modules/PoolerPlus"):GetPool("DebrisParticlePool") 

-- 3. Optimized Lookup Tables
local CrumpleZones = {} 
local PartConnections = {}

-- 4. Unified Break Logic (Localize for speed)
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

	-- Run VFX on a separate thread to resume physics calc immediately
	task.spawn(function()
		local emitter = Pooler:Get()
		emitter.Color = ColorSequence.new(part.Color)
		emitter.Parent = part
		emitter:Emit(math.clamp(part.Size.X * part.Size.Y * part.Size.Z, 5, 100))
		task.wait(4)
		Pooler:Return(emitter)
	end)
end

-- 5. The "Hot Path" (Optimized Touched Handler)
local function onTouched(part, otherPart)
	-- FILTER 1: Physics ignore
	if not otherPart.CanTouch or otherPart:IsDescendantOf(car) then return end

	local pv = part.AssemblyLinearVelocity
	local ov = otherPart.AssemblyLinearVelocity
	local rvX, rvY, rvZ = pv.X - ov.X, pv.Y - ov.Y, pv.Z - ov.Z
	local relVelSq = rvX*rvX + rvY*rvY + rvZ*rvZ

	if relVelSq < MIN_VELOCITY_SQ then return end

	-- FILTER 3: Context-aware thresholds
	local isCrumple = CrumpleZones[part]
	local limitImpactSq = isCrumple and CRUMPLE_IMPACT_SQ or IMPACT_BASE_SQ
	local limitShearSq = isCrumple and CRUMPLE_SHEAR_SQ or SHEAR_BASE_SQ

	local relVel = vector.new(rvX, rvY, rvZ)
	local contactDir = (part.Position - otherPart.Position).Unit
	local impactSpeed = relVel:Dot(contactDir)
	local impactSpeedSq = impactSpeed * impactSpeed

	-- Final Decision
	if impactSpeedSq > limitImpactSq then
		breakPart(part)
	elseif (relVelSq - impactSpeedSq) > limitShearSq then
		breakPart(part)
	end
end

-- 6. Initialization & Memory Cleanup
for _, part in ipairs(car:GetDescendants()) do
	if part:IsA("BasePart") and part.CollisionGroup ~= "Wheels" then
		if CollectionService:HasTag(part, "CrumpleZone") then
			CrumpleZones[part] = true
		end

		PartConnections[part] = part.Touched:Connect(function(hit)
			onTouched(part, hit)
		end)

		-- Memory Leak Protection: Remove references if the part is deleted
		part.Destroying:Connect(function()
			if PartConnections[part] then
				PartConnections[part]:Disconnect()
				PartConnections[part] = nil
			end
			CrumpleZones[part] = nil
		end)
	end
end