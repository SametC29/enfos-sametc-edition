-- Enfos Team Survival — SametC Edition
-- Aghanim's Shard & Aghanim's Scepter System (GAME_DESIGN_MASTER.md § 16, § 23)
-- Server-authoritative mechanics evolution for all 40 heroes across 5 roles.
-- Shard: smaller mechanic evolution + role empowerment.
-- Scepter: major ultimate evolution + wave-clear & boss shredding.
-- Aghanim's Blessing: consumes Scepter + Lumber, frees inventory slot while retaining Scepter.

local Log = require("lib/log")
local HeroTrace = require("lib/hero_trace")

if LinkLuaModifier then
	LinkLuaModifier("modifier_enfos_scepter_upgrade", "heroes/aghanim_manager", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_enfos_shard_upgrade", "heroes/aghanim_manager", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_enfos_shard_slow", "heroes/aghanim_manager", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_item_ascended_aghanims_blessing_consumed", "heroes/aghanim_manager", LUA_MODIFIER_MOTION_NONE)
end

local AghanimManager = {
	initialized = false,
	activeScepters = {}, -- [heroEntIndex] = true
	activeShards = {},   -- [heroEntIndex] = true
}

-- 40-Hero Role Mapping
AghanimManager.HERO_ROLES = {}
for _, hero in ipairs(require("heroes/roster")) do AghanimManager.HERO_ROLES[hero.id] = hero.role end

-- Role-based Aghanim Shard Configuration
AghanimManager.SHARD_ROLE_BUFFS = {
	Tank = {
		bonus_hp = 350,
		damage_reflect_pct = 15,
		name = "Çelik Dikenler / Iron Thorns",
	},
	Fighter = {
		bonus_as = 35,
		attack_slow_pct = 25,
		duration = 3.0,
		name = "Savaş Şevki / Battle Drive",
	},
	Carry = {
		bonus_ms_pct = 15,
		pure_damage_pct = 12,
		name = "Hassas Delme / Precision Pierce",
	},
	Mage = {
		spell_amp = 15,
		mana_restore_pct = 5,
		name = "Ark Taşkını / Arc Surge",
	},
	Support = {
		heal_amp_pct = 25,
		pulse_heal = 200,
		name = "Semavi Şifa / Seraphic Grace",
	},
}

-- Scepter Major Evolutions
AghanimManager.SCEPTER_BONUSES = {
	ult_damage_amp_pct = 40,
	ult_cdr_pct = 25,
	bonus_all_stats = 10,
	bonus_hp = 175,
	bonus_mana = 175,
}

function AghanimManager:DetectHeroRole(heroName)
	if not heroName then return "Tank" end
	return self.HERO_ROLES[heroName] or "Tank"
end

function AghanimManager:Init()
	if self.initialized then return end
	self.activeScepters = {}
	self.activeShards = {}
	self.initialized = true

	Log:Info("aghanim_manager", "AghanimManager initialized successfully.")

	if GameRules and GameRules.GetGameModeEntity and GameRules:GetGameModeEntity() then
		GameRules:GetGameModeEntity():SetContextThink("AghanimManagerPeriodicThink", function()
			if PlayerResource then
				for playerId = 0, (DOTA_MAX_TEAM_PLAYERS or 24)-1 do
					local hero = PlayerResource:GetSelectedHeroEntity(playerId)
					if hero and not hero:IsNull() and hero:IsAlive() then
						local heroName = hero.GetUnitName and hero:GetUnitName() or ""
						local role = hero.heroRole or self:DetectHeroRole(heroName)
						self:UpdateHeroAghanimState(hero, role)
					end
				end
			end
			return 1.0
		end, 1.0)
	end
end

function AghanimManager:HasScepter(hero)
	if not hero or (hero.IsNull and hero:IsNull()) then return false end

	if hero.HasScepter and hero:HasScepter() then
		return true
	end

	if hero.HasModifier then
		if hero:HasModifier("modifier_item_ultimate_scepter_consumed") or
		   hero:HasModifier("modifier_item_ascended_aghanims_blessing_passive") or
		   hero:HasModifier("modifier_item_ascended_aghanims_blessing_consumed") or
		   hero:HasModifier("modifier_ultimate_scepter_consumed") then
			return true
		end
	end

	if hero.HasItemInInventory and hero:HasItemInInventory("item_ultimate_scepter") then
		return true
	end

	return false
end

function AghanimManager:HasShard(hero)
	if not hero or (hero.IsNull and hero:IsNull()) then return false end

	if hero.HasModifier then
		-- Installed native localization identifies this permanent Shard buff.
		-- Introduce the compatibility branch only for the hero under review.
		if hero.GetUnitName and (hero:GetUnitName()=="npc_dota_hero_lich" or hero:GetUnitName()=="npc_dota_hero_vengefulspirit" or hero:GetUnitName()=="npc_dota_hero_jakiro")
			and hero:HasModifier("modifier_item_aghanims_shard_permanent_buff") then return true end
		if hero:HasModifier("modifier_item_aghanims_shard_consumed") or
		   hero:HasModifier("modifier_aghanims_shard_consumed") then
			return true
		end
	end

	if hero.HasItemInInventory and hero:HasItemInInventory("item_aghanims_shard") then
		return true
	end

	return false
end

function AghanimManager:UpdateHeroAghanimState(hero, role)
	if not hero or (hero.IsNull and hero:IsNull()) then return end

	local entIndex = hero.GetEntityIndex and hero:GetEntityIndex() or tostring(hero)
	local hasScepter = self:HasScepter(hero)
	local hasShard = self:HasShard(hero)
	local assignedRole = role or (hero.GetUnitName and self:DetectHeroRole(hero:GetUnitName())) or "Tank"
	if hero.GetUnitName and hero:GetUnitName()=="npc_dota_hero_vengefulspirit" then
		require('abilities/heroes/vengefulspirit/upgrades').Reconcile(hero, hasScepter)
	end

	-- Check Scepter activation
	if hasScepter and not self.activeScepters[entIndex] then
		self.activeScepters[entIndex] = true
		self:OnScepterAcquired(hero, assignedRole)
	elseif not hasScepter and self.activeScepters[entIndex] then
		self.activeScepters[entIndex] = nil
		self:OnScepterLost(hero)
	end

	-- Check Shard activation
	if hasShard and not self.activeShards[entIndex] then
		self.activeShards[entIndex] = true
		self:OnShardAcquired(hero, assignedRole)
	elseif not hasShard and self.activeShards[entIndex] then
		self.activeShards[entIndex] = nil
		self:OnShardLost(hero)
	elseif hasShard and hero.GetUnitName and hero:GetUnitName()=="npc_dota_hero_lich" then
		-- Existing periodic reconciliation also restores a missing/hidden extra slot
		-- after reload/reconnect without duplicating the ability or restarting casts.
		self:EnsureLichShardAbility(hero)
	end
end

function AghanimManager:EnsureLichShardAbility(hero)
	if not IsServer() or not hero or hero:IsNull() or not self:HasShard(hero) then return end
	local ability = hero:FindAbilityByName("enfos_lich_ice_spire")
	if ability and ability:IsNull() then ability=nil end
	if not ability then ability=hero:AddAbility("enfos_lich_ice_spire") end
	if not ability or ability:IsNull() then
		HeroTrace:Log('LICH','D','shard_ability_missing retry=existing_periodic_reconcile')
		return
	end
	local changed=false
	if ability:GetLevel()~=1 then ability:SetLevel(1);changed=true end
	if ability:IsHidden() then ability:SetHidden(false);changed=true end
	if not ability:IsActivated() then ability:SetActivated(true);changed=true end
	if changed then HeroTrace:Log('LICH','D','shard_ability_restored rank=1 visible=true activated=true') end
	return ability
end

function AghanimManager:OnScepterAcquired(hero, role)
	Log:Info("aghanim_manager", "Aghanim's Scepter activated on hero (Role: %s)", tostring(role))

	if hero.AddNewModifier then
		pcall(function()
			hero:AddNewModifier(hero, nil, "modifier_enfos_scepter_upgrade", {
				ult_amp = self.SCEPTER_BONUSES.ult_damage_amp_pct,
				ult_cdr = self.SCEPTER_BONUSES.ult_cdr_pct,
			})
		end)
	end
end

function AghanimManager:OnScepterLost(hero)
	Log:Info("aghanim_manager", "Aghanim's Scepter removed from hero.")
	if hero.RemoveModifierByName then
		hero:RemoveModifierByName("modifier_enfos_scepter_upgrade")
	end
end

function AghanimManager:OnShardAcquired(hero, role)
	local roleData = self.SHARD_ROLE_BUFFS[role] or self.SHARD_ROLE_BUFFS.Tank
	Log:Info("aghanim_manager", "Aghanim's Shard activated on hero (Role: %s - %s)", tostring(role), roleData.name)

	if hero.AddNewModifier then
		pcall(function()
			hero:AddNewModifier(hero, nil, "modifier_enfos_shard_upgrade", {
				role = role,
			})
		end)
	end
	if hero.GetUnitName and hero:GetUnitName() == "npc_dota_hero_witch_doctor" then
		local ability = hero.FindAbilityByName and hero:FindAbilityByName("enfos_wd_voodoo_switcheroo")
		if not ability and hero.AddAbility then ability = hero:AddAbility("enfos_wd_voodoo_switcheroo") end
		if ability then
			if ability.SetLevel then ability:SetLevel(1) end
			if ability.SetHidden then ability:SetHidden(false) end
			if ability.SetActivated then ability:SetActivated(true) end
		end
	end
	if hero.GetUnitName and hero:GetUnitName()=="npc_dota_hero_lich" then
		self:EnsureLichShardAbility(hero)
	end
end

function AghanimManager:OnShardLost(hero)
	Log:Info("aghanim_manager", "Aghanim's Shard removed from hero.")
	if hero.RemoveModifierByName then
		hero:RemoveModifierByName("modifier_enfos_shard_upgrade")
	end
	if hero.GetUnitName and hero:GetUnitName() == "npc_dota_hero_witch_doctor" then
		if hero.RemoveAbility then hero:RemoveAbility("enfos_wd_voodoo_switcheroo") end
	end
	if hero.GetUnitName and hero:GetUnitName()=="npc_dota_hero_lich" then
		require('abilities/heroes/lich/spire').Retire(hero, 'shard_lost')
		local ability=hero:FindAbilityByName("enfos_lich_ice_spire")
		if ability and not ability:IsNull() then
			ability:SetActivated(false);ability:SetHidden(true);ability:SetLevel(0)
		end
	end
end

--------------------------------------------------------------------------------
-- Modifiers
--------------------------------------------------------------------------------

-- Scepter Major Upgrade Modifier
modifier_enfos_scepter_upgrade = class({})
function modifier_enfos_scepter_upgrade:IsHidden()
    local parent = self.GetParent and self:GetParent()
    local name = parent and parent.GetUnitName and parent:GetUnitName()
    return name == "npc_dota_hero_vengefulspirit" or name == "npc_dota_hero_lich" or name == "npc_dota_hero_sven" or name == "npc_dota_hero_shadow_shaman" or name == "npc_dota_hero_tidehunter"
end
function modifier_enfos_scepter_upgrade:IsPurgable() return false end
function modifier_enfos_scepter_upgrade:IsPermanent() return true end
function modifier_enfos_scepter_upgrade:RemoveOnDeath() return false end
function modifier_enfos_scepter_upgrade:GetTexture() return "item_ultimate_scepter" end

function modifier_enfos_scepter_upgrade:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
	}
end
function modifier_enfos_scepter_upgrade:GetModifierSpellAmplify_Percentage(event)
    if self.GetParent and self:GetParent().GetUnitName and self:GetParent():GetUnitName()=="npc_dota_hero_vengefulspirit" then return 0 end
    if self.GetParent and self:GetParent().GetUnitName and self:GetParent():GetUnitName()=="npc_dota_hero_lich" then return 0 end
    if self.GetParent and self:GetParent().GetUnitName and self:GetParent():GetUnitName()=="npc_dota_hero_tidehunter" then return 0 end
    if self.GetParent and self:GetParent().GetUnitName and self:GetParent():GetUnitName()=="npc_dota_hero_sven" then return 0 end
    if self.GetParent and self:GetParent().GetUnitName and self:GetParent():GetUnitName()=="npc_dota_hero_shadow_shaman" then return 0 end
	local a=event and event.inflictor
	return a and a:GetAbilityType()==DOTA_ABILITY_TYPE_ULTIMATE and 40 or 0
end
function modifier_enfos_scepter_upgrade:GetModifierPercentageCooldown(event)
    if self.GetParent and self:GetParent().GetUnitName and self:GetParent():GetUnitName()=="npc_dota_hero_vengefulspirit" then return 0 end
    if self.GetParent and self:GetParent().GetUnitName and self:GetParent():GetUnitName()=="npc_dota_hero_lich" then return 0 end
    if self.GetParent and self:GetParent().GetUnitName and self:GetParent():GetUnitName()=="npc_dota_hero_tidehunter" then return 0 end
    if self.GetParent and self:GetParent().GetUnitName and self:GetParent():GetUnitName()=="npc_dota_hero_sven" then return 0 end
	local a=event and event.ability
	return a and a:GetAbilityType()==DOTA_ABILITY_TYPE_ULTIMATE and 25 or 0
end

-- Shard Role Upgrade Modifier
modifier_enfos_shard_upgrade = class({})
function modifier_enfos_shard_upgrade:IsHidden()
    local parent = self.GetParent and self:GetParent()
    local name = parent and parent.GetUnitName and parent:GetUnitName()
    return name == "npc_dota_hero_lich" or name == "npc_dota_hero_sven" or name == "npc_dota_hero_shadow_shaman" or name == "npc_dota_hero_tidehunter"
end
function modifier_enfos_shard_upgrade:IsPurgable() return false end
function modifier_enfos_shard_upgrade:IsPermanent() return true end
function modifier_enfos_shard_upgrade:RemoveOnDeath() return false end
function modifier_enfos_shard_upgrade:GetTexture() return "item_aghanims_shard" end

function modifier_enfos_shard_upgrade:OnCreated(kv)
	self.role = AghanimManager:DetectHeroRole(self:GetParent():GetUnitName())
	if kv and kv.role then
		self.role = kv.role
	end
end

function modifier_enfos_shard_upgrade:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_SOURCE,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_enfos_shard_upgrade:GetModifierHealthBonus()
    if self.GetParent and self:GetParent().GetUnitName and self:GetParent():GetUnitName()=="npc_dota_hero_tidehunter" then return 0 end
    if self.GetParent and self:GetParent().GetUnitName and self:GetParent():GetUnitName()=="npc_dota_hero_sven" then return 0 end
	if self.role == "Tank" then return 350 end
	return 0
end

function modifier_enfos_shard_upgrade:GetModifierAttackSpeedBonus_Constant()
	if self.role == "Fighter" then return 35 end
	return 0
end

function modifier_enfos_shard_upgrade:GetModifierMoveSpeedBonus_Percentage()
	if self.role == "Carry" then return 15 end
	return 0
end

function modifier_enfos_shard_upgrade:GetModifierSpellAmplify_Percentage()
	if self.role == "Mage" then return 15 end
	return 0
end

function modifier_enfos_shard_upgrade:GetModifierHealAmplify_PercentageSource()
	local parent = self.GetParent and self:GetParent()
	if parent and parent.GetUnitName and (parent:GetUnitName() == "npc_dota_hero_lich" or parent:GetUnitName() == "npc_dota_hero_vengefulspirit") then return 0 end
	if parent and parent.GetUnitName and parent:GetUnitName() == "npc_dota_hero_shadow_shaman" then return 0 end
	if self.role == "Support" then return 25 end
	return 0
end

function modifier_enfos_shard_upgrade:OnTakeDamage(keys)
    if self.GetParent and self:GetParent().GetUnitName and self:GetParent():GetUnitName()=="npc_dota_hero_tidehunter" then return end
    if self.GetParent and self:GetParent().GetUnitName and self:GetParent():GetUnitName()=="npc_dota_hero_sven" then return end
	if not IsServer or not IsServer() then return end
	if keys.unit ~= self:GetParent() then return end
	if bit.band(keys.damage_flags or 0, DOTA_DAMAGE_FLAG_REFLECTION) ~= 0 then return end

	-- Tank: reflect 15% damage
	if self.role == "Tank" and keys.attacker and not keys.attacker:IsNull() and keys.attacker:IsAlive() and keys.attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
		local reflect = (keys.original_damage or 0) * 0.15
		if reflect > 0 then
			ApplyDamage({
				victim = keys.attacker,
				attacker = self:GetParent(),
				damage = reflect,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
			})
		end
	end
end

function modifier_enfos_shard_upgrade:OnAttackLanded(keys)
	if not IsServer or not IsServer() then return end
	if keys.attacker ~= self:GetParent() then return end
	local target = keys.target
	if not target or target:IsNull() or not target:IsAlive() or target:GetTeamNumber()==self:GetParent():GetTeamNumber() then return end

	if self.role == "Fighter" then
		target:AddNewModifier(self:GetParent(), nil, "modifier_enfos_shard_slow", { duration = 3.0 })
	elseif self.role == "Carry" then
		ApplyDamage({
			victim = target,
			attacker = self:GetParent(),
			damage = (keys.damage or 0) * 0.12,
			damage_type = DAMAGE_TYPE_PURE,
			damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
		})
	end
end

-- Shard Fighter Slow Debuff
modifier_enfos_shard_slow = class({})
function modifier_enfos_shard_slow:IsHidden() return false end
function modifier_enfos_shard_slow:IsDebuff() return true end
function modifier_enfos_shard_slow:IsPurgable() return true end
function modifier_enfos_shard_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end
function modifier_enfos_shard_slow:GetModifierMoveSpeedBonus_Percentage() return -25 end
function modifier_enfos_shard_slow:GetModifierAttackSpeedBonus_Constant() return -25 end

-- Ascended Aghanim's Blessing Consumed Modifier (Permanent Stats)
modifier_item_ascended_aghanims_blessing_consumed = class({})
function modifier_item_ascended_aghanims_blessing_consumed:IsHidden() return false end
function modifier_item_ascended_aghanims_blessing_consumed:IsPurgable() return false end
function modifier_item_ascended_aghanims_blessing_consumed:IsPermanent() return true end
function modifier_item_ascended_aghanims_blessing_consumed:RemoveOnDeath() return false end
function modifier_item_ascended_aghanims_blessing_consumed:GetTexture() return "item_ultimate_scepter_2" end

function modifier_item_ascended_aghanims_blessing_consumed:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
	}
end
function modifier_item_ascended_aghanims_blessing_consumed:GetModifierBonusStats_Strength() return 10 end
function modifier_item_ascended_aghanims_blessing_consumed:GetModifierBonusStats_Agility() return 10 end
function modifier_item_ascended_aghanims_blessing_consumed:GetModifierBonusStats_Intellect() return 10 end
function modifier_item_ascended_aghanims_blessing_consumed:GetModifierHealthBonus() return 175 end
function modifier_item_ascended_aghanims_blessing_consumed:GetModifierManaBonus() return 175 end

return AghanimManager
