-- Match-only hero level and starting skill-point budget.
-- All progression in this game is match-local; no account or hero profile is loaded.
local MatchLevels = {}

MatchLevels.MAX_LEVEL = 50
MatchLevels.START_LEVEL = 1
MatchLevels.TEST_START_LEVEL = 6
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

function MatchLevels:StartingLevel()
	if GetMapName and GetMapName() == "enfos_test" then return self.TEST_START_LEVEL end
	return self.START_LEVEL
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

-- Ordinary matches start at level 1 with no paid points. The test arena starts
-- at level 6, then its own preparation raises the hero to level 10. The fifth
-- Enfos passive is separately granted at rank 1 in either map.
-- The caller owns this state so respawns/reconnects never grant levels twice.
function MatchLevels:InitializeStartingAbilityPoints(hero, initializedPlayers)
	if not hero or hero:IsNull() or not hero:IsRealHero() or hero:IsIllusion()
		or (hero.IsClone and hero:IsClone())
		or (hero.IsTempestDouble and hero:IsTempestDouble()) then return false end
	local playerID = hero:GetPlayerID()
	if playerID == nil or playerID < 0 then return false end
	if initializedPlayers[playerID] then return false end

	local startingLevel = math.min(self:StartingLevel(), self.MAX_LEVEL)
	local thresholds = self:BuildXPThresholds()
	local targetXP = thresholds[startingLevel]
	local currentLevel = hero:GetLevel()
	if currentLevel < startingLevel then
		local currentXP = hero:GetCurrentXP()
		if currentXP < targetXP then
			hero:AddExperience(targetXP - currentXP, DOTA_ModifyXP_Unspecified, false, true)
		end
		-- On a newly spawned hero, these are the only points earned before
		-- gameplay begins; leave the separately granted Enfos passive untouched.
		hero:SetAbilityPoints(math.max(0, hero:GetLevel() - 1))
	elseif startingLevel == 1 and currentLevel == 1 then
		-- Dota normally grants a level-one point. This roster budgets exactly
		-- 49 paid ranks from levels 2..50; the Enfos passive has a free rank.
		hero:SetAbilityPoints(0)
	end
	initializedPlayers[playerID] = true
	return true
end

return MatchLevels
