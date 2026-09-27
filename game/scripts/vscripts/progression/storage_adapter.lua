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
	if type(profile)~="table" then return StorageAdapter.CreateDefaultProfile() end
	local defaults=StorageAdapter.CreateDefaultProfile(profile.steamId)
	for key,value in pairs(defaults) do
		if type(profile[key])~=type(value) then profile[key]=value end
	end
	local function integer(value,low,high)
		local n=require("lib/validation").Finite(value) or low
		return math.max(low,math.min(high,math.floor(n)))
	end
	profile.accountLevel=integer(profile.accountLevel,1,100)
	profile.accountXp=integer(profile.accountXp,0,100000000)
	local earned=math.min(24,math.floor(profile.accountLevel/2))
	local spent=0
	for _,branch in ipairs({"offense","defense","economy","spellbringer"}) do
		profile.legacy[branch]=integer(profile.legacy[branch],0,12)
		spent=spent+profile.legacy[branch]
	end
	if spent>earned then
		for branch in pairs(profile.legacy) do profile.legacy[branch]=0 end
		spent=0
	end
	profile.unspentLegacyPoints=earned-spent
	profile.schemaVersion=StorageAdapter.CURRENT_SCHEMA_VERSION
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
	self.durable = false
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
	self.durable = false
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
