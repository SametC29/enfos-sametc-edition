-- Match-local player death timer; native reincarnation remains authoritative.
local Levels = require("heroes/match_levels")
local Respawn = { MIN_SECONDS = 30, MAX_SECONDS = 50, CURVE_START_LEVEL = 6 }

function Respawn:SecondsForLevel(level)
	local startLevel = self.CURVE_START_LEVEL
	local bounded = math.max(startLevel, math.min(Levels.MAX_LEVEL, level))
	local fraction = (bounded - startLevel) / (Levels.MAX_LEVEL - startLevel)
	return math.floor(self.MIN_SECONDS + (self.MAX_SECONDS - self.MIN_SECONDS) * fraction + 0.5)
end

function Respawn:Init()
	if self.listener then return end
	self.listener = ListenToGameEvent("entity_killed", function(event) self:OnDeath(event) end, nil)
end

function Respawn:OnDeath(event)
	if not event or not event.entindex_killed then return false end
	local hero = EntIndexToHScript(event.entindex_killed)
	if not hero or hero:IsNull() or not hero:IsRealHero() or hero:IsIllusion()
		or hero:IsAlive() or hero.isBoss then return false end
	local team, playerID = hero:GetTeamNumber(), hero:GetPlayerID()
	if (team ~= (DOTA_TEAM_GOODGUYS or 2) and team ~= (DOTA_TEAM_BADGUYS or 3))
		or not playerID or playerID < 0 or not PlayerResource:IsValidPlayerID(playerID)
		or PlayerResource:GetSelectedHeroEntity(playerID) ~= hero then return false end
	if (hero.IsClone and hero:IsClone()) or (hero.IsTempestDouble and hero:IsTempestDouble())
		or hero:IsReincarnating() or hero:WillReincarnate() then return false end
	local seconds = self:SecondsForLevel(hero:GetLevel())
	hero:SetTimeUntilRespawn(seconds)
	return true
end

return Respawn
