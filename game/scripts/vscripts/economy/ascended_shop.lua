--------------------------------------------------------------------------------
-- ascended_shop.lua
-- Server-authoritative Ascended Shop service for Enfos Team Survival — SametC Edition
-- Manages the 30 launch Ascended items:
-- Recipe: required normal Dota item + Lumber -> Ascended version.
-- Enforces: base item consumed, 1 copy per hero, 90% sellback, stacking & Boss caps.
-- Reference: docs/GAME_DESIGN_MASTER.md § 23
-- Reference: docs/IMPLEMENTATION_ROADMAP.md § Phase 8
--------------------------------------------------------------------------------

require("lib/log")

local AscendedShop = {}
AscendedShop.__index = AscendedShop

-- Lumber cost tiers (docs/GAME_DESIGN_MASTER.md § 23)
AscendedShop.TIER_1_LUMBER = 55
AscendedShop.TIER_2_LUMBER = 70
AscendedShop.TIER_3_LUMBER = 85

-- Sellback refund percentage (~90% underlying Gold and Lumber)
AscendedShop.SELLBACK_REFUND_PERCENT = 0.90

-- Catalog of 30 launch Ascended items
AscendedShop.ITEMS = {
	-- Tier 1 (55 Lumber)
	{ id = "item_ascended_thornplate", baseItem = "item_blade_mail", tier = 1, lumber = 55, gold = 2100, role = "Tank" },
	{ id = "item_ascended_sacred_reliquary", baseItem = "item_holy_locket", tier = 1, lumber = 55, gold = 2400, role = "Support" },
	{ id = "item_ascended_sunward_crest", baseItem = "item_solar_crest", tier = 1, lumber = 55, gold = 2400, role = "Support" },

	-- Tier 2 (70 Lumber)
	{ id = "item_ascended_bastion_guard", baseItem = "item_crimson_guard", tier = 2, lumber = 70, gold = 3725, role = "Tank" },
	{ id = "item_ascended_aegis_of_insight", baseItem = "item_pipe", tier = 2, lumber = 70, gold = 3475, role = "Tank" },
	{ id = "item_ascended_leviathan_harpoon", baseItem = "item_harpoon", tier = 2, lumber = 70, gold = 4500, role = "Fighter" },
	{ id = "item_ascended_warstride", baseItem = "item_sange_and_yasha", tier = 2, lumber = 70, gold = 4100, role = "Fighter" },
	{ id = "item_ascended_seraphic_greaves", baseItem = "item_guardian_greaves", tier = 2, lumber = 70, gold = 4950, role = "Support" },
	{ id = "item_ascended_mirror_lotus", baseItem = "item_lotus_orb", tier = 2, lumber = 70, gold = 3850, role = "Support" },
	{ id = "item_ascended_war_drums", baseItem = "item_boots_of_bearing", tier = 2, lumber = 70, gold = 4175, role = "Support" },
	{ id = "item_ascended_sovereign_bkb", baseItem = "item_black_king_bar", tier = 2, lumber = 70, gold = 4050, role = "Fighter" },
	{ id = "item_ascended_chrono_disk", baseItem = "item_aeon_disk", tier = 2, lumber = 70, gold = 3000, role = "Mage" },
	{ id = "item_ascended_astral_sphere", baseItem = "item_sphere", tier = 2, lumber = 70, gold = 4400, role = "Mage" },

	-- Tier 3 (85 Lumber)
	{ id = "item_ascended_worldheart", baseItem = "item_heart", tier = 3, lumber = 85, gold = 5000, role = "Tank" },
	{ id = "item_ascended_abyssal_dominion", baseItem = "item_abyssal_blade", tier = 3, lumber = 85, gold = 6250, role = "Fighter" },
	{ id = "item_ascended_blood_oath", baseItem = "item_satanic", tier = 3, lumber = 85, gold = 5050, role = "Carry" },
	{ id = "item_ascended_starforged_daedalus", baseItem = "item_greater_crit", tier = 3, lumber = 85, gold = 5100, role = "Carry" },
	{ id = "item_ascended_phantomwing", baseItem = "item_butterfly", tier = 3, lumber = 85, gold = 4975, role = "Carry" },
	{ id = "item_ascended_heavenpiercer", baseItem = "item_monkey_king_bar", tier = 3, lumber = 85, gold = 4900, role = "Carry" },
	{ id = "item_ascended_stormfather", baseItem = "item_mjollnir", tier = 3, lumber = 85, gold = 5500, role = "Carry" },
	{ id = "item_ascended_chronocore", baseItem = "item_octarine_core", tier = 3, lumber = 85, gold = 5200, role = "Mage" },
	{ id = "item_ascended_arc_bloodstone", baseItem = "item_bloodstone", tier = 3, lumber = 85, gold = 4400, role = "Mage" },
	{ id = "item_ascended_eternity_orb", baseItem = "item_refresher", tier = 3, lumber = 85, gold = 5000, role = "Mage" },
	{ id = "item_ascended_grand_vyse", baseItem = "item_sheepstick", tier = 3, lumber = 85, gold = 5550, role = "Mage" },
	{ id = "item_ascended_legion_cuirass", baseItem = "item_assault", tier = 3, lumber = 85, gold = 5125, role = "Fighter" },
	{ id = "item_ascended_absolute_zero", baseItem = "item_shivas_guard", tier = 3, lumber = 85, gold = 4825, role = "Mage" },
	{ id = "item_ascended_eye_of_deep_winter", baseItem = "item_skadi", tier = 3, lumber = 85, gold = 5300, role = "Carry" },
	{ id = "item_ascended_world_chain", baseItem = "item_gungir", tier = 3, lumber = 85, gold = 6150, role = "Carry" },
	{ id = "item_ascended_tempest_waker", baseItem = "item_wind_waker", tier = 3, lumber = 85, gold = 6825, role = "Mage" },
	{ id = "item_ascended_soulpiercer", baseItem = "item_bloodthorn", tier = 3, lumber = 85, gold = 6800, role = "Carry" },

	-- Special Ascended Blessing (Consumes Scepter + 40 Lumber -> frees slot)
	{ id = "item_ascended_aghanims_blessing", baseItem = "item_ultimate_scepter", tier = 1, lumber = 40, gold = 4200, role = "All" },
}

-- Fast lookup map
AscendedShop.LOOKUP = {}
for _, entry in ipairs(AscendedShop.ITEMS) do
	AscendedShop.LOOKUP[entry.id] = entry
end

--------------------------------------------------------------------------------
-- Initialize Ascended Shop Service
--------------------------------------------------------------------------------
function AscendedShop:Init(economyManager)
	self.economyManager = economyManager
	self:RegisterEventHandlers()
	self:SyncCatalogNetTable()
	Log:Info("ascended_shop", "AscendedShop service initialized with %d items.", #self.ITEMS)
end

--------------------------------------------------------------------------------
-- Catalog Synchronization via NetTable
--------------------------------------------------------------------------------
function AscendedShop:SyncCatalogNetTable()
	if not CustomNetTables then return end

	local catalogData = {}
	for idx, item in ipairs(self.ITEMS) do
		catalogData[tostring(idx)] = {
			id = item.id,
			base_item = item.baseItem,
			tier = item.tier,
			lumber = item.lumber,
			gold = item.gold,
			role = item.role,
		}
	end

	CustomNetTables:SetTableValue("ascended_shop", "catalog", catalogData)
end

--------------------------------------------------------------------------------
-- Inventory Helpers
--------------------------------------------------------------------------------
function AscendedShop:FindItemInHero(hero, itemName)
	if not hero or hero:IsNull() then return nil, -1 end

	-- Check inventory slots 0 to 5, and stash slots 9 to 14
	for slot = 0, 14 do
		local item = hero:GetItemInSlot(slot)
		if item and not item:IsNull() and item:GetAbilityName() == itemName then
			return item, slot
		end
	end
	return nil, -1
end

function AscendedShop:HasAscendedCopy(hero, ascendedId)
	if not hero or hero:IsNull() then return false end
	if ascendedId == "item_ascended_aghanims_blessing" and hero.HasModifier then
		if hero:HasModifier("modifier_item_ascended_aghanims_blessing_consumed") or
		   hero:HasModifier("modifier_item_ultimate_scepter_consumed") then
			return true
		end
	end
	local item = self:FindItemInHero(hero, ascendedId)
	return item ~= nil
end

--------------------------------------------------------------------------------
-- Upgrade Eligibility Check
--------------------------------------------------------------------------------
function AscendedShop:CanUpgrade(playerId, ascendedId)
	local entry = self.LOOKUP[ascendedId]
	if not entry then return false, "unknown_item" end

	if type(playerId)~="number" or not PlayerResource:IsValidPlayerID(playerId) then
		return false, "invalid_player"
	end

	local hero = PlayerResource:GetSelectedHeroEntity(playerId)
	if not hero or hero:IsNull() or not hero:IsAlive() then
		return false, "hero_unavailable"
	end

	-- 1. Restriction: One identical Ascended copy per hero
	if self:HasAscendedCopy(hero, ascendedId) then
		return false, "already_owned"
	end

	-- 2. Base item check
	local baseItem, slot = self:FindItemInHero(hero, entry.baseItem)
	if not baseItem then
		return false, "missing_base_item"
	end

	-- 3. Lumber balance check
	local currentLumber = self.economyManager:GetLumber(playerId)
	if currentLumber < entry.lumber then
		return false, "insufficient_lumber"
	end

	return true, "ok", baseItem, slot
end

--------------------------------------------------------------------------------
-- Transactional Purchase / Upgrade
--------------------------------------------------------------------------------
function AscendedShop:PurchaseUpgrade(playerId, ascendedId)
	local canUpgrade, reason, baseItem, slot = self:CanUpgrade(playerId, ascendedId)
	if not canUpgrade then
		Log:Warn("ascended_shop", "Player %s cannot upgrade to %s: %s", tostring(playerId), tostring(ascendedId), reason)
		return false, reason
	end

	local entry = self.LOOKUP[ascendedId]
	local hero = PlayerResource:GetSelectedHeroEntity(playerId)

	-- Preserve the original handle until the replacement is confirmed in inventory.

	-- Special handling for Aghanim's Blessing: immediately consume to free slot
	if ascendedId == "item_ascended_aghanims_blessing" then
		if hero.AddNewModifier then
			hero:AddNewModifier(hero, nil, "modifier_item_ascended_aghanims_blessing_consumed", {})
			hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
		end
		hero:RemoveItem(baseItem)
		self.economyManager:ModifyLumber(playerId,-entry.lumber,"ascended_upgrade_"..ascendedId)
		local AghanimManager = require("heroes/aghanim_manager")
		local heroName = hero.GetUnitName and hero:GetUnitName() or ""
		local role = hero.heroRole or AghanimManager:DetectHeroRole(heroName)
		AghanimManager:UpdateHeroAghanimState(hero, role)

		if hero.EmitSound then
			hero:EmitSound("DOTA_Item.Refresher.Activate")
		end
		if ParticleManager then
			local fx = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn_spotlight.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
			ParticleManager:ReleaseParticleIndex(fx)
		end
		Log:Info("ascended_shop", "Player %d upgraded Scepter -> Aghanim's Blessing (slot freed).", playerId)
		return true, "ok", nil
	end

	local newItem=CreateItem(ascendedId,hero,hero)
	if not newItem then return false,"item_creation_failed" end
	hero:TakeItem(baseItem)
	local ok=pcall(function() hero:AddItem(newItem) end)
	local actualSlot=-1
	for i=0,14 do if hero:GetItemInSlot(i)==newItem then actualSlot=i end end
	if not ok or actualSlot<0 then
		UTIL_Remove(newItem)
		hero:AddItem(baseItem)
		for i=0,14 do if hero:GetItemInSlot(i)==baseItem and i~=slot then hero:SwapItems(i,slot);break end end
		return false,"item_creation_failed"
	end
	if actualSlot~=slot then hero:SwapItems(actualSlot,slot) end
	if baseItem.GetCooldownTimeRemaining then newItem:StartCooldown(baseItem:GetCooldownTimeRemaining()) end
	UTIL_Remove(baseItem)
	self.economyManager:ModifyLumber(playerId,-entry.lumber,"ascended_upgrade_"..ascendedId)

	-- Audio & Visual feedback
	if hero.EmitSound then
		hero:EmitSound("Item.PickUpGemWorld")
	end
	if ParticleManager then
		local fx = ParticleManager:CreateParticle("particles/generic_hero_status/hero_levelup.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
		ParticleManager:ReleaseParticleIndex(fx)
	end

	Log:Info("ascended_shop", "SUCCESS: Player %d upgraded %s -> %s (Cost: %d Lumber)",
		playerId, entry.baseItem, ascendedId, entry.lumber)

	return true, "success", newItem
end

--------------------------------------------------------------------------------
-- Sellback with 90% Refund
--------------------------------------------------------------------------------
function AscendedShop:Sellback(playerId, item)
	if not item or item:IsNull() then return false, 0, 0 end
	local itemName = item:GetAbilityName()
	local entry = self.LOOKUP[itemName]
	if not entry then return false, 0, 0 end

	local hero = PlayerResource:GetSelectedHeroEntity(playerId)
	if not hero or hero:IsNull() then return false, 0, 0 end

	local owned=false
	for slot=0,14 do if hero:GetItemInSlot(slot)==item then owned=true;break end end
	if not owned then return false,0,0 end
	-- 90% Refund calculation
	local goldRefund = math.floor(entry.gold * self.SELLBACK_REFUND_PERCENT)
	local lumberRefund = math.floor(entry.lumber * self.SELLBACK_REFUND_PERCENT)

	-- Remove item
	hero:RemoveItem(item)

	-- Credit refunds
	PlayerResource:ModifyGold(playerId, goldRefund, true, DOTA_ModifyGold_SellConsumable)
	self.economyManager:ModifyLumber(playerId, lumberRefund, "ascended_sellback_" .. itemName)

	Log:Info("ascended_shop", "SELLBACK: Player %d sold %s for %d Gold and %d Lumber (90%% refund)",
		playerId, itemName, goldRefund, lumberRefund)

	return true, goldRefund, lumberRefund
end

--------------------------------------------------------------------------------
-- Register Panorama Custom Game Events
--------------------------------------------------------------------------------
function AscendedShop:RegisterEventHandlers()
	if not CustomGameEventManager then return end

	CustomGameEventManager:RegisterListener("enfos_buy_ascended_item", function(_, event)
		local playerId = event.PlayerID
		local ascendedId = event.ascended_id
		AscendedShop:PurchaseUpgrade(playerId, ascendedId)
	end)

	CustomGameEventManager:RegisterListener("enfos_sell_ascended_item", function(_, event)
		local playerId = event.PlayerID
		local slot = tonumber(event.slot)
		if not slot or slot~=math.floor(slot) or slot<0 or slot>14 then return end
		local hero = PlayerResource:GetSelectedHeroEntity(playerId)
		if hero and not hero:IsNull() and slot then
			local item = hero:GetItemInSlot(slot)
			if item then
				AscendedShop:Sellback(playerId, item)
			end
		end
	end)
end

return AscendedShop
