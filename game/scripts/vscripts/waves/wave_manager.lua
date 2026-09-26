--------------------------------------------------------------------------------
-- wave_manager.lua
-- Central server-authoritative wave manager
-- Orchestrates 60 authored waves, batch spawning, unit-cap overflow leaks,
-- Boss-only transitions, and HUD NetTable synchronization.
-- Reference: docs/GAME_DESIGN_MASTER.md §§ 3, 5, 8, 9, 10
--------------------------------------------------------------------------------

require("lib/log")
local WaveDefinitions = require("waves/wave_definitions")
local CreepAI = require("waves/creep_ai")
local LifeCore = require("waves/life_core")

local WaveManager = {}
WaveManager.__index = WaveManager

-- Wave States
WaveManager.STATE_IDLE = "IDLE"
WaveManager.STATE_PREPARATION = "PREPARATION"
WaveManager.STATE_BOSS_INCOMING = "BOSS_INCOMING"
WaveManager.STATE_SPAWNING = "SPAWNING"
WaveManager.STATE_ACTIVE = "ACTIVE"
WaveManager.STATE_CLEARED = "CLEARED"
WaveManager.STATE_VICTORY = "VICTORY"

-- Timings (seconds)
WaveManager.PREPARATION_TIME = 15.0
WaveManager.BOSS_INCOMING_TIME = 5.0
WaveManager.THINK_INTERVAL = 0.5

-- Spawner positions
WaveManager.SPAWN_LOCATIONS = {
	-- Radiant (2)
	[2] = {
		left = Vector(4658, 2841, 136),
		center = Vector(7706, -1452, 136),
		right = Vector(10510, 3095, 136),
	},
	-- Dire (3)
	[3] = {
		left = Vector(-10590, 2763, 136),
		center = Vector(-7752, -1367, 136),
		right = Vector(-5026, 3509, 143),
	},
}

--------------------------------------------------------------------------------
-- Initialize Wave Manager
--------------------------------------------------------------------------------
function WaveManager:Init()
	self.currentWave = 0
	self.state = WaveManager.STATE_IDLE
	self.stateTimer = 0
	self.activeCreeps = {
		[DOTA_TEAM_GOODGUYS or 2] = {},
		[DOTA_TEAM_BADGUYS or 3] = {},
	}
	self.pendingBatches = {}
	self.batchSpawnTimer = 0

	-- Initialize Life Core
	LifeCore:Init(self)

	-- Register Listeners
	ListenToGameEvent("entity_killed", Dynamic_Wrap(WaveManager, "OnEntityKilled"), self)

	-- Start Global Thinker
	GameRules:GetGameModeEntity():SetThink("WaveManager_Think", function()
		return self:OnThink()
	end, WaveManager.THINK_INTERVAL)

	self:SyncNetTable()
	Log:Info("wave_manager", "Wave Manager initialized successfully.")
end

--------------------------------------------------------------------------------
-- Active Player Count Calculation
--------------------------------------------------------------------------------
function WaveManager:GetActivePlayerCount(team)
	local count = 0
	for playerId = 0, 9 do
		if PlayerResource:IsValidPlayerID(playerId) then
			local playerTeam = PlayerResource:GetTeam(playerId)
			if (not team or playerTeam == team) and PlayerResource:GetConnectionState(playerId) == DOTA_CONNECTION_STATE_CONNECTED then
				count = count + 1
			end
		end
	end
	return math.max(1, count)
end

function WaveManager:GetUnitCap(team)
	local players = self:GetActivePlayerCount(team)
	return WaveDefinitions:GetUnitCap(players)
end

--------------------------------------------------------------------------------
-- Think Loop
--------------------------------------------------------------------------------
function WaveManager:OnThink()
	if GameRules:State_Get() < DOTA_GAMERULES_STATE_PRE_GAME then
		return WaveManager.THINK_INTERVAL
	end

	-- Auto-start from IDLE once game reaches PRE_GAME or GAME_IN_PROGRESS
	if self.state == WaveManager.STATE_IDLE then
		if GameRules:State_Get() >= DOTA_GAMERULES_STATE_PRE_GAME then
			self:StartPreparation()
		end
		return WaveManager.THINK_INTERVAL
	end

	-- Handle Preparation Countdown
	if self.state == WaveManager.STATE_PREPARATION then
		self.stateTimer = self.stateTimer - WaveManager.THINK_INTERVAL
		if self.stateTimer <= 0 then
			local nextWave = self.currentWave + 1
			if WaveDefinitions:IsBossWave(nextWave) then
				self:StartBossIncoming()
			else
				self:StartWave(nextWave)
			end
		end
		self:SyncNetTable()
		return WaveManager.THINK_INTERVAL
	end

	-- Handle Boss Incoming Countdown
	if self.state == WaveManager.STATE_BOSS_INCOMING then
		self.stateTimer = self.stateTimer - WaveManager.THINK_INTERVAL
		if self.stateTimer <= 0 then
			self:StartWave(self.currentWave + 1)
		end
		self:SyncNetTable()
		return WaveManager.THINK_INTERVAL
	end

	-- Handle Batch Spawning
	if self.state == WaveManager.STATE_SPAWNING then
		self.batchSpawnTimer = self.batchSpawnTimer - WaveManager.THINK_INTERVAL
		if self.batchSpawnTimer <= 0 then
			self:SpawnNextBatch()
		end
		self:SyncNetTable()
		return WaveManager.THINK_INTERVAL
	end

	-- Handle Active Wave
	if self.state == WaveManager.STATE_ACTIVE then
		local goodCount = self:GetActiveCreepCount(DOTA_TEAM_GOODGUYS or 2)
		local badCount = self:GetActiveCreepCount(DOTA_TEAM_BADGUYS or 3)

		if goodCount == 0 and badCount == 0 then
			self:OnWaveCleared()
		end
		self:SyncNetTable()
		return WaveManager.THINK_INTERVAL
	end

	return WaveManager.THINK_INTERVAL
end

--------------------------------------------------------------------------------
-- Preparation Phase
--------------------------------------------------------------------------------
function WaveManager:StartPreparation(customDuration)
	self.state = WaveManager.STATE_PREPARATION
	self.stateTimer = customDuration or WaveManager.PREPARATION_TIME

	local nextWaveNum = self.currentWave + 1
	Log:Info("wave_manager", "Preparation phase started for Wave %d (Duration: %.1fs).", nextWaveNum, self.stateTimer)

	self:SyncNetTable()
end

--------------------------------------------------------------------------------
-- Boss Incoming Transition (Clean Battlefield Rule)
-- Reference: docs/GAME_DESIGN_MASTER.md § 3
--------------------------------------------------------------------------------
function WaveManager:StartBossIncoming()
	self.state = WaveManager.STATE_BOSS_INCOMING
	self.stateTimer = WaveManager.BOSS_INCOMING_TIME

	local bossWaveNum = self.currentWave + 1
	local waveDef = WaveDefinitions:GetWave(bossWaveNum)

	Log:Warn("wave_manager", "========================================")
	Log:Warn("wave_manager", "BOSS INCOMING: Wave %d (%s)", bossWaveNum, waveDef and waveDef.boss_name or "Unknown")
	Log:Warn("wave_manager", "========================================")

	-- Announce to all players
	EmitGlobalSound("sounds/ui/stingers/boss_incoming.vsnd")
	CustomGameEventManager:Send_ServerToAllClients("enfos_boss_incoming", {
		wave = bossWaveNum,
		boss_name = waveDef and waveDef.boss_name or "",
	})

	-- Clean battlefield rule: resolve any remaining leakable units once
	for _, team in ipairs({ DOTA_TEAM_GOODGUYS or 2, DOTA_TEAM_BADGUYS or 3 }) do
		local creeps = self.activeCreeps[team]
		if creeps then
			for entIndex, creep in pairs(creeps) do
				if creep and not creep:IsNull() and creep:IsAlive() then
					local leakPenalty = WaveDefinitions:GetLeakPenalty(creep:GetUnitName())
					if leakPenalty > 0 then
						-- Apply standard leak penalty
						LifeCore:ApplyDamage(team, leakPenalty, "boss_transition_cleanup", creep:GetUnitName())
					end
					creep:ForceKill(false)
					UTIL_Remove(creep)
				end
			end
		end
		self.activeCreeps[team] = {}
	end

	self:SyncNetTable()
end

--------------------------------------------------------------------------------
-- Start Wave
--------------------------------------------------------------------------------
function WaveManager:StartWave(waveNumber)
	if waveNumber > WaveDefinitions:GetTotalWaves() then
		Log:Info("wave_manager", "All 60 waves completed! Entering Endless or Victory.")
		self.state = WaveManager.STATE_VICTORY
		self:SyncNetTable()
		return
	end

	self.currentWave = waveNumber
	local waveDef = WaveDefinitions:GetWave(waveNumber)
	if not waveDef then
		Log:Error("wave_manager", "Missing wave definition for Wave %d!", waveNumber)
		return
	end

	self.state = WaveManager.STATE_SPAWNING
	self.pendingBatches = {}

	local isBoss = WaveDefinitions:IsBossWave(waveNumber)
	local isElite = WaveDefinitions:IsEliteWave(waveNumber)

	Log:Info("wave_manager", "Starting Wave %d [Type: %s, Batches: %d]",
		waveNumber, waveDef.wave_type, waveDef.batches)

	-- Prepare batches
	local totalBatches = waveDef.batches or 1
	for b = 1, totalBatches do
		table.insert(self.pendingBatches, {
			batchIndex = b,
			totalBatches = totalBatches,
			waveDef = waveDef,
		})
	end

	self.batchSpawnTimer = 0 -- Spawn first batch immediately
	self:SyncNetTable()
end

--------------------------------------------------------------------------------
-- Spawn Batch (with Active Hostile Unit-Cap and Overflow Leak)
-- Reference: docs/GAME_DESIGN_MASTER.md § 5
--------------------------------------------------------------------------------
function WaveManager:SpawnNextBatch()
	if #self.pendingBatches == 0 then
		self.state = WaveManager.STATE_ACTIVE
		self:SyncNetTable()
		return
	end

	local batch = table.remove(self.pendingBatches, 1)
	local waveDef = batch.waveDef
	local isBoss = WaveDefinitions:IsBossWave(self.currentWave)

	-- Check teams to spawn for
	local teams = { DOTA_TEAM_GOODGUYS or 2, DOTA_TEAM_BADGUYS or 3 }

	for _, team in ipairs(teams) do
		local activePlayers = self:GetActivePlayerCount(team)
		local unitCap = self:GetUnitCap(team)

		for _, creepEntry in ipairs(waveDef.creeps or {}) do
			local unitName = creepEntry.unit_name
			local countPerPlayer = creepEntry.count_per_player or 1
			local laneAssignment = creepEntry.lane or "both"
			local totalToSpawn = math.max(1, countPerPlayer * activePlayers)

			-- Determine lanes for this creep entry
			local lanes = {}
			if isBoss or laneAssignment == "center" then
				lanes = { "center" }
			elseif laneAssignment == "left" then
				lanes = { "left" }
			elseif laneAssignment == "right" then
				lanes = { "right" }
			else
				-- "both" lanes: split creeps evenly between left and right lanes
				lanes = { "left", "right" }
			end

			-- Distribute total units across batches
			local unitsThisBatch = math.ceil(totalToSpawn / batch.totalBatches)
			if batch.batchIndex == batch.totalBatches then
				-- Last batch takes remainder
				unitsThisBatch = totalToSpawn - (unitsThisBatch * (batch.totalBatches - 1))
				if unitsThisBatch < 1 then unitsThisBatch = 1 end
			end

			for i = 1, unitsThisBatch do
				local lane = lanes[((i - 1) % #lanes) + 1]
				local currentActive = self:GetActiveCreepCount(team)

				-- OVERFLOW LEAK CHECK:
				-- If current active hostiles >= unitCap:
				-- Do NOT spawn entity. Immediately apply leak Life penalty!
				-- Boss is exempt: Boss ALWAYS spawns.
				if not isBoss and currentActive >= unitCap then
					local leakCost = WaveDefinitions:GetLeakPenalty(unitName)
					LifeCore:ApplyDamage(team, leakCost, "unit_cap_overflow", unitName)
					Log:Warn("wave_manager", "CAP OVERFLOW! Team %d at unit cap (%d/%d). Creep %s suppressed. -%d Life.",
						team, currentActive, unitCap, unitName, leakCost)
				else
					-- Spawn the creep entity
					self:SpawnCreepEntity(unitName, team, lane, isBoss, activePlayers)
				end
			end
		end
	end

	-- Set timer for next batch
	self.batchSpawnTimer = waveDef.batch_interval or 3.5

	if #self.pendingBatches == 0 then
		self.state = WaveManager.STATE_ACTIVE
	end

	self:SyncNetTable()
end

--------------------------------------------------------------------------------
-- Spawn Creep Entity & Attach AI
--------------------------------------------------------------------------------
function WaveManager:SpawnCreepEntity(unitName, defendingTeam, lane, isBoss, activePlayers)
	local spawnLocs = WaveManager.SPAWN_LOCATIONS[defendingTeam]
	if not spawnLocs then return end

	local spawnPos = spawnLocs[lane] or spawnLocs.left
	-- Slight random offset to prevent stacking
	local offset = RandomVector(RandomFloat(0, 60))
	local finalPos = spawnPos + Vector(offset.x, offset.y, 0)

	-- Creeps are on DOTA_TEAM_NEUTRALS (4) so both players and towers can target them
	local creep = CreateUnitByName(unitName, finalPos, true, nil, nil, DOTA_TEAM_NEUTRALS or 4)
	if not creep or creep:IsNull() then
		Log:Error("wave_manager", "Failed to create unit: %s", unitName)
		return
	end

	-- Tag creep metadata
	creep.defendingTeam = defendingTeam
	creep.laneName = lane
	creep.waveNumber = self.currentWave

	-- Boss HP scaling: 1 + 0.75 * (players - 1)
	if isBoss and activePlayers > 1 then
		local multiplier = 1 + 0.75 * (activePlayers - 1)
		local baseHealth = creep:GetMaxHealth()
		local scaledHealth = math.floor(baseHealth * multiplier)
		creep:SetMaxHealth(scaledHealth)
		creep:SetBaseMaxHealth(scaledHealth)
		creep:SetHealth(scaledHealth)
		Log:Info("wave_manager", "Scaled Boss HP for %d players: %d -> %d", activePlayers, baseHealth, scaledHealth)
	end

	-- Register active creep
	self.activeCreeps[defendingTeam][creep:entindex()] = creep

	-- Attach AI navigation and leak callback
	CreepAI:Attach(creep, defendingTeam, lane, function(leakingUnit, team)
		LifeCore:ProcessLeak(leakingUnit, team)
	end)

	return creep
end

--------------------------------------------------------------------------------
-- Creep Removed / Killed Handling
--------------------------------------------------------------------------------
function WaveManager:OnCreepRemoved(unit, team)
	if not unit or unit:IsNull() then return end
	local entIndex = unit:entindex()
	if self.activeCreeps[team] then
		self.activeCreeps[team][entIndex] = nil
	end
	self:SyncNetTable()
end

function WaveManager:OnEntityKilled(event)
	local killedUnit = EntIndexToHScript(event.entindex_killed)
	if not killedUnit or killedUnit:IsNull() then return end

	local killerUnit = event.entindex_attacker and EntIndexToHScript(event.entindex_attacker) or nil
	local defendingTeam = killedUnit.defendingTeam

	if defendingTeam and self.activeCreeps[defendingTeam] then
		self:OnCreepRemoved(killedUnit, defendingTeam)
	end
end

--------------------------------------------------------------------------------
-- Wave Cleared
--------------------------------------------------------------------------------
function WaveManager:OnWaveCleared()
	local waveDef = WaveDefinitions:GetWave(self.currentWave)
	Log:Info("wave_manager", "Wave %d CLEARED! Distributing completion rewards.", self.currentWave)

	self.state = WaveManager.STATE_CLEARED

	-- Distribute wave completion bounties to players
	if waveDef then
		local goldBounty = waveDef.gold_bounty or 50
		local xpBounty = waveDef.xp_bounty or 75

		for playerId = 0, 9 do
			if PlayerResource:IsValidPlayerID(playerId) then
				PlayerResource:ModifyGold(playerId, goldBounty, true, DOTA_ModifyGold_Unspecified)
				local hero = PlayerResource:GetSelectedHeroEntity(playerId)
				if hero and not hero:IsNull() and hero:IsAlive() then
					hero:AddExperience(xpBounty, DOTA_ModifyXP_CreepKill, false, true)
				end
			end
		end
	end

	-- Sound feedback
	EmitGlobalSound("General.Coins")

	-- Transition to next wave preparation
	self:StartPreparation()
end

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------
function WaveManager:GetActiveCreepCount(team)
	local count = 0
	local teamCreeps = self.activeCreeps[team]
	if teamCreeps then
		for entIndex, creep in pairs(teamCreeps) do
			if creep and not creep:IsNull() and creep:IsAlive() then
				count = count + 1
			else
				teamCreeps[entIndex] = nil
			end
		end
	end
	return count
end

--------------------------------------------------------------------------------
-- NetTable Sync
--------------------------------------------------------------------------------
function WaveManager:SyncNetTable()
	if not CustomNetTables then return end

	local waveDef = WaveDefinitions:GetWave(self.currentWave)
	local nextWaveNum = (self.state == WaveManager.STATE_PREPARATION or self.state == WaveManager.STATE_BOSS_INCOMING)
		and (self.currentWave + 1) or self.currentWave

	local displayDef = WaveDefinitions:GetWave(nextWaveNum) or waveDef

	CustomNetTables:SetTableValue("wave_info", "status", {
		current_wave = self.currentWave,
		next_wave = nextWaveNum,
		max_waves = WaveDefinitions:GetTotalWaves(),
		state = self.state,
		state_timer = math.max(0, math.floor(self.stateTimer + 0.5)),
		is_boss = displayDef and WaveDefinitions:IsBossWave(displayDef.wave_number) or false,
		is_elite = displayDef and WaveDefinitions:IsEliteWave(displayDef.wave_number) or false,
		title = displayDef and displayDef.title or "",
		active_goodguys = self:GetActiveCreepCount(DOTA_TEAM_GOODGUYS or 2),
		active_badguys = self:GetActiveCreepCount(DOTA_TEAM_BADGUYS or 3),
		cap_goodguys = self:GetUnitCap(DOTA_TEAM_GOODGUYS or 2),
		cap_badguys = self:GetUnitCap(DOTA_TEAM_BADGUYS or 3),
	})
end

return WaveManager
