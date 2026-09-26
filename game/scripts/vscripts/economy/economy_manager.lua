--------------------------------------------------------------------------------
-- economy_manager.lua
-- Server-authoritative economy system for Enfos Team Survival — SametC Edition
-- Handles Lumber currency, Gold <-> Lumber conversion, teammate transfers,
-- Boss Lumber awards, and escalating Tome stat purchases.
-- Reference: docs/GAME_DESIGN_MASTER.md § 20, 21, 22, 24
-- Reference: docs/IMPLEMENTATION_ROADMAP.md § Phase 7
--------------------------------------------------------------------------------

require("lib/log")

local EconomyManager = {}
EconomyManager.__index = EconomyManager

-- Conversion seeds (docs/GAME_DESIGN_MASTER.md § 21)
EconomyManager.GOLD_TO_LUMBER_RATE = 100 -- 100 Gold = 1 Lumber (1000 Gold -> 10 Lumber)
EconomyManager.LUMBER_TO_GOLD_RATE = 90  -- 1 Lumber = 90 Gold (10 Lumber -> 900 Gold, 10% loss)

-- Tome base configuration (docs/GAME_DESIGN_MASTER.md § 22)
EconomyManager.TOME_BASE_COST = 500       -- Base Gold cost per tome
EconomyManager.TOME_PRICE_GROWTH = 0.10   -- +10% price escalation per same-type purchase
EconomyManager.TOME_STAT_BONUS = 2        -- +2 permanent attribute per tome

--------------------------------------------------------------------------------
-- Initialize Economy Manager
--------------------------------------------------------------------------------
function EconomyManager:Init(waveManager)
	self.waveManager = waveManager
	self.playerLumber = {}
	self.tomePurchases = {}

	for id = 0, (DOTA_MAX_TEAM_PLAYERS or 24) - 1 do
		self.playerLumber[id] = 0
		self.tomePurchases[id] = { str = 0, agi = 0, int = 0 }
	end

	self:RegisterEventHandlers()
	self:SyncAllNetTables()

	Log:Info("economy", "EconomyManager initialized successfully.")
end

--------------------------------------------------------------------------------
-- NetTable Synchronization
--------------------------------------------------------------------------------
function EconomyManager:SyncNetTable(playerId)
	if not CustomNetTables or not playerId then return end

	local lumber = self:GetLumber(playerId)
	local tomes = self.tomePurchases[playerId] or { str = 0, agi = 0, int = 0 }

	CustomNetTables:SetTableValue("economy_state", tostring(playerId), {
		lumber = lumber,
		tome_str_count = tomes.str or 0,
		tome_agi_count = tomes.agi or 0,
		tome_int_count = tomes.int or 0,
		tome_str_cost = self:GetTomeCost(playerId, "str"),
		tome_agi_cost = self:GetTomeCost(playerId, "agi"),
		tome_int_cost = self:GetTomeCost(playerId, "int"),
	})
end

function EconomyManager:SyncAllNetTables()
	if not CustomNetTables then return end
	for id = 0, (DOTA_MAX_TEAM_PLAYERS or 24) - 1 do
		self:SyncNetTable(id)
	end
end

--------------------------------------------------------------------------------
-- Lumber Queries and Mutations
--------------------------------------------------------------------------------
function EconomyManager:GetLumber(playerId)
	if playerId == nil then return 0 end
	return self.playerLumber[playerId] or 0
end

function EconomyManager:ModifyLumber(playerId, amount, reason)
	if playerId == nil or amount == nil then return 0 end
	amount = math.floor(tonumber(amount) or 0)
	if amount == 0 then return self:GetLumber(playerId) end

	local current = self.playerLumber[playerId] or 0
	local updated = math.max(0, current + amount)
	self.playerLumber[playerId] = updated

	Log:Info("economy", "Player %d Lumber modified: %d -> %d (Delta: %d, Reason: %s)",
		playerId, current, updated, amount, tostring(reason or "generic"))

	self:SyncNetTable(playerId)
	return updated
end

--------------------------------------------------------------------------------
-- Gold <-> Lumber Conversions (docs/GAME_DESIGN_MASTER.md § 21)
--------------------------------------------------------------------------------
function EconomyManager:ConvertGoldToLumber(playerId, goldAmount)
	if playerId == nil or not PlayerResource:IsValidPlayerID(playerId) then return false, 0, 0 end
	goldAmount = math.floor(tonumber(goldAmount) or 0)
	if goldAmount < self.GOLD_TO_LUMBER_RATE then
		Log:Warn("economy", "Player %d attempted conversion below minimum 100 gold: %d", playerId, goldAmount)
		return false, 0, 0
	end

	local currentGold = PlayerResource:GetGold(playerId)
	if currentGold < goldAmount then
		Log:Warn("economy", "Player %d insufficient gold for conversion: has %d, requested %d", playerId, currentGold, goldAmount)
		return false, 0, 0
	end

	local lumberGained = math.floor(goldAmount / self.GOLD_TO_LUMBER_RATE)
	local actualGoldSpent = lumberGained * self.GOLD_TO_LUMBER_RATE

	-- Deduct Gold and grant Lumber
	PlayerResource:ModifyGold(playerId, -actualGoldSpent, true, DOTA_ModifyGold_PurchaseConsumable)
	self:ModifyLumber(playerId, lumberGained, "gold_to_lumber_conversion")

	Log:Info("economy", "CONVERSION: Player %d converted %d Gold -> %d Lumber", playerId, actualGoldSpent, lumberGained)
	return true, lumberGained, actualGoldSpent
end

function EconomyManager:ConvertLumberToGold(playerId, lumberAmount)
	if playerId == nil or not PlayerResource:IsValidPlayerID(playerId) then return false, 0 end
	lumberAmount = math.floor(tonumber(lumberAmount) or 0)
	if lumberAmount < 1 then return false, 0 end

	local currentLumber = self:GetLumber(playerId)
	if currentLumber < lumberAmount then
		Log:Warn("economy", "Player %d insufficient lumber for conversion: has %d, requested %d", playerId, currentLumber, lumberAmount)
		return false, 0
	end

	local goldGained = lumberAmount * self.LUMBER_TO_GOLD_RATE

	-- Deduct Lumber and grant Gold
	self:ModifyLumber(playerId, -lumberAmount, "lumber_to_gold_conversion")
	PlayerResource:ModifyGold(playerId, goldGained, true, DOTA_ModifyGold_SellConsumable)

	Log:Info("economy", "CONVERSION: Player %d converted %d Lumber -> %d Gold (10%% loss applied)", playerId, lumberAmount, goldGained)
	return true, goldGained
end

--------------------------------------------------------------------------------
-- Teammate Transfers (docs/GAME_DESIGN_MASTER.md § 20)
--------------------------------------------------------------------------------
function EconomyManager:TransferGold(senderId, recipientId, amount)
	if senderId == nil or recipientId == nil or senderId == recipientId then return false end
	if not PlayerResource:IsValidPlayerID(senderId) or not PlayerResource:IsValidPlayerID(recipientId) then return false end

	-- Must be on the same team
	if PlayerResource:GetTeam(senderId) ~= PlayerResource:GetTeam(recipientId) then
		Log:Warn("economy", "REJECTED: Player %d attempted cross-team gold transfer to Player %d", senderId, recipientId)
		return false
	end

	-- Sender must be active and connected (cannot transfer from abandoned players)
	if PlayerResource:GetConnectionState(senderId) ~= DOTA_CONNECTION_STATE_CONNECTED then
		return false
	end

	amount = math.floor(tonumber(amount) or 0)
	if amount <= 0 then return false end

	local senderGold = PlayerResource:GetGold(senderId)
	if senderGold < amount then
		Log:Warn("economy", "REJECTED: Player %d insufficient gold to transfer %d (has %d)", senderId, amount, senderGold)
		return false
	end

	-- Execute transfer
	PlayerResource:ModifyGold(senderId, -amount, true, DOTA_ModifyGold_AbilityCost)
	PlayerResource:ModifyGold(recipientId, amount, true, DOTA_ModifyGold_SharedGold)

	Log:Info("economy", "TRANSFER: Player %d sent %d Gold to teammate Player %d", senderId, amount, recipientId)
	return true
end

function EconomyManager:TransferLumber(senderId, recipientId, amount)
	if senderId == nil or recipientId == nil or senderId == recipientId then return false end
	if not PlayerResource:IsValidPlayerID(senderId) or not PlayerResource:IsValidPlayerID(recipientId) then return false end

	-- Must be on the same team
	if PlayerResource:GetTeam(senderId) ~= PlayerResource:GetTeam(recipientId) then
		Log:Warn("economy", "REJECTED: Player %d attempted cross-team lumber transfer to Player %d", senderId, recipientId)
		return false
	end

	-- Sender must be active and connected
	if PlayerResource:GetConnectionState(senderId) ~= DOTA_CONNECTION_STATE_CONNECTED then
		return false
	end

	amount = math.floor(tonumber(amount) or 0)
	if amount <= 0 then return false end

	local senderLumber = self:GetLumber(senderId)
	if senderLumber < amount then
		Log:Warn("economy", "REJECTED: Player %d insufficient lumber to transfer %d (has %d)", senderId, amount, senderLumber)
		return false
	end

	-- Execute transfer
	self:ModifyLumber(senderId, -amount, "transfer_sent")
	self:ModifyLumber(recipientId, amount, "transfer_received")

	Log:Info("economy", "TRANSFER: Player %d sent %d Lumber to teammate Player %d", senderId, amount, recipientId)
	return true
end

--------------------------------------------------------------------------------
-- Boss Lumber Award (docs/GAME_DESIGN_MASTER.md § 24)
--------------------------------------------------------------------------------
function EconomyManager:AwardBossLumber(team, waveNumber)
	if not team or not waveNumber then return end

	-- Formula: 5 + floor(waveNumber / 5) (scales with wave depth)
	local lumberAmount = 5 + math.floor(waveNumber / 5)
	local awardedPlayers = {}

	for id = 0, (DOTA_MAX_TEAM_PLAYERS or 24) - 1 do
		if PlayerResource:IsValidPlayerID(id)
			and PlayerResource:GetTeam(id) == team
			and PlayerResource:GetConnectionState(id) == DOTA_CONNECTION_STATE_CONNECTED then
			self:ModifyLumber(id, lumberAmount, "boss_clear_wave_" .. tostring(waveNumber))
			table.insert(awardedPlayers, id)
		end
	end

	Log:Info("economy", "BOSS REWARD: Awarded %d Lumber to %d players on Team %d for clearing Boss Wave %d",
		lumberAmount, #awardedPlayers, team, waveNumber)

	return lumberAmount, #awardedPlayers
end

--------------------------------------------------------------------------------
-- Tomes: Scaling Price & Permanent Stat Growth (docs/GAME_DESIGN_MASTER.md § 22)
--------------------------------------------------------------------------------
function EconomyManager:GetTomeCost(playerId, tomeType)
	if not self.tomePurchases[playerId] then
		self.tomePurchases[playerId] = { str = 0, agi = 0, int = 0 }
	end

	local count = self.tomePurchases[playerId][tomeType] or 0
	-- Escalation: +10% per same-type purchase
	return math.floor(self.TOME_BASE_COST * (1 + self.TOME_PRICE_GROWTH * count))
end

function EconomyManager:PurchaseTome(playerId, tomeType)
	if playerId == nil or not PlayerResource:IsValidPlayerID(playerId) then return false end
	if tomeType ~= "str" and tomeType ~= "agi" and tomeType ~= "int" then return false end

	local hero = PlayerResource:GetSelectedHeroEntity(playerId)
	if not hero or hero:IsNull() or not hero:IsAlive() then
		Log:Warn("economy", "Player %d cannot purchase tome: hero not alive/valid", playerId)
		return false
	end

	local cost = self:GetTomeCost(playerId, tomeType)
	local currentGold = PlayerResource:GetGold(playerId)
	if currentGold < cost then
		Log:Warn("economy", "Player %d insufficient gold for tome %s: cost %d, has %d", playerId, tomeType, cost, currentGold)
		return false
	end

	-- Deduct Gold
	PlayerResource:ModifyGold(playerId, -cost, true, DOTA_ModifyGold_PurchaseConsumable)

	-- Apply permanent stat to hero
	if tomeType == "str" then
		hero:ModifyStrength(self.TOME_STAT_BONUS)
	elseif tomeType == "agi" then
		hero:ModifyAgility(self.TOME_STAT_BONUS)
	elseif tomeType == "int" then
		hero:ModifyIntellect(self.TOME_STAT_BONUS)
	end

	-- Increment purchase count
	self.tomePurchases[playerId][tomeType] = (self.tomePurchases[playerId][tomeType] or 0) + 1

	-- Visual and sound effects
	if hero.EmitSound then
		hero:EmitSound("Item.TomeOfKnowledge")
	end
	if ParticleManager then
		local fx = ParticleManager:CreateParticle("particles/generic_hero_status/hero_levelup.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
		ParticleManager:ReleaseParticleIndex(fx)
	end

	Log:Info("economy", "TOME: Player %d purchased %s Tome (+%d stat) for %d Gold. Total %s tomes: %d",
		playerId, tomeType:upper(), self.TOME_STAT_BONUS, cost, tomeType, self.tomePurchases[playerId][tomeType])

	self:SyncNetTable(playerId)
	return true
end

--------------------------------------------------------------------------------
-- Register Panorama Custom Game Event Listeners
--------------------------------------------------------------------------------
function EconomyManager:RegisterEventHandlers()
	if not CustomGameEventManager then return end

	CustomGameEventManager:RegisterListener("enfos_convert_gold_to_lumber", function(_, event)
		local playerId = event.PlayerID
		local amount = event.amount or 1000
		EconomyManager:ConvertGoldToLumber(playerId, amount)
	end)

	CustomGameEventManager:RegisterListener("enfos_convert_lumber_to_gold", function(_, event)
		local playerId = event.PlayerID
		local amount = event.amount or 10
		EconomyManager:ConvertLumberToGold(playerId, amount)
	end)

	CustomGameEventManager:RegisterListener("enfos_transfer_gold", function(_, event)
		local senderId = event.PlayerID
		local recipientId = event.recipient_id
		local amount = event.amount
		EconomyManager:TransferGold(senderId, recipientId, amount)
	end)

	CustomGameEventManager:RegisterListener("enfos_transfer_lumber", function(_, event)
		local senderId = event.PlayerID
		local recipientId = event.recipient_id
		local amount = event.amount
		EconomyManager:TransferLumber(senderId, recipientId, amount)
	end)

	CustomGameEventManager:RegisterListener("enfos_buy_tome", function(_, event)
		local playerId = event.PlayerID
		local tomeType = event.tome_type
		EconomyManager:PurchaseTome(playerId, tomeType)
	end)
end

return EconomyManager
