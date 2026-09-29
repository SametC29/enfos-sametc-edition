-- Match-only hero level and starting skill-point budget.
-- Account level and Hero Mastery remain in progression/progression_curves.lua.
local MatchLevels = {}

MatchLevels.MAX_LEVEL = 50
MatchLevels.XP_FIRST_LEVEL_COST = 900
MatchLevels.XP_COST_STEP = 45

-- Dota's custom XP API consumes cumulative thresholds (level 1 starts at 0).
function MatchLevels:BuildXPThresholds()
	local thresholds = { 0 }
	local cumulativeXP = 0
	for currentLevel = 1, self.MAX_LEVEL - 1 do
		cumulativeXP = cumulativeXP + self.XP_FIRST_LEVEL_COST
			+ self.XP_COST_STEP * (currentLevel - 1)
		thresholds[currentLevel + 1] = cumulativeXP
	end
	return thresholds
end

function MatchLevels:Configure(gameMode)
	if not gameMode or not gameMode.SetCustomXPRequiredToReachNextLevel
		or not gameMode.SetUseCustomHeroLevels then
		error("Match hero progression requires custom hero-level VScript APIs")
	end

	-- Set the cumulative table before enabling custom hero levels.
	gameMode:SetCustomXPRequiredToReachNextLevel(self:BuildXPThresholds())
	if gameMode.SetCustomHeroMaxLevel then
		gameMode:SetCustomHeroMaxLevel(self.MAX_LEVEL)
	end
	gameMode:SetUseCustomHeroLevels(true)
end

-- Clear Dota's initial level-1 point once per player. The project grants the
-- fifth Enfos passive separately; levels 2..50 then supply the 49 paid ranks.
-- The caller owns this state so respawns and reconnects cannot clear points again.
function MatchLevels:InitializeStartingAbilityPoints(hero, initializedPlayers)
	if not hero or hero:IsNull() or not hero:IsRealHero() or hero:IsIllusion()
		or (hero.IsClone and hero:IsClone())
		or (hero.IsTempestDouble and hero:IsTempestDouble()) then return false end
	local playerID = hero:GetPlayerID()
	if playerID == nil or playerID < 0 then return false end
	if initializedPlayers[playerID] then return false end

	hero:SetAbilityPoints(0)
	initializedPlayers[playerID] = true
	return true
end

return MatchLevels
