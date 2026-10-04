--------------------------------------------------------------------------------
-- boss_framework.lua
-- Server-authoritative Boss framework for Enfos Team Survival — SametC Edition
-- Implements native roster-hero Boss setup, bounded native ability/item AI, and
-- a small Boss-specific CC/reflect safety modifier. No custom Boss attacks,
-- phases, threshold adds, or fallback behavior are allowed at runtime.
-- Reference: docs/GAME_DESIGN_MASTER.md § 10, docs/QA_BALANCE_RELEASE.md § 7
--------------------------------------------------------------------------------

require("lib/log")
local WaveDefinitions = require("waves/wave_definitions")
local NativeHeroBosses = require("bosses/native_hero_bosses")
local BossModifier = require("bosses/boss_modifier")
local BossFramework = {}
BossFramework.__index = BossFramework

-- Boss Balance Caps (docs/QA_BALANCE_RELEASE.md § 7)
BossFramework.STATUS_RESISTANCE = BossModifier.STATUS_RESISTANCE -- Percent
BossFramework.MAX_REFLECT_DAMAGE = BossModifier.MAX_REFLECT_DAMAGE -- Per damage instance

--------------------------------------------------------------------------------
-- Initialize Framework
--------------------------------------------------------------------------------
function BossFramework:Init()
	self.activeBosses = {}
	Log:Info("boss_framework", "BossFramework initialized successfully.")
end

-- Convert the selected roster hero into a hostile native-kit Boss before
-- reward configuration and match balance scaling are applied by WaveManager.
function BossFramework:PrepareBoss(unit, heroName, waveNumber, defendingTeam)
	local plan = WaveDefinitions.BOSS_HEROES or {}
	local valid = false
	for _, mappedHero in pairs(plan) do
		if mappedHero == heroName then valid = true; break end
	end
	if not valid then
		Log:Error("boss_framework", "Refusing unapproved native Boss hero: %s", tostring(heroName))
		return false
	end
	return NativeHeroBosses:Prepare(unit, heroName, waveNumber, defendingTeam, unit and unit.bossRewardName)
end

--------------------------------------------------------------------------------
-- Register Boss Entity
--------------------------------------------------------------------------------
function BossFramework:RegisterBoss(unit, bossName, waveNumber, playerCount, defendingTeam)
	if not unit or unit:IsNull() then return end
	if not unit.nativeBossHero or type(unit.bossAbilityNames) ~= "table" then
		Log:Error("boss_framework", "Refusing to register legacy custom Boss %s without a prepared native hero kit", tostring(bossName))
		return false
	end

	-- Apply Boss baseline modifier (status resistance and reflect safety cap).
	unit:AddNewModifier(unit, nil, "modifier_enfos_boss_base", {})

	-- Initialize Boss AI state machine
	unit.bossState = {
		name = bossName,
		wave = waveNumber,
		players = playerCount or 1,
		defendingTeam = defendingTeam or unit.bossDefendingTeam,
		nativeHero = true,
	}

	-- Attach Boss Thinker
	unit:SetContextThink("BossThinker", function()
	return self:OnBossThink(unit)
	end, 0.5)

	self.activeBosses[unit:entindex()] = unit
	Log:Info("boss_framework", "Registered Boss '%s' for Wave %d (Players: %d)", bossName, waveNumber, playerCount or 1)
	return true
end

--------------------------------------------------------------------------------
-- Boss Thinker Loop
--------------------------------------------------------------------------------
function BossFramework:OnBossThink(unit)
	if not unit or unit:IsNull() or not unit:IsAlive() then
		if unit and not unit:IsNull() and self.activeBosses then
			self.activeBosses[unit:entindex()] = nil
		end
		return nil
	end

	if GameRules and GameRules.IsGamePaused and GameRules:IsGamePaused() then
		return 0.5
	end

	local state = unit.bossState
	if not state then return nil end
	if not state.nativeHero then
		Log:Error("boss_framework", "Stopping unprepared legacy Boss AI for %s", tostring(state.name))
		if self.activeBosses then self.activeBosses[unit:entindex()] = nil end
		return nil
	end
	return NativeHeroBosses:Think(unit, state)
end

-- Retire the dead entity immediately; a later Boss spawn only registers its
-- own entity. The existing thinker observes the cleared state and stops.
function BossFramework:OnBossKilled(unit)
	if not unit or unit:IsNull() then return end
	unit.bossState = nil
	if self.activeBosses then self.activeBosses[unit:entindex()] = nil end
end

--------------------------------------------------------------------------------
return BossFramework
