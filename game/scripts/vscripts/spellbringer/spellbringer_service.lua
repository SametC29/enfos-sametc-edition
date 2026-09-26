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
	LinkLuaModifier("modifier_spellbringer_reveal_thinker", "spellbringer/spellbringer_service", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_spellbringer_reinforcement_timed_life", "spellbringer/spellbringer_service", LUA_MODIFIER_MOTION_NONE)
end

--------------------------------------------------------------------------------
-- Initialize Service
--------------------------------------------------------------------------------
function SpellbringerService:Init(waveManager)
	self.waveManager = waveManager
	self.playerState = {} -- [playerID] = { mana, max_mana, regen, cooldowns = {} }
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
			name = def.name,
			is_offensive = def.is_offensive,
			cost = def.cost,
			cooldown = def.cooldown,
			radius = def.radius or 0,
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
		is_coop = self.isCoop,
	})
end

--------------------------------------------------------------------------------
-- Target & Cast Validation
--------------------------------------------------------------------------------
function SpellbringerService:CanCast(playerID, abilityName, targetPos)
	local def = self.ABILITY_DEFS[abilityName]
	if not def then
		return false, "UNKNOWN_ABILITY"
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
	local playerID = args.PlayerID or (args.player_id and tonumber(args.player_id))
	if playerID == nil and userIdx ~= nil then
		playerID = userIdx
	end
	if playerID == nil then return end

	local abilityName = args.ability_name
	local targetPos = nil
	if args.target_x and args.target_y then
		targetPos = Vector(tonumber(args.target_x), tonumber(args.target_y), tonumber(args.target_z or 136))
	end

	local success, reason = self:CastSpell(playerID, abilityName, targetPos, nil)
	if not success then
		Log:Warn("spellbringer", "Player %d cast failed for %s: %s", playerID, tostring(abilityName), reason)
		if CustomGameEventManager and PlayerResource then
			local player = PlayerResource:GetPlayer(playerID)
			if player then
				CustomGameEventManager:Send_ServerToPlayer(player, "enfos_spellbringer_error", { error = reason })
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
		ok = self:CastArcaneBarrier(casterTeam, opponentTeam, def)
	elseif abilityName == "spellbringer_war_standard" then
		ok = self:CastWarStandard(casterTeam, opponentTeam, def, targetPos)
	elseif abilityName == "spellbringer_thorn_idol" then
		ok = self:CastThornIdol(casterTeam, opponentTeam, def, targetPos)
	elseif abilityName == "spellbringer_rift_surge" then
		ok = self:CastRiftSurge(casterTeam, opponentTeam, def)
	elseif abilityName == "spellbringer_whole_displacement" then
		ok = self:CastWholeDisplacement(casterTeam, def, targetPos)
	elseif abilityName == "spellbringer_reveal" then
		ok = self:CastReveal(casterTeam, def, targetPos)
	elseif abilityName == "spellbringer_purification" then
		ok = self:CastPurification(casterTeam, def, targetPos)
	elseif abilityName == "spellbringer_future_reinforcements" then
		ok = self:CastFutureReinforcements(casterTeam, def, targetPos)
	end

	Log:Info("spellbringer", "Player %d (Team %d) successfully cast %s", playerID, casterTeam, abilityName)
	return true, "OK"
end

--------------------------------------------------------------------------------
-- Ability 1: Arcane Barrier (Offensive)
-- Grants active opponent creeps temporary magic resistance and magic shield
--------------------------------------------------------------------------------
function SpellbringerService:CastArcaneBarrier(casterTeam, opponentTeam, def)
	local creeps = self:GetActiveHostiles(opponentTeam)
	for _, creep in ipairs(creeps) do
		if creep and not creep:IsNull() and creep:IsAlive() then
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
	local standard = CreateUnitByName("enfos_spellbringer_war_standard", pos, true, nil, nil, opponentTeam)
	if standard then
		standard.is_spellbringer_summon = true
		standard.enfosNoReward = true
		standard:AddNewModifier(standard, nil, "modifier_spellbringer_war_standard_aura", {})
		standard:AddNewModifier(standard, nil, "modifier_kill", { duration = def.duration })
		standard:EmitSound("Hero_LegionCommander.Duel.Cast")
	end
	return true
end

--------------------------------------------------------------------------------
-- Ability 3: Thorn Idol (Offensive)
-- Stationary summon granting controlled reflect to opponent creeps
--------------------------------------------------------------------------------
function SpellbringerService:CastThornIdol(casterTeam, opponentTeam, def, targetPos)
	local pos = targetPos or self:GetDefaultLanePos(opponentTeam)
	local idol = CreateUnitByName("enfos_spellbringer_thorn_idol", pos, true, nil, nil, opponentTeam)
	if idol then
		idol.is_spellbringer_summon = true
		idol.enfosNoReward = true
		idol:AddNewModifier(idol, nil, "modifier_spellbringer_thorn_idol_aura", {})
		idol:AddNewModifier(idol, nil, "modifier_kill", { duration = def.duration })
		idol:EmitSound("DOTA_Item.BladeMail.Activate")
	end
	return true
end

--------------------------------------------------------------------------------
-- Ability 4: Rift Surge (Offensive)
-- Adds 2 Void Stalkers to opponent lane; no reward farming, cannot cause cap-leak damage
--------------------------------------------------------------------------------
function SpellbringerService:CastRiftSurge(casterTeam, opponentTeam, def)
	local spawnPos = self:GetSpawnPos(opponentTeam)
	local CreepAI = require("waves/creep_ai")

	for i = 1, def.count do
		local unit = CreateUnitByName(def.unit_name, spawnPos + Vector(RandomFloat(-50, 50), RandomFloat(-50, 50), 0), true, nil, nil, opponentTeam)
		if unit then
			unit.is_spellbringer_summon = true
			unit.enfosNoReward = true
			unit.defendingTeam = opponentTeam
			unit:SetIdleAcquire(true)
			unit:SetAcquisitionRange(650)
			if CreepAI and CreepAI.RegisterCreep then
				CreepAI:RegisterCreep(unit, opponentTeam, "center")
			end
		end
	end
	EmitGlobalSound("Hero_Enigma.DemonicConversion")
	return true
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

	local units = FindUnitsInRadius(casterTeam, pos, nil, def.radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	local displaced = 0
	for _, unit in ipairs(units) do
		local name = unit:GetUnitName()
		-- Strictly non-Boss! Elites and regulars can be displaced
		if not name:find("enfos_boss_", 1, true) then
			FindClearSpaceForUnit(unit, laneStart, true)
			if unit.creepState then
				unit.creepState.currentWaypointIndex = 1
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
function SpellbringerService:CastReveal(casterTeam, def, targetPos)
	local pos = targetPos or self:GetDefaultLanePos(casterTeam)
	if CreateModifierThinker then
		CreateModifierThinker(nil, nil, "modifier_spellbringer_reveal_thinker", {
			duration = def.duration,
			radius = def.radius,
			team = casterTeam,
		}, pos, casterTeam, false)
	end
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
	local hostiles = FindUnitsInRadius(casterTeam, pos, nil, def.radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

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
-- Summons exactly 5 allied fighters scaled to wave+4 power. Never leak, no bounty.
--------------------------------------------------------------------------------
function SpellbringerService:CastFutureReinforcements(casterTeam, def, targetPos)
	local currentWave = (self.waveManager and self.waveManager.currentWave) or 1
	local targetWave = currentWave + 4
	local spawnPos = targetPos or self:GetReinforcementSpawnPos(casterTeam)

	for i = 1, def.count do
		local unit = CreateUnitByName(def.unit_name, spawnPos + Vector(RandomFloat(-60, 60), RandomFloat(-60, 60), 0), true, nil, nil, casterTeam)
		if unit then
			unit.is_allied_reinforcement = true
			unit.enfosNoReward = true

			-- Wave-scaling stats: +25 HP and +3 DMG per wave level
			local extraHp = targetWave * 25
			local extraDmg = targetWave * 3
			unit:SetMaxHealth(unit:GetMaxHealth() + extraHp)
			unit:SetHealth(unit:GetMaxHealth())
			unit:SetBaseDamageMin(unit:GetBaseDamageMin() + extraDmg)
			unit:SetBaseDamageMax(unit:GetBaseDamageMax() + extraDmg)

			unit:SetIdleAcquire(true)
			unit:SetAcquisitionRange(700)
			unit:AddNewModifier(unit, nil, "modifier_spellbringer_reinforcement_timed_life", { duration = def.duration })
		end
	end

	EmitGlobalSound("Hero_Silencer.GlobalSilence.Effect")
	return true
end

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------
function SpellbringerService:GetActiveHostiles(defendingTeam)
	if self.waveManager and self.waveManager.activeCreeps and self.waveManager.activeCreeps[defendingTeam] then
		return self.waveManager.activeCreeps[defendingTeam]
	end
	local center = self:GetDefaultLanePos(defendingTeam)
	return FindUnitsInRadius(defendingTeam, center, nil, 3000, DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
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

modifier_spellbringer_thorn_idol_buff = class({})
function modifier_spellbringer_thorn_idol_buff:IsPurgable() return true end
function modifier_spellbringer_thorn_idol_buff:DeclareFunctions()
	return { MODIFIER_EVENT_ON_TAKEDAMAGE }
end
function modifier_spellbringer_thorn_idol_buff:OnTakeDamage(params)
	if not (IsServer and IsServer()) then return end
	local parent = self:GetParent()
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
	if not (IsServer and IsServer()) then return end
	self.radius = kv.radius or 900
	self.team = kv.team or (DOTA_TEAM_GOODGUYS or 2)
	if AddFOWViewer then
		AddFOWViewer(self.team, self:GetParent():GetAbsOrigin(), self.radius, kv.duration or 15, false)
	end
	self:StartIntervalThink(0.5)
end
function modifier_spellbringer_reveal_thinker:OnIntervalThink()
	local pos = self:GetParent():GetAbsOrigin()
	local enemies = FindUnitsInRadius(self.team, pos, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, unit in ipairs(enemies) do
		unit:AddNewModifier(self:GetParent(), nil, "modifier_truesight", { duration = 0.6 })
	end
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
