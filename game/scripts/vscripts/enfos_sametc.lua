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
	self.playerCouriers = {}
	self.playerHeroes = {}
	self.deliveryRequested = {}
	self.pendingCouriers = {}

	Log:Info("system", "========================================")
	Log:Info("system", "Enfos Team Survival — SametC Edition")
	Log:Info("system", "Build: %s", self.buildVersion)
	Log:Info("system", "========================================")

	local gameMode = GameRules:GetGameModeEntity()

	-- Basic game settings
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 5)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 5)
	GameRules:SetUseUniversalShopMode(true)

	-- Hero Selection Settings
	GameRules:SetHeroSelectionTime(30.0)
	GameRules:SetStrategyTime(0.0)
	GameRules:SetShowcaseTime(0.0)
	GameRules:SetPreGameTime(10.0)
	GameRules:SetPostGameTime(60.0)
	GameRules:SetSameHeroSelectionEnabled(true)

	-- Full Map Vision & Disable Fog of War
	gameMode:SetFogOfWarDisabled(true)
	gameMode:SetUnseenFogOfWarEnabled(false)

	-- Flying Courier & Shop/Inventory Rules
	gameMode:SetFreeCourierModeEnabled(true)
	gameMode:SetUseTurboCouriers(true)
	gameMode:SetCanSellAnywhere(true)
	GameRules:SetUseUniversalShopMode(true)

	-- Order Filter to intercept and assist courier deliveries
	gameMode:SetExecuteOrderFilter(Dynamic_Wrap(EnfosSametC, "OrderFilter"), self)

	-- Atmospheric Theme: Colosseum / Motes Ambient Particles
	local weatherFx = ParticleManager:CreateParticle("particles/rain_fx/coloseum_terrain_motes.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(weatherFx, 0, Vector(0, 0, 256))

	-- Thinking
	gameMode:SetThink("OnThink", self, "GlobalThink", 0.5)

	-- Register event listeners
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(EnfosSametC, "OnGameRulesStateChange"), self)
	ListenToGameEvent("npc_spawned", Dynamic_Wrap(EnfosSametC, "OnNPCSpawned"), self)

	Log:Info("system", "Game mode initialized successfully.")
end

--------------------------------------------------------------------------------
-- Helper: Configure Courier
--------------------------------------------------------------------------------
function EnfosSametC:ConfigureCourier(courier, playerId)
	if not courier or courier:IsNull() then return false end
	if playerId == nil or not PlayerResource:IsValidPlayerID(playerId) then return false end
	if courier:GetPlayerOwnerID() ~= playerId or courier:GetTeamNumber() ~= PlayerResource:GetTeam(playerId) then return false end

	courier:SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY)
	courier:SetBaseMoveSpeed(1100)

	-- Ensure invulnerability and flying status
	if not courier:HasModifier("modifier_courier_flying") then
		courier:AddNewModifier(courier, nil, "modifier_courier_flying", {})
	end
	if not courier:HasModifier("modifier_invulnerable") then
		courier:AddNewModifier(courier, nil, "modifier_invulnerable", {})
	end
	if not courier:HasModifier("modifier_phased") then
		courier:AddNewModifier(courier, nil, "modifier_phased", {})
	end

	-- Level up all courier abilities so they are active and functional
	for i = 0, courier:GetAbilityCount() - 1 do
		local ab = courier:GetAbilityByIndex(i)
		if ab and ab:GetLevel() == 0 then
			ab:SetLevel(1)
		end
	end

	if playerId and playerId >= 0 then
		courier:SetControllableByPlayer(playerId, true)
		self.playerCouriers[playerId] = courier
	end

	Log:Info("courier", "Configured flying turbo courier with active abilities (Player %s).", tostring(playerId))
	return true
end

--------------------------------------------------------------------------------
-- Helper: Transfer Stash to Courier
--------------------------------------------------------------------------------
function EnfosSametC:TransferStashToCourier(hero, courier)
	if not hero or hero:IsNull() or not courier or courier:IsNull() then return 0 end

	return InventoryTransfer.Range(hero, courier, 9, 14, 0, 5)
end

--------------------------------------------------------------------------------
-- Helper: Transfer Courier to Hero
--------------------------------------------------------------------------------
function EnfosSametC:TransferCourierToHero(courier, hero)
	if not hero or hero:IsNull() or not courier or courier:IsNull() then return 0 end

	local deliveredCount = InventoryTransfer.Range(courier, hero, 0, 5, 0, 5)

	if deliveredCount > 0 then
		EmitSoundOn("Courier.TransferItems", hero)
	end
	return deliveredCount
end

--------------------------------------------------------------------------------
-- OrderFilter
--------------------------------------------------------------------------------
function EnfosSametC:OrderFilter(filterTable)
	if not filterTable then return true end
	local playerID = filterTable.issuer_player_id_const
	if playerID == nil or not PlayerResource:IsValidPlayerID(playerID) then return true end
	local courier = self.playerCouriers[playerID]
	if not courier or courier:IsNull() then return true end
	local abilityIndex = filterTable.entindex_ability
	local ability = abilityIndex and abilityIndex > 0 and EntIndexToHScript(abilityIndex) or nil
	if ability and not ability:IsNull() then
		local name = ability:GetAbilityName()
		local delivery = name == "courier_take_stash_and_transfer_items" or name == "courier_transfer_items" or name == "courier_autodeliver"
		local takeOnly = name == "courier_take_stash_items"
		if delivery or takeOnly then
			if ability:GetCaster() ~= courier or courier:GetPlayerOwnerID() ~= playerID then return false end
			local hero = PlayerResource:GetSelectedHeroEntity(playerID)
			if not hero or hero:IsNull() or hero:GetTeamNumber() ~= courier:GetTeamNumber() then return false end
			self.playerHeroes[playerID] = hero
			if name ~= "courier_transfer_items" then self:TransferStashToCourier(hero, courier) end
			self.deliveryRequested[playerID] = delivery or nil
			if delivery then courier:MoveToNPC(hero) end
			-- We handled this command; don't let native delivery race the transfer.
			return false
		end
		if ability:GetCaster() == courier then self.deliveryRequested[playerID] = nil end
	end
	if filterTable.order_type == DOTA_UNIT_ORDER_STOP
		or filterTable.order_type == DOTA_UNIT_ORDER_HOLD_POSITION
		or filterTable.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION then
		for _, index in pairs(filterTable.units or {}) do
			if EntIndexToHScript(index) == courier then self.deliveryRequested[playerID] = nil end
		end
	end
	return true
end

--------------------------------------------------------------------------------
-- OnThink
--------------------------------------------------------------------------------
function EnfosSametC:OnThink()
	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then return nil end
	for index, pending in pairs(self.pendingCouriers) do
		local unit = pending.unit
		if unit:IsNull() or pending.attempts >= 20 then
			self.pendingCouriers[index] = nil
		else
			local owner = unit:GetPlayerOwnerID()
			if owner and PlayerResource:IsValidPlayerID(owner) and self:ConfigureCourier(unit, owner) then
				self.pendingCouriers[index] = nil
			else
				pending.attempts = pending.attempts + 1
			end
		end
	end
	-- Permanent 100% full map vision
	AddFOWViewer(DOTA_TEAM_GOODGUYS, Vector(0, 0, 0), 20000, 1.5, false)
	AddFOWViewer(DOTA_TEAM_BADGUYS, Vector(0, 0, 0), 20000, 1.5, false)

	-- Proximity check for courier item hand-off to hero
	for playerId, courier in pairs(self.playerCouriers) do
		local hero = PlayerResource:GetSelectedHeroEntity(playerId)
		self.playerHeroes[playerId] = hero
		if self.deliveryRequested[playerId] and courier and hero and not courier:IsNull() and not hero:IsNull()
			and courier:GetPlayerOwnerID() == playerId and courier:GetTeamNumber() == hero:GetTeamNumber()
			and hero:IsAlive() and courier:IsAlive() then
			local dist = (courier:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()
			if dist <= 320 then
				self:TransferCourierToHero(courier, hero)
				local remaining = false
				for slot = 0, 5 do
					if courier:GetItemInSlot(slot) then remaining = true end
				end
				if not remaining then self.deliveryRequested[playerId] = nil end
			end
		end
	end

	-- FreeCourierMode owns courier creation; never spawn a competing fallback.

	return 0.5
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

	-- Register Hero
	if spawnedUnit:IsRealHero() then
		local playerId = spawnedUnit:GetPlayerID()
		if playerId and playerId >= 0 then
			self.playerHeroes[playerId] = spawnedUnit
		end
	end

	-- Reinforce courier when spawned by engine
	if spawnedUnit:IsCourier() then
		local playerId = spawnedUnit:GetPlayerOwnerID()
		if playerId and PlayerResource:IsValidPlayerID(playerId) then
			self:ConfigureCourier(spawnedUnit, playerId)
		else
			-- Ownership may not be assigned during npc_spawned. Retry for 10s.
			local count = 0
			for _ in pairs(self.pendingCouriers) do count = count + 1 end
			if count < 20 then
				self.pendingCouriers[event.entindex] = {unit = spawnedUnit, attempts = 0}
			end
		end
	end
end
