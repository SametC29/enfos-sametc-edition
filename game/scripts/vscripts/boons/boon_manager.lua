--------------------------------------------------------------------------------
-- boon_manager.lua
-- Server-authoritative Boons & Pacts system for Enfos Team Survival — SametC Edition
-- Handles 2-card team votes after Boss kills, candidate generation, recent weighting,
-- stack caps (3 max / 1 Unique), Pacts (wave 20+), and opponent-visible NetTable history.
-- Reference: docs/GAME_DESIGN_MASTER.md §§ 24, 25
-- Reference: docs/IMPLEMENTATION_ROADMAP.md § Phase 9
--------------------------------------------------------------------------------

require("lib/log")

local BoonManager = {}
BoonManager.__index = BoonManager

BoonManager.VOTE_DURATION = 10.0 -- 10 seconds voting window
BoonManager.DEFAULT_MAX_STACKS = 3

-- Registry of 25 Authored Boons + 3 Pacts (docs/GAME_DESIGN_MASTER.md § 24)
BoonManager.DEFINITIONS = {
	-- Offensive Boons
	{ id = "war_training", category = "offensive", isUnique = false, maxStacks = 3, minWave = 1, bonus = 10 },
	{ id = "quickening", category = "offensive", isUnique = false, maxStacks = 3, minWave = 1, bonus = 25 },
	{ id = "arcane_knowledge", category = "offensive", isUnique = false, maxStacks = 3, minWave = 1, bonus = 12 },
	{ id = "execution_training", category = "offensive", isUnique = false, maxStacks = 3, minWave = 1, bonus = 30 },
	{ id = "elite_hunters", category = "offensive", isUnique = false, maxStacks = 3, minWave = 1, bonus = 25 },
	{ id = "boss_slayers", category = "offensive", isUnique = false, maxStacks = 3, minWave = 1, bonus = 25 },
	{ id = "battle_rhythm", category = "offensive", isUnique = true, maxStacks = 1, minWave = 1, bonus = 35 },

	-- Defensive Boons
	{ id = "vitality", category = "defensive", isUnique = false, maxStacks = 3, minWave = 1, bonus = 250 },
	{ id = "reinforced_armor", category = "defensive", isUnique = false, maxStacks = 3, minWave = 1, bonus = 5 },
	{ id = "arcane_protection", category = "defensive", isUnique = false, maxStacks = 3, minWave = 1, bonus = 15 },
	{ id = "recovery", category = "defensive", isUnique = false, maxStacks = 3, minWave = 1, bonus = 15 },
	{ id = "second_wind", category = "defensive", isUnique = false, maxStacks = 3, minWave = 1, bonus = 4 },
	{ id = "emergency_seal", category = "defensive", isUnique = true, maxStacks = 1, minWave = 1, bonus = 15 },
	{ id = "resilience", category = "defensive", isUnique = false, maxStacks = 3, minWave = 1, bonus = 25 },

	-- Economy / Utility Boons
	{ id = "prosperity", category = "economy", isUnique = false, maxStacks = 3, minWave = 1, bonus = 15 },
	{ id = "boss_dividend", category = "economy", isUnique = false, maxStacks = 3, minWave = 1, bonus = 3 },
	{ id = "efficient_exchange", category = "economy", isUnique = false, maxStacks = 3, minWave = 1, bonus = 10 },
	{ id = "tome_knowledge", category = "economy", isUnique = true, maxStacks = 1, minWave = 1, bonus = 5 },
	{ id = "merchants_favor", category = "economy", isUnique = true, maxStacks = 1, minWave = 1, bonus = 5 },
	{ id = "swift_response", category = "utility", isUnique = false, maxStacks = 3, minWave = 1, bonus = 30 },
	{ id = "field_medicine", category = "utility", isUnique = false, maxStacks = 3, minWave = 1, bonus = 20 },

	-- Spellbringer Boons
	{ id = "mana_spring", category = "spellbringer", isUnique = false, maxStacks = 3, minWave = 1, bonus = 1.0 },
	{ id = "deep_reservoir", category = "spellbringer", isUnique = false, maxStacks = 3, minWave = 1, bonus = 40 },
	{ id = "efficient_invocation", category = "spellbringer", isUnique = false, maxStacks = 3, minWave = 1, bonus = 10 },
	{ id = "reinforcement_mastery", category = "spellbringer", isUnique = true, maxStacks = 1, minWave = 1, bonus = 2 },

	-- Pacts (Risk / Reward - starting after wave 20)
	{ id = "blood_pact", category = "pact", isUnique = true, maxStacks = 1, minWave = 20, damageBonus = 30, hpPenalty = 20 },
	{ id = "greed_pact", category = "pact", isUnique = true, maxStacks = 1, minWave = 20, goldBonus = 35, enemyHpBuff = 25 },
	{ id = "arcane_pact", category = "pact", isUnique = true, maxStacks = 1, minWave = 20, manaRegenBonus = 4.0, maxManaPenalty = 50 },
}

-- Fast lookup
BoonManager.LOOKUP = {}
for _, b in ipairs(BoonManager.DEFINITIONS) do
	BoonManager.LOOKUP[b.id] = b
end

--------------------------------------------------------------------------------
-- Initialize Boon Manager
--------------------------------------------------------------------------------
function BoonManager:Init(waveManager, economyManager, spellbringerService)
	self.waveManager = waveManager
	self.economyManager = economyManager
	self.spellbringerService = spellbringerService

	self.teamStacks = { [2] = {}, [3] = {} }
	self.teamHistory = { [2] = {}, [3] = {} }
	self.recentCandidates = { [2] = {}, [3] = {} }
	self.activeVotes = { [2] = nil, [3] = nil }

	for _, team in ipairs({ 2, 3 }) do
		for _, b in ipairs(self.DEFINITIONS) do
			self.teamStacks[team][b.id] = 0
		end
	end

	self:RegisterEventHandlers()
	self:SyncNetTable(2)
	self:SyncNetTable(3)

	Log:Info("boon_manager", "BoonManager initialized with %d Boons and Pacts.", #self.DEFINITIONS)
end

--------------------------------------------------------------------------------
-- Query Stacks and Active Buffs
--------------------------------------------------------------------------------
function BoonManager:GetStackCount(team, boonId)
	if not self.teamStacks[team] then return 0 end
	return self.teamStacks[team][boonId] or 0
end

function BoonManager:HasBoon(team, boonId)
	return self:GetStackCount(team, boonId) > 0
end

--------------------------------------------------------------------------------
-- Candidate Generation (Category Diversity + Recent Weighting + Stack Cap Check)
--------------------------------------------------------------------------------
function BoonManager:GetAvailableCandidates(team, waveNumber)
	local pool = {}
	local recent = self.recentCandidates[team] or {}

	for _, def in ipairs(self.DEFINITIONS) do
		local currentStacks = self:GetStackCount(team, def.id)
		local maxStacks = def.maxStacks or (def.isUnique and 1 or self.DEFAULT_MAX_STACKS)

		-- Must not exceed stack cap and must meet minimum wave requirement
		if currentStacks < maxStacks and waveNumber >= (def.minWave or 1) then
			-- Weight: recent cards offered have lower priority
			local weight = 1.0
			if recent[def.id] then
				weight = 0.25
			end
			table.insert(pool, { def = def, weight = weight })
		end
	end

	return pool
end

function BoonManager:GenerateTwoCandidates(team, waveNumber)
	local pool = self:GetAvailableCandidates(team, waveNumber)
	if #pool < 2 then
		-- Fallback if pool is exhausted: reset recent and take available
		self.recentCandidates[team] = {}
		pool = self:GetAvailableCandidates(team, waveNumber)
	end

	if #pool == 0 then return nil, nil end
	if #pool == 1 then return pool[1].def, pool[1].def end

	-- Weighted selection of Card 1
	local totalWeight = 0
	for _, entry in ipairs(pool) do totalWeight = totalWeight + entry.weight end
	local roll1 = (RandomFloat and RandomFloat(0, totalWeight) or (math.random() * totalWeight))
	local cumulative = 0
	local card1Idx = 1

	for idx, entry in ipairs(pool) do
		cumulative = cumulative + entry.weight
		if roll1 <= cumulative then
			card1Idx = idx
			break
		end
	end

	local card1 = pool[card1Idx].def

	-- Select Card 2: Prefer a different category for meaningful player choice
	local card2 = nil
	local diffCatCandidates = {}
	for idx, entry in ipairs(pool) do
		if idx ~= card1Idx and entry.def.category ~= card1.category then
			table.insert(diffCatCandidates, entry)
		end
	end

	if #diffCatCandidates > 0 then
		local roll2 = (RandomInt and RandomInt(1, #diffCatCandidates)) or math.random(1, #diffCatCandidates)
		card2 = diffCatCandidates[roll2].def
	else
		-- Fallback to any other card
		for idx, entry in ipairs(pool) do
			if idx ~= card1Idx then
				card2 = entry.def
				break
			end
		end
	end

	-- Update recent candidate memory
	self.recentCandidates[team] = {
		[card1.id] = true,
		[card2.id] = true,
	}

	return card1, card2
end

--------------------------------------------------------------------------------
-- Start 2-Card Vote Session
--------------------------------------------------------------------------------
function BoonManager:StartVote(team, waveNumber)
	local card1, card2 = self:GenerateTwoCandidates(team, waveNumber)
	if not card1 or not card2 then
		Log:Warn("boon_manager", "Team %d has no available boon candidates for Wave %d", team, waveNumber)
		return false
	end

	local now = (GameRules and GameRules.GetGameTime and GameRules:GetGameTime()) or 0
	local expiresAt = now + self.VOTE_DURATION

	self.activeVotes[team] = {
		wave = waveNumber,
		card1 = card1,
		card2 = card2,
		votes = {}, -- [playerId] = 1 or 2
		expiresAt = expiresAt,
		timerName = "BoonVote_" .. tostring(team) .. "_" .. tostring(waveNumber),
	}

	Log:Info("boon_manager", "VOTE STARTED: Team %d voting between [%s] and [%s] for Wave %d (Duration: %.1fs)",
		team, card1.id, card2.id, waveNumber, self.VOTE_DURATION)

	self:SyncNetTable(team)

	-- Schedule automatic resolution when vote expires
	if GameRules and GameRules.GetGameModeEntity and GameRules:GetGameModeEntity() then
		GameRules:GetGameModeEntity():SetContextThink(self.activeVotes[team].timerName, function()
			BoonManager:ResolveVote(team)
			return nil
		end, self.VOTE_DURATION)
	end

	return true, card1, card2
end

--------------------------------------------------------------------------------
-- Cast Player Vote
--------------------------------------------------------------------------------
function BoonManager:CastVote(playerId, cardIndex)
	if not playerId or not cardIndex then return false end
	if cardIndex ~= 1 and cardIndex ~= 2 then return false end

	local team = PlayerResource:GetTeam(playerId)
	local activeVote = self.activeVotes[team]
	if not activeVote then
		Log:Warn("boon_manager", "Player %d attempted vote but no active vote for team %d", playerId, team)
		return false
	end

	-- Record or update player vote
	activeVote.votes[playerId] = cardIndex
	Log:Info("boon_manager", "Player %d (Team %d) voted for Card %d", playerId, team, cardIndex)

	self:SyncNetTable(team)
	return true
end

--------------------------------------------------------------------------------
-- Resolve Vote & Apply Winner
--------------------------------------------------------------------------------
function BoonManager:ResolveVote(team)
	local activeVote = self.activeVotes[team]
	if not activeVote then return nil end

	-- Tally votes
	local votesCard1 = 0
	local votesCard2 = 0

	for playerId, choice in pairs(activeVote.votes) do
		-- Only tally active connected teammates
		if PlayerResource:IsValidPlayerID(playerId) and PlayerResource:GetTeam(playerId) == team
			and PlayerResource:GetConnectionState(playerId) == DOTA_CONNECTION_STATE_CONNECTED then
			if choice == 1 then
				votesCard1 = votesCard1 + 1
			elseif choice == 2 then
				votesCard2 = votesCard2 + 1
			end
		end
	end

	local winningCard = nil
	if votesCard1 > votesCard2 then
		winningCard = activeVote.card1
	elseif votesCard2 > votesCard1 then
		winningCard = activeVote.card2
	else
		-- Tie or no votes cast: random choice
		local tieBreak = (RandomInt and RandomInt(1, 2)) or math.random(1, 2)
		winningCard = (tieBreak == 1) and activeVote.card1 or activeVote.card2
		Log:Info("boon_manager", "Team %d vote tied or empty (%d - %d). Random resolution: Card %d (%s)",
			team, votesCard1, votesCard2, tieBreak, winningCard.id)
	end

	-- Apply winning Boon to team
	self:ApplyBoon(team, winningCard.id, activeVote.wave)

	-- Clear active vote
	self.activeVotes[team] = nil
	self:SyncNetTable(team)

	Log:Info("boon_manager", "VOTE RESOLVED: Team %d selected [%s] on Wave %d (Votes: %d vs %d)",
		team, winningCard.id, activeVote.wave, votesCard1, votesCard2)

	return winningCard
end

--------------------------------------------------------------------------------
-- Apply Boon to Team
--------------------------------------------------------------------------------
function BoonManager:ApplyBoon(team, boonId, waveNumber)
	local def = self.LOOKUP[boonId]
	if not def then return false end

	local currentStacks = self:GetStackCount(team, boonId)
	local maxStacks = def.maxStacks or (def.isUnique and 1 or self.DEFAULT_MAX_STACKS)

	if currentStacks >= maxStacks then
		Log:Warn("boon_manager", "Team %d cannot exceed stack cap (%d/%d) for boon %s",
			team, currentStacks, maxStacks, boonId)
		return false
	end

	self.teamStacks[team][boonId] = currentStacks + 1
	table.insert(self.teamHistory[team], {
		wave = waveNumber or 0,
		id = boonId,
		stacks = self.teamStacks[team][boonId],
	})

	-- Specific Boon Immediate Procs (e.g. Emergency Seal restores +15 Life)
	if boonId == "emergency_seal" then
		local LifeCore = require("waves/life_core")
		if LifeCore and LifeCore.RestoreLife then
			LifeCore:RestoreLife(team, 15, "emergency_seal")
		elseif LifeCore and LifeCore.SetLife then
			LifeCore:SetLife(team, math.min(100, (LifeCore:GetLife(team) or 0) + 15))
		end
	end

	Log:Info("boon_manager", "APPLIED: Team %d gained [%s] (Stacks: %d/%d)",
		team, boonId, self.teamStacks[team][boonId], maxStacks)

	return true
end

--------------------------------------------------------------------------------
-- NetTable Synchronization (Opponent-Visible History)
--------------------------------------------------------------------------------
function BoonManager:SyncNetTable(team)
	if not CustomNetTables then return end

	local activeVote = self.activeVotes[team]
	local activeVoteData = nil
	if activeVote then
		activeVoteData = {
			wave = activeVote.wave,
			card1_id = activeVote.card1.id,
			card2_id = activeVote.card2.id,
			expires_at = activeVote.expiresAt,
			votes = activeVote.votes,
		}
	end

	-- Send team state (stacks and history visible to all players / opponents)
	CustomNetTables:SetTableValue("boon_state", "team_" .. tostring(team), {
		stacks = self.teamStacks[team] or {},
		history = self.teamHistory[team] or {},
		active_vote = activeVoteData,
	})
end

--------------------------------------------------------------------------------
-- Panorama Event Handlers
--------------------------------------------------------------------------------
function BoonManager:RegisterEventHandlers()
	if not CustomGameEventManager then return end

	CustomGameEventManager:RegisterListener("enfos_cast_boon_vote", function(_, event)
		local playerId = event.PlayerID
		local cardIndex = event.card_index
		BoonManager:CastVote(playerId, cardIndex)
	end)
end

return BoonManager
