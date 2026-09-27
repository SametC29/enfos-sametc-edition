-- Automated Behavior Tests for Batch 1 PvE Hero Kits
-- Tests: Sven, Juggernaut, Drow Ranger, Lina, Omniknight, Luna

package.path = 'game/scripts/vscripts/?.lua;' .. package.path
local passed = 0
local function test(name, fn)
    fn()
    passed = passed + 1
    print('PASS ' .. name)
end

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
DOTA_UNIT_TARGET_HERO = 1
DOTA_UNIT_TARGET_BASIC = 2
DOTA_UNIT_TARGET_FLAG_NONE = 0
DAMAGE_TYPE_PHYSICAL = 1
DAMAGE_TYPE_MAGICAL = 2
DAMAGE_TYPE_PURE = 4
DOTA_DAMAGE_FLAG_REFLECTION = 16

ParticleManager = {
    CreateParticle = function() return 1 end,
    ReleaseParticleIndex = function() end,
    SetParticleControl = function() end,
    SetParticleControlEnt = function() end,
}

ProjectileManager = {
    CreateLinearProjectile = function() return 1 end,
    CreateTrackingProjectile = function() return 1 end,
}

local applied_damages = {}
ApplyDamage = function(info)
    table.insert(applied_damages, info)
end

CreateModifierThinker = function(caster, ability, mod_name, params, origin, team, is_phantom)
    local t = create_mock_unit('thinker', team, origin)
    local cls = _G[mod_name]
    if cls then
        local m = cls()
        m.GetParent = function() return t end
        m.GetCaster = function() return caster end
        m.GetAbility = function() return ability end
        if m.OnCreated then m:OnCreated(params) end
        if m.OnIntervalThink then m:OnIntervalThink() end
    end
    return t
end

local function create_mock_unit(name, team, origin, hp)
    hp = hp or 500
    local unit = {
        name = name,
        team = team,
        origin = origin or Vector(0, 0, 0),
        hp = hp,
        max_hp = hp,
        modifiers = {},
        alive = true,
        strength = 50,
        agility = 50,
        intellect = 50,
        armor = 10,
        status_res = 0,
        idx = math.random(100, 99999),
        IsNull = function() return false end,
        IsAlive = function(self) return self.alive end,
        GetTeamNumber = function(self) return self.team end,
        GetUnitName = function(self) return self.name end,
        GetAbsOrigin = function(self) return self.origin end,
        SetAbsOrigin = function(self, pos) self.origin = pos end,
        GetMaxHealth = function(self) return self.max_hp end,
        GetHealth = function(self) return self.hp end,
        GetStrength = function(self) return self.strength end,
        GetAgility = function(self) return self.agility end,
        GetIntellect = function(self) return self.intellect end,
        GetPhysicalArmorValue = function(self) return self.armor end,
        GetStatusResistance = function(self) return self.status_res end,
        PassivesDisabled = function() return false end,
        IsIllusion = function() return false end,
        entindex = function(self) return self.idx end,
        EmitSound = function() end,
        StopSound = function() end,
        TriggerSpellAbsorb = function() return false end,
        GetAverageTrueAttackDamage = function(self) return 100 end,
        AddNewModifier = function(self, caster, ability, mod_name, params)
            self.modifiers[mod_name] = { caster = caster, ability = ability, params = params }
            return self.modifiers[mod_name]
        end,
        FindModifierByName = function(self, mod_name) return self.modifiers[mod_name] end,
        HasModifier = function(self, mod_name) return self.modifiers[mod_name] ~= nil end,
        Heal = function(self, amount, ability) self.hp = math.min(self.max_hp, self.hp + amount) end,
        FindAbilityByName = function(self, ab_name) return nil end,
        IsHero = function(self) return self.name:find("hero", 1, true) ~= nil end,
        Kill = function(self, ability, killer) self.alive = false self.hp = 0 end,
        Purge = function(self) end,
        ModifyStrength = function(self, delta) self.strength = self.strength + delta end,
        SetHealth = function(self, hp) self.hp = hp end,
        PerformAttack = function(self, target, a, b, c, d, e, f, g)
            ApplyDamage({ victim = target, attacker = self, damage = self:GetAverageTrueAttackDamage(), damage_type = DAMAGE_TYPE_PHYSICAL })
        end,
    }
    return unit
end

local mock_world_units = {}
FindUnitsInRadius = function(team, point, cache, radius, target_team, target_type, flags, order, can_grow)
    local found = {}
    for _, u in ipairs(mock_world_units) do
        if u:IsAlive() then
            local is_enemy = (u:GetTeamNumber() ~= team)
            if (target_team == DOTA_UNIT_TARGET_TEAM_ENEMY and is_enemy) or
               (target_team == DOTA_UNIT_TARGET_TEAM_FRIENDLY and not is_enemy) then
                local dist = (u:GetAbsOrigin() - point):Length2D()
                if dist <= radius then
                    table.insert(found, u)
                end
            end
        end
    end
    return found
end

FindClearSpaceForUnit = function(unit, pos, bool)
    unit:SetAbsOrigin(pos)
end

require('abilities/pve_kits')

-- =========================================================================
-- TESTS
-- =========================================================================

test('Sven Shield Slam calculates Strength and Armor scaling with knockback', function()
    applied_damages = {}
    local sven = create_mock_unit('npc_dota_hero_sven', 2, Vector(0, 0, 0))
    sven.strength = 80
    sven.armor = 25
    local creep1 = create_mock_unit('enfos_creep_melee', 3, Vector(100, 0, 0))
    local boss = create_mock_unit('enfos_boss_stonebreaker', 3, Vector(200, 0, 0))
    mock_world_units = { sven, creep1, boss }

    local ab = bulwark_shield_slam()
    ab.GetCaster = function() return sven end
    ab.GetSpecialValueFor = function(_, k)
        if k == 'damage' then return 300 end
        if k == 'radius' then return 400 end
        if k == 'slow_duration' then return 3.0 end
        if k == 'slow_pct' then return -50 end
        return 0
    end

    ab:OnSpellStart()

    -- Damage formula: 300 + (80 * 2.0) + (25 * 8.0) = 300 + 160 + 200 = 660
    assert(#applied_damages == 2, 'Should hit both enemies in radius')
    assert(applied_damages[1].damage == 660, 'Damage must scale with Strength and Armor')
    assert(creep1:GetAbsOrigin().x > 100, 'Non-boss creep must be knocked back')
    assert(boss:GetAbsOrigin().x == 200, 'Boss must NOT be knocked back')
    assert(creep1:HasModifier('modifier_bulwark_shield_slam_slow'), 'Must apply slow modifier')
end)

test('Sven Challenge taunts enemies and reduces duration by 75% on bosses', function()
    local sven = create_mock_unit('npc_dota_hero_sven', 2, Vector(0, 0, 0))
    local creep = create_mock_unit('enfos_creep_melee', 3, Vector(150, 0, 0))
    local boss = create_mock_unit('enfos_boss_stonebreaker', 3, Vector(250, 0, 0))
    mock_world_units = { sven, creep, boss }

    local ab = bulwark_challenge()
    ab.GetCaster = function() return sven end
    ab.GetSpecialValueFor = function(_, k)
        if k == 'duration' then return 4.0 end
        if k == 'radius' then return 450 end
        if k == 'bonus_armor' then return 20 end
        return 0
    end

    ab:OnSpellStart()

    assert(sven:HasModifier('modifier_enfos_pve_warcry'), 'Sven must gain Warcry buff')
    assert(creep:HasModifier('modifier_enfos_pve_taunt'), 'Creep must be taunted')
    assert(boss:HasModifier('modifier_enfos_pve_taunt'), 'Boss must be taunted')
    assert(creep.modifiers['modifier_enfos_pve_taunt'].params.duration == 4.0, 'Normal creep takes full taunt duration')
    assert(boss.modifiers['modifier_enfos_pve_taunt'].params.duration == 1.0, 'Boss taunt must be 0.25x (1.0s)')
end)

test('Sven Iron Guard damage block reflects physical damage safely without recursion', function()
    applied_damages = {}
    local sven = create_mock_unit('npc_dota_hero_sven', 2, Vector(0, 0, 0))
    local attacker = create_mock_unit('enfos_creep_melee', 3, Vector(100, 0, 0))
    mock_world_units = { sven, attacker }

    local ab = bulwark_iron_guard()
    ab.GetSpecialValueFor = function(_, k)
        if k == 'bonus_armor' then return 20 end
        if k == 'damage_block' then return 80 end
        return 0
    end

    local mod = setmetatable({
        GetParent = function() return sven end,
        GetAbility = function() return ab end
    }, modifier_bulwark_iron_guard)

    -- Normal attack: should reflect 30% of 80 = 24
    mod:OnTakeDamage({
        unit = sven,
        attacker = attacker,
        damage_flags = 0
    })
    assert(#applied_damages == 1, 'Should reflect damage')
    assert(applied_damages[1].damage == 24, '30% of 80 blocked is 24')

    -- Reflection attack: should NOT reflect (anti-recursion check)
    mod:OnTakeDamage({
        unit = sven,
        attacker = attacker,
        damage_flags = DOTA_DAMAGE_FLAG_REFLECTION
    })
    assert(#applied_damages == 1, 'Reflection attack must be ignored to prevent loop')
end)

test('Luna Moon Glaives bounces across consecutive targets with 15% falloff', function()
    applied_damages = {}
    local luna = create_mock_unit('npc_dota_hero_luna', 2, Vector(0, 0, 0))
    local c1 = create_mock_unit('enfos_creep_1', 3, Vector(100, 0, 0))
    local c2 = create_mock_unit('enfos_creep_2', 3, Vector(250, 0, 0))
    local c3 = create_mock_unit('enfos_creep_3', 3, Vector(400, 0, 0))
    mock_world_units = { luna, c1, c2, c3 }

    local ab = enfos_luna_moon_glaives()
    ab.GetLevel = function() return 4 end

    local mod = setmetatable({
        GetParent = function() return luna end,
        GetAbility = function() return ab end
    }, modifier_enfos_luna_moon_glaives_passive)

    mod:OnAttackLanded({
        attacker = luna,
        target = c1
    })

    -- c1 was hit by basic attack. Glaive bounces: c1 -> c2 -> c3
    assert(#applied_damages >= 2, 'Glaive must bounce to other units')
    assert(applied_damages[1].victim == c2, 'First bounce must hit c2')
    assert(applied_damages[2].victim == c3, 'Second bounce must hit c3')
    local expected_dmg1 = 100 * 0.85
    local expected_dmg2 = expected_dmg1 * 0.85
    assert(math.abs(applied_damages[1].damage - expected_dmg1) < 0.01, 'Bounce 1 should apply 85% damage')
    assert(math.abs(applied_damages[2].damage - expected_dmg2) < 0.01, 'Bounce 2 should apply 85% * 85% damage')
end)

test('Luna Lucent Beam applies Agility scaling and triggers Lunar Resonance on nearby foes', function()
    applied_damages = {}
    local luna = create_mock_unit('npc_dota_hero_luna', 2, Vector(0, 0, 0))
    luna.agility = 100
    local target = create_mock_unit('enfos_creep_target', 3, Vector(200, 0, 0))
    local neighbor = create_mock_unit('enfos_creep_neighbor', 3, Vector(300, 0, 0))
    mock_world_units = { luna, target, neighbor }

    local ab = enfos_luna_lucent_beam()
    ab.GetCaster = function() return luna end
    ab.GetCursorTarget = function() return target end
    ab.GetSpecialValueFor = function(_, k)
        if k == 'beam_damage' then return 400 end
        if k == 'stun_duration' then return 0.4 end
        return 0
    end

    ab:OnSpellStart()

    -- Primary damage: 400 + (100 * 1.5) = 550
    -- Secondary resonance damage: 550 * 0.6 = 330
    assert(#applied_damages == 2, 'Should hit target and resonance neighbor')
    assert(applied_damages[1].victim == target and applied_damages[1].damage == 550)
    assert(applied_damages[2].victim == neighbor and applied_damages[2].damage == 330)
end)

test('Drow Frost Arrows scales with Agility and shatters on creep death', function()
    applied_damages = {}
    local drow = create_mock_unit('npc_dota_hero_drow_ranger', 2, Vector(0, 0, 0))
    drow.agility = 120
    local creep = create_mock_unit('enfos_creep_chilled', 3, Vector(200, 0, 0))
    local nearby_creep = create_mock_unit('enfos_creep_nearby', 3, Vector(250, 0, 0))
    mock_world_units = { drow, creep, nearby_creep }

    local ab = enfos_drow_frost_arrows()
    ab.GetSpecialValueFor = function(_, k)
        if k == 'bonus_damage' then return 60 end
        if k == 'agility_factor' then return 0.5 end
        if k == 'duration' then return 3.0 end
        if k == 'slow_pct' then return -50 end
        return 0
    end

    local mod = setmetatable({
        GetParent = function() return drow end,
        GetAbility = function() return ab end
    }, modifier_enfos_pve_frost)

    mod:OnAttackLanded({
        attacker = drow,
        target = creep
    })

    -- Damage: 60 + (120 * 0.5) = 120
    assert(#applied_damages == 1)
    assert(applied_damages[1].damage == 120)
    assert(creep:HasModifier('modifier_enfos_pve_slow'), 'Must apply slow')

    -- Now test shatter on death
    mod:OnDeath({
        unit = creep
    })
    -- Shatter damage: 80 + (120 * 0.4) = 128
    assert(#applied_damages == 2, 'Shatter should deal AoE damage to nearby creep')
    assert(applied_damages[2].victim == nearby_creep)
    assert(applied_damages[2].damage == 128)
end)

test('Drow Marksmanship procs armor-piercing bonus and splinters to 3 targets', function()
    applied_damages = {}
    local drow = create_mock_unit('npc_dota_hero_drow_ranger', 2, Vector(0, 0, 0))
    drow.agility = 100
    local target = create_mock_unit('enfos_target', 3, Vector(200, 0, 0))
    local c1 = create_mock_unit('c1', 3, Vector(250, 0, 0))
    local c2 = create_mock_unit('c2', 3, Vector(260, 0, 0))
    local c3 = create_mock_unit('c3', 3, Vector(270, 0, 0))
    mock_world_units = { drow, target, c1, c2, c3 }

    local ab = enfos_drow_marksmanship()
    ab.GetSpecialValueFor = function(_, k)
        if k == 'proc_chance' then return 100 end
        if k == 'bonus_damage' then return 200 end
        return 0
    end

    local mod = setmetatable({
        GetParent = function() return drow end,
        GetAbility = function() return ab end
    }, modifier_enfos_pve_marksmanship)

    mod:OnAttackLanded({
        attacker = drow,
        target = target
    })

    -- Target receives 200 + (100 * 0.5) = 250 bonus damage
    -- 3 splinter arrows hit c1, c2, c3 for 100 * 0.6 = 60
    assert(#applied_damages == 4, 'Must hit primary target and 3 splinter targets')
    assert(applied_damages[1].victim == target and applied_damages[1].damage == 250)
    for i = 2, 4 do
        assert(applied_damages[i].damage == 60, 'Splinter arrows should deal 60% true damage')
    end
end)

test('Juggernaut Duelist stacks on kill and caps at 10 with lifesteal', function()
    local jugg = create_mock_unit('npc_dota_hero_juggernaut', 2, Vector(0, 0, 0))
    local enemy = create_mock_unit('enfos_creep', 3, Vector(100, 0, 0))
    mock_world_units = { jugg, enemy }

    local ab = enfos_juggernaut_duelist()
    local stack_mod = setmetatable({
        count = 0,
        GetStackCount = function(self) return self.count end,
        SetStackCount = function(self, n) self.count = n end,
        SetDuration = function() end,
        GetParent = function() return jugg end,
        GetAbility = function() return ab end
    }, modifier_enfos_juggernaut_duelist_stack)

    jugg.FindModifierByName = function(_, name)
        if name == 'modifier_enfos_juggernaut_duelist_stack' then return stack_mod end
    end

    local duelist_mod = setmetatable({
        GetParent = function() return jugg end,
        GetAbility = function() return ab end
    }, modifier_enfos_juggernaut_duelist)

    for i = 1, 15 do
        duelist_mod:OnDeath({ attacker = jugg, unit = enemy })
    end

    assert(stack_mod:GetStackCount() == 10, 'Duelist stacks must cap at 10')
    assert(stack_mod:GetModifierAttackSpeedBonus_Constant() == 120, '10 stacks = 120 attack speed')
    assert(stack_mod:GetModifierPhysicalArmorBonus() == 20, '10 stacks = 20 armor')

    -- At 10 stacks, lifesteal active:
    jugg.hp = 300
    stack_mod:OnAttackLanded({
        attacker = jugg,
        damage = 200
    })
    -- 20% of 200 = 40 heal
    assert(jugg.hp == 340, 'Lifesteal at 10 stacks should heal 40 HP')
end)

test('Lina Combustion burns on spell hit and triggers corpse detonation on death with boss cap', function()
    applied_damages = {}
    local lina = create_mock_unit('npc_dota_hero_lina', 2, Vector(0, 0, 0))
    lina.intellect = 100
    local creep = create_mock_unit('enfos_creep_burning', 3, Vector(200, 0, 0), 1000)
    local neighbor = create_mock_unit('enfos_neighbor', 3, Vector(250, 0, 0))
    local boss = create_mock_unit('enfos_boss_test', 3, Vector(200, 0, 0), 50000)
    mock_world_units = { lina, creep, neighbor }

    local ab = enfos_lina_combustion()
    ab.GetSpecialValueFor = function(_, k)
        if k == 'spell_amp' then return 20 end
        if k == 'burn_duration' then return 3.0 end
        if k == 'burn_dps' then return 80 end
        return 0
    end

    local mod = setmetatable({
        GetParent = function() return lina end,
        GetAbility = function() return ab end
    }, modifier_enfos_pve_combustion)

    -- Spell hit applies burn
    mod:OnTakeDamage({
        attacker = lina,
        unit = creep,
        inflictor = { IsItem = function() return false end }
    })
    assert(creep:HasModifier('modifier_enfos_pve_burn'), 'Combustion must apply burn')

    -- Creep dies while burning: detonates for 120 + 8% of 1000 = 120 + 80 = 200
    mod:OnDeath({ unit = creep })
    assert(#applied_damages == 1)
    assert(applied_damages[1].victim == neighbor and applied_damages[1].damage == 200)

    -- Now test boss cap: 50,000 HP boss dying would be 4,000 dmg, but capped at 600 max health component
    applied_damages = {}
    mock_world_units = { lina, boss, neighbor }
    boss.modifiers['modifier_enfos_pve_burn'] = true
    mod:OnDeath({ unit = boss })
    assert(#applied_damages == 1)
    assert(applied_damages[1].damage == (120 + 600), 'Boss corpse explosion must be capped at 720 total')
end)

test('Omniknight Purification heals ally and deals matching Pure AoE damage to all surrounding enemies', function()
    applied_damages = {}
    local omni = create_mock_unit('npc_dota_hero_omniknight', 2, Vector(0, 0, 0))
    omni.strength = 100
    local injured_ally = create_mock_unit('npc_dota_hero_sven', 2, Vector(100, 0, 0), 1000)
    injured_ally.hp = 400
    local e1 = create_mock_unit('enemy_1', 3, Vector(150, 0, 0))
    local e2 = create_mock_unit('enemy_2', 3, Vector(250, 0, 0))
    mock_world_units = { omni, injured_ally, e1, e2 }

    local ab = enfos_omni_purification()
    ab.GetCaster = function() return omni end
    ab.GetCursorTarget = function() return injured_ally end
    ab.GetSpecialValueFor = function(_, k)
        if k == 'heal_amount' then return 500 end
        if k == 'radius' then return 400 end
        return 0
    end

    ab:OnSpellStart()

    -- Heal amount: 500 + (100 * 2.0) = 700
    assert(injured_ally.hp == 1000, 'Ally should be healed for 700 (capped at max hp)')
    assert(#applied_damages == 2, 'Both enemies within 400 of ally must be hit')
    assert(applied_damages[1].damage == 700 and applied_damages[1].damage_type == DAMAGE_TYPE_PURE)
    assert(applied_damages[2].damage == 700 and applied_damages[2].damage_type == DAMAGE_TYPE_PURE)
end)

test('Omniknight Hammer of Purity deals Pure damage with splash and heals caster', function()
    applied_damages = {}
    local omni = create_mock_unit('npc_dota_hero_omniknight', 2, Vector(0, 0, 0))
    omni.strength = 80
    omni.hp = 300
    local target = create_mock_unit('target', 3, Vector(100, 0, 0))
    local splash = create_mock_unit('splash', 3, Vector(150, 0, 0))
    mock_world_units = { omni, target, splash }

    local ab = enfos_omni_hammer_of_purity()
    ab.GetSpecialValueFor = function(_, k)
        if k == 'bonus_pure_damage' then return 200 end
        return 0
    end

    local mod = setmetatable({
        GetParent = function() return omni end,
        GetAbility = function() return ab end
    }, modifier_enfos_pve_hammer)

    mod:OnAttackLanded({
        attacker = omni,
        target = target
    })

    -- Damage: 200 + (80 * 1.2) = 296
    -- Splash: 296 * 0.5 = 148
    -- Self-heal: 296 * 0.5 = 148 -> omni hp: 300 + 148 = 448
    assert(#applied_damages == 2)
    assert(applied_damages[1].victim == target and applied_damages[1].damage == 296)
    assert(applied_damages[2].victim == splash and applied_damages[2].damage == 148)
    assert(omni.hp == 448, 'Omniknight should be healed for 148 HP')
end)


-- =========================================================================
-- BATCH 2 TESTS: Axe, Centaur, Legion Commander, Sniper, Crystal Maiden, Dazzle
-- =========================================================================

test('Axe Berserkers Call taunts and applies 75% duration reduction on bosses', function()
    local axe = create_mock_unit('npc_dota_hero_axe', 2, Vector(0, 0, 0))
    local creep = create_mock_unit('creep_1', 3, Vector(100, 0, 0))
    local boss = create_mock_unit('enfos_boss_warlord', 3, Vector(150, 0, 0))
    mock_world_units = { axe, creep, boss }

    local ab = enfos_axe_berserkers_call()
    ab.GetCaster = function() return axe end
    ab.GetSpecialValueFor = function(_, k)
        if k == 'radius' then return 400 end
        if k == 'duration' then return 4.0 end
        if k == 'bonus_armor' then return 30 end
        return 0
    end

    ab:OnSpellStart()

    assert(axe:HasModifier('modifier_enfos_axe_call_buff'), 'Axe must receive armor buff')
    assert(creep:HasModifier('modifier_enfos_axe_call_taunt'), 'Creep must receive taunt')
    assert(boss:HasModifier('modifier_enfos_axe_call_taunt'), 'Boss must receive taunt')
    local creep_dur = creep.modifiers['modifier_enfos_axe_call_taunt'].params.duration
    local boss_dur = boss.modifiers['modifier_enfos_axe_call_taunt'].params.duration
    assert(creep_dur == 4.0, 'Creep taunt must last 4.0s')
    assert(boss_dur == 1.0, 'Boss taunt must be reduced by 75% (1.0s)')
end)

test('Axe Counter Helix procs pure damage scaling with Strength on attacked', function()
    applied_damages = {}
    local axe = create_mock_unit('npc_dota_hero_axe', 2, Vector(0, 0, 0))
    axe.strength = 80
    local creep1 = create_mock_unit('creep_1', 3, Vector(100, 0, 0))
    local creep2 = create_mock_unit('creep_2', 3, Vector(150, 0, 0))
    mock_world_units = { axe, creep1, creep2 }

    local ab = enfos_axe_counter_helix()
    ab.GetSpecialValueFor = function(_, k)
        if k == 'trigger_chance' then return 100 end
        if k == 'helix_damage' then return 200 end
        if k == 'radius' then return 300 end
        return 0
    end

    local mod = setmetatable({
        GetParent = function() return axe end,
        GetAbility = function() return ab end
    }, modifier_enfos_axe_counter_helix_passive)
    mod:OnCreated()

    mod:OnAttacked({
        attacker = creep1,
        target = axe
    })

    -- Damage: 200 + (80 * 1.0) = 280 pure
    assert(#applied_damages == 2, 'Helix should hit both creeps in 300 radius')
    assert(applied_damages[1].damage == 280 and applied_damages[1].damage_type == DAMAGE_TYPE_PURE)
    assert(applied_damages[2].damage == 280 and applied_damages[2].damage_type == DAMAGE_TYPE_PURE)
end)

test('Axe Culling Blade executes target below threshold and buffs allies', function()
    applied_damages = {}
    local axe = create_mock_unit('npc_dota_hero_axe', 2, Vector(0, 0, 0))
    local low_creep = create_mock_unit('creep_low', 3, Vector(100, 0, 0), 1000)
    low_creep.hp = 250 -- 25% health (below 35% threshold)
    local ally = create_mock_unit('npc_dota_hero_sven', 2, Vector(200, 0, 0))
    mock_world_units = { axe, low_creep, ally }

    local ab = enfos_axe_culling_blade()
    ab.GetCaster = function() return axe end
    ab.GetCursorTarget = function() return low_creep end
    ab.GetSpecialValueFor = function(_, k)
        if k == 'kill_threshold_pct' then return 35 end
        return 0
    end
    ab.EndCooldown = function() end

    ab:OnSpellStart()

    assert(low_creep:IsAlive() == false, 'Target below 35% HP must be executed')
    assert(axe:HasModifier('modifier_enfos_axe_culling_blade_buff'), 'Axe must get buff on kill')
    assert(ally:HasModifier('modifier_enfos_axe_culling_blade_buff'), 'Allies must get buff on kill')
end)

test('Centaur Hoof Stomp stuns and scales with Strength', function()
    applied_damages = {}
    local centaur = create_mock_unit('npc_dota_hero_centaur', 2, Vector(0, 0, 0))
    centaur.strength = 100
    local creep = create_mock_unit('creep_1', 3, Vector(100, 0, 0))
    local boss = create_mock_unit('enfos_boss_titan', 3, Vector(150, 0, 0))
    mock_world_units = { centaur, creep, boss }

    local ab = enfos_centaur_hoof_stomp()
    ab.GetCaster = function() return centaur end
    ab.GetSpecialValueFor = function(_, k)
        if k == 'damage' then return 250 end
        if k == 'radius' then return 350 end
        if k == 'stun_duration' then return 2.0 end
        return 0
    end

    ab:OnSpellStart()

    -- Damage: 250 + (100 * 1.5) = 400 physical
    assert(#applied_damages == 2)
    assert(applied_damages[1].damage == 400 and applied_damages[1].damage_type == DAMAGE_TYPE_PHYSICAL)
    assert(applied_damages[2].damage == 400 and applied_damages[2].damage_type == DAMAGE_TYPE_PHYSICAL)
    assert(creep.modifiers['modifier_enfos_centaur_hoof_stomp_stun'].params.duration == 2.0)
    assert(boss.modifiers['modifier_enfos_centaur_hoof_stomp_stun'].params.duration == 0.8, 'Boss stun reduced')
end)

test('Centaur Double Edge damages target and self, scaling with Strength and Max HP', function()
    applied_damages = {}
    local centaur = create_mock_unit('npc_dota_hero_centaur', 2, Vector(0, 0, 0), 2000)
    centaur.strength = 120
    local target = create_mock_unit('target', 3, Vector(100, 0, 0))
    local neighbor = create_mock_unit('neighbor', 3, Vector(150, 0, 0))
    mock_world_units = { centaur, target, neighbor }

    local ab = enfos_centaur_double_edge()
    ab.GetCaster = function() return centaur end
    ab.GetCursorTarget = function() return target end
    ab.GetSpecialValueFor = function(_, k)
        if k == 'edge_damage' then return 300 end
        return 0
    end

    ab:OnSpellStart()

    -- Damage: 300 + (120 * 0.6) + (2000 * 0.15) = 300 + 72 + 300 = 672 pure
    assert(#applied_damages == 2, 'Cleaves to target and neighbor')
    assert(applied_damages[1].damage == 672 and applied_damages[1].damage_type == DAMAGE_TYPE_PURE)
    -- Self damage: 672 * 0.3 = 201.6 -> Centaur HP becomes 2000 - 201.6 = 1798.4
    assert(centaur.hp < 2000 and centaur.hp > 1750, 'Centaur takes 30% self damage')
end)

test('Legion Commander Overwhelming Odds scales with enemy count in AoE', function()
    applied_damages = {}
    local lc = create_mock_unit('npc_dota_hero_legion_commander', 2, Vector(0, 0, 0))
    local c1 = create_mock_unit('creep_1', 3, Vector(100, 0, 0))
    local c2 = create_mock_unit('creep_2', 3, Vector(150, 0, 0))
    local c3 = create_mock_unit('creep_3', 3, Vector(200, 0, 0))
    local boss = create_mock_unit('enfos_boss_warlord', 3, Vector(250, 0, 0))
    mock_world_units = { lc, c1, c2, c3, boss }

    local ab = enfos_legion_overwhelming_odds()
    ab.GetCaster = function() return lc end
    ab.GetCursorPosition = function() return Vector(150, 0, 0) end
    ab.GetSpecialValueFor = function(_, k)
        if k == 'damage' then return 150 end
        if k == 'damage_per_unit' then return 40 end
        if k == 'radius' then return 600 end
        return 0
    end

    ab:OnSpellStart()

    -- Total damage: 150 + (3 creeps * 40) + (1 boss * 100) = 150 + 120 + 100 = 370 magic
    assert(#applied_damages == 4, 'Hits all 4 units in radius')
    assert(applied_damages[1].damage == 370 and applied_damages[1].damage_type == DAMAGE_TYPE_MAGICAL)
    assert(lc:HasModifier('modifier_enfos_legion_overwhelming_odds_buff'))
    local buff = lc.modifiers['modifier_enfos_legion_overwhelming_odds_buff'].params
    -- bonus AS: 3*5 + 1*30 = 45 AS
    assert(buff.bonus_as == 45, 'Bonus attack speed must match creep and boss counts')
end)

test('Sniper Keen Eye pierces line behind primary target for secondary damage', function()
    applied_damages = {}
    local sniper = create_mock_unit('npc_dota_hero_sniper', 2, Vector(0, 0, 0))
    local primary = create_mock_unit('primary', 3, Vector(200, 0, 0))
    local behind = create_mock_unit('behind', 3, Vector(350, 0, 0))
    mock_world_units = { sniper, primary, behind }

    local ab = enfos_sniper_keen_eye()
    local mod = setmetatable({
        GetParent = function() return sniper end,
        GetAbility = function() return ab end
    }, modifier_enfos_sniper_keen_eye_passive)

    mod:OnAttackLanded({
        attacker = sniper,
        target = primary,
        damage = 300
    })

    -- 60% of 300 = 180 physical to behind unit
    assert(#applied_damages == 1, 'Secondary enemy behind must be pierced')
    assert(applied_damages[1].victim == behind and applied_damages[1].damage == 180)
end)

test('Crystal Maiden Glacial Mastery triggers 5-stack Glacial Shatter with boss cap', function()
    applied_damages = {}
    local cm = create_mock_unit('npc_dota_hero_crystal_maiden', 2, Vector(0, 0, 0))
    local boss = create_mock_unit('enfos_boss_hydra', 3, Vector(100, 0, 0), 20000)
    local neighbor = create_mock_unit('neighbor', 3, Vector(150, 0, 0))
    mock_world_units = { cm, boss, neighbor }

    local ab = enfos_cm_glacial_mastery()
    local stack_mod = setmetatable({
        GetParent = function() return boss end,
        GetCaster = function() return cm end,
        GetAbility = function() return ab end,
        count = 4,
        GetStackCount = function(self) return self.count end,
        SetStackCount = function(self, c) self.count = c end,
        Destroy = function(self) end
    }, modifier_enfos_cm_frost_stack)

    -- 5th stack triggers shatter
    stack_mod:OnRefresh()

    -- Max HP damage: 20000 * 0.10 = 2000, capped at 600 for bosses. Total damage: 150 + 600 = 750
    assert(#applied_damages == 2, 'Shatter hits boss and neighbor in 300 radius')
    assert(applied_damages[1].damage == 750 and applied_damages[1].damage_type == DAMAGE_TYPE_MAGICAL)
    assert(applied_damages[2].damage == 750 and applied_damages[2].damage_type == DAMAGE_TYPE_MAGICAL)
end)

test('Dazzle Shadow Wave heals jumping allies and deals pure physical damage around each', function()
    applied_damages = {}
    local dazzle = create_mock_unit('npc_dota_hero_dazzle', 2, Vector(0, 0, 0))
    dazzle.intellect = 80
    local frontline = create_mock_unit('ally_tank', 2, Vector(200, 0, 0), 1000)
    frontline.hp = 500
    local e1 = create_mock_unit('swarm_1', 3, Vector(220, 0, 0))
    local e2 = create_mock_unit('swarm_2', 3, Vector(250, 0, 0))
    mock_world_units = { dazzle, frontline, e1, e2 }

    local ab = enfos_dazzle_shadow_wave()
    ab.GetCaster = function() return dazzle end
    ab.GetCursorTarget = function() return frontline end
    ab.GetSpecialValueFor = function(_, k)
        if k == 'heal_amount' then return 170 end
        return 0
    end

    ab:OnSpellStart()

    -- Heal: 170 + (80 * 1.0) = 250
    assert(frontline.hp == 750, 'Frontline ally must be healed for 250')
    -- Damage: around frontline, both swarm_1 (dist 20) and swarm_2 (dist 50) are within 200 radius
    assert(#applied_damages == 2, 'Both swarming creeps around frontline must take 250 physical damage')
    assert(applied_damages[1].damage == 250 and applied_damages[1].damage_type == DAMAGE_TYPE_PHYSICAL)
    assert(applied_damages[2].damage == 250 and applied_damages[2].damage_type == DAMAGE_TYPE_PHYSICAL)
end)

print(passed .. ' hero kit regression tests passed (mock engine).')
