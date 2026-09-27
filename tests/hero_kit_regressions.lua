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
    DestroyParticle = function() end,
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
        mana = 500,
        max_mana = 1000,
        GetMana = function(self) return self.mana end,
        GetMaxMana = function(self) return self.max_mana end,
        GiveMana = function(self, amount) self.mana = math.min(self.max_mana, self.mana + amount) end,
        SpendMana = function(self, amount, ability) self.mana = math.max(0, self.mana - amount) end,
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
            self.modifiers[mod_name] = mod
            return mod
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
    ab.GetSpecialValueFor=function(_,key) return key=='bounce_count' and 6 or 0 end

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

test('Luna Lunar Orbit pulses physical damage scaling with Agility and cleans up particle', function()
    applied_damages = {}
    local luna = create_mock_unit('npc_dota_hero_luna', 2, Vector(0, 0, 0))
    luna.agility = 100
    local c1 = create_mock_unit('creep1', 3, Vector(100, 0, 0))
    local c2 = create_mock_unit('creep2', 3, Vector(200, 0, 0))
    mock_world_units = { luna, c1, c2 }

    local ab = enfos_luna_lunar_orbit()
    local mod = modifier_enfos_luna_lunar_orbit_buff()
    mod.GetParent = function() return luna end
    mod.GetAbility = function() return ab end

    mod:OnCreated()
    assert(mod.pfx ~= nil, 'Ambient particle must be created')

    -- 50 + (100 * 0.4) = 90 physical damage
    mod:OnIntervalThink()
    assert(#applied_damages == 2, 'Both creeps within 320 radius should take pulse damage')
    assert(applied_damages[1].damage == 90 and applied_damages[1].damage_type == DAMAGE_TYPE_PHYSICAL)

    mod:OnDestroy()
    assert(mod.pfx == nil, 'Ambient particle must be destroyed on buff expiration')
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

test('Bristleback Quill Spray stacks damage and triggers Warpath stacks', function()
    applied_damages = {}
    local bb = create_mock_unit('npc_dota_hero_bristleback', 2, Vector(0, 0, 0))
    bb.strength = 100
    local dummy = create_mock_unit('creep_1', 3, Vector(100, 0, 0))
    mock_world_units = { bb, dummy }

    local ab = enfos_bb_quill_spray()
    ab.GetCaster = function() return bb end
    ab.GetSpecialValueFor = function(_, k)
        if k == 'base_damage' then return 80 end
        if k == 'stack_damage' then return 40 end
        return 0
    end

    -- First spray: base 80 + str*0.4 (40) = 120
    ab:OnSpellStart()
    assert(#applied_damages == 1)
    assert(applied_damages[1].damage == 120 and applied_damages[1].damage_type == DAMAGE_TYPE_PHYSICAL)

    -- Mock second spray with existing stack modifier (1 stack)
    -- total_dmg = 80 + 40 + (1 * (40 + 15)) = 175
    local debuff = dummy:FindModifierByName('modifier_enfos_bb_quill_spray_debuff')
    assert(debuff ~= nil)
    ab:OnSpellStart()
    assert(#applied_damages == 2)
    assert(applied_damages[2].damage == 175)
end)

test('Tidehunter Anchor Smash deals attack damage plus strength scaling and applies damage reduction debuff', function()
    applied_damages = {}
    local tide = create_mock_unit('npc_dota_hero_tidehunter', 2, Vector(0, 0, 0))
    tide.strength = 80
    local target = create_mock_unit('creep_tide', 3, Vector(150, 0, 0))
    mock_world_units = { tide, target }

    local ab = enfos_tide_anchor_smash()
    ab.GetCaster = function() return tide end
    ab.GetSpecialValueFor = function(_, k)
        if k == 'attack_damage_bonus' or k == 'bonus_damage' then return 160 end
        if k == 'radius' then return 450 end
        if k == 'duration' then return 6 end
        return 0
    end

    ab:OnSpellStart()
    -- dmg = attack (100) + bonus (160) + (80 * 0.75 = 60) = 320
    assert(#applied_damages == 1)
    assert(applied_damages[1].damage == 320 and applied_damages[1].damage_type == DAMAGE_TYPE_PHYSICAL)
    local debuff = target:FindModifierByName('modifier_enfos_tide_anchor_smash_debuff')
    assert(debuff ~= nil, 'Anchor smash must apply debuff')
end)

test('Wraith King Mortal Strike procs cleave damage around target', function()
    applied_damages = {}
    local wk = create_mock_unit('npc_dota_hero_skeleton_king', 2, Vector(0, 0, 0))
    local primary = create_mock_unit('primary_target', 3, Vector(100, 0, 0))
    local secondary = create_mock_unit('secondary_target', 3, Vector(150, 0, 0))
    mock_world_units = { wk, primary, secondary }

    local ab = enfos_wk_mortal_strike()
    ab.GetSpecialValueFor=function(_,key) return ({crit_chance=20,crit_mult=260})[key] or 0 end
    local mod = modifier_enfos_wk_mortal_strike_passive()
    mod.GetParent = function() return wk end
    mod.GetAbility = function() return ab end

    local crit = mod:GetModifierPreAttack_CriticalStrike()
    assert(crit == 260, 'Mortal Strike crit must be 260%')
    mod:OnAttackLanded({ attacker = wk, target = primary, damage = 300 })

    -- Cleave damage to secondary: 300 * 0.5 = 150
    assert(#applied_damages == 1)
    assert(applied_damages[1].victim == secondary and applied_damages[1].damage == 150)
end)

test('Phantom Assassin Coup de Grace crits and splashes 50% damage in AoE', function()
    applied_damages = {}
    local pa = create_mock_unit('npc_dota_hero_phantom_assassin', 2, Vector(0, 0, 0))
    local primary = create_mock_unit('pa_target', 3, Vector(100, 0, 0))
    local swarm = create_mock_unit('pa_swarm', 3, Vector(130, 0, 0))
    mock_world_units = { pa, primary, swarm }

    local ab = enfos_pa_coup_de_grace()
    ab.GetSpecialValueFor=function(_,key) return ({crit_chance=15,crit_mult=425})[key] or 0 end
    local mod = modifier_enfos_pa_coup_de_grace_passive()
    mod.GetParent = function() return pa end
    mod.GetAbility = function() return ab end

    local crit = mod:GetModifierPreAttack_CriticalStrike()
    assert(crit == 425, 'Coup de Grace crit must be 425%')
    mod:OnAttackLanded({ attacker = pa, target = primary, damage = 500 })

    -- Splash to swarm: 500 * 0.5 = 250
    assert(#applied_damages == 1)
    assert(applied_damages[1].victim == swarm and applied_damages[1].damage == 250)
end)

test('Zeus Arc Lightning damages initial target and jumps with Intellect scaling', function()
    applied_damages = {}
    local zeus = create_mock_unit('npc_dota_hero_zuus', 2, Vector(0, 0, 0))
    zeus.intellect = 50
    local creep1 = create_mock_unit('creep1', 3, Vector(100, 0, 0), 1000)
    local creep2 = create_mock_unit('creep2', 3, Vector(200, 0, 0), 1000)
    mock_world_units = { zeus, creep1, creep2 }

    local ab = enfos_zeus_arc_lightning()
    ab.GetCaster = function() return zeus end
    ab.GetCursorTarget = function() return creep1 end
    ab.GetSpecialValueFor = function(_, k)
        if k == 'damage' then return 90 end
        if k == 'jump_count' then return 5 end
        return 0
    end

    ab:OnSpellStart()

    -- 90 base + 50 * 0.6 = 120 magical damage to both creep1 and creep2
    assert(#applied_damages == 2, 'expected 2 hits for arc lightning, got ' .. #applied_damages)
    assert(applied_damages[1].victim == creep1 and applied_damages[1].damage == 120)
    assert(applied_damages[2].victim == creep2 and applied_damages[2].damage == 120)
    assert(applied_damages[1].damage_type == DAMAGE_TYPE_MAGICAL)
end)

test('Zeus Static Field deals current HP percent damage with boss cap', function()
    applied_damages = {}
    local zeus = create_mock_unit('npc_dota_hero_zuus', 2, Vector(0, 0, 0))
    local creep = create_mock_unit('creep_zeus', 3, Vector(100, 0, 0), 1000)
    local boss = create_mock_unit('enfos_boss_titan', 3, Vector(200, 0, 0), 30000)
    mock_world_units = { zeus, creep, boss }

    local ab = enfos_zeus_static_field()
    ab.GetSpecialValueFor = function(_, k)
        if k == 'damage_pct' then return 8 end
        return 0
    end
    local mod = modifier_enfos_zeus_static_field_passive()
    mod.GetParent = function() return zeus end
    mod.GetAbility = function() return ab end

    mod:OnAbilityFullyCast({ unit = zeus, ability = {} })

    -- Creep: 1000 * 0.08 = 80 magical dmg
    -- Boss: 30000 * 0.08 = 2400 -> capped at 500
    assert(#applied_damages == 2)
    assert(applied_damages[1].victim == creep and applied_damages[1].damage == 80)
    assert(applied_damages[2].victim == boss and applied_damages[2].damage == 500)
end)

test('Witch Doctor Paralyzing Cask bounces and reduces boss stun duration', function()
    applied_damages = {}
    local wd = create_mock_unit('npc_dota_hero_witch_doctor', 2, Vector(0, 0, 0))
    wd.intellect = 50
    local boss = create_mock_unit('enfos_boss_wd', 3, Vector(100, 0, 0), 10000)
    local creep = create_mock_unit('creep_wd', 3, Vector(150, 0, 0), 500)
    mock_world_units = { wd, boss, creep }

    local ab = enfos_wd_paralyzing_cask()
    ab.GetCaster = function() return wd end
    ab.GetCursorTarget = function() return boss end
    ab.GetSpecialValueFor = function(_, k)
        if k == 'damage' then return 100 end
        if k == 'bounces' then return 3 end
        return 0
    end

    ab:OnSpellStart()

    -- Damage per bounce: 100 + (50 * 0.4) = 120
    assert(#applied_damages >= 2, 'Cask must bounce between boss and creep')
    assert(applied_damages[1].damage == 120 and applied_damages[1].damage_type == DAMAGE_TYPE_MAGICAL)
    local boss_stun = boss:FindModifierByName('modifier_enfos_wd_paralyzing_cask_stun')
    assert(boss_stun ~= nil and boss_stun.params.duration == 0.3, 'Boss stun duration must be reduced to 0.3s')
    local creep_stun = creep:FindModifierByName('modifier_enfos_wd_paralyzing_cask_stun')
    assert(creep_stun ~= nil and creep_stun.params.duration == 1.0, 'Creep stun duration must be 1.0s')
end)

test('Dragon Knight Breathe Fire deals magic damage and reduces enemy attack damage', function()
    applied_damages = {}
    local dk = create_mock_unit('npc_dota_hero_dragon_knight', 2, Vector(0, 0, 0))
    dk.strength = 80
    local dummy = create_mock_unit('creep_dk', 3, Vector(200, 0, 0))
    mock_world_units = { dk, dummy }

    local ab = enfos_dk_breathe_fire()
    ab.GetCaster = function() return dk end
    ab.GetCursorPosition = function() return Vector(300, 0, 0) end
    ab.GetSpecialValueFor = function(_, k)
        if k == 'damage' then return 240 end
        if k == 'reduction_pct' then return 40 end
        return 0
    end

    ab:OnSpellStart()
    -- dmg = 240 + (80 * 1.2 = 96) = 336
    assert(#applied_damages == 1)
    assert(applied_damages[1].damage == 336 and applied_damages[1].damage_type == DAMAGE_TYPE_MAGICAL)
    local debuff = dummy:FindModifierByName('modifier_enfos_dk_breathe_fire_debuff')
    assert(debuff ~= nil)
end)

test('Pudge Meat Hook deals pure damage scaling with Strength', function()
    applied_damages = {}
    local pudge = create_mock_unit('npc_dota_hero_pudge', 2, Vector(0, 0, 0))
    pudge.strength = 100
    local target = create_mock_unit('hook_target', 3, Vector(400, 0, 0))
    mock_world_units = { pudge, target }

    local ab = enfos_pudge_meat_hook()
    ab.GetCaster = function() return pudge end
    ab.GetCursorPosition = function() return Vector(500, 0, 0) end
    ab.GetSpecialValueFor = function(_, k)
        if k == 'hook_damage' then return 350 end
        return 0
    end

    ab:OnSpellStart()
    -- dmg = 350 + (100 * 1.8 = 180) = 530 Pure
    assert(#applied_damages == 1)
    assert(applied_damages[1].damage == 530 and applied_damages[1].damage_type == DAMAGE_TYPE_PURE)
end)

test('Slark Essence Shift stacks Agility on attack landed', function()
    local slark = create_mock_unit('npc_dota_hero_slark', 2, Vector(0, 0, 0))
    local creep = create_mock_unit('creep_slark', 3, Vector(100, 0, 0))
    mock_world_units = { slark, creep }

    local ab = enfos_slark_essence_shift()
    local mod = modifier_enfos_slark_essence_shift_passive()
    mod.GetParent = function() return slark end
    mod.GetAbility = function() return ab end

    mod:OnAttackLanded({ attacker = slark, target = creep })
    mod:OnAttackLanded({ attacker = slark, target = creep })

    local buff = slark:FindModifierByName('modifier_enfos_slark_essence_shift_buff')
    assert(buff ~= nil)
    assert(buff:GetStackCount() == 2)
    assert(buff:GetModifierBonusStats_Agility() == 6)
end)

test('Ursa Fury Swipes compounds damage on consecutive attacks and cleaves', function()
    applied_damages = {}
    local ursa = create_mock_unit('npc_dota_hero_ursa', 2, Vector(0, 0, 0))
    ursa.agility = 60
    local boss = create_mock_unit('boss_ursa', 3, Vector(100, 0, 0), 20000)
    local minion = create_mock_unit('minion_ursa', 3, Vector(150, 0, 0), 500)
    mock_world_units = { ursa, boss, minion }

    local ab = enfos_ursa_fury_swipes()
    ab.GetSpecialValueFor = function(_, k)
        if k == 'bonus_damage' then return 40 end
        return 0
    end
    local mod = modifier_enfos_ursa_fury_swipes_passive()
    mod.GetParent = function() return ursa end
    mod.GetAbility = function() return ab end

    -- Hit 1: stack = 1. dmg = 1 * (40 + 9) = 49. Cleave to minion = 49 * 0.35 = 17.15
    mod:OnAttackLanded({ attacker = ursa, target = boss })
    assert(#applied_damages == 2)
    assert(applied_damages[1].victim == boss and applied_damages[1].damage == 49)
    assert(applied_damages[2].victim == minion)

    -- Hit 2: stack = 2. dmg = 2 * 49 = 98
    mod:OnAttackLanded({ attacker = ursa, target = boss })
    assert(#applied_damages == 4)
    assert(applied_damages[3].victim == boss and applied_damages[3].damage == 98)
end)

test('Anti-Mage Mana Break deals physical damage scaling with Agility and cleaves', function()
    applied_damages = {}
    local am = create_mock_unit('npc_dota_hero_antimage', 2, Vector(0, 0, 0))
    am.agility = 100
    local primary = create_mock_unit('creep_am', 3, Vector(100, 0, 0))
    local secondary = create_mock_unit('creep_am_2', 3, Vector(150, 0, 0))
    mock_world_units = { am, primary, secondary }

    local ab = enfos_am_mana_break()
    ab.GetSpecialValueFor = function(_, k)
        if k == 'bonus_damage' then return 80 end
        return 0
    end
    local mod = modifier_enfos_am_mana_break_passive()
    mod.GetParent = function() return am end
    mod.GetAbility = function() return ab end

    mod:OnAttackLanded({ attacker = am, target = primary })
    -- primary dmg = 80 + (100 * 0.6 = 60) = 140
    -- secondary cleave = 140 * 0.35 = 49
    assert(#applied_damages == 2)
    assert(applied_damages[1].victim == primary and applied_damages[1].damage == 140)
    assert(applied_damages[2].victim == secondary and applied_damages[2].damage == 49)
end)

test('Lion Finger of Death splashes damage in AoE and increments stack on kill', function()
    applied_damages = {}
    local lion = create_mock_unit('npc_dota_hero_lion', 2, Vector(0, 0, 0))
    lion.intellect = 80
    local target = create_mock_unit('target_lion', 3, Vector(100, 0, 0), 100)
    local splash_creep = create_mock_unit('splash_lion', 3, Vector(120, 0, 0), 500)
    mock_world_units = { lion, target, splash_creep }

    local ab = enfos_lion_finger_of_death()
    ab.GetCaster = function() return lion end
    ab.GetCursorTarget = function() return target end
    ab.GetSpecialValueFor = function(_, k)
        if k == 'damage' then return 850 end
        return 0
    end

    -- Add finger counter modifier
    lion:AddNewModifier(lion, ab, 'modifier_enfos_lion_finger_counter', {})

    ab:OnSpellStart()
    -- dmg = 850 + (80 * 2.5 = 200) = 1050
    assert(#applied_damages == 2)
    assert(applied_damages[1].damage == 1050 and applied_damages[1].damage_type == DAMAGE_TYPE_MAGICAL)
    assert(applied_damages[2].damage == 1050 and applied_damages[2].damage_type == DAMAGE_TYPE_MAGICAL)
end)


test('Underlord Firestorm damages enemies in radius with Str scaling and applies burn', function()
    applied_damages = {}
    local underlord = create_mock_unit('npc_dota_hero_abyssal_underlord', 2, Vector(0, 0, 0))
    underlord.strength = 100
    local creep1 = create_mock_unit('creep_ul1', 3, Vector(100, 0, 0), 1000)
    local creep2 = create_mock_unit('creep_ul2', 3, Vector(200, 0, 0), 1000)
    mock_world_units = { underlord, creep1, creep2 }

    local ab = enfos_underlord_firestorm()
    ab.GetCaster = function() return underlord end
    ab.GetCursorPosition = function() return Vector(100, 0, 0) end
    ab.GetSpecialValueFor = function(_, k)
        if k == 'radius' then return 425 end
        if k == 'wave_damage' then return 95 end
        return 0
    end

    ab:OnSpellStart()
    -- dmg = 95 + (100 * 0.3 = 30) = 125
    assert(#applied_damages == 2, 'Firestorm hits both creeps in radius')
    assert(applied_damages[1].damage == 125 and applied_damages[1].damage_type == DAMAGE_TYPE_MAGICAL)
    assert(applied_damages[2].damage == 125 and applied_damages[2].damage_type == DAMAGE_TYPE_MAGICAL)
end)

test('Troll Warlord Whirling Axes deals magic damage with Agility scaling and blinds', function()
    applied_damages = {}
    local troll = create_mock_unit('npc_dota_hero_troll_warlord', 2, Vector(0, 0, 0))
    troll.agility = 120
    local creep = create_mock_unit('creep_troll', 3, Vector(150, 0, 0), 1000)
    mock_world_units = { troll, creep }

    local ab = enfos_troll_whirling_axes()
    ab.GetCaster = function() return troll end
    ab.GetSpecialValueFor = function(_, k)
        if k == 'radius' then return 450 end
        if k == 'damage' then return 270 end
        if k == 'duration' then return 4.0 end
        return 0
    end

    ab:OnSpellStart()
    -- dmg = 270 + (120 * 0.8 = 96) = 366
    assert(#applied_damages == 1)
    assert(applied_damages[1].damage == 366 and applied_damages[1].damage_type == DAMAGE_TYPE_MAGICAL)
    assert(creep:FindModifierByName('modifier_enfos_troll_whirling_axes_blind') ~= nil)
end)

test('Chaos Knight Chaos Strike procs crit, lifesteal and AoE cleave', function()
    applied_damages = {}
    local ck = create_mock_unit('npc_dota_hero_chaos_knight', 2, Vector(0, 0, 0), 2000)
    ck.hp = 500
    local target = create_mock_unit('target_ck', 3, Vector(50, 0, 0), 1000)
    local splash = create_mock_unit('splash_ck', 3, Vector(100, 0, 0), 1000)
    mock_world_units = { ck, target, splash }

    local ab = enfos_ck_chaos_strike()
    ab.GetSpecialValueFor = function(_, k)
        if k == 'bonus_damage' then return 50 end
        if k == 'crit_chance' then return 100 end
        if k == 'crit_mult' then return 200 end
        if k == 'lifesteal' then return 50 end
        return 0
    end

    local mod = ck:AddNewModifier(ck, ab, 'modifier_enfos_ck_chaos_strike', {})
    assert(mod:GetModifierPreAttack_CriticalStrike() == 200)

    mod:OnTakeDamage({
        attacker = ck,
        unit = target,
        damage = 300,
        damage_category = DOTA_DAMAGE_CATEGORY_ATTACK
    })

    assert(ck.hp == 650, 'Lifesteals 50% of 300 damage = +150 HP')
    assert(#applied_damages == 1, 'Cleaves to nearby splash target')
    assert(applied_damages[1].victim == splash and applied_damages[1].damage == 120)
end)

test('Medusa Mystic Snake bounces across targets with Agility scaling and restores mana', function()
    applied_damages = {}
    local medusa = create_mock_unit('npc_dota_hero_medusa', 2, Vector(0, 0, 0))
    medusa.agility = 100
    medusa.mana = 100
    local creep1 = create_mock_unit('creep_m1', 3, Vector(100, 0, 0), 1000)
    local creep2 = create_mock_unit('creep_m2', 3, Vector(200, 0, 0), 1000)
    mock_world_units = { medusa, creep1, creep2 }

    local ab = enfos_medusa_mystic_snake()
    ab.GetCaster = function() return medusa end
    ab.GetCursorTarget = function() return creep1 end
    ab.GetSpecialValueFor = function(_, k)
        if k == 'jump_count' then return 5 end
        if k == 'base_damage' then return 300 end
        return 0
    end

    ab:OnSpellStart()
    -- jump 1: 300 + (100 * 0.8 = 80) = 380
    -- jump 2: 380 * 1.2 = 456
    assert(#applied_damages == 2, 'Snake bounces to second creep')
    assert(applied_damages[1].damage == 380)
    assert(applied_damages[2].damage == 456)
    assert(medusa.mana == 160, 'Restores mana on hits')
end)

test('Terrorblade Sunder heals caster and deals pure damage with boss cap', function()
    applied_damages = {}
    local tb = create_mock_unit('npc_dota_hero_terrorblade', 2, Vector(0, 0, 0), 2000)
    tb.hp = 200
    tb.agility = 100
    local boss = create_mock_unit('enfos_boss_tb', 3, Vector(100, 0, 0), 10000)
    boss.is_boss = true
    mock_world_units = { tb, boss }

    local ab = enfos_tb_sunder()
    ab.GetCaster = function() return tb end
    ab.GetCursorTarget = function() return boss end
    ab.GetSpecialValueFor = function(_, k)
        if k == 'heal_amount' then return 1000 end
        return 0
    end

    ab:OnSpellStart()
    -- heal = 1000 + (100 * 1.5 = 150) = 1150
    assert(tb.hp == 1350, 'TB healed for 1150')
    assert(#applied_damages == 1)
    assert(applied_damages[1].damage == 1000, 'Boss damage capped at 1000')
    assert(applied_damages[1].damage_type == DAMAGE_TYPE_PURE)
end)

test('Leshrac Pulse Nova pulses magic AoE scaling with Int and spends mana', function()
    applied_damages = {}
    local leshrac = create_mock_unit('npc_dota_hero_leshrac', 2, Vector(0, 0, 0))
    leshrac.intellect = 100
    leshrac.mana = 200
    local creep = create_mock_unit('creep_lesh', 3, Vector(100, 0, 0), 1000)
    mock_world_units = { leshrac, creep }

    local ab = enfos_leshrac_pulse_nova()
    ab.GetSpecialValueFor = function(_, k)
        if k == 'damage' then return 220 end
        if k == 'radius' then return 450 end
        if k == 'mana_cost_per_second' then return 40 end
        return 0
    end

    local mod = leshrac:AddNewModifier(leshrac, ab, 'modifier_enfos_leshrac_pulse_nova', {})
    mod:OnIntervalThink()

    assert(leshrac.mana == 160, 'Spends 40 mana per pulse')
    -- dmg = 220 + (100 * 0.75 = 75) = 295
    assert(#applied_damages == 1)
    assert(applied_damages[1].damage == 295 and applied_damages[1].damage_type == DAMAGE_TYPE_MAGICAL)
end)

test('Invoker Sun Strike deals pure AoE damage scaling with Intellect', function()
    applied_damages = {}
    local invoker = create_mock_unit('npc_dota_hero_invoker', 2, Vector(0, 0, 0))
    invoker.intellect = 120
    local creep = create_mock_unit('creep_invo', 3, Vector(100, 0, 0), 1000)
    mock_world_units = { invoker, creep }

    local ab = enfos_invoker_sun_strike()
    ab.GetCaster = function() return invoker end
    ab.GetCursorPosition = function() return Vector(100, 0, 0) end
    ab.GetSpecialValueFor = function(_, k)
        if k == 'radius' then return 200 end
        if k == 'damage' then return 500 end
        return 0
    end

    ab:OnSpellStart()
    -- dmg = 500 + (120 * 1.8 = 216) = 716 pure
    assert(#applied_damages == 1)
    assert(applied_damages[1].damage == 716 and applied_damages[1].damage_type == DAMAGE_TYPE_PURE)
end)

test('Puck Dream Coil stuns and damages with boss duration reduction', function()
    applied_damages = {}
    local puck = create_mock_unit('npc_dota_hero_puck', 2, Vector(0, 0, 0))
    puck.intellect = 100
    local creep = create_mock_unit('creep_puck', 3, Vector(50, 0, 0), 1000)
    local boss = create_mock_unit('enfos_boss_puck', 3, Vector(100, 0, 0), 5000)
    boss.is_boss = true
    mock_world_units = { puck, creep, boss }

    local ab = enfos_puck_dream_coil()
    ab.GetCaster = function() return puck end
    ab.GetCursorPosition = function() return Vector(75, 0, 0) end
    ab.GetSpecialValueFor = function(_, k)
        if k == 'radius' then return 375 end
        if k == 'break_damage' then return 600 end
        if k == 'stun_duration' then return 3.0 end
        return 0
    end

    ab:OnSpellStart()
    -- dmg = 600 + (100 * 1.5 = 150) = 750
    assert(#applied_damages == 2)
    assert(applied_damages[1].damage == 750)
    assert(applied_damages[2].damage == 750)

    local mod_creep = creep:FindModifierByName('modifier_generic_stunned_lua')
    local mod_boss = boss:FindModifierByName('modifier_generic_stunned_lua')
    assert(mod_creep.params.duration == 3.0, 'Creep takes full 3.0s stun')
    assert(math.abs(mod_boss.params.duration - 1.05) < 0.01, 'Boss stun reduced by 65%')
end)

test('Jakiro Dual Breath damages in cone with Int scaling and applies slow', function()
    applied_damages = {}
    local jakiro = create_mock_unit('npc_dota_hero_jakiro', 2, Vector(0, 0, 0))
    jakiro.intellect = 90
    local creep = create_mock_unit('creep_jak', 3, Vector(200, 0, 0), 1000)
    mock_world_units = { jakiro, creep }

    local ab = enfos_jakiro_dual_breath()
    ab.GetCaster = function() return jakiro end
    ab.GetCursorPosition = function() return Vector(200, 0, 0) end
    ab.GetSpecialValueFor = function(_, k)
        if k == 'damage' then return 340 end
        if k == 'duration' then return 5.0 end
        return 0
    end

    ab:OnSpellStart()
    -- dmg = 340 + (90 * 0.8 = 72) = 412
    assert(#applied_damages == 1)
    assert(applied_damages[1].damage == 412 and applied_damages[1].damage_type == DAMAGE_TYPE_MAGICAL)
    assert(creep:FindModifierByName('modifier_enfos_jakiro_dual_breath_slow') ~= nil)
end)

test('Vengeful Spirit Nether Swap damages target with Agi scaling and buffs defense', function()
    applied_damages = {}
    local vs = create_mock_unit('npc_dota_hero_vengefulspirit', 2, Vector(0, 0, 0))
    vs.agility = 110
    local creep = create_mock_unit('creep_vs', 3, Vector(500, 0, 0), 1000)
    mock_world_units = { vs, creep }

    local ab = enfos_vs_nether_swap()
    ab.GetCaster = function() return vs end
    ab.GetCursorTarget = function() return creep end
    ab.GetSpecialValueFor = function(_, k)
        if k == 'damage' then return 400 end
        return 0
    end

    ab:OnSpellStart()
    -- dmg = 400 + (110 * 1.2 = 132) = 532
    assert(#applied_damages == 1)
    assert(applied_damages[1].damage == 532 and applied_damages[1].damage_type == DAMAGE_TYPE_MAGICAL)
    assert(vs:FindModifierByName('modifier_enfos_vs_nether_swap_buff') ~= nil)
end)

test('Lich Chain Frost bounces across enemies with Intellect scaling', function()
    applied_damages = {}
    local lich = create_mock_unit('npc_dota_hero_lich', 2, Vector(0, 0, 0))
    lich.intellect = 100
    local creep1 = create_mock_unit('creep_lich1', 3, Vector(100, 0, 0), 2000)
    local creep2 = create_mock_unit('creep_lich2', 3, Vector(200, 0, 0), 2000)
    mock_world_units = { lich, creep1, creep2 }

    local ab = enfos_lich_chain_frost()
    ab.GetCaster = function() return lich end
    ab.GetCursorTarget = function() return creep1 end
    ab.GetSpecialValueFor = function(_, k)
        if k == 'jump_count' then return 4 end
        if k == 'damage' then return 400 end
        return 0
    end

    ab:OnSpellStart()
    -- dmg per hit = 400 + (100 * 1.0 = 100) = 500
    assert(#applied_damages == 4, 'Chain frost completes 4 jumps')
    assert(applied_damages[1].damage == 500)
    assert(applied_damages[2].damage == 500)
    assert(applied_damages[3].damage == 500)
    assert(applied_damages[4].damage == 500)
end)

print(passed .. ' hero kit regression tests passed (mock engine).')
