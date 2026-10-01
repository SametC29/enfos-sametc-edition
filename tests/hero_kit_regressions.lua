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
function RandomFloat(min, max) return min end
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
DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES = 16
MODIFIER_STATE_DEBUFF_IMMUNE = 56
MODIFIER_STATE_STUNNED = 1
MODIFIER_STATE_TETHERED = 45
MODIFIER_STATE_INVULNERABLE = 57
MODIFIER_STATE_OUT_OF_GAME = 58
MODIFIER_STATE_INVISIBLE = 59
MODIFIER_STATE_TRUESIGHT_IMMUNE = 60
MODIFIER_EVENT_ON_DEATH = 4
MODIFIER_EVENT_ON_ATTACK_LANDED = 5
MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY = 101
MODIFIER_EVENT_ON_ATTACKED = 6
MODIFIER_EVENT_ON_TAKEDAMAGE = 7
MODIFIER_EVENT_ON_ABILITY_FULLY_CAST = 8
MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK = 10
MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT = 9
DAMAGE_TYPE_PHYSICAL = 1
DAMAGE_TYPE_MAGICAL = 2
DAMAGE_TYPE_PURE = 4
DOTA_DAMAGE_FLAG_REFLECTION = 16
DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR = 128
DOTA_DAMAGE_CATEGORY_ATTACK = 1
DOTA_DAMAGE_CATEGORY_SPELL = 2
PATTACH_ABSORIGIN_FOLLOW = 'mock_absorigin_follow'

ParticleManager = {
    CreateParticle = function() return 1 end,
    DestroyParticle = function() end,
    ReleaseParticleIndex = function() end,
    SetParticleControl = function() end,
    SetParticleControlEnt = function() end,
}
local create_mock_unit

ProjectileManager = {
    CreateLinearProjectile = function(_, options) _G.last_linear_projectile = options return 1 end,
    CreateTrackingProjectile = function(_, options) _G.last_tracking_projectile = options return 1 end,
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
        t.modifiers[mod_name] = m
        m.StartIntervalThink = function(self, interval) self.interval = interval end
        m.Destroy = function(self) self.destroyed = true; if self.OnDestroy then self:OnDestroy() end end
        if m.OnCreated then m:OnCreated(params) end
        if m.OnIntervalThink then m:OnIntervalThink() end
    end
    return t
end
UTIL_Remove = function(entity) if entity then entity.removed = true end end

create_mock_unit = function(name, team, origin, hp)
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
        forward = Vector(1, 0, 0),
        GetForwardVector = function(self) return self.forward end,
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
        StartGesture = function() end,
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
        FindModifierByNameAndCaster = function(self, mod_name, caster)
            local modifier = self.modifiers[mod_name]
            if modifier and modifier.caster == caster then return modifier end
        end,
        HasModifier = function(self, mod_name) return self.modifiers[mod_name] ~= nil end,
        Heal = function(self, amount, ability) self.hp = math.min(self.max_hp, self.hp + amount) end,
        FindAbilityByName = function(self, ab_name) return nil end,
        IsHero = function(self) return self.name:find("hero", 1, true) ~= nil end,
        Kill = function(self, ability, killer) self.alive = false self.hp = 0 end,
        Purge = function(self) end,
        ModifyStrength = function(self, delta) self.strength = self.strength + delta end,
        SetHealth = function(self, hp) self.hp = hp end,
        PerformAttack = function(self, target, a, b, c, d, e, f, g)
            ApplyDamage({ victim = target, attacker = self, damage = self:GetAverageTrueAttackDamage(), damage_type = DAMAGE_TYPE_PHYSICAL,
                damage_category = DOTA_DAMAGE_CATEGORY_ATTACK })
        end,
    }
    return unit
end

local mock_world_units = {}
EntIndexToHScript = function(index)
    for _, unit in ipairs(mock_world_units) do
        if unit and unit.entindex and unit:entindex() == index then return unit end
    end
end
FindUnitsInRadius = function(team, point, cache, radius, target_team, target_type, flags, order, can_grow)
    _G.last_find_units_flags = flags
    _G.last_find_units_radius = radius
    _G.last_find_units_point = point
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
FindUnitsInLine = function(team, start_pos, end_pos, cache, width, target_team, target_type, flags)
    local found = {}
    local dx, dy = end_pos.x - start_pos.x, end_pos.y - start_pos.y
    local length_sq = dx * dx + dy * dy
    for _, unit in ipairs(mock_world_units) do
        if unit:IsAlive() and unit:GetTeamNumber() ~= team then
            local p = unit:GetAbsOrigin()
            local t = math.max(0, math.min(1, ((p.x-start_pos.x)*dx+(p.y-start_pos.y)*dy) / math.max(1, length_sq)))
            local qx, qy = start_pos.x + t*dx, start_pos.y + t*dy
            local dist = math.sqrt((p.x-qx)^2 + (p.y-qy)^2)
            if dist <= width then table.insert(found, unit) end
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

test('Sven Q/W/E Lua callbacks are registered', function()
    assert(type(bulwark_shield_slam) == 'table' and type(bulwark_shield_slam.OnSpellStart) == 'function')
    assert(type(bulwark_shield_slam.OnProjectileHit) == 'function')
    assert(type(bulwark_challenge) == 'table' and type(bulwark_challenge.OnSpellStart) == 'function')
    assert(type(bulwark_iron_guard) == 'table' and type(bulwark_iron_guard.GetIntrinsicModifierName) == 'function')
    assert(type(modifier_bulwark_iron_guard) == 'table' and type(modifier_bulwark_iron_guard.OnAttackLanded) == 'function')
end)

test('Sven Storm Hammer launches a visible tracking bolt and applies impact AoE', function()
    applied_damages = {}
    local sven = create_mock_unit('npc_dota_hero_sven', 2, Vector(0, 0, 0))
    local target = create_mock_unit('enfos_creep_melee', 3, Vector(500, 0, 0))
    local creep1 = create_mock_unit('enfos_creep_melee', 3, Vector(550, 0, 0))
    local boss = create_mock_unit('enfos_boss_stonebreaker', 3, Vector(580, 0, 0))
    mock_world_units = { sven, target, creep1, boss }

    local ab = bulwark_shield_slam()
    ab.GetCaster = function() return sven end
    ab.GetCursorTarget = function() return target end
    ab.GetSpecialValueFor = function(_, k)
        if k == 'damage' then return 300 end
        if k == 'radius' then return 100 end
        if k == 'stun_duration' then return 1.5 end
        if k == 'boss_stun_cap' then return 0.6 end
        if k == 'bolt_speed' then return 1000 end
        return 0
    end

    ab:OnSpellStart()
    assert(#applied_damages == 0, 'Damage is applied on projectile impact, not cast')
    assert(last_tracking_projectile.Target == target, 'Tracking bolt must follow the selected target')
    assert(last_tracking_projectile.iMoveSpeed == 1000, 'Projectile speed must match the tuned value')
    assert(last_tracking_projectile.EffectName:find('sven_storm_bolt_projectile_trail.vpcf', 1, true), 'Use Sven Storm Hammer trail VFX')

    ab:OnProjectileHit(target, target:GetAbsOrigin())
    assert(#applied_damages == 3, 'Impact AoE should damage the target, nearby creep and boss')
    assert(applied_damages[1].damage == 300 and applied_damages[1].damage_type == DAMAGE_TYPE_MAGICAL, 'Storm Hammer damage must be magical')
    assert(creep1:HasModifier('modifier_stunned'), 'Ordinary creep must be stunned')
    assert(boss:HasModifier('modifier_stunned'), 'Boss receives capped stun')
    assert(boss.modifiers.modifier_stunned.params.duration == 0.6, 'Boss stun duration is capped')
    assert(not creep1:HasModifier('modifier_bulwark_shield_slam_slow'), 'Removed the old unapproved slow')
    local hitCount = #applied_damages
    ab:OnProjectileHit(nil, target:GetAbsOrigin())
    assert(#applied_damages == hitCount, 'Dodged/lost projectiles must not detonate')
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
        if k == 'boss_taunt_pct' then return 25 end
        return 0
    end

    ab:OnSpellStart()

    assert(sven:HasModifier('modifier_enfos_pve_warcry'), 'Sven must gain Warcry buff')
    assert(creep:HasModifier('modifier_enfos_pve_taunt'), 'Creep must be taunted')
    assert(boss:HasModifier('modifier_enfos_pve_taunt'), 'Boss must be taunted')
    assert(creep.modifiers['modifier_enfos_pve_taunt'].params.duration == 4.0, 'Normal creep takes full taunt duration')
    assert(boss.modifiers['modifier_enfos_pve_taunt'].params.duration == 1.0, 'Boss taunt must be 0.25x (1.0s)')
end)

test('Sven Warcry taunt cleans up only its own forced target', function()
    local caster = create_mock_unit('npc_dota_hero_sven', 2, Vector(0, 0, 0))
    local enemy = create_mock_unit('enfos_creep_melee', 3, Vector(100, 0, 0))
    local replacement = create_mock_unit('npc_dota_hero_axe', 2, Vector(0, 100, 0))
    enemy.SetForceAttackTarget = function(self, target) self.forcedTarget = target end
    enemy.GetForceAttackTarget = function(self) return self.forcedTarget end
    enemy.MoveToTargetToAttack = function(self, target) self.orderedTarget = target end
    local taunt = modifier_enfos_pve_taunt()
    taunt.GetParent = function() return enemy end
    taunt.GetCaster = function() return caster end
    taunt:OnCreated()
    assert(enemy.forcedTarget == caster, 'Taunt forces the enemy onto Sven')
    enemy.forcedTarget = replacement
    taunt:OnDestroy()
    assert(enemy.forcedTarget == replacement, 'Taunt cleanup must preserve a newer forced target')
end)

test('Sven Great Cleave delegates native damage and visuals with tuned widths and lethal-hit guards', function()
    local sven = create_mock_unit('npc_dota_hero_sven', 2, Vector(0, 0, 0))
    local primary = create_mock_unit('enfos_creep_melee', 3, Vector(100, 0, 0))
    local ab = bulwark_iron_guard()
    ab.GetSpecialValueFor = function(_, k)
        return ({cleave_pct=50,cleave_starting_width=150,cleave_ending_width=270,cleave_distance=300})[k] or 0
    end
    local mod = setmetatable({GetParent=function() return sven end,GetAbility=function() return ab end}, modifier_bulwark_iron_guard)
    local oldCleave,oldCreate = DoCleaveAttack,ParticleManager.CreateParticle
    local calls={}
    DoCleaveAttack=function(...) calls[#calls+1]={...};return 1 end
    ParticleManager.CreateParticle=function() error('Engine owns cleave VFX; no manual target-attached copies') end
    mod:OnAttackLanded({attacker=sven,target=primary,original_damage=200})
    assert(#calls==1 and calls[1][1]==sven and calls[1][2]==primary and calls[1][3]==ab)
    assert(calls[1][4]==100 and calls[1][5]==75 and calls[1][6]==135 and calls[1][7]==300)
    assert(calls[1][8]=='particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf')
    primary.alive=false
    mod:OnAttackLanded({attacker=sven,target=primary,original_damage=200})
    assert(#calls==2, 'A lethal primary hit must still dispatch cleave')
    sven.modifiers.modifier_bulwark_fortress={}
    mod:OnAttackLanded({attacker=sven,target=primary,original_damage=200})
    assert(calls[3][8]=='particles/units/heroes/hero_sven/sven_spell_great_cleave_gods_strength.vpcf')
    sven.PassivesDisabled=function() return true end
    mod:OnAttackLanded({attacker=sven,target=primary,original_damage=200});assert(#calls==3)
    sven.PassivesDisabled=function() return false end;sven.IsIllusion=function() return true end
    mod:OnAttackLanded({attacker=sven,target=primary,original_damage=200});assert(#calls==3)
    sven.IsIllusion=function() return false end;primary.team=2
    mod:OnAttackLanded({attacker=sven,target=primary,original_damage=200});assert(#calls==3)
    primary.IsNull=function() return true end
    mod:OnAttackLanded({attacker=sven,target=primary,original_damage=200});assert(#calls==3)
    DoCleaveAttack,ParticleManager.CreateParticle=oldCleave,oldCreate
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
    ab.GetCaster = function() return luna end
    local previous_projectile = ProjectileManager.CreateTrackingProjectile
    local glaive_projectiles = {}
    ProjectileManager.CreateTrackingProjectile = function(_, options)
        glaive_projectiles[#glaive_projectiles + 1] = options
        return #glaive_projectiles
    end

    mod:OnAttackLanded({
        attacker = luna,
        target = c1
    })

    -- c1 was hit by basic attack. Glaive bounces: c1 -> c2 -> c3
    assert(#applied_damages == 0 and #glaive_projectiles == 2,
        'Glaive damage must wait for the tracking projectile impacts')
    ab:OnProjectileHit_ExtraData(c2, c2:GetAbsOrigin(), glaive_projectiles[1].ExtraData)
    ab:OnProjectileHit_ExtraData(c3, c3:GetAbsOrigin(), glaive_projectiles[2].ExtraData)
    ProjectileManager.CreateTrackingProjectile = previous_projectile
    assert(#applied_damages == 2, 'Glaive projectiles must apply damage on impact')
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

test('Luna Eclipse uses its own ranked beam value and caps total boss damage per cast', function()
    applied_damages = {}
    local luna = create_mock_unit('npc_dota_hero_luna', 2, Vector(0, 0, 0))
    local boss = create_mock_unit('enfos_boss_luna_test', 3, Vector(100, 0, 0), 1000)
    mock_world_units = { luna, boss }
    local eclipse = enfos_luna_eclipse()
    eclipse.GetSpecialValueFor = function(_, key)
        local values = { radius = 750, beam_damage = 730, boss_damage_pct = 10, max_hits_per_target = 6 }
        return values[key] or 0
    end
    local thinker = setmetatable({
        GetParent = function() return luna end,
        GetAbility = function() return eclipse end,
        StartIntervalThink = function(self, interval) self.interval = interval end,
    }, modifier_enfos_luna_eclipse_thinker)
    thinker:OnCreated()
    thinker:OnIntervalThink()
    thinker:OnIntervalThink()
    assert(#applied_damages == 1 and applied_damages[1].damage == 100,
        'Eclipse uses its own damage rank and cannot exceed the configured per-cast boss cap')
end)

test('Luna Lunar Orbit pulses physical damage scaling with Agility and cleans up particle', function()
    applied_damages = {}
    local luna = create_mock_unit('npc_dota_hero_luna', 2, Vector(0, 0, 0))
    luna.agility = 100
    local c1 = create_mock_unit('creep1', 3, Vector(100, 0, 0))
    local c2 = create_mock_unit('creep2', 3, Vector(200, 0, 0))
    mock_world_units = { luna, c1, c2 }

    local ab = enfos_luna_lunar_orbit()
    ab.GetSpecialValueFor = function(_, key)
        local values = { pulse_interval = 0.5, pulse_radius = 320, pulse_damage = 50,
            agility_multiplier = 0.4, damage_reduction_pct = 25, bonus_range = 75, bonus_ms = 25, duration = 8 }
        return values[key] or 0
    end
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
        if k == 'shatter_base_damage' then return 80 end
        if k == 'shatter_agility_factor' then return 0.4 end
        if k == 'shatter_radius' then return 325 end
        if k == 'shatter_slow_duration' then return 2 end
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

    -- A slow from another Drow must not trigger this owner's shatter.
    applied_damages = {}
    local other_drow = create_mock_unit('npc_dota_hero_drow_ranger', 2, Vector(0, 50, 0))
    creep:AddNewModifier(other_drow, ab, 'modifier_enfos_pve_slow', { duration = 3.0 })
    mod:OnDeath({ unit = creep })
    assert(#applied_damages == 0, 'A different caster must not receive this Drow passive shatter')
end)

test('Drow Frost slow exists before its bonus damage triggers synchronous death',function()
 local c=create_mock_unit('npc_dota_hero_drow_ranger',2,Vector(0,0,0))
 local t=create_mock_unit('enfos_creep',3,Vector(200,0,0));local near=create_mock_unit('enfos_creep2',3,Vector(220,0,0));mock_world_units={c,t,near}
 local a=enfos_drow_frost_arrows();a.GetCaster=function() return c end
 a.GetSpecialValueFor=function(_,k) return ({bonus_damage=60,agility_factor=0,duration=3,shatter_base_damage=80,shatter_agility_factor=0,shatter_radius=325,shatter_slow_duration=2})[k] or 0 end
 local m=setmetatable({GetParent=function() return c end,GetAbility=function() return a end},modifier_enfos_pve_frost)
 local oldDamage=ApplyDamage;local events={}
 ApplyDamage=function(event)
  events[#events+1]=event
  if event.victim==t then t.alive=false;m:OnDeath({unit=t,attacker=c}) end
 end
 m:OnAttackLanded({attacker=c,target=t});ApplyDamage=oldDamage
 assert(#events==2 and events[1].victim==t and events[2].victim==near and events[2].damage==80,
  'the first Frost bonus killing a fresh target must not miss its own death shatter')
end)

test('Drow Marksmanship lethal landed target still splinters without damaging a corpse',function()
 local c=create_mock_unit('npc_dota_hero_drow_ranger',2,Vector(0,0,0))
 local t=create_mock_unit('enfos_creep',3,Vector(200,0,0));t.alive=false
 local near=create_mock_unit('enfos_creep2',3,Vector(220,0,0));mock_world_units={c,t,near}
 local a=enfos_drow_marksmanship();a.GetCaster=function() return c end
 a.GetSpecialValueFor=function(_,k) return ({proc_chance=100,bonus_damage=80,agility_factor=0,splinter_count=3,splinter_radius=450,splinter_damage_pct=60})[k] or 0 end
 local m=setmetatable({GetParent=function() return c end,GetAbility=function() return a end},modifier_enfos_pve_marksmanship)
 applied_damages={};m:OnAttackLanded({attacker=c,target=t})
 assert(#applied_damages==1 and applied_damages[1].victim==near and applied_damages[1].damage==60,
  'a killing primary attack keeps its bounded secondary proc; no corpse damage')
 c.PassivesDisabled=function() return true end;applied_damages={};m:OnAttackLanded({attacker=c,target=t});assert(#applied_damages==0)
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
        if k == 'agility_factor' then return 0.5 end
        if k == 'splinter_count' then return 3 end
        if k == 'splinter_damage_pct' then return 60 end
        if k == 'splinter_radius' then return 450 end
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
    assert(applied_damages[1].damage_type == DAMAGE_TYPE_PHYSICAL
        and applied_damages[1].damage_flags == DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR,
        'Marksmanship primary proc must pierce physical armor')
    for i = 2, 4 do
        assert(applied_damages[i].damage == 60 and applied_damages[i].damage_type == DAMAGE_TYPE_PHYSICAL,
            'Splinter arrows should deal 60% attack damage as physical damage')
    end
    assert(last_find_units_flags == DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        'Marksmanship splash target search must match its native spell-immunity behavior')
end)

test('Drow instant hits use finite native impact roots at captured target positions',function()
 local c=create_mock_unit('npc_dota_hero_drow_ranger',2,Vector(0,0,0))
 local primary=create_mock_unit('enfos_creep',3,Vector(200,40,0))
 local secondary=create_mock_unit('enfos_creep2',3,Vector(240,40,0));mock_world_units={c,primary,secondary}
 local a=enfos_drow_marksmanship();a.GetCaster=function() return c end
 a.GetSpecialValueFor=function(_,k) return ({proc_chance=100,bonus_damage=80,agility_factor=0.5,splinter_count=3,splinter_radius=450,splinter_damage_pct=60})[k] or 0 end
 local m=setmetatable({GetParent=function() return c end,GetAbility=function() return a end},modifier_enfos_pve_marksmanship)
 local oldCreate,oldControl,oldRelease,oldDamage=ParticleManager.CreateParticle,ParticleManager.SetParticleControl,ParticleManager.ReleaseParticleIndex,ApplyDamage
 local entries={}
 ParticleManager.CreateParticle=function(_,path,attach,owner)
  assert(attach==PATTACH_WORLDORIGIN and owner==nil);entries[#entries+1]={path=path,cp={}};return #entries
 end
 ParticleManager.SetParticleControl=function(_,id,cp,v) entries[id].cp[cp]=v end
 ParticleManager.ReleaseParticleIndex=function(_,id) entries[id].released=true end
 ApplyDamage=function(event) event.victim:SetAbsOrigin(Vector(999,999,0)) end
 m:OnAttackLanded({attacker=c,target=primary})
 local q=enfos_drow_frost_arrows();q.GetCaster=function() return c end;q.GetSpecialValueFor=function() return 1 end
 local qm=setmetatable({GetParent=function() return c end,GetAbility=function() return q end},modifier_enfos_pve_frost)
 primary:SetAbsOrigin(Vector(300,40,0));qm:OnAttackLanded({attacker=c,target=primary})
 ParticleManager.CreateParticle,ParticleManager.SetParticleControl,ParticleManager.ReleaseParticleIndex,ApplyDamage=oldCreate,oldControl,oldRelease,oldDamage
 assert(#entries==3 and entries[1].path:find('drow_frost_arrow_explosion.vpcf',1,true)
  and entries[2].path:find('drow_base_attack_explosion_flash.vpcf',1,true)
  and entries[3].path:find('drow_frost_arrow_explosion.vpcf',1,true))
 for i,x in ipairs({200,240,300}) do
  assert(entries[i].cp[0].x==x and entries[i].cp[3].x==x and entries[i].released,
   'impact position must be captured before ApplyDamage changes/removes the target')
 end
end)

test('Drow impact and cross-hero shatter resources have explicit ability precache owners',function()
 local old=PrecacheResource;local seen={};PrecacheResource=function(kind,path,context) assert(kind=='particle' and context=='drow-test');seen[path]=true end
 enfos_drow_frost_arrows():Precache('drow-test');enfos_drow_marksmanship():Precache('drow-test');PrecacheResource=old
 assert(seen['particles/units/heroes/hero_drow/drow_frost_arrow_explosion.vpcf']
  and seen['particles/units/heroes/hero_drow/drow_base_attack_explosion_flash.vpcf']
  and seen['particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_explode.vpcf'])
end)

test('Drow Gust defaults a zero cursor to forward and only applies once per target', function()
    local drow = create_mock_unit('npc_dota_hero_drow_ranger', 2, Vector(0, 0, 0))
    drow.forward = Vector(0, 1, 0)
    local enemy = create_mock_unit('enfos_creep_gust_target', 3, Vector(200, 0, 0))
    local gust = enfos_drow_gust()
    gust.GetCaster = function() return drow end
    gust.GetCursorPosition = function() return drow:GetAbsOrigin() end
    gust.GetSpecialValueFor = function(_, key)
        return ({ wave_distance = 1000, wave_speed = 1200, wave_width = 250,
            knockback_distance = 200, silence_duration = 3, boss_control_duration_pct = 30,
            physical_vulnerability_pct = 25 })[key] or 0
    end
    gust:OnSpellStart()
    assert(last_linear_projectile.vVelocity.x == 0 and last_linear_projectile.vVelocity.y == 1200,
        'Zero-length cursor should launch the wave along Drow forward')
    gust:OnProjectileHit_ExtraData(enemy, nil, last_linear_projectile.ExtraData)
    local moved = enemy:GetAbsOrigin()
    assert(moved.x == 200 and moved.y == 200, 'Gust knockback should follow the wave direction')
    gust:OnProjectileHit_ExtraData(enemy, nil, last_linear_projectile.ExtraData)
    assert(enemy:GetAbsOrigin().y == 200, 'The same projectile must not knock back or apply control repeatedly')
end)

test('Drow Gust isolates overlapping wave direction, hits and destination cleanup',function()
 local c=create_mock_unit('npc_dota_hero_drow_ranger',2,Vector(0,0,0))
 local t=create_mock_unit('enfos_creep',3,Vector(200,0,0));local cursor=Vector(1000,0,0)
 local a=enfos_drow_gust();a.GetCaster=function() return c end;a.GetCursorPosition=function() return cursor end
 a.GetSpecialValueFor=function(_,k) return ({wave_distance=1000,wave_speed=1200,wave_width=250,knockback_distance=200,silence_duration=3,boss_control_duration_pct=30})[k] or 0 end
 a:OnSpellStart();local first=last_linear_projectile.ExtraData
 cursor=Vector(0,1000,0);a:OnSpellStart();local second=last_linear_projectile.ExtraData
 assert(first.gust_cast~=second.gust_cast)
 a:OnProjectileHit_ExtraData(t,nil,first)
 assert(t:GetAbsOrigin().x==400 and t:GetAbsOrigin().y==0,'first wave must keep its +X direction')
 a:OnProjectileHit_ExtraData(t,nil,first)
 assert(t:GetAbsOrigin().x==400,'one wave cannot hit the same target twice')
 a:OnProjectileHit_ExtraData(t,nil,second)
 assert(t:GetAbsOrigin().x==400 and t:GetAbsOrigin().y==200,'another wave may hit independently with +Y direction')
 a:OnProjectileHit_ExtraData(nil,nil,first)
 assert(a.gust_waves[first.gust_cast]==nil and a.gust_waves[second.gust_cast]~=nil)
 a:OnProjectileHit_ExtraData(t,nil,first)
 assert(t:GetAbsOrigin().y==200,'retired wave cannot resurrect its state')
 a:OnProjectileHit_ExtraData(nil,nil,second)
 assert(next(a.gust_waves)==nil,'destination callback retires all completed wave records')
end)

test('Drow Gust rejects friendly, dead, null and unknown callbacks without retiring a live wave',function()
 local c=create_mock_unit('npc_dota_hero_drow_ranger',2,Vector(0,0,0))
 local ally=create_mock_unit('enfos_ally',2,Vector(100,0,0));local dead=create_mock_unit('enfos_dead',3,Vector(100,0,0));dead.alive=false
 local null={IsNull=function() return true end};local enemy=create_mock_unit('enfos_creep',3,Vector(100,0,0))
 local a=enfos_drow_gust();a.GetCaster=function() return c end;a.GetCursorPosition=function() return Vector(1000,0,0) end
 a.GetSpecialValueFor=function(_,k) return ({wave_distance=1000,wave_speed=1200,wave_width=250,knockback_distance=200,silence_duration=3,boss_control_duration_pct=30})[k] or 0 end
 a:OnSpellStart();local data=last_linear_projectile.ExtraData
 for _,t in ipairs({ally,dead,null}) do a:OnProjectileHit_ExtraData(t,nil,data) end
 a:OnProjectileHit_ExtraData(enemy,nil,{gust_cast=999});a:OnProjectileHit_ExtraData(enemy,nil,{})
 assert(ally:GetAbsOrigin().x==100 and dead:GetAbsOrigin().x==100 and enemy:GetAbsOrigin().x==100)
 assert(a.gust_waves[data.gust_cast] and next(a.gust_waves[data.gust_cast].hit_targets)==nil)
 a:OnProjectileHit_ExtraData(enemy,nil,data);assert(enemy:GetAbsOrigin().x==300)
 a:OnProjectileHit_ExtraData(nil,nil,data);assert(next(a.gust_waves)==nil)
end)

test('Drow Multishot projectiles retain spell-immunity pierce and configured travel data', function()
    local drow = create_mock_unit('npc_dota_hero_drow_ranger', 2, Vector(0, 0, 0))
    local multishot = enfos_drow_multishot()
    multishot.GetCaster = function() return drow end
    multishot.GetCursorPosition = function() return Vector(0, 0, 0) end
    multishot.GetSpecialValueFor = function(_, key)
        return ({ channel_time = 2, arrow_count = 12, lane_count = 6, spread_start_angle = -25,
            spread_angle_step = 10, arrow_range = 1100, arrow_width = 75, arrow_speed = 1200 })[key] or 0
    end
    multishot:OnSpellStart()
    multishot:OnChannelThink(0.1)
    assert(last_linear_projectile.iUnitTargetFlags == DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        'Each linear arrow must use Drow Multishot native immunity targeting')
    assert(last_linear_projectile.fDistance == 1100 and last_linear_projectile.fStartRadius == 75)
    assert(math.floor(last_linear_projectile.vVelocity:Length2D() + 0.5) == 1200)
end)

test('Drow Gust and Precision Aura expose configured control values and team radius', function()
    local gust = enfos_drow_gust()
    gust.GetSpecialValueFor = function(_, key) return key == 'physical_vulnerability_pct' and 25 or 0 end
    local vuln = setmetatable({ GetAbility = function() return gust end }, modifier_enfos_pve_gust_vulnerable)
    assert(vuln:GetModifierIncomingPhysicalDamage_Percentage() == 25)

    local aura = enfos_drow_precision_aura()
    aura.GetSpecialValueFor = function(_, key) return key == 'aura_radius' and 1200 or 0 end
    local aura_mod = setmetatable({ GetAbility = function() return aura end }, modifier_enfos_pve_precision)
    aura_mod.GetParent = function() return { PassivesDisabled = function() return false end } end
    assert(aura_mod:GetAuraRadius() == 1200)
    assert(aura_mod:GetAuraSearchTeam() == DOTA_UNIT_TARGET_TEAM_FRIENDLY)
    assert(aura_mod:IsAura())
    aura_mod.GetParent = function() return { PassivesDisabled = function() return true end } end
    assert(not aura_mod:IsAura(), 'Drow Precision Aura must be disabled by Break')
end)

test('Juggernaut Duelist stacks on kill and caps at 10 with lifesteal', function()
    local jugg = create_mock_unit('npc_dota_hero_juggernaut', 2, Vector(0, 0, 0))
    local enemy = create_mock_unit('enfos_creep', 3, Vector(100, 0, 0))
    mock_world_units = { jugg, enemy }

    local ab = enfos_juggernaut_duelist()
    ab.GetSpecialValueFor = function(_, key)
        return ({ kill_stack_cap = 10, kill_stack_duration = 7, kill_stack_attack_speed = 12,
            kill_stack_armor = 2, kill_stack_movespeed_pct = 2, kill_stack_lifesteal_pct = 20 })[key] or 0
    end
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
        target = enemy,
        damage = 200
    })
    -- 20% of 200 = 40 heal
    assert(jugg.hp == 340, 'Lifesteal at 10 stacks should heal 40 HP')
    stack_mod:OnAttackLanded({attacker=jugg,target=jugg,damage=200})
    assert(jugg.hp==340, 'Friendly/deny attacks cannot heal Duelist')
end)
test('Juggernaut Healing Ward casts at the cursor, creates its effect and caps live wards', function()
    local jugg = create_mock_unit('npc_dota_hero_juggernaut', 2, Vector(0, 0, 0))
    local point = Vector(200, 300, 0)
    local sounds = {}
    jugg.EmitSound = function(_, sound) sounds[#sounds + 1] = sound end
    local ability = enfos_juggernaut_healing_ward()
    ability.GetCaster = function() return jugg end
    ability.GetCursorPosition = function() return point end
    ability.GetSpecialValueFor = function(_, key) return ({ duration = 12, radius = 500, heal_pct = 6 })[key] or 0 end
    local removed = {}
    local oldRemove = UTIL_Remove
    UTIL_Remove = function(entity) removed[#removed + 1] = entity; oldRemove(entity) end
    for _ = 1, 4 do ability:OnSpellStart() end
    UTIL_Remove = oldRemove
    assert(#ability.enfosGroundEffects == 3, 'at most three ward effects should remain active')
    assert(removed[1] and removed[1].removed, 'placing a fourth ward should remove the oldest effect')
    assert(ability.enfosGroundEffects[3]:GetAbsOrigin() == point)
    assert(#sounds == 4 and sounds[1] == 'Hero_Juggernaut.HealingWard.Cast')
    local thinker = setmetatable({ GetAbility = function() return ability end }, modifier_enfos_juggernaut_healing_ward_thinker)
    local aura = setmetatable({ GetAbility = function() return ability end }, modifier_enfos_juggernaut_healing_ward_aura)
    assert(thinker:GetAuraRadius() == 500 and aura:GetModifierHealthRegenPercentage() == 6)
    assert(thinker:GetEffectName() == 'particles/units/heroes/hero_juggernaut/juggernaut_healing_ward.vpcf')
end)
test('Juggernaut critical splash is tied to the landed critical and respects Break', function()
    local jugg = create_mock_unit('npc_dota_hero_juggernaut', 2, Vector(0, 0, 0))
    local target = create_mock_unit('enfos_creep_target', 3, Vector(100, 0, 0))
    local neighbor = create_mock_unit('enfos_creep_neighbor', 3, Vector(150, 0, 0))
    mock_world_units = { jugg, target, neighbor }
    local ability = enfos_juggernaut_blade_dance()
    ability.GetCaster = function() return jugg end
    ability.GetSpecialValueFor = function(_, key)
        return ({ crit_chance = 100, crit_mult = 300, crit_splash_pct = 60, crit_splash_radius = 350 })[key] or 0
    end
    local modifier = setmetatable({ GetParent = function() return jugg end, GetAbility = function() return ability end }, modifier_enfos_pve_crit)
    local oldRoll = RollPercentage
    RollPercentage = function() return true end
    assert(modifier:GetModifierPreAttack_CriticalStrike({ attacker = jugg, target = target, record = 11 }) == 300)
    applied_damages = {}
    local other = create_mock_unit('enfos_other_attacker', 2, Vector(0, 0, 0))
    modifier:OnAttackLanded({ attacker = other, target = target, record = 12 })
    modifier:OnAttackLanded({ attacker = jugg, target = target, record = 11 })
    assert(#applied_damages == 1 and applied_damages[1].victim == neighbor and applied_damages[1].damage == 60)
    applied_damages = {}
    modifier:OnAttackLanded({ attacker = jugg, target = target, record = 11 })
    assert(#applied_damages == 0, 'a stale critical flag must not splash on the next attack')
    jugg.PassivesDisabled = function() return true end
    assert(modifier:GetModifierPreAttack_CriticalStrike({ target = target }) == nil)
    RollPercentage = oldRoll
end)
test('Juggernaut critical records survive overlap, cache rolls and clean up cancelled attacks', function()
    local c=create_mock_unit('npc_dota_hero_juggernaut',2,Vector(0,0,0))
    local t=create_mock_unit('enfos_creep_target',3,Vector(100,0,0))
    local n=create_mock_unit('enfos_creep_neighbor',3,Vector(150,0,0));mock_world_units={c,t,n}
    local a=enfos_juggernaut_blade_dance();a.GetCaster=function() return c end
    a.GetSpecialValueFor=function(_,k) return ({crit_chance=50,crit_mult=300,crit_splash_pct=60,crit_splash_radius=350})[k] or 0 end
    local m=setmetatable({GetParent=function() return c end,GetAbility=function() return a end},modifier_enfos_pve_crit)
    local oldRoll=RollPercentage;local rolls=0
    RollPercentage=function() rolls=rolls+1;return rolls==1 end
    assert(m:GetModifierPreAttack_CriticalStrike({attacker=c,target=t,record=21})==300)
    assert(m:GetModifierPreAttack_CriticalStrike({attacker=c,target=t,record=21})==300 and rolls==1)
    assert(m:GetModifierPreAttack_CriticalStrike({attacker=c,target=t,record=22})==nil)
    assert(m:GetModifierPreAttack_CriticalStrike({attacker=c,target=t,record=22})==nil and rolls==2)
    applied_damages={};m:OnAttackLanded({attacker=c,target=t,record=22});assert(#applied_damages==0)
    m:OnAttackLanded({attacker=c,target=t,record=21});assert(#applied_damages==1)
    assert(next(m.critRecords)==nil, 'Landed records must be consumed')
    RollPercentage=function() return true end
    m:GetModifierPreAttack_CriticalStrike({attacker=c,target=t,record=23})
    m:OnAttackRecordDestroy({attacker=c,record=23});assert(next(m.critRecords)==nil)
    m:OnAttackLanded({attacker=c,target=t,record=23});assert(#applied_damages==1)
    m:GetModifierPreAttack_CriticalStrike({attacker=c,target=t,record=24})
    c.PassivesDisabled=function() return true end
    m:OnAttackLanded({attacker=c,target=t,record=24});assert(#applied_damages==1 and next(m.critRecords)==nil)
    c.PassivesDisabled=function() return false end
    m:GetModifierPreAttack_CriticalStrike({attacker=c,target=t,record=25});m:OnDestroy();assert(m.critRecords==nil)
    RollPercentage=oldRoll
end)
test('Juggernaut Omni Slash selects a fresh nearby enemy after the current target', function()
    local jugg = create_mock_unit('npc_dota_hero_juggernaut', 2, Vector(0, 0, 0))
    local first = create_mock_unit('enfos_creep_first', 3, Vector(100, 0, 0))
    local second = create_mock_unit('enfos_creep_second', 3, Vector(160, 0, 0))
    mock_world_units = { jugg, first, second }
    local ability = enfos_juggernaut_omni_slash()
    ability.GetCaster = function() return jugg end
    ability.GetSpecialValueFor = function(_, key) return ({ radius = 450, slash_interval = 0.3, bonus_damage = 50 })[key] or 0 end
    local modifier = setmetatable({ GetParent = function() return jugg end, GetAbility = function() return ability end,
        home = jugg:GetAbsOrigin(), target = first, visitedTargets = {}, Destroy = function(self) self.destroyed = true end }, modifier_enfos_pve_slashes)
    applied_damages = {}
    modifier:OnIntervalThink()
    assert(applied_damages[1].victim == first)
    modifier:OnIntervalThink()
    assert(applied_damages[2].victim == second, 'jump should avoid repeating an already-hit target when another is nearby')
    assert(last_find_units_flags==DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        'Omni Slash follow-up search must match its native/KV immunity-piercing target policy')
end)

test('Juggernaut Omni Slash supplies native beam endpoints before movement and lethal damage',function()
 local c=create_mock_unit('npc_dota_hero_juggernaut',2,Vector(12,30,0))
 local t=create_mock_unit('enfos_creep',3,Vector(100,50,0));mock_world_units={c,t}
 local a=enfos_juggernaut_omni_slash();a.GetCaster=function() return c end
 a.GetSpecialValueFor=function(_,k) return k=='radius' and 450 or 50 end
 local m=setmetatable({GetParent=function() return c end,GetAbility=function() return a end,home=c:GetAbsOrigin(),target=t,visitedTargets={}},modifier_enfos_pve_slashes)
 local oldCreate,oldControl,oldRelease,oldDamage=ParticleManager.CreateParticle,ParticleManager.SetParticleControl,ParticleManager.ReleaseParticleIndex,ApplyDamage
 local controls,released={},0
 ParticleManager.CreateParticle=function(_,path,attach,owner) assert(path:find('juggernaut_omni_slash.vpcf',1,true) and attach==PATTACH_WORLDORIGIN and owner==nil);return 77 end
 ParticleManager.SetParticleControl=function(_,id,cp,v) assert(id==77);controls[cp]=v end
 ParticleManager.ReleaseParticleIndex=function(_,id) assert(id==77);released=released+1 end
 ApplyDamage=function() t.alive=false end
 m:OnIntervalThink()
 ParticleManager.CreateParticle,ParticleManager.SetParticleControl,ParticleManager.ReleaseParticleIndex,ApplyDamage=oldCreate,oldControl,oldRelease,oldDamage
 assert(controls[0].x==100 and controls[0].y==50 and controls[1].x==12 and controls[1].y==30 and released==1)
end)
test('Juggernaut Blade Fury owns its loop and emits the verified ending sound',function()
 local c=create_mock_unit('npc_dota_hero_juggernaut',2,Vector(0,0,0));local sounds,stopped={},{}
 c.EmitSound=function(_,s) sounds[#sounds+1]=s end;c.StopSound=function(_,s) stopped[#stopped+1]=s end
 local a=enfos_juggernaut_blade_fury();a.GetSpecialValueFor=function() return 0.2 end
 local m=setmetatable({GetParent=function() return c end,GetAbility=function() return a end,StartIntervalThink=function() end,AddParticle=function() end},modifier_enfos_pve_fury)
 m:OnCreated();m:OnDestroy()
 assert(sounds[1]=='Hero_Juggernaut.BladeFuryStart' and sounds[2]=='Hero_Juggernaut.BladeFuryStop' and stopped[1]==sounds[1])
end)
test('Juggernaut Blade Fury supplies native radius CP and modifier-owned particle lifetime',function()
 local c=create_mock_unit('npc_dota_hero_juggernaut',2,Vector(0,0,0))
 local a=enfos_juggernaut_blade_fury();a.GetSpecialValueFor=function(_,k) return k=='radius' and 425 or 0.5 end
 local created,controlled,owned=0,0,0
 local oldCreate,oldControl,oldServer=ParticleManager.CreateParticle,ParticleManager.SetParticleControl,IsServer
 ParticleManager.CreateParticle=function(_,path,attach,parent)
  assert(path=='particles/units/heroes/hero_juggernaut/juggernaut_blade_fury.vpcf' and attach==PATTACH_ABSORIGIN_FOLLOW and parent==c)
  created=created+1;return 91
 end
 ParticleManager.SetParticleControl=function(_,id,cp,v) assert(id==91 and cp==5 and v.x==425 and v.y==0);controlled=controlled+1 end
 local m=setmetatable({GetParent=function() return c end,GetAbility=function() return a end,StartIntervalThink=function() end,
  AddParticle=function(_,id,immediate,status,priority,hero,overhead)
   assert(id==91 and immediate==false and status==false and priority==-1 and hero==false and overhead==false);owned=owned+1
  end},modifier_enfos_pve_fury)
 m:OnCreated();IsServer=function() return false end;m:OnCreated()
 ParticleManager.CreateParticle,ParticleManager.SetParticleControl,IsServer=oldCreate,oldControl,oldServer
 assert(created==1 and controlled==1 and owned==1 and modifier_enfos_pve_fury.GetEffectName==nil,
  'one server-created effect, owned by the modifier; no duplicate automatic effect')
end)

test('Shadow Shaman Fowl Play does not consume its save until lethal damage is prevented', function()
    local shaman = create_mock_unit('npc_dota_hero_shadow_shaman', 2, Vector(0, 0, 0), 1000)
    local ability = enfos_ss_fowl_play()
    local cooldownReady, cooldownStarts = true, 0
    ability.IsCooldownReady = function() return cooldownReady end
    ability.StartCooldown = function(_, duration) cooldownReady = false; cooldownStarts = cooldownStarts + 1; ability.cooldown = duration end
    ability.GetSpecialValueFor = function(_, key) return ({ cooldown = 45, duration = 6, bonus_ms = 160 })[key] or 0 end
    local passive = setmetatable({
        GetParent = function() return shaman end,
        GetAbility = function() return ability end,
    }, modifier_enfos_ss_fowl_play_passive)

    assert(passive:GetMinHealth() == 1 and cooldownStarts == 0, 'property query must not spend the save')
    shaman.hp = 700
    passive:OnTakeDamage({ unit = shaman, damage = 100 })
    assert(cooldownStarts == 0 and cooldownReady, 'non-lethal damage must not trigger Fowl Play')
    shaman.hp = 1
    passive:OnTakeDamage({ unit = shaman, damage = 999 })
    assert(cooldownStarts == 1 and not cooldownReady, 'a prevented lethal hit must start the cooldown')
    assert(shaman:HasModifier('modifier_enfos_ss_fowl_play_buff'), 'the save grants its movement buff')
    assert(passive:GetMinHealth() == 0, 'the minimum-health guard ends while the ability is on cooldown')
    passive:OnTakeDamage({ unit = shaman, damage = 1 })
    assert(cooldownStarts == 1, 'the same cooldown cannot trigger twice')
end)

test('Shadow Shaman Shackles shortens boss channel with its boss control duration', function()
    local ability = enfos_ss_shackles()
    local target = create_mock_unit('enfos_boss_test', 3, Vector(0, 0, 0))
    ability.GetSpecialValueFor = function(_, key) return key == 'duration' and 3.5 or 0 end
    ability.GetCursorTarget = function() return target end
    assert(math.abs(ability:GetChannelTime() - 1.225) < 0.0001, 'boss channel and stun should share the 35% duration')
    target.name = 'enfos_ordinary_creep'
    assert(ability:GetChannelTime() == 3.5, 'ordinary targets retain the full channel')
end)

test('Shadow Shaman Scepter boosts summoned Serpent Ward attack damage', function()
    local oldSummons, oldAghanim = package.loaded['heroes/summons'], package.loaded['heroes/aghanim_manager']
    local summonedDamage, hasScepter = nil, true
    package.loaded['heroes/summons'] = { Units = function(_, _, _, _, _, _, damage, _) summonedDamage = damage end }
    package.loaded['heroes/aghanim_manager'] = {
        SCEPTER_BONUSES = { ult_damage_amp_pct = 40 },
        HasScepter = function() return hasScepter end,
    }
    local shaman = create_mock_unit('npc_dota_hero_shadow_shaman', 2, Vector(0, 0, 0))
    shaman.intellect = 100
    local ability = enfos_ss_mass_serpent_ward()
    ability.GetCaster = function() return shaman end
    ability.GetCursorPosition = function() return Vector(0, 0, 0) end
    ability.GetSpecialValueFor = function(_, key) return ({ ward_damage = 100, ward_count = 8, ward_duration = 30, ward_health = 450 })[key] or 0 end
    ability:OnSpellStart()
    assert(summonedDamage == 196, '140 base attack damage should receive the shared 40% Scepter bonus')
    hasScepter = false
    ability:OnSpellStart()
    assert(summonedDamage == 140, 'without Scepter, wards use the configured attack damage')
    package.loaded['heroes/summons'], package.loaded['heroes/aghanim_manager'] = oldSummons, oldAghanim
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
        if k == 'burn_int_pct' then return 30 end
        if k == 'corpse_burst_base' then return 120 end
        if k == 'corpse_burst_hp_pct' then return 8 end
        if k == 'corpse_burst_hp_cap' then return 600 end
        if k == 'corpse_burst_radius' then return 300 end
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

    -- Burn tick scales from the configured percent of Intelligence, not a Lua literal.
    applied_damages = {}
    local burn = setmetatable({ GetCaster = function() return lina end, GetParent = function() return creep end,
        GetAbility = function() return ab end }, modifier_enfos_pve_burn)
    burn:OnIntervalThink()
    assert(#applied_damages == 1 and applied_damages[1].damage == 55,
        'A 30% Intelligence component adds 30 to 80 DPS, applied as a half-second tick')

    -- Now test boss cap: 50,000 HP boss dying would be 4,000 dmg, but capped at 600 max health component
    applied_damages = {}
    mock_world_units = { lina, boss, neighbor }
    boss:AddNewModifier(lina, ab, 'modifier_enfos_pve_burn', { duration = 3 })
    mod:OnDeath({ unit = boss })
    assert(#applied_damages == 1)
    assert(applied_damages[1].damage == (120 + 600), 'Boss corpse explosion must be capped at 720 total')

    applied_damages = {}
    local other_lina = create_mock_unit('npc_dota_hero_lina', 2, Vector(0, 0, 0))
    local other_burned = create_mock_unit('enfos_other_lina_burn', 3, Vector(200, 0, 0), 1000)
    mock_world_units = { lina, other_lina, neighbor }
    other_burned:AddNewModifier(other_lina, ab, 'modifier_enfos_pve_burn', { duration = 3 })
    mod:OnDeath({ unit = other_burned })
    assert(#applied_damages == 0, 'Combustion must not detonate burns owned by another Lina')

    lina.PassivesDisabled = function() return true end
    applied_damages = {}
    other_burned:AddNewModifier(lina, ab, 'modifier_enfos_pve_burn', { duration = 3 })
    mod:OnDeath({ unit = other_burned })
    assert(#applied_damages == 0 and mod:GetModifierSpellAmplify_Percentage() == 0,
        'Break disables Combustion amplification and corpse detonation')

    lina.PassivesDisabled = function() return false end
    lina.IsIllusion = function() return true end
    local illusion_target = create_mock_unit('enfos_illusion_target', 3, Vector(200, 0, 0), 1000)
    mod:OnTakeDamage({ attacker = lina, unit = illusion_target,
        inflictor = { IsItem = function() return false end } })
    applied_damages = {}
    mod:OnDeath({ unit = other_burned })
    assert(not illusion_target:HasModifier('modifier_enfos_pve_burn') and #applied_damages == 0
        and mod:GetModifierSpellAmplify_Percentage() == 0,
        'Illusions must not apply Combustion burns, amplify spells, or trigger corpse detonations')
end)

test('Lina Light Strike Array deals damage and stuns only after its configured warning delay', function()
    local previous_game_rules = GameRules
    local callback, callback_delay
    GameRules = { GetGameModeEntity = function()
        return { SetContextThink = function(_, name, fn, delay) callback, callback_delay = fn, delay end }
    end }
    local lina = create_mock_unit('npc_dota_hero_lina', 2, Vector(0, 0, 0))
    lina.intellect = 100
    local creep = create_mock_unit('enfos_lsa_creep', 3, Vector(100, 0, 0))
    local boss = create_mock_unit('enfos_boss_lsa', 3, Vector(120, 0, 0))
    mock_world_units = { lina, creep, boss }
    local ability = enfos_lina_light_strike_array()
    ability.entindex = function() return 77 end
    ability.GetCaster = function() return lina end
    ability.GetCursorPosition = function() return Vector(100, 0, 0) end
    ability.GetSpecialValueFor = function(_, key)
        return ({ radius = 350, stun_duration = 2, light_strike_array_delay_time = 0.5, damage = 150 })[key] or 0
    end
    applied_damages = {}
    ability:OnSpellStart()
    assert(#applied_damages == 0 and callback_delay == 0.5,
        'Damage and control must wait for Lina Light Strike Array impact time')
    assert(callback and callback() == nil)
    assert(#applied_damages == 2 and applied_damages[1].damage == 250)
    assert(creep:HasModifier('modifier_stunned') and creep.modifiers.modifier_stunned.params.duration == 2)
    assert(boss.modifiers.modifier_stunned.params.duration == 0.7, 'Boss stun must stay at the configured 35% cap')
    GameRules = previous_game_rules
end)

test('Lina Dragon Slave uses a valid forward fallback and configured projectile speed', function()
    local lina = create_mock_unit('npc_dota_hero_lina', 2, Vector(0, 0, 0))
    lina.forward = Vector(0, 1, 0)
    local ability = enfos_lina_dragon_slave()
    ability.GetCaster = function() return lina end
    ability.GetCursorPosition = function() return lina:GetAbsOrigin() end
    ability.GetSpecialValueFor = function(_, key)
        return ({ dragon_slave_distance = 1200, dragon_slave_width_initial = 275,
            dragon_slave_width_end = 200, dragon_slave_speed = 1200 })[key] or 0
    end
    ability:OnSpellStart()
    assert(last_linear_projectile.vVelocity.x == 0 and last_linear_projectile.vVelocity.y == 1200)
    assert(last_linear_projectile.fDistance == 1200)
end)

test('Lina Laguna Blade handles spell block and validates its target before particle or damage', function()
    local lina = create_mock_unit('npc_dota_hero_lina', 2, Vector(0, 0, 0))
    lina.intellect = 100
    local target = create_mock_unit('enfos_laguna_target', 3, Vector(100, 0, 0))
    local splash = create_mock_unit('enfos_laguna_splash', 3, Vector(150, 0, 0))
    mock_world_units = { lina, target, splash }
    local ability = enfos_lina_laguna_blade()
    ability.GetCaster = function() return lina end
    ability.GetCursorTarget = function() return target end
    ability.GetSpecialValueFor = function(_, key)
        return ({ damage = 100, overflow_radius = 450, overflow_damage_pct = 50 })[key] or 0
    end
    target.TriggerSpellAbsorb = function() return true end
    applied_damages = {}
    ability:OnSpellStart()
    assert(#applied_damages == 0, 'A spell block must cancel Laguna Blade')
    target.TriggerSpellAbsorb = function() return false end
    ability:OnSpellStart()
    assert(#applied_damages == 2 and applied_damages[1].victim == target and applied_damages[1].damage == 300)
    assert(applied_damages[2].victim == splash and applied_damages[2].damage == 150)
    ability.GetCursorTarget = function() return nil end
    ability:OnSpellStart()
    assert(#applied_damages == 2, 'Missing unit targets must be ignored safely')
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
        if k == 'strength_multiplier' then return 2 end
        return 0
    end

    ab:OnSpellStart()

    -- Heal amount: 500 + (100 * 2.0) = 700
    assert(injured_ally.hp == 1000, 'Ally should be healed for 700 (capped at max hp)')
    assert(#applied_damages == 2, 'Both enemies within 400 of ally must be hit')
    assert(applied_damages[1].damage == 700 and applied_damages[1].damage_type == DAMAGE_TYPE_PURE)
    assert(applied_damages[2].damage == 700 and applied_damages[2].damage_type == DAMAGE_TYPE_PURE)
end)

test('Omniknight Repel grants unpurgable debuff immunity and rejects invalid or enemy targets', function()
    local omni = create_mock_unit('npc_dota_hero_omniknight', 2, Vector(0, 0, 0))
    local ally = create_mock_unit('ally', 2, Vector(20, 0, 0))
    local enemy = create_mock_unit('enemy', 3, Vector(30, 0, 0))
    local ability = enfos_omni_repel()
    ability.GetCaster = function() return omni end
    ability.GetCursorTarget = function() return ally end
    ability.GetSpecialValueFor = function(_, key) return key == 'duration' and 8 or 0 end
    ability:OnSpellStart()
    local buff = ally:FindModifierByName('modifier_enfos_pve_repel')
    assert(buff and buff:IsPurgable() == false and buff:IsDebuff() == false)
    assert(buff:CheckState()[MODIFIER_STATE_DEBUFF_IMMUNE] == true)
    ability.GetCursorTarget = function() return enemy end
    ability:OnSpellStart()
    assert(not enemy:FindModifierByName('modifier_enfos_pve_repel'), 'Repel must only affect allies')
    ability.GetCursorTarget = function() return nil end
    omni.alive = false
    ability:OnSpellStart()
    assert(not omni:FindModifierByName('modifier_enfos_pve_repel'), 'A dead caster must not receive the fallback buff')
end)

test('Omniknight Degen Aura tick damage uses configured pure-damage scaling', function()
    applied_damages = {}
    local omni = create_mock_unit('npc_dota_hero_omniknight', 2, Vector(0, 0, 0))
    omni.strength = 100
    local enemy = create_mock_unit('degen_target', 3, Vector(100, 0, 0))
    local ability = enfos_omni_degen_aura()
    ability.GetSpecialValueFor = function(_, key)
        return ({ damage_per_second = 40, strength_damage_factor = 0.5, slow_pct = -35, attack_slow = -45 })[key] or 0
    end
    local modifier = setmetatable({ GetCaster = function() return omni end, GetParent = function() return enemy end,
        GetAbility = function() return ability end }, modifier_enfos_pve_degen_debuff)
    modifier:OnIntervalThink()
    assert(#applied_damages == 1 and applied_damages[1].damage == 90 and applied_damages[1].damage_type == DAMAGE_TYPE_PURE)
    assert(modifier:GetModifierMoveSpeedBonus_Percentage() == -35 and modifier:GetModifierAttackSpeedBonus_Constant() == -45)
    local aura = setmetatable({ GetParent = function() return omni end, GetAbility = function() return ability end }, modifier_enfos_pve_degen_aura)
    assert(aura:IsAura() and aura:GetEffectName():find('omniknight_degen_aura.vpcf', 1, true))
    assert(modifier:GetEffectName():find('omniknight_degen_aura_debuff.vpcf', 1, true))
    omni.PassivesDisabled = function() return true end
    assert(not aura:IsAura(), 'Break must disable Degen Aura')
end)

test('Omniknight Guardian Angel applies bounded physical protection only to nearby allies', function()
    local omni = create_mock_unit('npc_dota_hero_omniknight', 2, Vector(0, 0, 0))
    local ally = create_mock_unit('near_ally', 2, Vector(200, 0, 0))
    local enemy = create_mock_unit('enemy', 3, Vector(200, 0, 0))
    mock_world_units = { omni, ally, enemy }
    local ability = enfos_omni_guardian_angel()
    ability.GetCaster = function() return omni end
    ability.GetSpecialValueFor = function(_, key) return ({ radius = 1200, duration = 6, bonus_hp_regen = 30 })[key] or 0 end
    ability:OnSpellStart()
    local self_buff = omni:FindModifierByName('modifier_enfos_pve_angel')
    local ally_buff = ally:FindModifierByName('modifier_enfos_pve_angel')
    assert(self_buff and ally_buff and self_buff:IsPurgable() == false)
    assert(self_buff:GetAbsoluteNoDamagePhysical() == 1 and self_buff:GetModifierConstantHealthRegen() == 30)
    assert(not enemy:FindModifierByName('modifier_enfos_pve_angel'), 'Guardian Angel must not affect enemies')
    assert(ally_buff:GetEffectName():find('omniknight_guardian_angel_omni.vpcf', 1, true))
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
        if k == 'slow_pct' then return -30 end
        if k == 'slow_duration' then return 2 end
        if k == 'strength_multiplier' then return 1.2 end
        if k == 'lifesteal_pct' then return 50 end
        if k == 'splash_radius' then return 275 end
        if k == 'splash_damage_pct' then return 50 end
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
    local slow = target:FindModifierByName('modifier_enfos_pve_slow')
    assert(slow and slow:GetModifierMoveSpeedBonus_Percentage() == -30, 'Hammer should apply its configured movement slow')
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
        if k == 'attacks_to_trigger' then return 2 end
        if k == 'helix_damage' then return 200 end
        if k == 'radius' then return 300 end
        if k == 'strength_damage_factor' then return 1 end
        if k == 'boss_proc_interval' then return 0.2 end
        return 0
    end

    local mod = setmetatable({
        GetParent = function() return axe end,
        GetAbility = function() return ab end
    }, modifier_enfos_axe_counter_helix_passive)
    mod:OnCreated()

    mod:OnAttacked({ attacker = creep1, target = axe })
    assert(#applied_damages == 0, 'Counter Helix must wait for its configured attack count')
    mod:OnAttacked({
        attacker = creep1,
        target = axe
    })

    -- Damage: 200 + (80 * 1.0) = 280 pure
    assert(#applied_damages == 2, 'Helix should hit both creeps in 300 radius')
    assert(applied_damages[1].damage == 280 and applied_damages[1].damage_type == DAMAGE_TYPE_PURE)
    assert(applied_damages[2].damage == 280 and applied_damages[2].damage_type == DAMAGE_TYPE_PURE)
end)

test('Axe Counter Helix passive is disabled by Break and ignores allied attacks', function()
    local axe = create_mock_unit('npc_dota_hero_axe', 2, Vector(0, 0, 0))
    local enemy = create_mock_unit('creep_enemy', 3, Vector(0, 0, 0))
    local ally = create_mock_unit('npc_dota_hero_sven', 2, Vector(0, 0, 0))
    mock_world_units = { axe, enemy, ally }
    local ability = enfos_axe_counter_helix()
    ability.GetSpecialValueFor = function(_, key) return key == 'attacks_to_trigger' and 1 or 0 end
    local mod = setmetatable({ GetParent = function() return axe end, GetAbility = function() return ability end }, modifier_enfos_axe_counter_helix_passive)
    mod:OnCreated()
    mod:OnAttacked({ attacker = ally, target = axe })
    assert((mod.attack_counter or 0) == 0, 'Allied attacks must not advance the counter')
    axe.PassivesDisabled = function() return true end
    mod:OnAttacked({ attacker = enemy, target = axe })
    assert((mod.attack_counter or 0) == 0, 'Break must disable Counter Helix')
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
        if k == 'speed_duration' then return 6.0 end
        if k == 'success_buff_radius' then return 900 end
        if k == 'success_bonus_movespeed_pct' then return 40 end
        if k == 'success_bonus_attack_speed' then return 60 end
        if k == 'strength_damage_factor' then return 2.5 end
        return 0
    end
    ab.EndCooldown = function() end

    ab:OnSpellStart()

    assert(low_creep:IsAlive() == false, 'Target below 35% HP must be executed')
    assert(axe:HasModifier('modifier_enfos_axe_culling_blade_buff'), 'Axe must get buff on kill')
    assert(ally:HasModifier('modifier_enfos_axe_culling_blade_buff'), 'Allies must get buff on kill')
    assert(axe.modifiers['modifier_enfos_axe_culling_blade_buff'].params.duration == 6.0,
        'Culling Blade ally buff must use the configured speed duration')
end)

test('Axe Culling Blade uses its lower boss execute threshold', function()
    applied_damages = {}
    local axe = create_mock_unit('npc_dota_hero_axe', 2, Vector(0, 0, 0))
    local boss = create_mock_unit('enfos_boss_test', 3, Vector(100, 0, 0), 1000)
    boss.hp = 200
    mock_world_units = { axe, boss }
    local ability = enfos_axe_culling_blade()
    ability.GetCaster = function() return axe end
    ability.GetCursorTarget = function() return boss end
    ability.GetSpecialValueFor = function(_, key)
        local values = { kill_threshold_pct = 35, boss_kill_threshold_pct = 15, damage = 100, strength_damage_factor = 0,
            success_buff_radius = 0, speed_duration = 0 }
        return values[key] or 0
    end
    ability.EndCooldown = function() end

    ability:OnSpellStart()
    assert(boss:IsAlive(), 'A boss above its configured execute threshold must survive')
    assert(#applied_damages == 1 and applied_damages[1].damage == 100, 'A non-executing boss hit deals configured damage')

    boss.hp = 150
    ability:OnSpellStart()
    assert(not boss:IsAlive(), 'A boss at its configured execute threshold must be executed')
end)

test('Axe Battle Hunger spreads only to configured number within configured radius', function()
    local axe = create_mock_unit('npc_dota_hero_axe', 2, Vector(0, 0, 0))
    local dead = create_mock_unit('creep_dead', 3, Vector(0, 0, 0))
    local near1 = create_mock_unit('creep_near1', 3, Vector(100, 0, 0))
    local near2 = create_mock_unit('creep_near2', 3, Vector(200, 0, 0))
    local near3 = create_mock_unit('creep_near3', 3, Vector(250, 0, 0))
    local far = create_mock_unit('creep_far', 3, Vector(600, 0, 0))
    mock_world_units = { axe, dead, near1, near2, near3, far }
    local ability = enfos_axe_battle_hunger()
    ability.GetCaster = function() return axe end
    ability.GetSpecialValueFor = function(_, key)
        if key == 'spread_radius' then return 300 end
        if key == 'spread_duration' then return 7 end
        if key == 'spread_target_count' then return 2 end
        return 0
    end
    local mod = setmetatable({ GetParent = function() return dead end, GetCaster = function() return axe end, GetAbility = function() return ability end }, modifier_enfos_axe_battle_hunger_debuff)
    mod:OnDeath({ unit = dead })
    local applied = 0
    for _, unit in ipairs({ near1, near2, near3, far }) do
        if unit:HasModifier('modifier_enfos_axe_battle_hunger_debuff') then
            applied = applied + 1
            assert(unit.modifiers['modifier_enfos_axe_battle_hunger_debuff'].params.duration == 7)
        end
    end
    assert(applied == 2, 'Spread must honor configured target cap and stay within the configured radius')
    assert(not far:HasModifier('modifier_enfos_axe_battle_hunger_debuff'))
end)

test('Axe Blood Armor stacks only from configured enemy kills and caps armor/regen stacks', function()
    local axe = create_mock_unit('npc_dota_hero_axe', 2, Vector(0, 0, 0))
    local creep = create_mock_unit('creep_enemy', 3, Vector(0, 0, 0))
    local ally = create_mock_unit('npc_dota_hero_sven', 2, Vector(0, 0, 0))
    local ability = enfos_axe_blood_armor()
    ability.GetSpecialValueFor = function(_, key)
        local values = { stack_cap = 2, creep_kills_per_stack = 2, armor_per_stack = 3, health_regen_per_stack = 4, bonus_armor = 8, bonus_health_regen = 20 }
        return values[key] or 0
    end
    local mod = setmetatable({ GetParent = function() return axe end, GetAbility = function() return ability end, SetStackCount = function(self, n) self.stack_count = n end }, modifier_enfos_axe_blood_armor_passive)
    mod:OnDeath({ attacker = axe, unit = ally })
    assert((mod.stacks or 0) == 0, 'Allied deaths must not grant stacks')
    for _ = 1, 6 do mod:OnDeath({ attacker = axe, unit = creep }) end
    assert(mod.stacks == 2 and mod.stack_count == 2, 'Stacks must follow configured threshold and cap')
    assert(mod:GetModifierPhysicalArmorBonus() == 14)
    assert(mod:GetModifierConstantHealthRegen() == 28)
end)

test('Axe Blood Armor reflects only physical enemy damage, ignores reflected damage and respects Break', function()
    applied_damages = {}
    local axe = create_mock_unit('npc_dota_hero_axe', 2, Vector(0, 0, 0))
    local enemy = create_mock_unit('creep_attacker', 3, Vector(100, 0, 0))
    local ability = enfos_axe_blood_armor()
    ability.GetSpecialValueFor = function(_, key)
        return key == 'physical_damage_reflect_pct' and 25 or 0
    end
    local mod = setmetatable({ GetParent = function() return axe end, GetAbility = function() return ability end }, modifier_enfos_axe_blood_armor_passive)

    mod:OnTakeDamage({ unit = axe, attacker = enemy, damage_type = DAMAGE_TYPE_PHYSICAL, original_damage = 80, damage_flags = 0 })
    assert(#applied_damages == 1 and applied_damages[1].victim == enemy, 'Physical enemy damage should reflect once')
    assert(applied_damages[1].damage == 20 and applied_damages[1].damage_type == DAMAGE_TYPE_PHYSICAL)
    assert(applied_damages[1].damage_flags == DOTA_DAMAGE_FLAG_REFLECTION)

    mod:OnTakeDamage({ unit = axe, attacker = enemy, damage_type = DAMAGE_TYPE_MAGICAL, original_damage = 80, damage_flags = 0 })
    mod:OnTakeDamage({ unit = axe, attacker = enemy, damage_type = DAMAGE_TYPE_PHYSICAL, original_damage = 80, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION })
    assert(#applied_damages == 1, 'Magic and reflected hits must not cause another reflection')

    axe.PassivesDisabled = function() return true end
    mod:OnTakeDamage({ unit = axe, attacker = enemy, damage_type = DAMAGE_TYPE_PHYSICAL, original_damage = 80, damage_flags = 0 })
    assert(#applied_damages == 1, 'Break must disable damage reflection')
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
        if k == 'strength_damage_factor' then return 1.5 end
        if k == 'boss_stun_pct' then return 40 end
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

test('Centaur Double Edge uses configured splash radius and self-damage', function()
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
        if k == 'radius' then return 40 end
        if k == 'strength_damage_factor' then return 0.6 end
        if k == 'max_health_damage_pct' then return 15 end
        if k == 'self_damage_pct' then return 30 end
        if k == 'minimum_health' then return 1 end
        return 0
    end

    ab:OnSpellStart()

    -- Damage: 300 + (120 * 0.6) + (2000 * 0.15) = 672 pure. The neighbor is 50 units away,
    -- so a configured 40 radius must exclude it even though the ability default is 250.
    assert(#applied_damages == 1, 'Configured 40 radius must only damage the targeted creep')
    assert(applied_damages[1].damage == 672 and applied_damages[1].damage_type == DAMAGE_TYPE_PURE)
    -- Self damage: 672 * 0.3 = 201.6 -> Centaur HP becomes 2000 - 201.6 = 1798.4
    assert(centaur.hp < 2000 and centaur.hp > 1750, 'Centaur takes 30% self damage')
end)

test('Centaur Double Edge spell block cancels self-cost and damage', function()
    applied_damages = {}
    local centaur = create_mock_unit('npc_dota_hero_centaur', 2, Vector(0, 0, 0), 2000)
    local target = create_mock_unit('target', 3, Vector(100, 0, 0))
    target.TriggerSpellAbsorb = function() return true end
    local ability = enfos_centaur_double_edge()
    ability.GetCaster = function() return centaur end
    ability.GetCursorTarget = function() return target end
    ability.GetSpecialValueFor = function(_, key) return key == 'edge_damage' and 300 or 0 end
    ability:OnSpellStart()
    assert(centaur.hp == 2000 and #applied_damages == 0, 'Spell block must prevent both Double Edge damage and its health cost')
end)

test('Centaur Return rejects allied damage and is disabled by Break', function()
    applied_damages = {}
    local centaur = create_mock_unit('npc_dota_hero_centaur', 2, Vector(0, 0, 0))
    local ally = create_mock_unit('npc_dota_hero_sven', 2, Vector(0, 0, 0))
    local enemy = create_mock_unit('creep_enemy', 3, Vector(0, 0, 0))
    local ability = enfos_centaur_return()
    ability.GetSpecialValueFor = function(_, key) return key == 'return_damage' and 40 or 0 end
    local mod = setmetatable({ GetParent = function() return centaur end, GetAbility = function() return ability end }, modifier_enfos_centaur_return_passive)
    mod:OnCreated()
    mod:OnTakeDamage({ unit = centaur, attacker = ally, damage = 100 })
    assert(#applied_damages == 0 and mod.accumulated_damage == 0, 'Allied damage must not trigger Return or its pulse counter')
    centaur.PassivesDisabled = function() return true end
    mod:OnTakeDamage({ unit = centaur, attacker = enemy, damage = 100 })
    assert(#applied_damages == 0 and mod.accumulated_damage == 0, 'Break must disable Return')
end)

test('Centaur Return reflects enemy damage and pulses at the configured threshold', function()
    applied_damages = {}
    local centaur = create_mock_unit('npc_dota_hero_centaur', 2, Vector(0, 0, 0))
    centaur.strength = 100
    local attacker = create_mock_unit('creep_enemy', 3, Vector(100, 0, 0))
    mock_world_units = { centaur, attacker }
    local ability = { GetSpecialValueFor = function(_, key)
        return ({ return_damage = 20, strength_damage_factor = 0.5,
            pulse_damage_threshold = 300, pulse_radius = 250 })[key] or 0
    end }
    local mod = setmetatable({ GetParent = function() return centaur end,
        GetAbility = function() return ability end }, modifier_enfos_centaur_return_passive)
    mod:OnCreated()
    mod:OnTakeDamage({ unit = centaur, attacker = attacker, damage = 150, damage_flags = 0 })
    assert(#applied_damages == 1 and applied_damages[1].victim == attacker
        and applied_damages[1].damage == 70, 'Return must reflect its configured flat plus Strength damage')
    mod:OnTakeDamage({ unit = centaur, attacker = attacker, damage = 150, damage_flags = 0 })
    assert(#applied_damages == 3, 'Crossing the threshold must add one AoE pulse after reflecting the triggering hit')
    assert(applied_damages[2].damage_flags == DOTA_DAMAGE_FLAG_REFLECTION,
        'Returned damage must carry the reflection flag to prevent recursive Return')
    assert(applied_damages[3].victim == attacker and applied_damages[3].damage == 70,
        'The configured pulse must deal the same Return damage to enemies in radius')
    assert(last_find_units_flags == DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        'Physical Return pulse must query magic-immune enemies as its KV immunity policy allows')
    assert(mod.accumulated_damage == 0, 'Threshold pulse must consume its accumulated-damage window')
end)

test('Centaur Stampede tramples each enemy once per ally buff', function()
    applied_damages = {}
    local centaur = create_mock_unit('npc_dota_hero_centaur', 2, Vector(0, 0, 0))
    centaur.strength = 100
    local enemy = create_mock_unit('creep_stampede', 3, Vector(100, 0, 0))
    mock_world_units = { centaur, enemy }
    local ability = { GetSpecialValueFor = function(_, key)
        return ({ trample_damage = 200, strength_damage_factor = 2,
            trample_radius = 150, slow_duration = 1.5, slow_pct = 40 })[key] or 0
    end }
    local mod = setmetatable({ GetParent = function() return centaur end,
        GetCaster = function() return centaur end, GetAbility = function() return ability end,
        StartIntervalThink = function() end }, modifier_enfos_centaur_stampede_buff)
    mod:OnCreated()
    mod:OnIntervalThink()
    assert(#applied_damages == 1 and applied_damages[1].victim == enemy
        and applied_damages[1].damage == 400 and applied_damages[1].damage_type == DAMAGE_TYPE_PHYSICAL,
        'Stampede trample must apply configured Strength-scaled physical damage')
    assert(enemy:HasModifier('modifier_enfos_centaur_stampede_slow'), 'Trampled enemies must receive the slow')
    mod:OnIntervalThink()
    assert(#applied_damages == 1, 'One ally buff must not trample the same enemy repeatedly during its duration')
end)

test('Centaur Colossal Hide blocks physical damage and loses both bonuses under Break', function()
    local centaur = create_mock_unit('npc_dota_hero_centaur', 2, Vector(0, 0, 0))
    centaur.strength = 100
    local ability = { GetSpecialValueFor = function(_, key)
        return ({ damage_block = 40, strength_block_factor = 0.05, bonus_health_pct = 25 })[key] or 0
    end }
    local mod = setmetatable({ GetParent = function() return centaur end,
        GetAbility = function() return ability end }, modifier_enfos_centaur_colossal_hide_passive)
    assert(mod:GetModifierPhysical_ConstantBlock() == 45, 'Physical block must include the configured Strength component')
    assert(mod:GetModifierExtraHealthPercentage() == 25, 'Passive must grant its configured bonus maximum health')
    centaur.PassivesDisabled = function() return true end
    assert(mod:GetModifierPhysical_ConstantBlock() == 0 and mod:GetModifierExtraHealthPercentage() == 0,
        'Break must disable both Colossal Hide properties')
end)

test('Centaur Stampede exposes configured speed and damage reduction', function()
    local ability = enfos_centaur_stampede()
    ability.GetSpecialValueFor = function(_, key)
        if key == 'movespeed' then return 525 end
        if key == 'incoming_damage_pct' then return -35 end
        return 0
    end
    local buff = setmetatable({ GetAbility = function() return ability end }, modifier_enfos_centaur_stampede_buff)
    assert(buff:GetModifierMoveSpeed_Absolute() == 525)
    assert(buff:GetModifierIncomingDamage_Percentage() == -35)
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
        if k == 'damage_per_hero_or_boss' then return 100 end
        if k == 'attack_speed_per_creep' then return 5 end
        if k == 'attack_speed_per_hero_or_boss' then return 30 end
        if k == 'movespeed_per_creep' then return 2 end
        if k == 'movespeed_per_hero_or_boss' then return 10 end
        if k == 'movespeed_cap' then return 60 end
        if k == 'buff_duration' then return 6 end
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

test('Legion Press the Attack purges and buffs only a living ally', function()
    local legion = create_mock_unit('npc_dota_hero_legion_commander', 2, Vector(0, 0, 0))
    local ally = create_mock_unit('npc_dota_hero_sven', 2, Vector(100, 0, 0))
    local enemy = create_mock_unit('enemy', 3, Vector(100, 0, 0))
    local purge_args
    ally.Purge = function(_, ...) purge_args = { ... } end
    enemy.Purge = function() error('Press the Attack must not purge an enemy target') end
    local ability = enfos_legion_press_the_attack()
    ability.GetCaster = function() return legion end
    ability.GetCursorTarget = function() return ally end
    ability.GetSpecialValueFor = function(_, key) return key == 'duration' and 6 or 0 end

    ability:OnSpellStart()
    assert(ally:HasModifier('modifier_enfos_legion_press_the_attack_buff'), 'Friendly target receives the buff')
    assert(purge_args and purge_args[1] == false and purge_args[2] == true and purge_args[4] == true,
        'Friendly target receives the configured debuff/stun purge call')
    assert(ally.modifiers['modifier_enfos_legion_press_the_attack_buff'].params.duration == 6)

    ability.GetCursorTarget = function() return enemy end
    ability:OnSpellStart()
    assert(not enemy:HasModifier('modifier_enfos_legion_press_the_attack_buff'), 'Enemy target receives no buff')
end)

test('Legion Duel spell block prevents both sides entering the Duel', function()
    local lc = create_mock_unit('npc_dota_hero_legion_commander', 2, Vector(0, 0, 0))
    local target = create_mock_unit('enemy', 3, Vector(100, 0, 0))
    target.TriggerSpellAbsorb = function() return true end
    local ability = enfos_legion_duel()
    ability.GetCaster = function() return lc end
    ability.GetCursorTarget = function() return target end
    ability.GetSpecialValueFor = function(_, key) return key == 'duration' and 4 or 0 end
    ability:OnSpellStart()
    assert(not lc:HasModifier('modifier_enfos_legion_duel_buff') and not target:HasModifier('modifier_enfos_legion_duel_buff'),
        'Spell block must cancel the paired Duel modifiers')
end)

test('Legion Moment of Courage is disabled by Break and ignores allied attacks', function()
    local lc = create_mock_unit('npc_dota_hero_legion_commander', 2, Vector(0, 0, 0))
    local enemy = create_mock_unit('enemy', 3, Vector(100, 0, 0))
    local ally = create_mock_unit('npc_dota_hero_sven', 2, Vector(100, 0, 0))
    local ability = enfos_legion_moment_of_courage()
    ability.GetSpecialValueFor = function(_, key) return key == 'trigger_chance' and 100 or 0 end
    local mod = setmetatable({ GetParent = function() return lc end, GetAbility = function() return ability end }, modifier_enfos_legion_moment_of_courage_passive)
    mod:OnCreated()
    mod:OnAttacked({ attacker = ally, target = lc })
    assert(not mod.proc_active, 'Allied attacks must not trigger the counterattack')
    lc.PassivesDisabled = function() return true end
    mod:OnAttacked({ attacker = enemy, target = lc })
    assert(not mod.proc_active, 'Break must disable Moment of Courage')
end)

test('Legion Moment of Courage lifesteals only from its counterattack target and attack damage', function()
    local lc = create_mock_unit('npc_dota_hero_legion_commander', 2, Vector(0, 0, 0))
    local counter_target = create_mock_unit('enemy', 3, Vector(100, 0, 0))
    local secondary = create_mock_unit('secondary_enemy', 3, Vector(120, 0, 0))
    lc.hp = 100
    local ability = enfos_legion_moment_of_courage()
    ability.GetSpecialValueFor = function(_, key) return key == 'proc_lifesteal_pct' and 75 or 0 end
    local mod = setmetatable({ GetParent = function() return lc end, GetAbility = function() return ability end,
        proc_active = true, proc_target = counter_target }, modifier_enfos_legion_moment_of_courage_passive)

    mod:OnTakeDamage({ attacker = lc, unit = counter_target, damage = 100, damage_category = DOTA_DAMAGE_CATEGORY_ATTACK })
    assert(lc.hp == 175, 'Counterattack damage to the tracked target must heal for configured lifesteal')
    mod:OnTakeDamage({ attacker = lc, unit = secondary, damage = 100, damage_category = DOTA_DAMAGE_CATEGORY_ATTACK })
    mod:OnTakeDamage({ attacker = lc, unit = counter_target, damage = 100, damage_category = DOTA_DAMAGE_CATEGORY_SPELL })
    assert(lc.hp == 175, 'Unrelated proc damage and spell damage must not add counterattack lifesteal')
end)

test("Legion Commander's Banner applies owner/ally values and attack-only lifesteal", function()
    local legion = create_mock_unit('npc_dota_hero_legion_commander', 2, Vector(0, 0, 0))
    local ally = create_mock_unit('npc_dota_hero_sven', 2, Vector(0, 0, 0))
    local enemy = create_mock_unit('creep_enemy', 3, Vector(0, 0, 0))
    legion.hp = 200
    local ab = enfos_legion_commanders_banner()
    ab.GetSpecialValueFor = function(_, key)
        local values = { aura_radius = 900, owner_bonus_damage_pct = 40, bonus_damage_pct = 20,
            owner_lifesteal_pct = 24, lifesteal_pct = 12 }
        return values[key] or 0
    end
    local owner_buff = modifier_enfos_legion_commanders_banner_buff()
    owner_buff.GetParent = function() return legion end
    owner_buff.GetCaster = function() return legion end
    owner_buff.GetAbility = function() return ab end
    assert(owner_buff:GetModifierBaseDamageOutgoing_Percentage() == 40)
    owner_buff:OnAttackLanded({ attacker = legion, target = enemy, damage = 100 })
    assert(legion.hp == 224, 'Legion receives configured 24% attack lifesteal')
    owner_buff:OnAttackLanded({ attacker = legion, target = legion, damage = 100 })
    assert(legion.hp == 224, 'Friendly attacks must not trigger the aura lifesteal')

    local ally_buff = modifier_enfos_legion_commanders_banner_buff()
    ally_buff.GetParent = function() return ally end
    ally_buff.GetCaster = function() return legion end
    ally_buff.GetAbility = function() return ab end
    assert(ally_buff:GetModifierBaseDamageOutgoing_Percentage() == 20)
end)

test('Sniper Keen Eye pierces line behind primary target for secondary damage', function()
    applied_damages = {}
    local sniper = create_mock_unit('npc_dota_hero_sniper', 2, Vector(0, 0, 0))
    local primary = create_mock_unit('primary', 3, Vector(200, 0, 0))
    local behind = create_mock_unit('behind', 3, Vector(350, 0, 0))
    mock_world_units = { sniper, primary, behind }

    local ab = enfos_sniper_keen_eye()
    ab.GetSpecialValueFor = function(_, key)
        return ({ pierce_damage_pct = 40, pierce_distance = 550, pierce_width = 300, max_pierced_targets = 3 })[key] or 0
    end
    local mod = setmetatable({
        GetParent = function() return sniper end,
        GetAbility = function() return ab end
    }, modifier_enfos_sniper_keen_eye_passive)

    mod:OnAttackLanded({
        attacker = sniper,
        target = primary,
        damage = 300
    })

    -- Configured 40% of 300 = 120 physical to behind unit
    assert(#applied_damages == 1, 'Secondary enemy behind must be pierced')
    assert(applied_damages[1].victim == behind and applied_damages[1].damage == 120)
end)

test('Sniper Keen Eye is a forward lane, excludes flanks, and caps targets', function()
    applied_damages = {}
    local sniper = create_mock_unit('npc_dota_hero_sniper', 2, Vector(0, 0, 0))
    local primary = create_mock_unit('primary', 3, Vector(200, 0, 0))
    local behind1 = create_mock_unit('behind1', 3, Vector(300, 0, 0))
    local behind2 = create_mock_unit('behind2', 3, Vector(400, 0, 0))
    local behind3 = create_mock_unit('behind3', 3, Vector(500, 0, 0))
    local behind4 = create_mock_unit('behind4', 3, Vector(600, 0, 0))
    local flank = create_mock_unit('flank', 3, Vector(350, 200, 0))
    local in_front = create_mock_unit('in_front', 3, Vector(100, 0, 0))
    mock_world_units = { sniper, primary, behind4, flank, behind2, in_front, behind1, behind3 }
    local ab = enfos_sniper_keen_eye()
    ab.GetSpecialValueFor = function(_, key)
        return ({ pierce_damage_pct = 40, pierce_distance = 550, pierce_width = 300, max_pierced_targets = 3 })[key] or 0
    end
    local mod = setmetatable({ GetParent = function() return sniper end, GetAbility = function() return ab end },
        modifier_enfos_sniper_keen_eye_passive)
    mod:OnAttackLanded({ attacker = sniper, target = primary, damage = 300 })
    assert(#applied_damages == 3, 'Keen Eye should pierce no more than the configured number of targets')
    assert(applied_damages[1].victim == behind1 and applied_damages[2].victim == behind2
        and applied_damages[3].victim == behind3, 'Keen Eye should choose the nearest enemies in its lane')
    for _, hit in ipairs(applied_damages) do assert(hit.damage == 120 and hit.damage_type == DAMAGE_TYPE_PHYSICAL) end
    sniper.IsIllusion = function() return true end
    mod:OnAttackLanded({ attacker = sniper, target = primary, damage = 300 })
    assert(#applied_damages == 3, 'illusion copies must not duplicate the custom Keen Eye passive')
end)

test('Sniper Headshot and Keen Eye passives honor Break and reject allied targets', function()
    applied_damages = {}
    local sniper = create_mock_unit('npc_dota_hero_sniper', 2, Vector(0, 0, 0))
    local ally = create_mock_unit('npc_dota_hero_sven', 2, Vector(100, 0, 0))
    local enemy = create_mock_unit('enemy', 3, Vector(200, 0, 0))
    mock_world_units = { sniper, ally, enemy }
    local headshot = enfos_sniper_headshot()
    headshot.GetSpecialValueFor = function(_, key) return key == 'proc_chance' and 100 or 0 end
    local hs = setmetatable({ GetParent = function() return sniper end, GetAbility = function() return headshot end }, modifier_enfos_sniper_headshot_passive)
    sniper.PassivesDisabled = function() return true end
    hs:OnAttackLanded({ attacker = sniper, target = enemy })
    local keen = setmetatable({ GetParent = function() return sniper end, GetAbility = function() return enfos_sniper_keen_eye() end }, modifier_enfos_sniper_keen_eye_passive)
    keen:OnAttackLanded({ attacker = sniper, target = ally, damage = 100 })
    assert(#applied_damages == 0, 'Break must suppress both Sniper passives, and Keen Eye must ignore allies')
end)

test('Sniper Headshot applies configured bonus damage and non-boss knockback', function()
    applied_damages = {}
    local sniper = create_mock_unit('npc_dota_hero_sniper', 2, Vector(0, 0, 0))
    sniper.agility = 80
    local target = create_mock_unit('enemy', 3, Vector(100, 0, 0))
    local ability = enfos_sniper_headshot()
    ability.GetSpecialValueFor = function(_, key)
        return ({ proc_chance = 100, headshot_damage = 120, knockback_distance = 60, take_aim_proc_chance = 80 })[key] or 0
    end
    local mod = setmetatable({ GetParent = function() return sniper end, GetAbility = function() return ability end },
        modifier_enfos_sniper_headshot_passive)
    mod:OnAttackLanded({ attacker = sniper, target = target })
    assert(#applied_damages == 1 and applied_damages[1].victim == target)
    assert(applied_damages[1].damage == 180 and applied_damages[1].damage_type == DAMAGE_TYPE_PHYSICAL,
        'Headshot must apply configured base damage plus 75% Agility')
    assert(target.origin.x == 160 and target.origin.y == 0, 'Non-boss target must be displaced by configured knockback')
end)

test('Sniper Assassinate deals damage only when its tracking projectile hits', function()
    applied_damages = {}
    local sniper = create_mock_unit('npc_dota_hero_sniper', 2, Vector(0, 0, 0))
    local target = create_mock_unit('creep_target', 3, Vector(800, 0, 0))
    local ab = enfos_sniper_assassinate()
    ab.GetCaster = function() return sniper end
    ab.GetCursorTarget = function() return target end
    ab.GetSpecialValueFor = function(_, key)
        local values = { damage = 650, agility_damage_factor = 3, projectile_speed = 3000 }
        return values[key] or 0
    end

    ab:OnSpellStart()
    assert(#applied_damages == 0, 'Assassinate damage must wait for projectile impact')
    assert(last_tracking_projectile.Target == target and last_tracking_projectile.iMoveSpeed == 3000)
    assert(ab:OnProjectileHit(target, target:GetAbsOrigin()) == true)
    assert(#applied_damages == 1 and applied_damages[1].damage == 800)
    assert(applied_damages[1].victim == target and applied_damages[1].damage_type == DAMAGE_TYPE_PHYSICAL)
end)

test('Sniper Assassinate spell block prevents projectile launch', function()
    applied_damages = {}
    last_tracking_projectile = nil
    local sniper = create_mock_unit('npc_dota_hero_sniper', 2, Vector(0, 0, 0))
    local target = create_mock_unit('creep_target', 3, Vector(800, 0, 0))
    target.TriggerSpellAbsorb = function() return true end
    local ability = enfos_sniper_assassinate()
    ability.GetCaster = function() return sniper end
    ability.GetCursorTarget = function() return target end
    ability:OnSpellStart()
    assert(last_tracking_projectile == nil and #applied_damages == 0,
        'A spell-blocked target must not receive a projectile or impact damage')
end)

test('Crystal Maiden Glacial Mastery triggers 5-stack Glacial Shatter with boss cap', function()
    applied_damages = {}
    local cm = create_mock_unit('npc_dota_hero_crystal_maiden', 2, Vector(0, 0, 0))
    local boss = create_mock_unit('enfos_boss_hydra', 3, Vector(100, 0, 0), 20000)
    local neighbor = create_mock_unit('neighbor', 3, Vector(150, 0, 0))
    mock_world_units = { cm, boss, neighbor }

    local ab = enfos_cm_glacial_mastery()
    ab.GetSpecialValueFor = function(_, key)
        return ({ shatter_damage = 200, frost_stack_limit = 5, freeze_duration = 1.5, boss_freeze_duration_pct = 25,
            max_hp_damage_pct = 10, boss_shatter_damage_cap = 600, shatter_radius = 300 })[key] or 0
    end
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

    -- Max HP damage: 20000 * 0.10 = 2000, capped at 600 for bosses. Configured bonus: 200.
    assert(#applied_damages == 2, 'Shatter hits boss and neighbor in 300 radius')
    assert(applied_damages[1].damage == 800 and applied_damages[1].damage_type == DAMAGE_TYPE_MAGICAL)
    assert(applied_damages[2].damage == 800 and applied_damages[2].damage_type == DAMAGE_TYPE_MAGICAL)
    assert(boss.modifiers['modifier_enfos_cm_frozen'].params.duration == 0.375, 'Boss freeze duration must be capped to 25%')
end)

test('Crystal Maiden Frostbite spell block cancels the debuff', function()
    local cm = create_mock_unit('npc_dota_hero_crystal_maiden', 2, Vector(0, 0, 0))
    local enemy = create_mock_unit('enemy', 3, Vector(50, 0, 0))
    enemy.TriggerSpellAbsorb = function() return true end
    local ability = enfos_cm_frostbite()
    ability.GetCaster = function() return cm end
    ability.GetCursorTarget = function() return enemy end
    ability.GetSpecialValueFor = function(_, key) return key == 'duration' and 3 or 0 end
    ability:OnSpellStart()
    assert(not enemy:HasModifier('modifier_enfos_cm_frostbite_debuff'), 'Spell block must prevent Frostbite')
end)

test('Crystal Maiden Arcane Aura uses configured global range and includes allied basics', function()
    local cm = create_mock_unit('npc_dota_hero_crystal_maiden', 2, Vector(0, 0, 0))
    local aura = modifier_enfos_cm_arcane_aura()
    aura.GetAbility = function()
        return { GetSpecialValueFor = function(_, key) return key == 'aura_radius' and 99999 or 0 end }
    end
    assert(aura:GetAuraRadius() == 99999)
    assert(aura:GetAuraSearchType() == DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        'The support aura should reach friendly basic units as its tooltip promises')
    local owner = create_mock_unit('npc_dota_hero_crystal_maiden', 2, Vector(0, 0, 0))
    local ability = { GetSpecialValueFor = function(_, key)
        return ({ aura_radius = 99999, mana_regen = 4, spell_amp = 18 })[key] or 0
    end }
    aura.GetParent = function() return owner end
    aura.GetAbility = function() return ability end
    assert(aura:GetAuraEntityReject(owner), 'The aura source must be excluded to prevent duplicate self bonuses')
    assert(aura:GetModifierConstantManaRegen() == 12 and aura:GetModifierSpellAmplify_Percentage() == 18,
        'Crystal Maiden must receive her own triple mana regen and spell amplification directly')
end)

test('Crystal Maiden Freezing Field defensive bonuses and slow read KV', function()
    local ability = { GetSpecialValueFor = function(_, key)
        return ({ bonus_armor = 20, bonus_magic_resist = 50, slow_pct = 35 })[key] or 0
    end }
    local mod = setmetatable({ GetAbility = function() return ability end }, modifier_enfos_cm_freezing_field_channel)
    local slow = setmetatable({ GetAbility = function() return ability end }, modifier_enfos_cm_freezing_field_slow)
    assert(mod:GetModifierPhysicalArmorBonus() == 20)
    assert(mod:GetModifierMagicalResistanceBonus() == 50)
    assert(slow:GetModifierMoveSpeedBonus_Percentage() == -35)
end)

test('Crystal Nova particle is emitted at the selected ground point', function()
    local cm = create_mock_unit('npc_dota_hero_crystal_maiden', 2, Vector(0, 0, 0))
    mock_world_units = { cm }
    local point = Vector(500, 600, 32)
    local previous_manager, previous_attach = ParticleManager, PATTACH_WORLDORIGIN
    local created = {}
    ParticleManager = {
        CreateParticle = function(_, path, attach, owner)
            created.path, created.attach, created.owner = path, attach, owner
            return 731
        end,
        SetParticleControl = function(_, particle, control, value)
            created.control, created.position = control, value
        end,
        ReleaseParticleIndex = function(_, particle) created.released = particle end
    }
    PATTACH_WORLDORIGIN = 941
    local ab = enfos_cm_crystal_nova()
    ab.GetCaster = function() return cm end
    ab.GetCursorPosition = function() return point end
    ab.GetSpecialValueFor = function() return 0 end
    local ok, err = pcall(ab.OnSpellStart, ab)
    ParticleManager, PATTACH_WORLDORIGIN = previous_manager, previous_attach
    assert(ok, err)
    assert(created.path == 'particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf')
    assert(created.attach == 941 and created.owner == nil, 'Ground burst must not follow the caster')
    assert(created.control == 0 and created.position == point, 'Burst control point 0 must use the selected location')
    assert(created.released == 731, 'One-shot burst particle index must be released')
end)

test('Crystal Nova uses configured area damage, Intelligence scaling and slow values', function()
    applied_damages = {}
    local cm = create_mock_unit('npc_dota_hero_crystal_maiden', 2, Vector(0, 0, 0))
    cm.intellect = 100
    local near = create_mock_unit('cm_nova_near', 3, Vector(100, 0, 0))
    local far = create_mock_unit('cm_nova_far', 3, Vector(500, 0, 0))
    mock_world_units = { cm, near, far }
    local nova = enfos_cm_crystal_nova()
    nova.GetCaster = function() return cm end
    nova.GetCursorPosition = function() return Vector(0, 0, 0) end
    nova.GetSpecialValueFor = function(_, key)
        return ({ radius = 200, damage = 120, int_damage_factor = 0.75,
            duration = 3, slow_pct = 35, attack_slow = 40 })[key] or 0
    end
    nova:OnSpellStart()
    assert(#applied_damages == 1 and applied_damages[1].victim == near)
    assert(applied_damages[1].damage == 195 and applied_damages[1].damage_type == DAMAGE_TYPE_MAGICAL)
    assert(last_find_units_radius == 200)
    local slow = near:FindModifierByName('modifier_enfos_cm_crystal_nova_slow')
    assert(slow and slow.params.duration == 3)
    slow.GetAbility = function() return nova end
    assert(slow:GetModifierMoveSpeedBonus_Percentage() == -35)
    assert(slow:GetModifierAttackSpeedBonus_Constant() == -40)
end)

test('Crystal Maiden Frostbite tick reads ranked values and boosts creep damage', function()
    applied_damages = {}
    local cm = create_mock_unit('npc_dota_hero_crystal_maiden', 2, Vector(0, 0, 0))
    cm.intellect = 50
    local creep = create_mock_unit('cm_frostbite_creep', 3, Vector(100, 0, 0), 1000)
    local ability = { GetSpecialValueFor = function(_, key)
        return ({ damage_per_second = 100, damage_interval = 0.5,
            int_damage_factor = 0.5, creep_damage_multiplier = 3 })[key] or 0
    end }
    local modifier = setmetatable({
        GetParent = function() return creep end,
        GetCaster = function() return cm end,
        GetAbility = function() return ability end,
        StartIntervalThink = function(self, interval) self.interval = interval end,
    }, modifier_enfos_cm_frostbite_debuff)
    modifier:OnCreated()
    assert(modifier.interval == 0.5)
    modifier:OnIntervalThink()
    assert(#applied_damages == 1 and applied_damages[1].victim == creep)
    assert(applied_damages[1].damage == 187.5 and applied_damages[1].damage_type == DAMAGE_TYPE_MAGICAL,
        'creep tick = (100 DPS + 50 Int scaling) x 0.5 sec x 3 multiplier')
end)

test('Crystal Maiden Arcane Aura grants configured ally and owner values and honors Break', function()
    local cm = create_mock_unit('npc_dota_hero_crystal_maiden', 2, Vector(0, 0, 0))
    local ally = create_mock_unit('cm_aura_ally', 2, Vector(100, 0, 0))
    local ability = { GetSpecialValueFor = function(_, key)
        return ({ mana_regen = 4, spell_amp = 18 })[key] or 0
    end }
    local buff = modifier_enfos_cm_arcane_aura_buff()
    buff.GetCaster = function() return cm end
    buff.GetAbility = function() return ability end
    buff.GetParent = function() return ally end
    assert(buff:GetModifierConstantManaRegen() == 4)
    assert(buff:GetModifierSpellAmplify_Percentage() == 18)
    buff.GetParent = function() return cm end
    assert(buff:GetModifierConstantManaRegen() == 4, 'Aura recipient modifier should grant only the ally value')
    local source = setmetatable({ GetParent = function() return cm end, GetAbility = function() return ability end },
        modifier_enfos_cm_arcane_aura)
    assert(source:GetModifierConstantManaRegen() == 12, 'Crystal Maiden gets triple configured mana regeneration')
    assert(source:GetModifierSpellAmplify_Percentage() == 18, 'Crystal Maiden receives aura spell amplification')
    cm.PassivesDisabled = function() return true end
    assert(buff:GetModifierConstantManaRegen() == 0 and buff:GetModifierSpellAmplify_Percentage() == 0
        and source:GetModifierConstantManaRegen() == 0 and source:GetModifierSpellAmplify_Percentage() == 0,
        'Break on aura source disables both allied bonuses')
end)

test('Crystal Maiden Freezing Field applies a configured random-target pulse and ends its loop sound', function()
    applied_damages = {}
    local cm = create_mock_unit('npc_dota_hero_crystal_maiden', 2, Vector(0, 0, 0))
    cm.intellect = 100
    local enemy = create_mock_unit('cm_field_enemy', 3, Vector(100, 0, 0), 1000)
    mock_world_units = { cm, enemy }
    local ability = { GetSpecialValueFor = function(_, key)
        return ({ radius = 300, explosion_damage = 50, int_damage_factor = 0.6,
            tick_interval = 0.25, slow_duration = 1, slow_pct = 30,
            duration = 8 })[key] or 0
    end }
    local modifier = setmetatable({
        GetParent = function() return cm end,
        GetAbility = function() return ability end,
        StartIntervalThink = function(self, interval) self.interval = interval end,
    }, modifier_enfos_cm_freezing_field_channel)
    modifier:OnCreated()
    modifier:OnIntervalThink()
    assert(modifier.interval == 0.25 and last_find_units_radius == 300)
    assert(#applied_damages == 1 and applied_damages[1].victim == enemy)
    assert(applied_damages[1].damage == 110 and applied_damages[1].damage_type == DAMAGE_TYPE_MAGICAL)
    assert(enemy:FindModifierByName('modifier_enfos_cm_freezing_field_slow').params.duration == 1)
    local stopped
    cm.StopSound = function(_, event) stopped = event end
    modifier:OnDestroy()
    assert(stopped == 'hero_Crystal.freezingField.wind', 'channel cleanup must stop its looping wind event')
end)

test('Dazzle Poison Touch only refreshes and ramps slow on Dazzle attacks', function()
    applied_damages = {}
    local dazzle = create_mock_unit('npc_dota_hero_dazzle', 2, Vector(0, 0, 0))
    local enemy = create_mock_unit('creep_poison_touch', 3, Vector(200, 0, 0))
    mock_world_units = { dazzle, enemy }
    assert(#FindUnitsInRadius(2, dazzle:GetAbsOrigin(), nil, 700, DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false) == 1,
        'Poison Touch test enemy must be inside the mock search radius')
    local ab = enfos_dazzle_poison_touch()
    ab.GetCaster = function() return dazzle end
    ab.GetSpecialValueFor = function(_, key)
        return ({ radius = 700, max_targets = 8, duration = 6, damage_per_second = 20,
            int_damage_pct = 35, slow_pct = 25, slow_per_attack = 2, max_bonus_slow = 35 })[key] or 0
    end
    ab:OnSpellStart()
    local debuff = enemy:FindModifierByName('modifier_enfos_dazzle_poison_touch_debuff')
    assert(debuff, 'Poison Touch must apply its base debuff')
    debuff.StartIntervalThink = function() end
    debuff:OnCreated()
    assert(debuff.bonus_slow == 0, 'Poison Touch must start with no bonus slow')
    local ally = create_mock_unit('npc_dota_hero_ally', 2, Vector(0, 0, 0))
    debuff:OnAttackLanded({ attacker = ally, target = enemy })
    assert(debuff.bonus_slow == 0, 'Other allied attacks must not build Dazzle attack stacks')
    debuff:OnAttackLanded({ attacker = dazzle, target = enemy })
    assert(debuff.bonus_slow == 2, 'Dazzle attacks must add configured slow')
end)

test('Dazzle Shallow Grave grants lethal-damage floor and configured healing amplification', function()
    local dazzle = create_mock_unit('npc_dota_hero_dazzle', 2, Vector(0, 0, 0))
    local ally = create_mock_unit('ally_grave', 2, Vector(100, 0, 0))
    local ab = enfos_dazzle_shallow_grave()
    ab.GetCaster = function() return dazzle end
    ab.GetCursorTarget = function() return ally end
    ab.GetSpecialValueFor = function(_, key) return ({ duration = 5, heal_amp_pct = 30 })[key] or 0 end
    ab:OnSpellStart()
    local grave = ally:FindModifierByName('modifier_enfos_dazzle_shallow_grave_buff')
    assert(grave, 'Shallow Grave must apply its protective modifier to the friendly target')
    assert(grave:GetMinHealth() == 1, 'Shallow Grave must prevent lethal damage by holding the target at 1 health')
    assert(grave:GetModifierHealAmplify_PercentageTarget() == 30, 'Shallow Grave must expose configured heal amplification')
end)

test('Dazzle Bad Juju spends configured health and reduces other ability cooldowns', function()
    local dazzle = create_mock_unit('npc_dota_hero_dazzle', 2, Vector(0, 0, 0), 1000)
    local enemy = create_mock_unit('enemy_juju', 3, Vector(100, 0, 0))
    local ally = create_mock_unit('ally_juju', 2, Vector(100, 0, 0))
    mock_world_units = { dazzle, enemy, ally }
    local cd = 10
    local affected = {
        IsItem = function() return false end,
        GetCooldownTimeRemaining = function() return cd end,
        EndCooldown = function() cd = 0 end,
        StartCooldown = function(_, duration) cd = duration end,
    }
    local just_cast = { IsItem = function() return false end }
    dazzle.GetAbilityByIndex = function(_, index) return index == 0 and affected or nil end
    local ab = enfos_dazzle_bad_juju()
    ab.GetCaster = function() return dazzle end
    ab.GetSpecialValueFor = function(_, key)
        return ({ self_health_cost_pct = 20, effect_duration = 8, radius = 500,
            cooldown_reduction = 3, ally_armor = 4, enemy_armor_reduction = 4 })[key] or 0
    end
    ab:OnSpellStart()
    assert(dazzle:GetHealth() == 800, 'Bad Juju must spend its configured percent of current health')
    assert(enemy:HasModifier('modifier_enfos_dazzle_bad_juju_debuff'), 'Bad Juju must debuff enemies in range')
    assert(ally:HasModifier('modifier_enfos_dazzle_bad_juju_buff'), 'Bad Juju must buff allies in range')
    local passive = modifier_enfos_dazzle_bad_juju_passive()
    passive.GetParent = function() return dazzle end
    passive.GetAbility = function() return ab end
    passive:OnAbilityFullyCast({ unit = dazzle, ability = just_cast })
    assert(cd == 7, 'Bad Juju passive must reduce another ability cooldown by its configured value')
end)

test('Dazzle Nothl Weave is suppressed by Break while active Poison Touch still applies', function()
    local dazzle = create_mock_unit('npc_dota_hero_dazzle', 2, Vector(0, 0, 0))
    local enemy = create_mock_unit('enemy', 3, Vector(100, 0, 0))
    mock_world_units = { dazzle, enemy }
    local weave = enfos_dazzle_nothl_weave()
    weave.GetSpecialValueFor = function(_, key) return key == 'duration' and 6 or 0 end
    dazzle.FindAbilityByName = function(_, name) return name == 'enfos_dazzle_nothl_weave' and weave or nil end
    dazzle.PassivesDisabled = function() return true end
    local poison = enfos_dazzle_poison_touch()
    poison.GetCaster = function() return dazzle end
    poison.GetSpecialValueFor = function(_, key) return ({ radius = 700, max_targets = 8, duration = 6 })[key] or 0 end
    poison:OnSpellStart()
    assert(enemy:HasModifier('modifier_enfos_dazzle_poison_touch_debuff'), 'The active Poison Touch should still apply under Break')
    assert(not enemy:HasModifier('modifier_enfos_dazzle_nothl_weave_debuff'), 'Break must suppress the Enfos passive Weave')
end)

test('Dazzle Shadow Wave heals allies and deals pure physical damage around each', function()
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
        return ({ heal_amount = 170, int_heal_factor = 1, max_bounces = 6,
            bounce_radius = 500, damage_radius = 200 })[k] or 0
    end
    local weave = { GetSpecialValueFor = function(_, key)
        return ({ armor_change = 2, max_stacks = 5, duration = 6 })[key] or 0
    end }
    dazzle.FindAbilityByName = function(_, name)
        return name == 'enfos_dazzle_nothl_weave' and weave or nil
    end

    ab:OnSpellStart()

    -- Heal: 170 + (80 * 1.0) = 250
    assert(frontline.hp == 750, 'Frontline ally must be healed for 250')
    local weave_buff = frontline:FindModifierByName('modifier_enfos_dazzle_nothl_weave_buff')
    assert(weave_buff and weave_buff:GetStackCount() == 1,
        'The first Weave application must start at one stack instead of granting zero armor')
    assert(weave_buff:GetModifierPhysicalArmorBonus() == 2, 'The first Weave stack grants configured armor')
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
        return ({ base_damage = 80, stack_damage = 40, radius = 700,
            strength_damage_factor = 0.4, stack_strength_factor = 0.15,
            max_stacks = 10, debuff_duration = 14 })[k] or 0
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

test('Bristleback reduction depends on rear/side direction and rear damage procs Quills', function()
    applied_damages = {}
    local bb = create_mock_unit('npc_dota_hero_bristleback', 2, Vector(0, 0, 0))
    local rear = create_mock_unit('enemy_rear', 3, Vector(-100, 0, 0))
    local side = create_mock_unit('enemy_side', 3, Vector(-70.71, 70.71, 0))
    local front = create_mock_unit('enemy_front', 3, Vector(100, 0, 0))
    local passive_ability = { GetSpecialValueFor = function(_, key)
        return ({ rear_angle = 70, side_angle = 110, back_damage_reduction = 40,
            side_damage_reduction = 20, quill_damage_threshold = 200 })[key] or 0
    end }
    local passive = modifier_enfos_bb_bristleback_passive()
    passive.GetParent = function() return bb end
    passive.GetAbility = function() return passive_ability end
    assert(passive:GetModifierIncomingDamage_Percentage({ attacker = front }) == 0)
    assert(passive:GetModifierIncomingDamage_Percentage({ attacker = side }) == -20)
    assert(passive:GetModifierIncomingDamage_Percentage({ attacker = rear }) == -40)

    local enemy = create_mock_unit('enemy_near_bristleback', 3, Vector(100, 0, 0))
    mock_world_units = { bb, enemy }
    local quills = { GetLevel = function() return 1 end, GetCaster = function() return bb end,
        GetSpecialValueFor = function(_, key)
            return ({ radius = 700, base_damage = 80, stack_damage = 40, strength_damage_factor = 0.4,
                stack_strength_factor = 0.15, max_stacks = 10, debuff_duration = 14 })[key] or 0
        end }
    bb.FindAbilityByName = function(_, name) return name == 'enfos_bb_quill_spray' and quills or nil end
    passive:OnCreated()
    passive:OnTakeDamage({ unit = bb, attacker = front, damage = 200 })
    passive:OnTakeDamage({ unit = bb, attacker = rear, damage = 199 })
    assert(#applied_damages == 0)
    passive:OnTakeDamage({ unit = bb, attacker = rear, damage = 1 })
    assert(#applied_damages == 1 and applied_damages[1].victim == enemy,
        'Rear damage threshold should emit one actual Quill Spray hit')
    assert(passive.accumulated_damage == 0, 'Rear threshold should reset after one retaliatory spray')
end)

test('Bristleback Goo slow and armor scale with capped stacks', function()
    local ability = { GetSpecialValueFor = function(_, key)
        return ({ armor_reduction = 4, base_slow_pct = 15, slow_per_stack = 3, max_stacks = 4 })[key] or 0
    end }
    local mod = modifier_enfos_bb_viscous_nasal_goo_debuff()
    mod.GetAbility = function() return ability end
    mod.GetStackCount = function() return 4 end
    assert(mod:GetModifierPhysicalArmorBonus() == -16)
    assert(mod:GetModifierMoveSpeedBonus_Percentage() == -27)
end)

test('Bristleback Goo spell block prevents the stack and its impact effect', function()
    local bb = create_mock_unit('npc_dota_hero_bristleback', 2, Vector(0, 0, 0))
    local target = create_mock_unit('enemy', 3, Vector(100, 0, 0))
    target.TriggerSpellAbsorb = function() return true end
    local ability = enfos_bb_viscous_nasal_goo()
    ability.GetCaster = function() return bb end
    ability.GetCursorTarget = function() return target end
    ability:OnSpellStart()
    assert(not target:HasModifier('modifier_enfos_bb_viscous_nasal_goo_debuff'), 'Spell block must cancel Goo')
end)

test('Bristleback Warpath gains one bounded stack per non-item spell cast', function()
    local bb = create_mock_unit('npc_dota_hero_bristleback', 2, Vector(0, 0, 0))
    local warpath = { GetSpecialValueFor = function(_, key)
        return ({ max_stacks = 3, stack_duration = 10, damage_per_stack = 20, ms_per_stack = 4 })[key] or 0
    end }
    local passive = modifier_enfos_bb_warpath_passive()
    passive.GetParent = function() return bb end
    passive.GetAbility = function() return warpath end
    local cast = { IsItem = function() return false end }
    passive:OnAbilityFullyCast({ unit = bb, ability = cast })
    local buff = bb:FindModifierByName('modifier_enfos_bb_warpath_buff')
    assert(buff and buff:GetStackCount() == 1)
    assert(buff:GetEffectName() == 'particles/units/heroes/hero_bristleback/bristleback_warpath.vpcf',
        'Warpath buff must use its native visual effect')
    assert(buff:GetEffectAttachType() == PATTACH_ABSORIGIN_FOLLOW,
        'Warpath visual must follow Bristleback for the buff lifetime')
    assert(buff:GetModifierPreAttack_BonusDamage() == 20 and buff:GetModifierMoveSpeedBonus_Percentage() == 4)
    passive:OnAbilityFullyCast({ unit = bb, ability = { IsItem = function() return true end } })
    assert(buff:GetStackCount() == 1, 'Items must not build native Warpath stacks')
    passive:OnAbilityFullyCast({ unit = bb, ability = cast })
    passive:OnAbilityFullyCast({ unit = bb, ability = cast })
    passive:OnAbilityFullyCast({ unit = bb, ability = cast })
    assert(buff:GetStackCount() == 3, 'Warpath stacks must respect the configured cap')
end)

test('Bristleback Warpath stops stacking and grants no bonus while Broken', function()
    local bb = create_mock_unit('npc_dota_hero_bristleback', 2, Vector(0, 0, 0))
    bb.PassivesDisabled = function() return true end
    local warpath = { GetSpecialValueFor = function(_, key) return key == 'stack_duration' and 10 or 0 end }
    local passive = setmetatable({ GetParent = function() return bb end, GetAbility = function() return warpath end }, modifier_enfos_bb_warpath_passive)
    passive:OnAbilityFullyCast({ unit = bb, ability = { IsItem = function() return false end } })
    assert(not bb:HasModifier('modifier_enfos_bb_warpath_buff'), 'Break must suppress Warpath stack gain')
end)

test('Bristleback Hairball applies Goo and Quill Spray at the cursor point', function()
    applied_damages = {}
    local bb = create_mock_unit('npc_dota_hero_bristleback', 2, Vector(0, 0, 0))
    local target = create_mock_unit('hairball_target', 3, Vector(1000, 0, 0))
    local bystander = create_mock_unit('near_caster', 3, Vector(100, 0, 0))
    mock_world_units = { bb, target, bystander }
    local goo_applications = 0
    local old_add = target.AddNewModifier
    target.AddNewModifier = function(self, caster, ability, name, params)
        if name == 'modifier_enfos_bb_viscous_nasal_goo_debuff' then goo_applications = goo_applications + 1 end
        return old_add(self, caster, ability, name, params)
    end
    local goo = { GetSpecialValueFor = function(_, key)
        return ({ duration = 5, max_stacks = 4, armor_reduction = 3,
            base_slow_pct = 15, slow_per_stack = 3 })[key] or 0
    end }
    local quills = { GetCaster = function() return bb end, GetSpecialValueFor = function(_, key)
        return ({ radius = 700, base_damage = 80, stack_damage = 40, strength_damage_factor = 0.4,
            stack_strength_factor = 0.15, max_stacks = 10, debuff_duration = 14 })[key] or 0
    end }
    bb.FindAbilityByName = function(_, name)
        if name == 'enfos_bb_viscous_nasal_goo' then return goo end
        if name == 'enfos_bb_quill_spray' then return quills end
    end
    local point = Vector(1000, 0, 0)
    local hairball = enfos_bb_hairball()
    hairball.GetCaster = function() return bb end
    hairball.GetCursorPosition = function() return point end
    hairball.GetSpecialValueFor = function(_, key) return ({ radius = 400, goo_stacks = 2 })[key] or 0 end
    local previous_manager, previous_attach = ParticleManager, PATTACH_WORLDORIGIN
    local particles = {}
    ParticleManager = {
        CreateParticle = function(_, path, attach, owner)
            local idx = #particles + 1
            particles[idx] = { path = path, attach = attach, owner = owner }
            return idx
        end,
        SetParticleControl = function(_, idx, control, position)
            particles[idx].control, particles[idx].position = control, position
        end,
        ReleaseParticleIndex = function() end
    }
    PATTACH_WORLDORIGIN = 951
    local ok, err = pcall(hairball.OnSpellStart, hairball)
    ParticleManager, PATTACH_WORLDORIGIN = previous_manager, previous_attach
    assert(ok, err)
    assert(goo_applications == 2, 'Hairball should apply two Goo stacks at its impact point')
    assert(#applied_damages == 1 and applied_damages[1].victim == target,
        'Quill Spray from Hairball must hit the cursor area, not Bristleback’s position')
    assert(applied_damages[1].ability == hairball,
        'Hairball damage must retain its ultimate inflictor so Enfos Scepter amplification applies')
    local impact
    for _, particle in ipairs(particles) do
        if particle.path == 'particles/units/heroes/hero_bristleback/bristleback_quill_spray.vpcf'
            and particle.owner == nil then impact = particle end
    end
    assert(impact and impact.attach == 951 and impact.control == 0 and impact.position == point,
        'Hairball world particle control point 0 must match its selected impact location')
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
        if k == 'strength_factor' then return 0.5 end
        if k == 'radius' then return 450 end
        if k == 'duration' then return 6 end
        return 0
    end

    ab:OnSpellStart()
    -- Mock strength factor is 0.5: attack (100) + bonus (160) + (80 * 0.5 = 40) = 300.
    assert(#applied_damages == 1)
    assert(applied_damages[1].damage == 300 and applied_damages[1].damage_type == DAMAGE_TYPE_PHYSICAL)
    assert(last_find_units_flags == DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        'Anchor Smash declares SPELL_IMMUNITY_ENEMIES_YES and must include immune enemies in its radius query')
    local debuff = target:FindModifierByName('modifier_enfos_tide_anchor_smash_debuff')
    assert(debuff ~= nil, 'Anchor smash must apply debuff')
end)

test('Tidehunter Gush blocks spell-absorbed targets and rejects allies', function()
    applied_damages = {}
    local tide = create_mock_unit('npc_dota_hero_tidehunter', 2, Vector(0, 0, 0))
    local enemy = create_mock_unit('enemy', 3, Vector(100, 0, 0))
    local ab = enfos_tide_gush()
    ab.GetCaster = function() return tide end
    ab.GetCursorTarget = function() return enemy end
    ab.GetSpecialValueFor = function(_, key) return ({gush_damage=100,damage=100,duration=3,strength_factor=1})[key] or 0 end
    enemy.TriggerSpellAbsorb = function() return true end
    ab:OnSpellStart()
    assert(#applied_damages == 0 and not enemy:HasModifier('modifier_enfos_tide_gush_debuff'))
    enemy.TriggerSpellAbsorb = function() return false end
    enemy.team = 2
    ab:OnSpellStart()
    assert(#applied_damages == 0, 'Gush must not hit a friendly unit')
    enemy.team = 3
    enemy.TriggerSpellAbsorb = function() return false end
    tide.strength = 50
    ab:OnSpellStart()
    assert(applied_damages[1].damage == 150,
        'Gush must use the KV Strength coefficient in addition to ranked base damage')
end)

test('Tidehunter Kraken Shell respects Break and applies configured block and regeneration', function()
    local tide = create_mock_unit('npc_dota_hero_tidehunter', 2, Vector(0, 0, 0))
    local purges = 0
    tide.Purge = function() purges = purges + 1 end
    local ab = enfos_tide_kraken_shell()
    ab.GetSpecialValueFor = function(_, key) return ({damage_block=70,bonus_hp_regen=12,purge_damage_threshold=100})[key] or 0 end
    local mod = modifier_enfos_tide_kraken_shell_passive()
    mod.GetParent = function() return tide end
    mod.GetAbility = function() return ab end
    local declared = {}
    for _, property in ipairs(mod:DeclareFunctions()) do declared[property] = true end
    assert(declared[MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT],
        'Kraken Shell must register its health regeneration property with the engine')
    assert(mod:GetModifierPhysical_ConstantBlock() == 72.5, 'configured block plus Strength scaling must be applied')
    assert(mod:GetModifierConstantHealthRegen() == 12)
    mod:OnTakeDamage({ unit=tide, damage=60 })
    assert(purges == 0, 'the configured purge threshold should accumulate damage before purging')
    mod:OnTakeDamage({ unit=tide, damage=50 })
    assert(purges == 1, 'crossing the configured damage threshold should purge debuffs')
    tide.PassivesDisabled = function() return true end
    assert(mod:GetModifierPhysical_ConstantBlock() == 0 and mod:GetModifierConstantHealthRegen() == 0)
end)

test('Tidehunter Ravage uses the configured boss stun cap', function()
    applied_damages = {}
    local tide = create_mock_unit('npc_dota_hero_tidehunter', 2, Vector(0, 0, 0))
    local boss = create_mock_unit('enfos_boss_tide', 3, Vector(100, 0, 0))
    mock_world_units = { tide, boss }
    local ab = enfos_tide_ravage()
    ab.GetCaster = function() return tide end
    ab.GetSpecialValueFor = function(_, key)
        return ({radius=1000,damage=300,stun_duration=3,boss_stun_duration=0.8})[key] or 0
    end
    ab:OnSpellStart()
    assert(boss.modifiers['modifier_enfos_tide_ravage_stun'].params.duration == 0.8)
end)

test('Tidehunter Colossal Presence grants configured stats and shuts off under Break', function()
    local tide = create_mock_unit('npc_dota_hero_tidehunter', 2, Vector(0, 0, 0))
    local ab = enfos_tide_colossal_presence()
    ab.GetSpecialValueFor = function(_, key) return ({bonus_health=180,bonus_armor=8,radius=850})[key] or 0 end
    local mod = modifier_enfos_tide_colossal_presence_aura()
    mod.GetParent = function() return tide end
    mod.GetAbility = function() return ab end
    assert(mod:IsAura() and mod:GetModifierExtraHealthBonus() == 180 and mod:GetModifierPhysicalArmorBonus() == 8)
    assert(mod:GetAuraRadius() == 850)
    tide.PassivesDisabled = function() return true end
    assert(not mod:IsAura() and mod:GetModifierExtraHealthBonus() == 0 and mod:GetModifierPhysicalArmorBonus() == 0)
end)

test('Wraith King Mortal Strike procs cleave damage around target', function()
    applied_damages = {}
    local wk = create_mock_unit('npc_dota_hero_skeleton_king', 2, Vector(0, 0, 0))
    local primary = create_mock_unit('primary_target', 3, Vector(100, 0, 0))
    local secondary = create_mock_unit('secondary_target', 3, Vector(150, 0, 0))
    mock_world_units = { wk, primary, secondary }

    local ab = enfos_wk_mortal_strike()
    ab.GetSpecialValueFor=function(_,key) return ({crit_chance=20,crit_mult=260,cleave_pct=50,cleave_radius=300})[key] or 0 end
    local mod = modifier_enfos_wk_mortal_strike_passive()
    mod.GetParent = function() return wk end
    mod.GetAbility = function() return ab end

    local crit = mod:GetModifierPreAttack_CriticalStrike()
    assert(crit == 260, 'Mortal Strike crit must be 260%')
    mod:OnAttackLanded({ attacker = wk, target = primary, damage = 300 })

    -- Cleave damage to secondary: 300 * 0.5 = 150
    assert(#applied_damages == 1)
    assert(applied_damages[1].victim == secondary and applied_damages[1].damage == 150)
    wk.PassivesDisabled = function() return true end
    assert(mod:GetModifierPreAttack_CriticalStrike() == 0, 'Mortal Strike must be disabled by Break')
end)

test('Wraith King Wraithfire Blast travels before dealing impact damage and effects', function()
    applied_damages = {}
    last_tracking_projectile = nil
    local wk = create_mock_unit('npc_dota_hero_skeleton_king', 2, Vector(0, 0, 0))
    wk.strength = 100
    local target = create_mock_unit('target', 3, Vector(200, 0, 0))
    mock_world_units = { wk, target }
    local ab = enfos_wk_wraithfire_blast()
    ab.GetCaster = function() return wk end
    ab.GetCursorTarget = function() return target end
    ab.GetSpecialValueFor = function(_, key)
        return ({damage=150,projectile_speed=1200,strength_damage_factor=1.2,stun_duration=1.5,
            boss_stun_duration=0.6,dot_duration=2,dot_damage=50,slow_pct=20})[key] or 0
    end
    ab:OnSpellStart()
    assert(last_tracking_projectile and last_tracking_projectile.Target == target)
    assert(last_tracking_projectile.iMoveSpeed == 1200 and last_tracking_projectile.bDodgeable)
    assert(#applied_damages == 0, 'Damage must wait until the projectile hits')
    ab:OnProjectileHit(target, target:GetAbsOrigin())
    assert(#applied_damages == 1 and applied_damages[1].damage == 270)
    assert(target:HasModifier('modifier_enfos_wk_wraithfire_blast_stun'))
    assert(target.modifiers['modifier_enfos_wk_wraithfire_blast_dot'].params.duration == 2)

    local boss = create_mock_unit('enfos_boss_wraith', 3, Vector(250, 0, 0))
    ab:OnProjectileHit(boss, boss:GetAbsOrigin())
    assert(boss.modifiers['modifier_enfos_wk_wraithfire_blast_stun'].params.duration == 0.6,
        'Boss stun must use the configured cap after projectile impact')
    assert(#applied_damages == 2)
end)

test('Wraith King Hellfire Blast rejects allies and stops at spell block', function()
    last_tracking_projectile = nil
    local wk = create_mock_unit('npc_dota_hero_skeleton_king', 2, Vector(0, 0, 0))
    local target = create_mock_unit('target', 3, Vector(200, 0, 0))
    local ab = enfos_wk_wraithfire_blast()
    ab.GetCaster = function() return wk end
    ab.GetCursorTarget = function() return target end
    target.TriggerSpellAbsorb = function() return true end
    ab:OnSpellStart()
    assert(last_tracking_projectile == nil, 'Spell block must stop the projectile at cast')
    target.TriggerSpellAbsorb = function() return false end
    target.team = 2
    ab:OnSpellStart()
    assert(last_tracking_projectile == nil, 'Hellfire Blast must reject allied targets')
end)

test('Wraith King Vampiric Aura heals attack damage and ignores spell damage callbacks', function()
    local wk = create_mock_unit('npc_dota_hero_skeleton_king', 2, Vector(0, 0, 0))
    local ally = create_mock_unit('npc_dota_hero_sven', 2, Vector(100, 0, 0))
    local enemy = create_mock_unit('enemy', 3, Vector(100, 0, 0))
    local aura = enfos_wk_vampiric_aura()
    aura.GetSpecialValueFor = function(_, key) return key == 'aura_radius' and 700 or key == 'lifesteal_pct' and 25 or 0 end
    aura.GetCaster = function() return wk end
    local aura_mod = setmetatable({ GetParent = function() return wk end, GetAbility = function() return aura end }, modifier_enfos_wk_vampiric_aura)
    assert(aura_mod:GetAuraRadius() == 700)
    assert(aura_mod:GetAuraEntityReject(wk), 'Wraith King must be excluded from the aura to prevent duplicate self lifesteal')
    local buff = setmetatable({ GetParent = function() return ally end, GetCaster = function() return wk end,
        GetAbility = function() return aura end }, modifier_enfos_wk_vampiric_aura_buff)
    wk.hp = 100
    ally.hp = 100
    aura_mod:OnAttackLanded({ attacker = wk, target = enemy, damage = 200 })
    buff:OnAttackLanded({ attacker = ally, target = enemy, damage = 200 })
    assert(wk.hp == 150 and ally.hp == 150, 'Owner and aura recipients must heal for the configured attack lifesteal')
    wk.PassivesDisabled = function() return true end
    aura_mod:OnAttackLanded({ attacker = wk, target = enemy, damage = 200 })
    buff:OnAttackLanded({ attacker = ally, target = enemy, damage = 200 })
    assert(wk.hp == 150 and ally.hp == 150, 'Broken aura owner must stop granting lifesteal')
    assert(buff:DeclareFunctions()[1] == MODIFIER_EVENT_ON_ATTACK_LANDED,
        'Aura must only receive landed-attack events, not generic spell damage events')
    assert(not aura_mod:IsAura(), 'Broken Wraith King must not emit the aura')
end)

test('Wraith King Reincarnation uses configured delay and separates boss slow duration', function()
    applied_damages = {}
    local wk = create_mock_unit('npc_dota_hero_skeleton_king', 2, Vector(0, 0, 0))
    wk.strength = 100
    wk.IsReincarnating = function() return true end
    local creep = create_mock_unit('creep_enemy', 3, Vector(100, 0, 0))
    local boss = create_mock_unit('enfos_boss_test', 3, Vector(150, 0, 0))
    mock_world_units = { wk, creep, boss }
    local ability = enfos_wk_reincarnation()
    local values = { reincarnation_time=4, damage=300, strength_damage_factor=2.5, slow_radius=900,
        slow_duration=3, boss_slow_duration=1, slow_pct=40 }
    ability.GetSpecialValueFor = function(_, key) return values[key] or 0 end
    ability.GetLevel = function() return 1 end
    ability.IsNull = function() return false end
    ability.IsCooldownReady = function() return true end
    ability.UseResources = function() ability.cooldown_used = true end
    local mod = setmetatable({ GetParent = function() return wk end, GetAbility = function() return ability end }, modifier_enfos_wk_reincarnation_passive)
    assert(mod:ReincarnateTime() == 4)
    wk.PassivesDisabled = function() return true end
    assert(mod:ReincarnateTime() == nil, 'Reincarnation must be disabled by Break')
    wk.PassivesDisabled = function() return false end
    mod:OnDeath({ unit = wk })
    assert(ability.cooldown_used, 'Reincarnation must consume its cooldown on the death event')
    assert(#applied_damages == 2 and applied_damages[1].damage == 550 and applied_damages[2].damage == 550)
    assert(creep.modifiers['modifier_enfos_wk_rebirth_slow'].params.duration == 3)
    assert(boss.modifiers['modifier_enfos_wk_rebirth_slow'].params.duration == 1)
    local slow = setmetatable({ GetAbility = function() return ability end }, modifier_enfos_wk_rebirth_slow)
    assert(slow:GetModifierMoveSpeedBonus_Percentage() == -40)
end)

test('Wraith King Skeleton Army charges ignore friendly deaths and respect KV cap', function()
    local wk = create_mock_unit('npc_dota_hero_skeleton_king', 2, Vector(0, 0, 0))
    local enemy = create_mock_unit('creep_enemy', 3, Vector(100, 0, 0))
    local ally = create_mock_unit('npc_dota_hero_sven', 2, Vector(100, 0, 0))
    local ability = enfos_wk_skeleton_army()
    ability.GetSpecialValueFor = function(_, key) return key == 'max_skeletons' and 2 or 0 end
    local mod = setmetatable({ GetParent = function() return wk end, GetAbility = function() return ability end,
        GetStackCount = function(self) return self.stack_count or 0 end,
        SetStackCount = function(self, count) self.stack_count = count end }, modifier_enfos_wk_skeleton_army_passive)
    mod:OnDeath({ attacker = wk, unit = ally })
    assert((mod.stack_count or 0) == 0)
    for _=1,4 do mod:OnDeath({ attacker = wk, unit = enemy }) end
    assert(mod.stack_count == 2, 'Kill charge count must stop at configured summon cap')
    wk.PassivesDisabled = function() return true end
    mod:OnDeath({ attacker = wk, unit = enemy })
    assert(mod.stack_count == 2, 'Break must stop passive Skeleton Army charge generation')
end)

test('Phantom Assassin Coup de Grace crits and uses its configured physical splash', function()
    applied_damages = {}
    local pa = create_mock_unit('npc_dota_hero_phantom_assassin', 2, Vector(0, 0, 0))
    local primary = create_mock_unit('pa_target', 3, Vector(100, 0, 0))
    local swarm = create_mock_unit('pa_swarm', 3, Vector(130, 0, 0))
    mock_world_units = { pa, primary, swarm }

    local ab = enfos_pa_coup_de_grace()
    ab.GetSpecialValueFor=function(_,key) return ({crit_chance=15,crit_mult=425,splash_radius=400,splash_pct=60})[key] or 0 end
    local mod = modifier_enfos_pa_coup_de_grace_passive()
    mod.GetParent = function() return pa end
    mod.GetAbility = function() return ab end

    local crit = mod:GetModifierPreAttack_CriticalStrike()
    assert(crit == 425, 'Coup de Grace crit must be 425%')
    mod:OnAttackLanded({ attacker = pa, target = primary, damage = 500 })

    -- Configured splash to swarm: 500 * 0.6 = 300.
    assert(#applied_damages == 1)
    assert(applied_damages[1].victim == swarm and applied_damages[1].damage == 300)
    assert(last_find_units_radius == 400 and last_find_units_flags == DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        'Coup splash must use KV radius and include spell-immune enemies for physical damage')
    pa.PassivesDisabled = function() return true end
    assert(mod:GetModifierPreAttack_CriticalStrike() == 0, 'Coup de Grace must be disabled by Break')
end)

test('Phantom Assassin Phantom Strike lands behind the target facing', function()
    local pa = create_mock_unit('npc_dota_hero_phantom_assassin', 2, Vector(0, 0, 0))
    local target = create_mock_unit('pa_facing_north', 3, Vector(100, 100, 0))
    target.forward = Vector(0, 1, 0)
    local ab = enfos_pa_phantom_strike()
    ab.GetCaster = function() return pa end
    ab.GetCursorTarget = function() return target end
    ab.GetSpecialValueFor = function(_, key) return ({bonus_attack_speed=100,buff_duration=3})[key] or 0 end
    ab:OnSpellStart()
    assert(pa.origin.x == 100 and pa.origin.y == 40, 'expected destination 60 units behind the target facing')
end)

test('Phantom Assassin Immaterial exposes its configured innate evasion', function()
    local ability = enfos_pa_immaterial()
    ability.GetSpecialValueFor = function(_, key) return key == 'evasion' and 10 or 0 end
    local mod = modifier_enfos_pa_immaterial_passive()
    mod.GetAbility = function() return ability end
    mod.GetParent = function() return create_mock_unit('npc_dota_hero_phantom_assassin', 2, Vector(0, 0, 0)) end
    assert(mod:GetModifierEvasion_Constant() == 10)
    local pa = mod:GetParent()
    pa.PassivesDisabled = function() return true end
    mod.GetParent = function() return pa end
    assert(mod:GetModifierEvasion_Constant() == 0, 'Enfos passive evasion must stop under Break')
end)

test('Phantom Assassin Stifling Dagger validates spell block, enemy target and configured projectile', function()
    last_tracking_projectile = nil
    local pa = create_mock_unit('npc_dota_hero_phantom_assassin', 2, Vector(0, 0, 0))
    local target = create_mock_unit('pa_dagger_target', 3, Vector(100, 0, 0))
    local ab = enfos_pa_stifling_dagger()
    ab.GetCaster = function() return pa end
    ab.GetCursorTarget = function() return target end
    ab.GetSpecialValueFor = function(_, key) return ({base_damage=100,attack_factor=70,projectile_speed=1400,
        agility_factor=0.4,chain_targets=0,chain_radius=275,chain_damage_pct=60,slow_duration=2,slow_pct=25})[key] or 0 end
    mock_world_units = { pa, target }
    target.TriggerSpellAbsorb = function() return true end
    ab:OnSpellStart()
    assert(last_tracking_projectile == nil, 'spell block must cancel the cast')
    target.TriggerSpellAbsorb = function() return false end
    ab:OnSpellStart()
    assert(last_tracking_projectile and last_tracking_projectile.iMoveSpeed == 1400)
    assert(last_tracking_projectile.ExtraData.damage == 190,
        'Dagger damage must use the configured Agility coefficient')
    assert(last_find_units_radius == 275 and last_find_units_flags == DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        'Dagger chaining must use KV radius and include spell-immune enemies for physical damage')
    local friendly = create_mock_unit('pa_ally', 2, Vector(100, 0, 0))
    ab.GetCursorTarget = function() return friendly end
    last_tracking_projectile = nil
    ab:OnSpellStart()
    assert(last_tracking_projectile == nil, 'Stifling Dagger must reject friendly targets')
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

    creep1.TriggerSpellAbsorb = function() return true end
    ab:OnSpellStart()
    assert(#applied_damages == 0, 'spell block must cancel Arc Lightning and all chain jumps')
    creep1.TriggerSpellAbsorb = function() return false end
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
        if k == 'boss_damage_cap' then return 500 end
        return 0
    end
    local mod = modifier_enfos_zeus_static_field_passive()
    mod.GetParent = function() return zeus end
    mod.GetAbility = function() return ab end

    local source_spell = {}
    mod:OnTakeDamage({ attacker = zeus, unit = creep, inflictor = source_spell, damage = 200 })
    mod:OnTakeDamage({ attacker = zeus, unit = boss, inflictor = source_spell, damage = 300 })
    mod:OnTakeDamage({ attacker = zeus, unit = creep, damage = 200 })

    -- Creep: 1000 * 0.08 = 80 magical dmg
    -- Boss: 30000 * 0.08 = 2400 -> capped at 500
    assert(#applied_damages == 2)
    assert(applied_damages[1].victim == creep and applied_damages[1].damage == 80)
    assert(applied_damages[2].victim == boss and applied_damages[2].damage == 500)
    zeus.PassivesDisabled = function() return true end
    mod:OnTakeDamage({ attacker = zeus, unit = creep, inflictor = source_spell, damage = 200 })
    assert(#applied_damages == 2, 'Static Field must stop triggering under Break')
end)

test('Zeus Lightning Bolt respects spell block and rejects allied targets', function()
    applied_damages = {}
    local zeus = create_mock_unit('npc_dota_hero_zuus', 2, Vector(0, 0, 0))
    local target = create_mock_unit('zeus_bolt_target', 3, Vector(100, 0, 0))
    local ab = enfos_zeus_lightning_bolt()
    ab.GetCaster = function() return zeus end
    ab.GetCursorTarget = function() return target end
    ab.GetSpecialValueFor = function(_, key) return key == 'damage' and 150 or 0 end
    target.TriggerSpellAbsorb = function() return true end
    ab:OnSpellStart()
    assert(#applied_damages == 0, 'spell block must absorb Lightning Bolt')
    target.TriggerSpellAbsorb = function() return false end
    target.team = 2
    ab:OnSpellStart()
    assert(#applied_damages == 0, 'Lightning Bolt must reject allied targets')
end)

test('Zeus Heavenly Jump leaps while stationary and emits native launch/landing effects', function()
    applied_damages = {}
    local zeus = create_mock_unit('npc_dota_hero_zuus', 2, Vector(0, 0, 0))
    zeus.forward = Vector(1, 0, 0)
    zeus.IsMoving = function() return false end
    zeus.intellect = 50
    local creep = create_mock_unit('creep_zeus_jump', 3, Vector(500, 0, 0), 1000)
    mock_world_units = { zeus, creep }

    local previous_manager = ParticleManager
    local emitted = {}
    ParticleManager = {
        CreateParticle = function(_, path) emitted[#emitted + 1] = path return #emitted end,
        ReleaseParticleIndex = function() end
    }

    local ab = enfos_zeus_heavenly_jump()
    ab.GetCaster = function() return zeus end
    ab.GetSpecialValueFor = function(_, k)
        return ({ damage = 150, bonus_ms_pct = 20, buff_duration = 3, slow_pct = 40, slow_duration = 2, max_targets = 2 })[k] or 0
    end
    ab:OnSpellStart()
    ParticleManager = previous_manager
    assert(zeus.origin.x == 450, 'Heavenly Jump must move 450 units forward')
    assert(emitted[1] == 'particles/units/heroes/hero_zuus/zuus_shard_jump_launch_ring.vpcf', 'Heavenly Jump must create its native launch effect')
    assert(emitted[2] == 'particles/units/heroes/hero_zuus/zuus_shard_jump_landing_ring.vpcf', 'Heavenly Jump must create its native landing effect')
    assert(#applied_damages == 1 and applied_damages[1].victim == creep and applied_damages[1].damage == 190)
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
          if k == 'stun_duration' then return 1.0 end
          if k == 'boss_stun_duration' then return 0.3 end
        return 0
    end

    ab:OnSpellStart()

    -- Damage per bounce: 100 + (50 * 0.4) = 120
    assert(#applied_damages == 2, 'Cask must hit each nearby unit no more than once')
    assert(applied_damages[1].damage == 120 and applied_damages[1].damage_type == DAMAGE_TYPE_MAGICAL)
    local boss_stun = boss:FindModifierByName('modifier_enfos_wd_paralyzing_cask_stun')
    assert(boss_stun ~= nil and boss_stun.params.duration == 0.3, 'Boss stun duration must be reduced to 0.3s')
    local creep_stun = creep:FindModifierByName('modifier_enfos_wd_paralyzing_cask_stun')
    assert(creep_stun ~= nil and creep_stun.params.duration == 1.0, 'Creep stun duration must be 1.0s')
end)

test('Witch Doctor Maledict uses rank values and only bursts damage since the prior burst', function()
    applied_damages = {}
    local wd = create_mock_unit('npc_dota_hero_witch_doctor', 2, Vector(0, 0, 0))
    local target = create_mock_unit('creep_wd_maledict', 3, Vector(100, 0, 0), 1000)
    local ability = enfos_wd_maledict()
    ability.GetCaster = function() return wd end
    ability.GetSpecialValueFor = function(_, key)
        if key == 'base_dps' then return 10 end
        if key == 'burst_interval' then return 2 end
        if key == 'lost_health_pct' then return 20 end
        if key == 'duration' then return 12 end
        return 0
    end
    local modifier = modifier_enfos_wd_maledict_debuff()
    modifier.GetParent = function() return target end
    modifier.GetAbility = function() return ability end
    modifier.StartIntervalThink = function() end
    modifier:OnCreated()
    target.hp = 900
    modifier:OnIntervalThink()
    assert(#applied_damages == 1, 'No burst should happen before configured interval')
    target.hp = 800
    modifier:OnIntervalThink()
    assert(#applied_damages == 3, 'Second tick should deal DPS plus a burst')
    assert(applied_damages[3].damage == 40, 'Burst uses configured 20% of the latest 200 HP loss')
    target.hp = 700
    modifier:OnIntervalThink()
    target.hp = 600
    modifier:OnIntervalThink()
    assert(applied_damages[6].damage == 40, 'Later burst must not re-count damage from the first window')
end)

test('Witch Doctor Death Ward creates the native ward and removes it when channel ends', function()
    local wd = create_mock_unit('npc_dota_hero_witch_doctor', 2, Vector(0, 0, 0))
    local ward = create_mock_unit('npc_dota_witch_doctor_death_ward', 2, Vector(300, 200, 0))
    mock_world_units = { wd, ward }
    local original_create_unit = CreateUnitByName
    CreateUnitByName = function(name, position, clear_space, owner, entity_owner, team)
        assert(name == 'npc_dota_witch_doctor_death_ward', 'Death Ward must use the native unit definition')
        assert(position.x == 300 and position.y == 200 and team == 2)
        return ward
    end

    local ability = enfos_wd_death_ward()
    ability.GetCaster = function() return wd end
    ability.GetCursorPosition = function() return Vector(300, 200, 0) end
    ability.GetSpecialValueFor = function(_, key) return key == 'channel_duration' and 8 or 0 end
    ability:OnSpellStart()
    assert(ward:HasModifier('modifier_enfos_wd_death_ward_visual'), 'Ward must receive its visual/immobile modifier')
    local channel = wd:FindModifierByName('modifier_enfos_wd_death_ward_channel')
    channel.StartIntervalThink = function() end
    channel:OnCreated(channel.params)
    assert(channel and channel.ward_idx == ward:entindex(), 'Channel must own the spawned ward handle')
    channel:OnDestroy()
    assert(ward.removed, 'Ward must be removed when the channel ends')
    CreateUnitByName = original_create_unit
end)

test('Witch Doctor Death Ward targeting includes spell-immune enemies', function()
    applied_damages = {}
    local wd = create_mock_unit('npc_dota_hero_witch_doctor', 2, Vector(0, 0, 0))
    local target = create_mock_unit('spell_immune_creep_wd', 3, Vector(100, 0, 0), 1000)
    local ward = create_mock_unit('npc_dota_witch_doctor_death_ward', 2, Vector(20, 0, 0))
    mock_world_units = { wd, target, ward }
    local ability = enfos_wd_death_ward()
    ability.GetCaster = function() return wd end
    ability.GetSpecialValueFor = function(_, key) return ({ damage = 240, projectile_speed = 1000 })[key] or 0 end
    local channel = modifier_enfos_wd_death_ward_channel()
    channel.GetCaster = function() return wd end
    channel.GetAbility = function() return ability end
    channel.pos = Vector(0, 0, 0)
    channel.ward_idx = ward:entindex()
    local originalProjectile = ProjectileManager.CreateTrackingProjectile
    local projectile
    ProjectileManager.CreateTrackingProjectile = function(_, options) projectile = options; return 1 end
    channel:OnIntervalThink()
    assert(last_find_units_flags == DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        'Death Ward declares spell-immunity piercing and must include those enemies in its search')
    assert(projectile and projectile.Source == ward and projectile.Target == target and projectile.iMoveSpeed == 1000)
    assert(#applied_damages == 0, 'Ward attack damage must wait for the visible projectile impact')
    ability:OnProjectileHit_ExtraData(nil, nil, projectile.ExtraData)
    assert(#applied_damages == 0, 'Lost target must not take damage')
    ability:OnProjectileHit_ExtraData(wd, nil, projectile.ExtraData)
    assert(#applied_damages == 0, 'Impact must reject allied targets')
    ability:OnProjectileHit_ExtraData(target, nil, projectile.ExtraData)
    assert(#applied_damages == 1 and applied_damages[1].victim == target)
    assert(applied_damages[1].damage == 277.5, 'Ranked damage and Intelligence scaling must be preserved')
    target.alive = false
    ability:OnProjectileHit_ExtraData(target, nil, projectile.ExtraData)
    assert(#applied_damages == 1, 'A dead target must not receive a second hit')
    ProjectileManager.CreateTrackingProjectile = originalProjectile
end)

test('Witch Doctor Gris-Gris does not pay while broken or to an illusion', function()
    local previous_player_resource = PlayerResource
    local paid = 0
    PlayerResource = {
        IsValidPlayerID = function(_, id) return id == 0 end,
        ModifyGold = function(_, id, amount) paid = paid + amount end,
    }
    local hero = create_mock_unit('npc_dota_hero_witch_doctor', 2, Vector(0, 0, 0))
    hero.GetPlayerOwnerID = function() return 0 end
    hero.PassivesDisabled = function() return false end
    hero.IsIllusion = function() return false end
    local ability = enfos_wd_gris_gris()
    ability.GetSpecialValueFor = function(_, key) return key == 'gold_per_interval' and 3 or 0 end
    local passive = modifier_enfos_wd_gris_gris()
    passive.GetParent = function() return hero end
    passive.GetAbility = function() return ability end
    passive:OnIntervalThink()
    assert(paid == 3, 'a real, unbroken hero should receive the configured gold')
    hero.PassivesDisabled = function() return true end
    passive:OnIntervalThink()
    hero.PassivesDisabled = function() return false end
    hero.IsIllusion = function() return true end
    passive:OnIntervalThink()
    assert(paid == 3, 'Break and illusions must not generate passive gold')
    PlayerResource = previous_player_resource
end)

test('Witch Doctor Aghanim Shard grants and removes Switcheroo exactly once', function()
    local AghanimManager = require('heroes/aghanim_manager')
    local hero = {
        name = 'npc_dota_hero_witch_doctor', abilities = {}, modifiers = {},
        GetUnitName = function(self) return self.name end,
        FindAbilityByName = function(self, name) return self.abilities[name] end,
        AddAbility = function(self, name)
            local ability = { level = 0, hidden = true, activated = false,
                SetLevel = function(self, level) self.level = level end,
                SetHidden = function(self, hidden) self.hidden = hidden end,
                SetActivated = function(self, active) self.activated = active end }
            self.abilities[name] = ability
            return ability
        end,
        RemoveAbility = function(self, name) self.abilities[name] = nil end,
        AddNewModifier = function(self, _, _, name) self.modifiers[name] = true end,
        RemoveModifierByName = function(self, name) self.modifiers[name] = nil end,
    }
    AghanimManager:OnShardAcquired(hero, 'Support')
    local ability = hero.abilities.enfos_wd_voodoo_switcheroo
    assert(ability and ability.level == 1 and not ability.hidden and ability.activated)
    AghanimManager:OnShardAcquired(hero, 'Support')
    assert(hero.abilities.enfos_wd_voodoo_switcheroo == ability, 'Repeated acquisition must not duplicate the ability')
    AghanimManager:OnShardLost(hero)
    assert(hero.abilities.enfos_wd_voodoo_switcheroo == nil, 'Losing Shard must remove its active ability')
end)

test('Dragon Knight Breathe Fire deals magic damage and reduces enemy attack damage', function()
    applied_damages = {}
    local dk = create_mock_unit('npc_dota_hero_dragon_knight', 2, Vector(0, 0, 0))
    dk.strength = 80
    local dummy = create_mock_unit('creep_dk', 3, Vector(200, 0, 0))
    local off_axis = create_mock_unit('creep_dk_off_axis', 3, Vector(200, 400, 0))
    mock_world_units = { dk, dummy, off_axis }

    local ab = enfos_dk_breathe_fire()
    ab.GetCaster = function() return dk end
    ab.GetCursorPosition = function() return Vector(300, 0, 0) end
    ab.GetSpecialValueFor = function(_, k)
        if k == 'damage' then return 240 end
        if k == 'reduction_pct' then return 40 end
        if k == 'duration' then return 7 end
        if k == 'range' then return 750 end
        if k == 'width' then return 225 end
        return 0
    end

    ab:OnSpellStart()
    -- dmg = 240 + (80 * 1.2 = 96) = 336
    assert(#applied_damages == 1)
    assert(applied_damages[1].damage == 336 and applied_damages[1].damage_type == DAMAGE_TYPE_MAGICAL)
    local debuff = dummy:FindModifierByName('modifier_enfos_dk_breathe_fire_debuff')
    assert(debuff ~= nil and debuff.params.duration == 7)
    assert(off_axis:FindModifierByName('modifier_enfos_dk_breathe_fire_debuff') == nil, 'Breathe Fire must respect its line width')
end)

test('Dragon Knight Dragon Tail rejects spell block and reads the boss stun cap from KV', function()
    applied_damages = {}
    local dk = create_mock_unit('npc_dota_hero_dragon_knight', 2, Vector(0, 0, 0))
    local boss = create_mock_unit('enfos_boss_dragon', 3, Vector(100, 0, 0), 10000)
    mock_world_units = { dk, boss }
    local ability = enfos_dk_dragon_tail()
    ability.GetCaster = function() return dk end
    ability.GetCursorTarget = function() return boss end
    ability.GetSpecialValueFor = function(_, key)
        if key == 'damage' then return 400 end
        if key == 'stun_duration' then return 3 end
        if key == 'boss_stun_duration' then return 0.8 end
        return 0
    end
    ability:OnSpellStart()
    local stun = boss:FindModifierByName('modifier_enfos_dk_dragon_tail_stun')
    assert(stun and stun.params.duration == 0.8, 'Boss stun cap must come from KV')
    assert(#applied_damages == 1 and applied_damages[1].damage == 450)
    boss.TriggerSpellAbsorb = function() return true end
    ability:OnSpellStart()
    assert(#applied_damages == 1, 'Spell block must prevent Dragon Tail damage')
end)

test('Dragon Knight passives respect Break and read ten-rank ability values', function()
    local dk = create_mock_unit('npc_dota_hero_dragon_knight', 2, Vector(0, 0, 0))
    local ability = { GetSpecialValueFor = function(_, key) return key == 'bonus_armor' and 20 or key == 'bonus_hp_regen' and 30 or 20 end }
    local blood = modifier_enfos_dk_dragon_blood_passive()
    blood.GetParent = function() return dk end
    blood.GetAbility = function() return ability end
    assert(blood:GetModifierPhysicalArmorBonus() == 20)
    assert(blood:GetModifierConstantHealthRegen() == 32.5)
    dk.PassivesDisabled = function() return true end
    assert(blood:GetModifierPhysicalArmorBonus() == 0 and blood:GetModifierConstantHealthRegen() == 0)
    local vigor = modifier_enfos_dk_wyrm_vigor_passive()
    vigor.GetParent = function() return dk end
    vigor.GetAbility = function() return ability end
    assert(vigor:GetModifierMagicalResistanceBonus() == 0 and vigor:GetModifierBonusStats_Strength() == 0)
    dk.PassivesDisabled = function() return false end
    dk.IsIllusion = function() return true end
    assert(blood:GetModifierPhysicalArmorBonus() == 0 and blood:GetModifierConstantHealthRegen() == 0
        and vigor:GetModifierMagicalResistanceBonus() == 0 and vigor:GetModifierBonusStats_Strength() == 0,
        'Dragon Blood and Wyrm Vigor passive stats must not duplicate on illusions')
end)

test('Dragon Knight Elder Dragon Form swaps to the verified dragon model and restores the hero model', function()
    local dk = create_mock_unit('npc_dota_hero_dragon_knight', 2, Vector(0, 0, 0))
    dk.model = 'models/heroes/dragon_knight/dragon_knight.vmdl'
    dk.GetModelName = function(self) return self.model end
    dk.SetModel = function(self, model) self.model = model end
    dk.SetOriginalModel = function(self, model) self.original_model = model end
    dk.SetAttackCapability = function() end
    local modifier = modifier_enfos_dk_elder_dragon_form_buff()
    modifier.GetParent = function() return dk end
    modifier:OnCreated()
    assert(dk.model == 'models/heroes/dragon_knight/dragon_knight_dragon.vmdl')
    modifier:OnDestroy()
    assert(dk.model == 'models/heroes/dragon_knight/dragon_knight.vmdl', 'Form expiry restores the original model')
end)

test('Pudge Meat Hook launches a real linear hook and pulls the first target on impact', function()
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
        if k == 'hook_range' then return 1400 end
        if k == 'hook_width' then return 100 end
        if k == 'hook_speed' then return 1600 end
        return 0
    end

    ab:OnSpellStart()
    assert(last_linear_projectile and last_linear_projectile.EffectName == 'particles/units/heroes/hero_pudge/pudge_meathook.vpcf', 'Hook must travel visibly as a linear projectile')
    assert(#applied_damages == 0, 'Hook must not deal its impact damage at cast time')
    ab:OnProjectileHit(target, target:GetAbsOrigin())
    -- dmg = 350 + (100 * 1.8 = 180) = 530 Pure
    assert(#applied_damages == 1)
    assert(applied_damages[1].damage == 530 and applied_damages[1].damage_type == DAMAGE_TYPE_PURE)
    assert(target:GetAbsOrigin().x == 120, 'Normal targets are pulled toward Pudge after impact')
end)

test('Pudge Dismember rejects spell block, applies a capped boss stun and cleans up its tether', function()
    local pudge = create_mock_unit('npc_dota_hero_pudge', 2, Vector(0, 0, 0))
    local boss = create_mock_unit('enfos_boss_pudge', 3, Vector(100, 0, 0), 10000)
    mock_world_units = { pudge, boss }
    local ability = enfos_pudge_dismember()
    ability.GetCaster = function() return pudge end
    ability.GetCursorTarget = function() return boss end
    ability.GetSpecialValueFor = function(_, key)
        if key == 'channel_duration' then return 3 end
        if key == 'boss_control_duration' then return 1.5 end
        return 0
    end
    ability:OnSpellStart()
    local target_mod = boss:FindModifierByName('modifier_enfos_pudge_dismember_target')
    assert(target_mod and target_mod.params.duration == 1.5)
    target_mod:OnCreated()
    assert(target_mod.pfx ~= nil, 'Dismember tether visual is owned by the target modifier')
    boss.RemoveModifierByNameAndCaster = function(self, name)
        local mod = self.modifiers[name]
        if mod then if mod.OnDestroy then mod:OnDestroy() end; self.modifiers[name] = nil end
    end
    pudge.RemoveModifierByName = function(self, name)
        local mod = self.modifiers[name]
        if mod then if mod.OnDestroy then mod:OnDestroy() end; self.modifiers[name] = nil end
    end
    local channel = pudge:FindModifierByName('modifier_enfos_pudge_dismember_channel')
    channel.StartIntervalThink = function() end
    channel:OnCreated({ target_idx = boss:entindex() })
    ability:OnChannelFinish(true)
    assert(boss:FindModifierByName('modifier_enfos_pudge_dismember_target') == nil, 'Interrupted channel removes stun/tether')
    boss.TriggerSpellAbsorb = function() return true end
    ability:OnSpellStart()
    assert(boss:FindModifierByName('modifier_enfos_pudge_dismember_target') == nil, 'Spell block prevents Dismember')
end)

test('Pudge Dismember ends the real channel when its target or caster dies', function()
    local pudge = create_mock_unit('npc_dota_hero_pudge', 2, Vector(0, 0, 0))
    local target = create_mock_unit('dismember_target', 3, Vector(100, 0, 0))
    mock_world_units = { pudge, target }
    local ended = 0
    local ability = { EndChannel = function(_, interrupted) if interrupted then ended = ended + 1 end end }
    local channel = setmetatable({
        target_idx = target:entindex(),
        GetParent = function() return pudge end,
        GetAbility = function() return ability end,
        Destroy = function(self) self.destroyed = true end,
    }, modifier_enfos_pudge_dismember_channel)
    target.alive = false
    channel:OnIntervalThink()
    assert(ended == 1, 'a dead target should interrupt the engine channel')

    target.alive = true
    pudge.alive = false
    channel:OnIntervalThink()
    assert(ended == 2, 'a dead caster should interrupt the engine channel')
end)

test('Pudge Rot spends configured mana and applies rank-scaled damage inside its KV radius', function()
    applied_damages = {}
    local pudge = create_mock_unit('npc_dota_hero_pudge', 2, Vector(0, 0, 0), 1000)
    pudge.strength = 100
    local near = create_mock_unit('creep_near_rot', 3, Vector(100, 0, 0), 500)
    local far = create_mock_unit('creep_far_rot', 3, Vector(500, 0, 0), 500)
    mock_world_units = { pudge, near, far }
    local ability = enfos_pudge_rot()
    ability.GetCaster = function() return pudge end
    ability.GetSpecialValueFor = function(_, key)
        return ({ rot_damage=100, rot_radius=350, tick_interval=0.5, mana_per_second=8, self_damage_pct=50, debuff_duration=0.6, slow_pct=30 })[key] or 0
    end
    local modifier = modifier_enfos_pudge_rot_aura()
    modifier.GetParent = function() return pudge end
    modifier.GetAbility = function() return ability end
    modifier:OnIntervalThink()
    assert(pudge.mana == 496, 'Half-second interval spends half the configured mana per second')
    assert(pudge.hp == 965, 'Self-cost uses the configured percentage of the aura tick')
    assert(#applied_damages == 1 and applied_damages[1].victim == near and applied_damages[1].damage == 70)
    assert(near:FindModifierByName('modifier_enfos_pudge_rot_debuff').params.duration == 0.6)
end)

test('Pudge Flesh Heap kill stacks honor Break and the configured cap', function()
    local pudge = create_mock_unit('npc_dota_hero_pudge', 2, Vector(0, 0, 0))
    local creep = create_mock_unit('creep_flesh_heap', 3, Vector(100, 0, 0))
    local boss = create_mock_unit('enfos_boss_flesh_heap', 3, Vector(150, 0, 0))
    local ability = enfos_pudge_flesh_heap()
    ability.GetSpecialValueFor = function(_, key) return ({ normal_kill_stacks=1, boss_kill_stacks=5, max_stacks=6, strength_per_stack=0.5, bonus_strength=20 })[key] or 0 end
    local modifier = modifier_enfos_pudge_flesh_heap_passive()
    modifier.GetParent = function() return pudge end
    modifier.GetAbility = function() return ability end
    modifier.GetStackCount = function(self) return self.stacks or 0 end
    modifier.SetStackCount = function(self, stacks) self.stacks = stacks end
    modifier:OnDeath({ attacker=pudge, unit=creep })
    modifier:OnDeath({ attacker=pudge, unit=boss })
    assert(modifier:GetStackCount() == 6 and modifier:GetModifierBonusStats_Strength() == 23)
    modifier:OnDeath({ attacker=pudge, unit=boss })
    assert(modifier:GetStackCount() == 6, 'Permanent Strength stack total is capped by KV')
    pudge.PassivesDisabled = function() return true end
    modifier:OnDeath({ attacker=pudge, unit=creep })
    assert(modifier:GetStackCount() == 6 and modifier:GetModifierPhysical_ConstantBlock() == 0)
    pudge.PassivesDisabled = function() return false end
    pudge.IsIllusion = function() return true end
    modifier:OnDeath({ attacker=pudge, unit=creep })
    assert(modifier:GetStackCount() == 6 and modifier:GetModifierBonusStats_Strength() == 0,
        'Flesh Heap must not accumulate kill stacks or strength on illusions')
end)

test('Pudge Meat Shield accumulates damage to a KV threshold, caps bursts and honors Break', function()
    applied_damages = {}
    local pudge = create_mock_unit('npc_dota_hero_pudge', 2, Vector(0, 0, 0), 1000)
    local near = create_mock_unit('creep_meat_shield_near', 3, Vector(100, 0, 0), 1000)
    local far = create_mock_unit('creep_meat_shield_far', 3, Vector(500, 0, 0), 1000)
    mock_world_units = { pudge, near, far }
    local ability = enfos_pudge_meat_shield()
    ability.GetSpecialValueFor = function(_, key)
        return ({ damage_threshold = 500, burst_hp_pct = 10, burst_radius = 400,
            magic_resist = 20, bonus_hp = 300 })[key] or 0
    end
    local modifier = modifier_enfos_pudge_meat_shield_passive()
    modifier.GetParent = function() return pudge end
    modifier.GetAbility = function() return ability end
    modifier:OnTakeDamage({ unit = pudge, damage = 250 })
    assert(#applied_damages == 0, 'Sub-threshold damage must stay banked')
    modifier:OnTakeDamage({ unit = pudge, damage = 250 })
    assert(#applied_damages == 1 and applied_damages[1].damage == 100,
        'Crossing the configured threshold must burst for configured max-health percent')
    assert(applied_damages[1].victim == near and applied_damages[1].damage_type == DAMAGE_TYPE_PHYSICAL,
        'Meat Shield must hit only enemies within its radius with physical damage')
    assert(last_find_units_flags == DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        'Physical Meat Shield bursts must include magic-immune enemies')
    applied_damages = {}
    modifier:OnTakeDamage({ unit = pudge, damage = 2000 })
    assert(#applied_damages == 1 and applied_damages[1].damage == 300,
        'One damage event must produce no more than three bursts')
    pudge.PassivesDisabled = function() return true end
    local banked = modifier.accumulated
    modifier:OnTakeDamage({ unit = pudge, damage = 500 })
    assert(modifier.accumulated == banked and #applied_damages == 1,
        'Break must suppress Meat Shield accumulation and burst damage')
    assert(modifier:GetModifierMagicalResistanceBonus() == 0 and modifier:GetModifierHealthBonus() == 0,
        'Break must suppress Meat Shield defensive bonuses')
    pudge.PassivesDisabled = function() return false end
    pudge.IsIllusion = function() return true end
    local banked = modifier.accumulated
    modifier:OnTakeDamage({ unit = pudge, damage = 500 })
    assert(modifier.accumulated == banked and #applied_damages == 1
        and modifier:GetModifierMagicalResistanceBonus() == 0 and modifier:GetModifierHealthBonus() == 0,
        'Illusions must not gain Meat Shield bonuses or trigger damage bursts')
end)

test('Slark Essence Shift stacks Agility on attack landed', function()
    local slark = create_mock_unit('npc_dota_hero_slark', 2, Vector(0, 0, 0))
    local creep = create_mock_unit('creep_slark', 3, Vector(100, 0, 0))
    mock_world_units = { slark, creep }

    local ab = enfos_slark_essence_shift()
    ab.GetSpecialValueFor = function(_, key)
        return ({ bonus_agi=3, duration=30, max_stacks=50 })[key] or 0
    end
    local mod = modifier_enfos_slark_essence_shift_passive()
    mod.GetParent = function() return slark end
    mod.GetAbility = function() return ab end

    mod:OnAttackLanded({ attacker = slark, target = creep })
    mod:OnAttackLanded({ attacker = slark, target = creep })

    local buff = slark:FindModifierByName('modifier_enfos_slark_essence_shift_buff')
    assert(buff ~= nil)
    assert(buff:GetStackCount() == 2)
    assert(buff:GetModifierBonusStats_Agility() == 6)
    slark.PassivesDisabled = function() return true end
    assert(buff:GetModifierBonusStats_Agility() == 0, 'Break must suppress existing Essence Shift stacks')
    slark.PassivesDisabled = function() return false end
    slark.IsIllusion = function() return true end
    mod:OnAttackLanded({ attacker = slark, target = creep })
    assert(buff:GetStackCount() == 2 and buff:GetModifierBonusStats_Agility() == 0,
        'Essence Shift must not trigger or grant its bonus to illusions')
end)

test('Slark Dark Pact pulses its configured total damage in the configured radius', function()
    applied_damages = {}
    local slark = create_mock_unit('npc_dota_hero_slark', 2, Vector(0, 0, 0))
    slark.agility = 20
    local near = create_mock_unit('creep_dark_pact_near', 3, Vector(100, 0, 0), 1000)
    local far = create_mock_unit('creep_dark_pact_far', 3, Vector(500, 0, 0), 1000)
    mock_world_units = { slark, near, far }
    local ability = enfos_slark_dark_pact()
    ability.GetCaster = function() return slark end
    ability.GetSpecialValueFor = function(_, key)
        return ({ damage=100, radius=200, tick_interval=0.1, pulse_count=10, agility_factor=1 })[key] or 0
    end
    ability:OnSpellStart()
    local modifier = slark:FindModifierByName('modifier_enfos_slark_dark_pact_buff')
    modifier.GetParent = function() return slark end
    modifier.GetAbility = function() return ability end
    modifier.StartIntervalThink = function() end
    modifier.Destroy = function(self) self.finished = true end
    modifier:OnCreated()
    for _ = 1, 10 do modifier:OnIntervalThink() end
    assert(modifier.finished and #applied_damages == 10)
    assert(applied_damages[1].damage == 12, 'Each of 10 pulses applies one tenth of configured total')
    assert(far.hp == 1000, 'Dark Pact must respect the configured radius')
end)

test('Slark Pounce performs a visible timed dash and applies a true capped leash on impact', function()
    applied_damages = {}
    local slark = create_mock_unit('npc_dota_hero_slark', 2, Vector(0, 0, 0))
    slark.agility = 50
    local creep = create_mock_unit('creep_pounce', 3, Vector(700, 0, 0), 1000)
    mock_world_units = { slark, creep }
    local ability = enfos_slark_pounce()
    ability.GetCaster = function() return slark end
    ability.GetSpecialValueFor = function(_, key)
        return ({ pounce_distance=700, dash_speed=1400, impact_radius=250, damage=200, agility_factor=0.8,
            leash_duration=3, boss_leash_duration=1 })[key] or 0
    end
    ability:OnSpellStart()
    assert(slark:GetAbsOrigin().x == 0, 'Pounce must travel over time rather than teleport on cast')
    local dash = slark:FindModifierByName('modifier_enfos_slark_pounce_dash')
    dash.GetParent = function() return slark end
    dash.GetAbility = function() return ability end
    dash.StartIntervalThink = function() end
    dash.Destroy = function(self) self.completed = true; self:OnDestroy() end
    dash:OnCreated(dash.params)
    while not dash.completed do dash:OnIntervalThink() end
    assert(slark:GetAbsOrigin().x == 700 and #applied_damages == 1)
    assert(applied_damages[1].damage == 240 and applied_damages[1].damage_type == DAMAGE_TYPE_PHYSICAL)
    local leash = creep:FindModifierByName('modifier_enfos_slark_pounce_leash')
    assert(leash and leash.params.duration == 3 and leash:CheckState()[MODIFIER_STATE_TETHERED])
end)

test('Slark Shadow Dance applies ranked states and releases its persistent particle', function()
    local previous_create = ParticleManager.CreateParticle
    local previous_destroy = ParticleManager.DestroyParticle
    local previous_release = ParticleManager.ReleaseParticleIndex
    local destroyed, released
    ParticleManager.CreateParticle = function(_, path, attach, parent)
        assert(path == 'particles/units/heroes/hero_slark/slark_shadow_dance.vpcf' and parent ~= nil)
        return 91
    end
    ParticleManager.DestroyParticle = function(_, index) if index == 91 then destroyed = true end end
    ParticleManager.ReleaseParticleIndex = function(_, index) if index == 91 then released = true end end

    local slark = create_mock_unit('npc_dota_hero_slark', 2, Vector(0, 0, 0))
    local ability = enfos_slark_shadow_dance()
    ability.GetCaster = function() return slark end
    ability.GetSpecialValueFor = function(_, key)
        return ({ duration = 7.2, bonus_ms = 87, health_regen_pct = 15 })[key] or 0
    end
    ability:OnSpellStart()
    local buff = slark:FindModifierByName('modifier_enfos_slark_shadow_dance_buff')
    assert(buff and buff.params.duration == 7.2)
    buff:OnCreated()
    local states = buff:CheckState()
    assert(states[MODIFIER_STATE_INVISIBLE] and states[MODIFIER_STATE_TRUESIGHT_IMMUNE])
    assert(buff:GetModifierMoveSpeedBonus_Percentage() == 87 and buff:GetModifierHealthRegenPercentage() == 15)
    assert(buff.pfx == 91)
    buff:OnDestroy()
    assert(destroyed and released and buff.pfx == nil, 'Modifier expiry must release the persistent particle')

    ParticleManager.CreateParticle = previous_create
    ParticleManager.DestroyParticle = previous_destroy
    ParticleManager.ReleaseParticleIndex = previous_release
end)

test('Slark Fish Bait uses its rank values for cleave and stacked armor reduction', function()
    applied_damages = {}
    local slark = create_mock_unit('npc_dota_hero_slark', 2, Vector(0, 0, 0))
    local target = create_mock_unit('creep_fish_bait_target', 3, Vector(100, 0, 0))
    local neighbor = create_mock_unit('creep_fish_bait_neighbor', 3, Vector(150, 0, 0))
    mock_world_units = { slark, target, neighbor }
    local ability = enfos_slark_fish_bait()
    ability.GetSpecialValueFor = function(_, key)
        return ({ proc_chance=25, cleave_pct=40, cleave_radius=250, armor_reduction=3, max_armor_stacks=5, debuff_duration=4 })[key] or 0
    end
    local modifier = modifier_enfos_slark_fish_bait_passive()
    modifier.GetParent = function() return slark end
    modifier.GetAbility = function() return ability end
    modifier:OnAttackLanded({ attacker=slark, target=target, damage=100 })
    local debuff = target:FindModifierByName('modifier_enfos_slark_fish_bait_debuff')
    assert(debuff and debuff:GetModifierPhysicalArmorBonus() == -3)
    assert(#applied_damages == 1 and applied_damages[1].victim == neighbor and applied_damages[1].damage == 40)
    assert(last_find_units_flags == DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        'Physical Fish Bait cleave must include magic-immune enemies')
    slark.IsIllusion = function() return true end
    modifier:OnAttackLanded({ attacker=slark, target=target, damage=100 })
    assert(#applied_damages == 1 and target:FindModifierByName('modifier_enfos_slark_fish_bait_debuff'):GetStackCount() == 1,
        'Fish Bait must not proc from illusions')
end)

test('Troll Berserker Rage toggles melee stance and uses configured enemy proc values', function()
    applied_damages = {}
    DOTA_UNIT_CAP_MELEE_ATTACK, DOTA_UNIT_CAP_RANGED_ATTACK = 1, 2
    local troll = create_mock_unit('npc_dota_hero_troll_warlord', 2, Vector(0, 0, 0))
    local enemy = create_mock_unit('enfos_boss_troll', 3, Vector(100, 0, 0), 10000)
    troll.SetAttackCapability = function(self, cap) self.attack_capability = cap end
    local ability = enfos_troll_berserkers_rage()
    ability.GetCaster = function() return troll end
    ability.GetToggleState = function() return true end
    ability.GetSpecialValueFor = function(_, key)
        return ({ bonus_armor=9, bonus_ms=38, attack_range_penalty=350, stun_chance_pct=20, stun_duration=0.5, boss_stun_duration=0.3, bonus_damage=100, agility_factor=0.8 })[key] or 0
    end
    ability:OnToggle()
    local rage = troll:FindModifierByName('modifier_enfos_troll_berserkers_rage')
    rage:OnCreated()
    assert(troll.attack_capability == DOTA_UNIT_CAP_MELEE_ATTACK and rage:RemoveOnDeath() == false)
    assert(rage:GetModifierPhysicalArmorBonus() == 9 and rage:GetModifierMoveSpeedBonus_Constant() == 38)
    assert(rage:GetModifierAttackRangeBonus() == -350)
    rage:OnAttackLanded({ attacker=troll, target=enemy })
    assert(#applied_damages == 1 and applied_damages[1].damage == 140)
    assert(enemy:FindModifierByName('modifier_enfos_troll_berserkers_rage_stun').params.duration == 0.3)
end)

test('Troll Whirling Axes uses rank damage, blind and boss duration values', function()
    applied_damages = {}
    local troll = create_mock_unit('npc_dota_hero_troll_warlord', 2, Vector(0, 0, 0))
    local creep = create_mock_unit('creep_troll', 3, Vector(100, 0, 0))
    local boss = create_mock_unit('enfos_boss_troll', 3, Vector(200, 0, 0), 12000)
    local outside = create_mock_unit('creep_troll_outside', 3, Vector(700, 0, 0))
    mock_world_units = { troll, creep, boss, outside }
    local ability = enfos_troll_whirling_axes()
    ability.GetCaster = function() return troll end
    ability.GetSpecialValueFor = function(_, key)
        return ({ radius=500, damage=240, duration=4, boss_duration=1.5, blind_pct=48, agility_factor=0.8 })[key] or 0
    end
    ability:OnSpellStart()
    assert(#applied_damages == 2 and applied_damages[1].damage == 280)
    assert(applied_damages[1].damage_type == DAMAGE_TYPE_MAGICAL)
    assert(creep:FindModifierByName('modifier_enfos_troll_whirling_axes_blind').params.duration == 4)
    assert(boss:FindModifierByName('modifier_enfos_troll_whirling_axes_blind').params.duration == 1.5)
end)

test('Troll Fervor stacks on the same enemy, resets on retarget and respects Break', function()
    local troll = create_mock_unit('npc_dota_hero_troll_warlord', 2, Vector(0, 0, 0))
    local first = create_mock_unit('creep_troll_a', 3, Vector(100, 0, 0))
    local second = create_mock_unit('creep_troll_b', 3, Vector(150, 0, 0))
    local ally = create_mock_unit('ally_troll', 2, Vector(50, 0, 0))
    local ability = enfos_troll_fervor()
    ability.GetSpecialValueFor = function(_, key) return ({ max_stacks=10, attack_speed_per_stack=12 })[key] or 0 end
    local mod = modifier_enfos_troll_fervor()
    mod.GetParent = function() return troll end
    mod.GetAbility = function() return ability end
    mod.GetStackCount = function(self) return self.stacks or 0 end
    mod.SetStackCount = function(self, count) self.stacks = count end
    mod:OnAttackLanded({ attacker=troll, target=ally })
    mod:OnAttackLanded({ attacker=troll, target=first })
    mod:OnAttackLanded({ attacker=troll, target=first })
    assert(mod:GetStackCount() == 2 and mod:GetModifierAttackSpeedBonus_Constant() == 24)
    mod:OnAttackLanded({ attacker=troll, target=second })
    assert(mod:GetStackCount() == 1 and mod:GetModifierAttackSpeedBonus_Constant() == 12)
    troll.PassivesDisabled = function() return true end
    mod:OnAttackLanded({ attacker=troll, target=second })
    assert(mod:GetStackCount() == 1 and mod:GetModifierAttackSpeedBonus_Constant() == 0,
        'Break must suppress the attack-speed bonus from existing Fervor stacks')
    troll.PassivesDisabled = function() return false end
    assert(mod:GetModifierAttackSpeedBonus_Constant() == 12,
        'Existing Fervor stacks must resume when Break ends')
end)

test('Troll Battle Trance reads rank values and heals only from enemy attacks', function()
    local troll = create_mock_unit('npc_dota_hero_troll_warlord', 2, Vector(0, 0, 0), 500)
    troll.hp = 100
    local ally = create_mock_unit('ally_troll', 2, Vector(100, 0, 0))
    local enemy = create_mock_unit('creep_troll', 3, Vector(100, 0, 0))
    local ability = enfos_troll_battle_trance()
    ability.GetCaster = function() return troll end
    ability.GetSpecialValueFor = function(_, key)
        return ({ duration=6, bonus_as=240, move_speed_pct=40, heal_pct=45 })[key] or 0
    end
    ability:OnSpellStart()
    local buff = troll:FindModifierByName('modifier_enfos_troll_battle_trance')
    assert(buff and buff.params.duration == 6 and buff:GetModifierAttackSpeedBonus_Constant() == 240)
    assert(buff:GetModifierMoveSpeedBonus_Percentage() == 40 and buff:GetMinHealth() == 1)
    buff:OnAttackLanded({ attacker=troll, target=ally, damage=100 })
    assert(troll.hp == 100)
    buff:OnAttackLanded({ attacker=troll, target=enemy, damage=100 })
    assert(troll.hp == 145)
end)

test('Troll Rampage passive uses ten-rank values and respects Break', function()
    local troll = create_mock_unit('npc_dota_hero_troll_warlord', 2, Vector(0, 0, 0))
    local ability = enfos_troll_rampage()
    ability.GetSpecialValueFor = function(_, key) return ({ bonus_damage=90, status_resistance=18 })[key] or 0 end
    local passive = modifier_enfos_troll_rampage()
    passive.GetParent = function() return troll end
    passive.GetAbility = function() return ability end
    assert(passive:GetModifierPreAttack_BonusDamage() == 90 and passive:GetModifierStatusResistanceStacking() == 18)
    troll.PassivesDisabled = function() return true end
    assert(passive:GetModifierPreAttack_BonusDamage() == 0 and passive:GetModifierStatusResistanceStacking() == 0)
end)

test('Monkey King Boundless Strike follows the configured line, damage and boss stun cap', function()
    applied_damages = {}
    local mk = create_mock_unit('npc_dota_hero_monkey_king', 2, Vector(0, 0, 0))
    local creep = create_mock_unit('creep_mk', 3, Vector(600, 0, 0))
    local outside_width = create_mock_unit('creep_mk_outside', 3, Vector(600, 200, 0))
    local boss = create_mock_unit('enfos_boss_mk', 3, Vector(900, 0, 0), 30000)
    mock_world_units = { mk, creep, outside_width, boss }
    local ability = enfos_mk_boundless_strike()
    ability.GetCaster = function() return mk end
    ability.GetCursorPosition = function() return Vector(1200, 0, 0) end
    ability.GetSpecialValueFor = function(_, key)
        return ({ range=1200, radius=100, strike_damage=200, stun_duration=1.5, boss_stun_duration=0.6 })[key] or 0
    end
    ability:OnSpellStart()
    assert(#applied_damages == 2)
    assert(applied_damages[1].victim == creep and applied_damages[1].damage == 200)
    assert(applied_damages[2].victim == boss and applied_damages[2].damage == 200)
    assert(creep:FindModifierByName('modifier_enfos_mk_boundless_strike_stun').params.duration == 1.5)
    assert(boss:FindModifierByName('modifier_enfos_mk_boundless_strike_stun').params.duration == 0.6)
end)

test('Monkey King Boundless Strike falls back to facing when the cursor is at the caster', function()
    applied_damages = {}
    local mk = create_mock_unit('npc_dota_hero_monkey_king', 2, Vector(0, 0, 0))
    mk.forward = Vector(0, 1, 0)
    local enemy = create_mock_unit('creep_mk_facing', 3, Vector(0, 500, 0))
    mock_world_units = { mk, enemy }
    local ability = enfos_mk_boundless_strike()
    ability.GetCaster = function() return mk end
    ability.GetCursorPosition = function() return mk:GetAbsOrigin() end
    ability.GetSpecialValueFor = function(_, key)
        return ({ range = 800, radius = 100, strike_damage = 150, stun_duration = 0.8 })[key] or 0
    end
    ability:OnSpellStart()
    assert(#applied_damages == 1 and applied_damages[1].victim == enemy,
        'Zero cursor direction must use the caster facing to form the strike line')
end)

test('Monkey King Primal Spring uses rank damage type, area and slow values', function()
    applied_damages = {}
    local mk = create_mock_unit('npc_dota_hero_monkey_king', 2, Vector(0, 0, 0))
    mk.agility = 100
    local creep = create_mock_unit('creep_mk', 3, Vector(100, 0, 0))
    local outside = create_mock_unit('creep_mk_far', 3, Vector(600, 0, 0))
    mock_world_units = { mk, creep, outside }
    local ability = enfos_mk_primal_spring()
    ability.GetCaster = function() return mk end
    ability.GetCursorPosition = function() return Vector(100, 0, 0) end
    ability.GetSpecialValueFor = function(_, key)
        return ({ spring_damage=200, agility_factor=1.5, radius=350, slow_duration=3.5, slow_pct=40 })[key] or 0
    end
    ability:OnSpellStart()
    assert(mk:GetAbsOrigin().x == 100)
    assert(#applied_damages == 1 and applied_damages[1].victim == creep)
    assert(applied_damages[1].damage == 350 and applied_damages[1].damage_type == DAMAGE_TYPE_PHYSICAL)
    assert(creep:FindModifierByName('modifier_enfos_mk_primal_spring_slow').params.duration == 3.5)
end)

test('Monkey King Jingu stacks only enemy hits and consumes configured empowered attacks', function()
    local mk = create_mock_unit('npc_dota_hero_monkey_king', 2, Vector(0, 0, 0), 300)
    local ally = create_mock_unit('ally_mk', 2, Vector(100, 0, 0))
    local enemy = create_mock_unit('creep_mk', 3, Vector(100, 0, 0))
    local ability = enfos_mk_jingu_mastery()
    ability.GetSpecialValueFor = function(_, key)
        return ({ charges_required=2, buff_attacks=3, buff_duration=12, bonus_damage=120, agility_factor=0.8, lifesteal_pct=35 })[key] or 0
    end
    local passive = modifier_enfos_mk_jingu_mastery_passive()
    passive.GetParent = function() return mk end
    passive.GetAbility = function() return ability end
    passive:OnAttackLanded({ attacker=mk, target=ally })
    assert((passive.counter or 0) == 0)
    passive:OnAttackLanded({ attacker=mk, target=enemy })
    assert(passive.counter == 1)
    passive:OnAttackLanded({ attacker=mk, target=enemy })
    local buff = mk:FindModifierByName('modifier_enfos_mk_jingu_mastery_buff')
    assert(buff and buff:GetStackCount() == 3 and buff.params.duration == 12)
    assert(buff:GetModifierPreAttack_BonusDamage() == 160)
    mk.PassivesDisabled = function() return true end
    buff:OnAttackLanded({ attacker=mk, target=enemy, damage=100 })
    assert(buff:GetModifierPreAttack_BonusDamage() == 0 and buff:GetStackCount() == 3,
        'Break must suppress existing Jingu bonus damage without consuming its empowered attacks')
    mk.PassivesDisabled = function() return false end
    buff:OnAttackLanded({ attacker=mk, target=ally, damage=100 })
    assert(buff:GetStackCount() == 3)
    buff:OnAttackLanded({ attacker=mk, target=enemy, damage=100 })
    assert(buff:GetStackCount() == 2 and mk.hp == 300)
end)

test('Monkey King Wukong pulses within its configured ring and Mischief honors Break', function()
    applied_damages = {}
    local mk = create_mock_unit('npc_dota_hero_monkey_king', 2, Vector(0, 0, 0))
    local inside = create_mock_unit('creep_mk_inside', 3, Vector(300, 0, 0))
    local outside = create_mock_unit('creep_mk_outside', 3, Vector(700, 0, 0))
    mock_world_units = { mk, inside, outside }
    local ability = enfos_mk_wukongs_command()
    ability.GetSpecialValueFor = function(_, key) return ({ ring_radius=500, soldier_damage=125, attack_interval=1.25 })[key] or 0 end
    local thinker = create_mock_unit('mk_thinker', 2, Vector(0, 0, 0))
    local modifier = modifier_enfos_mk_wukongs_command_thinker()
    modifier.GetParent = function() return thinker end
    modifier.GetCaster = function() return mk end
    modifier.GetAbility = function() return ability end
    modifier.StartIntervalThink = function(self, interval) self.interval = interval end
    modifier:OnCreated()
    assert(modifier.interval == 1.25)
    modifier:OnIntervalThink()
    assert(#applied_damages == 1 and applied_damages[1].victim == inside)
    assert(applied_damages[1].damage == 125 and applied_damages[1].damage_type == DAMAGE_TYPE_PHYSICAL)

    local passive = modifier_enfos_mk_mischief_passive()
    passive.GetParent = function() return mk end
    local passiveAbility = enfos_mk_mischief()
    passiveAbility.GetSpecialValueFor = function(_, key) return ({ bonus_range=88, evasion_pct=24 })[key] or 0 end
    passive.GetAbility = function() return passiveAbility end
    assert(passive:GetModifierAttackRangeBonus() == 88 and passive:GetModifierEvasion_Constant() == 24)
    mk.PassivesDisabled = function() return true end
    assert(passive:GetModifierAttackRangeBonus() == 0 and passive:GetModifierEvasion_Constant() == 0)
    mk.PassivesDisabled = function() return false end
    mk.IsIllusion = function() return true end
    assert(passive:GetModifierAttackRangeBonus() == 0 and passive:GetModifierEvasion_Constant() == 0,
        'Mischief bonuses must not be duplicated on illusions')
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
        if k == 'agility_factor' then return 0.15 end
        if k == 'max_stacks' then return 50 end
        if k == 'boss_max_stacks' then return 25 end
        if k == 'debuff_duration' then return 6 end
        if k == 'cleave_radius' then return 250 end
        if k == 'cleave_pct' then return 35 end
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
    assert(last_find_units_flags == DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        'Physical Fury Swipes cleave must include magic-immune enemy units')

    local other_ursa = create_mock_unit('npc_dota_hero_ursa', 2, Vector(-50, 0, 0))
    local foreign_stacks = { caster = other_ursa, stacks = 7 }
    boss.modifiers['modifier_enfos_ursa_fury_swipes_debuff'] = foreign_stacks
    local other_passive = modifier_enfos_ursa_fury_swipes_passive()
    other_passive.GetParent = function() return ursa end
    other_passive.GetAbility = function() return ab end
    other_passive:OnAttackLanded({ attacker = ursa, target = boss })
    local own_stacks = boss:FindModifierByNameAndCaster('modifier_enfos_ursa_fury_swipes_debuff', ursa)
    assert(own_stacks and own_stacks:GetStackCount() == 1,
        'Each Ursa must build its own Fury Swipes stacks instead of sharing another caster modifier')
end)

test('Ursa Earthshock reads radius, rank damage and boss slow cap from KV', function()
    applied_damages = {}
    local ursa = create_mock_unit('npc_dota_hero_ursa', 2, Vector(0, 0, 0))
    local boss = create_mock_unit('enfos_boss_ursa', 3, Vector(300, 0, 0), 20000)
    local outside = create_mock_unit('creep_outside_ursa', 3, Vector(500, 0, 0))
    mock_world_units = { ursa, boss, outside }
    local ability = enfos_ursa_earthshock()
    ability.GetCaster = function() return ursa end
    ability.GetSpecialValueFor = function(_, key)
        return ({ damage=240, strength_factor=1.5, radius=385, slow_duration=3.5, boss_slow_duration=1.0, slow_pct=44 })[key] or 0
    end
    ability:OnSpellStart()
    assert(#applied_damages == 1 and applied_damages[1].victim == boss)
    assert(applied_damages[1].damage == 315 and applied_damages[1].damage_type == DAMAGE_TYPE_PHYSICAL)
    assert(boss:FindModifierByName('modifier_enfos_ursa_earthshock_slow').params.duration == 1.0)
    assert(boss:FindModifierByName('modifier_enfos_ursa_earthshock_slow').params.slow_pct == 44)
end)

test('Ursa Overpower reads attack count and only consumes on enemy attacks', function()
    local ursa = create_mock_unit('npc_dota_hero_ursa', 2, Vector(0, 0, 0), 200)
    local ally = create_mock_unit('ally_ursa', 2, Vector(100, 0, 0))
    local enemy = create_mock_unit('creep_ursa', 3, Vector(100, 0, 0))
    local ability = enfos_ursa_overpower()
    ability.GetCaster = function() return ursa end
    ability.GetSpecialValueFor = function(_, key) return ({ buff_duration=12, max_attacks=7, attack_speed=650, attack_heal_pct=25 })[key] or 0 end
    ability:OnSpellStart()
    local buff = ursa:FindModifierByName('modifier_enfos_ursa_overpower_buff')
    assert(buff and buff:GetStackCount() == 7 and buff.params.duration == 12)
    assert(buff:GetModifierAttackSpeedBonus_Constant() == 650)
    buff:OnAttackLanded({ attacker=ursa, target=ally, damage=100 })
    assert(buff:GetStackCount() == 7 and ursa.hp == 200)
    buff:OnAttackLanded({ attacker=ursa, target=enemy, damage=100 })
    assert(buff:GetStackCount() == 6 and ursa.hp == 200) -- already at full health
end)

test('Ursa Enrage and Enfos passive honor configured values and Break', function()
    local ursa = create_mock_unit('npc_dota_hero_ursa', 2, Vector(0, 0, 0))
    local enrage = enfos_ursa_enrage()
    enrage.GetCaster = function() return ursa end
    enrage.GetSpecialValueFor = function(_, key) return ({ duration=7, damage_reduction=86, status_resistance=54 })[key] or 0 end
    enrage:OnSpellStart()
    local buff = ursa:FindModifierByName('modifier_enfos_ursa_enrage_buff')
    assert(buff and buff.params.duration == 7)
    assert(buff:GetModifierIncomingDamage_Percentage() == -86)
    assert(buff:GetModifierStatusResistanceStacking() == 54)

    local passive = modifier_enfos_ursa_minor_passive()
    passive.GetParent = function() return ursa end
    local passiveAbility = enfos_ursa_ursa_minor()
    passiveAbility.GetSpecialValueFor = function(_, key) if key == 'bonus_ms' then return 26 end return 0 end
    passive.GetAbility = function() return passiveAbility end
    assert(passive:GetModifierMoveSpeedBonus_Constant() == 26)
    ursa.PassivesDisabled = function() return true end
    assert(passive:GetModifierMoveSpeedBonus_Constant() == 0)
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
        if k == 'agility_factor' then return 0.6 end
        if k == 'cleave_radius' then return 250 end
        if k == 'cleave_pct' then return 35 end
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
    assert(last_find_units_flags == DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        'physical Mana Break cleave should also search spell-immune enemies')
end)

test('Anti-Mage Mana Break is disabled by Break, rejects illusions and ignores allies', function()
    applied_damages = {}
    local am = create_mock_unit('npc_dota_hero_antimage', 2, Vector(0, 0, 0))
    local enemy = create_mock_unit('enemy_am', 3, Vector(100, 0, 0))
    local ally = create_mock_unit('ally_am', 2, Vector(120, 0, 0))
    mock_world_units = { am, enemy, ally }
    local ab = enfos_am_mana_break()
    ab.GetSpecialValueFor = function(_, k)
        return ({ bonus_damage = 100, agility_factor = 0.5, cleave_radius = 250, cleave_pct = 30 })[k] or 0
    end
    local mod = modifier_enfos_am_mana_break_passive()
    mod.GetParent = function() return am end
    mod.GetAbility = function() return ab end
    mod:OnAttackLanded({ attacker = am, target = ally })
    am.PassivesDisabled = function() return true end
    mod:OnAttackLanded({ attacker = am, target = enemy })
    am.PassivesDisabled = function() return false end
    am.IsIllusion = function() return true end
    mod:OnAttackLanded({ attacker = am, target = enemy })
    assert(#applied_damages == 0)
end)

test('Anti-Mage Blink uses ranked range and preserves native start/end VFX flow', function()
    local am = create_mock_unit('npc_dota_hero_antimage', 2, Vector(0, 0, 0))
    local destination = Vector(800, 200, 0)
    local ab = enfos_am_blink()
    ab.GetCaster = function() return am end
    ab.GetCursorPosition = function() return destination end
    ab.GetSpecialValueFor = function(_, k) if k == 'blink_range' then return 900 end return 0 end
    assert(ab:GetCastRange() == 900)
    ab:OnSpellStart()
    assert(am.origin == destination)
end)

test('Anti-Mage Counterspell rank scales passive and active resistance and Break only shuts off passive', function()
    local am = create_mock_unit('npc_dota_hero_antimage', 2, Vector(0, 0, 0))
    local ab = enfos_am_counterspell()
    ab.GetCaster = function() return am end
    ab.GetSpecialValueFor = function(_, k)
        return ({ magic_resist = 45, active_resist = 90, active_duration = 2.75 })[k] or 0
    end
    local passive = modifier_enfos_am_counterspell_passive()
    passive.GetParent = function() return am end
    passive.GetAbility = function() return ab end
    assert(passive:GetModifierMagicalResistanceBonus() == 45)
    am.PassivesDisabled = function() return true end
    assert(passive:GetModifierMagicalResistanceBonus() == 0)
    am.PassivesDisabled = function() return false end
    am.IsIllusion = function() return true end
    assert(passive:GetModifierMagicalResistanceBonus() == 0, 'Counterspell passive resistance must not duplicate on illusions')
    local active = modifier_enfos_am_counterspell_active()
    active.GetAbility = function() return ab end
    assert(active:GetModifierMagicalResistanceBonus() == 90)
    ab:OnSpellStart()
    assert(am.modifiers.modifier_enfos_am_counterspell_active.params.duration == 2.75)
end)

test('Anti-Mage Mana Void uses missing mana, magical damage and a per-boss health cap', function()
    applied_damages = {}
    local am = create_mock_unit('npc_dota_hero_antimage', 2, Vector(0, 0, 0))
    am.agility = 100
    local target = create_mock_unit('enemy_void', 3, Vector(100, 0, 0), 10000)
    target.mana = 200
    target.max_mana = 1000
    local boss = create_mock_unit('enfos_boss_test', 3, Vector(120, 0, 0), 10000)
    boss.max_hp = 10000
    mock_world_units = { am, target, boss }
    local ab = enfos_am_mana_void()
    ab.GetCaster = function() return am end
    ab.GetCursorTarget = function() return target end
    ab.GetSpecialValueFor = function(_, k)
        return ({ radius = 500, base_damage = 100, damage_per_missing_mana = 0.5,
            agility_factor = 1, boss_damage_cap_pct = 5, stun_duration = 1.2 })[k] or 0
    end
    ab:OnSpellStart()
    assert(last_find_units_flags == DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        'Mana Void AoE search must include spell-immune enemies to match its piercing KV')
    -- 100 base + 800 missing mana x .5 + 100 Agility = 600.
    assert(#applied_damages == 2)
    assert(applied_damages[1].victim == target and applied_damages[1].damage == 600)
    assert(applied_damages[1].damage_type == DAMAGE_TYPE_MAGICAL)
    assert(applied_damages[2].victim == boss and applied_damages[2].damage == 500)
    assert(boss:FindModifierByName('modifier_enfos_am_mana_void_stun') == nil)
    assert(target:FindModifierByName('modifier_enfos_am_mana_void_stun').params.duration == 1.2)
end)

test('Anti-Mage Spellbreaker rank stats honor Break', function()
    local am = create_mock_unit('npc_dota_hero_antimage', 2, Vector(0, 0, 0))
    local ab = enfos_am_spellbreaker()
    ab.GetSpecialValueFor = function(_, k) return ({ bonus_as = 80, bonus_ms = 40 })[k] or 0 end
    local mod = modifier_enfos_am_spellbreaker_passive()
    mod.GetParent = function() return am end
    mod.GetAbility = function() return ab end
    assert(mod:GetModifierAttackSpeedBonus_Constant() == 80)
    assert(mod:GetModifierMoveSpeedBonus_Constant() == 40)
    am.PassivesDisabled = function() return true end
    assert(mod:GetModifierAttackSpeedBonus_Constant() == 0)
    assert(mod:GetModifierMoveSpeedBonus_Constant() == 0)
    am.PassivesDisabled = function() return false end
    am.IsIllusion = function() return true end
    assert(mod:GetModifierAttackSpeedBonus_Constant() == 0 and mod:GetModifierMoveSpeedBonus_Constant() == 0,
        'Spellbreaker passive stats must not duplicate on illusions')
end)

test('Faceless Void Time Walk uses rank range and rank healing', function()
    local void = create_mock_unit('npc_dota_hero_faceless_void', 2, Vector(0, 0, 0))
    void.hp, void.max_hp = 500, 1000
    local destination = Vector(600, 100, 0)
    local ab = enfos_void_time_walk()
    ab.GetCaster = function() return void end
    ab.GetCursorPosition = function() return destination end
    ab.GetSpecialValueFor = function(_, k) return ({ range = 900, heal = 225 })[k] or 0 end
    assert(ab:GetCastRange() == 900)
    ab:OnSpellStart()
    assert(void.origin == destination and void.hp == 725)
end)

test('Faceless Void Time Dilation applies rank slows and a shorter boss duration', function()
    local void = create_mock_unit('npc_dota_hero_faceless_void', 2, Vector(0, 0, 0))
    local creep = create_mock_unit('creep_void', 3, Vector(100, 0, 0))
    local boss = create_mock_unit('enfos_boss_void', 3, Vector(150, 0, 0))
    mock_world_units = { void, creep, boss }
    local ab = enfos_void_time_dilation()
    ab.GetCaster = function() return void end
    ab.GetSpecialValueFor = function(_, k)
        return ({ radius = 750, duration = 8, boss_duration = 3.5,
            move_slow_pct = 38, attack_slow = 70 })[k] or 0
    end
    ab:OnSpellStart()
    assert(creep.modifiers.modifier_enfos_void_time_dilation_debuff.params.duration == 8)
    assert(boss.modifiers.modifier_enfos_void_time_dilation_debuff.params.duration == 3.5)
    local debuff = creep.modifiers.modifier_enfos_void_time_dilation_debuff
    assert(debuff:GetModifierMoveSpeedBonus_Percentage() == -38)
    assert(debuff:GetModifierAttackSpeedBonus_Constant() == -70)
end)

test('Faceless Void Time Lock uses rank proc values, enemy-only hits, and boss stun cap', function()
    applied_damages = {}
    local void = create_mock_unit('npc_dota_hero_faceless_void', 2, Vector(0, 0, 0))
    void.agility = 100
    local creep = create_mock_unit('creep_void', 3, Vector(100, 0, 0))
    local boss = create_mock_unit('enfos_boss_void', 3, Vector(120, 0, 0))
    mock_world_units = { void, creep, boss }
    local ab = enfos_void_time_lock()
    ab.GetSpecialValueFor = function(_, k)
        return ({ bonus_damage = 100, proc_chance = 30, agility_factor = 0.8,
            stun_duration = 0.5, boss_stun_duration = 0.2 })[k] or 0
    end
    local mod = modifier_enfos_void_time_lock_passive()
    mod.GetParent = function() return void end
    mod.GetAbility = function() return ab end
    mod:OnAttackLanded({ attacker = void, target = creep })
    assert(applied_damages[1].victim == creep and applied_damages[1].damage == 180)
    assert(creep.modifiers.modifier_enfos_void_time_lock_stun.params.duration == 0.5)
    mod:OnAttackLanded({ attacker = void, target = boss })
    assert(boss.modifiers.modifier_enfos_void_time_lock_stun.params.duration == 0.2)
    void.PassivesDisabled = function() return true end
    mod:OnAttackLanded({ attacker = void, target = creep })
    assert(#applied_damages == 2)
end)

test('Faceless Void Backtrack ranks damage avoidance and honors Break and illusion rules', function()
    local void = create_mock_unit('npc_dota_hero_faceless_void', 2, Vector(0, 0, 0))
    local ab = enfos_void_backtrack()
    ab.GetSpecialValueFor = function(_, k) if k == 'dodge_pct' then return 22 end return 0 end
    local mod = modifier_enfos_void_backtrack_passive()
    mod.GetParent = function() return void end
    mod.GetAbility = function() return ab end
    assert(mod:GetModifierAvoidDamage({}) == 1)
    void.PassivesDisabled = function() return true end
    assert(mod:GetModifierAvoidDamage({}) == 0)
    void.PassivesDisabled = function() return false end
    void.IsIllusion = function() return true end
    assert(mod:GetModifierAvoidDamage({}) == 0)
end)

test('Faceless Void Chronosphere refreshes normal freezes, limits boss control and cleans its thinker', function()
    local void = create_mock_unit('npc_dota_hero_faceless_void', 2, Vector(-500, 0, 0))
    local creep = create_mock_unit('creep_void_chrono', 3, Vector(100, 0, 0))
    local boss = create_mock_unit('enfos_boss_void_chrono', 3, Vector(200, 0, 0))
    local ally = create_mock_unit('ally_void_chrono', 2, Vector(150, 0, 0))
    local outside = create_mock_unit('creep_void_chrono_outside', 3, Vector(700, 0, 0))
    mock_world_units = { void, creep, boss, ally, outside }
    local boss_freeze_count = 0
    local boss_add_modifier = boss.AddNewModifier
    boss.AddNewModifier = function(self, caster, ability, modifier_name, params)
        if modifier_name == 'modifier_enfos_void_chronosphere_freeze' then boss_freeze_count = boss_freeze_count + 1 end
        return boss_add_modifier(self, caster, ability, modifier_name, params)
    end

    local captured_thinker
    local create_thinker = CreateModifierThinker
    CreateModifierThinker = function(caster, ability, modifier_name, params, position, team, phantom)
        local entity = create_thinker(caster, ability, modifier_name, params, position, team, phantom)
        captured_thinker = entity.modifiers[modifier_name]
        return entity
    end
    local destroyed_particle
    local destroy_particle = ParticleManager.DestroyParticle
    ParticleManager.DestroyParticle = function(_, index, immediate)
        destroyed_particle = index
        return destroy_particle(index, immediate)
    end

    local ability = enfos_void_chronosphere()
    ability.GetCaster = function() return void end
    ability.GetCursorPosition = function() return Vector(0, 0, 0) end
    ability.GetSpecialValueFor = function(_, key)
        return ({ duration = 5, radius = 500, boss_duration = 0.4 })[key] or 0
    end
    ability:OnSpellStart()
    assert(captured_thinker, 'Chronosphere must create its bounded ground thinker')
    assert(creep:FindModifierByName('modifier_enfos_void_chronosphere_freeze').params.duration == 0.5,
        'Normal enemies receive a short renewable freeze')
    assert(boss:FindModifierByName('modifier_enfos_void_chronosphere_freeze').params.duration == 0.4,
        'Boss control must use the configured short duration')
    assert(not ally:HasModifier('modifier_enfos_void_chronosphere_freeze')
        and not outside:HasModifier('modifier_enfos_void_chronosphere_freeze'),
        'Chronosphere affects only enemies within its radius')
    captured_thinker:OnIntervalThink()
    assert(boss_freeze_count == 1, 'Repeated pulses must not refresh the boss control in one sphere')
    local thinker_parent = captured_thinker:GetParent()
    captured_thinker:Destroy()
    CreateModifierThinker = create_thinker
    ParticleManager.DestroyParticle = destroy_particle
    assert(destroyed_particle == 1 and thinker_parent.removed,
        'Chronosphere expiry must destroy its persistent particle and remove the thinker')
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
        if k == 'splash_radius' then return 325 end
        if k == 'int_scaling_pct' then return 250 end
        if k == 'boss_damage_cap_pct' then return 12 end
        if k == 'kill_stack_cap' then return 20 end
        if k == 'kill_stack_damage' then return 40 end
        if k == 'kill_stack_spell_amp_pct' then return 1.5 end
        return 0
    end

    -- Add finger counter modifier
    local counter = lion:AddNewModifier(lion, ab, 'modifier_enfos_lion_finger_counter', {})

    ab:OnSpellStart()
    -- dmg = 850 + (80 * 2.5 = 200) = 1050
    assert(#applied_damages == 2)
    assert(applied_damages[1].damage == 1050 and applied_damages[1].damage_type == DAMAGE_TYPE_MAGICAL)
    assert(applied_damages[2].damage == 1050 and applied_damages[2].damage_type == DAMAGE_TYPE_MAGICAL)

    counter:SetStackCount(25)
    assert(counter:GetModifierSpellAmplify_Percentage() == 30, 'spell amplification must stop at the 20-stack cap')
    applied_damages = {}
    ab:OnSpellStart()
    assert(applied_damages[1].damage == 1850, 'Finger bonus damage must also clamp to the configured stack cap')

    local boss = create_mock_unit('enfos_boss_test', 3, Vector(100, 0, 0), 1000)
    mock_world_units = { lion, boss }
    applied_damages = {}
    counter:SetStackCount(0)
    ab:OnSpellStart()
    assert(applied_damages[1].damage == 120, 'boss damage must respect the KV-configured 12% max-health cap')
end)

test('Lion Earth Spike uses KV geometry and Hex reads normal/boss control values', function()
    applied_damages = {}
    local lion = create_mock_unit('npc_dota_hero_lion', 2, Vector(0, 0, 0))
    lion.intellect = 100
    local target = create_mock_unit('earth_spike_target', 3, Vector(700, 0, 0))
    mock_world_units = { lion, target }
    local spike = enfos_lion_earth_spike()
    spike.GetCaster = function() return lion end
    spike.GetCursorPosition = function() return Vector(100, 0, 0) end
    spike.GetSpecialValueFor = function(_, key)
        local values = { damage = 200, int_scaling_pct = 110, distance = 700, radius = 125, stun_duration = 2 }
        return values[key] or 0
    end
    spike:OnSpellStart()
    assert(last_find_units_radius == 125 and last_find_units_point.x == 700,
        'Earth Spike should use configured radius and cast-direction distance')
    assert(applied_damages[1].damage == 310, 'Earth Spike should read its configured intelligence coefficient')
    assert(math.abs(target.modifiers.modifier_enfos_lion_earth_spike_stun.params.duration - 2) < 0.001)

    local normal = create_mock_unit('hex_normal', 3, Vector(0, 0, 0))
    local hex = enfos_lion_hex()
    hex.GetCaster = function() return lion end
    hex.GetCursorTarget = function() return normal end
    hex.GetSpecialValueFor = function(_, key)
        return ({ duration = 4.5, boss_duration = 0.8, base_move_speed = 140 })[key] or 0
    end
    hex:OnSpellStart()
    assert(normal.modifiers.modifier_enfos_lion_hex_debuff.params.duration == 4.5,
        'normal Hex should use ranked duration')
    local speed_mod = normal.modifiers.modifier_enfos_lion_hex_debuff
    assert(speed_mod:GetModifierMoveSpeedOverride() == 140)
    local boss = create_mock_unit('enfos_boss_hex', 3, Vector(0, 0, 0))
    hex.GetCursorTarget = function() return boss end
    hex:OnSpellStart()
    assert(boss.modifiers.modifier_enfos_lion_hex_debuff.params.duration == 0.8,
        'boss Hex duration should come from its named KV value')
end)

test('Lion Mana Drain channel and slow values are read from KV', function()
    local lion = create_mock_unit('npc_dota_hero_lion', 2, Vector(0, 0, 0))
    local target = create_mock_unit('lion_mana_target', 3, Vector(100, 0, 0))
    local drain = enfos_lion_mana_drain()
    drain.GetCaster = function() return lion end
    drain.GetCursorTarget = function() return target end
    drain.GetSpecialValueFor = function(_, key)
        return ({ channel_duration = 6, slow_pct = 42 })[key] or 0
    end
    drain:OnSpellStart()
    assert(lion.modifiers.modifier_enfos_lion_mana_drain_channel.params.duration == 6)
    assert(target.modifiers.modifier_enfos_lion_mana_drain_debuff.params.duration == 6)
    assert(target.modifiers.modifier_enfos_lion_mana_drain_debuff:GetModifierMoveSpeedBonus_Percentage() == -42)
end)

test('Lion Mana Drain ends the engine channel when its target dies', function()
    local lion = create_mock_unit('npc_dota_hero_lion', 2, Vector(0, 0, 0))
    local target = create_mock_unit('lion_drain_target', 3, Vector(100, 0, 0))
    target.alive = false
    mock_world_units = { lion, target }
    local ended = false
    local ability = { EndChannel = function(_, interrupted) ended = interrupted == true end }
    local channel = setmetatable({
        target_idx = target:entindex(),
        GetParent = function() return lion end,
        GetAbility = function() return ability end,
        Destroy = function(self) self.destroyed = true end,
    }, modifier_enfos_lion_mana_drain_channel)
    channel:OnIntervalThink()
    assert(ended, 'invalid target should stop the actual ability channel')
end)


test('Underlord Firestorm delivers six ranked damage waves at the configured interval', function()
    local previous_game_rules = GameRules
    local callback, callback_delay
    GameRules = { GetGameModeEntity = function()
        return { SetContextThink = function(_, name, fn, delay) callback, callback_delay = fn, delay end }
    end }
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
        if k == 'wave_count' then return 6 end
        if k == 'wave_interval' then return 1 end
        if k == 'burn_duration' then return 2 end
        if k == 'burn_pct' then return 2 end
        return 0
    end

    ab:OnSpellStart()
    -- dmg = 95 + (100 * 0.3 = 30) = 125
    assert(callback and callback_delay == 1, 'Later Firestorm impacts use the configured interval')
    assert(#applied_damages == 2, 'Firestorm first wave is immediate and hits both creeps')
    assert(applied_damages[1].damage == 125 and applied_damages[1].damage_type == DAMAGE_TYPE_MAGICAL)
    assert(applied_damages[2].damage == 125 and applied_damages[2].damage_type == DAMAGE_TYPE_MAGICAL)
    for _ = 2, 5 do assert(callback() == 1, 'Firestorm schedules its next wave') end
    assert(callback() == nil, 'Firestorm stops after its configured sixth wave')
    assert(#applied_damages == 12, 'Six waves must each damage both enemies once')
    assert(creep1:HasModifier('modifier_enfos_underlord_firestorm_burn'))
    assert(creep2:HasModifier('modifier_enfos_underlord_firestorm_burn'))
    GameRules = previous_game_rules
end)

test('Underlord Pit of Malice damages enemies and shortens boss root duration', function()
    applied_damages = {}
    local underlord = create_mock_unit('npc_dota_hero_abyssal_underlord', 2, Vector(0, 0, 0))
    underlord.strength = 100
    local creep = create_mock_unit('creep_underlord_pit', 3, Vector(100, 0, 0))
    local boss = create_mock_unit('enfos_boss_underlord_pit', 3, Vector(200, 0, 0), 20000)
    mock_world_units = { underlord, creep, boss }
    local ability = enfos_underlord_pit_of_malice()
    ability.GetCaster = function() return underlord end
    ability.GetCursorPosition = function() return Vector(100, 0, 0) end
    ability.GetSpecialValueFor = function(_, key)
        return ({ radius = 400, ensnare_duration = 2, damage = 80 })[key] or 0
    end

    ability:OnSpellStart()
    assert(#applied_damages == 2 and applied_damages[1].damage == 130 and applied_damages[2].damage == 130)
    assert(creep:FindModifierByName('modifier_enfos_underlord_pit_root').params.duration == 2)
    assert(boss:FindModifierByName('modifier_enfos_underlord_pit_root').params.duration == 0.7)
end)

test('Underlord Atrophy Aura accumulates nearby enemy deaths and honors Break', function()
    local underlord = create_mock_unit('npc_dota_hero_abyssal_underlord', 2, Vector(0, 0, 0))
    local nearby = create_mock_unit('creep_underlord_atrophy', 3, Vector(300, 0, 0))
    local boss = create_mock_unit('enfos_boss_underlord_atrophy', 3, Vector(400, 0, 0))
    local distant = create_mock_unit('creep_underlord_atrophy_far', 3, Vector(1000, 0, 0))
    local ability = enfos_underlord_atrophy_aura()
    ability.GetSpecialValueFor = function(_, key)
        return ({ radius = 900, bonus_damage = 20, bonus_damage_per_stack = 7,
            normal_kill_stacks = 2, boss_kill_stacks = 4, reduction = 25 })[key] or 0
    end
    local aura = modifier_enfos_underlord_atrophy_aura()
    aura.GetParent = function() return underlord end
    aura.GetAbility = function() return ability end
    aura.GetStackCount = function(self) return self.stack_count or 0 end
    aura.SetStackCount = function(self, count) self.stack_count = count end
    aura:OnDeath({ unit = nearby })
    aura:OnDeath({ unit = boss })
    aura:OnDeath({ unit = distant })
    assert(aura:GetStackCount() == 6, 'Nearby normal and boss deaths grant their configured Atrophy stacks; distant deaths grant none')
    assert(aura:GetModifierPreAttack_BonusDamage() == 62,
        'Atrophy attack damage must use the configured bonus per stack rather than a Lua constant')
    underlord.PassivesDisabled = function() return true end
    assert(aura:GetModifierPreAttack_BonusDamage() == 0, 'Break disables the owner damage bonus')

    local debuff = modifier_enfos_underlord_atrophy_debuff()
    debuff.GetAbility = function() return ability end
    assert(debuff:GetModifierBaseDamageOutgoing_Percentage() == -25)
end)

test('Underlord Dark Rift caps boss burst and Abyssal Carapace stats honor Break', function()
    applied_damages = {}
    local underlord = create_mock_unit('npc_dota_hero_abyssal_underlord', 2, Vector(0, 0, 0))
    underlord.strength = 100
    local creep = create_mock_unit('creep_underlord_rift', 3, Vector(100, 0, 0), 10000)
    local boss = create_mock_unit('enfos_boss_underlord_rift', 3, Vector(200, 0, 0), 2000)
    mock_world_units = { underlord, creep, boss }
    local ability = enfos_underlord_dark_rift()
    ability.GetCaster = function() return underlord end
    ability.GetSpecialValueFor = function(_, key)
        return ({ radius = 750, burst_damage = 350 })[key] or 0
    end
    ability:OnSpellStart()
    assert(#applied_damages == 2 and applied_damages[1].damage == 500 and applied_damages[2].damage == 200)
    assert(applied_damages[1].damage_type == DAMAGE_TYPE_MAGICAL and applied_damages[2].damage_type == DAMAGE_TYPE_MAGICAL)

    local carapace = modifier_enfos_underlord_carapace()
    carapace.GetParent = function() return underlord end
    carapace.GetAbility = function()
        return { GetSpecialValueFor = function(_, key) return ({ bonus_armor = 8, bonus_hp = 500 })[key] or 0 end }
    end
    assert(carapace:GetModifierPhysicalArmorBonus() == 8 and carapace:GetModifierHealthBonus() == 500)
    underlord.PassivesDisabled = function() return true end
    assert(carapace:GetModifierPhysicalArmorBonus() == 0 and carapace:GetModifierHealthBonus() == 0)
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
        if k == 'agility_factor' then return 0.8 end
        return 0
    end

    ab:OnSpellStart()
    -- dmg = 270 + (120 * 0.8 = 96) = 366
    assert(#applied_damages == 1)
    assert(applied_damages[1].damage == 366 and applied_damages[1].damage_type == DAMAGE_TYPE_MAGICAL)
    assert(creep:FindModifierByName('modifier_enfos_troll_whirling_axes_blind') ~= nil)
end)

test('Chaos Knight Chaos Bolt launches a targetable projectile and caps boss stun', function()
    applied_damages = {}
    local ck = create_mock_unit('npc_dota_hero_chaos_knight', 2, Vector(0, 0, 0))
    ck.strength = 100
    local target = create_mock_unit('creep_ck', 3, Vector(400, 0, 0))
    mock_world_units = { ck, target }
    local ability = enfos_ck_chaos_bolt()
    ability.GetCaster = function() return ck end
    ability.GetCursorTarget = function() return target end
    ability.GetSpecialValueFor = function(_, key)
        return ({ range=600, damage=240, strength_factor=0.9, projectile_speed=1100, stun_min=1, stun_max=2.5, boss_stun_duration=0.5 })[key] or 0
    end
    ability:OnSpellStart()
    assert(last_tracking_projectile and last_tracking_projectile.Target == target)
    assert(last_tracking_projectile.iMoveSpeed == 1100 and last_tracking_projectile.bDodgeable)
    ability:OnProjectileHit(target, target:GetAbsOrigin())
    assert(#applied_damages == 1 and applied_damages[1].damage == 330 and applied_damages[1].damage_type == DAMAGE_TYPE_MAGICAL)
    assert(target:FindModifierByName('modifier_enfos_ck_chaos_bolt_stun').params.duration == 1)

    local boss = create_mock_unit('enfos_boss_ck', 3, Vector(500, 0, 0), 20000)
    ability:OnProjectileHit(boss, boss:GetAbsOrigin())
    assert(boss:FindModifierByName('modifier_enfos_ck_chaos_bolt_stun').params.duration == 0.5)
    target.TriggerSpellAbsorb = function() return true end
    local previous = last_tracking_projectile
    ability:OnSpellStart()
    assert(last_tracking_projectile == previous, 'spell block must cancel the projectile')
end)

test('Chaos Knight Reality Rift honors spell block, boss limits and only repositions enemies', function()
    local ck = create_mock_unit('npc_dota_hero_chaos_knight', 2, Vector(0, 0, 0))
    local target = create_mock_unit('creep_ck', 3, Vector(800, 0, 0))
    ck.MoveToTargetToAttack = function(self, unit) self.attack_target = unit end
    local ability = enfos_ck_reality_rift()
    ability.GetCaster = function() return ck end
    ability.GetCursorTarget = function() return target end
    ability.GetSpecialValueFor = function(_, key)
        return ({ range=600, armor_reduction=12, duration=7.5, boss_duration=3 })[key] or 0
    end
    target.TriggerSpellAbsorb = function() return true end
    ability:OnSpellStart()
    assert(target:GetAbsOrigin().x == 800 and ck:GetAbsOrigin().x == 0)
    target.TriggerSpellAbsorb = function() return false end
    ability:OnSpellStart()
    assert(ck:GetAbsOrigin().x == 400 and target:GetAbsOrigin().x == 400 and ck.attack_target == target)
    local debuff = target:FindModifierByName('modifier_enfos_ck_reality_rift_debuff')
    assert(debuff and debuff.params.duration == 7.5 and debuff:GetModifierPhysicalArmorBonus() == -12)
    local boss = create_mock_unit('enfos_boss_ck', 3, Vector(900, 0, 0), 20000)
    ability.GetCursorTarget = function() return boss end
    ability:OnSpellStart()
    assert(boss:FindModifierByName('modifier_enfos_ck_reality_rift_debuff').params.duration == 3)
    assert(boss:GetAbsOrigin().x == 900, 'bosses do not get displaced')
end)

test('Chaos Knight Phantasm passes rank count and outgoing damage to the bounded summon service', function()
    local ck = create_mock_unit('npc_dota_hero_chaos_knight', 2, Vector(0, 0, 0))
    local enemy = create_mock_unit('creep_ck', 3, Vector(100, 0, 0))
    local ability = enfos_ck_phantasm()
    ability.GetCaster = function() return ck end
    ability.GetSpecialValueFor = function(_, key)
        return ({ duration=28, illusion_count=4, illusion_outgoing_pct=55, bonus_damage=160, echo_damage_pct=46 })[key] or 0
    end
    local oldCreateIllusions, received = CreateIllusions, nil
    CreateIllusions = function(hero, owner, options, count) received = { options=options, count=count }; return {} end
    ability:OnSpellStart()
    CreateIllusions = oldCreateIllusions
    assert(received and received.count == 4 and received.options.duration == 28)
    assert(received.options.outgoing_damage == -45 and received.options.incoming_damage == 200)
    local buff = ck:FindModifierByName('modifier_enfos_ck_phantasm_buff')
    assert(buff and buff.params.duration == 28 and buff:GetModifierPreAttack_BonusDamage() == 160)
    applied_damages = {}
    buff:OnAttackLanded({ attacker=ck, target=enemy, damage=100 })
    assert(#applied_damages == 1 and applied_damages[1].damage == 46)
end)

test('Chaos Knight Entropy passive uses rank values and respects Break', function()
    local ck = create_mock_unit('npc_dota_hero_chaos_knight', 2, Vector(0, 0, 0))
    local ability = enfos_ck_entropy()
    ability.GetSpecialValueFor = function(_, key) return ({ bonus_strength=45, bonus_speed=45 })[key] or 0 end
    local passive = modifier_enfos_ck_entropy()
    passive.GetParent = function() return ck end
    passive.GetAbility = function() return ability end
    assert(passive:GetModifierBonusStats_Strength() == 45 and passive:GetModifierAttackSpeedBonus_Constant() == 45)
    ck.PassivesDisabled = function() return true end
    assert(passive:GetModifierBonusStats_Strength() == 0 and passive:GetModifierAttackSpeedBonus_Constant() == 0)
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
        if k == 'cleave_radius' then return 250 end
        if k == 'cleave_pct' then return 40 end
        return 0
    end

    local mod = ck:AddNewModifier(ck, ab, 'modifier_enfos_ck_chaos_strike', {})
    assert(mod:GetModifierPreAttack_CriticalStrike() == 200)

    mod:OnTakeDamage({
        attacker = ck,
        unit = target,
        damage = 300,
        damage_category = DOTA_DAMAGE_CATEGORY_ATTACK,
        inflictor = nil
    })

    assert(ck.hp == 650, 'Lifesteals 50% of 300 damage = +150 HP')
    assert(#applied_damages == 1, 'Cleaves to nearby splash target')
    assert(applied_damages[1].victim == splash and applied_damages[1].damage == 120)
    local hp = ck.hp
    mod:OnTakeDamage({ attacker=ck, unit=target, damage=500, damage_category=DOTA_DAMAGE_CATEGORY_SPELL, inflictor=ab })
    assert(ck.hp == hp and #applied_damages == 1, 'Ability damage must not trigger attack lifesteal or recursive cleave')
end)

test('Medusa Mystic Snake chains real tracking projectiles and restores configured mana', function()
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
        if k == 'agility_factor' then return 0.8 end
        if k == 'damage_per_jump_pct' then return 120 end
        if k == 'mana_steal' then return 30 end
        if k == 'boss_damage_cap_pct' then return 5 end
        if k == 'projectile_speed' then return 900 end
        return 0
    end

    ab:OnSpellStart()
    assert(last_tracking_projectile.Target == creep1, 'Snake starts with a visible tracking projectile')
    local firstExtra = last_tracking_projectile.ExtraData
    ab:OnProjectileHit_ExtraData(creep1, creep1:GetAbsOrigin(), firstExtra)
    assert(last_tracking_projectile.Target == creep2, 'Snake launches its next projectile after impact')
    local secondExtra = last_tracking_projectile.ExtraData
    ab:OnProjectileHit_ExtraData(creep2, creep2:GetAbsOrigin(), secondExtra)
    -- jump 1: 300 + (100 * 0.8 = 80) = 380
    -- jump 2: 380 * 1.2 = 456
    assert(#applied_damages == 2, 'Snake bounces to second creep')
    assert(applied_damages[1].damage == 380)
    assert(applied_damages[2].damage == 456)
    assert(medusa.mana == 160, 'Restores mana on hits')
end)

test('Medusa Split Shot deals additional damage on tracking projectile impact', function()
    applied_damages = {}
    local medusa = create_mock_unit('npc_dota_hero_medusa', 2, Vector(0, 0, 0))
    medusa.agility = 100
    local primary = create_mock_unit('primary_medusa', 3, Vector(100, 0, 0))
    local side1 = create_mock_unit('side_medusa_1', 3, Vector(150, 0, 0))
    local side2 = create_mock_unit('side_medusa_2', 3, Vector(200, 0, 0))
    mock_world_units = { medusa, primary, side1, side2 }
    local ab = enfos_medusa_split_shot()
    ab.GetCaster = function() return medusa end
    ab.GetSpecialValueFor = function(_, k)
        return ({ arrow_count = 2, damage_modifier = 50, agility_factor = 0.4,
            projectile_speed = 1000, radius = 500 })[k] or 0
    end
    ab.GetToggleState = function() return true end
    local mod = modifier_enfos_medusa_split_shot()
    mod.GetParent = function() return medusa end
    mod.GetAbility = function() return ab end
    local projectiles = {}
    local previous = ProjectileManager.CreateTrackingProjectile
    ProjectileManager.CreateTrackingProjectile = function(_, options) projectiles[#projectiles + 1] = options return #projectiles end
    mod:OnAttackLanded({ attacker = medusa, target = primary })
    assert(#projectiles == 2 and #applied_damages == 0, 'Side-shot damage waits for projectile impact')
    assert(projectiles[1].Target == side1 and projectiles[2].Target == side2)
    assert(projectiles[1].ExtraData.split_shot_damage == 90)
    ab:OnProjectileHit_ExtraData(side1, side1:GetAbsOrigin(), projectiles[1].ExtraData)
    assert(#applied_damages == 1 and applied_damages[1].victim == side1)
    assert(applied_damages[1].damage == 90 and applied_damages[1].damage_type == DAMAGE_TYPE_PHYSICAL)
    ProjectileManager.CreateTrackingProjectile = previous
end)

test('Medusa Mana Shield spends rank-scaled mana and Break disables shield and mana bonus', function()
    local medusa = create_mock_unit('npc_dota_hero_medusa', 2, Vector(0, 0, 0))
    local ab = enfos_medusa_mana_shield()
    ab.GetSpecialValueFor = function(_, k)
        return ({ bonus_mana = 700, absorption_pct = 60, damage_per_mana = 2 })[k] or 0
    end
    local mod = modifier_enfos_medusa_mana_shield()
    mod.GetParent = function() return medusa end
    mod.GetAbility = function() return ab end
    assert(mod:GetModifierManaBonus() == 700)
    assert(mod:GetModifierIncomingDamageConstant({ damage = 200 }) == -120)
    assert(medusa.mana == 440)
    medusa.PassivesDisabled = function() return true end
    assert(mod:GetModifierManaBonus() == 0)
    assert(mod:GetModifierIncomingDamageConstant({ damage = 200 }) == 0)
end)

test('Medusa Stone Gaze uses rank petrify/amp values and limits boss control', function()
    local medusa = create_mock_unit('npc_dota_hero_medusa', 2, Vector(0, 0, 0))
    local creep = create_mock_unit('creep_stone', 3, Vector(100, 0, 0))
    local boss = create_mock_unit('enfos_boss_stone', 3, Vector(120, 0, 0))
    mock_world_units = { medusa, creep, boss }
    local ab = enfos_medusa_stone_gaze()
    ab.GetCaster = function() return medusa end
    ab.GetSpecialValueFor = function(_, k)
        return ({ radius = 900, petrify_duration = 3, boss_duration = 0.8, damage_amp = 45 })[k] or 0
    end
    ab:OnSpellStart()
    assert(creep.modifiers.modifier_enfos_medusa_petrified.params.duration == 3)
    assert(boss.modifiers.modifier_enfos_medusa_petrified.params.duration == 0.8)
    local petrified = modifier_enfos_medusa_petrified()
    petrified.GetAbility = function() return ab end
    assert(petrified:GetModifierIncomingPhysicalDamage_Percentage() == 45)
end)

test('Medusa Enfos passive grants rank stats and respects Break and illusion rules', function()
    local medusa = create_mock_unit('npc_dota_hero_medusa', 2, Vector(0, 0, 0))
    local ab = enfos_medusa_gorgon_gaze()
    ab.GetSpecialValueFor = function(_, k) return ({ bonus_damage = 150, bonus_range = 100 })[k] or 0 end
    local mod = modifier_enfos_medusa_gorgon_gaze()
    mod.GetParent = function() return medusa end
    mod.GetAbility = function() return ab end
    assert(mod:GetModifierPreAttack_BonusDamage() == 150)
    assert(mod:GetModifierAttackRangeBonus() == 100)
    medusa.PassivesDisabled = function() return true end
    assert(mod:GetModifierPreAttack_BonusDamage() == 0 and mod:GetModifierAttackRangeBonus() == 0)
    medusa.PassivesDisabled = function() return false end
    medusa.IsIllusion = function() return true end
    assert(mod:GetModifierPreAttack_BonusDamage() == 0 and mod:GetModifierAttackRangeBonus() == 0)
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
        return ({ heal_amount=1000, agility_factor=1.5, boss_damage_cap_pct=10 })[k] or 0
    end

    ab:OnSpellStart()
    -- heal = 1000 + (100 * 1.5 = 150) = 1150
    assert(tb.hp == 1350, 'TB healed for 1150')
    assert(#applied_damages == 1)
    assert(applied_damages[1].damage == 1000, 'Boss damage capped at 1000')
    assert(applied_damages[1].damage_type == DAMAGE_TYPE_PURE)
end)

test('Terrorblade Reflection applies ranked slow and periodic damage with a boss cap', function()
    applied_damages = {}
    local tb = create_mock_unit('npc_dota_hero_terrorblade', 2, Vector(0, 0, 0))
    tb.agility = 100
    local boss = create_mock_unit('enfos_boss_tb', 3, Vector(50, 0, 0), 10000)
    boss.is_boss = true
    local ability = enfos_tb_reflection()
    ability.GetCaster = function() return tb end
    ability.GetCursorPosition = function() return Vector(50, 0, 0) end
    ability.GetSpecialValueFor = function(_, k)
        return ({ radius=250, duration=5, boss_duration=2, boss_slow_pct=20,
            damage_per_tick=200, agility_factor=1, boss_tick_cap_pct=0.5 })[k] or 0
    end
    mock_world_units = { tb, boss }
    ability:OnSpellStart()
    local debuff = boss:FindModifierByName('modifier_enfos_tb_reflection')
    assert(debuff and debuff.params.duration == 2 and debuff:GetModifierMoveSpeedBonus_Percentage() == -20)
    debuff.GetCaster = function() return tb end
    debuff.GetAbility = function() return ability end
    debuff:OnIntervalThink()
    assert(#applied_damages == 1 and applied_damages[1].damage == 50)
end)

test('Terrorblade Conjure Image passes rank count/duration/damage to summon service', function()
    local tb = create_mock_unit('npc_dota_hero_terrorblade', 2, Vector(0, 0, 0))
    local ability = enfos_tb_conjure_image()
    ability.GetCaster = function() return tb end
    ability.GetSpecialValueFor = function(_, k)
        return ({ duration=36, illusion_count=3, illusion_damage=58, bonus_damage=150, echo_damage_pct=30 })[k] or 0
    end
    local oldCreateIllusions, received = CreateIllusions, nil
    CreateIllusions = function(_, _, options, count) received={ options=options, count=count }; return {} end
    ability:OnSpellStart()
    CreateIllusions = oldCreateIllusions
    assert(received and received.count == 3 and received.options.duration == 36)
    assert(received.options.outgoing_damage == -42 and received.options.incoming_damage == 200)
    local buff = tb:FindModifierByName('modifier_enfos_tb_conjure_image_buff')
    assert(buff and buff:GetModifierPreAttack_BonusDamage() == 150)
end)

test('Terrorblade Metamorphosis applies its ranked transformation bonus', function()
    local tb = create_mock_unit('npc_dota_hero_terrorblade', 2, Vector(0, 0, 0))
    tb.agility = 100
    local ability = enfos_tb_metamorphosis()
    ability.GetCaster = function() return tb end
    ability.GetSpecialValueFor = function(_, k)
        return ({ duration=40, bonus_damage=180, bonus_range=560, agility_factor=0.9 })[k] or 0
    end
    ability:OnSpellStart()
    local buff = tb:FindModifierByName('modifier_enfos_tb_metamorphosis')
    assert(buff and buff.params.duration == 40)
    assert(buff:GetModifierPreAttack_BonusDamage() == 270 and buff:GetModifierAttackRangeBonus() == 560)
end)

test('Terrorblade Demon Zeal rank passive respects Break and illusions', function()
    local tb = create_mock_unit('npc_dota_hero_terrorblade', 2, Vector(0, 0, 0))
    local ability = enfos_tb_demon_zeal()
    ability.GetSpecialValueFor = function(_, k) return ({ bonus_as=100, bonus_ms=50 })[k] or 0 end
    local mod = modifier_enfos_tb_demon_zeal()
    mod.GetParent = function() return tb end
    mod.GetAbility = function() return ability end
    assert(mod:GetModifierAttackSpeedBonus_Constant() == 100 and mod:GetModifierMoveSpeedBonus_Constant() == 50)
    tb.PassivesDisabled = function() return true end
    assert(mod:GetModifierAttackSpeedBonus_Constant() == 0 and mod:GetModifierMoveSpeedBonus_Constant() == 0)
    tb.PassivesDisabled = function() return false end
    tb.IsIllusion = function() return true end
    assert(mod:GetModifierAttackSpeedBonus_Constant() == 0 and mod:GetModifierMoveSpeedBonus_Constant() == 0)
end)

test('Storm Static Remnant uses rank values and triggers on nearby enemies', function()
    applied_damages = {}
    local storm = create_mock_unit('npc_dota_hero_storm_spirit', 2, Vector(0, 0, 0))
    storm.intellect = 100
    local creep = create_mock_unit('creep_storm', 3, Vector(100, 0, 0), 2000)
    mock_world_units = { storm, creep }
    local ability = enfos_storm_static_remnant()
    ability.GetCaster = function() return storm end
    ability.GetSpecialValueFor = function(_, k) return ({ duration=12, trigger_radius=330, damage=390 })[k] or 0 end
    ability:OnSpellStart()
    assert(#applied_damages == 1 and applied_damages[1].damage == 510 and applied_damages[1].damage_type == DAMAGE_TYPE_MAGICAL)
end)

test('Storm Electric Vortex respects spell block and applies ranked boss stun', function()
    applied_damages = {}
    local storm = create_mock_unit('npc_dota_hero_storm_spirit', 2, Vector(0, 0, 0))
    local boss = create_mock_unit('enfos_boss_storm', 3, Vector(100, 0, 0), 10000)
    boss.is_boss = true
    mock_world_units = { storm, boss }
    local ability = enfos_storm_electric_vortex()
    ability.GetCaster = function() return storm end
    ability.GetCursorTarget = function() return boss end
    ability.GetSpecialValueFor = function(_, k) return ({ radius=375, duration=2.6, boss_duration=0.8 })[k] or 0 end
    ability:OnSpellStart()
    local stun = boss:FindModifierByName('modifier_enfos_storm_electric_vortex_debuff')
    assert(stun and stun.params.duration == 0.8 and #applied_damages == 0)
    boss.TriggerSpellAbsorb = function() return true end
    ability:OnSpellStart()
    assert(boss:FindModifierByName('modifier_enfos_storm_electric_vortex_debuff') == stun)
end)

test('Storm Overload is one charged, ranked proc and expires after timeout', function()
    applied_damages = {}
    local storm = create_mock_unit('npc_dota_hero_storm_spirit', 2, Vector(0, 0, 0))
    storm.intellect = 100
    local creep = create_mock_unit('creep_storm', 3, Vector(50, 0, 0), 1000)
    mock_world_units = { storm, creep }
    local ability = enfos_storm_overload()
    ability.GetSpecialValueFor = function(_, k) return ({ bonus_damage=190, radius=360, slow_duration=1.3, slow_pct=55 })[k] or 0 end
    local mod = modifier_enfos_storm_overload_passive()
    mod.GetParent = function() return storm end
    mod.GetAbility = function() return ability end
    mod:OnAbilityFullyCast({ unit=storm, ability=enfos_storm_static_remnant() })
    local ally = create_mock_unit('ally_storm', 2, Vector(30, 0, 0), 1000)
    mod:OnAttackLanded({ attacker=storm, target=ally })
    assert(mod.charged, 'Attacking a friendly unit must not consume the enemy proc')
    mod:OnAttackLanded({ attacker=storm, target=creep })
    assert(#applied_damages == 1 and applied_damages[1].damage == 250)
    local slow = creep:FindModifierByName('modifier_enfos_storm_overload_slow')
    assert(slow and slow.params.duration == 1.3 and slow:GetModifierMoveSpeedBonus_Percentage() == -55)
end)

test('Storm Ball Lightning spends distance mana and caps boss damage', function()
    applied_damages = {}
    local storm = create_mock_unit('npc_dota_hero_storm_spirit', 2, Vector(0, 0, 0))
    storm.intellect = 100
    local boss = create_mock_unit('enfos_boss_storm', 3, Vector(800, 0, 0), 10000)
    boss.is_boss = true
    mock_world_units = { storm, boss }
    local ability = enfos_storm_ball_lightning()
    ability.GetCaster = function() return storm end
    ability.GetCursorPosition = function() return Vector(800, 0, 0) end
    ability.GetSpecialValueFor = function(_, k) return ({ damage_per_100=80, radius=330, mana_per_100=9, boss_damage_cap_pct=3, max_distance=1800 })[k] or 0 end
    ability:OnSpellStart()
    assert(storm.mana == 428 and storm:GetAbsOrigin().x == 800)
    assert(#applied_damages == 1 and applied_damages[1].damage == 300)
end)

test('Storm Galvanic Core rank passive respects Break and illusions', function()
    local storm = create_mock_unit('npc_dota_hero_storm_spirit', 2, Vector(0, 0, 0))
    local ability = enfos_storm_galvanic_core()
    ability.GetSpecialValueFor = function(_, k) return ({ mana_regen=4.2, bonus_int=24 })[k] or 0 end
    local mod = modifier_enfos_storm_galvanic_core_passive()
    mod.GetParent = function() return storm end
    mod.GetAbility = function() return ability end
    assert(mod:GetModifierConstantManaRegen() == 4.2 and mod:GetModifierBonusStats_Intellect() == 24)
    storm.PassivesDisabled = function() return true end
    assert(mod:GetModifierConstantManaRegen() == 0 and mod:GetModifierBonusStats_Intellect() == 0)
end)

test('Leshrac Split Earth deals ranked magic damage and reduces boss stun', function()
    applied_damages = {}
    local leshrac = create_mock_unit('npc_dota_hero_leshrac', 2, Vector(0, 0, 0))
    leshrac.intellect = 100
    local boss = create_mock_unit('enfos_boss_lesh', 3, Vector(100, 0, 0), 10000)
    boss.is_boss = true
    mock_world_units = { leshrac, boss }
    local ability = enfos_leshrac_split_earth()
    ability.GetCaster = function() return leshrac end
    ability.GetCursorPosition = function() return Vector(100, 0, 0) end
    ability.GetSpecialValueFor = function(_, k) return ({ radius=310, damage=450, stun_duration=2.2 })[k] or 0 end
    ability:OnSpellStart()
    local stun = boss:FindModifierByName('modifier_generic_stunned_lua')
    assert(stun and math.abs(stun.params.duration - 0.88) < 0.001)
    assert(#applied_damages == 1 and applied_damages[1].damage == 540)
end)

test('Leshrac Diabolic Edict uses ranked explosion count, radius and pure damage', function()
    applied_damages = {}
    local leshrac = create_mock_unit('npc_dota_hero_leshrac', 2, Vector(0, 0, 0))
    leshrac.intellect = 100
    local creep = create_mock_unit('creep_lesh', 3, Vector(50, 0, 0), 1000)
    mock_world_units = { leshrac, creep }
    local ability = enfos_leshrac_diabolic_edict()
    ability.GetCaster = function() return leshrac end
    ability.GetSpecialValueFor = function(_, k) return ({ num_explosions=40, radius=650, damage_per_explosion=48 })[k] or 0 end
    ability:OnSpellStart()
    local mod = leshrac:FindModifierByName('modifier_enfos_leshrac_diabolic_edict')
    assert(mod and mod.params.duration == 10)
    mod:OnIntervalThink()
    assert(#applied_damages == 1 and applied_damages[1].damage == 63 and applied_damages[1].damage_type == DAMAGE_TYPE_PURE)
end)

test('Leshrac Lightning Storm chains ranked hits, slows targets and caps boss damage', function()
    applied_damages = {}
    local leshrac = create_mock_unit('npc_dota_hero_leshrac', 2, Vector(0, 0, 0))
    leshrac.intellect = 100
    local boss = create_mock_unit('enfos_boss_lesh', 3, Vector(100, 0, 0), 10000)
    boss.is_boss = true
    local creep = create_mock_unit('creep_lesh', 3, Vector(200, 0, 0), 1000)
    mock_world_units = { leshrac, boss, creep }
    local ability = enfos_leshrac_lightning_storm()
    ability.GetCaster = function() return leshrac end
    ability.GetCursorTarget = function() return boss end
    ability.GetSpecialValueFor = function(_, k) return ({ jump_count=2, damage=360, slow_pct=42 })[k] or 0 end
    ability:OnSpellStart()
    assert(#applied_damages == 2 and applied_damages[1].damage == 300 and applied_damages[2].damage == 440)
    assert(boss:FindModifierByName('modifier_enfos_leshrac_lightning_slow').params.duration == 0.25)
    assert(creep:FindModifierByName('modifier_enfos_leshrac_lightning_slow').params.duration == 0.5)
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

test('Leshrac Defilement lifesteals only from enemy ability damage and is disabled by Break/illusions', function()
    local leshrac = create_mock_unit('npc_dota_hero_leshrac', 2, Vector(0, 0, 0))
    leshrac.hp = 300
    local enemy = create_mock_unit('creep_lesh_defilement', 3, Vector(100, 0, 0), 1000)
    local ability = enfos_leshrac_defilement()
    ability.GetSpecialValueFor = function(_, key) return key == 'spell_lifesteal' and 25 or 0 end
    local mod = modifier_enfos_leshrac_defilement()
    mod.GetParent = function() return leshrac end
    mod.GetAbility = function() return ability end
    local event = { attacker=leshrac, inflictor=ability, unit=enemy, damage=100, damage_flags=0 }

    mod:OnTakeDamage(event)
    assert(leshrac.hp == 325, 'A spell damage event heals by the configured percentage')
    event.inflictor = nil
    mod:OnTakeDamage(event)
    assert(leshrac.hp == 325, 'An attack without an ability inflictor does not trigger spell lifesteal')
    event.inflictor = ability
    event.damage_flags = DOTA_DAMAGE_FLAG_REFLECTION
    mod:OnTakeDamage(event)
    assert(leshrac.hp == 325, 'Reflected damage does not trigger spell lifesteal')
    event.damage_flags = 0
    leshrac.PassivesDisabled = function() return true end
    mod:OnTakeDamage(event)
    assert(leshrac.hp == 325, 'Break disables spell lifesteal')
    leshrac.PassivesDisabled = function() return false end
    leshrac.IsIllusion = function() return true end
    mod:OnTakeDamage(event)
    assert(leshrac.hp == 325, 'Illusions do not receive Defilement healing')
end)

test('Puck Illusory Orb falls back to facing for a zero-length aim and applies ranked impact damage', function()
    applied_damages = {}
    local puck = create_mock_unit('npc_dota_hero_puck', 2, Vector(0, 0, 0))
    puck.forward = Vector(0, 1, 0)
    puck.intellect = 100
    local creep = create_mock_unit('creep_puck', 3, Vector(800, 0, 0), 2000)
    mock_world_units = { puck, creep }
    local ability = enfos_puck_illusory_orb()
    ability.GetCaster = function() return puck end
    ability.GetCursorPosition = function() return puck:GetAbsOrigin() end
    ability.GetSpecialValueFor = function(_, k) return ({ speed=1100, radius=280, damage=500 })[k] or 0 end
    ability:OnSpellStart()
    assert(last_linear_projectile and last_linear_projectile.fDistance == 1500 and last_linear_projectile.fStartRadius == 280)
    assert(last_linear_projectile.vVelocity.x == 0 and last_linear_projectile.vVelocity.y == 1100,
        'A zero-length cursor direction must use the caster facing vector')
    assert(#applied_damages == 0, 'Orb deals damage on projectile impact, not cast')
    ability:OnProjectileHit_ExtraData(creep, creep:GetAbsOrigin(), {})
    assert(#applied_damages == 1 and applied_damages[1].damage == 585)
end)

test('Puck Waning Rift damages and silences at target point without teleporting', function()
    applied_damages = {}
    local puck = create_mock_unit('npc_dota_hero_puck', 2, Vector(0, 0, 0))
    puck.intellect = 100
    local creep = create_mock_unit('creep_puck', 3, Vector(100, 0, 0), 1000)
    mock_world_units = { puck, creep }
    local ability = enfos_puck_waning_rift()
    ability.GetCaster = function() return puck end
    ability.GetCursorPosition = function() return Vector(100, 0, 0) end
    ability.GetSpecialValueFor = function(_, k) return ({ radius=480, damage=370, silence_duration=4.2 })[k] or 0 end
    ability:OnSpellStart()
    assert(puck:GetAbsOrigin().x == 0)
    assert(#applied_damages == 1 and applied_damages[1].damage == 445)
    assert(creep:FindModifierByName('modifier_enfos_puck_silence').params.duration == 4.2)
end)

test('Puck Phase Shift grants ranked invulnerability and out-of-game state', function()
    local puck = create_mock_unit('npc_dota_hero_puck', 2, Vector(0, 0, 0))
    local ability = enfos_puck_phase_shift()
    ability.GetCaster = function() return puck end
    ability.GetSpecialValueFor = function(_, key) return key == 'duration' and 3.75 or 0 end
    ability:OnSpellStart()
    local modifier = puck:FindModifierByName('modifier_enfos_puck_phase_shift')
    local states = modifier:CheckState()
    assert(modifier and modifier.params.duration == 3.75)
    assert(states[MODIFIER_STATE_INVULNERABLE] and states[MODIFIER_STATE_OUT_OF_GAME])
end)

test('Invoker Sun Strike deals pure AoE damage after its configured warning delay', function()
    local previous_game_rules = GameRules
    local callback, callback_delay
    GameRules = { GetGameModeEntity = function()
        return { SetContextThink = function(_, name, fn, delay) callback, callback_delay = fn, delay end }
    end }
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
        if k == 'delay' then return 1.5 end
        return 0
    end

    ab:OnSpellStart()
    assert(#applied_damages == 0 and callback_delay == 1.5,
        'Sun Strike must wait for its configured warning before dealing damage')
    assert(callback and callback() == nil)
    -- dmg = 500 + (120 * 1.8 = 216) = 716 pure
    assert(#applied_damages == 1)
    assert(applied_damages[1].damage == 716 and applied_damages[1].damage_type == DAMAGE_TYPE_PURE)
    GameRules = previous_game_rules
end)

test('Invoker Chaos Meteor delays impact and caps boss impact/burn damage', function()
    local previous_game_rules = GameRules
    local callback, callback_delay
    GameRules = { GetGameModeEntity = function()
        return { SetContextThink = function(_, name, fn, delay) callback, callback_delay = fn, delay end }
    end }
    applied_damages = {}
    local invoker = create_mock_unit('npc_dota_hero_invoker', 2, Vector(0, 0, 0))
    invoker.intellect = 100
    local creep = create_mock_unit('creep_invo_meteor', 3, Vector(100, 0, 0), 1000)
    local boss = create_mock_unit('enfos_boss_invo_meteor', 3, Vector(150, 0, 0), 2000)
    mock_world_units = { invoker, creep, boss }
    local ability = enfos_invoker_chaos_meteor()
    ability.GetCaster = function() return invoker end
    ability.GetCursorPosition = function() return Vector(100, 0, 0) end
    ability.GetSpecialValueFor = function(_, key)
        return ({ radius=300, impact_damage=300, impact_delay=1.3, burn_duration=3,
            burn_dps=100, burn_tick_interval=0.5, burn_int_factor=0.1,
            boss_impact_cap_pct=10, boss_burn_tick_cap_pct=1 })[key] or 0
    end

    ability:OnSpellStart()
    assert(#applied_damages == 0 and callback_delay == 1.3,
        'Meteor impact damage waits for the falling warning')
    assert(callback and callback() == nil)
    assert(#applied_damages == 2 and applied_damages[1].damage == 420 and applied_damages[2].damage == 200)
    local burn = boss:FindModifierByName('modifier_enfos_invoker_meteor_burn')
    assert(burn and burn.params.duration == 3)
    burn.StartIntervalThink = function(self, interval) self.interval = interval end
    burn:OnCreated()
    burn:OnIntervalThink()
    assert(burn.interval == 0.5 and applied_damages[3].damage == 20,
        'Boss burn tick is capped at one percent max health')
    local creep_burn = creep:FindModifierByName('modifier_enfos_invoker_meteor_burn')
    creep_burn:OnIntervalThink()
    assert(applied_damages[4].damage == 60, 'Creep burn includes configured DPS interval and Intelligence scaling')
    GameRules = previous_game_rules
end)

test('Invoker EMP delays damage and mana burn until its configured discharge', function()
    local previous_game_rules = GameRules
    local callback, callback_delay
    GameRules = { GetGameModeEntity = function()
        return { SetContextThink = function(_, name, fn, delay) callback, callback_delay = fn, delay end }
    end }
    applied_damages = {}
    local invoker = create_mock_unit('npc_dota_hero_invoker', 2, Vector(0, 0, 0))
    invoker.intellect = 100
    invoker.mana = 0
    local creep = create_mock_unit('creep_invo_emp', 3, Vector(100, 0, 0), 1000)
    creep.mana = 500
    creep.GetMana = function(self) return self.mana end
    creep.SpendMana = function(self, amount) self.mana = math.max(0, self.mana - amount) end
    invoker.GiveMana = function(self, amount) self.mana = self.mana + amount end
    mock_world_units = { invoker, creep }

    local ab = enfos_invoker_emp()
    ab.GetCaster = function() return invoker end
    ab.GetCursorPosition = function() return Vector(100, 0, 0) end
    ab.GetSpecialValueFor = function(_, k)
        return ({ radius = 600, damage = 300, mana_burn = 150, delay = 2.5 })[k] or 0
    end
    ab:OnSpellStart()
    assert(#applied_damages == 0 and creep.mana == 500 and invoker.mana == 0,
        'EMP must not deal damage or burn mana before discharge')
    assert(callback_delay == 2.5 and callback and callback() == nil)
    assert(#applied_damages == 1 and applied_damages[1].damage == 450)
    assert(creep.mana == 350 and invoker.mana == 150)
    GameRules = previous_game_rules
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
    assert(applied_damages[2].damage == 400, 'Boss coil damage is capped at eight percent of max health')

    local mod_creep = creep:FindModifierByName('modifier_generic_stunned_lua')
    local mod_boss = boss:FindModifierByName('modifier_generic_stunned_lua')
    assert(mod_creep.params.duration == 3.0, 'Creep takes full 3.0s stun')
    assert(math.abs(mod_boss.params.duration - 1.05) < 0.01, 'Boss stun reduced by 65%')
end)

test('Jakiro Ice Path delays damage and control until the configured path warning', function()
    local previous_game_rules = GameRules
    local callback, callback_delay
    GameRules = { GetGameModeEntity = function()
        return { SetContextThink = function(_, name, fn, delay) callback, callback_delay = fn, delay end }
    end }
    applied_damages = {}
    local jakiro = create_mock_unit('npc_dota_hero_jakiro', 2, Vector(0, 0, 0))
    jakiro.intellect = 100
    local creep = create_mock_unit('creep_jak_path', 3, Vector(100, 0, 0), 1000)
    local boss = create_mock_unit('enfos_boss_jak_path', 3, Vector(200, 0, 0), 5000)
    boss.is_boss = true
    mock_world_units = { jakiro, creep, boss }

    local ab = enfos_jakiro_ice_path()
    ab.GetCaster = function() return jakiro end
    ab.GetCursorPosition = function() return Vector(800, 0, 0) end
    ab.GetSpecialValueFor = function(_, k)
        return ({ damage = 200, stun_duration = 2, path_delay = 0.5 })[k] or 0
    end
    ab:OnSpellStart()
    assert(#applied_damages == 0 and callback_delay == 0.5,
        'Ice Path damage and stun must wait for its warning delay')
    jakiro:SetAbsOrigin(Vector(1000, 0, 0))
    assert(callback and callback() == nil)
    assert(#applied_damages == 2 and applied_damages[1].damage == 260)
    assert(creep:FindModifierByName('modifier_generic_stunned_lua').params.duration == 2)
    assert(math.abs(boss:FindModifierByName('modifier_generic_stunned_lua').params.duration - 0.7) < 0.01)
    GameRules = previous_game_rules
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

test('Jakiro Double Trouble stats stop under Break and do not transfer to illusions', function()
    local jakiro = create_mock_unit('npc_dota_hero_jakiro', 2, Vector(0, 0, 0))
    local ability = enfos_jakiro_double_trouble()
    ability.GetSpecialValueFor = function(_, key)
        if key == 'bonus_int' then return 38 end
        if key == 'bonus_as' then return 57 end
        return 0
    end
    local modifier = modifier_enfos_jakiro_double_trouble()
    modifier.GetParent = function() return jakiro end
    modifier.GetAbility = function() return ability end
    assert(modifier:GetModifierBonusStats_Intellect() == 38)
    assert(modifier:GetModifierAttackSpeedBonus_Constant() == 57)
    jakiro.PassivesDisabled = function() return true end
    assert(modifier:GetModifierBonusStats_Intellect() == 0 and modifier:GetModifierAttackSpeedBonus_Constant() == 0,
        'Break should disable both Double Trouble bonuses')
    jakiro.PassivesDisabled = function() return false end
    jakiro.IsIllusion = function() return true end
    assert(modifier:GetModifierBonusStats_Intellect() == 0 and modifier:GetModifierAttackSpeedBonus_Constant() == 0,
        'Double Trouble should not be duplicated by illusions')
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

test('Vengeful Spirit Vengeance Aura stops buffing allies while its source is broken', function()
    local venge = create_mock_unit('npc_dota_hero_vengefulspirit', 2, Vector(0, 0, 0))
    local aura = modifier_enfos_vs_vengeance_aura()
    aura.GetParent = function() return venge end
    venge.PassivesDisabled = function() return false end
    assert(aura:IsAura() == true, 'Vengeance Aura should be active while passives are enabled')
    venge.PassivesDisabled = function() return true end
    assert(aura:IsAura() == false, 'Break must disable the source aura')
end)

test('Lich Chain Frost slows targets and never repeats a bounce on an already hit enemy', function()
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
        if k == 'slow_pct' then return 50 end
        if k == 'slow_attack_pct' then return 50 end
        if k == 'slow_duration' then return 2.5 end
        return 0
    end

    ab:OnSpellStart()
    -- dmg per hit = 400 + (100 * 1.0 = 100) = 500
    assert(#applied_damages == 2, 'Chain Frost visits each available enemy at most once')
    assert(applied_damages[1].damage == 500)
    assert(applied_damages[2].damage == 500)
    local slow1 = creep1:FindModifierByName('modifier_enfos_lich_chain_frost_slow')
    local slow2 = creep2:FindModifierByName('modifier_enfos_lich_chain_frost_slow')
    assert(slow1 and slow1.params.duration == 2.5 and slow1:GetModifierMoveSpeedBonus_Percentage() == -50)
    assert(slow1:GetModifierAttackSpeedBonus_Constant() == -50)
    assert(slow2 and slow2.params.duration == 2.5)
end)

test('Lich Ice Aura stops benefiting allies while its source is broken', function()
    local lich = create_mock_unit('npc_dota_hero_lich', 2, Vector(0, 0, 0))
    local aura = modifier_enfos_lich_ice_aura()
    aura.GetParent = function() return lich end
    lich.PassivesDisabled = function() return false end
    assert(aura:IsAura() == true, 'Lich Ice Aura should be active while passives are enabled')
    lich.PassivesDisabled = function() return true end
    assert(aura:IsAura() == false, 'Break must disable the source aura')
end)

test('Lich Sinister Gaze disables its target and ends channel when target dies', function()
    local lich = create_mock_unit('npc_dota_hero_lich', 2, Vector(0, 0, 0))
    local target = create_mock_unit('lich_gaze_target', 3, Vector(100, 0, 0))
    local boss = create_mock_unit('enfos_boss_lich_gaze', 3, Vector(100, 0, 0))
    target.alive = false
    local ended = false
    local ability = enfos_lich_sinister_gaze()
    ability.GetSpecialValueFor = function(_, key) return key == 'duration' and 3.8 or 0 end
    ability.GetCursorTarget = function() return target end
    assert(ability:GetChannelTime() == 3.8, 'normal channel should match the ranked effect duration')
    ability.GetCursorTarget = function() return boss end
    assert(math.abs(ability:GetChannelTime() - 1.33) < 0.001,
        'boss channel should use the same shortened duration as its control effect')
    ability.EndChannel = function(_, interrupted) ended = interrupted == true end
    local gaze = setmetatable({
        GetParent = function() return target end,
        GetCaster = function() return lich end,
        GetAbility = function() return ability end,
        Destroy = function(self) self.destroyed = true end,
    }, modifier_enfos_lich_sinister_gaze_debuff)
    assert(gaze:CheckState()[MODIFIER_STATE_STUNNED] == true,
        'Sinister Gaze must prevent the controlled target from acting')
    gaze:OnIntervalThink()
    assert(ended, 'a dead target should interrupt the actual ability channel')
end)

test('Lich Frost Blast slows the primary target and secondary enemies', function()
    local lich = create_mock_unit('npc_dota_hero_lich', 2, Vector(0, 0, 0))
    lich.intellect = 100
    local target = create_mock_unit('lich_frost_blast_target', 3, Vector(100, 0, 0), 1000)
    local splash = create_mock_unit('lich_frost_blast_splash', 3, Vector(150, 0, 0), 1000)
    mock_world_units = { lich, target, splash }
    local ability = enfos_lich_frost_blast()
    ability.GetCaster = function() return lich end
    ability.GetCursorTarget = function() return target end
    ability.GetSpecialValueFor = function(_, key)
        return ({ target_damage = 100, radius_damage = 80, radius = 200,
            duration = 4, slow_pct = 35, slow_attack = 40 })[key] or 0
    end
    ability:OnSpellStart()
    local target_slow = target:FindModifierByName('modifier_enfos_lich_frost_blast_slow')
    local splash_slow = splash:FindModifierByName('modifier_enfos_lich_frost_blast_slow')
    assert(target_slow and target_slow.params.duration == 4,
        'the primary Frost Blast target must receive the slow')
    assert(splash_slow and splash_slow.params.duration == 4)
    assert(target_slow:GetModifierMoveSpeedBonus_Percentage() == -35)
    assert(target_slow:GetModifierAttackSpeedBonus_Constant() == -40)
end)

test('Sven Warcry barrier absorbs, refreshes and reflects only physical damage with Shard',function()
 local sven=create_mock_unit('npc_dota_hero_sven',2,Vector(0,0,0));sven.strength=100;sven.max_hp=2000
 local enemy=create_mock_unit('enfos_creep_melee',4,Vector(100,0,0))
 local a=bulwark_challenge();a.GetCaster=function() return sven end
 local values={barrier_hp=150,bonus_armor=10,bonus_ms_pct=20}
 a.GetSpecialValueFor=function(_,k) return values[k] or 0 end
 local m=sven:AddNewModifier(sven,a,'modifier_enfos_pve_warcry',{})
 m.SetStackCount=function(_,v) m.stacks=v end;m.GetStackCount=function() return m.stacks end
 m:OnCreated();assert(m.barrier==300 and m:GetModifierPhysicalArmorBonus()==10 and m:GetModifierMoveSpeedBonus_Percentage()==20)
 assert(m:GetModifierTotal_ConstantBlock({damage=120})==120 and m.barrier==180 and m:OnTooltip2()==180)
 assert(m:GetModifierTotal_ConstantBlock({damage=200})==180 and m.barrier==0)
 sven.modifiers.modifier_item_aghanims_shard={};m:OnRefresh();assert(m.barrier==800)
 applied_damages={};m:OnTakeDamage({unit=sven,attacker=enemy,damage=100,damage_type=DAMAGE_TYPE_MAGICAL})
 assert(#applied_damages==0)
 m:OnTakeDamage({unit=sven,attacker=enemy,damage=100,damage_type=DAMAGE_TYPE_PHYSICAL});assert(#applied_damages==1 and applied_damages[1].damage==40)
 m:OnTakeDamage({unit=sven,attacker=enemy,damage=100,damage_type=DAMAGE_TYPE_PHYSICAL,damage_flags=DOTA_DAMAGE_FLAG_REFLECTION});assert(#applied_damages==1)
 local friend=create_mock_unit('npc_dota_hero_axe',2,Vector(100,0,0))
 m:OnTakeDamage({unit=sven,attacker=friend,damage=100,damage_type=DAMAGE_TYPE_PHYSICAL})
 enemy.alive=false
 m:OnTakeDamage({unit=sven,attacker=enemy,damage=100,damage_type=DAMAGE_TYPE_PHYSICAL})
 assert(#applied_damages==1, 'Warcry must not reflect onto allies or dead attackers')
end)
test('Sven Warcry cast owns a head-bound native burst and precaches its resources',function()
 local c=create_mock_unit('npc_dota_hero_sven',2,Vector(0,0,0));mock_world_units={c}
 local a=bulwark_challenge();a.GetCaster=function() return c end
 a.GetSpecialValueFor=function(_,k) return k=='radius' and 500 or 3 end
 local oldCreate,oldEnt,oldRelease=ParticleManager.CreateParticle,ParticleManager.SetParticleControlEnt,ParticleManager.ReleaseParticleIndex
 local oldPrecache,oldAttach=PrecacheResource,PATTACH_POINT_FOLLOW
 local created,bound,released,resources=0,0,0,{}
 PATTACH_POINT_FOLLOW='mock_point_follow'
 ParticleManager.CreateParticle=function(_,path,attach,owner)
  assert(path=='particles/units/heroes/hero_sven/sven_spell_warcry.vpcf' and owner==c)
  created=created+1;return 71
 end
 ParticleManager.SetParticleControlEnt=function(_,id,cp,owner,attach,name)
  assert(id==71 and cp==2 and owner==c and attach==PATTACH_POINT_FOLLOW and name=='attach_head');bound=bound+1
 end
 ParticleManager.ReleaseParticleIndex=function(_,id) assert(id==71);released=released+1 end
 PrecacheResource=function(kind,path) resources[path]=kind end
 a:Precache({});a:OnSpellStart()
 ParticleManager.CreateParticle,ParticleManager.SetParticleControlEnt,ParticleManager.ReleaseParticleIndex=oldCreate,oldEnt,oldRelease
 PrecacheResource,PATTACH_POINT_FOLLOW=oldPrecache,oldAttach
 assert(created==1 and bound==1 and released==1, 'One self-ending native cast burst, no persistent helper duplicate')
 assert(resources['particles/units/heroes/hero_sven/sven_spell_warcry.vpcf']=='particle')
 assert(resources['soundevents/game_sounds_heroes/game_sounds_sven.vsndevts']=='soundfile')
end)
test('Sven Warcry announces each recipient barrier and Gods Strength resists dispel',function()
 local sven=create_mock_unit('npc_dota_hero_sven',2,Vector(0,0,0))
 local ally=create_mock_unit('npc_dota_hero_axe',2,Vector(100,0,0))
 local a=bulwark_challenge();a.GetSpecialValueFor=function(_,k) return k=='barrier_hp' and 100 or 0 end
 local m=ally:AddNewModifier(sven,a,'modifier_enfos_pve_warcry',{})
 local oldMessage,oldAlert=SendOverheadEventMessage,OVERHEAD_ALERT_BLOCK
 local recipient;OVERHEAD_ALERT_BLOCK=1
 SendOverheadEventMessage=function(_,_,unit) recipient=unit end
 m:OnCreated()
 SendOverheadEventMessage,OVERHEAD_ALERT_BLOCK=oldMessage,oldAlert
 assert(recipient==ally, 'Show the ally barrier on the ally, not repeatedly on Sven')
 assert(modifier_bulwark_fortress:IsPurgable()==false, 'Native Gods Strength is non-dispellable')
end)
test('Sven taunt starts an attack order and releases it on expiry',function()
 local sven=create_mock_unit('npc_dota_hero_sven',2,Vector(0,0,0));local enemy=create_mock_unit('enfos_creep_melee',4,Vector(100,0,0))
 enemy.SetForceAttackTarget=function(_,u) enemy.forced=u end;enemy.GetForceAttackTarget=function() return enemy.forced end;enemy.MoveToTargetToAttack=function(_,u) enemy.ordered=u end
 local m=enemy:AddNewModifier(sven,{},'modifier_enfos_pve_taunt',{})
 m:OnCreated();assert(enemy.forced==sven and enemy.ordered==sven);m:OnDestroy();assert(enemy.forced==nil)
end)
test('Sven innate has no second cleave and Scepter ally modifier is registered',function()
 assert(modifier_bulwark_unbreakable.OnAttackLanded==nil)
 local found=false;for _,n in ipairs(ENFOS_PVE_MODIFIER_LIST) do if n=='modifier_bulwark_fortress_scepter_ally' then found=true end end;assert(found)
 local sven=create_mock_unit('npc_dota_hero_sven',2,Vector(0,0,0));sven.max_hp=1000;sven.hp=399
 sven.GetHealthPercent=function(self) return self.hp/self.max_hp*100 end
  local values={bonus_hp_regen=15,bonus_max_hp=100,status_resistance=10}
  local a=bulwark_unbreakable();a.GetSpecialValueFor=function(_,k) return values[k] or 0 end
  local m=sven:AddNewModifier(sven,a,'modifier_bulwark_unbreakable',{});assert(m:GetModifierConstantHealthRegen()==15)
  assert(m:GetModifierExtraHealthBonus()==100 and m:GetModifierStatusResistanceStacking()==10)
 sven.modifiers.modifier_item_aghanims_shard={};assert(m:GetModifierConstantHealthRegen()==30)
 sven.hp=400;assert(m:GetModifierConstantHealthRegen()==15)
  sven.PassivesDisabled=function() return true end
  assert(m:GetModifierConstantHealthRegen()==0 and m:GetModifierExtraHealthBonus()==0 and m:GetModifierStatusResistanceStacking()==0)
end)
test('Sven Gods Strength uses configured pulse and Scepter values',function()
 local sven=create_mock_unit('npc_dota_hero_sven',2,Vector(0,0,0));sven.strength=100
 sven.GetStrength=function(self) return self.strength end
 local enemy=create_mock_unit('enfos_creep_melee',4,Vector(100,0,0));mock_world_units={sven,enemy}
 local values={shockwave_interval=1.5,shockwave_damage=220,shockwave_strength_factor=1,radius=450,
  duration=21,scepter_duration_bonus=5,scepter_status_resistance=50,scepter_ally_radius=900,
  scepter_ally_duration=1.8,scepter_ally_bonus_damage_pct=50,scepter_ally_bonus_armor=10,move_speed_pct=20}
 local a=bulwark_fortress();a.GetCaster=function() return sven end
 a.GetSpecialValueFor=function(_,k) return values[k] or 0 end
 local modifier=sven:AddNewModifier(sven,a,'modifier_bulwark_fortress',{})
 modifier.StartIntervalThink=function(_,interval) modifier.interval=interval end
 modifier:OnCreated();assert(modifier.interval==1.5)
 applied_damages={};modifier:OnIntervalThink()
 assert(#applied_damages==1 and applied_damages[1].damage==320)
 assert(modifier:GetModifierStatusResistanceStacking()==0)
 sven.HasScepter=function() return true end
 assert(modifier:GetModifierStatusResistanceStacking()==50)
 local ally=create_mock_unit('npc_dota_hero_axe',2,Vector(200,0,0));ally.IsHero=function() return true end
 mock_world_units={sven,ally};modifier:OnIntervalThink()
 local allyModifier=ally.modifiers.modifier_bulwark_fortress_scepter_ally
 assert(allyModifier and allyModifier:GetModifierBaseDamageOutgoing_Percentage()==50 and allyModifier:GetModifierPhysicalArmorBonus()==10)
end)

test('Jakiro Macropyre ticks along its cast line and caps total boss damage per cast', function()
    applied_damages = {}
    local jakiro = create_mock_unit('npc_dota_hero_jakiro', 2, Vector(0, 0, 0))
    local creep = create_mock_unit('macropyre_creep', 3, Vector(500, 0, 0), 5000)
    local boss = create_mock_unit('enfos_boss_macropyre', 3, Vector(650, 40, 0), 5000)
    local off_line = create_mock_unit('macropyre_off_line', 3, Vector(500, 500, 0), 5000)
    mock_world_units = { jakiro, creep, boss, off_line }
    local ability = enfos_jakiro_macropyre()
    ability.GetCaster = function() return jakiro end
    ability.GetCursorPosition = function() return Vector(1200, 0, 0) end
    ability.GetSpecialValueFor = function(_, key)
        if key == 'length' then return 1200 end
        if key == 'duration' then return 4 end
        if key == 'damage_per_sec' then return 1000 end
        return 0
    end
    ability:OnSpellStart()
    local thinker = ability.enfosGroundEffects[1]
    local zone = thinker.modifiers.modifier_enfos_jakiro_macropyre_zone
    assert(zone and zone.interval == 0.5)
    for _ = 1, 3 do zone:OnIntervalThink() end
    local creep_hits, boss_total, off_line_hits = 0, 0, 0
    for _, hit in ipairs(applied_damages) do
        if hit.victim == creep then creep_hits = creep_hits + 1 end
        if hit.victim == boss then boss_total = boss_total + hit.damage end
        if hit.victim == off_line then off_line_hits = off_line_hits + 1 end
    end
    assert(creep_hits == 4, 'Macropyre should apply repeated burn ticks to enemies on its line')
    assert(boss_total <= 500, 'one cast should cap boss damage at 10% max health')
    assert(off_line_hits == 0, 'enemies outside the line should not be damaged')
end)

test('Vengeful Wave of Terror falls back to facing for a zero-length aim and hits only its line', function()
    applied_damages = {}
    local vengeful = create_mock_unit('npc_dota_hero_vengefulspirit', 2, Vector(0, 0, 0))
    vengeful.forward = Vector(1, 0, 0)
    local in_line = create_mock_unit('vengeful_in_line', 3, Vector(700, 0, 0), 1000)
    local off_line = create_mock_unit('vengeful_off_line', 3, Vector(700, 400, 0), 1000)
    mock_world_units = { vengeful, in_line, off_line }
    local ability = enfos_vs_wave_of_terror()
    ability.GetCaster = function() return vengeful end
    ability.GetCursorPosition = function() return vengeful:GetAbsOrigin() end
    ability.GetSpecialValueFor = function(_, key)
        if key == 'damage' then return 100 end
        if key == 'duration' then return 8 end
        if key == 'armor_reduction' then return 4 end
        return 0
    end
    ability:OnSpellStart()
    assert(#applied_damages == 1 and applied_damages[1].victim == in_line)
end)

test('Shadow Fiend passives honor Break and reject illusion death triggers', function()
    local sf = create_mock_unit('npc_dota_hero_nevermore', 2, Vector(0, 0, 0))
    local creep = create_mock_unit('enfos_creep_melee', 3, Vector(100, 0, 0))
    local ability = enfos_sf_necromastery()
    ability.GetSpecialValueFor = function(_, key)
        if key == 'damage_per_soul' then return 4 end
        if key == 'max_souls' then return 10 end
        return 0
    end
    local modifier = modifier_enfos_sf_necromastery_passive()
    modifier.GetParent = function() return sf end
    modifier.GetAbility = function() return ability end
    modifier.stacks = 3
    modifier.GetStackCount = function(self) return self.stacks end
    modifier.SetStackCount = function(self, count) self.stacks = count end
    assert(modifier:GetModifierPreAttack_BonusDamage() == 12)
    sf.PassivesDisabled = function() return true end
    assert(modifier:GetModifierPreAttack_BonusDamage() == 0)
    modifier:OnDeath({ attacker = sf, unit = creep })
    assert(modifier.stacks == 3, 'Necromastery should not gain souls while Broken')
    sf.PassivesDisabled = function() return false end
    sf.IsIllusion = function() return true end
    assert(modifier:GetModifierPreAttack_BonusDamage() == 0)
    modifier:OnDeath({ attacker = sf, unit = creep })
    assert(modifier.stacks == 3, 'illusions should not gain Necromastery souls')
end)

test('Shadow Fiend aura and Feast of Souls disable while Broken', function()
    local sf = create_mock_unit('npc_dota_hero_nevermore', 2, Vector(0, 0, 0))
    local aura = modifier_enfos_sf_presence_aura()
    aura.GetParent = function() return sf end
    assert(aura:IsAura())
    sf.PassivesDisabled = function() return true end
    assert(not aura:IsAura(), 'Presence aura should stop while Broken')

    sf.PassivesDisabled = function() return false end
    sf.hp = 400
    sf.mana = 300
    local ability = enfos_sf_feast_of_souls()
    ability.GetSpecialValueFor = function(_, key)
        if key == 'hp_per_kill' then return 25 end
        if key == 'mana_per_kill' then return 15 end
        return 0
    end
    local feast = modifier_enfos_sf_feast_of_souls_passive()
    feast.GetParent = function() return sf end
    feast.GetAbility = function() return ability end
    sf.PassivesDisabled = function() return true end
    feast:OnDeath({ attacker = sf, unit = create_mock_unit('enfos_creep_melee', 3) })
    assert(sf.hp == 400 and sf.mana == 300, 'Feast should grant no sustain while Broken')
    sf.PassivesDisabled = function() return false end
    feast:OnDeath({ attacker = sf, unit = create_mock_unit('enfos_creep_melee', 3) })
    assert(sf.hp == 425 and sf.mana == 315, 'Feast should heal and restore mana for a valid kill')
end)

test('Witch Doctor restoration owns audio and particle cleanup on off and mana exhaustion', function()
    local wd = create_mock_unit('npc_dota_hero_witch_doctor', 2, Vector(0, 0, 0), 1000)
    wd.hp = 500
    local emitted, stopped = {}, {}
    wd.EmitSound = function(_, event) emitted[#emitted + 1] = event end
    wd.StopSound = function(_, event) stopped[#stopped + 1] = event end
    local ability = enfos_wd_voodoo_restoration()
    local active = true
    ability.GetCaster = function() return wd end
    ability.GetToggleState = function() return active end
    ability.GetSpecialValueFor = function(_, key)
        return ({ mana_per_second = 8, radius = 500, heal_per_second = 20 })[key] or 0
    end
    local function remove()
        local mod = wd.modifiers.modifier_enfos_wd_voodoo_restoration_aura
        if mod then mod:OnDestroy(); wd.modifiers.modifier_enfos_wd_voodoo_restoration_aura = nil end
    end
    wd.RemoveModifierByName = function() remove() end
    ability.ToggleAbility = function() active = not active; ability:OnToggle() end
    local originalAdd = wd.AddNewModifier
    wd.AddNewModifier = function(self, ...)
        local mod = originalAdd(self, ...)
        mod.StartIntervalThink = function() end
        mod.Destroy = function() remove() end
        mod:OnCreated()
        return mod
    end
    mock_world_units = { wd }
    ability:OnToggle()
    local aura = wd.modifiers.modifier_enfos_wd_voodoo_restoration_aura
    assert(aura and not aura:IsPurgable(), 'Purge must not detach an enabled healing toggle')
    assert(emitted[1] == 'Hero_WitchDoctor.Voodoo_Restoration')
    assert(emitted[2] == 'Hero_WitchDoctor.Voodoo_Restoration.Loop')
    aura:OnIntervalThink()
    assert(wd.mana == 492 and wd.hp == 535, 'The audio change must preserve mana and heal behavior')
    assert(#emitted == 2, 'Healing ticks must not repeatedly start the sound')
    ability:ToggleAbility()
    assert(stopped[1] == 'Hero_WitchDoctor.Voodoo_Restoration.Loop' and aura.particle == nil)
    assert(emitted[3] == 'Hero_WitchDoctor.Voodoo_Restoration.Off')
    ability:ToggleAbility()
    wd.mana = 0
    wd.modifiers.modifier_enfos_wd_voodoo_restoration_aura:OnIntervalThink()
    assert(not active and #stopped == 2, 'Mana exhaustion must stop the loop exactly once and disable the toggle')
    local originalServer = IsServer
    IsServer = function() return false end
    local count = #emitted
    ability:OnToggle()
    assert(#emitted == count, 'Predicted client callback must not emit server audio or modify state')
    IsServer = originalServer
end)

test('Witch Doctor channel and Shard sound stop during modifier teardown', function()
    local wd = create_mock_unit('npc_dota_hero_witch_doctor', 2, Vector(0, 0, 0))
    local stopped = {}
    wd.StopSound = function(_, event) stopped[#stopped + 1] = event end
    local channel = modifier_enfos_wd_death_ward_channel()
    channel.GetCaster = function() return wd end
    channel:OnDestroy()
    assert(stopped[1] == 'Hero_WitchDoctor.Death_WardBuild', 'Death/expiry teardown must stop audio without relying on OnChannelFinish')
    local shard = modifier_enfos_wd_voodoo_switcheroo_buff()
    shard.GetParent = function() return wd end
    shard:OnDestroy()
    assert(stopped[2] == 'Hero_WitchDoctor.Death_WardBuild', 'Two-second Shard must not leave the eight-second build sound playing')
end)

test('Witch Doctor Shard launches its ward projectile and resolves damage at impact', function()
    applied_damages = {}
    local wd = create_mock_unit('npc_dota_hero_witch_doctor', 2, Vector(0, 0, 0))
    local enemy = create_mock_unit('enfos_creep_melee', 3, Vector(100, 0, 0))
    mock_world_units = { wd, enemy }
    local ability = enfos_wd_voodoo_switcheroo()
    ability.GetCaster = function() return wd end
    ability.GetSpecialValueFor = function(_, key) return key == 'projectile_speed' and 1000 or 0 end
    local buff = modifier_enfos_wd_voodoo_switcheroo_buff()
    buff.GetParent = function() return wd end
    buff.GetAbility = function() return ability end
    local previous = ProjectileManager.CreateTrackingProjectile
    local projectile
    ProjectileManager.CreateTrackingProjectile = function(_, options) projectile = options; return 1 end
    buff:OnIntervalThink()
    assert(projectile.Source == wd and projectile.Target == enemy and projectile.iMoveSpeed == 1000)
    assert(#applied_damages == 0)
    ability:OnProjectileHit_ExtraData(enemy, nil, projectile.ExtraData)
    assert(#applied_damages == 1 and applied_damages[1].damage == 160)
    ProjectileManager.CreateTrackingProjectile = previous
end)


test('Lina Dragon Slave cannot bypass Combustion Break through its direct burn path', function()
    local lina = create_mock_unit('npc_dota_hero_lina', 2, Vector(0, 0, 0))
    local target = create_mock_unit('enfos_lina_break_target', 3, Vector(100, 0, 0))
    local comb = enfos_lina_combustion()
    comb.GetLevel = function() return 1 end
    comb.GetSpecialValueFor = function(_, key) return key == 'burn_duration' and 3 or 0 end
    lina.FindAbilityByName = function(_, name) return name == 'enfos_lina_combustion' and comb or nil end
    local q = enfos_lina_dragon_slave()
    q.GetCaster = function() return lina end
    q.GetSpecialValueFor = function() return 100 end
    lina.PassivesDisabled = function() return true end
    applied_damages = {}
    q:OnProjectileHit(target)
    assert(#applied_damages == 1, 'Break must not disable active Dragon Slave damage')
    assert(not target:HasModifier('modifier_enfos_pve_burn'), 'Q direct burn bypassed Combustion Break')
    lina.PassivesDisabled = function() return false end
    q:OnProjectileHit(target)
    assert(target:HasModifier('modifier_enfos_pve_burn'), 'Learned unbroken passive still burns the enemy')
end)

test('Lina Fiery Soul attack proc rejects friendly and missing targets but retains hostile killing hits', function()
    local lina = create_mock_unit('npc_dota_hero_lina', 2, Vector(0, 0, 0))
    local ally = create_mock_unit('enfos_lina_friendly', 2, Vector(100, 0, 0))
    local enemy = create_mock_unit('enfos_lina_hostile', 3, Vector(100, 0, 0))
    local ability = enfos_lina_fiery_soul()
    ability.GetSpecialValueFor = function(_, key) return key == 'fiery_soul_attack_proc_chance' and 25 or 10 end
    local mod = modifier_enfos_pve_fiery()
    mod.GetParent = function() return lina end
    mod.GetAbility = function() return ability end
    mod:OnAttackLanded({attacker=lina,target=ally})
    assert(not lina:HasModifier('modifier_enfos_pve_fiery_stacks'), 'Deny/friendly attack must not grant combat stacks')
    mod:OnAttackLanded({attacker=lina})
    assert(not lina:HasModifier('modifier_enfos_pve_fiery_stacks'), 'Missing target must not grant stacks')
    enemy.alive = false
    mod:OnAttackLanded({attacker=lina,target=enemy})
    assert(lina:HasModifier('modifier_enfos_pve_fiery_stacks'), 'Hostile killing landed event must still grant stack')
end)


test('Lina Fiery Soul owns one stack-controlled flame particle across refreshes', function()
    local lina = create_mock_unit('npc_dota_hero_lina', 2, Vector(0,0,0))
    local a = enfos_lina_fiery_soul()
    a.GetSpecialValueFor = function(_, key) return key == 'fiery_soul_max_stacks' and 4 or 10 end
    local mod = lina:AddNewModifier(lina, a, 'modifier_enfos_pve_fiery_stacks', {})
    local oldCreate, oldControl = ParticleManager.CreateParticle, ParticleManager.SetParticleControl
    local creates, controls, owned = 0, {}, 0
    ParticleManager.CreateParticle = function(_, path, attachment, unit)
        assert(path == 'particles/units/heroes/hero_lina/lina_fiery_soul.vpcf')
        assert(attachment == PATTACH_ABSORIGIN_FOLLOW and unit == lina)
        creates = creates + 1; return 771
    end
    ParticleManager.SetParticleControl = function(_, id, cp, vector)
        assert(id == 771 and cp == 1); controls[#controls + 1] = vector.x
    end
    mod.AddParticle = function(_, id, immediate, status, priority, hero, overhead)
        assert(id == 771 and immediate == false and status == false)
        owned = owned + 1
    end
    mod:OnCreated()
    assert(creates == 1 and owned == 1 and controls[1] == 1,
        'Fiery Soul must own its flame and supply decoded emission stack CP1')
    for i=1,6 do mod:OnRefresh() end
    assert(creates == 1 and owned == 1 and mod:GetStackCount() == 4 and controls[#controls] == 4,
        'Refreshes update the same particle to capped stacks, never allocate another')
    ParticleManager.CreateParticle, ParticleManager.SetParticleControl = oldCreate, oldControl
end)


test('Lina Light Strike Array supplies native radius and motion controls matching its targeting cursor', function()
    local c=create_mock_unit('npc_dota_hero_lina',2,Vector(0,0,0))
    local a=enfos_lina_light_strike_array()
    a.GetCaster=function() return c end
    a.GetCursorPosition=function() return Vector(100,200,0) end
    a.GetSpecialValueFor=function(_,k) return ({radius=350,light_strike_array_delay_time=0.5})[k] or 0 end
    local oldRules,oldCreate,oldControl,oldRelease=GameRules,ParticleManager.CreateParticle,ParticleManager.SetParticleControl,ParticleManager.ReleaseParticleIndex
    GameRules={GetGameModeEntity=function() return {SetContextThink=function() end} end}
    local attachment,owner,controls,released
    controls={}
    ParticleManager.CreateParticle=function(_,path,at,u) attachment,owner=at,u; return 791 end
    ParticleManager.SetParticleControl=function(_,id,cp,v) controls[cp]=v end
    ParticleManager.ReleaseParticleIndex=function(_,id) released=id end
    a:OnSpellStart()
    assert(controls[1].x==350 and controls[1].y==1 and controls[1].z==1,
        'Decoded LSA collapse rings need CP1 motion component, not radius with zero controls')
    assert(attachment==PATTACH_WORLDORIGIN and owner==nil and controls[0].x==100 and released==791)
    assert(type(a.GetAOERadius)=='function' and a:GetAOERadius()==350,'Targeting cursor must expose the same area used for hits')
    GameRules,ParticleManager.CreateParticle,ParticleManager.SetParticleControl,ParticleManager.ReleaseParticleIndex=oldRules,oldCreate,oldControl,oldRelease
end)

test('Lina Combustion presents its captured corpse explosion center and radius without a dead attachment', function()
    local c=create_mock_unit('npc_dota_hero_lina',2,Vector(0,0,0))
    local corpse=create_mock_unit('enfos_lina_corpse',3,Vector(200,30,0),1000)
    local neighbor=create_mock_unit('enfos_lina_burst_neighbor',3,Vector(220,30,0))
    local a=enfos_lina_combustion()
    a.GetCaster=function() return c end
    a.GetSpecialValueFor=function(_,k) return ({corpse_burst_base=120,corpse_burst_hp_pct=8,corpse_burst_hp_cap=600,corpse_burst_radius=300})[k] or 0 end
    corpse:AddNewModifier(c,a,'modifier_enfos_pve_burn',{})
    corpse.alive=false
    local mod=modifier_enfos_pve_combustion()
    mod.GetParent=function() return c end
    mod.GetAbility=function() return a end
    mock_world_units={corpse,neighbor}
    local oldDamage,oldCreate,oldControl,oldRelease=ApplyDamage,ParticleManager.CreateParticle,ParticleManager.SetParticleControl,ParticleManager.ReleaseParticleIndex
    local controls,attachment,owner={},nil,nil
    ApplyDamage=function(info) corpse:SetAbsOrigin(Vector(999,999,0)); return 200 end
    ParticleManager.CreateParticle=function(_,path,at,u) attachment,owner=at,u;return 792 end
    ParticleManager.SetParticleControl=function(_,id,cp,v) controls[cp]=v end
    ParticleManager.ReleaseParticleIndex=function() end
    mod:OnDeath({unit=corpse})
    assert(attachment==PATTACH_WORLDORIGIN and owner==nil,'Corpse detonation must not follow a dead/removed entity')
    assert(controls[0] and controls[0].x==200 and controls[0].y==30,'Damage callback must not shift explosion presentation origin')
    assert(controls[1] and controls[1].x==300 and controls[1].z==1,'Corpse explosion must supply its own configured radius and native motion CP')
    ApplyDamage,ParticleManager.CreateParticle,ParticleManager.SetParticleControl,ParticleManager.ReleaseParticleIndex=oldDamage,oldCreate,oldControl,oldRelease
end)


test('Omniknight Hammer retains splash and sustain on lethal landed attacks without modifying the corpse', function()
    local c=create_mock_unit('npc_dota_hero_omniknight',2,Vector(0,0,0),1000)
    c.hp=300;c.strength=100
    local corpse=create_mock_unit('enfos_hammer_corpse',3,Vector(100,0,0),1000)
    corpse.alive=false
    local neighbor=create_mock_unit('enfos_hammer_neighbor',3,Vector(120,0,0),1000)
    mock_world_units={corpse,neighbor}
    local a=enfos_omni_hammer_of_purity()
    a.GetCaster=function() return c end
    a.GetSpecialValueFor=function(_,k) return ({bonus_pure_damage=80,strength_multiplier=1.2,lifesteal_pct=50,splash_radius=275,splash_damage_pct=50,slow_duration=2})[k] or 0 end
    local m=modifier_enfos_pve_hammer()
    m.GetParent=function() return c end;m.GetAbility=function() return a end
    applied_damages={}
    m:OnAttackLanded({attacker=c,target=corpse})
    assert(#applied_damages==1 and applied_damages[1].victim==neighbor and applied_damages[1].damage==100,'Lethal landed attack must still trigger Hammer splash')
    assert(c.hp==400,'Lethal landed attack must retain configured sustain')
    assert(not corpse:HasModifier('modifier_enfos_pve_slow'),'Never apply slow to the already dead primary target')
    -- Bonus damage can itself kill/relocate the primary before splash or slow runs.
    corpse.alive=true;c.hp=300;applied_damages={}
    local oldDamage=ApplyDamage
    ApplyDamage=function(info)
        local result=oldDamage(info)
        if info.victim==corpse then corpse.alive=false;corpse:SetAbsOrigin(Vector(999,999,0)) end
        return result
    end
    m:OnAttackLanded({attacker=c,target=corpse})
    ApplyDamage=oldDamage
    assert(#applied_damages==2 and applied_damages[2].victim==neighbor and applied_damages[2].damage==100,'Bonus lethal hit must retain splash at captured center')
    assert(not corpse:HasModifier('modifier_enfos_pve_slow'),'Bonus lethal hit must not add slow to the corpse')
    assert(c.hp==400,'Bonus lethal hit must retain configured sustain')
end)

print(passed .. ' hero kit regression tests passed (mock engine).')
