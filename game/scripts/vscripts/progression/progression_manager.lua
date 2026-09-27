--------------------------------------------------------------------------------
-- progression_manager.lua
-- Server-authoritative Progression Manager for Enfos Team Survival — SametC Edition
-- Coordinates player profiles, Account Level, Legacy allocation, Hero Mastery,
-- match rewards, idempotency, and NetTable synchronization.
-- Reference: docs/GAME_DESIGN_MASTER.md §§ 27, 28, 29
-- Reference: docs/IMPLEMENTATION_ROADMAP.md § Phase 10
--------------------------------------------------------------------------------

require("lib/log")
local StorageAdapter = require("progression/storage_adapter")
local ProgressionCurves = require("progression/progression_curves")

local ProgressionManager = {}
ProgressionManager.__index = ProgressionManager

--------------------------------------------------------------------------------
-- Init
--------------------------------------------------------------------------------
function ProgressionManager:Init(storageAdapter, waveManager, lifeCore)
	self.storageAdapter = storageAdapter or StorageAdapter.LocalStorageAdapter.New()
	self.waveManager = waveManager
	self.lifeCore = lifeCore
	self.initialized = true
	self.profiles = {} -- [playerId] = profile
	self.playerSteamIds = {} -- [playerId] = steamIdStr

	self:RegisterEventHandlers()
	Log:Info("progression_manager", "ProgressionManager initialized successfully.")
end

--------------------------------------------------------------------------------
-- Profile Loading / Reconnect
--------------------------------------------------------------------------------
function ProgressionManager:LoadPlayer(playerId, steamId)
	local idStr = tostring(steamId or playerId or "0")
	self.playerSteamIds[playerId] = idStr

	local profile = self.storageAdapter:LoadProfile(idStr)
	self.profiles[playerId] = profile

	self:SyncNetTable(playerId)
	Log:Info("progression_manager", "Loaded player %d (SteamID: %s) - Level %d, Unspent Legacy: %d",
		playerId, idStr, profile.accountLevel, profile.unspentLegacyPoints)

	return profile
end

function ProgressionManager:GetProfile(playerId)
	return self.profiles[playerId]
end

--------------------------------------------------------------------------------
-- Legacy Allocation & Respec
--------------------------------------------------------------------------------
function ProgressionManager:AllocateLegacyRank(playerId, branch)
	local profile = self.profiles[playerId]
	if not profile then return false, "profile_not_loaded" end

	local ok, errOrRank = ProgressionCurves.AllocateLegacyRank(profile, branch)
	if not ok then
		Log:Warn("progression_manager", "Player %d failed to allocate Legacy to [%s]: %s",
			playerId, tostring(branch), tostring(errOrRank))
		return false, errOrRank
	end

	self.storageAdapter:SaveProfile(profile.steamId, profile)
	self:SyncNetTable(playerId)
	return true, errOrRank
end

function ProgressionManager:RespecLegacy(playerId)
	local profile = self.profiles[playerId]
	if not profile then return false, "profile_not_loaded" end

	local ok, refunded = ProgressionCurves.RespecLegacy(profile)
	if not ok then return false end

	self.storageAdapter:SaveProfile(profile.steamId, profile)
	self:SyncNetTable(playerId)
	return true, refunded
end

--------------------------------------------------------------------------------
-- Match End Rewards (Idempotent)
--------------------------------------------------------------------------------
function ProgressionManager:AwardMatchRewards(playerId, matchId, params)
	local profile = self.profiles[playerId]
	if not profile then
		Log:Warn("progression_manager", "Cannot award match rewards: Player %d profile not loaded", playerId)
		return nil, "profile_not_loaded"
	end

	local mId = tostring(matchId or ("match_" .. tostring(GameRules and GameRules:GetGameTime() or 0)))

	-- Idempotency check: never process the same match twice
	if profile.processedMatchIds and profile.processedMatchIds[mId] then
		Log:Warn("progression_manager", "REJECTED duplicate reward award for match [%s] on player %d", mId, playerId)
		return nil, "duplicate_match"
	end

	local rewards = ProgressionCurves.CalculateMatchRewards(params)

	-- 1. Account XP & Level
	local _, levelsGained = ProgressionCurves.AddAccountXP(profile, rewards.accountXp)

	-- 2. Hero Mastery XP
	local heroId = params.heroId or (PlayerResource:GetSelectedHeroEntity(playerId) and
		PlayerResource:GetSelectedHeroEntity(playerId):GetUnitName()) or "unknown_hero"

	profile.heroMastery = profile.heroMastery or {}
	if not profile.heroMastery[heroId] then
		profile.heroMastery[heroId] = {
			rank = 1,
			xp = 0,
			passivePoints = 0,
			buildUnlocks = {},
		}
	end

	local heroData = profile.heroMastery[heroId]
	local _, ranksGained = ProgressionCurves.AddHeroMasteryXP(heroData, rewards.heroXp)

	-- 3. Check difficulty unlock
	local unlockedDiff, newDiff = ProgressionCurves.CheckDifficultyUnlock(
		profile, params.difficulty or "normal", rewards.isFullClear)

	-- 4. Mark match as processed
	profile.processedMatchIds = profile.processedMatchIds or {}
	profile.processedMatchIds[mId] = true

	local summary = {
		matchId = mId,
		accountXpEarned = rewards.accountXp,
		heroXpEarned = rewards.heroXp,
		levelsGained = levelsGained,
		ranksGained = ranksGained,
		unlockedDifficulty = unlockedDiff and newDiff or nil,
		outcome = rewards.outcome,
		completedWaves = params.completedWaves or 0,
		isFullClear = rewards.isFullClear,
	}

	profile.lastMatchRewards = summary
	table.insert(profile.matchHistory, summary)
	if #profile.matchHistory > 10 then
		table.remove(profile.matchHistory, 1)
	end

	-- 5. Save & Sync
	self.storageAdapter:SaveProfile(profile.steamId, profile)
	self:SyncNetTable(playerId)

	Log:Info("progression_manager", "REWARDED Player %d: +%d Account XP, +%d Hero XP [%s] (Match: %s)",
		playerId, rewards.accountXp, rewards.heroXp, heroId, mId)

	return summary
end

--------------------------------------------------------------------------------
-- NetTable Synchronization
--------------------------------------------------------------------------------
function ProgressionManager:SyncNetTable(playerId)
	if not CustomNetTables then return end
	local profile = self.profiles[playerId]
	if not profile then return end

	local reqXP = ProgressionCurves.GetAccountLevelXPRequired(profile.accountLevel) or 0

	CustomNetTables:SetTableValue("progression_state", "player_" .. tostring(playerId), {
		storage_durable = self.storageAdapter.durable == true and 1 or 0,
		account_level = profile.accountLevel or 1,
		account_xp = profile.accountXp or 0,
		account_xp_required = reqXP,
		unspent_legacy = profile.unspentLegacyPoints or 0,
		legacy = profile.legacy or { offense = 0, defense = 0, economy = 0, spellbringer = 0 },
		highest_difficulty = profile.highestDifficultyUnlocked or "normal",
		hero_unlock_tokens = profile.heroUnlockTokens or 0,
		hero_mastery = profile.heroMastery or {},
		last_rewards = profile.lastMatchRewards or {},
	})
end

--------------------------------------------------------------------------------
-- Custom Game Event Handlers
--------------------------------------------------------------------------------
function ProgressionManager:RegisterEventHandlers()
	if not CustomGameEventManager then return end

	CustomGameEventManager:RegisterListener("enfos_allocate_legacy_rank", function(_, event)
		local playerId = event.PlayerID
		local branch = event.branch
		ProgressionManager:AllocateLegacyRank(playerId, branch)
	end)

	CustomGameEventManager:RegisterListener("enfos_respec_legacy", function(_, event)
		local playerId = event.PlayerID
		ProgressionManager:RespecLegacy(playerId)
	end)
end

return ProgressionManager
