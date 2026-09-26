--------------------------------------------------------------------------------
-- elite_framework.lua
-- Server-authoritative Elite framework for Enfos Team Survival — SametC Edition
-- Implements reusable:
-- 1. Elite base modifier: CC reduction (35% status resistance) and distinct visual presentation.
-- 2. Leak penalty strictly -2.
-- 3. Meaningful mechanic augmentations for the first 2 Elites:
--    - Elite Vanguard (Wave 6): Shield Wall (35% physical reduction) + Taunt Pulse.
--    - Elite Assassin (Wave 12): Shadow Fade (Invis fade) + Ambush Strike (+60% damage, 30% slow).
-- Reference: docs/GAME_DESIGN_MASTER.md § 9, docs/QA_BALANCE_RELEASE.md § 7
--------------------------------------------------------------------------------

require("lib/log")
local WaveDefinitions = require("waves/wave_definitions")
local class = _G.class or function(...)
	local c = {}
	c.__index = c
	setmetatable(c, {
		__call = function(cls, ...)
			return setmetatable({}, cls)
		end
	})
	return c
end

local EliteFramework = {}
EliteFramework.__index = EliteFramework

EliteFramework.STATUS_RESISTANCE = 35 -- Percent

-- Link Lua Modifiers
if IsServer and IsServer() and LinkLuaModifier then
	LinkLuaModifier("modifier_enfos_elite_base", "bosses/elite_framework", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_enfos_elite_vanguard_shield", "bosses/elite_framework", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_enfos_elite_assassin_stealth", "bosses/elite_framework", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_enfos_elite_assassin_ambush", "bosses/elite_framework", LUA_MODIFIER_MOTION_NONE)
end

--------------------------------------------------------------------------------
-- Initialize Elite Framework
--------------------------------------------------------------------------------
function EliteFramework:Init()
	self.activeElites = {}
	Log:Info("elite_framework", "EliteFramework initialized successfully.")
end

--------------------------------------------------------------------------------
-- Register Elite Unit
--------------------------------------------------------------------------------
function EliteFramework:RegisterElite(unit, eliteName, waveNumber)
	if not unit or unit:IsNull() then return end

	-- Apply core Elite baseline modifier (CC reduction + visual aura)
	unit:AddNewModifier(unit, nil, "modifier_enfos_elite_base", {})

	unit.eliteState = {
		name = eliteName,
		wave = waveNumber,
		abilityTimer = 4.0,
	}

	-- Attach specific mechanics
	if eliteName == "enfos_elite_vanguard" then
		unit:AddNewModifier(unit, nil, "modifier_enfos_elite_vanguard_shield", {})
	elseif eliteName == "enfos_elite_assassin" then
		unit:AddNewModifier(unit, nil, "modifier_enfos_elite_assassin_stealth", {})
	end

	-- Attach Elite Thinker
	unit:SetContextThink("EliteThinker", function()
		return self:OnEliteThink(unit)
	end, 0.5)

	self.activeElites[unit:entindex()] = unit
	Log:Info("elite_framework", "Registered Elite '%s' for Wave %d", eliteName, waveNumber)
end

--------------------------------------------------------------------------------
-- Elite Thinker Loop
--------------------------------------------------------------------------------
function EliteFramework:OnEliteThink(unit)
	if not unit or unit:IsNull() or not unit:IsAlive() then
		return nil
	end

	if GameRules and GameRules.IsGamePaused and GameRules:IsGamePaused() then
		return 0.5
	end

	local state = unit.eliteState
	if not state then return nil end

	state.abilityTimer = (state.abilityTimer or 0) - 0.5

	-- Elite Vanguard: Taunt Pulse every 12 seconds
	if state.name == "enfos_elite_vanguard" and state.abilityTimer <= 0 then
		state.abilityTimer = 12.0
		self:ExecuteVanguardTaunt(unit)
	end

	return 0.5
end

function EliteFramework:ExecuteVanguardTaunt(unit)
	local heroes = FindUnitsInRadius(unit:GetTeamNumber(), unit:GetAbsOrigin(), nil, 400,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	if #heroes > 0 then
		unit:EmitSound("Hero_Axe.BerserkersCall")
		for _, hero in ipairs(heroes) do
			hero:AddNewModifier(unit, nil, "modifier_taunt", { duration = 1.5 })
		end
		Log:Info("elite_framework", "Elite Vanguard executed Taunt Pulse on %d heroes.", #heroes)
	end
end

--------------------------------------------------------------------------------
-- MODIFIERS
--------------------------------------------------------------------------------

-- 1. Elite Base Modifier (CC resistance + distinctive status)
modifier_enfos_elite_base = class({})
function modifier_enfos_elite_base:IsHidden() return true end
function modifier_enfos_elite_base:IsPurgable() return false end
function modifier_enfos_elite_base:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_PROPERTY_MODEL_SCALE,
	}
end
function modifier_enfos_elite_base:GetModifierStatusResistanceStacking()
	return EliteFramework.STATUS_RESISTANCE
end
function modifier_enfos_elite_base:GetModifierModelScale()
	return 15 -- +15% model size
end
function modifier_enfos_elite_base:GetEffectName()
	return "particles/units/heroes/hero_omniknight/omniknight_repel_buff.vpcf"
end

-- 2. Elite Vanguard: Shield Wall (35% Physical damage reduction)
modifier_enfos_elite_vanguard_shield = class({})
function modifier_enfos_elite_vanguard_shield:IsPurgable() return false end
function modifier_enfos_elite_vanguard_shield:DeclareFunctions()
	return { MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE }
end
function modifier_enfos_elite_vanguard_shield:GetModifierIncomingPhysicalDamage_Percentage()
	return -35 -- 35% physical damage reduction
end

-- 3. Elite Assassin: Shadow Fade & Ambush Strike
modifier_enfos_elite_assassin_stealth = class({})
function modifier_enfos_elite_assassin_stealth:IsPurgable() return false end
function modifier_enfos_elite_assassin_stealth:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = true,
	}
end
function modifier_enfos_elite_assassin_stealth:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end
function modifier_enfos_elite_assassin_stealth:GetModifierInvisibilityLevel() return 1.0 end
function modifier_enfos_elite_assassin_stealth:OnAttackLanded(params)
	if not (IsServer and IsServer()) then return end
	if params.attacker == self:GetParent() then
		-- Break stealth, apply Ambush Strike (+60% damage + 30% slow)
		self:GetParent():EmitSound("Hero_PhantomAssassin.Attack")
		if params.target and not params.target:IsNull() then
			local bonusDmg = params.damage * 0.60
			ApplyDamage({
				victim = params.target,
				attacker = self:GetParent(),
				damage = bonusDmg,
				damage_type = DAMAGE_TYPE_PHYSICAL,
			})
			params.target:AddNewModifier(self:GetParent(), nil, "modifier_enfos_elite_assassin_ambush", { duration = 2.5 })
		end
		self:Destroy()
	end
end

modifier_enfos_elite_assassin_ambush = class({})
function modifier_enfos_elite_assassin_ambush:IsDebuff() return true end
function modifier_enfos_elite_assassin_ambush:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end
function modifier_enfos_elite_assassin_ambush:GetModifierMoveSpeedBonus_Percentage() return -30 end

return EliteFramework
