--------------------------------------------------------------------------------
-- progression_curves.lua
-- Authoritative curves and algorithms for Account Level, Legacy, Hero Mastery,
-- Match Rewards, and Difficulty Progression for Enfos Team Survival — SametC Edition
-- Reference: docs/GAME_DESIGN_MASTER.md §§ 27, 28, 29
-- Reference: docs/IMPLEMENTATION_ROADMAP.md § Phase 10
--------------------------------------------------------------------------------

require("lib/log")

local ProgressionCurves = {}

ProgressionCurves.MAX_ACCOUNT_LEVEL = 100
ProgressionCurves.MAX_LEGACY_POINTS = 24
ProgressionCurves.MAX_LEGACY_BRANCH_RANK = 12
ProgressionCurves.MAX_HERO_MASTERY_RANK = 20

ProgressionCurves.DIFFICULTY_XP_MULTIPLIERS = {
	casual = 0.85,
	normal = 1.00,
	hard = 1.15,
	nightmare = 1.35,
	hell = 1.60,
}

ProgressionCurves.DIFFICULTY_TIERS = { "casual", "normal", "hard", "nightmare", "hell" }

--------------------------------------------------------------------------------
-- Account XP & Level
--------------------------------------------------------------------------------
-- XP required to advance from (level) to (level + 1): 500 + 35 * (level - 1)
function ProgressionCurves.GetAccountLevelXPRequired(level)
	if level >= ProgressionCurves.MAX_ACCOUNT_LEVEL then
		return nil
	end
	return 500 + 35 * (level - 1)
end

function ProgressionCurves.AddAccountXP(profile, xpAmount)
	if not profile or xpAmount <= 0 then return false, 0 end

	local oldLevel = profile.accountLevel or 1
	profile.accountXp = (profile.accountXp or 0) + xpAmount
	local levelsGained = 0

	while profile.accountLevel < ProgressionCurves.MAX_ACCOUNT_LEVEL do
		local req = ProgressionCurves.GetAccountLevelXPRequired(profile.accountLevel)
		if req and profile.accountXp >= req then
			profile.accountXp = profile.accountXp - req
			profile.accountLevel = profile.accountLevel + 1
			levelsGained = levelsGained + 1

			-- Legacy points: 1 point every 2 levels up to Level 48 (max 24 points)
			if profile.accountLevel <= 48 and (profile.accountLevel % 2 == 0) then
				profile.unspentLegacyPoints = (profile.unspentLegacyPoints or 0) + 1
				Log:Info("progression_curves", "Account level %d awarded +1 Legacy point (Unspent: %d)",
					profile.accountLevel, profile.unspentLegacyPoints)
			end
		else
			break
		end
	end

	if levelsGained > 0 then
		Log:Info("progression_curves", "Account leveled up: %d -> %d (+%d levels)",
			oldLevel, profile.accountLevel, levelsGained)
	end

	return true, levelsGained
end

--------------------------------------------------------------------------------
-- Legacy Tree Allocation & PvEvP Normalization
--------------------------------------------------------------------------------
-- Legacy branches: offense, defense, economy, spellbringer
function ProgressionCurves.AllocateLegacyRank(profile, branch)
	if not profile or not branch then return false, "invalid_arguments" end
	if not profile.legacy or profile.legacy[branch] == nil then return false, "unknown_branch" end

	if (profile.unspentLegacyPoints or 0) <= 0 then
		return false, "insufficient_points"
	end

	local currentRank = profile.legacy[branch] or 0
	if currentRank >= ProgressionCurves.MAX_LEGACY_BRANCH_RANK then
		return false, "branch_capped"
	end

	profile.legacy[branch] = currentRank + 1
	profile.unspentLegacyPoints = profile.unspentLegacyPoints - 1

	Log:Info("progression_curves", "Allocated Legacy rank to [%s]: %d -> %d (Unspent remaining: %d)",
		branch, currentRank, profile.legacy[branch], profile.unspentLegacyPoints)

	return true, profile.legacy[branch]
end

function ProgressionCurves.RespecLegacy(profile)
	if not profile or not profile.legacy then return false end

	local totalSpent = (profile.legacy.offense or 0) + (profile.legacy.defense or 0) +
		(profile.legacy.economy or 0) + (profile.legacy.spellbringer or 0)

	profile.legacy.offense = 0
	profile.legacy.defense = 0
	profile.legacy.economy = 0
	profile.legacy.spellbringer = 0
	profile.unspentLegacyPoints = (profile.unspentLegacyPoints or 0) + totalSpent

	Log:Info("progression_curves", "Legacy tree respecced. Refunded %d points. Total unspent: %d",
		totalSpent, profile.unspentLegacyPoints)

	return true, totalSpent
end

-- PvEvP Normalization: Co-op/Endless at 100% (1.0), Standard PvEvP at 50% (0.5)
function ProgressionCurves.GetLegacyBonuses(profile, isPvEvP)
	if not profile or not profile.legacy then
		return { offense = 0, defense = 0, economy = 0, spellbringer = 0 }
	end

	local effectiveness = isPvEvP and 0.5 or 1.0

	return {
		-- Offense: ~0.5% PvE damage per rank
		offenseDamageMultiplier = (profile.legacy.offense or 0) * 0.005 * effectiveness,
		-- Defense: ~0.5% Max HP per rank
		defenseMaxHpMultiplier = (profile.legacy.defense or 0) * 0.005 * effectiveness,
		-- Economy: ~0.5% Gold multiplier per rank
		economyGoldMultiplier = (profile.legacy.economy or 0) * 0.005 * effectiveness,
		-- Spellbringer: ~0.5% mana / cost efficiency per rank
		spellbringerEfficiency = (profile.legacy.spellbringer or 0) * 0.005 * effectiveness,
		effectiveness = effectiveness,
	}
end

--------------------------------------------------------------------------------
-- Hero Mastery XP & Rank
--------------------------------------------------------------------------------
-- XP required to advance from (rank) to (rank + 1): 100 + 35 * (rank - 1)
function ProgressionCurves.GetHeroMasteryXPRequired(rank)
	if rank >= ProgressionCurves.MAX_HERO_MASTERY_RANK then
		return nil
	end
	return 100 + 35 * (rank - 1)
end

function ProgressionCurves.AddHeroMasteryXP(heroData, xpAmount)
	if not heroData or xpAmount <= 0 then return false, 0 end

	heroData.rank = heroData.rank or 1
	heroData.xp = (heroData.xp or 0) + xpAmount
	heroData.passivePoints = heroData.passivePoints or 0
	heroData.buildUnlocks = heroData.buildUnlocks or {}

	local oldRank = heroData.rank
	local ranksGained = 0

	while heroData.rank < ProgressionCurves.MAX_HERO_MASTERY_RANK do
		local req = ProgressionCurves.GetHeroMasteryXPRequired(heroData.rank)
		if req and heroData.xp >= req then
			heroData.xp = heroData.xp - req
			heroData.rank = heroData.rank + 1
			ranksGained = ranksGained + 1

			-- Every even rank awards +1 Hero Passive point (up to 10 points by rank 20)
			if heroData.rank % 2 == 0 then
				heroData.passivePoints = heroData.passivePoints + 1
			end

			-- Mastery 5, 10, 15, 20 unlock extra in-match build choices
			if heroData.rank == 5 or heroData.rank == 10 or heroData.rank == 15 or heroData.rank == 20 then
				heroData.buildUnlocks[tostring(heroData.rank)] = true
				Log:Info("progression_curves", "Hero Mastery %d unlocked in-match build choice milestone!", heroData.rank)
			end
		else
			break
		end
	end

	if ranksGained > 0 then
		Log:Info("progression_curves", "Hero Mastery ranked up: %d -> %d (+%d ranks, Passive Points: %d)",
			oldRank, heroData.rank, ranksGained, heroData.passivePoints)
	end

	return true, ranksGained
end

--------------------------------------------------------------------------------
-- Match Reward Calculation
--------------------------------------------------------------------------------
function ProgressionCurves.CalculateMatchRewards(params)
	local completedWaves = math.max(0, math.min(60, params.completedWaves or 0))
	local isFullClear = (completedWaves >= 60) and (params.isFullClear == true)
	local diffKey = (params.difficulty or "normal"):lower()
	local diffMult = ProgressionCurves.DIFFICULTY_XP_MULTIPLIERS[diffKey] or 1.00
	local outcome = (params.outcome or "loss"):lower() -- "win", "loss", "surrender", "abandon"
	local endlessCheckpoints = math.max(0, params.endlessCheckpoints or 0)

	-- Base formulas:
	-- Account XP: 1200 * (completedWaves / 60)^1.30 + (clearBonus 300)
	-- Hero XP: 400 * (completedWaves / 60)^1.20 + (clearBonus 100)
	local waveRatio = completedWaves / 60.0
	local baseAccountXp = 1200.0 * (waveRatio ^ 1.30)
	local baseHeroXp = 400.0 * (waveRatio ^ 1.20)

	if isFullClear then
		baseAccountXp = baseAccountXp + 300.0
		baseHeroXp = baseHeroXp + 100.0
	end

	-- Apply difficulty multiplier
	local accountXp = baseAccountXp * diffMult
	local heroXp = baseHeroXp * diffMult

	-- Outcome modifier
	if outcome == "win" then
		-- PvEvP winner: +15% Account and Hero Mastery XP
		accountXp = accountXp * 1.15
		heroXp = heroXp * 1.15
	elseif outcome == "abandon" then
		-- Abandon receives reduced legitimate progress only (50%)
		accountXp = accountXp * 0.50
		heroXp = heroXp * 0.50
	elseif outcome == "surrender" then
		-- Surrender keeps legitimate progress earned up to that wave
		-- (already reflected by completedWaves ratio)
	end

	-- Endless Checkpoint Rewards (+80 Account XP, +30 Hero XP * diffMult per 5 waves)
	if endlessCheckpoints > 0 then
		accountXp = accountXp + (endlessCheckpoints * 80.0 * diffMult)
		heroXp = heroXp + (endlessCheckpoints * 30.0 * diffMult)
	end

	return {
		accountXp = math.floor(accountXp + 0.5),
		heroXp = math.floor(heroXp + 0.5),
		isFullClear = isFullClear,
		difficulty = diffKey,
		difficultyMultiplier = diffMult,
		outcome = outcome,
		endlessCheckpoints = endlessCheckpoints,
	}
end

--------------------------------------------------------------------------------
-- Difficulty Unlocks
--------------------------------------------------------------------------------
function ProgressionCurves.CheckDifficultyUnlock(profile, completedDifficulty, isFullClear)
	if not profile or not isFullClear then return false end

	local currentUnlocked = profile.highestDifficultyUnlocked or "normal"
	local currentIdx = 1
	local targetIdx = 1

	for idx, name in ipairs(ProgressionCurves.DIFFICULTY_TIERS) do
		if name == currentUnlocked then currentIdx = idx end
		if name == completedDifficulty then targetIdx = idx end
	end

	-- If player completed their highest unlocked difficulty (or equal), unlock next tier
	if targetIdx >= currentIdx and currentIdx < #ProgressionCurves.DIFFICULTY_TIERS then
		local newDifficulty = ProgressionCurves.DIFFICULTY_TIERS[currentIdx + 1]
		profile.highestDifficultyUnlocked = newDifficulty
		Log:Info("progression_curves", "UNLOCKED new difficulty tier: %s for player %s",
			newDifficulty, tostring(profile.steamId))
		return true, newDifficulty
	end

	return false, currentUnlocked
end

return ProgressionCurves
