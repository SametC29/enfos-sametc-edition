--------------------------------------------------------------------------------
-- enfos_sametc.lua
-- Main game mode class for Enfos Team Survival — SametC Edition
--------------------------------------------------------------------------------

require("lib/log")

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
	if not courier or courier:IsNull() then return end

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
end

--------------------------------------------------------------------------------
-- Helper: Transfer Stash to Courier
--------------------------------------------------------------------------------
function EnfosSametC:TransferStashToCourier(hero, courier)
	if not hero or hero:IsNull() or not courier or courier:IsNull() then return 0 end

	local transferredCount = 0
	-- Stash slots in Dota 2 are 9 through 14 (DOTA_STASH_SLOT_1 .. DOTA_STASH_SLOT_6)
	for slot = 9, 14 do
		local item = hero:GetItemInSlot(slot)
		if item and not item:IsNull() then
			hero:TakeItem(item)
			courier:AddItem(item)
			transferredCount = transferredCount + 1
		end
	end
	return transferredCount
end

--------------------------------------------------------------------------------
-- Helper: Transfer Courier to Hero
--------------------------------------------------------------------------------
function EnfosSametC:TransferCourierToHero(courier, hero)
	if not hero or hero:IsNull() or not courier or courier:IsNull() then return 0 end

	local deliveredCount = 0
	-- Courier slots 0 to 5
	for slot = 0, 5 do
		local item = courier:GetItemInSlot(slot)
		if item and not item:IsNull() then
			-- Check if hero has inventory space (main 0..5 or backpack 6..8)
			local hasSpace = false
			for hSlot = 0, 8 do
				if hero:GetItemInSlot(hSlot) == nil then
					hasSpace = true
					break
				end
			end

			if hasSpace then
				courier:TakeItem(item)
				hero:AddItem(item)
				deliveredCount = deliveredCount + 1
			end
		end
	end

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

	local orderType = filterTable.order_type
	local playerID = filterTable.issuer_player_id_const
	local abilityIndex = filterTable.entindex_ability

	-- If a courier delivery ability is triggered
	if abilityIndex and abilityIndex > 0 then
		local ability = EntIndexToHScript(abilityIndex)
		if ability and not ability:IsNull() then
			local abilityName = ability:GetAbilityName()
			if abilityName == "courier_take_stash_and_transfer_items"
				or abilityName == "courier_take_stash_items"
				or abilityName == "courier_transfer_items"
				or abilityName == "courier_autodeliver" then

				local hero = self.playerHeroes[playerID]
				local courier = self.playerCouriers[playerID]

				if hero and courier and not hero:IsNull() and not courier:IsNull() then
					-- Immediately retrieve all items from hero's stash into courier
					self:TransferStashToCourier(hero, courier)
					courier:MoveToNPC(hero)
				end
			end
		end
	end

	return true
end

--------------------------------------------------------------------------------
-- OnThink
--------------------------------------------------------------------------------
function EnfosSametC:OnThink()
	-- Permanent 100% full map vision
	AddFOWViewer(DOTA_TEAM_GOODGUYS, Vector(0, 0, 0), 20000, 1.5, false)
	AddFOWViewer(DOTA_TEAM_BADGUYS, Vector(0, 0, 0), 20000, 1.5, false)

	-- Proximity check for courier item hand-off to hero
	for playerId, courier in pairs(self.playerCouriers) do
		local hero = self.playerHeroes[playerId]
		if courier and hero and not courier:IsNull() and not hero:IsNull() and hero:IsAlive() and courier:IsAlive() then
			local dist = (courier:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D()
			if dist <= 320 then
				self:TransferCourierToHero(courier, hero)
			end
		end
	end

	-- Ensure each hero has a configured courier
	for playerId, hero in pairs(self.playerHeroes) do
		if hero and not hero:IsNull() and hero:IsAlive() and not self.playerCouriers[playerId] then
			local spawnPos = hero:GetAbsOrigin() + Vector(120, 0, 0)
			local courier = hero:SpawnCourierAtPosition(spawnPos)
			if courier and not courier:IsNull() then
				self:ConfigureCourier(courier, playerId)
			end
		end
	end

	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
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
		if not playerId or playerId < 0 then
			playerId = 0
		end
		self:ConfigureCourier(spawnedUnit, playerId)
	end
end
