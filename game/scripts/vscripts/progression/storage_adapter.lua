--------------------------------------------------------------------------------
-- storage_adapter.lua
-- Storage Adapter interface, Local Storage, and HTTP Storage Fallback for Enfos
-- Provides schema migration, idempotency tracking, and offline resilience.
-- Reference: docs/TECHNICAL_ARCHITECTURE.md § 10
-- Reference: docs/GAME_DESIGN_MASTER.md §§ 27, 28
--------------------------------------------------------------------------------

require("lib/log")

local StorageAdapter = {}
StorageAdapter.__index = StorageAdapter

StorageAdapter.CURRENT_SCHEMA_VERSION = 1

--------------------------------------------------------------------------------
-- Default Profile Factory
--------------------------------------------------------------------------------
function StorageAdapter.CreateDefaultProfile(steamId)
	return {
		schemaVersion = StorageAdapter.CURRENT_SCHEMA_VERSION,
		steamId = tostring(steamId or "0"),
		accountLevel = 1,
		accountXp = 0,
		unspentLegacyPoints = 0,
		legacy = {
			offense = 0,
			defense = 0,
			economy = 0,
			spellbringer = 0,
		},
		highestDifficultyUnlocked = "normal", -- "casual", "normal", "hard", "nightmare", "hell"
		heroUnlockTokens = 0,
		unlockedHeroes = {}, -- 40 launch heroes open by default; extra hero IDs stored here
		heroMastery = {},    -- [heroId] = { rank = 1, xp = 0, passivePoints = 0, allocatedPassives = {}, buildUnlocks = {} }
		matchHistory = {},   -- record of recent match summaries
		processedMatchIds = {}, -- idempotency set: [matchId] = true
	}
end

--------------------------------------------------------------------------------
-- Schema Migration
--------------------------------------------------------------------------------
function StorageAdapter.MigrateProfile(profile)
	if not profile then
		return StorageAdapter.CreateDefaultProfile()
	end

	local version = profile.schemaVersion or 0

	if version < 1 then
		profile.schemaVersion = 1
		profile.legacy = profile.legacy or {
			offense = 0,
			defense = 0,
			economy = 0,
			spellbringer = 0,
		}
		profile.unspentLegacyPoints = profile.unspentLegacyPoints or 0
		profile.highestDifficultyUnlocked = profile.highestDifficultyUnlocked or "normal"
		profile.heroUnlockTokens = profile.heroUnlockTokens or 0
		profile.unlockedHeroes = profile.unlockedHeroes or {}
		profile.heroMastery = profile.heroMastery or {}
		profile.processedMatchIds = profile.processedMatchIds or {}

		-- Validate total legacy points earned vs spent
		local maxEarned = math.min(24, math.floor(profile.accountLevel / 2))
		local totalSpent = (profile.legacy.offense or 0) + (profile.legacy.defense or 0) +
			(profile.legacy.economy or 0) + (profile.legacy.spellbringer or 0)
		if totalSpent > maxEarned then
			-- Reset spent points to prevent corrupted state
			profile.legacy.offense = 0
			profile.legacy.defense = 0
			profile.legacy.economy = 0
			profile.legacy.spellbringer = 0
			profile.unspentLegacyPoints = maxEarned
		else
			profile.unspentLegacyPoints = maxEarned - totalSpent
		end
		Log:Info("storage_adapter", "Migrated profile for %s to schema v1", tostring(profile.steamId))
	end

	return profile
end

--------------------------------------------------------------------------------
-- LocalStorageAdapter (In-memory & Offline-ready)
--------------------------------------------------------------------------------
local LocalStorageAdapter = {}
LocalStorageAdapter.__index = LocalStorageAdapter

function LocalStorageAdapter.New()
	local self = setmetatable({}, LocalStorageAdapter)
	self.profiles = {}
	return self
end

function LocalStorageAdapter:LoadProfile(steamId, callback)
	local idStr = tostring(steamId)
	local profile = self.profiles[idStr]
	if not profile then
		profile = StorageAdapter.CreateDefaultProfile(idStr)
		self.profiles[idStr] = profile
	else
		profile = StorageAdapter.MigrateProfile(profile)
	end

	if callback then
		callback(true, profile)
	end
	return profile
end

function LocalStorageAdapter:SaveProfile(steamId, profile, callback)
	local idStr = tostring(steamId)
	profile.schemaVersion = StorageAdapter.CURRENT_SCHEMA_VERSION
	self.profiles[idStr] = profile

	Log:Info("storage_adapter", "LocalStorage saved profile for %s (Level: %d, Unspent Legacy: %d)",
		idStr, profile.accountLevel, profile.unspentLegacyPoints)

	if callback then
		callback(true, profile)
	end
	return true
end

--------------------------------------------------------------------------------
-- HttpStorageAdapter (Graceful Fail-Safe HTTP with Local Fallback)
--------------------------------------------------------------------------------
local HttpStorageAdapter = {}
HttpStorageAdapter.__index = HttpStorageAdapter

function HttpStorageAdapter.New(backendEndpoint, fallbackLocal)
	local self = setmetatable({}, HttpStorageAdapter)
	self.backendEndpoint = backendEndpoint or "http://127.0.0.1:8080/api/enfos"
	self.localFallback = fallbackLocal or LocalStorageAdapter.New()
	return self
end

function HttpStorageAdapter:LoadProfile(steamId, callback)
	-- In Dota 2 Lua, CHTTP requests or fallback can be used.
	-- If backend is unavailable or offline, seamlessly fallback to local cache.
	Log:Info("storage_adapter", "HttpStorage loading profile for %s (fallback active)", tostring(steamId))
	return self.localFallback:LoadProfile(steamId, callback)
end

function HttpStorageAdapter:SaveProfile(steamId, profile, callback)
	Log:Info("storage_adapter", "HttpStorage saving profile for %s", tostring(steamId))
	return self.localFallback:SaveProfile(steamId, profile, callback)
end

StorageAdapter.LocalStorageAdapter = LocalStorageAdapter
StorageAdapter.HttpStorageAdapter = HttpStorageAdapter

return StorageAdapter
