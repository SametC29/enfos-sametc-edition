--------------------------------------------------------------------------------
-- creep_ai.lua
-- Server-authoritative creep AI navigation, aggro leash, and stuck detection
-- Reference: docs/GAME_DESIGN_MASTER.md § 6
--------------------------------------------------------------------------------

require("lib/log")

local CreepAI = {}
CreepAI.__index = CreepAI

-- Navigation routes table with coordinates
CreepAI.ROUTES = {
	-- Radiant (DOTA_TEAM_GOODGUYS = 2)
	[2] = {
		left = {
			Vector(4697, 11364, 128),
			Vector(4658, 2841, 136),
			Vector(7540, 1580, 136),
			Vector(7504, -1357, 136),
			Vector(6528, -1664, 136),
			Vector(4104, -9932, 136),
			Vector(5604, -11099, 136),
			Vector(7538, -10816, 136),
			Vector(7530, -3440, 520),
			Vector(7656.83, -3451.99, 726.59),
		},
		center = {
			Vector(7559, 11381, 128),
			Vector(7706, -1452, 136),
			Vector(10903, -1935, 136),
			Vector(11009, -9833, 136),
			Vector(9729, -10923, 136),
			Vector(7823, -10816, 136),
			Vector(7858, -3436, 520),
			Vector(7656.83, -3451.99, 726.59),
		},
		right = {
			Vector(10624, 11418, 128),
			Vector(10510, 3095, 136),
			Vector(7870, 1554, 136),
			Vector(7914, -1382, 136),
			Vector(8384, -1600, 136),
			Vector(11112, -10090, 136),
			Vector(9765, -11046, 136),
			Vector(7680, -10923, 136),
			Vector(7707, -3442, 520),
			Vector(7656.83, -3451.99, 726.59),
		},
	},

	-- Dire (DOTA_TEAM_BADGUYS = 3)
	[3] = {
		left = {
			Vector(-10629, 11563, 128),
			Vector(-10590, 2763, 136),
			Vector(-7887, 1011, 136),
			Vector(-7936, -1183, 139),
			Vector(-9088, -1664, 136),
			Vector(-11097, -9712, 136),
			Vector(-10044, -10709, 136),
			Vector(-8043, -10678, 136),
			Vector(-7920, -3480, 446),
			Vector(-7809.26, -3683.53, 470.43),
		},
		center = {
			Vector(-7814, 11436, 128),
			Vector(-7752, -1367, 136),
			Vector(-4774, -2105, 136),
			Vector(-4664, -9640, 136),
			Vector(-5851, -10805, 136),
			Vector(-7597, -10821, 128),
			Vector(-7675, -3465, 458),
			Vector(-7809.26, -3683.53, 470.43),
		},
		right = {
			Vector(-4998, 11506, 128),
			Vector(-5026, 3509, 143),
			Vector(-7624, 1013, 136),
			Vector(-7616, -1186, 136),
			Vector(-7168, -1408, 136),
			Vector(-6656, -1664, 136),
			Vector(-4372, -9536, 136),
			Vector(-5521, -10903, 143),
			Vector(-7817, -10955, 136),
			Vector(-7794, -3451, 456),
			Vector(-7809.26, -3683.53, 470.43),
		},
	},
}

-- Parameters
local WAYPOINT_REACH_RADIUS = 280
local LEASH_DISTANCE = 1100
local THINK_INTERVAL = 0.4
local STUCK_THRESHOLD_TIME = 4.0
local STUCK_MIN_DISTANCE = 35

-- Distance to the lane segment, not distance to the next waypoint. Long lane
-- segments must not continually interrupt attack windups with movement orders.
function CreepAI:DistanceToSegment(pos, a, b)
	local dx, dy = b.x-a.x, b.y-a.y
	local lengthSquared = dx*dx + dy*dy
	local t = lengthSquared > 0 and ((pos.x-a.x)*dx + (pos.y-a.y)*dy)/lengthSquared or 0
	t = math.max(0, math.min(1, t))
	return math.sqrt((pos.x-a.x-t*dx)^2 + (pos.y-a.y-t*dy)^2)
end

--------------------------------------------------------------------------------
-- Attach AI to Unit
--------------------------------------------------------------------------------
function CreepAI:Attach(unit, defendingTeam, laneName, onLeakCallback)
	if not unit or unit:IsNull() then return nil end

	local teamRoutes = CreepAI.ROUTES[defendingTeam]
	if not teamRoutes then
		Log:Error("creep_ai", "Invalid defending team: %s", tostring(defendingTeam))
		return nil
	end

	local route = teamRoutes[laneName] or teamRoutes.left
	if not route or #route == 0 then
		Log:Error("creep_ai", "No route found for team %s lane %s", tostring(defendingTeam), tostring(laneName))
		return nil
	end

	local unitName = unit:GetUnitName()
	local isRunner = unitName == "enfos_creep_runner"
	local isBoss = unit.isBoss == true or string.find(unitName, "boss") ~= nil

	local state = {
		unit = unit,
		defendingTeam = defendingTeam,
		laneName = laneName,
		route = route,
		waypointIndex = 1,
		isRunner = isRunner,
		isBoss = isBoss,
		onLeakCallback = onLeakCallback,
		lastPos = unit:GetAbsOrigin(),
		stuckTimer = 0,
		leashed = false,
	}
	if isRunner then unit:AddNewModifier(unit, nil, "modifier_phased", {}) end

	unit.creepState = state
	-- Initial order towards first waypoint
	CreepAI:OrderMoveToWaypoint(state)

	-- Start AI thinker on unit
	unit:SetContextThink("CreepAI_Think", function()
		return CreepAI:OnThink(state)
	end, THINK_INTERVAL)

	return state
end

--------------------------------------------------------------------------------
-- Move to Current Waypoint
--------------------------------------------------------------------------------
function CreepAI:OrderMoveToWaypoint(state)
	local unit = state.unit
	if not unit or unit:IsNull() or not unit:IsAlive() then return end

	local targetPos = state.route[state.waypointIndex]
	if not targetPos then return end

	local order = {
		UnitIndex = unit:entindex(),
		OrderType = state.isRunner and DOTA_UNIT_ORDER_MOVE_TO_POSITION or DOTA_UNIT_ORDER_ATTACK_MOVE,
		Position = targetPos,
		Queue = false,
	}
	ExecuteOrderFromTable(order)
end

--------------------------------------------------------------------------------
-- AI Think Loop
--------------------------------------------------------------------------------
function CreepAI:OnThink(state)
	if GameRules:IsGamePaused() then return THINK_INTERVAL end
	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then return nil end
	local unit = state.unit
	if not unit or unit:IsNull() or not unit:IsAlive() then
		return nil -- Stop thinking
	end

	local currentPos = unit:GetAbsOrigin()
	local currentWaypoint = state.route[state.waypointIndex]
	-- Preserve native Boss casts before movement, stuck recovery or leaks.
	local activeAbility = unit.GetCurrentActiveAbility and unit:GetCurrentActiveAbility()
	local casting = activeAbility and not activeAbility:IsNull() and activeAbility:IsInAbilityPhase()
	if unit:IsStunned() or unit:IsRooted() or unit:IsChanneling()
		or casting
		or (not state.isRunner and unit:HasModifier("modifier_enfos_pve_taunt")) then
		state.stuckTimer = 0
		return THINK_INTERVAL
	end

	if not currentWaypoint then
		-- Reached the end of route: Life Core!
		if state.onLeakCallback then
			state.onLeakCallback(unit, state.defendingTeam)
		end
		return nil
	end

	-- Distance to current waypoint
	local distToWaypoint = (currentPos - currentWaypoint):Length2D()

	-- Waypoint arrival check
	if distToWaypoint <= WAYPOINT_REACH_RADIUS then
		state.waypointIndex = state.waypointIndex + 1
		state.stuckTimer = 0
		state.lastPos = currentPos

		if state.waypointIndex > #state.route then
			-- Reached Life Core!
			if state.onLeakCallback then
				state.onLeakCallback(unit, state.defendingTeam)
			end
			return nil
		else
			CreepAI:OrderMoveToWaypoint(state)
			return THINK_INTERVAL
		end
	end

	-- Let a valid attack finish. Repath only when outside the lane corridor.
	if not state.isRunner then
		local previous = state.route[math.max(1, state.waypointIndex-1)]
		local distFromRoutePoint = self:DistanceToSegment(currentPos, previous, currentWaypoint)
		if distFromRoutePoint > LEASH_DISTANCE then
			if not state.leashed then CreepAI:OrderMoveToWaypoint(state) end
			state.leashed = true
		else
			state.leashed = false
			local target = unit:GetAttackTarget()
			if target and not target:IsNull() and target:IsAlive() then
				state.stuckTimer = 0
				state.lastPos = currentPos
				return THINK_INTERVAL
			end
			-- Explicit acquisition: Query defending team's units (heroes, summons) within aggro range.
			local enemies = FindUnitsInRadius(
				state.defendingTeam,
				currentPos,
				nil,
				750,
				DOTA_UNIT_TARGET_TEAM_FRIENDLY,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				DOTA_UNIT_TARGET_FLAG_NONE,
				FIND_CLOSEST,
				false
			)
			for _, enemy in ipairs(enemies) do
				if enemy and not enemy:IsNull() and enemy:IsAlive() and not enemy:IsInvulnerable() then
					ExecuteOrderFromTable({
						UnitIndex = unit:entindex(),
						OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
						TargetIndex = enemy:entindex(),
						Queue = false,
					})
					state.stuckTimer = 0
					return THINK_INTERVAL
				end
			end
		end
	end

	-- Anti-stuck detection
	local movedDist = (currentPos - state.lastPos):Length2D()
	if movedDist < STUCK_MIN_DISTANCE and not unit:IsStunned() and not unit:IsRooted() then
		state.stuckTimer = state.stuckTimer + THINK_INTERVAL
		if state.stuckTimer >= STUCK_THRESHOLD_TIME then
			-- Creep is stuck: apply temporary phasing and re-issue move
			if not unit:HasModifier("modifier_phased") then
				unit:AddNewModifier(unit, nil, "modifier_phased", { duration = 2.0 })
			end
			CreepAI:OrderMoveToWaypoint(state)
			state.stuckTimer = 0
			Log:Debug("creep_ai", "Stuck recovery triggered for unit %s", unit:GetUnitName())
		end
	else
		state.stuckTimer = 0
		state.lastPos = currentPos
	end

	return THINK_INTERVAL
end

return CreepAI
