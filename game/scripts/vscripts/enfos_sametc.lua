--------------------------------------------------------------------------------
-- enfos_sametc.lua
-- Main game mode class for Enfos Team Survival — SametC Edition
--------------------------------------------------------------------------------

require("lib/log")
local InventoryTransfer = require("lib/inventory_transfer")

local function ReadBuildVersion()
	return "0.1.0-dev"
end

if EnfosSametC == nil then
	EnfosSametC = class({})
end

--------------------------------------------------------------------------------
-- InitGameMode
--------------------------------------------------------------------------------
function EnfosSametC:InitGameMode()
	self.buildVersion = ReadBuildVersion()
	self.playerHeroes = {}

	Log:Info("system", "========================================")
	Log:Info("system", "Enfos Team Survival — SametC Edition")
	Log:Info("system", "Build: %s", self.buildVersion)
	Log:Info("system", "========================================")

	local gameMode = GameRules:GetGameModeEntity()
	-- Install native team markers before the engine creates selected heroes.
	require("map/hero_spawns"):Init()

	-- Basic game settings
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 5)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 5)
	GameRules:SetUseUniversalShopMode(true)

	-- Custom Game Setup & Hero Selection Settings
	GameRules:EnableCustomGameSetupAutoLaunch(false)
	GameRules:SetCustomGameSetupTimeout(45.0)
	GameRules:SetCustomGameSetupAutoLaunchDelay(0.0)
	GameRules:SetCustomGameSetupRemainingTime(45.0)
	GameRules:SetHeroSelectionTime(90.0)
	GameRules:SetStrategyTime(0.0)
	GameRules:SetShowcaseTime(0.0)
	GameRules:SetPreGameTime(10.0)
	GameRules:SetPostGameTime(60.0)
	GameRules:SetSameHeroSelectionEnabled(true)

	-- Full Map Vision & Disable Fog of War
	gameMode:SetFogOfWarDisabled(true)
	gameMode:SetUnseenFogOfWarEnabled(false)

	-- Direct Inventory Purchasing Rules (No Couriers)
	gameMode:SetFreeCourierModeEnabled(false)
	gameMode:SetUseTurboCouriers(false)
	gameMode:SetCanSellAnywhere(true)
	GameRules:SetUseUniversalShopMode(true)
	gameMode:SetStashPurchasingDisabled(false)
	if gameMode.SetSendToStashEnabled then
		gameMode:SetSendToStashEnabled(false)
	end

	-- Native recipes and secret-shop components use one universal home shop.
	require("economy/native_shop"):Init()

	-- Order Filter to intercept item sellback
	gameMode:SetExecuteOrderFilter(Dynamic_Wrap(EnfosSametC, "OrderFilter"), self)

	-- Atmospheric Theme: Colosseum / Motes Ambient Particles
	local weatherFx = ParticleManager:CreateParticle("particles/rain_fx/coloseum_terrain_motes.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(weatherFx, 0, Vector(0, 0, 256))

	-- Thinking
	gameMode:SetThink("OnThink", self, "GlobalThink", 0.25)

	-- Register event listeners
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(EnfosSametC, "OnGameRulesStateChange"), self)
	ListenToGameEvent("npc_spawned", Dynamic_Wrap(EnfosSametC, "OnNPCSpawned"), self)

	Log:Info("system", "Game mode initialized successfully.")
end

--------------------------------------------------------------------------------
-- Helper: Direct Inventory & Stash Auto-Transfer / Auto-Combine
--------------------------------------------------------------------------------
function EnfosSametC:TransferStashToInventory(hero)
	if not hero or hero:IsNull() or not hero:IsAlive() then return end

	-- 1. Check stash slots (9 to 14) and move items into inventory (0..5) or backpack (6..8)
	for stashSlot = 9, 14 do
		local item = hero:GetItemInSlot(stashSlot)
		if item and not item:IsNull() then
			-- Prefer main inventory slots 0 to 5 first so recipes auto-combine
			local targetSlot = nil
			for slot = 0, 5 do
				if hero:GetItemInSlot(slot) == nil then
					targetSlot = slot
					break
				end
			end
			-- If main inventory is full, fall back to backpack slots 6 to 8
			if targetSlot == nil then
				for slot = 6, 8 do
					if hero:GetItemInSlot(slot) == nil then
						targetSlot = slot
						break
					end
				end
			end

			if targetSlot ~= nil then
				hero:SwapItems(stashSlot, targetSlot)
			end
		end
	end

	-- 2. If main inventory (0..5) has an empty slot and backpack (6..8) has items,
	-- promote backpack items to main inventory so recipes auto-combine smoothly.
	for mainSlot = 0, 5 do
		if hero:GetItemInSlot(mainSlot) == nil then
			for bpSlot = 6, 8 do
				local bpItem = hero:GetItemInSlot(bpSlot)
				if bpItem and not bpItem:IsNull() then
					hero:SwapItems(bpSlot, mainSlot)
					break
				end
			end
		end
	end
end

--------------------------------------------------------------------------------
-- OrderFilter
--------------------------------------------------------------------------------
function EnfosSametC:OrderFilter(filterTable)
	if not filterTable then return true end
	local playerID = filterTable.issuer_player_id_const
	if playerID == nil or not PlayerResource:IsValidPlayerID(playerID) then return true end
	if filterTable.order_type == DOTA_UNIT_ORDER_SELL_ITEM then
		local it = filterTable.entindex_ability and EntIndexToHScript(filterTable.entindex_ability)
		if it and not it:IsNull() and require("economy/ascended_shop").LOOKUP[it:GetAbilityName()] then
			require("economy/ascended_shop"):Sellback(playerID, it)
			return false
		end
	end
	return true
end

--------------------------------------------------------------------------------
-- OnThink
--------------------------------------------------------------------------------
function EnfosSametC:OnThink()
	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then return nil end

	-- Permanent 100% full map vision
	AddFOWViewer(DOTA_TEAM_GOODGUYS, Vector(0, 0, 0), 20000, 1.5, false)
	AddFOWViewer(DOTA_TEAM_BADGUYS, Vector(0, 0, 0), 20000, 1.5, false)

	-- Direct-to-inventory purchasing: auto-transfer stash items into inventory/backpack
	for playerId, hero in pairs(self.playerHeroes) do
		if hero and not hero:IsNull() and hero:IsAlive() then
			require("economy/native_shop"):FollowHero(hero)
			self:TransferStashToInventory(hero)
		end
	end

	return 0.25
end

--------------------------------------------------------------------------------
-- Event handlers
--------------------------------------------------------------------------------
function EnfosSametC:OnGameRulesStateChange()
	local state = GameRules:State_Get()
	Log:Info("system", "Game state changed to: %d", state)
end

function EnfosSametC:OnNPCSpawned(event)
	local spawnedUnit = EntIndexToHScript(event.entindex)
	if not spawnedUnit or spawnedUnit:IsNull() then return end

	-- Eliminate any courier spawned by engine
	if spawnedUnit:IsCourier() then
		spawnedUnit:RemoveSelf()
		return
	end

	-- Register Hero
	if spawnedUnit:IsRealHero() then
		require("map/hero_spawns"):ConfigureHero(spawnedUnit)
		require("heroes/hero_power"):Apply(spawnedUnit)
		require("heroes/innates"):Apply(spawnedUnit)
		local playerId = spawnedUnit:GetPlayerID()
		if playerId and playerId >= 0 then
			self.playerHeroes[playerId] = spawnedUnit
			require("evolution/evolution_manager"):RestoreHero(playerId, spawnedUnit)
			local progression = require("progression/progression_manager")
			if progression.initialized and not progression:GetProfile(playerId) then
				progression:LoadPlayer(playerId, PlayerResource:GetSteamAccountID(playerId))
			end
		end
	end
end
