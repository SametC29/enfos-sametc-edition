--------------------------------------------------------------------------------
-- stats/scoreboard_manager.lua
-- Server-authoritative stats tracker for Enfos Team Survival — SametC Edition
-- Tracks:
--   - Total damage dealt to enemy units
--   - Total enemies / creeps killed (Retribution score)
--   - Total gold earned
--   - Hero level and lumber
-- Exposes stats via "player_stats" NetTable for Panorama Scoreboard & HUD.
--------------------------------------------------------------------------------

require("lib/log")

if ScoreboardManager == nil then
	ScoreboardManager = {}
	ScoreboardManager.__index = ScoreboardManager
end

ScoreboardManager.SYNC_INTERVAL = 0.5

function ScoreboardManager:Init()
	self.stats = {}
	self.lastHurtSync = 0

	local maxPlayers = (DOTA_MAX_TEAM_PLAYERS or 24) - 1
	for id = 0, maxPlayers do
		self.stats[id] = {
			damageDealt = 0,
			kills = 0,
			goldEarned = 0,
			level = 1,
			lumber = 0
		}
	end

	ListenToGameEvent("entity_hurt", Dynamic_Wrap(ScoreboardManager, "OnEntityHurt"), self)
	ListenToGameEvent("entity_killed", Dynamic_Wrap(ScoreboardManager, "OnEntityKilled"), self)

	-- Periodic sync thinker
	if GameRules and GameRules:GetGameModeEntity() then
		GameRules:GetGameModeEntity():SetContextThink("ScoreboardManager_Think", function()
			return self:OnThink()
		end, self.SYNC_INTERVAL)
	end

	self:SyncAll()
	Log:Info("system", "ScoreboardManager initialized successfully.")
end

function ScoreboardManager:ResolvePlayerID(entity)
	if not entity or entity:IsNull() then return -1 end

	if entity.GetPlayerOwnerID then
		local pid = entity:GetPlayerOwnerID()
		if pid and pid >= 0 then return pid end
	end

	if entity.GetPlayerID then
		local pid = entity:GetPlayerID()
		if pid and pid >= 0 then return pid end
	end

	if entity.GetOwner then
		local owner = entity:GetOwner()
		if owner and not owner:IsNull() and owner ~= entity then
			return self:ResolvePlayerID(owner)
		end
	end

	return -1
end

function ScoreboardManager:OnEntityHurt(event)
	if not event or not event.entindex_attacker or not event.entindex_killed then return end

	local attacker = EntIndexToHScript(event.entindex_attacker)
	local victim = EntIndexToHScript(event.entindex_killed)
	if not attacker or attacker:IsNull() or not victim or victim:IsNull() then return end

	-- Only count damage dealt to enemy units
	if attacker.GetTeamNumber and victim.GetTeamNumber and attacker:GetTeamNumber() == victim:GetTeamNumber() then
		return
	end

	local pid = self:ResolvePlayerID(attacker)
	if pid >= 0 and self.stats[pid] then
		local dmg = tonumber(event.damage) or 0
		if dmg > 0 then
			self.stats[pid].damageDealt = self.stats[pid].damageDealt + dmg
		end
	end
end

function ScoreboardManager:OnEntityKilled(event)
	if not event or not event.entindex_attacker or not event.entindex_killed then return end

	local killer = EntIndexToHScript(event.entindex_attacker)
	local victim = EntIndexToHScript(event.entindex_killed)
	if not killer or killer:IsNull() or not victim or victim:IsNull() then return end

	-- Check that killer and victim are on opposing teams
	if killer.GetTeamNumber and victim.GetTeamNumber and killer:GetTeamNumber() == victim:GetTeamNumber() then
		return
	end

	local pid = self:ResolvePlayerID(killer)
	if pid >= 0 and self.stats[pid] then
		self.stats[pid].kills = self.stats[pid].kills + 1
		self:SyncPlayer(pid)
	end
end

function ScoreboardManager:OnThink()
	self:SyncAll()
	return self.SYNC_INTERVAL
end

function ScoreboardManager:SyncPlayer(playerId)
	if not CustomNetTables or playerId < 0 or not self.stats[playerId] then return end

	local data = self.stats[playerId]
	local hero = PlayerResource and PlayerResource:GetSelectedHeroEntity(playerId) or nil
	local level = (hero and not hero:IsNull() and hero.GetLevel) and hero:GetLevel() or 1
	local lumber = (EconomyManager and EconomyManager.GetLumber) and EconomyManager:GetLumber(playerId) or 0
	local goldEarned = (PlayerResource and PlayerResource.GetTotalGoldEarned) and PlayerResource:GetTotalGoldEarned(playerId) or 0

	CustomNetTables:SetTableValue("player_stats", tostring(playerId), {
		damage_dealt = math.floor(data.damageDealt or 0),
		kills = math.floor(data.kills or 0),
		gold_earned = math.floor(goldEarned),
		level = level,
		lumber = math.floor(lumber)
	})
end

function ScoreboardManager:SyncAll()
	if not CustomNetTables then return end

	local maxPlayers = (DOTA_MAX_TEAM_PLAYERS or 24) - 1
	for id = 0, maxPlayers do
		if PlayerResource and PlayerResource:IsValidPlayerID(id) then
			self:SyncPlayer(id)
		end
	end
end

function ScoreboardManager:GetDamageDealt(playerId)
	return self.stats[playerId] and self.stats[playerId].damageDealt or 0
end

function ScoreboardManager:GetKills(playerId)
	return self.stats[playerId] and self.stats[playerId].kills or 0
end

return ScoreboardManager
