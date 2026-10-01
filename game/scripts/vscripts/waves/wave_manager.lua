--------------------------------------------------------------------------------
-- wave_manager.lua
-- Central server-authoritative wave manager
-- Orchestrates 60 authored waves, batch spawning without a population cap,
-- Boss-only transitions, and HUD NetTable synchronization.
-- Reference: docs/GAME_DESIGN_MASTER.md §§ 3, 5, 8, 9, 10
--------------------------------------------------------------------------------

require("lib/log")
local WaveDefinitions = require("waves/wave_definitions")
local CreepAI = require("waves/creep_ai")
local LifeCore = require("waves/life_core")
local Rewards = require("waves/rewards")
local BossFramework = require("bosses/boss_framework")
local EconomyManager = require("economy/economy_manager")
local BoonManager = require("boons/boon_manager")
local BalanceConfig = require("waves/balance_config")
local BossResources = require("bosses/resource_gate")

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
WaveManager.SPAWN_LOCATIONS = {}
for team,lanes in pairs(CreepAI.ROUTES) do
    WaveManager.SPAWN_LOCATIONS[team]={}
    for lane,route in pairs(lanes) do WaveManager.SPAWN_LOCATIONS[team][lane]=route[1] end
end

--------------------------------------------------------------------------------
-- Initialize Wave Manager
--------------------------------------------------------------------------------
function WaveManager:Init()
	self.currentWave = 0
	self.matchConfig = nil
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
	self.bossResources = BossResources.New()
	self.bossResourcePlan = nil
	self.bossResourceWait = 0

	-- Initialize Life Core, Rewards and Boss framework
	LifeCore:Init(self)
	Rewards:Init()
	BossFramework:Init()

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
	if self.matchConfig then return false end
	self.difficulty = (difficulty or "normal"):lower()
	Log:Info("wave_manager", "Game difficulty set to: %s", self.difficulty)
end

function WaveManager:GetDifficulty()
	return self.matchConfig and self.matchConfig.difficulty or self.difficulty or "normal"
end

function WaveManager:EnsureMatchConfig()
	if not self.matchConfig then
		self.matchConfig=BalanceConfig.Snapshot(self:GetDifficulty(),self:GetActivePlayerCount(2),self:GetActivePlayerCount(3))
		require("heroes/hero_power"):SetSnapshot(self.matchConfig)
		Log:Info("wave_manager","Balance snapshot: version=%s difficulty=%s solo=%s",self.matchConfig.version,self.matchConfig.difficulty,tostring(self.matchConfig.solo))
	end
	return self.matchConfig
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
				if connState ~= (DOTA_CONNECTION_STATE_ABANDONED or 4) and (connState == (DOTA_CONNECTION_STATE_CONNECTED or 2) or hasHero) then
					count = count + 1
				end
			end
		end
	end
	return count
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
		-- The opening wave is the onboarding: start it as soon as the match is live.
		-- Later waves retain their normal preparation and Boss warning transitions.
		self:EnsureMatchConfig()
		self:StartWave(1)
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

	-- The deadline runs while spawning and fighting, including uncleared enemies.
	-- Do not consume a Boss batch or its combat deadline before its actual
	-- native hero resources finish loading. Normal waves never enter this gate.
	if self.state == self.STATE_SPAWNING and self.bossResourcePlan
		and not self.bossResources:IsPlanReady(self.bossResourcePlan) then
		self.bossResourceWait = self.bossResourceWait + self.THINK_INTERVAL
		if self.bossResourceWait == 30 then
			Log:Error("boss_resources", "Wave %d blocked: Boss precache callback still pending after 30 seconds", self.currentWave)
		end
		return self.THINK_INTERVAL
	end
	if self.state == self.STATE_SPAWNING or self.state == self.STATE_ACTIVE then
		self.stateTimer = self.stateTimer - self.THINK_INTERVAL
		if self.stateTimer <= 0 then self:AdvanceScheduledWave(); return self.THINK_INTERVAL end
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
	local config=self:EnsureMatchConfig()
	self.state = WaveManager.STATE_PREPARATION
	local duration=config.normalPreparation
	if config.solo and self.currentWave<config.fullSupportThrough then duration=config.soloPreparation end
	self.stateTimer = customDuration or duration

	local nextWaveNum = self.currentWave + 1
	Log:Info("wave_manager", "Preparation phase started for Wave %d (Duration: %.1fs).", nextWaveNum, self.stateTimer)

	self:SyncNetTable()
end

--------------------------------------------------------------------------------
-- Boss Incoming Transition
-- Reference: docs/GAME_DESIGN_MASTER.md § 3
--------------------------------------------------------------------------------
function WaveManager:StartBossIncoming()
	self.state = WaveManager.STATE_BOSS_INCOMING
	self.stateTimer = WaveManager.BOSS_INCOMING_TIME

	local bossWaveNum = self.currentWave + 1
	local waveDef = WaveDefinitions:GetWave(bossWaveNum)
	self.bossResources:RequestPlan(WaveDefinitions:GetSpawnPlan(bossWaveNum, 1))

	Log:Warn("wave_manager", "========================================")
	Log:Warn("wave_manager", "BOSS INCOMING: Wave %d (%s)", bossWaveNum, waveDef and waveDef.boss_name or "Unknown")
	Log:Warn("wave_manager", "========================================")

	-- Announce to all players
	EmitGlobalSound("sounds/ui/stingers/boss_incoming.vsnd")
	CustomGameEventManager:Send_ServerToAllClients("enfos_boss_incoming", {
		wave = bossWaveNum,
		boss_name = waveDef and waveDef.boss_name or "",
	})

	-- Previous waves remain on the field. Scheduled hostiles only cost Life
	-- after they physically reach the Core leak trigger.
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
	self.stateTimer = WaveDefinitions:GetDuration(waveNumber)
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
	self.bossResourcePlan = isBoss and WaveDefinitions:GetSpawnPlan(waveNumber, 1) or nil
	self.bossResourceWait = 0
	if self.bossResourcePlan then self.bossResources:RequestPlan(self.bossResourcePlan) end
	Log:Info("wave_manager", "Starting Wave %d [Type: %s, Batches: %d]",
		waveNumber, waveDef.wave_type, waveDef.batches)

	-- Prepare batches
	local totalBatches = isBoss and 1 or math.ceil(WaveDefinitions:GetScheduledCount(waveNumber,1)/6)
	self.waveBatchInterval = isBoss and 0 or (self.stateTimer * 0.60 / math.max(1,totalBatches-1))
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
-- Spawn Batch (all scheduled units spawn regardless of active population)
-- Reference: docs/GAME_DESIGN_MASTER.md § 5
--------------------------------------------------------------------------------
function WaveManager:SpawnNextBatch()
	if self.bossResourcePlan and not self.bossResources:IsPlanReady(self.bossResourcePlan) then return end
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

		if activePlayers > 0 then
			for _, creepEntry in ipairs(self.spawnPlans[team] or {}) do
				local unitName = creepEntry.unit_name
				local bossRewardName = creepEntry.boss_reward_name
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
					self:SpawnCreepEntity(unitName, team, lane, isBoss, activePlayers, bossRewardName)
				end
			end
		end
	end

	-- Set timer for next batch
	self.batchSpawnTimer = self.waveBatchInterval or 1

	if #self.pendingBatches == 0 then
		self.state = WaveManager.STATE_ACTIVE
	end

	self:SyncNetTable()
end

--------------------------------------------------------------------------------
-- Spawn Creep Entity & Attach AI
--------------------------------------------------------------------------------
function WaveManager:SpawnCreepEntity(unitName, defendingTeam, lane, isBoss, activePlayers, bossRewardName)
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
	creep.bossRewardName = isBoss and bossRewardName or nil
	if isBoss and not BossFramework:PrepareBoss(creep, unitName, self.currentWave, defendingTeam) then
		Log:Error("wave_manager", "Boss setup failed; refusing to spawn an incorrectly configured Boss %s", unitName)
		creep:ForceKill(false)
		UTIL_Remove(creep)
		return nil
	end
	Rewards:Configure(creep, unitName, creep.bossRewardName)
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

	BalanceConfig.Apply(creep,self:EnsureMatchConfig(),self.currentWave)
	-- A Boss without its native roster kit must not enter the live wave as an
	-- unarmed legacy unit. Register before indexing it as active.
	if isBoss and not BossFramework:RegisterBoss(creep, creep.bossRewardName or unitName, self.currentWave, activePlayers, defendingTeam) then
		Log:Error("wave_manager", "Boss registration failed; removing unconfigured Boss %s", unitName)
		creep:ForceKill(false)
		UTIL_Remove(creep)
		return nil
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
		if self.activeCreeps[defendingTeam][killedUnit:entindex()] then
			Rewards:OnKill(killedUnit, killerUnit)
			if killedUnit.isBoss and not killedUnit.enfosLeaked then
				if EconomyManager then
					EconomyManager:AwardBossLumber(defendingTeam, killedUnit.waveNumber)
				end
				if BoonManager and killedUnit.waveNumber % self:EnsureMatchConfig().boonEvery == 0 then
					BoonManager:StartVote(defendingTeam, killedUnit.waveNumber)
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
    -- Keep the existing deadline when cleared early; the button can skip it.
    if self.currentWave == WaveDefinitions:GetTotalWaves() then
        self.state = self.STATE_VICTORY
        return
    end
    self:StartPreparation(math.max(0,self.stateTimer))
end

function WaveManager:AdvanceScheduledWave()
    self.pendingBatches = {}
    -- A wave deadline advances scheduling only; living units stay active and
    -- are charged Life only by the physical Core leak callback.
    if WaveDefinitions:IsBossWave(self.currentWave+1) then self:StartBossIncoming()
    else self:StartWave(self.currentWave+1) end
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
		solo_support = self.matchConfig and self.matchConfig.solo and 1 or 0,
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
		clear_gold = 0,
		state_timer = math.max(0, math.floor(self.stateTimer + 0.5)),
		is_boss = displayDef and WaveDefinitions:IsBossWave(displayDef.wave_number) or false,
		title = displayDef and displayDef.title or "",
		active_goodguys = self:GetActiveCreepCount(DOTA_TEAM_GOODGUYS or 2),
		active_badguys = self:GetActiveCreepCount(DOTA_TEAM_BADGUYS or 3),
		hostile_cap_enabled = 0,
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
