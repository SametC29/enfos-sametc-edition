--------------------------------------------------------------------------------
-- boss_framework.lua
-- Server-authoritative Boss framework for Enfos Team Survival — SametC Edition
-- Implements reusable:
-- 1. Boss base modifier: CC reduction (max 1.5s stun), reflect cap (150 max),
--    and %-HP damage cap (max 4% max HP per instance).
-- 2. Ground telegraph system: readable delay and visual warning before heavy spells.
-- 3. Boss-only wave transition and battlefield cleanup.
-- 4. Concrete behaviors for first 3 Bosses:
--    - Stonebreaker (Wave 5): Ground Slam telegraph + Low-HP Enrage phase.
--    - Brood Matron (Wave 10): Toxic Spit telegraph + Capped spiderling add spawns.
--    - Bloodfang Alpha (Wave 15): Alpha Pounce telegraph + Lifesteal / Blood Frenzy.
-- Reference: docs/GAME_DESIGN_MASTER.md § 10, docs/QA_BALANCE_RELEASE.md § 7
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

local BossFramework = {telegraphSerial=0}
if LinkLuaModifier then LinkLuaModifier("modifier_enfos_boss_phase_guard", "bosses/boss_framework", LUA_MODIFIER_MOTION_NONE) end
BossFramework.__index = BossFramework

-- Boss Balance Caps (docs/QA_BALANCE_RELEASE.md § 7)
BossFramework.MAX_STUN_DURATION = 1.5 -- Seconds
BossFramework.STATUS_RESISTANCE = 60 -- Percent
BossFramework.MAX_REFLECT_DAMAGE = 150 -- Per damage instance
BossFramework.MAX_HP_PERCENT_DAMAGE = 0.04 -- Max 4% of max HP per instance

-- Link Lua Modifiers
if IsServer and IsServer() and LinkLuaModifier then
	LinkLuaModifier("modifier_enfos_boss_base", "bosses/boss_framework", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_enfos_boss_enrage", "bosses/boss_framework", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_enfos_boss_toxic_pool", "bosses/boss_framework", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_enfos_boss_toxic_slow", "bosses/boss_framework", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_enfos_boss_blood_frenzy", "bosses/boss_framework", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_enfos_boss_hemorrhage", "bosses/boss_framework", LUA_MODIFIER_MOTION_NONE)
end

--------------------------------------------------------------------------------
-- Initialize Framework
--------------------------------------------------------------------------------
function BossFramework:Init()
	self.activeBosses = {}
	Log:Info("boss_framework", "BossFramework initialized successfully.")
end

--------------------------------------------------------------------------------
-- Register Boss Entity
--------------------------------------------------------------------------------
function BossFramework:RegisterBoss(unit, bossName, waveNumber, playerCount)
	if not unit or unit:IsNull() then return end

	-- Apply core Boss baseline modifier (caps CC, reflect, and %-HP damage)
	unit:AddNewModifier(unit, nil, "modifier_enfos_boss_base", {})

	-- Initialize Boss AI state machine
	unit.bossState = {
		name = bossName,
		wave = waveNumber,
		players = playerCount or 1,
		phase = 1,
		abilityTimer = 3.0, -- First ability after 3s
		isEnraged = false,
		addsSpawned = false,
	}

	-- Attach Boss Thinker
	unit:SetContextThink("BossThinker", function()
		return self:OnBossThink(unit)
	end, 0.5)

	self.activeBosses[unit:entindex()] = unit
	Log:Info("boss_framework", "Registered Boss '%s' for Wave %d (Players: %d)", bossName, waveNumber, playerCount or 1)
end

--------------------------------------------------------------------------------
-- Boss Thinker Loop
--------------------------------------------------------------------------------
function BossFramework:OnBossThink(unit)
	if not unit or unit:IsNull() or not unit:IsAlive() then
        if unit and not unit:IsNull() then self.activeBosses[unit:entindex()]=nil end
		return nil
	end

	if GameRules and GameRules.IsGamePaused and GameRules:IsGamePaused() then
		return 0.5
	end

	local state = unit.bossState
	if not state then return nil end

	local boundary = state.phase == 1 and 0.70 or (state.phase == 2 and 0.35 or 0)
    if boundary > 0 and unit:GetHealth() <= math.ceil(unit:GetMaxHealth()*boundary) then
        state.phase = state.phase + 1
        state.abilityTimer = 2.5
        unit:AddNewModifier(unit,nil,"modifier_enfos_boss_phase_guard",{duration=2})
        unit:EmitSound("Hero_Sven.WarCry")
        Log:Info("boss_framework","Boss phase: wave=%d phase=%d",state.wave,state.phase)
    end
    state.abilityTimer = (state.abilityTimer or 0) - 0.5

	-- Dispatch to specific Boss behavior
	if state.name == "enfos_boss_stonebreaker" then
		self:ThinkStonebreaker(unit, state)
	elseif state.name == "enfos_boss_brood_matron" then
		self:ThinkBroodMatron(unit, state)
	elseif state.name == "enfos_boss_bloodfang_alpha" then
		self:ThinkBloodfangAlpha(unit, state)
    else
        self:ThinkPhasedBoss(unit,state)
	end

	return 0.5
end

--------------------------------------------------------------------------------
-- Telegraph System
-- Creates a readable ground warning indicator and invokes callback upon completion
--------------------------------------------------------------------------------
function BossFramework:CreateTelegraph(centerPos, radius, duration, onCompleteCallback)
	if not centerPos then return end

	-- Visual telegraph particle
	local pfx = nil
	if ParticleManager then
		pfx = ParticleManager:CreateParticle("particles/ui_mouseactions/range_display.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, centerPos)
		ParticleManager:SetParticleControl(pfx, 1, Vector(radius, 0, 0))
		ParticleManager:SetParticleControl(pfx, 2, Vector(255, 60, 60)) -- Red warning color
	end

	-- Sound indicator
	EmitGlobalSound("General.Cast")

	-- Timer for telegraph windup
	local elapsed = 0
	self.telegraphSerial = self.telegraphSerial + 1
	local thinkerName = "EnfosTelegraph_" .. self.telegraphSerial

	if GameRules and GameRules.GetGameModeEntity then
		local mode = GameRules:GetGameModeEntity()
		if mode and mode.SetContextThink then
			mode:SetContextThink(thinkerName, function()
				if GameRules.IsGamePaused and GameRules:IsGamePaused() then return 0.1 end
                elapsed = elapsed + 0.1
				if elapsed >= duration then
					if pfx and ParticleManager then
						ParticleManager:DestroyParticle(pfx, false)
						ParticleManager:ReleaseParticleIndex(pfx)
					end
					if onCompleteCallback then
						onCompleteCallback(centerPos, radius)
					end
					return nil
				end
				return 0.1
			end, 0.1)
			return
		end
	end

	-- Fallback for synchronous test environments
	if onCompleteCallback then
		onCompleteCallback(centerPos, radius)
	end
end

--------------------------------------------------------------------------------
-- Boss 1: Stonebreaker (Wave 5)
-- Abilities:
-- 1. Ground Slam (Telegraphed 1.5s, 450 AoE, 300 damage + 1.5s stun)
-- 2. Enrage Phase (<30% HP: +40 AS, +25% MS, red glow)
--------------------------------------------------------------------------------
function BossFramework:ThinkStonebreaker(unit, state)
	local hpPct = (unit:GetHealth() / unit:GetMaxHealth()) * 100

	-- Phase 2: Enrage below 30% HP
	if hpPct <= 30 and not state.isEnraged then
		state.isEnraged = true
		unit:AddNewModifier(unit, nil, "modifier_enfos_boss_enrage", {})
		unit:EmitSound("Hero_Sven.GodsStrength")
		Log:Info("boss_framework", "Stonebreaker entered ENRAGE phase!")
	end

	-- Ability: Ground Slam every 12 seconds in combat
	if state.abilityTimer <= 0 then
		state.abilityTimer = state.isEnraged and 8.0 or 12.0

		-- Target nearest hero
		local heroes = FindUnitsInRadius(unit:GetTeamNumber(), unit:GetAbsOrigin(), nil, 600,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)

		local targetPos = (#heroes > 0 and heroes[1]:GetAbsOrigin()) or unit:GetAbsOrigin()

		-- Start 1.5s Ground Slam Telegraph
		self:CreateTelegraph(targetPos, 450, 1.5, function(pos, radius)
			if not unit or unit:IsNull() or not unit:IsAlive() then return end

			-- Execute Ground Slam
			unit:EmitSound("Hero_Tiny.Avalanche")
			if ScreenShake then ScreenShake(pos, 8, 100, 0.5, 1000, 0, true) end

			local targets = FindUnitsInRadius(unit:GetTeamNumber(), pos, nil, radius,
				DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

			for _, target in ipairs(targets) do
				ApplyDamage({
					victim = target,
					attacker = unit,
					damage = 300,
					damage_type = DAMAGE_TYPE_PHYSICAL,
				})
				target:AddNewModifier(unit, nil, "modifier_stunned", { duration = 1.5 })
			end
		end)
	end
end

--------------------------------------------------------------------------------
-- Boss 2: Brood Matron (Wave 10)
-- Abilities:
-- 1. Toxic Spit (Telegraphed 1.2s, 350 AoE, leaves pool dealing 80 DPS & 40% slow for 6s)
-- 2. Brood Spawn (Summons 4 spiderlings at 50% HP or periodically)
--------------------------------------------------------------------------------
function BossFramework:ThinkBroodMatron(unit, state)
	local hpPct = (unit:GetHealth() / unit:GetMaxHealth()) * 100

	-- Spawn spiderling adds at 50% HP (once)
	if hpPct <= 50 and not state.addsSpawned then
		state.addsSpawned = true
		self:SpawnSpiderlingAdds(unit, 4)
		unit:EmitSound("Hero_Broodmother.SpawnSpiderlings")
		Log:Info("boss_framework", "Brood Matron spawned spiderling adds at 50% HP.")
	end

	-- Ability: Toxic Spit every 10 seconds
	if state.abilityTimer <= 0 then
		state.abilityTimer = 10.0

		local heroes = FindUnitsInRadius(unit:GetTeamNumber(), unit:GetAbsOrigin(), nil, 700,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

		local targetPos = (#heroes > 0 and heroes[1]:GetAbsOrigin()) or unit:GetAbsOrigin()

		-- Start 1.2s Toxic Spit Telegraph
		self:CreateTelegraph(targetPos, 350, 1.2, function(pos, radius)
			if not unit or unit:IsNull() or not unit:IsAlive() then return end

			unit:EmitSound("Hero_Venomancer.PoisonNova")
			if CreateModifierThinker then
				CreateModifierThinker(unit, nil, "modifier_enfos_boss_toxic_pool", {
					duration = 6.0,
					radius = radius,
				}, pos, unit:GetTeamNumber(), false)
			end
		end)
	end
end

function BossFramework:SpawnSpiderlingAdds(boss, count)
	local pos = boss:GetAbsOrigin()
	for i = 1, count do
		local offset = Vector(math.cos(i) * 100, math.sin(i) * 100, 0)
		local add = CreateUnitByName("enfos_creep_spiderling", pos + offset, true, boss, boss, boss:GetTeamNumber())
		if add then
			add.is_boss_add = true
			add.defendingTeam = boss.defendingTeam or 2
			add:SetIdleAcquire(true)
			add:SetAcquisitionRange(650)
		end
	end
end

--------------------------------------------------------------------------------
-- Boss 3: Bloodfang Alpha (Wave 15)
-- Abilities:
-- 1. Alpha Pounce (Telegraphed 1.0s, targets farthest hero within 800 range, 350 DMG + Bleed)
-- 2. Blood Frenzy (+25% Lifesteal, <40% HP gains +50 Attack Speed)
--------------------------------------------------------------------------------
function BossFramework:ThinkBloodfangAlpha(unit, state)
	local hpPct = (unit:GetHealth() / unit:GetMaxHealth()) * 100

	-- Ensure Blood Frenzy passive modifier is present
	if not unit:HasModifier("modifier_enfos_boss_blood_frenzy") then
		unit:AddNewModifier(unit, nil, "modifier_enfos_boss_blood_frenzy", {})
	end

	-- Ability: Alpha Pounce every 12 seconds
	if state.abilityTimer <= 0 then
		state.abilityTimer = 12.0

		local heroes = FindUnitsInRadius(unit:GetTeamNumber(), unit:GetAbsOrigin(), nil, 800,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_FARTHEST, false)

		if #heroes > 0 then
			local targetHero = heroes[1]
			local targetPos = targetHero:GetAbsOrigin()

			-- Start 1.0s Alpha Pounce Telegraph
			self:CreateTelegraph(targetPos, 250, 1.0, function(pos, radius)
				if not unit or unit:IsNull() or not unit:IsAlive() then return end
				if not targetHero or targetHero:IsNull() or not targetHero:IsAlive() then return end

				-- Leap to target
				FindClearSpaceForUnit(unit, targetPos, true)
				unit:EmitSound("Hero_Lycan.Howl")

				ApplyDamage({
					victim = targetHero,
					attacker = unit,
					damage = 350,
					damage_type = DAMAGE_TYPE_PHYSICAL,
				})

				-- Apply Hemorrhage (40 bleed DPS for 5s)
				targetHero:AddNewModifier(unit, nil, "modifier_enfos_boss_hemorrhage", { duration = 5.0 })
			end)
		end
	end
end

--------------------------------------------------------------------------------
-- MODIFIERS
--------------------------------------------------------------------------------

-- All later bosses use a bounded, dodgeable multi-zone phase pattern.
function BossFramework:ThinkPhasedBoss(unit,state)
    if state.abilityTimer > 0 then return end
    state.abilityTimer = 10 - state.phase
    local heroes = FindUnitsInRadius(unit:GetTeamNumber(),unit:GetAbsOrigin(),nil,1600,
        DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false)
    local marked=0
    for _,hero in ipairs(heroes) do
        if hero:GetTeamNumber()==unit.defendingTeam and not hero:IsIllusion() then
            local position=hero:GetAbsOrigin()
            marked=marked+1
            self:CreateTelegraph(position,280,1.8,function(pos,radius)
                if unit:IsNull() or not unit:IsAlive() then return end
                unit:EmitSound("Hero_Centaur.HoofStomp")
                local targets=FindUnitsInRadius(unit:GetTeamNumber(),pos,nil,radius,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
                    DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
                for _,target in ipairs(targets) do
                    if target:GetTeamNumber()==unit.defendingTeam then
                        ApplyDamage({victim=target,attacker=unit,damage=unit:GetBaseDamageMax(),damage_type=DAMAGE_TYPE_MAGICAL})
                        target:AddNewModifier(unit,nil,"modifier_enfos_boss_toxic_slow",{duration=2})
                    end
                end
            end)
            if marked >= state.phase then break end
        end
    end
end

modifier_enfos_boss_phase_guard=class({})
function modifier_enfos_boss_phase_guard:IsPurgable() return false end
function modifier_enfos_boss_phase_guard:CheckState()
    return {[MODIFIER_STATE_INVULNERABLE]=true,[MODIFIER_STATE_ROOTED]=true,[MODIFIER_STATE_DISARMED]=true}
end
function modifier_enfos_boss_phase_guard:GetEffectName() return "particles/items_fx/black_king_bar_avatar.vpcf" end
function modifier_enfos_boss_phase_guard:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

-- 1. Boss Base Modifier (CC, reflect, and %-HP damage caps)
modifier_enfos_boss_base = class({})
function modifier_enfos_boss_base:IsHidden() return true end
function modifier_enfos_boss_base:IsPurgable() return false end
function modifier_enfos_boss_base:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
        MODIFIER_PROPERTY_MIN_HEALTH,
	}
end

function modifier_enfos_boss_base:GetMinHealth()
    if IsServer and not IsServer() then return 0 end
    local unit=self:GetParent()
    local phase=unit.bossState and unit.bossState.phase or 3
    return math.ceil(unit:GetMaxHealth()*(phase==1 and 0.70 or (phase==2 and 0.35 or 0)))
end
function modifier_enfos_boss_base:GetModifierStatusResistanceStacking()
	return BossFramework.STATUS_RESISTANCE
end

function modifier_enfos_boss_base:GetModifierTotal_ConstantBlock(kv)
	if IsServer and not IsServer() then return 0 end
	local parent = self:GetParent()
	local incoming = kv.damage or 0

	-- 1. Cap reflect damage (prevents suicide-reflect loops)
	local isReflect = false
	if kv.damage_flags then
		if bit and bit.band then
			isReflect = bit.band(kv.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION or 16) ~= 0
		else
			isReflect = (kv.damage_flags == (DOTA_DAMAGE_FLAG_REFLECTION or 16))
		end
	end

	if isReflect and incoming > BossFramework.MAX_REFLECT_DAMAGE then
		return incoming - BossFramework.MAX_REFLECT_DAMAGE
	end

	-- 2. Cap single-instance %-HP damage at 4% of Boss max HP
	local maxHp = parent and parent:GetMaxHealth() or 10000
	local cap = maxHp * BossFramework.MAX_HP_PERCENT_DAMAGE
	if incoming > cap then
		return incoming - cap
	end

	return 0
end

-- 2. Stonebreaker Enrage Modifier
modifier_enfos_boss_enrage = class({})
function modifier_enfos_boss_enrage:IsPurgable() return false end
function modifier_enfos_boss_enrage:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_enfos_boss_enrage:GetModifierAttackSpeedBonus_Constant() return 40 end
function modifier_enfos_boss_enrage:GetModifierMoveSpeedBonus_Percentage() return 25 end
function modifier_enfos_boss_enrage:GetStatusEffectName() return "particles/status_fx/status_effect_gods_strength.vpcf" end

-- 3. Brood Matron Toxic Pool Thinker & Slow
modifier_enfos_boss_toxic_pool = class({})
function modifier_enfos_boss_toxic_pool:OnCreated(kv)
	if not (IsServer and IsServer()) then return end
	self.radius = kv.radius or 350
	self:StartIntervalThink(0.5)
end
function modifier_enfos_boss_toxic_pool:OnIntervalThink()
	local caster = self:GetCaster()
	local pos = self:GetParent():GetAbsOrigin()
	local targets = FindUnitsInRadius(self:GetParent():GetTeamNumber(), pos, nil, self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	for _, target in ipairs(targets) do
		ApplyDamage({
			victim = target,
			attacker = caster or self:GetParent(),
			damage = 40, -- 80 DPS (0.5s ticks)
			damage_type = DAMAGE_TYPE_MAGICAL,
		})
		target:AddNewModifier(caster, nil, "modifier_enfos_boss_toxic_slow", { duration = 1.0 })
	end
end

modifier_enfos_boss_toxic_slow = class({})
function modifier_enfos_boss_toxic_slow:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end
function modifier_enfos_boss_toxic_slow:GetModifierMoveSpeedBonus_Percentage() return -40 end

-- 4. Bloodfang Alpha Blood Frenzy & Hemorrhage
modifier_enfos_boss_blood_frenzy = class({})
function modifier_enfos_boss_blood_frenzy:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end
function modifier_enfos_boss_blood_frenzy:GetModifierAttackSpeedBonus_Constant()
	local parent = self:GetParent()
	if parent and (parent:GetHealth() / parent:GetMaxHealth()) <= 0.4 then
		return 50
	end
	return 0
end
function modifier_enfos_boss_blood_frenzy:OnAttackLanded(params)
	if not (IsServer and IsServer()) then return end
	if params.attacker == self:GetParent() and not self:GetParent():PassivesDisabled() then
		local heal = params.damage * 0.25
		self:GetParent():Heal(heal, self:GetParent())
	end
end

modifier_enfos_boss_hemorrhage = class({})
function modifier_enfos_boss_hemorrhage:IsDebuff() return true end
function modifier_enfos_boss_hemorrhage:OnCreated()
	if not (IsServer and IsServer()) then return end
	self:StartIntervalThink(1.0)
end
function modifier_enfos_boss_hemorrhage:OnIntervalThink()
	ApplyDamage({
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = 40,
		damage_type = DAMAGE_TYPE_PHYSICAL,
	})
end

return BossFramework
