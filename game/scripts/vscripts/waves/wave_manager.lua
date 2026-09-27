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
local Rewards = require("waves/rewards")
local BossFramework = require("bosses/boss_framework")
local EliteFramework = require("bosses/elite_framework")
local EconomyManager = require("economy/economy_manager")
local BoonManager = require("boons/boon_manager")

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
	self.spawnPlans = {}
	self.wavePlayers = {}
	self.batchSpawnTimer = 0

	-- Initialize Life Core, Rewards, Boss and Elite Frameworks
	LifeCore:Init(self)
	Rewards:Init()
	BossFramework:Init()
	EliteFramework:Init()

	-- Register Listeners
	ListenToGameEvent("entity_killed", Dynamic_Wrap(WaveManager, "OnEntityKilled"), self)

	-- Start Global Thinker
	GameRules:GetGameModeEntity():SetContextThink("WaveManager_Think", function()
		return self:OnThink()
	end, WaveManager.THINK_INTERVAL)
	CustomGameEventManager:RegisterListener("enfos_next_wave", function(_, event)
		self:RequestNextWave(event.PlayerID)
	end)

	self.difficulty = "normal"
	self:SyncNetTable()
	Log:Info("wave_manager", "Wave Manager initialized successfully.")
end

function WaveManager:SetDifficulty(difficulty)
	self.difficulty = (difficulty or "normal"):lower()
	Log:Info("wave_manager", "Game difficulty set to: %s", self.difficulty)
end

function WaveManager:GetDifficulty()
	return self.difficulty or "normal"
end

--------------------------------------------------------------------------------
-- Active Player Count Calculation
--------------------------------------------------------------------------------
function WaveManager:GetActivePlayerCount(team)
	local count = 0
	for playerId = 0, (DOTA_MAX_TEAM_PLAYERS or 24)-1 do
		if PlayerResource:IsValidPlayerID(playerId) then
			local playerTeam = PlayerResource:GetTeam(playerId)
			if (not team or playerTeam == team) then
				local connState = PlayerResource:GetConnectionState(playerId)
				local hasHero = PlayerResource.GetSelectedHeroEntity and (PlayerResource:GetSelectedHeroEntity(playerId) ~= nil)
				if connState == (DOTA_CONNECTION_STATE_CONNECTED or 2) or hasHero then
					count = count + 1
				end
			end
		end
	end
	return count
end

function WaveManager:GetUnitCap(team)
	local players = self:GetActivePlayerCount(team)
	return WaveDefinitions:GetUnitCap(players)
end

--------------------------------------------------------------------------------
-- Think Loop
--------------------------------------------------------------------------------
function WaveManager:OnThink()
	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME or LifeCore.isGameOver then return nil end
	if GameRules:IsGamePaused() then return WaveManager.THINK_INTERVAL end
	if GameRules:State_Get() < DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		return WaveManager.THINK_INTERVAL
	end

	-- Auto-start once the match begins.
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
					creep.enfosLeaked = true
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
	self.spawnPlans, self.wavePlayers = {}, {}
	for _, team in ipairs({2,3}) do
		self.wavePlayers[team] = self:GetActivePlayerCount(team)
		self.spawnPlans[team] = WaveDefinitions:GetSpawnPlan(waveNumber,self.wavePlayers[team])
	end
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
		local activePlayers = self.wavePlayers[team] or self:GetActivePlayerCount(team)
		local unitCap = self:GetUnitCap(team)

		if activePlayers > 0 then
			for _, creepEntry in ipairs(self.spawnPlans[team] or {}) do
				local unitName = creepEntry.unit_name
				local countPerPlayer = creepEntry.count_per_player or 1
				local laneAssignment = creepEntry.lane or "both"
				local totalToSpawn = creepEntry.count

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
				local previous = math.floor(totalToSpawn * (batch.batchIndex - 1) / batch.totalBatches)
				local unitsThisBatch = math.floor(totalToSpawn * batch.batchIndex / batch.totalBatches) - previous

				for i = 1, unitsThisBatch do
					local lane = lanes[((previous + i - 1) % #lanes) + 1]
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
	creep.isBoss = isBoss
	Rewards:Configure(creep, unitName)
	creep:SetIdleAcquire(true)
	creep:SetAcquisitionRange(unitName == "enfos_creep_runner" and 0 or 650)

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

	-- Hook Boss / Elite frameworks
	if isBoss then
		BossFramework:RegisterBoss(creep, unitName, self.currentWave, activePlayers)
	elseif unitName:find("enfos_elite_", 1, true) then
		EliteFramework:RegisterElite(creep, unitName, self.currentWave)
	end

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
		if self.activeCreeps[defendingTeam][killedUnit:entindex()] then
			Rewards:OnKill(killedUnit, killerUnit)
			if killedUnit.isBoss then
				if EconomyManager then
					EconomyManager:AwardBossLumber(defendingTeam, self.currentWave)
				end
				if BoonManager then
					BoonManager:StartVote(defendingTeam, self.currentWave)
				end
			end
		end
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

		for _, team in ipairs({2,3}) do
			for _, playerId in ipairs(Rewards:Players(team)) do Rewards:Credit(playerId,goldBounty,xpBounty) end
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
	local summaries = {}
	for _, team in ipairs({2,3}) do
		local plan = self.spawnPlans[team] or {}
		if self.state == self.STATE_PREPARATION or self.state == self.STATE_IDLE then
			plan = WaveDefinitions:GetSpawnPlan(math.min(self.currentWave+1,WaveDefinitions:GetTotalWaves()),self:GetActivePlayerCount(team))
		end
		summaries[team] = Rewards:Estimate(plan)
	end

	CustomNetTables:SetTableValue("wave_info", "status", {
		current_wave = self.currentWave,
		next_wave = nextWaveNum,
		max_waves = WaveDefinitions:GetTotalWaves(),
		state = self.state,
		can_send_next = self:CanSendNextWave() and 1 or 0,
		planned_goodguys = summaries[2].count,
		planned_badguys = summaries[3].count,
		gold_min_goodguys = summaries[2].goldMin,
		gold_max_goodguys = summaries[2].goldMax,
		gold_min_badguys = summaries[3].goldMin,
		gold_max_badguys = summaries[3].goldMax,
		clear_gold = displayDef and displayDef.gold_bounty or 0,
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

function WaveManager:CanSendNextWave()
	return self.currentWave > 0 and self.currentWave < WaveDefinitions:GetTotalWaves()
		and self.state == self.STATE_PREPARATION and #self.pendingBatches == 0
		and not LifeCore.isGameOver
		and self:GetActiveCreepCount(2) == 0 and self:GetActiveCreepCount(3) == 0
end

function WaveManager:RequestNextWave(playerID)
	if type(playerID) ~= "number" or not PlayerResource:IsValidPlayerID(playerID) then return false end
	local team = PlayerResource:GetTeam(playerID)
	if team ~= 2 and team ~= 3 then return false end
	if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS or GameRules:IsGamePaused() then return false end
	if not self:CanSendNextWave() then return false end
	-- Transition immediately: repeated clicks cannot enqueue another wave.
	if WaveDefinitions:IsBossWave(self.currentWave + 1) then self:StartBossIncoming()
	else self:StartWave(self.currentWave + 1) end
	return true
end

return WaveManager
