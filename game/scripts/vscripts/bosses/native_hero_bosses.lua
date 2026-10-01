-- Native roster-hero Boss setup and low-frequency ability/item AI.
-- Data sources are the currently mounted Valve hero KV and bot loadouts.

require("lib/log")

local NativeBosses = {}
NativeBosses.__index = NativeBosses

local MAX_HERO_LEVEL = 50
local THINK_INTERVAL = 0.4
local ENEMY_SEARCH_RADIUS = 1400

local function hasBehavior(ability, behaviorFlag)
	return bit and bit.band and behaviorFlag and bit.band(ability:GetBehaviorInt(), behaviorFlag) ~= 0
end

local function enableAutocast(ability)
	if hasBehavior(ability, DOTA_ABILITY_BEHAVIOR_AUTOCAST)
		and ability.GetAutoCastState and ability.ToggleAutoCast
		and not ability:GetAutoCastState() then
		ability:ToggleAutoCast()
	end
end

-- Ordered from the current Valve scripts/npc/bot_loadouts.txt core list. These
-- are the six inventory slots; shard/scepter entries stay in the list only
-- where they occur among the first six native core recommendations.
local BOT_CORE_ITEMS = {
	npc_dota_hero_sven = {"item_power_treads", "item_mask_of_madness", "item_harpoon", "item_blink", "item_black_king_bar", "item_greater_crit"},
	npc_dota_hero_axe = {"item_bracer", "item_phase_boots", "item_blade_mail", "item_blink", "item_black_king_bar", "item_aghanims_shard"},
	npc_dota_hero_juggernaut = {"item_bfury", "item_power_treads", "item_manta", "item_butterfly", "item_ultimate_scepter", "item_blink"},
	npc_dota_hero_drow_ranger = {"item_falcon_blade", "item_power_treads", "item_hurricane_pike", "item_manta", "item_aghanims_shard", "item_butterfly"},
	npc_dota_hero_lina = {"item_bottle", "item_travel_boots", "item_yasha_and_kaya", "item_ultimate_scepter", "item_blink", "item_ethereal_blade"},
	npc_dota_hero_omniknight = {"item_bracer", "item_phase_boots", "item_harpoon", "item_blink", "item_black_king_bar", "item_aghanims_shard"},
	npc_dota_hero_sniper = {"item_power_treads", "item_mjollnir", "item_hurricane_pike", "item_black_king_bar", "item_greater_crit", "item_satanic"},
	npc_dota_hero_crystal_maiden = {"item_tranquil_boots", "item_glimmer_cape", "item_aghanims_shard", "item_blink", "item_ultimate_scepter", "item_black_king_bar"},
	npc_dota_hero_dazzle = {"item_holy_locket", "item_guardian_greaves", "item_glimmer_cape", "item_aghanims_shard", "item_force_staff", "item_ultimate_scepter"},
	npc_dota_hero_witch_doctor = {"item_arcane_boots", "item_glimmer_cape", "item_aghanims_shard", "item_blink", "item_ultimate_scepter", "item_black_king_bar"},
	npc_dota_hero_luna = {"item_power_treads", "item_mask_of_madness", "item_manta", "item_ultimate_scepter", "item_black_king_bar", "item_butterfly"},
	npc_dota_hero_dragon_knight = {"item_power_treads", "item_mask_of_madness", "item_armlet", "item_blink", "item_black_king_bar", "item_greater_crit"},
}

local function heroRecord(heroName)
	if not LoadKeyValues then return nil end
	local file = LoadKeyValues("scripts/npc/heroes/" .. heroName .. ".txt")
	local heroes = file and (file.DOTAHeroes or file)
	return heroes and heroes[heroName] or nil
end

local function bossTemplate(templateName)
	if not templateName or not LoadKeyValues then return nil end
	local units = LoadKeyValues("scripts/npc/npc_units_custom.txt") or {}
	units = units.DOTAUnits or units
	return units[templateName]
end

local function playerTeamLevel(team)
	local total, count = 0, 0
	if PlayerResource then
		for playerID = 0, (DOTA_MAX_TEAM_PLAYERS or 24) - 1 do
			if PlayerResource:IsValidPlayerID(playerID) and PlayerResource:GetTeam(playerID) == team then
				local hero = PlayerResource:GetSelectedHeroEntity(playerID)
				local connection = PlayerResource.GetConnectionState and PlayerResource:GetConnectionState(playerID)
				local abandoned = connection == (DOTA_CONNECTION_STATE_ABANDONED or 4)
				local active = connection == nil or connection == (DOTA_CONNECTION_STATE_CONNECTED or 2) or hero ~= nil
				if not abandoned and active and hero and not hero:IsNull() and hero:IsAlive() then
					total = total + hero:GetLevel()
					count = count + 1
				end
			end
		end
	end
	return count > 0 and math.floor(total / count + 0.5) or 6
end

local function itemCountForLevel(level)
	-- 1 item at the level-6 start; the sixth arrives only at the level-50 cap.
	return math.min(6, 1 + math.floor(math.max(0, level - 6) * 5 / 44))
end

local function nativeKit(hero)
	local entries, seen = {}, {}
	for key, name in pairs(hero.AbilityDraftAbilities or {}) do
		local slot = tonumber(tostring(key):match("^Ability(%d+)$"))
		if slot and type(name) == "string" and name ~= "" and not seen[name] then
			entries[#entries + 1] = { slot = slot, name = name }
			seen[name] = true
		end
	end
	-- Ability Draft is not always a four-entry contiguous QWER list: Lina's
	-- ultimate uses Ability6; CM omits Brilliance Aura. Restore only a missing
	-- native hero slot actually trained by Valve's bot build, never a guessed
	-- ability or an untrained Scepter/innate helper.
	if #entries < 4 then
		local trained = {}
		for _, name in pairs(hero.Bot and hero.Bot.Build or {}) do trained[name] = true end
		for slot = 1, 9 do
			local name = hero["Ability" .. slot]
			if type(name) == "string" and trained[name] and not seen[name] then
				entries[#entries + 1] = { slot = slot, name = name }
				seen[name] = true
			end
		end
	end
	-- Use native hero slot ordering when available; Draft can compact slots.
	for _, entry in ipairs(entries) do
		for slot = 1, 9 do
			if hero["Ability" .. slot] == entry.name then entry.slot = slot; break end
		end
	end
	table.sort(entries, function(a, b) return a.slot < b.slot end)
	if #entries ~= 4 then return nil end
	local names = {}
	for slot, entry in ipairs(entries) do names[slot] = entry.name end
	return names
end

function NativeBosses:Prepare(unit, heroName, waveNumber, defendingTeam, rewardTemplateName)
	if not unit or unit:IsNull() or not unit:IsHero() then
		Log:Error("boss_framework", "Native Boss creation failed: %s is not a hero", tostring(heroName))
		return false
	end

	local hero = heroRecord(heroName)
	local abilityNames = hero and nativeKit(hero)
	if not abilityNames then
		Log:Error("boss_framework", "Valve hero KV/QWER unavailable for Boss %s", tostring(heroName))
		return false
	end

	-- The custom-game hero KV replaces player abilities. Remove that kit and
	-- rebuild native QWER using Draft/native slots and bot-trained omissions.
	local remove = {}
	for index = 0, unit:GetAbilityCount() - 1 do
		local ability = unit:GetAbilityByIndex(index)
		if ability and not ability:IsNull() then
			remove[#remove + 1] = ability:GetAbilityName()
		end
	end
	for _, name in ipairs(remove) do unit:RemoveAbility(name) end

	for slot = 1, 4 do
		local abilityName = abilityNames[slot]
		local ability = unit:AddAbility(abilityName)
		if not ability or ability:IsNull() then
			Log:Error("boss_framework", "Could not add native ability %s to %s", abilityName, heroName)
			return false
		end
		abilityNames[slot] = abilityName
	end

	local targetLevel = math.max(1, math.min(MAX_HERO_LEVEL,
		waveNumber >= 60 and MAX_HERO_LEVEL or playerTeamLevel(defendingTeam)))
	while unit:GetLevel() < targetLevel do unit:HeroLevelUp(false) end
	unit:SetAbilityPoints(0)

	-- Native Valve bot skill build, including its level order. Talent entries are
	-- absent because Bosses receive exactly the native four QWER abilities.
	local build = hero.Bot and hero.Bot.Build or {}
	local spentRanks = 0
	for level = 1, targetLevel do
		local choice = build[tostring(level)] or build[level]
		local ability = type(choice) == "string" and unit:FindAbilityByName(choice) or nil
		if ability and not ability:IsNull() then
			local maxLevel = ability:GetMaxLevel()
			if ability:GetLevel() < maxLevel then
				ability:SetLevel(ability:GetLevel() + 1)
				spentRanks = spentRanks + 1
			end
		end
	end
	-- Current Valve bot builds can still train omitted talents or an old core
	-- slot (Luna's build omits Lunar Orbit). Spend only their unused budget on
	-- the verified current kit, respecting native rank caps and hero-level gates.
	local remainingRanks = math.max(0, targetLevel - spentRanks)
	while remainingRanks > 0 do
		local upgraded = false
		for _, name in ipairs(abilityNames) do
			local ability = unit:FindAbilityByName(name)
			if remainingRanks > 0 and ability and not ability:IsNull()
				and ability:GetLevel() < ability:GetMaxLevel()
				and (not ability.GetHeroLevelRequiredToUpgrade
					or ability:GetHeroLevelRequiredToUpgrade() <= targetLevel) then
				ability:SetLevel(ability:GetLevel() + 1)
				remainingRanks = remainingRanks - 1
				upgraded = true
			end
		end
		if not upgraded then break end
	end
	unit:SetAbilityPoints(0)
	for _, name in ipairs(abilityNames) do
		local ability = unit:FindAbilityByName(name)
		if ability and not ability:IsNull() then enableAutocast(ability) end
	end

	-- The legacy themed unit remains a wave-authored durability/damage floor.
	-- Native hero levels and items add on top; this preserves the existing Boss
	-- curve while changing its identity and skills to a roster hero.
	local template = bossTemplate(rewardTemplateName)
	if template then
		local minHealth = tonumber(template.StatusHealth) or 0
		if minHealth > unit:GetMaxHealth() then
			unit:SetBaseMaxHealth(minHealth)
			unit:SetMaxHealth(minHealth)
			unit:SetHealth(minHealth)
		end
		local minDamage = tonumber(template.AttackDamageMin) or 0
		local maxDamage = tonumber(template.AttackDamageMax) or minDamage
		if minDamage > unit:GetBaseDamageMin() then unit:SetBaseDamageMin(minDamage) end
		if maxDamage > unit:GetBaseDamageMax() then unit:SetBaseDamageMax(maxDamage) end
	end

	local items = BOT_CORE_ITEMS[heroName] or {}
	local count = waveNumber >= 60 and 6 or itemCountForLevel(targetLevel)
	for index = 1, count do
		local itemName = items[index]
		if itemName then
			local item = unit:AddItemByName(itemName)
			if not item then Log:Warn("boss_framework", "Valve Boss build item unavailable: %s", itemName) end
		end
	end

	unit.nativeBossHero = heroName
	unit.bossRewardName = rewardTemplateName
	unit.bossDefendingTeam = defendingTeam
	unit.bossAbilityNames = abilityNames
	unit.isBoss = true
	Log:Info("boss_framework", "Prepared native Boss %s at level %d with %d Valve core items for wave %d",
		heroName, targetLevel, count, waveNumber)
	return true
end

local function nearbyDefenders(unit, state, ability)
	local targetTeam = ability.GetAbilityTargetTeam and ability:GetAbilityTargetTeam() or DOTA_UNIT_TARGET_TEAM_ENEMY
	if targetTeam == DOTA_UNIT_TARGET_TEAM_FRIENDLY then return { unit } end
	local targetType = ability.GetAbilityTargetType and ability:GetAbilityTargetType()
	if not targetType or targetType == 0 then targetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
	local castRange = ability.GetCastRange and ability:GetCastRange(unit:GetAbsOrigin(), nil) or 0
	local searchRadius = castRange > 0 and math.min(ENEMY_SEARCH_RADIUS, castRange + 96) or ENEMY_SEARCH_RADIUS
	local targetFlags = ability.GetAbilityTargetFlags and ability:GetAbilityTargetFlags() or DOTA_UNIT_TARGET_FLAG_NONE
	if bit and bit.bor then targetFlags = bit.bor(targetFlags, DOTA_UNIT_TARGET_FLAG_NO_INVIS or DOTA_UNIT_TARGET_FLAG_NONE) end
	-- Boss heroes are engine-neutral (team 4), so ENEMY-relative unit searches
	-- can return inconsistently. Search as the defended player team for FRIENDLY
	-- units, then keep only that team's heroes/units before issuing native orders.
	local found = FindUnitsInRadius(state.defendingTeam, unit:GetAbsOrigin(), nil, searchRadius,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY, targetType, targetFlags,
		FIND_CLOSEST, false) or {}
	local defenders = {}
	for _, target in ipairs(found) do
		if target and not target:IsNull() and target:IsAlive()
			and target:GetTeamNumber() == state.defendingTeam
			and (castRange <= 0 or (target:GetAbsOrigin() - unit:GetAbsOrigin()):Length2D() <= searchRadius) then
			defenders[#defenders + 1] = target
		end
	end
	return defenders
end

local function issueCast(unit, ability, orderType, target)
	local order = {
		UnitIndex = unit:entindex(),
		OrderType = orderType,
		AbilityIndex = ability:entindex(),
		Queue = false,
	}
	if orderType == DOTA_UNIT_ORDER_CAST_TARGET then order.TargetIndex = target:entindex() end
	if orderType == DOTA_UNIT_ORDER_CAST_POSITION then order.Position = target:GetAbsOrigin() end
	ExecuteOrderFromTable(order)
	return true
end

local function tryAbility(unit, state, ability)
	if not ability or ability:IsNull() or ability:IsHidden() or ability:IsPassive()
		or ability:GetLevel() <= 0 or not ability:IsActivated() or not ability:IsFullyCastable()
		or (ability.IsInAbilityPhase and ability:IsInAbilityPhase()) then return false end
	local behavior = ability:GetBehaviorInt()
	if hasBehavior(ability, DOTA_ABILITY_BEHAVIOR_AUTOCAST) then
		enableAutocast(ability)
		return false -- Auto-cast + attack-behavior skills ride the lane attack order.
	end
	if hasBehavior(ability, DOTA_ABILITY_BEHAVIOR_TOGGLE) then return false end

	if hasBehavior(ability, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) then
		local targets = nearbyDefenders(unit, state, ability)
		local target = targets[1]
		if target then return issueCast(unit, ability, DOTA_UNIT_ORDER_CAST_TARGET, target) end
	end
	if hasBehavior(ability, DOTA_ABILITY_BEHAVIOR_POINT) then
		local targets = nearbyDefenders(unit, state, ability)
		local target = targets[1]
		if target then return issueCast(unit, ability, DOTA_UNIT_ORDER_CAST_POSITION, target) end
	end
	if hasBehavior(ability, DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
		local targetTeam = ability.GetAbilityTargetTeam and ability:GetAbilityTargetTeam() or DOTA_UNIT_TARGET_TEAM_NONE
		if targetTeam == DOTA_UNIT_TARGET_TEAM_ENEMY and #nearbyDefenders(unit, state, ability) == 0 then return false end
		return issueCast(unit, ability, DOTA_UNIT_ORDER_CAST_NO_TARGET)
	end
	return false
end

local function tryItem(unit, state, slot)
	local item = unit:GetItemInSlot(slot)
	if not item or item:IsNull() or not item:IsFullyCastable() then return false end
	-- Treads' native no-target action changes its attribute without a cooldown.
	-- Repeating it every think starves every later inventory slot. Keep its
	-- spawn attribute instead of treating an attribute switch as a combat spell.
	if item:GetAbilityName() == "item_power_treads" then return false end
	local behavior = item:GetBehaviorInt()
	-- The native DK build includes Armlet. Enable once in combat and disable
	-- once when no defenders are nearby; never alternate it every think.
	if item:GetAbilityName() == "item_armlet"
		and hasBehavior(item, DOTA_ABILITY_BEHAVIOR_TOGGLE) then
		local shouldEnable = #nearbyDefenders(unit, state, item) > 0
		if item:GetToggleState() ~= shouldEnable then
			return issueCast(unit, item, DOTA_UNIT_ORDER_CAST_NO_TARGET)
		end
		return false
	end
	if hasBehavior(item, DOTA_ABILITY_BEHAVIOR_AUTOCAST)
		or hasBehavior(item, DOTA_ABILITY_BEHAVIOR_TOGGLE) then return false end
	if hasBehavior(item, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) then
		local target = nearbyDefenders(unit, state, item)[1]
		if target then return issueCast(unit, item, DOTA_UNIT_ORDER_CAST_TARGET, target) end
	end
	if hasBehavior(item, DOTA_ABILITY_BEHAVIOR_POINT) then
		local target = nearbyDefenders(unit, state, item)[1]
		if target then return issueCast(unit, item, DOTA_UNIT_ORDER_CAST_POSITION, target) end
	end
	if hasBehavior(item, DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
		return issueCast(unit, item, DOTA_UNIT_ORDER_CAST_NO_TARGET)
	end
	return false
end

function NativeBosses:Think(unit, state)
	if not unit or unit:IsNull() or not unit:IsAlive() then return nil end
	if GameRules and GameRules.IsGamePaused and GameRules:IsGamePaused() then return THINK_INTERVAL end
	if unit:IsStunned() or unit:IsChanneling() then return THINK_INTERVAL end
	-- Checking only the candidate spell's phase allowed a later slot or item
	-- to replace the already-started spell with another nonqueued order.
	local activeAbility = unit.GetCurrentActiveAbility and unit:GetCurrentActiveAbility()
	if activeAbility and not activeAbility:IsNull() and activeAbility:IsInAbilityPhase() then
		return THINK_INTERVAL
	end

	if not unit:IsSilenced() then
		for slot = 0, 3 do
			local ability = unit:GetAbilityByIndex(slot)
			if tryAbility(unit, state, ability) then return THINK_INTERVAL end
		end
	end
	-- Silence blocks spells, not item actives; item mute is a separate state.
	if not (unit.IsMuted and unit:IsMuted()) then
		for slot = 0, 5 do
			if tryItem(unit, state, slot) then return THINK_INTERVAL end
		end
	end
	return THINK_INTERVAL
end

return NativeBosses
