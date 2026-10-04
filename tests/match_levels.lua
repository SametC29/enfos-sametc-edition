package.path = "game/scripts/vscripts/?.lua;" .. package.path
local MatchLevels = require("heroes/match_levels")

local xp = MatchLevels:BuildXPThresholds()
assert(#xp == 50, "custom XP table must contain one cumulative threshold per hero level")
assert(xp[1] == 0, "level 1 threshold starts at zero")
assert(xp[2]==150 and xp[3]==450 and xp[4]==900 and xp[5]==1550, "opening skills unlock progressively")
assert(xp[7]-xp[6]==1125, "later per-level cost resumes the existing curve")
assert(MatchLevels.START_LEVEL == 1 and MatchLevels.TEST_START_LEVEL == 6, "normal and test starts stay separate")
local mapName="enfos"
function GetMapName() return mapName end
assert(xp[6] == 2400, "level 6 start requires the first five level thresholds")
assert(xp[50] == 94470, "level 50 threshold matches the 49 transition costs")
for level = 2, #xp do
	assert(xp[level] > xp[level - 1], "XP thresholds must strictly increase")
end

local callOrder = {}
local gameMode = {
	SetCustomXPRequiredToReachNextLevel = function(_, thresholds)
		assert(thresholds[50] == 94470)
		callOrder[#callOrder + 1] = "xp"
	end,
	SetCustomHeroMaxLevel = function(_, level)
		assert(level == 50)
		callOrder[#callOrder + 1] = "max"
	end,
	SetUseCustomHeroLevels = function(_, enabled)
		assert(enabled == true)
		callOrder[#callOrder + 1] = "enable"
	end,
}
MatchLevels:Configure(gameMode)
assert(table.concat(callOrder, ",") == "xp,max,enable", "configure XP before enabling custom levels")

local initialized = {}
local function hero(playerID, points, real, illusion, level, currentXP)
	return {
		abilityPoints = points,
		level = level or 1,
		currentXP = currentXP or 0,
		IsNull = function() return false end,
		IsRealHero = function() return real ~= false end,
		IsIllusion = function() return illusion == true end,
		GetPlayerID = function() return playerID end,
		GetLevel = function(self) return self.level end,
		GetCurrentXP = function(self) return self.currentXP end,
		AddExperience = function(self, amount)
			self.currentXP = self.currentXP + amount
			self.level = 6
		end,
		SetAbilityPoints = function(self, value) self.abilityPoints = value end,
	}
end

local first = hero(2, 1)
assert(MatchLevels:InitializeStartingAbilityPoints(first, initialized) == true)
assert(first.level == 1 and first.currentXP == 0, "normal Enfos starts at level 1 with no granted XP")
assert(first.abilityPoints == 0, "first paid rank arrives at level 2; the fifth passive is free")
local respawn = hero(2, 3)
assert(MatchLevels:InitializeStartingAbilityPoints(respawn, initialized) == false)
assert(respawn.abilityPoints == 3 and respawn.level == 1, "do not grant levels or change points on respawn/reconnect")
local otherPlayer = hero(3, 1)
assert(MatchLevels:InitializeStartingAbilityPoints(otherPlayer, initialized) == true)
assert(otherPlayer.abilityPoints == 0, "normal players have the same level-one budget")
mapName="enfos_test"
local testPlayer=hero(7, 1)
assert(MatchLevels:InitializeStartingAbilityPoints(testPlayer, initialized) == true)
assert(testPlayer.level == 6 and testPlayer.currentXP == xp[6] and testPlayer.abilityPoints == 5,
    "test arena keeps the six-level preload before its level-ten preparation")
local higherLevel = hero(5, 2, true, false, 9, xp[9])
assert(MatchLevels:InitializeStartingAbilityPoints(higherLevel, initialized) == true)
assert(higherLevel.level == 9 and higherLevel.abilityPoints == 2, "preserve spent-point state for an engine-initialized level above the start floor")
local illusion = hero(4, 2, true, true)
assert(MatchLevels:InitializeStartingAbilityPoints(illusion, initialized) == false)
assert(illusion.abilityPoints == 2, "ignore illusions")

print("Match hero level progression tests passed: level table, normal level-one and test level-six starts, setup order and one-time point budget")
