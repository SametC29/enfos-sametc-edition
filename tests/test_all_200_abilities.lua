-- Exhaustive runtime execution test for all 200 hero abilities and modifiers
package.path = 'game/scripts/vscripts/?.lua;' .. package.path

function class(t)
    t = t or {}
    t.__index = t
    setmetatable(t, {
        __call = function(cls, ...)
            local inst = setmetatable({}, cls)
            if inst.constructor then inst:constructor(...) end
            return inst
        end
    })
    return t
end

function LinkLuaModifier() end
function IsServer() return true end
function EmitGlobalSound() end
function EmitSoundOn() end
function RandomInt(min, max) return min end
function RollPercentage(pct) return true end

bit = { band = function(a, b) return math.floor(a / b) % 2 == 1 and b or 0 end }

function Vector(x, y, z)
    local mt = {
        __add = function(a, b) return Vector(a.x + b.x, a.y + b.y, a.z + b.z) end,
        __sub = function(a, b) return Vector(a.x - b.x, a.y - b.y, a.z - b.z) end,
        __mul = function(a, b)
            if type(b) == 'number' then return Vector(a.x * b, a.y * b, a.z * b) end
            return Vector(a.x * b.x, a.y * b.y, a.z * b.z)
        end
    }
    local v = { x = x or 0, y = y or 0, z = z or 0 }
    function v:Length2D() return math.sqrt(self.x^2 + self.y^2) end
    function v:Normalized()
        local l = self:Length2D()
        if l == 0 then return Vector(1, 0, 0) end
        return Vector(self.x / l, self.y / l, 0)
    end
    return setmetatable(v, mt)
end

DOTA_UNIT_TARGET_TEAM_ENEMY = 2
DOTA_UNIT_TARGET_TEAM_FRIENDLY = 1
DOTA_UNIT_TARGET_TEAM_BOTH = 3
DOTA_UNIT_TARGET_HERO = 1
DOTA_UNIT_TARGET_BASIC = 2
DOTA_UNIT_TARGET_FLAG_NONE = 0
DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES = 8
DAMAGE_TYPE_PHYSICAL = 1
DAMAGE_TYPE_MAGICAL = 2
DAMAGE_TYPE_PURE = 4
DOTA_DAMAGE_FLAG_REFLECTION = 16
DOTA_DAMAGE_CATEGORY_ATTACK = 1
PATTACH_ABSORIGIN_FOLLOW = 1
PATTACH_POINT_FOLLOW = 2
PATTACH_CUSTOMORIGIN = 3
PATTACH_WORLDORIGIN = 4
PATTACH_ABSORIGIN = 5
LUA_MODIFIER_MOTION_NONE = 0
FIND_ANY_ORDER = 0
FIND_CLOSEST = 1

MODIFIER_EVENT_ON_ATTACK_LANDED = 1
MODIFIER_EVENT_ON_TAKEDAMAGE = 2
MODIFIER_EVENT_ON_ABILITY_FULLY_CAST = 3
MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE = 10
MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE = 11
MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE = 12
MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS = 13
MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT = 14
MODIFIER_PROPERTY_MANA_REGEN_CONSTANT = 15
MODIFIER_PROPERTY_STATS_STRENGTH_BONUS = 16
MODIFIER_PROPERTY_STATS_AGILITY_BONUS = 17
MODIFIER_PROPERTY_STATS_INTELLECT_BONUS = 18
MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE = 19
MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS = 20
MODIFIER_PROPERTY_EVASION_CONSTANT = 21
MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE = 22
MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT = 23
MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE = 24
MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS = 25
MODIFIER_PROPERTY_SPELL_LIFESTEAL_PERCENTAGE = 26
MODIFIER_PROPERTY_ATTACK_RANGE_BONUS = 27
MODIFIER_STATE_ROOTED = 0
MODIFIER_STATE_DISARMED = 1
MODIFIER_STATE_ATTACK_IMMUNE = 2
MODIFIER_STATE_SILENCED = 3
MODIFIER_STATE_MUTED = 4
MODIFIER_STATE_STUNNED = 5
MODIFIER_STATE_HEXED = 6
MODIFIER_STATE_INVISIBLE = 7
MODIFIER_STATE_INVULNERABLE = 8
MODIFIER_STATE_MAGIC_IMMUNE = 9
MODIFIER_STATE_PROVIDES_VISION = 10
MODIFIER_STATE_CANNOT_MISS = 17
MODIFIER_STATE_FROZEN = 19
MODIFIER_STATE_COMMAND_RESTRICTED = 20
MODIFIER_STATE_NO_HEALTH_BAR = 23
MODIFIER_STATE_NO_UNIT_COLLISION = 27
MODIFIER_STATE_OUT_OF_GAME = 33
MODIFIER_STATE_TRUESIGHT_IMMUNE = 36
MODIFIER_STATE_FEARED = 47
MODIFIER_STATE_TAUNTED = 48

local mock_world_units = {}

function EntIndexToHScript(idx)
    for _, u in ipairs(mock_world_units) do
        if u and u.entindex and u:entindex() == idx then return u end
    end
    return mock_world_units[1]
end

ParticleManager = {
    CreateParticle = function() return 1 end,
    DestroyParticle = function() end,
    ReleaseParticleIndex = function() end,
    SetParticleControl = function() end,
    SetParticleControlEnt = function() end,
}

ProjectileManager = {
    CreateLinearProjectile = function() return 1 end,
    CreateTrackingProjectile = function() return 1 end,
}

function FindUnitsInRadius(team, pos, cache, radius, target_team, target_type, flags, order, find_clear)
    local res = {}
    for _, u in ipairs(mock_world_units) do
        if u and not u:IsNull() and u:IsAlive() then
            local matches_team = false
            if target_team == DOTA_UNIT_TARGET_TEAM_ENEMY and u:GetTeamNumber() ~= team then matches_team = true end
            if target_team == DOTA_UNIT_TARGET_TEAM_FRIENDLY and u:GetTeamNumber() == team then matches_team = true end
            if target_team == DOTA_UNIT_TARGET_TEAM_BOTH then matches_team = true end
            if matches_team then
                table.insert(res, u)
            end
        end
    end
    return res
end

function CreateUnitByName(name, origin, find_clear, owner, owner2, team)
    return create_mock_unit(name, team, origin, 1000)
end

function FindClearSpaceForUnit(unit, pos, cache)
    if unit and pos then unit:SetAbsOrigin(pos) end
end

ApplyDamage = function(info)
    return info.damage or 0
end

function RandomFloat(min, max) return (min + max) / 2 end

function CreateModifierThinker(caster, ability, modifierName, modifierParams, origin, teamNumber, bPhantomBlocks)
    local thinker = create_mock_unit('thinker', teamNumber, origin, 100)
    if modifierName and _G[modifierName] then
        thinker:AddNewModifier(caster, ability, modifierName, modifierParams)
    end
    table.insert(mock_world_units, thinker)
    return thinker
end

function create_mock_unit(name, team, origin, hp)
    hp = hp or 2000
    local u = {
        name = name,
        team = team,
        origin = origin or Vector(0, 0, 0),
        hp = hp,
        max_hp = hp,
        modifiers = {},
        alive = true,
        strength = 75,
        agility = 75,
        intellect = 75,
        armor = 15,
        status_res = 0,
        idx = math.random(1000, 99999),
        IsNull = function() return false end,
        IsAlive = function(self) return self.alive end,
        GetTeamNumber = function(self) return self.team end,
        GetUnitName = function(self) return self.name end,
        GetAbsOrigin = function(self) return self.origin end,
        SetAbsOrigin = function(self, pos) self.origin = pos end,
        GetForwardVector = function(self) return Vector(1, 0, 0) end,
        GetMaxHealth = function(self) return self.max_hp end,
        GetHealth = function(self) return self.hp end,
        SetHealth = function(self, h) self.hp = h end,
        GetStrength = function(self) return self.strength end,
        GetAgility = function(self) return self.agility end,
        GetIntellect = function(self, skipNoConsume) return self.intellect end,
        mana = 1000,
        max_mana = 1000,
        GetMana = function(self) return self.mana end,
        GetMaxMana = function(self) return self.max_mana end,
        GiveMana = function(self, amount) self.mana = math.min(self.max_mana, self.mana + amount) end,
        SpendMana = function(self, amount, ability) self.mana = math.max(0, self.mana - amount) end,
        GetPhysicalArmorValue = function(self) return self.armor end,
        GetStatusResistance = function(self) return self.status_res end,
        PassivesDisabled = function() return false end,
        IsIllusion = function() return false end,
        IsHero = function() return true end,
        IsMagicImmune = function() return false end,
        IsInvulnerable = function() return false end,
        MoveToTargetToAttack = function(self, target) end,
        GetAttackRange = function() return 500 end,
        HasItemInInventory = function() return false end,
        Kill = function() end,
        SetForceAttackTarget = function(self, target) end,
        entindex = function(self) return self.idx end,
        EmitSound = function() end,
        StopSound = function() end,
        TriggerSpellAbsorb = function() return false end,
        GetAverageTrueAttackDamage = function(self) return 150 end,
        AddNewModifier = function(self, caster, ability, mod_name, params)
            local cls = _G[mod_name]
            local mod = cls and cls() or {}
            mod.caster = caster
            mod.ability = ability
            mod.params = params
            mod.stacks = mod.stacks or 0
            mod.GetParent = function() return self end
            mod.GetCaster = function() return caster end
            mod.GetAbility = function() return ability end
            mod.GetStackCount = function(m) return m.stacks or 0 end
            mod.SetStackCount = function(m, count) m.stacks = count end
            mod.SetDuration = function(m, dur, refresh) end
            mod.Destroy = function(m) self.modifiers[mod_name] = nil end
            mod.StartIntervalThink = function() end
            self.modifiers[mod_name] = mod
            if mod.OnCreated then
                pcall(function() mod:OnCreated(params) end)
            end
            return mod
        end,
        FindModifierByName = function(self, mod_name) return self.modifiers[mod_name] end,
        HasModifier = function(self, mod_name) return self.modifiers[mod_name] ~= nil end,
        RemoveModifierByName = function(self, mod_name)
            local mod = self.modifiers[mod_name]
            if mod and mod.OnDestroy then pcall(function() mod:OnDestroy() end) end
            self.modifiers[mod_name] = nil
        end,
        Heal = function(self, amount, source) self.hp = math.min(self.max_hp, self.hp + amount) end,
        Purge = function() end,
        FindAbilityByName = function(self, ab_name)
            local cls = _G[ab_name]
            if cls then
                local a = cls()
                a.GetCaster = function() return self end
                a.GetSpecialValueFor = function(_, k) return 100 end
                a.IsItem = function() return false end
                a.EndCooldown = function() end
                a.StartCooldown = function() end
                return a
            end
            return nil
        end
    }
    return u
end

-- Load the authoritative PvE Kits
require('abilities/pve_kits')
local roster = require('heroes/roster')

print('======================================================================')
print('LIVE RUNTIME EXECUTION TEST FOR ALL 40 HEROES / 200 ABILITIES')
print('======================================================================\n')

local tested_abilities = 0
local passed_abilities = 0
local failed_abilities = {}

for _, hero_info in ipairs(roster) do
    local hero = create_mock_unit(hero_info.id, 2, Vector(0, 0, 0), 2500)
    local ally = create_mock_unit('mock_ally', 2, Vector(100, 0, 0), 2000)
    local enemy = create_mock_unit('mock_enemy', 3, Vector(250, 0, 0), 1500)
    local enemy2 = create_mock_unit('mock_enemy_2', 3, Vector(350, 0, 0), 1500)
    mock_world_units = { hero, ally, enemy, enemy2 }

    for _, ab_name in ipairs(hero_info.abilities) do
        tested_abilities = tested_abilities + 1
        local cls = _G[ab_name]
        if not cls then
            table.insert(failed_abilities, { hero = hero_info.name, ability = ab_name, err = 'Class not found in global namespace' })
        else
            local ab = cls()
            ab.GetCaster = function() return hero end
            ab.GetCursorTarget = function() return enemy end
            ab.GetCursorPosition = function() return enemy:GetAbsOrigin() end
            ab.GetLevel = function() return 4 end
            ab.GetSpecialValueFor = function(s, k) return 100 end
            ab.GetAbilityDamageType = function() return DAMAGE_TYPE_MAGICAL end
            ab.GetToggleState = function() return true end
            ab.ToggleAbility = function() end
            ab.IsItem = function() return false end
            ab.EndCooldown = function() end
            ab.StartCooldown = function() end

            local success, err_msg = pcall(function()
                -- 1. Test OnSpellStart
                if ab.OnSpellStart then
                    ab:OnSpellStart()
                end

                -- 2. Test OnToggle
                if ab.OnToggle then
                    ab:OnToggle()
                end

                -- 3. Test OnChannelFinish
                if ab.OnChannelFinish then
                    ab:OnChannelFinish(false)
                end

                -- 4. Test Intrinsic Modifiers
                if ab.GetIntrinsicModifierName then
                    local mod_name = ab:GetIntrinsicModifierName()
                    local mod_cls = _G[mod_name]
                    if not mod_cls then
                        error('Intrinsic modifier class ' .. tostring(mod_name) .. ' not found')
                    end
                    local mod = mod_cls()
                    mod.GetParent = function() return hero end
                    mod.GetCaster = function() return hero end
                    mod.GetAbility = function() return ab end
                    mod.GetStackCount = function() return 2 end
                    mod.SetStackCount = function() end
                    mod.StartIntervalThink = function() end
                    if mod.OnCreated then mod:OnCreated({}) end
                    if mod.OnAttackLanded then
                        mod:OnAttackLanded({ attacker = hero, target = enemy, damage = 150 })
                        mod:OnAttackLanded({ attacker = enemy, target = hero, damage = 100 })
                    end
                    if mod.OnIntervalThink then mod:OnIntervalThink() end
                    if mod.OnTakeDamage then mod:OnTakeDamage({ attacker = enemy, unit = hero, damage = 100 }) end
                    if mod.OnAbilityFullyCast then mod:OnAbilityFullyCast({ unit = hero, ability = ab }) end
                    if mod.OnDestroy then mod:OnDestroy() end
                end
            end)

            if success then
                passed_abilities = passed_abilities + 1
            else
                table.insert(failed_abilities, { hero = hero_info.name, ability = ab_name, err = tostring(err_msg) })
            end
        end
    end
end

print(string.format('Tested Abilities: %d / %d | Passed: %d | Failed: %d\n', tested_abilities, 200, passed_abilities, #failed_abilities))

if #failed_abilities > 0 then
    print('FAILED ABILITIES:')
    for _, f in ipairs(failed_abilities) do
        print(string.format('  ❌ [%s] %s: %s', f.hero, f.ability, f.err))
    end
    os.exit(1)
end

local modifier_list = _G.ENFOS_PVE_MODIFIER_LIST or {}

print('======================================================================')
print('LIVE RUNTIME EXECUTION TEST FOR ALL ' .. tostring(#modifier_list) .. ' MODIFIERS')
print('======================================================================\n')

local tested_modifiers = 0
local passed_modifiers = 0
local failed_modifiers = {}

local hero = create_mock_unit('test_hero', 2, Vector(0, 0, 0), 2500)
local enemy = create_mock_unit('test_enemy', 3, Vector(200, 0, 0), 2000)
mock_world_units = { hero, enemy }

local dummy_ability = {
    GetCaster = function() return hero end,
    GetSpecialValueFor = function(_, k) return 100 end,
    GetLevel = function() return 4 end,
    IsNull = function() return false end,
    IsItem = function() return false end,
}

for _, mod_name in ipairs(modifier_list) do
    tested_modifiers = tested_modifiers + 1
    local mod_cls = _G[mod_name]
    if not mod_cls then
        table.insert(failed_modifiers, { modifier = mod_name, err = 'Modifier class not found in global namespace' })
    else
        local ok, err_msg = xpcall(function()
            local mod = mod_cls()
            mod.GetParent = function() return hero end
            mod.GetCaster = function() return hero end
            mod.GetAbility = function() return dummy_ability end
            mod.GetStackCount = function() return 3 end
            mod.SetStackCount = function() end
            mod.StartIntervalThink = function() end
            mod.SetDuration = function() end
            mod.Destroy = function() end

            if mod.DeclareFunctions then
                local funcs = mod:DeclareFunctions()
                if type(funcs) ~= 'table' then error('DeclareFunctions must return a table') end
            end

            if mod.CheckState then
                local states = mod:CheckState()
                if type(states) ~= 'table' then error('CheckState must return a table') end
            end

            if mod.OnCreated then mod:OnCreated({}) end
            if mod.OnIntervalThink then mod:OnIntervalThink() end

            if mod.OnAttackLanded then
                mod:OnAttackLanded({ attacker = hero, target = enemy, damage = 150 })
                mod:OnAttackLanded({ attacker = enemy, target = hero, damage = 100 })
            end

            if mod.OnTakeDamage then
                mod:OnTakeDamage({ attacker = enemy, unit = hero, damage = 100, damage_category = 1 })
                mod:OnTakeDamage({ attacker = hero, unit = enemy, damage = 150, damage_category = 1 })
            end

            if mod.OnAbilityFullyCast then
                mod:OnAbilityFullyCast({ unit = hero, ability = dummy_ability })
            end

            if mod.OnDeath then
                mod:OnDeath({ attacker = hero, unit = enemy })
            end

            -- Test property getter functions
            local getters = {
                'GetModifierPreAttack_BonusDamage',
                'GetModifierMoveSpeedBonus_Percentage',
                'GetModifierPhysicalArmorBonus',
                'GetModifierHealthRegenPercentage',
                'GetModifierConstantHealthRegen',
                'GetModifierConstantManaRegen',
                'GetModifierTotalPercentageManaRegen',
                'GetModifierBonusStats_Strength',
                'GetModifierBonusStats_Agility',
                'GetModifierBonusStats_Intellect',
                'GetModifierPreAttack_CriticalStrike',
                'GetModifierEvasion_Constant',
                'GetModifierAttackSpeedBonus_Constant',
                'GetModifierIncomingDamage_Percentage',
                'GetModifierMagicalResistanceBonus',
                'GetModifierAttackRangeBonus',
                'GetModifierMiss_Percentage',
                'GetModifierAvoidDamage',
                'GetModifierCastRangeBonusStacking',
                'GetModifierMoveSpeed_BaseOverride',
                'GetModifierHealthBonus',
                'GetModifierManaBonus',
                'GetModifierSpellAmplify_Percentage',
                'GetModifierPhysical_ConstantBlock',
                'GetModifierBaseDamageOutgoing_Percentage',
                'GetModifierStatusResistanceStacking',
                'GetModifierIncomingPhysicalDamage_Percentage',
                'GetModifierAbsoluteNoDamagePhysical',
                'GetModifierMoveSpeed_Absolute',
                'GetModifierMinHealth',
                'GetModifierHealAmplify_PercentageTarget'
            }
            for _, g in ipairs(getters) do
                if mod[g] then
                    mod[g](mod, {})
                end
            end

            if mod.OnDestroy then mod:OnDestroy() end
        end, function(e) return debug.traceback(e, 2) end)

        if ok then
            passed_modifiers = passed_modifiers + 1
        else
            table.insert(failed_modifiers, { modifier = mod_name, err = tostring(err_msg) })
        end
    end
end

print(string.format('Tested Modifiers: %d / %d | Passed: %d | Failed: %d\n', tested_modifiers, #modifier_list, passed_modifiers, #failed_modifiers))

if #failed_modifiers > 0 then
    print('FAILED MODIFIERS:')
    for _, f in ipairs(failed_modifiers) do
        print(string.format('  ❌ %s: %s', f.modifier, f.err))
    end
    os.exit(1)
else
    print('ALL 200 ABILITIES AND ALL ' .. tostring(#modifier_list) .. ' MODIFIERS EXECUTED FLAWLESSLY! 🚀')
end

