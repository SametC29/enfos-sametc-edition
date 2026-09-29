package.path = "game/scripts/vscripts/?.lua;" .. package.path
local MatchLevels = require("heroes/match_levels")

local xp = MatchLevels:BuildXPThresholds()
assert(#xp == 50, "custom XP table must contain one cumulative threshold per hero level")
assert(xp[1] == 0, "level 1 threshold starts at zero")
assert(xp[50] == 97020, "level 50 threshold matches the 49 transition costs")
for level = 2, #xp do
	assert(xp[level] > xp[level - 1], "XP thresholds must strictly increase")
end

local callOrder = {}
local gameMode = {
	SetCustomXPRequiredToReachNextLevel = function(_, thresholds)
		assert(thresholds[50] == 97020)
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
local function hero(playerID, points, real, illusion)
	return {
		abilityPoints = points,
		IsNull = function() return false end,
		IsRealHero = function() return real ~= false end,
		IsIllusion = function() return illusion == true end,
		GetPlayerID = function() return playerID end,
		SetAbilityPoints = function(self, value) self.abilityPoints = value end,
	}
end

local first = hero(2, 1)
assert(MatchLevels:InitializeStartingAbilityPoints(first, initialized) == true)
assert(first.abilityPoints == 0, "clear only the initial level-1 ability point")
local respawn = hero(2, 3)
assert(MatchLevels:InitializeStartingAbilityPoints(respawn, initialized) == false)
assert(respawn.abilityPoints == 3, "do not clear earned points on respawn or reconnect")
local otherPlayer = hero(3, 1)
assert(MatchLevels:InitializeStartingAbilityPoints(otherPlayer, initialized) == true)
assert(otherPlayer.abilityPoints == 0, "initialize each player once")
local illusion = hero(4, 2, true, true)
assert(MatchLevels:InitializeStartingAbilityPoints(illusion, initialized) == false)
assert(illusion.abilityPoints == 2, "ignore illusions")

print("Match hero level progression tests passed: level table, setup order and one-time point budget")
