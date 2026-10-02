--------------------------------------------------------------------------------
-- spellbringer_service.lua
-- Server-authoritative Spellbringer engine for Enfos Team Survival — SametC Edition
-- Manages separate player Spellbringer Mana, passive regeneration, cooldowns,
-- 8 launch abilities (4 offensive, 4 defensive), target validation,
-- Co-op mode restrictions, unequal-team normalization, and NetTable synchronization.
-- Reference: docs/GAME_DESIGN_MASTER.md § 12, docs/TECHNICAL_ARCHITECTURE.md § 3
--------------------------------------------------------------------------------

require("lib/log")
local WaveDefinitions = require("waves/wave_definitions")
local RandomFloat = _G.RandomFloat or function(a, b) return a + math.random() * (b - a) end

local SpellbringerService = {}
SpellbringerService.__index = SpellbringerService
local MAX_TARGET_COORDINATE = 12000
local ICONS = {
	spellbringer_arcane_barrier="abaddon_aphotic_shield", spellbringer_war_standard="legion_commander_press_the_attack",
	spellbringer_thorn_idol="bristleback_bristleback", spellbringer_rift_surge="enigma_demonic_conversion",
	spellbringer_whole_displacement="chen_test_of_faith", spellbringer_reveal="slardar_amplify_damage",
	spellbringer_purification="omniknight_purification", spellbringer_future_reinforcements="furion_force_of_nature",
}

-- Base balance constants (docs/GAME_DESIGN_MASTER.md § 12)
SpellbringerService.DEFAULT_START_MANA = 100
SpellbringerService.DEFAULT_MAX_MANA = 200
SpellbringerService.DEFAULT_REGEN = 2.5 -- Mana per second
SpellbringerService.THINK_INTERVAL = 0.5 -- Update frequency in seconds

-- The 8 Launch Abilities
SpellbringerService.ABILITY_DEFS = {
	-- -------------------------------------------------------------------------
	-- Offensive Abilities (affect opponent's PvE environment, never enemy heroes)
	-- Disabled in pure Co-op mode
	-- -------------------------------------------------------------------------
	spellbringer_arcane_barrier = {
		name = "spellbringer_arcane_barrier",
		is_offensive = true,
		cost = 45,
		cooldown = 20.0,
		radius = 800,
		duration = 12.0,
		barrier_amount = 300,
		magic_resist = 40,
	},
	spellbringer_war_standard = {
		name = "spellbringer_war_standard",
		is_offensive = true,
		cost = 60,
		cooldown = 30.0,
		radius = 800,
		duration = 20.0,
		bonus_damage_pct = 25,
		bonus_speed = 40,
	},
	spellbringer_thorn_idol = {
		name = "spellbringer_thorn_idol",
		is_offensive = true,
		cost = 65,
		cooldown = 35.0,
		radius = 800,
		duration = 15.0,
		reflect_pct = 25,
	},
	spellbringer_rift_surge = {
		name = "spellbringer_rift_surge",
		is_offensive = true,
		cost = 75,
		cooldown = 40.0,
		count = 2,
		unit_name = "enfos_spellbringer_void_stalker",
	},

	-- -------------------------------------------------------------------------
	-- Defensive Abilities (support own team's lane & survival)
	-- Available in all modes
	-- -------------------------------------------------------------------------
	spellbringer_whole_displacement = {
		name = "spellbringer_whole_displacement",
		is_offensive = false,
		cost = 80,
		cooldown = 50.0,
		radius = 450,
	},
	spellbringer_reveal = {
		name = "spellbringer_reveal",
		is_offensive = false,
		cost = 30,
		cooldown = 15.0,
		radius = 900,
		duration = 15.0,
	},
	spellbringer_purification = {
		name = "spellbringer_purification",
		is_offensive = false,
		cost = 50,
		cooldown = 25.0,
		radius = 600,
		summon_damage = 800,
	},
	spellbringer_future_reinforcements = {
		name = "spellbringer_future_reinforcements",
		is_offensive = false,
		cost = 100,
		cooldown = 60.0,
		count = 5,
		duration = 30.0,
		unit_name = "enfos_spellbringer_reinforcement",
	},
}

-- Ordered ability key list for UI rendering
SpellbringerService.ORDERED_ABILITIES = {
	"spellbringer_arcane_barrier",
	"spellbringer_war_standard",
	"spellbringer_thorn_idol",
	"spellbringer_rift_surge",
	"spellbringer_whole_displacement",
	"spellbringer_reveal",
	"spellbringer_purification",
	"spellbringer_future_reinforcements",
}

-- Link Lua Modifiers
if IsServer and IsServer() then
	LinkLuaModifier("modifier_spellbringer_arcane_barrier", "spellbringer/spellbringer_service", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_spellbringer_war_standard_aura", "spellbringer/spellbringer_service", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_spellbringer_war_standard_buff", "spellbringer/spellbringer_service", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_spellbringer_thorn_idol_aura", "spellbringer/spellbringer_service", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_spellbringer_thorn_idol_buff", "spellbringer/spellbringer_service", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_spellbringer_reinforcement_timed_life", "spellbringer/spellbringer_service", LUA_MODIFIER_MOTION_NONE)
end
-- Reveal is an engine aura: its source must also be registered on the client.
if LinkLuaModifier then
	LinkLuaModifier("modifier_spellbringer_reveal_thinker", "spellbringer/spellbringer_service", LUA_MODIFIER_MOTION_NONE)
end

--------------------------------------------------------------------------------
-- Initialize Service
--------------------------------------------------------------------------------
function SpellbringerService:Init(waveManager)
	self.waveManager = waveManager
	self.modeInitialized = false
	self.playerState = {} -- [playerID] = { mana, max_mana, regen, cooldowns = {} }
	self.summons = { [DOTA_TEAM_GOODGUYS or 2] = {}, [DOTA_TEAM_BADGUYS or 3] = {} }
	self.isCoop = false
	if GameRules and GameRules.EnfosSametC and GameRules.EnfosSametC.isCoop then
		self.isCoop = true
	end

	-- Broadcast ability definitions metadata to client NetTable
	self:PublishMetadata()

	-- Register custom game event listener for client cast requests
	if CustomGameEventManager then
		CustomGameEventManager:RegisterListener("enfos_spellbringer_cast", function(userIdx, args)
			self:OnCastRequest(userIdx, args)
		end)
	end

	-- Start thinker loop for mana regeneration and cooldown decay
	if GameRules and GameRules.GetGameModeEntity then
		local mode = GameRules:GetGameModeEntity()
		if mode and mode.SetContextThink then
			mode:SetContextThink("SpellbringerThinker", function()
				return self:OnThink(self.THINK_INTERVAL)
			end, self.THINK_INTERVAL)
		end
	end

	Log:Info("spellbringer", "SpellbringerService initialized successfully.")
end

--------------------------------------------------------------------------------
-- Publish Static Metadata
--------------------------------------------------------------------------------
function SpellbringerService:PublishMetadata()
	if not CustomNetTables then return end
	local meta = {}
	for _, id in ipairs(self.ORDERED_ABILITIES) do
		local def = self.ABILITY_DEFS[id]
		meta[id] = {
			icon = ICONS[id],
			name = def.name,
			is_offensive = def.is_offensive,
			cost = def.cost,
			cooldown = def.cooldown,
			radius = def.radius or (id=="spellbringer_rift_surge" and 71 or 85),
			duration = def.duration or 0,
		}
	end
	CustomNetTables:SetTableValue("spellbringer_meta", "abilities", meta)
end

--------------------------------------------------------------------------------
-- Player Registration & State Access
--------------------------------------------------------------------------------
function SpellbringerService:EnsurePlayer(playerID)
	if not self.playerState[playerID] then
		self.playerState[playerID] = {
			mana = self.DEFAULT_START_MANA,
			max_mana = self.DEFAULT_MAX_MANA,
			base_regen = self.DEFAULT_REGEN,
			regen = self.DEFAULT_REGEN,
			cooldowns = {}, -- [ability_name] = remaining_seconds
		}
		self:UpdateNormalization()
		self:SyncNetTable(playerID)
	end
	return self.playerState[playerID]
end

function SpellbringerService:GetMana(playerID)
	local state = self:EnsurePlayer(playerID)
	return state.mana
end

function SpellbringerService:SetMana(playerID, amount)
	local state = self:EnsurePlayer(playerID)
	state.mana = math.max(0, math.min(state.max_mana, amount))
	self:SyncNetTable(playerID)
end

function SpellbringerService:GetMaxMana(playerID)
	local state = self:EnsurePlayer(playerID)
	return state.max_mana
end

function SpellbringerService:GetCooldownRemaining(playerID, abilityName)
	local state = self:EnsurePlayer(playerID)
	return math.max(0, state.cooldowns[abilityName] or 0)
end

--------------------------------------------------------------------------------
-- Unequal-Team / Abandonment Normalization
-- Adjusts passive regen if active player counts differ between Radiant and Dire
--------------------------------------------------------------------------------
function SpellbringerService:UpdateNormalization()
	if not PlayerResource then return end
	local radiantCount, direCount = 0, 0
	local maxPlayers = (DOTA_MAX_TEAM_PLAYERS or 24) - 1

	for id = 0, maxPlayers do
		if PlayerResource:IsValidPlayerID(id) and PlayerResource:GetConnectionState(id) == (DOTA_CONNECTION_STATE_CONNECTED or 2) then
			local team = PlayerResource:GetTeam(id)
			if team == (DOTA_TEAM_GOODGUYS or 2) then radiantCount = radiantCount + 1 end
			if team == (DOTA_TEAM_BADGUYS or 3) then direCount = direCount + 1 end
		end
	end

	for id, state in pairs(self.playerState) do
		local team = PlayerResource:IsValidPlayerID(id) and PlayerResource:GetTeam(id) or 2
		local own = team == 2 and radiantCount or direCount
		local opp = team == 2 and direCount or radiantCount
		if own > 0 and opp > 0 and own ~= opp then
			-- Scale regen proportionally to compensate smaller team's spell output
			state.regen = state.base_regen * (opp / own)
		else
			state.regen = state.base_regen
		end
	end
end

--------------------------------------------------------------------------------
-- Periodic Thinker (Regen & Cooldown Decay)
--------------------------------------------------------------------------------
function SpellbringerService:OnThink(dt)
	if GameRules:State_Get()>=DOTA_GAMERULES_STATE_POST_GAME then return nil end
	if GameRules:State_Get()<DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then return self.THINK_INTERVAL end
	for id=0,(DOTA_MAX_TEAM_PLAYERS or 24)-1 do
		if PlayerResource:IsValidPlayerID(id) and (PlayerResource:GetTeam(id)==2 or PlayerResource:GetTeam(id)==3) then self:EnsurePlayer(id) end
	end
	if not self.modeInitialized and self.waveManager and self.waveManager.GetActivePlayerCount then
		self.isCoop=self.waveManager:GetActivePlayerCount(2)==0 or self.waveManager:GetActivePlayerCount(3)==0
		self.modeInitialized=true
		for id in pairs(self.playerState) do self:SyncNetTable(id) end
	end
	if GameRules and GameRules.IsGamePaused and GameRules:IsGamePaused() then
		return self.THINK_INTERVAL
	end

	for playerID, state in pairs(self.playerState) do
		local dirty = false

		-- Passive mana regeneration (does not reset between waves)
		if state.mana < state.max_mana then
			state.mana = math.min(state.max_mana, state.mana + state.regen * dt)
			dirty = true
		end

		-- Cooldown countdown
		for abilityName, remaining in pairs(state.cooldowns) do
			if remaining > 0 then
				local updated = math.max(0, remaining - dt)
				state.cooldowns[abilityName] = updated
				dirty = true
			end
		end

		if dirty then
			self:SyncNetTable(playerID)
		end
	end

	return self.THINK_INTERVAL
end

--------------------------------------------------------------------------------
-- NetTable Synchronization
--------------------------------------------------------------------------------
function SpellbringerService:SyncNetTable(playerID)
	if not CustomNetTables then return end
	local state = self.playerState[playerID]
	if not state then return end

	local cdTable = {}
	for k, v in pairs(state.cooldowns) do
		if v > 0 then cdTable[k] = math.floor(v * 10) / 10 end
	end

	CustomNetTables:SetTableValue("spellbringer_state", tostring(playerID), {
		mana = math.floor(state.mana),
		max_mana = math.floor(state.max_mana),
		regen = math.floor(state.regen * 10) / 10,
		cooldowns = cdTable,
		is_coop = self.isCoop and 1 or 0,
	})
end

--------------------------------------------------------------------------------
-- Target & Cast Validation
--------------------------------------------------------------------------------
function SpellbringerService:CanCast(playerID, abilityName, targetPos)
	if type(playerID)~="number" or not PlayerResource:IsValidPlayerID(playerID) then return false,"INVALID_PLAYER" end
	local team=PlayerResource:GetTeam(playerID)
	if team~=2 and team~=3 then return false,"INVALID_PLAYER" end
	if GameRules:State_Get()~=DOTA_GAMERULES_STATE_GAME_IN_PROGRESS or GameRules:IsGamePaused() then return false,"INVALID_PHASE" end
	local def = self.ABILITY_DEFS[abilityName]
	if not def then
		return false, "UNKNOWN_ABILITY"
	end

	if targetPos then
		local finite=require("lib/validation").Finite
		if not finite(targetPos.x) or not finite(targetPos.y) or not finite(targetPos.z) then return false,"INVALID_TARGET" end
		local targetTeam=def.is_offensive and (team==2 and 3 or 2) or team
		if math.abs(targetPos.x)>MAX_TARGET_COORDINATE
			or targetPos.y < -MAX_TARGET_COORDINATE or targetPos.y > MAX_TARGET_COORDINATE
			or (targetTeam==2 and targetPos.x<0) or (targetTeam==3 and targetPos.x>0) then return false,"INVALID_TARGET" end
		if GridNav and (not GridNav:IsTraversable(targetPos) or GridNav:IsBlocked(targetPos)) then return false,"INVALID_TARGET" end
	end
	local state = self:EnsurePlayer(playerID)

	-- Co-op mode blocks offensive spells
	if self.isCoop and def.is_offensive then
		return false, "COOP_OFFENSIVE_DISABLED"
	end

	-- Mana check
	if state.mana < def.cost then
		return false, "INSUFFICIENT_MANA"
	end

	-- Cooldown check
	if (state.cooldowns[abilityName] or 0) > 0.05 then
		return false, "ON_COOLDOWN"
	end

	return true, "OK"
end

--------------------------------------------------------------------------------
-- Client Cast Request Handler
--------------------------------------------------------------------------------
function SpellbringerService:OnCastRequest(userIdx, args)
	if not args then return end
	local playerID = args.PlayerID
	if type(playerID) ~= "number" then return end

	local abilityName = args.ability_name
	local targetPos = nil
	if args.target_x and args.target_y then
		local finite=require("lib/validation").Finite
		local x,y,z=finite(args.target_x),finite(args.target_y),finite(args.target_z or 136)
		if not x or not y or not z then return end
		-- Reject pathological coordinates before passing them into an engine query.
		if math.abs(x)>MAX_TARGET_COORDINATE or y < -MAX_TARGET_COORDINATE or y > MAX_TARGET_COORDINATE
			or z < -2048 or z > 4096 then return end
		targetPos = GetGroundPosition(Vector(x,y,z),nil)
	end
	-- UI casts always require an explicit ground target; never silently use Core.
	if not targetPos then
		local player=PlayerResource:GetPlayer(playerID)
		if player then CustomGameEventManager:Send_ServerToPlayer(player,"enfos_spellbringer_error",{reason="#enfos_spell_target_invalid"}) end
		return
	end

	local success, reason = self:CastSpell(playerID, abilityName, targetPos, nil)
	if not success then
		Log:Warn("spellbringer", "Player %d cast failed for %s: %s", playerID, tostring(abilityName), reason)
		if CustomGameEventManager and PlayerResource then
			local player = PlayerResource:GetPlayer(playerID)
			if player then
				local reasons={INVALID_TARGET="#enfos_spell_target_invalid",INSUFFICIENT_MANA="#enfos_error_insufficient_spellbringer_mana",ON_COOLDOWN="#enfos_spell_on_cooldown",COOP_OFFENSIVE_DISABLED="#enfos_spellbringer_coop_notice"}
				CustomGameEventManager:Send_ServerToPlayer(player, "enfos_spellbringer_error", { reason = reasons[reason] or "#enfos_error_generic" })
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Authoritative Spell Execution
--------------------------------------------------------------------------------
function SpellbringerService:CastSpell(playerID, abilityName, targetPos, targetEntity)
	local canCast, reason = self:CanCast(playerID, abilityName, targetPos)
	if not canCast then return false, reason end

	local def = self.ABILITY_DEFS[abilityName]
	local state = self:EnsurePlayer(playerID)
	local casterTeam = PlayerResource and PlayerResource:IsValidPlayerID(playerID) and PlayerResource:GetTeam(playerID) or 2
	local opponentTeam = (casterTeam == (DOTA_TEAM_GOODGUYS or 2)) and (DOTA_TEAM_BADGUYS or 3) or (DOTA_TEAM_GOODGUYS or 2)

	-- Deduct mana and set cooldown
	state.mana = state.mana - def.cost
	state.cooldowns[abilityName] = def.cooldown
	self:SyncNetTable(playerID)

	-- Execute specific ability logic
	local ok = false
	if abilityName == "spellbringer_arcane_barrier" then
		ok = self:CastArcaneBarrier(casterTeam, opponentTeam, def, targetPos)
	elseif abilityName == "spellbringer_war_standard" then
		ok = self:CastWarStandard(casterTeam, opponentTeam, def, targetPos)
	elseif abilityName == "spellbringer_thorn_idol" then
		ok = self:CastThornIdol(casterTeam, opponentTeam, def, targetPos)
	elseif abilityName == "spellbringer_rift_surge" then
		ok = self:CastRiftSurge(casterTeam, opponentTeam, def, targetPos)
	elseif abilityName == "spellbringer_whole_displacement" then
		ok = self:CastWholeDisplacement(casterTeam, def, targetPos)
	elseif abilityName == "spellbringer_reveal" then
		ok = self:CastReveal(casterTeam, def, targetPos, playerID)
	elseif abilityName == "spellbringer_purification" then
		ok = self:CastPurification(casterTeam, def, targetPos)
	elseif abilityName == "spellbringer_future_reinforcements" then
		ok = self:CastFutureReinforcements(casterTeam, def, targetPos, playerID)
	end

	if not ok then
		state.mana=math.min(state.max_mana,state.mana+def.cost)
		state.cooldowns[abilityName]=nil
		self:SyncNetTable(playerID)
		return false,"CAST_FAILED"
	end
	Log:Info("spellbringer", "Player %d (Team %d) successfully cast %s", playerID, casterTeam, abilityName)
	if targetPos and CustomGameEventManager and CustomGameEventManager.Send_ServerToAllClients then
		CustomGameEventManager:Send_ServerToAllClients("enfos_spellbringer_effect", {
			ability=abilityName,team=casterTeam,x=targetPos.x,y=targetPos.y,z=targetPos.z,
		})
	end
	return true, "OK"
end

--------------------------------------------------------------------------------
-- Ability 1: Arcane Barrier (Offensive)
-- Grants active opponent creeps temporary magic resistance and magic shield
--------------------------------------------------------------------------------
function SpellbringerService:CastArcaneBarrier(casterTeam, opponentTeam, def, targetPos)
	local creeps = self:GetActiveHostiles(opponentTeam)
	for _, creep in pairs(creeps) do
		if creep and not creep:IsNull() and creep:IsAlive() and (not targetPos or (creep:GetAbsOrigin()-targetPos):Length2D()<=def.radius) then
			creep:AddNewModifier(creep, nil, "modifier_spellbringer_arcane_barrier", { duration = def.duration })
		end
	end
	EmitGlobalSound("Hero_Silencer.Curse.Cast")
	return true
end

--------------------------------------------------------------------------------
-- Ability 2: War Standard (Offensive)
-- Stationary summon buffing opponent creeps' attack and movement
--------------------------------------------------------------------------------
function SpellbringerService:CastWarStandard(casterTeam, opponentTeam, def, targetPos)
	local pos = targetPos or self:GetDefaultLanePos(opponentTeam)
	local standard = CreateUnitByName("enfos_spellbringer_war_standard", pos, true, nil, nil, DOTA_TEAM_NEUTRALS or 4)
	if standard then
		self:RegisterSummon(standard, opponentTeam)
		standard:AddNewModifier(standard, nil, "modifier_spellbringer_war_standard_aura", {})
		standard:AddNewModifier(standard, nil, "modifier_kill", { duration = def.duration })
		standard:EmitSound("Hero_LegionCommander.Duel.Cast")
	end
	return standard ~= nil
end

--------------------------------------------------------------------------------
-- Ability 3: Thorn Idol (Offensive)
-- Stationary summon granting controlled reflect to opponent creeps
--------------------------------------------------------------------------------
function SpellbringerService:CastThornIdol(casterTeam, opponentTeam, def, targetPos)
	local pos = targetPos or self:GetDefaultLanePos(opponentTeam)
	local idol = CreateUnitByName("enfos_spellbringer_thorn_idol", pos, true, nil, nil, DOTA_TEAM_NEUTRALS or 4)
	if idol then
		self:RegisterSummon(idol, opponentTeam)
		idol:AddNewModifier(idol, nil, "modifier_spellbringer_thorn_idol_aura", {})
		idol:AddNewModifier(idol, nil, "modifier_kill", { duration = def.duration })
		idol:EmitSound("DOTA_Item.BladeMail.Activate")
	end
	return idol ~= nil
end

--------------------------------------------------------------------------------
-- Ability 4: Rift Surge (Offensive)
-- Adds 2 Void Stalkers to opponent lane; no reward farming, cannot cause cap-leak damage
--------------------------------------------------------------------------------
function SpellbringerService:CastRiftSurge(casterTeam, opponentTeam, def, targetPos)
	local spawnPos = targetPos or self:GetSpawnPos(opponentTeam)
	local CreepAI = require("waves/creep_ai")
	local created=0

	for i = 1, def.count do
		local unit = CreateUnitByName(def.unit_name, spawnPos + Vector(RandomFloat(-50, 50), RandomFloat(-50, 50), 0), true, nil, nil, DOTA_TEAM_NEUTRALS or 4)
		if unit then
			created=created+1
			self:RegisterSummon(unit, opponentTeam)
			unit:SetIdleAcquire(true)
			unit:SetAcquisitionRange(650)
			unit:AddNewModifier(unit,nil,"modifier_kill",{duration=30})
			local route = CreepAI:RouteFromPosition(opponentTeam, "center", unit:GetAbsOrigin())
			CreepAI:Attach(unit,opponentTeam,"center",function(u) u:ForceKill(false) end,route)
		end
	end
	EmitGlobalSound("Hero_Enigma.Demonic_Conversion")
	return created>0
end

--------------------------------------------------------------------------------
-- Ability 5: Whole Displacement (Defensive)
-- Returns eligible non-Boss hostile creeps in target radius toward lane start
--------------------------------------------------------------------------------
function SpellbringerService:CastWholeDisplacement(casterTeam, def, targetPos)
	local pos = targetPos or self:GetDefaultLanePos(casterTeam)
	local CreepAI = require("waves/creep_ai")
	local laneStart = CreepAI and CreepAI.ROUTES and CreepAI.ROUTES[casterTeam] and CreepAI.ROUTES[casterTeam].left and CreepAI.ROUTES[casterTeam].left[1]
	if not laneStart then laneStart = self:GetSpawnPos(casterTeam) end

	local units = self:GetActiveHostiles(casterTeam, pos, def.radius)

	local displaced = 0
	for _, unit in ipairs(units) do
		local name = unit:GetUnitName()
		-- Bosses cannot be displaced; regular wave creeps can be moved.
		if unit.defendingTeam==casterTeam and not unit.isBoss and not name:find("enfos_boss_", 1, true) then
			local destination=unit.creepState and unit.creepState.route[1] or laneStart
			FindClearSpaceForUnit(unit, destination, true)
			if unit.creepState then
				unit.creepState.waypointIndex = 1
				unit.creepState.lastPos = destination
				CreepAI:OrderMoveToWaypoint(unit.creepState)
			end
			unit:EmitSound("Hero_Chen.TeleportOut")
			displaced = displaced + 1
		end
	end
	Log:Info("spellbringer", "Whole Displacement returned %d units toward lane start.", displaced)
	return true
end

--------------------------------------------------------------------------------
-- Ability 6: Reveal (Defensive)
-- Reveals invisible enemies and grants True Sight in an area for 15s
--------------------------------------------------------------------------------
function SpellbringerService:CastReveal(casterTeam, def, targetPos, playerID)
	local pos = targetPos or self:GetDefaultLanePos(casterTeam)
	-- Reveal is defensive: detect the neutral hostiles attacking the caster's
	-- lanes, matching CanCast's own-side target validation.
	local defendingTeam = casterTeam
	local caster = playerID ~= nil and PlayerResource and PlayerResource:GetSelectedHeroEntity(playerID)
	if not caster or caster:IsNull() or caster:GetTeamNumber() ~= casterTeam or not CreateModifierThinker then
		Log:Warn("spellbringer", "Reveal failed: valid caster/source unavailable for team %d", casterTeam)
		return false
	end
	local thinker = CreateModifierThinker(caster, nil, "modifier_spellbringer_reveal_thinker", {
			duration = def.duration,
			radius = def.radius,
			team = casterTeam,
			defending_team = defendingTeam,
		}, pos, casterTeam, false)
	if not thinker or thinker:IsNull() or not thinker:FindModifierByName("modifier_spellbringer_reveal_thinker") then
		if thinker and not thinker:IsNull() then UTIL_Remove(thinker) end
		Log:Error("spellbringer", "Reveal failed: detection aura was not created for team %d", casterTeam)
		return false
	end
	Log:Info("spellbringer", "Reveal active: team=%d x=%.0f y=%.0f radius=%.0f duration=%.1f", casterTeam, pos.x, pos.y, def.radius, def.duration)
	EmitGlobalSound("DOTA_Item.DustOfAppearance.Activate")
	return true
end

--------------------------------------------------------------------------------
-- Ability 7: Purification (Defensive)
-- Removes hostile Spellbringer buffs, cleanses ally effects, counters hostile summons
--------------------------------------------------------------------------------
function SpellbringerService:CastPurification(casterTeam, def, targetPos)
	local pos = targetPos or self:GetDefaultLanePos(casterTeam)

	-- 1. Remove hostile Spellbringer buffs and destroy Spellbringer summons in radius
	local hostiles = self:GetActiveHostiles(casterTeam, pos, def.radius)

	for _, unit in ipairs(hostiles) do
		-- Dispel Spellbringer buffs
		unit:RemoveModifierByName("modifier_spellbringer_arcane_barrier")
		unit:RemoveModifierByName("modifier_spellbringer_war_standard_buff")
		unit:RemoveModifierByName("modifier_spellbringer_thorn_idol_buff")

		-- Counter hostile Spellbringer summons
		if unit.is_spellbringer_summon or unit:GetUnitName():find("spellbringer", 1, true) then
			ApplyDamage({
				victim = unit,
				attacker = unit,
				damage = def.summon_damage,
				damage_type = DAMAGE_TYPE_PURE,
			})
		end
	end

	-- 2. Cleanse allied heroes in radius
	local allies = FindUnitsInRadius(casterTeam, pos, nil, def.radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, hero in ipairs(allies) do
		if hero and not hero:IsNull() and hero.Purge then
			hero:Purge(false, true, false, true, true)
		end
	end

	EmitGlobalSound("Hero_Omniknight.Purification")
	return true
end

--------------------------------------------------------------------------------
-- Ability 8: Future Reinforcements (Defensive)
-- Summons exactly 5 allied fighters from wave+5. Never leak, no bounty.
--------------------------------------------------------------------------------
function SpellbringerService:CastFutureReinforcements(casterTeam, def, targetPos, playerID)
	local currentWave = (self.waveManager and self.waveManager.currentWave) or 1
	local future, targetWave = require("waves/native_roster").Future(currentWave)
	if self.waveManager and self.waveManager.bossResources then
		local plan=require("waves/native_roster").ResourcePlan(currentWave)
		self.waveManager.bossResources:RequestPlan(plan)
		if not self.waveManager.bossResources:IsPlanReady(plan) then return false end
	end
	local stats = require("waves/difficulty_curve").Normal(targetWave)
	local spawnPos = targetPos or self:GetReinforcementSpawnPos(casterTeam)
	local owner=playerID and PlayerResource:GetSelectedHeroEntity(playerID) or nil
	local created=0
	local spawnedUnits={}

	for i = 1, def.count do
		local unit = CreateUnitByName(future.unit, spawnPos + Vector(RandomFloat(-60, 60), RandomFloat(-60, 60), 0), true, owner, owner, casterTeam)
		if unit then
			created=created+1
			if owner then unit:SetOwner(owner);unit:SetControllableByPlayer(playerID,true) end
			unit.is_allied_reinforcement = true
			spawnedUnits[#spawnedUnits+1]=unit
			unit.enfosNoReward = true
			unit:SetMinimumGoldBounty(0);unit:SetMaximumGoldBounty(0);unit:SetDeathXP(0)

			-- Same scheduled-wave stats; no additive legacy summon bonuses.
			unit:SetBaseMaxHealth(stats.hp)
			unit:SetMaxHealth(unit:GetBaseMaxHealth())
			unit:SetHealth(unit:GetMaxHealth())
			unit:SetBaseDamageMin(stats.damage)
			unit:SetBaseDamageMax(math.ceil(stats.damage * 1.1))
			unit.waveNumber = targetWave
			unit:SetPhysicalArmorBaseValue(stats.armor)
			unit:SetBaseMagicalResistanceValue(stats.magicResistance)
			unit:SetBaseMoveSpeed(stats.speed)
			require("waves/special_creeps").Configure(unit,future.wave,casterTeam,true)
			local snapshot = self.waveManager and self.waveManager.EnsureMatchConfig and self.waveManager:EnsureMatchConfig()
			if snapshot then require("waves/balance_config").Apply(unit,snapshot,targetWave) end

			unit:SetIdleAcquire(true)
			unit:SetAcquisitionRange(700)
			unit:AddNewModifier(unit, nil, "modifier_kill", { duration = def.duration })
		end
	end

	-- Capture the owner's next move attempt automatically in a Tools test.
	-- Pass actual handles so incorrect owner IDs cannot hide a failed assignment.
	if created>0 and IsInToolsMode and IsInToolsMode() then
		local ok,err=pcall(function() require("tools/spellbringer_audit").Run(playerID,spawnedUnits) end)
		if not ok then Log:Warn("spellbringer","Reinforcement observation failed: %s",tostring(err)) end
	end
	EmitGlobalSound("Hero_Silencer.GlobalSilence.Effect")
	return created>0
end

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------
function SpellbringerService:RegisterSummon(unit, defendingTeam)
	if not unit or unit:IsNull() then return false end
	unit.defendingTeam = defendingTeam
	unit.is_spellbringer_summon = true
	unit.enfosNoReward = true
	self.summons = self.summons or { [2] = {}, [3] = {} }
	self.summons[defendingTeam] = self.summons[defendingTeam] or {}
	self.summons[defendingTeam][unit:entindex()] = unit
	return true
end

-- Wave creeps and Spellbringer summons use DOTA_TEAM_NEUTRALS in the engine;
-- `ENEMY` relative to a player therefore misses them. `defendingTeam` is the
-- authoritative team relationship for this mode and is used for all area casts.
function SpellbringerService:GetActiveHostiles(defendingTeam, center, radius)
	local found, seen = {}, {}
	local function consider(unit)
		if not unit or unit:IsNull() or not unit:IsAlive() or unit.defendingTeam ~= defendingTeam then return end
		if center and radius then
			local delta = unit:GetAbsOrigin() - center
			if delta:Length2D() > radius then return end
		end
		local id = unit:entindex()
		if not seen[id] then
			seen[id] = true
			found[#found + 1] = unit
		end
	end

	local active = self.waveManager and self.waveManager.activeCreeps and self.waveManager.activeCreeps[defendingTeam]
	if active then for _, unit in pairs(active) do consider(unit) end end
	local summons = self.summons and self.summons[defendingTeam]
	if summons then
		for id, unit in pairs(summons) do
			if not unit or unit:IsNull() or not unit:IsAlive() then summons[id] = nil
			else consider(unit) end
		end
	end

	if active == nil and FindUnitsInRadius then
		local searchCenter = center or self:GetDefaultLanePos(defendingTeam)
		local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS or 4, searchCenter, nil, radius or 3000,
			DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, unit in ipairs(units) do consider(unit) end
	end
	return found
end

function SpellbringerService:GetDefaultLanePos(team)
	if team == (DOTA_TEAM_GOODGUYS or 2) then
		return Vector(7504, -1357, 136)
	else
		return Vector(-7936, -1183, 139)
	end
end

function SpellbringerService:GetSpawnPos(team)
	if self.waveManager and self.waveManager.SPAWN_LOCATIONS and self.waveManager.SPAWN_LOCATIONS[team] then
		return self.waveManager.SPAWN_LOCATIONS[team].center
	end
	if team == (DOTA_TEAM_GOODGUYS or 2) then
		return Vector(7706, -1452, 136)
	else
		return Vector(-7752, -1367, 136)
	end
end

function SpellbringerService:GetReinforcementSpawnPos(team)
	if team == (DOTA_TEAM_GOODGUYS or 2) then
		return Vector(7530, -3440, 520)
	else
		return Vector(-7920, -3480, 446)
	end
end

--------------------------------------------------------------------------------
-- MODIFIERS
--------------------------------------------------------------------------------

-- 1. Arcane Barrier Buff
modifier_spellbringer_arcane_barrier = class({})
function modifier_spellbringer_arcane_barrier:IsDebuff() return false end
function modifier_spellbringer_arcane_barrier:IsPurgable() return true end
function modifier_spellbringer_arcane_barrier:DeclareFunctions()
	return { MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK }
end
function modifier_spellbringer_arcane_barrier:GetModifierMagicalResistanceBonus() return 40 end
function modifier_spellbringer_arcane_barrier:GetModifierTotal_ConstantBlock(kv)
	if kv.damage_type == DAMAGE_TYPE_MAGICAL then
		local block = math.min(self.barrier or 300, kv.damage)
		self.barrier = (self.barrier or 300) - block
		if self.barrier <= 0 then self:Destroy() end
		return block
	end
	return 0
end
function modifier_spellbringer_arcane_barrier:OnCreated()
	self.barrier = 300
	if IsServer and IsServer() then
		self.pfx = ParticleManager:CreateParticle("particles/items3_fx/glimmer_cape_initial.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	end
end
function modifier_spellbringer_arcane_barrier:OnDestroy()
	if IsServer and IsServer() and self.pfx then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
	end
end

-- 2. War Standard Aura & Buff
modifier_spellbringer_war_standard_aura = class({})
function modifier_spellbringer_war_standard_aura:IsAura() return true end
function modifier_spellbringer_war_standard_aura:GetAuraRadius() return 800 end
function modifier_spellbringer_war_standard_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_spellbringer_war_standard_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC end
function modifier_spellbringer_war_standard_aura:GetModifierAura() return "modifier_spellbringer_war_standard_buff" end
function modifier_spellbringer_war_standard_aura:GetAuraEntityReject(target)
	return not target or target.defendingTeam ~= self:GetParent().defendingTeam
end

modifier_spellbringer_war_standard_buff = class({})
function modifier_spellbringer_war_standard_buff:IsPurgable() return true end
function modifier_spellbringer_war_standard_buff:DeclareFunctions()
	return { MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT }
end
function modifier_spellbringer_war_standard_buff:GetModifierBaseDamageOutgoing_Percentage() return 25 end
function modifier_spellbringer_war_standard_buff:GetModifierMoveSpeedBonus_Constant() return 40 end

-- 3. Thorn Idol Aura & Buff (Controlled reflect)
modifier_spellbringer_thorn_idol_aura = class({})
function modifier_spellbringer_thorn_idol_aura:IsAura() return true end
function modifier_spellbringer_thorn_idol_aura:GetAuraRadius() return 800 end
function modifier_spellbringer_thorn_idol_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_spellbringer_thorn_idol_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_BASIC end
function modifier_spellbringer_thorn_idol_aura:GetModifierAura() return "modifier_spellbringer_thorn_idol_buff" end
function modifier_spellbringer_thorn_idol_aura:GetAuraEntityReject(target)
	return not target or target.defendingTeam ~= self:GetParent().defendingTeam
end

modifier_spellbringer_thorn_idol_buff = class({})
function modifier_spellbringer_thorn_idol_buff:IsPurgable() return true end
function modifier_spellbringer_thorn_idol_buff:DeclareFunctions()
	return { MODIFIER_EVENT_ON_TAKEDAMAGE }
end
function modifier_spellbringer_thorn_idol_buff:OnTakeDamage(params)
	if not (IsServer and IsServer()) then return end
	local parent = self:GetParent()
	if bit.band(params.damage_flags or 0,DOTA_DAMAGE_FLAG_REFLECTION)~=0 then return end
	if params.unit == parent and params.attacker and not params.attacker:IsNull() and params.attacker ~= parent then
		local reflect = math.min(params.damage * 0.25, parent:GetMaxHealth() * 0.25)
		if reflect > 0 then
			ApplyDamage({
				victim = params.attacker,
				attacker = parent,
				damage = reflect,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
			})
		end
	end
end

-- 4. Reveal Thinker
modifier_spellbringer_reveal_thinker = class({})
function modifier_spellbringer_reveal_thinker:OnCreated(kv)
	self.radius = tonumber(kv.radius) or 900
	self.team = tonumber(kv.team) or self:GetParent():GetTeamNumber()
	self.defendingTeam = tonumber(kv.defending_team) or self.team
	if not (IsServer and IsServer()) then return end
	if AddFOWViewer then
		AddFOWViewer(self.team, self:GetParent():GetAbsOrigin(), self.radius, tonumber(kv.duration) or 15, false)
	end
end
function modifier_spellbringer_reveal_thinker:IsHidden() return true end
function modifier_spellbringer_reveal_thinker:IsPurgable() return false end
function modifier_spellbringer_reveal_thinker:IsAura() return true end
function modifier_spellbringer_reveal_thinker:GetAuraRadius() return self.radius or 900 end
function modifier_spellbringer_reveal_thinker:GetAuraDuration() return 0.75 end
function modifier_spellbringer_reveal_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_BOTH end
function modifier_spellbringer_reveal_thinker:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_spellbringer_reveal_thinker:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_spellbringer_reveal_thinker:GetModifierAura() return "modifier_truesight" end
function modifier_spellbringer_reveal_thinker:GetAuraEntityReject(unit)
	return not unit or unit:IsNull() or not unit:IsAlive() or unit.defendingTeam ~= self.defendingTeam
end
function modifier_spellbringer_reveal_thinker:OnDestroy()
	if not (IsServer and IsServer()) then return end
	local parent = self:GetParent()
	if parent and not parent:IsNull() then UTIL_Remove(parent) end
end

-- 5. Future Reinforcements Timed Life
modifier_spellbringer_reinforcement_timed_life = class({})
function modifier_spellbringer_reinforcement_timed_life:IsHidden() return true end
function modifier_spellbringer_reinforcement_timed_life:OnCreated(kv)
	if not (IsServer and IsServer()) then return end
	self:StartIntervalThink(kv.duration or 30)
end
function modifier_spellbringer_reinforcement_timed_life:OnIntervalThink()
	if self:GetParent() and not self:GetParent():IsNull() and self:GetParent():IsAlive() then
		self:GetParent():ForceKill(false)
	end
	self:Destroy()
end

return SpellbringerService
