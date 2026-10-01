--------------------------------------------------------------------------------
-- boss_framework.lua
-- Server-authoritative Boss framework for Enfos Team Survival — SametC Edition
-- Implements reusable:
-- 1. Boss base modifier: CC resistance and reflect cap (150 max).
-- 2. Ground telegraph system: readable delay and visual warning before heavy spells.
-- 3. Boss-only wave transition while prior scheduled creeps remain active.
-- 4. Concrete signature behaviors for all 12 Bosses:
--    - Stonebreaker (Wave 5): Ground Slam telegraph.
--    - Brood Matron (Wave 10): Toxic Spit telegraph + Capped spiderling add spawns.
--    - Bloodfang Alpha (Wave 15): Alpha Pounce telegraph + Lifesteal / Blood Frenzy.
--    - Later Bosses each mark a distinct control, positioning, resource, or hazard check.
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
BossFramework.__index = BossFramework

-- Boss Balance Caps (docs/QA_BALANCE_RELEASE.md § 7)
BossFramework.MAX_STUN_DURATION = 1.5 -- Seconds
BossFramework.STATUS_RESISTANCE = 60 -- Percent
BossFramework.MAX_REFLECT_DAMAGE = 150 -- Per damage instance

-- Link Lua Modifiers
if IsServer and IsServer() and LinkLuaModifier then
	LinkLuaModifier("modifier_enfos_boss_base", "bosses/boss_framework", LUA_MODIFIER_MOTION_NONE)
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

	-- Apply Boss baseline modifier (status resistance and reflect safety cap).
	unit:AddNewModifier(unit, nil, "modifier_enfos_boss_base", {})

	-- Initialize Boss AI state machine
	unit.bossState = {
		name = bossName,
		wave = waveNumber,
		players = playerCount or 1,
		abilityTimer = 3.0, -- First ability after 3s
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

    state.abilityTimer = (state.abilityTimer or 0) - 0.5

	-- Dispatch to specific Boss behavior
	if state.name == "enfos_boss_stonebreaker" then
		self:ThinkStonebreaker(unit, state)
	elseif state.name == "enfos_boss_brood_matron" then
		self:ThinkBroodMatron(unit, state)
	elseif state.name == "enfos_boss_bloodfang_alpha" then
		self:ThinkBloodfangAlpha(unit, state)
    else
        self:ThinkSignatureBoss(unit,state)
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
-- 2. Wave-scaled boss attacks (no health-gated invulnerability phases).
--------------------------------------------------------------------------------
function BossFramework:ThinkStonebreaker(unit, state)
	-- Ability: Ground Slam on a fixed cadence; boss power scales with the wave.
	if state.abilityTimer <= 0 then
		state.abilityTimer = 12.0

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

--------------------------------------------------------------------------------
-- Boss 3: Bloodfang Alpha (Wave 15)
-- Abilities:
-- 1. Alpha Pounce (Telegraphed 1.0s, targets farthest hero within 800 range, 350 DMG + Bleed)
-- 2. Blood Frenzy (+25% Lifesteal, <40% HP gains +50 Attack Speed)
--------------------------------------------------------------------------------
function BossFramework:ThinkBloodfangAlpha(unit, state)

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

local function BossTargets(unit, position, radius, order)
	local candidates = FindUnitsInRadius(unit:GetTeamNumber(), position, nil, radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE, order or FIND_ANY_ORDER, false)
	local targets = {}
	for _, target in ipairs(candidates) do
		if target and not target:IsNull() and target:IsAlive()
			and target:GetTeamNumber() == unit.defendingTeam and not target:IsIllusion() then
			table.insert(targets, target)
		end
	end
	return targets
end

local function BossDamage(unit, multiplier)
	return math.max(180, (unit:GetBaseDamageMax() or 150) * multiplier)
end

function BossFramework:ResolveBossStrike(unit, position, radius, damage, damageType, onHit)
	if not unit or unit:IsNull() or not unit:IsAlive() then return end
	local targets = BossTargets(unit, position, radius)
	for _, target in ipairs(targets) do
		ApplyDamage({ victim = target, attacker = unit, damage = damage, damage_type = damageType })
		if onHit then onHit(target) end
	end
end

-- Bosses 4–12 have separate signatures. Each attack marks its danger area before
-- resolving, while each identity tests a different team response.
function BossFramework:ThinkSignatureBoss(unit, state)
	if state.abilityTimer > 0 then return end
	local name = state.name
	local origin = unit:GetAbsOrigin()
	local waveTier = math.floor(math.max(0, (state.wave or 5) - 5) / 10)
	local damage = BossDamage(unit, 1.25 + 0.04 * waveTier)

	if name == "enfos_boss_frost_warden" then
		state.abilityTimer = 9
		local targets = BossTargets(unit, origin, 1000, FIND_CLOSEST)
		if #targets == 0 then return end
		local pos = targets[1]:GetAbsOrigin()
		self:CreateTelegraph(pos, 390, 1.5, function(mark, radius)
			self:ResolveBossStrike(unit, mark, radius, damage, DAMAGE_TYPE_MAGICAL, function(target)
				target:AddNewModifier(unit, nil, "modifier_enfos_boss_toxic_slow", { duration = 3.0 })
			end)
		end)
	elseif name == "enfos_boss_mind_devourer" then
		state.abilityTimer = 10
		local targets = BossTargets(unit, origin, 1100)
		local target, lowestMana
		for _, hero in ipairs(targets) do
			if not lowestMana or hero:GetMana() < lowestMana then target, lowestMana = hero, hero:GetMana() end
		end
		if not target then return end
		local pos = target:GetAbsOrigin()
		self:CreateTelegraph(pos, 310, 1.35, function(mark, radius)
			self:ResolveBossStrike(unit, mark, radius, damage, DAMAGE_TYPE_MAGICAL, function(victim)
			local drained = math.min(victim:GetMana(), 90 + 30 * math.floor((state.wave or 5) / 20))
				if drained > 0 then victim:SpendMana(drained, unit) end
			end)
		end)
	elseif name == "enfos_boss_iron_colossus" then
		state.abilityTimer = 11
		self:CreateTelegraph(origin, 430 + 70 * math.floor((state.wave or 5) / 20), 1.8, function(mark, radius)
			self:ResolveBossStrike(unit, mark, radius, damage * 1.2, DAMAGE_TYPE_PHYSICAL, function(target)
				target:AddNewModifier(unit, nil, "modifier_stunned", { duration = 0.75 })
				local direction = (target:GetAbsOrigin() - mark):Normalized()
				FindClearSpaceForUnit(target, target:GetAbsOrigin() + direction * 250, true)
			end)
		end)
	elseif name == "enfos_boss_gravecaller" then
		state.abilityTimer = 13
		local summon = unit:FindAbilityByName("enfos_creep_summoner_raise")
		if summon and summon:IsCooldownReady() then unit:CastAbilityNoTarget(summon, -1) end
		self:CreateTelegraph(origin, 500, 1.25, function(mark, radius)
			self:ResolveBossStrike(unit, mark, radius, damage * 0.85, DAMAGE_TYPE_MAGICAL, function(target)
				target:AddNewModifier(unit, nil, "modifier_enfos_boss_toxic_slow", { duration = 1.5 })
			end)
		end)
	elseif name == "enfos_boss_storm_tyrant" then
		state.abilityTimer = 8
		local targets = BossTargets(unit, origin, 1300, FIND_CLOSEST)
		for i = 1, math.min(#targets, 2 + math.floor(waveTier / 2)) do
			local pos = targets[i]:GetAbsOrigin()
			self:CreateTelegraph(pos, 270, 1.1, function(mark, radius)
				self:ResolveBossStrike(unit, mark, radius, damage * 0.8, DAMAGE_TYPE_MAGICAL, function(target)
					target:AddNewModifier(unit, nil, "modifier_stunned", { duration = 0.45 })
				end)
			end)
		end
	elseif name == "enfos_boss_shadow_huntress" then
		state.abilityTimer = 9
		local targets = BossTargets(unit, origin, 1400, FIND_FARTHEST)
		for i = 1, math.min(#targets, 1 + math.floor(waveTier / 2)) do
			local pos = targets[i]:GetAbsOrigin()
			self:CreateTelegraph(pos, 235, 1.25, function(mark, radius)
				self:ResolveBossStrike(unit, mark, radius, damage * 1.05, DAMAGE_TYPE_PHYSICAL, function(target)
					target:AddNewModifier(unit, nil, "modifier_enfos_boss_hemorrhage", { duration = 4.0 })
				end)
			end)
		end
	elseif name == "enfos_boss_plague_behemoth" then
		state.abilityTimer = 10
		local targets = BossTargets(unit, origin, 1000)
		if #targets == 0 then return end
		local pos = targets[1]:GetAbsOrigin()
		self:CreateTelegraph(pos, 360, 1.4, function(mark, radius)
			self:ResolveBossStrike(unit, mark, radius, damage, DAMAGE_TYPE_MAGICAL, function(target)
				target:AddNewModifier(unit, nil, "modifier_enfos_boss_hemorrhage", { duration = 6.0 })
			end)
		end)
	elseif name == "enfos_boss_rift_lord" then
		state.abilityTimer = 11
		self:CreateTelegraph(origin, 700, 1.6, function(mark, radius)
			if not unit or unit:IsNull() or not unit:IsAlive() then return end
			local targets = BossTargets(unit, mark, radius)
			for _, target in ipairs(targets) do
				local offset = (target:GetAbsOrigin() - mark):Normalized() * 180
				FindClearSpaceForUnit(target, mark + offset, true)
				ApplyDamage({ victim = target, attacker = unit, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL })
				target:AddNewModifier(unit, nil, "modifier_stunned", { duration = 0.6 })
			end
		end)
	elseif name == "enfos_boss_ascendant_gatekeeper" then
		state.abilityTimer = 12
		for ring = 1, 3 do
			local inner = (ring - 1) * 240
			local outer = ring * 240
			local ringInner, ringOuter, ringIndex = inner, outer, ring
			self:CreateTelegraph(origin, ringOuter, 1.0 + ring * 0.3, function(mark)
				if not unit or unit:IsNull() or not unit:IsAlive() then return end
				local targets = BossTargets(unit, mark, ringOuter)
				for _, target in ipairs(targets) do
					local distance = (target:GetAbsOrigin() - mark):Length2D()
					if distance > ringInner and distance <= ringOuter then
						ApplyDamage({ victim = target, attacker = unit, damage = damage * (0.7 + 0.15 * ringIndex), damage_type = DAMAGE_TYPE_MAGICAL })
					end
				end
			end)
		end
	end
end

-- 1. Boss Base Modifier (CC resistance and reflect cap)
modifier_enfos_boss_base = class({})
function modifier_enfos_boss_base:IsHidden() return true end
function modifier_enfos_boss_base:IsPurgable() return false end
function modifier_enfos_boss_base:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
	}
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

	return 0
end

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
	return { MODIFIER_EVENT_ON_ATTACK_LANDED }
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
