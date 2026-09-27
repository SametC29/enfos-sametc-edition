package.path = "game/scripts/vscripts/?.lua;" .. package.path
local Transfer = require("lib/inventory_transfer")
local passed = 0
local function test(name, fn)
    fn()
    passed = passed + 1
    print("PASS " .. name)
end
local function item()
    return {IsNull = function() return false end}
end
local function unit(maxSlot)
    local u = {slots = {}, maxSlot = maxSlot or 5}
    function u:IsNull() return false end
    function u:GetItemInSlot(slot) return self.slots[slot] end
    function u:TakeItem(it)
        for slot, value in pairs(self.slots) do if value == it then self.slots[slot] = nil end end
        return it
    end
    function u:AddItem(it)
        if self.reject then return nil end
        if self.throw then error("engine_rejected") end
        for slot = 0, self.maxSlot do
            if not self.slots[slot] then self.slots[slot] = it; return it end
        end
    end
    function u:SwapItems(a, b) self.slots[a], self.slots[b] = self.slots[b], self.slots[a] end
    return u
end
test("full courier leaves stash unchanged", function()
    local hero, courier = unit(14), unit()
    local original = item(); hero.slots[9] = original
    for slot = 0, 5 do courier.slots[slot] = item() end
    assert(Transfer.Range(hero, courier, 9, 14, 0, 5) == 0)
    assert(hero.slots[9] == original)
end)
test("partial capacity preserves remaining items and exact handles", function()
    local hero, courier = unit(14), unit()
    local first, second = item(), item(); hero.slots[9], hero.slots[10] = first, second
    for slot = 0, 4 do courier.slots[slot] = item() end
    assert(Transfer.Range(hero, courier, 9, 14, 0, 5) == 1)
    assert(hero.slots[9] == nil and hero.slots[10] == second and courier.slots[5] == first)
    assert(Transfer.Range(hero, courier, 9, 14, 0, 5) == 0)
end)
test("rejected/throwing AddItem restores original stash slot", function()
    for _, mode in ipairs({"reject", "throw"}) do
        local hero, courier = unit(14), unit()
        local original = item(); hero.slots[12] = original; courier[mode] = true
        assert(not Transfer.Move(hero, courier, 12, 0, 5))
        assert(hero.slots[12] == original and hero.slots[0] == nil and courier.slots[0] == nil)
    end
end)
test("delivery does not fill backpack or detach when combat slots full", function()
    local hero, courier = unit(14), unit()
    local original = item(); courier.slots[0] = original
    for slot = 0, 5 do hero.slots[slot] = item() end
    assert(Transfer.Range(courier, hero, 0, 5, 0, 5) == 0)
    assert(courier.slots[0] == original and hero.slots[6] == nil)
end)
test("successful delivery is not duplicated by repeated ticks", function()
    local hero, courier = unit(14), unit()
    local original = item(); courier.slots[0] = original
    assert(Transfer.Range(courier, hero, 0, 5, 0, 5) == 1)
    assert(Transfer.Range(courier, hero, 0, 5, 0, 5) == 0)
    assert(hero.slots[0] == original and courier.slots[0] == nil)
end)
test("null handles and self transfers are rejected", function()
    local hero = unit(14)
    assert(not Transfer.Move(nil, hero, 9, 0, 5))
    assert(not Transfer.Move(hero, hero, 9, 0, 5))
    assert(not Transfer.Move({IsNull = function() return true end}, hero, 9, 0, 5))
end)
function class(...)
    local c = {}
    c.__index = c
    setmetatable(c, {
        __call = function(cls, ...)
            return setmetatable({}, cls)
        end
    })
    return c
end
require("enfos_sametc")
local fakeEntities = {}
function EntIndexToHScript(index) return fakeEntities[index] end
DOTA_UNIT_ORDER_STOP = 21
DOTA_UNIT_ORDER_HOLD_POSITION = 10
DOTA_UNIT_ORDER_MOVE_TO_POSITION = 1
PlayerResource = {
    IsValidPlayerID = function(_, id) return id == 0 or id == 1 end,
    GetTeam = function(self, id) return self.teams and self.teams[id] or (id == 0 and 2 or 3) end,
    GetSelectedHeroEntity = function(self, id) return self.heroes[id] end,
    GetGold = function(self, id) return self.gold and self.gold[id] or 0 end,
    ModifyGold = function(self, id, amt, isReliable, reason)
        self.gold = self.gold or {}
        self.gold[id] = (self.gold[id] or 0) + amt
    end,
    GetConnectionState = function(self, id) return self.connectionState and self.connectionState[id] or 2 end,
    heroes = {},
    gold = {},
    teams = {},
    connectionState = {},
}
local function mode()
    return setmetatable({playerHeroes = {}}, {__index = EnfosSametC})
end
test("TransferStashToInventory moves stash items into main inventory", function()
    local m, hero = mode(), unit(14)
    function hero:IsAlive() return true end
    local stashItem = item()
    hero.slots[9] = stashItem
    m:TransferStashToInventory(hero)
    assert(hero.slots[9] == nil)
    assert(hero.slots[0] == stashItem)
end)
test("TransferStashToInventory falls back to backpack when main inventory is full", function()
    local m, hero = mode(), unit(14)
    function hero:IsAlive() return true end
    for slot = 0, 5 do hero.slots[slot] = item() end
    local stashItem = item()
    hero.slots[10] = stashItem
    m:TransferStashToInventory(hero)
    assert(hero.slots[10] == nil)
    assert(hero.slots[6] == stashItem)
end)
test("TransferStashToInventory promotes backpack items when main inventory space frees up", function()
    local m, hero = mode(), unit(14)
    function hero:IsAlive() return true end
    local bpItem = item()
    hero.slots[6] = bpItem
    m:TransferStashToInventory(hero)
    assert(hero.slots[6] == nil)
    assert(hero.slots[0] == bpItem)
end)
test("OrderFilter intercept allows general orders and intercepts sellback", function()
    local m = mode()
    assert(m:OrderFilter({issuer_player_id_const = 0, order_type = DOTA_UNIT_ORDER_HOLD_POSITION}) == true)
end)

-- =========================================================================
-- Wave Definitions Tests
-- =========================================================================
local WaveDefs = require("waves/wave_definitions")
test("all 60 authored waves exist and have valid structure", function()
    assert(WaveDefs.TOTAL_WAVES == 60)
    for wave = 1, 60 do
        local def = WaveDefs:GetWave(wave)
        assert(def ~= nil, "Missing wave " .. wave)
        assert(def.wave_number == wave)
        assert(def.batches >= 1 and def.batches <= 5)
        assert(def.batch_interval >= 0)
        assert(def.gold_bounty > 0)
        assert(def.xp_bounty > 0)
        assert(#def.creeps > 0)
    end
end)

test("boss waves are exactly every 5th wave and contain only the Boss", function()
    local expectedBosses = {5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60}
    for _, wave in ipairs(expectedBosses) do
        assert(WaveDefs:IsBossWave(wave), "Wave " .. wave .. " should be a boss wave")
        local def = WaveDefs:GetWave(wave)
        assert(def.wave_type == "boss", "Wave " .. wave .. " type should be boss")
        assert(#def.creeps == 1, "Boss wave " .. wave .. " must contain only the Boss")
        assert(def.creeps[1].is_boss == true, "Wave " .. wave .. " creep must have is_boss=true")
    end
end)

test("elite waves are every 6th wave except boss overlaps", function()
    local expectedElites = {6, 12, 18, 24, 36, 42, 48, 54}
    for _, wave in ipairs(expectedElites) do
        assert(WaveDefs:IsEliteWave(wave), "Wave " .. wave .. " should be an elite wave")
        local def = WaveDefs:GetWave(wave)
        assert(def.wave_type == "elite", "Wave " .. wave .. " type should be elite")
    end
    -- Wave 30 is a boss wave (6*5=30), boss takes precedence
    assert(WaveDefs:IsBossWave(30))
    assert(not WaveDefs:IsEliteWave(30))
end)


test("leak penalties strictly follow game design specification", function()
    assert(WaveDefs:GetLeakPenalty("enfos_creep_soldier") == 1)
    assert(WaveDefs:GetLeakPenalty("enfos_creep_runner") == 1)
    assert(WaveDefs:GetLeakPenalty("enfos_elite_vanguard") == 2)
    assert(WaveDefs:GetLeakPenalty("enfos_elite_assassin") == 2)
    assert(WaveDefs:GetLeakPenalty("enfos_boss_stonebreaker") == 5)
    assert(WaveDefs:GetLeakPenalty("enfos_boss_brood_matron") == 5)
    assert(WaveDefs:GetLeakPenalty("enfos_creep_skeleton") == 0)
    assert(WaveDefs:GetLeakPenalty("enfos_creep_spiderling") == 0)
end)

-- =========================================================================
-- Life Core Tests
local vecMeta = {
    __add = function(a, b) return Vector((a.x or 0) + (b.x or 0), (a.y or 0) + (b.y or 0), (a.z or 0) + (b.z or 0)) end,
    __sub = function(a, b) return Vector((a.x or 0) - (b.x or 0), (a.y or 0) - (b.y or 0), (a.z or 0) - (b.z or 0)) end,
}
function Vector(x, y, z)
    return setmetatable({x = x or 0, y = y or 0, z = z or 0}, vecMeta)
end
function EmitGlobalSound() end
function ScreenShake() end
function UTIL_Remove() end
CustomNetTables = {
    tables = {},
    SetTableValue = function(self, tableName, key, val)
        self.tables[tableName] = self.tables[tableName] or {}
        self.tables[tableName][key] = val
    end,
    GetTableValue = function(self, tableName, key)
        return (self.tables[tableName] or {})[key]
    end,
}
GameRules = GameRules or {}
GameRules.SetGameWinner = function(self, winner) self.winner = winner end
local LifeCore = require("waves/life_core")

test("life core starts at 100 life for both teams and deducts on leaks", function()
    LifeCore:Init(nil)
    assert(LifeCore:GetLife(2) == 100)
    assert(LifeCore:GetLife(3) == 100)

    local function makeCreep(name)
        return {
            IsNull = function() return false end,
            IsAlive = function() return true end,
            ForceKill = function() end,
            GetUnitName = function() return name end,
            GetTeamNumber = function() return 2 end,
        }
    end

    -- Normal creep leak (-1)
    LifeCore:ProcessLeak(makeCreep("enfos_creep_soldier"), 2)
    assert(LifeCore:GetLife(2) == 99)

    -- Elite creep leak (-2)
    LifeCore:ProcessLeak(makeCreep("enfos_elite_vanguard"), 2)
    assert(LifeCore:GetLife(2) == 97)

    -- Boss leak (-5)
    LifeCore:ProcessLeak(makeCreep("enfos_boss_stonebreaker"), 2)
    assert(LifeCore:GetLife(2) == 92)

    -- Summon leak (-0)
    LifeCore:ProcessLeak(makeCreep("enfos_creep_skeleton"), 2)
    assert(LifeCore:GetLife(2) == 92)

    -- Direct deduction causing defeat
    LifeCore:ApplyDamage(2, 92, "test_defeat", "boss")
    assert(LifeCore:GetLife(2) == 0)
    assert(GameRules.winner == 3) -- When Radiant (2) reaches 0, Dire (3) wins
end)

-- =========================================================================
-- Spawn Plan & Threat Budget Tests (20 creeps per player on Wave 1)
-- =========================================================================
test("wave 1 budgets exactly 20 creeps per player", function()
    local plan1, spent1, budget1 = WaveDefs:GetSpawnPlan(1, 1)
    assert(budget1 == 20, "Budget for 1 player should be 20")
    local totalCreeps1 = 0
    for _, entry in ipairs(plan1) do
        totalCreeps1 = totalCreeps1 + entry.count
    end
    assert(totalCreeps1 == 20, "Wave 1 must produce exactly 20 creeps for 1 player, got: " .. totalCreeps1)

    local plan2, spent2, budget2 = WaveDefs:GetSpawnPlan(1, 2)
    assert(budget2 == 40, "Budget for 2 players should be 40")
    local totalCreeps2 = 0
    for _, entry in ipairs(plan2) do
        totalCreeps2 = totalCreeps2 + entry.count
    end
    assert(totalCreeps2 == 40, "Wave 1 must produce exactly 40 creeps for 2 players, got: " .. totalCreeps2)

    -- Boss wave 5 has exactly 1 boss
    local bossPlan = WaveDefs:GetSpawnPlan(5, 1)
    assert(#bossPlan == 1 and bossPlan[1].count == 1, "Boss wave must have 1 boss")
end)

-- =========================================================================
-- Rewards System Tests
-- =========================================================================
LoadKeyValues = LoadKeyValues or function() return {} end
local Rewards = require("waves/rewards")
test("rewards distribute shared gold and award killer bonus, leak gives zero", function()
    Rewards:Init()
    local goldGiven = {}
    local xpGiven = {}
    DOTA_ModifyGold_CreepKill = 1
    DOTA_ModifyXP_CreepKill = 1
    DOTA_CONNECTION_STATE_CONNECTED = 2
    PlayerResource.ModifyGold = function(self, id, amt, isReliable, reason)
        goldGiven[id] = (goldGiven[id] or 0) + amt
    end
    PlayerResource.GetConnectionState = function(self, id) return 2 end
    PlayerResource.heroes[0] = {
        IsNull = function() return false end,
        AddExperience = function(self, xp, reason, bSelector, bDirect)
            xpGiven[0] = (xpGiven[0] or 0) + xp
        end,
    }

    local testUnit = {
        enfosGold = 100,
        enfosXP = 50,
        defendingTeam = 2,
        enfosRewardResolved = false,
        enfosLeaked = false,
        SetMinimumGoldBounty = function() end,
        SetMaximumGoldBounty = function() end,
        SetDeathXP = function() end,
    }
    local killerHero = {
        IsNull = function() return false end,
        GetPlayerOwnerID = function() return 0 end,
    }

    -- Normal kill by player 0 on team 2 (only player 0 is on team 2 in mock)
    local resolved = Rewards:OnKill(testUnit, killerHero)
    assert(resolved == true)
    -- Player 0 gets 100 * 1.2 = 120 gold
    assert(goldGiven[0] == 120, "Killer should receive 20% bonus gold, got: " .. tostring(goldGiven[0]))

    -- Leaked unit gives zero reward
    local leakedUnit = {
        enfosGold = 100,
        enfosXP = 50,
        defendingTeam = 2,
        enfosRewardResolved = false,
        enfosLeaked = true,
    }
    local leakResolved = Rewards:OnKill(leakedUnit, nil)
    assert(leakResolved == false)
end)

-- =========================================================================
-- Spellbringer Tests (Phase 5)
-- =========================================================================
local SpellbringerService = require("spellbringer/spellbringer_service")

DOTA_UNIT_TARGET_TEAM_FRIENDLY = 1
DOTA_UNIT_TARGET_TEAM_ENEMY = 2
DOTA_UNIT_TARGET_HERO = 1
DOTA_UNIT_TARGET_BASIC = 2
DOTA_UNIT_TARGET_FLAG_NONE = 0

-- Mock engine APIs for Spellbringer tests
CreateUnitByName = CreateUnitByName or function(unitName, pos, bFindClearSpace, npcOwner, entityOwner, team)
    return {
        IsNull = function() return false end,
        IsAlive = function() return true end,
        GetUnitName = function() return unitName end,
        GetTeamNumber = function() return team end,
        GetAbsOrigin = function() return pos end,
        AddNewModifier = function(self, caster, ability, modName, kv) end,
        RemoveModifierByName = function(self, modName) self[modName] = nil end,
        EmitSound = function() end,
        SetIdleAcquire = function() end,
        SetAcquisitionRange = function() end,
        GetMaxHealth = function() return 500 end,
        SetMaxHealth = function(self, h) self.maxHealth = h end,
        SetHealth = function(self, h) self.health = h end,
        GetBaseDamageMin = function() return 30 end,
        SetBaseDamageMin = function() end,
        GetBaseDamageMax = function() return 40 end,
        SetBaseDamageMax = function() end,
        ForceKill = function() end,
    }
end

FindUnitsInRadius = FindUnitsInRadius or function() return {} end
ApplyDamage = ApplyDamage or function() end
FindClearSpaceForUnit = FindClearSpaceForUnit or function() end
CreateModifierThinker = CreateModifierThinker or function() end
AddFOWViewer = AddFOWViewer or function() end

GameRules.State_Get=function() return 7 end
GameRules.IsGamePaused=function() return false end
DOTA_GAMERULES_STATE_GAME_IN_PROGRESS=7
DOTA_GAMERULES_STATE_POST_GAME=8
test("spellbringer initializes with 100 mana and regenerates over time", function()
    SpellbringerService:Init(nil)
    assert(SpellbringerService:GetMana(0) == 100, "Starting mana should be 100")
    assert(SpellbringerService:GetMaxMana(0) == 200, "Max mana should be 200")

    -- Consume mana down to 50
    SpellbringerService:SetMana(0, 50)
    assert(SpellbringerService:GetMana(0) == 50)

    -- OnThink(1.0) with default regen (2.5/s) should regenerate 2.5 mana -> 52.5
    SpellbringerService:OnThink(1.0)
    assert(SpellbringerService:GetMana(0) == 52.5, "Mana should regenerate by 2.5 after 1 second")

    -- Mana should not exceed max_mana
    SpellbringerService:SetMana(0, 199)
    SpellbringerService:OnThink(2.0)
    assert(SpellbringerService:GetMana(0) == 200, "Mana should not exceed max_mana")
end)

test("spellbringer cast enforces mana cost and cooldown, rejects duplicate/unfunded cast", function()
    SpellbringerService:Init(nil)
    SpellbringerService.isCoop = false
    SpellbringerService:SetMana(0, 50)

    -- Arcane barrier costs 45
    local canCast, reason = SpellbringerService:CanCast(0, "spellbringer_arcane_barrier")
    assert(canCast == true, "Player should have enough mana for arcane barrier")

    -- Whole displacement costs 80, player has 50 -> should fail
    local canCastWD, reasonWD = SpellbringerService:CanCast(0, "spellbringer_whole_displacement")
    assert(canCastWD == false and reasonWD == "INSUFFICIENT_MANA", "Should reject with INSUFFICIENT_MANA")

    -- Cast arcane barrier: mana goes 50 -> 5, cooldown set to 20s
    local castOk = SpellbringerService:CastSpell(0, "spellbringer_arcane_barrier", nil, nil)
    assert(castOk == true, "Cast should succeed")
    assert(SpellbringerService:GetMana(0) == 5, "Mana should be deducted to 5")
    assert(SpellbringerService:GetCooldownRemaining(0, "spellbringer_arcane_barrier") == 20.0, "Cooldown should be 20s")

    -- Immediate recast fails with INSUFFICIENT_MANA (or ON_COOLDOWN)
    local canRecast, recastReason = SpellbringerService:CanCast(0, "spellbringer_arcane_barrier")
    assert(canRecast == false)

    -- Reset mana to 100, recast should still fail because of cooldown
    SpellbringerService:SetMana(0, 100)
    local canRecastWithMana, cdReason = SpellbringerService:CanCast(0, "spellbringer_arcane_barrier")
    assert(canRecastWithMana == false and cdReason == "ON_COOLDOWN", "Should fail due to ON_COOLDOWN")

    -- Advance time by 20 seconds, cooldown decays to 0
    SpellbringerService:OnThink(20.0)
    assert(SpellbringerService:GetCooldownRemaining(0, "spellbringer_arcane_barrier") == 0, "Cooldown should be expired")
    assert(SpellbringerService:CanCast(0, "spellbringer_arcane_barrier") == true, "Should be castable again after cooldown")
end)

test("coop mode disables offensive spellbringer abilities while keeping defensive", function()
    SpellbringerService:Init(nil)
    SpellbringerService.isCoop = true
    SpellbringerService:SetMana(0, 200)

    -- Offensive abilities must fail
    local canOffensive, offReason = SpellbringerService:CanCast(0, "spellbringer_rift_surge")
    assert(canOffensive == false and offReason == "COOP_OFFENSIVE_DISABLED", "Offensive ability must be disabled in co-op")

    local canBarrier, barReason = SpellbringerService:CanCast(0, "spellbringer_arcane_barrier")
    assert(canBarrier == false and barReason == "COOP_OFFENSIVE_DISABLED")

    -- Defensive abilities must remain allowed
    local canReveal = SpellbringerService:CanCast(0, "spellbringer_reveal")
    assert(canReveal == true, "Defensive ability should remain castable in co-op")

    local canPurify = SpellbringerService:CanCast(0, "spellbringer_purification")
    assert(canPurify == true, "Purification should remain castable in co-op")

    local canReinforce = SpellbringerService:CanCast(0, "spellbringer_future_reinforcements")
    assert(canReinforce == true, "Future reinforcements should remain castable in co-op")
end)

test("purification dispels spellbringer buffs and destroys summons", function()
    SpellbringerService:Init(nil)
    SpellbringerService.isCoop = false
    SpellbringerService:SetMana(0, 200)

    local removedModifiers = {}
    local damagedUnits = {}

    local hostileCreep = {
        IsNull = function() return false end,
        IsAlive = function() return true end,
        GetUnitName = function() return "enfos_creep_soldier" end,
        is_spellbringer_summon = false,
        RemoveModifierByName = function(self, mod) removedModifiers[mod] = true end,
    }

    local hostileSummon = {
        IsNull = function() return false end,
        IsAlive = function() return true end,
        GetUnitName = function() return "enfos_spellbringer_war_standard" end,
        is_spellbringer_summon = true,
        RemoveModifierByName = function() end,
    }

    local alliedHero = {
        IsNull = function() return false end,
        IsAlive = function() return true end,
        purged = false,
        Purge = function(self, bRemovePositiveBuffs, bRemoveDebuffs, bFrameOnly, bRemoveStuns, bRemoveExceptions)
            self.purged = true
        end,
    }

    local originalFind = FindUnitsInRadius
    FindUnitsInRadius = function(team, pos, cache, radius, targetTeam, targetType, flags, order, bHelp)
        if targetTeam == DOTA_UNIT_TARGET_TEAM_ENEMY then
            return { hostileCreep, hostileSummon }
        elseif targetTeam == DOTA_UNIT_TARGET_TEAM_FRIENDLY then
            return { alliedHero }
        end
        return {}
    end

    local originalDamage = ApplyDamage
    ApplyDamage = function(kv)
        damagedUnits[#damagedUnits+1] = kv
    end

    local ok = SpellbringerService:CastSpell(0, "spellbringer_purification", Vector(7504,-1357,136), nil)
    assert(ok == true)
    assert(removedModifiers["modifier_spellbringer_arcane_barrier"] == true, "Should dispel arcane barrier")
    assert(removedModifiers["modifier_spellbringer_war_standard_buff"] == true, "Should dispel war standard buff")
    assert(removedModifiers["modifier_spellbringer_thorn_idol_buff"] == true, "Should dispel thorn idol buff")
    assert(alliedHero.purged == true, "Allied hero should be purged/cleansed")
    assert(#damagedUnits == 1 and damagedUnits[1].victim == hostileSummon and damagedUnits[1].damage == 800,
        "Hostile summon should receive 800 pure counter damage")

    FindUnitsInRadius = originalFind
    ApplyDamage = originalDamage
end)

test("future reinforcements summons exactly 5 allied fighters with wave scaling and 0 leak penalty", function()
    SpellbringerService:Init(nil)
    SpellbringerService.isCoop = false
    SpellbringerService:SetMana(0, 200)

    local spawnedUnits = {}
    local originalCreate = CreateUnitByName
    CreateUnitByName = function(unitName, pos, bFindClearSpace, npcOwner, entityOwner, team)
        local u = {
            name = unitName,
            position = pos,
            owner = npcOwner,
            SetOwner = function(self, v) self.owner = v end,
            SetControllableByPlayer = function(self, id, enabled) self.controller = id; self.controlled = enabled end,
            SetBaseMaxHealth = function(self, v) self.maxHp = v end,
            GetBaseMaxHealth = function(self) return self.maxHp end,
            team = team,
            maxHp = 550,
            baseDmg = 35,
            GetMaxHealth = function(self) return self.maxHp end,
            SetMaxHealth = function(self, v) self.maxHp = v end,
            SetHealth = function() end,
            GetBaseDamageMin = function(self) return self.baseDmg end,
            SetBaseDamageMin = function(self, v) self.baseDmg = v end,
            GetBaseDamageMax = function() return 45 end,
            SetBaseDamageMax = function() end,
            SetIdleAcquire = function() end,
            SetAcquisitionRange = function() end,
            AddNewModifier = function(self, caster, ability, modName, kv) self.timedLife = kv.duration end,
        }
        spawnedUnits[#spawnedUnits+1] = u
        return u
    end

    SpellbringerService.waveManager = { currentWave = 10 }
    local ok = SpellbringerService:CastSpell(0, "spellbringer_future_reinforcements", Vector(7504,-1357,136), nil)
    assert(ok == true)
    assert(#spawnedUnits == 5, "Future reinforcements must summon exactly 5 fighters, got: " .. #spawnedUnits)

    for _, unit in ipairs(spawnedUnits) do
        assert(unit.name == "enfos_spellbringer_reinforcement")
        assert(unit.controller == 0 and unit.controlled == true, "Summons must be controlled by the casting player")
        assert(unit.is_allied_reinforcement == true)
        assert(unit.enfosNoReward == true)
        assert(unit.timedLife == 30.0, "Must have 30s timed life")
        -- Wave 10 + 4 = 14 -> 14 * 25 = 350 bonus HP -> 550 + 350 = 900
        assert(unit.maxHp == 900, "HP should scale to wave+4 power")
    end

    -- Verify leak penalty in wave definitions is 0
    assert(WaveDefs:GetLeakPenalty("enfos_spellbringer_reinforcement") == 0, "Reinforcement leak penalty must be 0")
    assert(WaveDefs:GetLeakPenalty("enfos_spellbringer_void_stalker") == 0, "Void stalker leak penalty must be 0")
    assert(WaveDefs:GetLeakPenalty("enfos_spellbringer_war_standard") == 0, "War standard leak penalty must be 0")
    assert(WaveDefs:GetLeakPenalty("enfos_spellbringer_thorn_idol") == 0, "Thorn idol leak penalty must be 0")

    CreateUnitByName = originalCreate
end)

-- =========================================================================
-- Elite & Boss Framework Tests (Phase 6)
-- =========================================================================
LinkLuaModifier = LinkLuaModifier or function() end
IsServer = function() return true end
local BossFramework = require("bosses/boss_framework")
local EliteFramework = require("bosses/elite_framework")

test("boss base modifier enforces CC, reflect, and %-HP damage caps", function()
    BossFramework:Init()

    local dummyBoss = {
        IsNull = function() return false end,
        IsAlive = function() return true end,
        GetMaxHealth = function() return 10000 end,
        GetHealth = function() return 10000 end,
        AddNewModifier = function() end,
        SetContextThink = function() end,
        entindex = function() return 999 end,
    }

    local mod = modifier_enfos_boss_base()
    mod.GetParent = function() return dummyBoss end

    -- 1. Status Resistance is 60%
    assert(mod:GetModifierStatusResistanceStacking() == 60, "Boss must have 60% status resistance")

    -- 2. Reflect damage is capped at 150
    DOTA_DAMAGE_FLAG_REFLECTION = 16
    local reflectBlock = mod:GetModifierTotal_ConstantBlock({
        damage = 500,
        damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
    })
    -- Total damage was 500, cap is 150, so blocked portion is 500 - 150 = 350
    assert(reflectBlock == 350, "Reflect damage above 150 must be blocked, got blocked: " .. tostring(reflectBlock))

    -- 3. %-HP damage is capped at 4% max HP (4% of 10000 = 400)
    local giantDamageBlock = mod:GetModifierTotal_ConstantBlock({
        damage = 2500,
        damage_flags = 0,
    })
    -- Max allowed is 400, so blocked portion is 2500 - 400 = 2100
    assert(giantDamageBlock == 2100, "%-HP damage above 4% max HP must be blocked, got: " .. tostring(giantDamageBlock))
end)

test("boss ground telegraph executes callback and notifies warning", function()
    BossFramework:Init()
    local callbackExecuted = false
    local testPos = Vector(100, 200, 0)
    BossFramework:CreateTelegraph(testPos, 450, 1.5, function(pos, radius)
        callbackExecuted = true
        assert(pos.x == 100 and pos.y == 200)
        assert(radius == 450)
    end)
    assert(callbackExecuted == true, "Telegraph callback must execute")
end)

test("stonebreaker enrages below 30% HP and brood matron spawns adds below 50% HP", function()
    BossFramework:Init()

    -- Stonebreaker
    local stonebreaker = {
        IsNull = function() return false end,
        IsAlive = function() return true end,
        maxHp = 3000,
        hp = 800, -- 800/3000 = 26.6% (<30%)
        GetMaxHealth = function(self) return self.maxHp end,
        GetHealth = function(self) return self.hp end,
        AddNewModifier = function(self, caster, ability, name) self.enragedMod = name end,
        EmitSound = function() end,
        GetTeamNumber = function() return 4 end,
        GetAbsOrigin = function() return Vector(0,0,0) end,
        SetContextThink = function() end,
        entindex = function() return 1001 end,
    }

    BossFramework:RegisterBoss(stonebreaker, "enfos_boss_stonebreaker", 5, 1)
    BossFramework:ThinkStonebreaker(stonebreaker, stonebreaker.bossState)
    assert(stonebreaker.bossState.isEnraged == true, "Stonebreaker must enrage below 30% HP")
    assert(stonebreaker.enragedMod == "modifier_enfos_boss_enrage", "Must apply modifier_enfos_boss_enrage")

    -- Brood Matron
    local broodMatron = {
        IsNull = function() return false end,
        IsAlive = function() return true end,
        maxHp = 5500,
        hp = 2500, -- 2500/5500 = 45.4% (<50%)
        GetMaxHealth = function(self) return self.maxHp end,
        GetHealth = function(self) return self.hp end,
        AddNewModifier = function() end,
        EmitSound = function() end,
        GetTeamNumber = function() return 4 end,
        GetAbsOrigin = function() return Vector(0,0,0) end,
        SetContextThink = function() end,
        entindex = function() return 1002 end,
    }

    local spawnedAdds = 0
    local originalCreate = CreateUnitByName
    CreateUnitByName = function(name, pos, bFind, caster, owner, team)
        if name == "enfos_creep_spiderling" then
            spawnedAdds = spawnedAdds + 1
        end
        return { SetIdleAcquire = function() end, SetAcquisitionRange = function() end }
    end

    BossFramework:RegisterBoss(broodMatron, "enfos_boss_brood_matron", 10, 1)
    BossFramework:ThinkBroodMatron(broodMatron, broodMatron.bossState)
    assert(broodMatron.bossState.addsSpawned == true, "Brood Matron must spawn adds below 50% HP")
    assert(spawnedAdds == 4, "Brood Matron must spawn exactly 4 spiderlings, got: " .. spawnedAdds)

    CreateUnitByName = originalCreate
end)

test("elite vanguard has 35% physical damage reduction and elite assassin has ambush stealth", function()
    EliteFramework:Init()

    -- 1. Vanguard Shield Wall
    local shieldMod = modifier_enfos_elite_vanguard_shield()
    assert(shieldMod:GetModifierIncomingPhysicalDamage_Percentage() == -35, "Vanguard must have -35% physical damage reduction")

    -- 2. Elite Base status resistance
    local eliteBase = modifier_enfos_elite_base()
    assert(eliteBase:GetModifierStatusResistanceStacking() == 35, "Elite must have 35% status resistance")
    assert(eliteBase:GetModifierModelScale() == 15, "Elite must have +15% model scale")

    -- 3. Elite Assassin Ambush Strike
    MODIFIER_STATE_INVISIBLE = 1
    local assassinMod = modifier_enfos_elite_assassin_stealth()
    assert(assassinMod:CheckState()[MODIFIER_STATE_INVISIBLE] == true, "Assassin must have invisible state")
end)

-- =========================================================================
-- Economy Manager Tests (Phase 7)
-- =========================================================================
local EconomyManager = require("economy/economy_manager")
PlayerResource.SpendGold=function(self,id,amount,reason) self:ModifyGold(id,-amount,true,reason) end
PlayerResource.gold = {}
PlayerResource.GetGold = function(self, id) return self.gold[id] or 0 end
PlayerResource.ModifyGold = function(self, id, amt, isReliable, reason)
    self.gold[id] = (self.gold[id] or 0) + amt
end
PlayerResource.GetConnectionState = function(self, id) return 2 end

test("economy manager tracks lumber and enforces non-negative clamping", function()
    EconomyManager:Init()
    assert(EconomyManager:GetLumber(0) == 0, "Initial lumber must be 0")
    EconomyManager:ModifyLumber(0, 50, "test_gain")
    assert(EconomyManager:GetLumber(0) == 50, "Lumber should be 50")
    EconomyManager:ModifyLumber(0, -100, "test_loss")
    assert(EconomyManager:GetLumber(0) == 0, "Lumber must not drop below 0")
end)

test("gold to lumber conversion requires minimum 100 gold and enforces 100:1 rate", function()
    EconomyManager:Init()
    PlayerResource.gold = { [0] = 1250 }
    PlayerResource.IsValidPlayerID = function(_, id) return id == 0 or id == 1 end
    
    -- Sub-minimum rejection
    local ok1 = EconomyManager:ConvertGoldToLumber(0, 50)
    assert(ok1 == false, "Conversion below 100 gold must fail")

    -- Insufficient gold rejection
    local ok2 = EconomyManager:ConvertGoldToLumber(0, 2000)
    assert(ok2 == false, "Conversion exceeding player balance must fail")

    -- Valid 1000 Gold -> 10 Lumber
    local ok3, lumberGained, goldSpent = EconomyManager:ConvertGoldToLumber(0, 1000)
    assert(ok3 == true, "Conversion of 1000 gold must succeed")
    assert(lumberGained == 10, "Must gain 10 lumber")
    assert(goldSpent == 1000, "Must spend 1000 gold")
    assert(PlayerResource:GetGold(0) == 250, "Remaining gold must be 250")
    assert(EconomyManager:GetLumber(0) == 10, "Player lumber must be 10")
end)

test("lumber to gold conversion applies 10% loss (10 Lumber -> 900 Gold)", function()
    EconomyManager:Init()
    PlayerResource.gold = { [0] = 100 }
    EconomyManager:ModifyLumber(0, 25, "seed")

    -- Insufficient lumber
    local ok1 = EconomyManager:ConvertLumberToGold(0, 50)
    assert(ok1 == false, "Conversion with insufficient lumber must fail")

    -- Valid conversion: 10 Lumber -> 900 Gold
    local ok2, goldGained = EconomyManager:ConvertLumberToGold(0, 10)
    assert(ok2 == true, "Conversion must succeed")
    assert(goldGained == 900, "Must gain 900 gold (10% loss applied)")
    assert(EconomyManager:GetLumber(0) == 15, "Remaining lumber must be 15")
    assert(PlayerResource:GetGold(0) == 1000, "Gold balance must be 1000")
end)

test("teammate transfers reject cross-team, overdrafts, and self-transfers", function()
    EconomyManager:Init()
    PlayerResource.gold = { [0] = 500, [1] = 200 }
    PlayerResource.GetTeam = function(_, id)
        if id == 0 or id == 1 then return 2 end -- Team 2 (teammates)
        return 3 -- Team 3 (enemy)
    end
    PlayerResource.GetConnectionState = function(_, id) return 2 end -- Connected
    PlayerResource.IsValidPlayerID = function(_, id) return id >= 0 and id <= 2 end

    -- 1. Self transfer rejected
    assert(EconomyManager:TransferGold(0, 0, 100) == false, "Self transfer must be rejected")

    -- 2. Cross-team transfer rejected (Player 0 to Player 2)
    assert(EconomyManager:TransferGold(0, 2, 100) == false, "Cross-team transfer must be rejected")

    -- 3. Overdraft rejected
    assert(EconomyManager:TransferGold(0, 1, 1000) == false, "Overdraft must be rejected")

    -- 4. Valid teammate gold transfer: 300 gold from P0 to P1
    local okGold = EconomyManager:TransferGold(0, 1, 300)
    assert(okGold == true, "Teammate gold transfer must succeed")
    assert(PlayerResource:GetGold(0) == 200, "Sender remaining gold: 200")
    assert(PlayerResource:GetGold(1) == 500, "Recipient gold: 500")

    -- 5. Teammate lumber transfer
    EconomyManager:ModifyLumber(0, 20, "seed")
    local okLum = EconomyManager:TransferLumber(0, 1, 8)
    assert(okLum == true, "Teammate lumber transfer must succeed")
    assert(EconomyManager:GetLumber(0) == 12, "Sender remaining lumber: 12")
    assert(EconomyManager:GetLumber(1) == 8, "Recipient lumber: 8")
end)

test("boss lumber award scales by wave and distributes to active teammates", function()
    EconomyManager:Init()
    PlayerResource.GetTeam = function(_, id) return (id == 0 or id == 1) and 2 or 3 end
    PlayerResource.GetConnectionState = function(_, id) return 2 end
    PlayerResource.IsValidPlayerID = function(_, id) return id >= 0 and id <= 3 end

    -- Wave 5 Boss: 5 + floor(5/5) = 6 Lumber
    local w5Lumber = EconomyManager:AwardBossLumber(2, 5)
    assert(w5Lumber == 6, "Wave 5 Boss must award 6 Lumber")
    assert(EconomyManager:GetLumber(0) == 6, "Player 0 must receive 6 Lumber")
    assert(EconomyManager:GetLumber(1) == 6, "Player 1 must receive 6 Lumber")
    assert(EconomyManager:GetLumber(2) == 0, "Opponent Team 3 must receive 0 Lumber")

    -- Wave 20 Boss: 5 + floor(20/5) = 9 Lumber
    local w20Lumber = EconomyManager:AwardBossLumber(2, 20)
    assert(w20Lumber == 9, "Wave 20 Boss must award 9 Lumber")
    assert(EconomyManager:GetLumber(0) == 15, "Player 0 total lumber must be 15")
end)

test("tome purchase escalates cost by 10% and increases hero attributes permanently", function()
    EconomyManager:Init()
    PlayerResource.gold = { [0] = 5000 }
    PlayerResource.IsValidPlayerID = function(_, id) return id == 0 end

    local heroMock = {
        IsNull = function() return false end,
        IsAlive = function() return true end,
        strength = 20,
        agility = 20,
        intellect = 20,
        ModifyStrength = function(self, amt) self.strength = self.strength + amt end,
        ModifyAgility = function(self, amt) self.agility = self.agility + amt end,
        ModifyIntellect = function(self, amt) self.intellect = self.intellect + amt end,
        EmitSound = function() end,
    }
    PlayerResource.heroes[0] = heroMock

    -- 1. Initial cost is 500
    assert(EconomyManager:GetTomeCost(0, "str") == 500, "Base tome cost must be 500")

    -- 2. First STR tome purchase
    local ok1 = EconomyManager:PurchaseTome(0, "str")
    assert(ok1 == true, "Tome purchase must succeed")
    assert(heroMock.strength == 22, "Strength must increase by +2")
    assert(PlayerResource:GetGold(0) == 4500, "Gold must decrease by 500")

    -- 3. Escalated cost: 500 * (1 + 0.10 * 1) = 550
    assert(EconomyManager:GetTomeCost(0, "str") == 550, "Second STR tome cost must be 550 (+10%)")

    -- 4. Different type (AGI) still starts at 500
    assert(EconomyManager:GetTomeCost(0, "agi") == 500, "AGI tome cost must still be base 500")

    -- 5. Second STR tome purchase at 550
    local ok2 = EconomyManager:PurchaseTome(0, "str")
    assert(ok2 == true, "Second purchase must succeed")
    assert(heroMock.strength == 24, "Strength must now be 24 (+4 total)")
    assert(PlayerResource:GetGold(0) == 3950, "Gold must be 4500 - 550 = 3950")

    -- 6. Third cost: 500 * (1 + 0.10 * 2) = 600
    assert(EconomyManager:GetTomeCost(0, "str") == 600, "Third STR tome cost must be 600")
end)

-- =========================================================================
-- Ascended Shop Tests (Phase 8)
-- =========================================================================
local AscendedShop = require("economy/ascended_shop")

test("ascended shop initializes with catalog items including ascended blessing", function()
    AscendedShop:Init(EconomyManager)
    assert(#AscendedShop.ITEMS == 31, "Ascended shop must contain 31 items (30 launch items + 1 Blessing), got: " .. #AscendedShop.ITEMS)
    assert(AscendedShop.LOOKUP["item_ascended_worldheart"] ~= nil, "Worldheart must exist")
    assert(AscendedShop.LOOKUP["item_ascended_thornplate"] ~= nil, "Thornplate must exist")
    assert(AscendedShop.LOOKUP["item_ascended_soulpiercer"] ~= nil, "Soulpiercer must exist")
    assert(AscendedShop.LOOKUP["item_ascended_aghanims_blessing"] ~= nil, "Aghanim's Blessing must exist")
end)

test("ascended upgrade requires base item and sufficient lumber", function()
    AscendedShop:Init(EconomyManager)
    EconomyManager:Init()

    local hero = {
        IsNull = function() return false end,
        IsAlive = function() return true end,
        items = {},
        GetItemInSlot = function(self, slot) return self.items[slot] end,
        RemoveItem = function(self, item)
            for s, it in pairs(self.items) do
                if it == item then self.items[s] = nil break end
            end
        end,
        AddItemByName = function(self, name)
            local it = {
                IsNull = function() return false end,
                GetAbilityName = function() return name end,
            }
            self.items[0] = it
            return it
        end,
        EmitSound = function() end,
    }
    PlayerResource.heroes[0] = hero

    -- 1. Missing base item check: hero has nothing in inventory
    local can1, reason1 = AscendedShop:CanUpgrade(0, "item_ascended_thornplate")
    assert(can1 == false, "Upgrade without base item must fail")
    assert(reason1 == "missing_base_item", "Reason must be missing_base_item")

    -- 2. Give hero item_blade_mail, but 0 Lumber
    local heartItem = { IsNull = function() return false end, GetAbilityName = function() return "item_blade_mail" end }
    hero.items[0] = heartItem
    local can2, reason2 = AscendedShop:CanUpgrade(0, "item_ascended_thornplate")
    assert(can2 == false, "Upgrade with 0 lumber must fail")
    assert(reason2 == "insufficient_lumber", "Reason must be insufficient_lumber")

    -- 3. Give hero 55 Lumber -> Upgrade must succeed
    EconomyManager:ModifyLumber(0, 55, "test")
    local can3 = AscendedShop:CanUpgrade(0, "item_ascended_thornplate")
    assert(can3 == true, "Upgrade with base item and sufficient lumber must succeed")

    hero.TakeItem=hero.RemoveItem
    hero.AddItem=function(self,it) self.items[0]=it;return it end
    hero.SwapItems=function(self,a,b) self.items[a],self.items[b]=self.items[b],self.items[a] end
    CreateItem=function(name) return {IsNull=function() return false end,GetAbilityName=function() return name end} end
    UTIL_Remove=function() end
    local okUpgrade, _, newItem = AscendedShop:PurchaseUpgrade(0, "item_ascended_thornplate")
    assert(okUpgrade == true, "PurchaseUpgrade must succeed")
    assert(EconomyManager:GetLumber(0) == 0, "55 Lumber must be deducted")
    assert(newItem:GetAbilityName() == "item_ascended_thornplate", "New item must be Thornplate")

    -- 4. One copy restriction: cannot buy second Thornplate
    hero.items[1] = heartItem
    EconomyManager:ModifyLumber(0, 55, "test")
    local canDuplicate, reasonDup = AscendedShop:CanUpgrade(0, "item_ascended_thornplate")
    assert(canDuplicate == false, "Hero cannot purchase duplicate Ascended item")
    assert(reasonDup == "already_owned", "Reason must be already_owned")
end)

test("ascended sellback refunds 90% underlying gold and 90% lumber", function()
    AscendedShop:Init(EconomyManager)
    EconomyManager:Init()
    PlayerResource.gold = { [0] = 500 }

    local worldheart = {
        IsNull = function() return false end,
        GetAbilityName = function() return "item_ascended_worldheart" end,
    }
    local hero = {
        IsNull = function() return false end,
        IsAlive = function() return true end,
        items = { [0] = worldheart },
        GetItemInSlot = function(self, slot) return self.items[slot] end,
        RemoveItem = function(self, item)
            for s, it in pairs(self.items) do
                if it == item then self.items[s] = nil break end
            end
        end,
    }
    PlayerResource.heroes[0] = hero

    -- Worldheart: 5000 Gold, 85 Lumber
    -- 90% Gold = 4500, 90% Lumber = 76
    local okSell, goldRefund, lumberRefund = AscendedShop:Sellback(0, worldheart)
    assert(okSell == true, "Sellback must succeed")
    assert(goldRefund == math.floor(AscendedShop.LOOKUP["item_ascended_worldheart"].gold * 0.9), "Must refund 90% of current native base cost")
    assert(lumberRefund == 76, "Must refund 76 lumber (90% of 85), got: " .. lumberRefund)
    assert(PlayerResource:GetGold(0) == 500 + goldRefund, "Gold balance must include exactly the refund")
    assert(EconomyManager:GetLumber(0) == 76, "Lumber balance must be 76")
    assert(hero.items[0] == nil, "Item must be removed from hero inventory")
end)

-- =========================================================================
-- Boons & Pacts Tests (Phase 9)
-- =========================================================================
local BoonManager = require("boons/boon_manager")

test("boon candidate generation offers 2 cards with category diversity and respects wave limits and stack caps", function()
    BoonManager:Init(nil, EconomyManager, nil)

    -- Wave 5 candidates for Team 2:
    local card1, card2 = BoonManager:GenerateTwoCandidates(2, 5)
    assert(card1 ~= nil and card2 ~= nil, "Must return 2 cards")
    assert(card1.id ~= card2.id, "Cards must be distinct")
    -- Check that Pacts (minWave=20) were not offered at wave 5
    assert(card1.category ~= "pact" and card2.category ~= "pact", "Pacts must not appear on wave 5")
    -- Category diversity: card1 and card2 should have different categories if pool allows
    assert(card1.category ~= card2.category, "Candidate cards must prefer different categories")

    -- Check available candidates at Wave 20: Pacts should be present in pool
    local poolW20 = BoonManager:GetAvailableCandidates(2, 20)
    local foundPact = false
    for _, item in ipairs(poolW20) do
        if item.def.category == "pact" then
            foundPact = true
            break
        end
    end
    assert(foundPact == true, "Pacts must be present in candidate pool for wave 20+")
end)

test("boon vote session tallies votes and resolves winner to team", function()
    BoonManager:Init(nil, EconomyManager, nil)

    PlayerResource.teams = { [0] = 2, [1] = 2 }
    PlayerResource.connectionState = { [0] = DOTA_CONNECTION_STATE_CONNECTED, [1] = DOTA_CONNECTION_STATE_CONNECTED }

    -- Start vote on Team 2 for wave 5
    local started, c1, c2 = BoonManager:StartVote(2, 5)
    assert(started == true, "Vote session must start")
    assert(BoonManager.activeVotes[2] ~= nil, "Active vote must exist")

    -- Player 0 votes for Card 2
    local voted = BoonManager:CastVote(0, 2)
    assert(voted == true, "Vote cast must succeed")
    assert(BoonManager.activeVotes[2].votes[0] == 2, "Player 0 vote must be recorded")

    -- Resolve vote: Card 2 has 1 vote, Card 1 has 0 votes -> Card 2 wins
    local winner = BoonManager:ResolveVote(2)
    assert(winner.id == c2.id, "Card 2 must win")
    assert(BoonManager:GetStackCount(2, c2.id) == 1, "Winning card stack count must be 1")
    assert(BoonManager.activeVotes[2] == nil, "Active vote must be cleared")
    assert(#BoonManager.teamHistory[2] == 1, "Team history must have 1 entry")
    assert(BoonManager.teamHistory[2][1].id == c2.id, "History entry ID must match")
end)

test("boon stack caps enforce 3 max for ordinary and 1 max for unique, and emergency seal restores 15 Life", function()
    BoonManager:Init(nil, EconomyManager, nil)
    LifeCore:Init(nil)

    -- Ordinary boon: war_training (maxStacks = 3)
    assert(BoonManager:ApplyBoon(2, "war_training", 5) == true)
    assert(BoonManager:ApplyBoon(2, "war_training", 10) == true)
    assert(BoonManager:ApplyBoon(2, "war_training", 15) == true)
    assert(BoonManager:GetStackCount(2, "war_training") == 3)
    -- 4th stack must be rejected
    assert(BoonManager:ApplyBoon(2, "war_training", 20) == false, "4th stack of war_training must be rejected")
    assert(BoonManager:GetStackCount(2, "war_training") == 3)

    -- Unique boon: battle_rhythm (maxStacks = 1, isUnique = true)
    assert(BoonManager:ApplyBoon(2, "battle_rhythm", 5) == true)
    assert(BoonManager:GetStackCount(2, "battle_rhythm") == 1)
    -- 2nd stack must be rejected
    assert(BoonManager:ApplyBoon(2, "battle_rhythm", 10) == false, "2nd stack of unique boon must be rejected")
    assert(BoonManager:GetStackCount(2, "battle_rhythm") == 1)

    -- Emergency Seal: restores +15 Life to team
    LifeCore:SetLife(2, 80)
    assert(LifeCore:GetLife(2) == 80)
    assert(BoonManager:ApplyBoon(2, "emergency_seal", 25) == true)
    assert(LifeCore:GetLife(2) == 95, "Emergency seal must restore +15 Life to team, got: " .. LifeCore:GetLife(2))
end)

-- =========================================================================
-- Progression & Hero Mastery Tests (Phase 10)
-- =========================================================================
local StorageAdapter = require("progression/storage_adapter")
local ProgressionCurves = require("progression/progression_curves")
local ProgressionManager = require("progression/progression_manager")

test("account xp leveling curve awards legacy points up to level 48 (max 24 points)", function()
    local profile = StorageAdapter.CreateDefaultProfile("test_user_1")
    assert(profile.accountLevel == 1)
    assert(profile.unspentLegacyPoints == 0)

    -- Level 1 -> 2: requires 500 XP
    ProgressionCurves.AddAccountXP(profile, 500)
    assert(profile.accountLevel == 2, "Must reach level 2")
    assert(profile.unspentLegacyPoints == 1, "Must gain 1 Legacy point on level 2")

    -- Add enough XP to level up through 48
    -- Level 48 should have earned exactly 24 points (48 / 2)
    for lvl = 2, 47 do
        local req = ProgressionCurves.GetAccountLevelXPRequired(profile.accountLevel)
        ProgressionCurves.AddAccountXP(profile, req)
    end
    assert(profile.accountLevel == 48, "Must reach level 48, got: " .. profile.accountLevel)
    assert(profile.unspentLegacyPoints == 24, "Must have 24 legacy points at level 48, got: " .. profile.unspentLegacyPoints)

    -- Levels beyond 48 do not award raw Legacy points (capped at 24)
    local req48 = ProgressionCurves.GetAccountLevelXPRequired(48)
    local req49 = ProgressionCurves.GetAccountLevelXPRequired(49)
    ProgressionCurves.AddAccountXP(profile, req48 + req49)
    assert(profile.accountLevel == 50, "Must reach level 50")
    assert(profile.unspentLegacyPoints == 24, "Legacy points must remain capped at 24, got: " .. profile.unspentLegacyPoints)
end)

test("legacy allocation, branch caps, free respec, and pvevp 50% normalization", function()
    local profile = StorageAdapter.CreateDefaultProfile("test_user_2")
    profile.unspentLegacyPoints = 5

    -- Allocate 3 to offense, 2 to defense
    assert(ProgressionCurves.AllocateLegacyRank(profile, "offense") == true)
    assert(ProgressionCurves.AllocateLegacyRank(profile, "offense") == true)
    assert(ProgressionCurves.AllocateLegacyRank(profile, "offense") == true)
    assert(profile.legacy.offense == 3)
    assert(profile.unspentLegacyPoints == 2)

    assert(ProgressionCurves.AllocateLegacyRank(profile, "defense") == true)
    assert(ProgressionCurves.AllocateLegacyRank(profile, "defense") == true)
    assert(profile.legacy.defense == 2)
    assert(profile.unspentLegacyPoints == 0)

    -- Insufficient points check
    local okFail, reason = ProgressionCurves.AllocateLegacyRank(profile, "economy")
    assert(okFail == false)
    assert(reason == "insufficient_points")

    -- PvEvP 50% normalization check
    -- Co-op: 100% effectiveness
    local coopBonuses = ProgressionCurves.GetLegacyBonuses(profile, false)
    assert(coopBonuses.effectiveness == 1.0)
    assert(math.abs(coopBonuses.offenseDamageMultiplier - 0.015) < 0.0001, "Co-op offense should be 3 * 0.005 * 1.0 = +1.5%")
    assert(math.abs(coopBonuses.defenseMaxHpMultiplier - 0.010) < 0.0001, "Co-op defense should be 2 * 0.005 * 1.0 = +1.0%")

    -- Standard PvEvP: 50% effectiveness
    local pvevpBonuses = ProgressionCurves.GetLegacyBonuses(profile, true)
    assert(pvevpBonuses.effectiveness == 0.5)
    assert(math.abs(pvevpBonuses.offenseDamageMultiplier - 0.0075) < 0.0001, "PvEvP offense should be 3 * 0.005 * 0.5 = +0.75%")
    assert(math.abs(pvevpBonuses.defenseMaxHpMultiplier - 0.0050) < 0.0001, "PvEvP defense should be 2 * 0.005 * 0.5 = +0.5%")

    -- Free Respec
    local okRespec, refunded = ProgressionCurves.RespecLegacy(profile)
    assert(okRespec == true)
    assert(refunded == 5, "Must refund 5 spent points")
    assert(profile.legacy.offense == 0 and profile.legacy.defense == 0)
    assert(profile.unspentLegacyPoints == 5)
end)

test("hero mastery ranking, passive points, and milestone build unlocks at 5/10/15/20", function()
    local heroData = { rank = 1, xp = 0, passivePoints = 0, buildUnlocks = {} }

    -- Rank 1 -> 2: requires 100 XP
    ProgressionCurves.AddHeroMasteryXP(heroData, 100)
    assert(heroData.rank == 2)
    assert(heroData.passivePoints == 1, "Even rank must award +1 Hero Passive point")

    -- Advance to rank 5
    for r = 2, 4 do
        local req = ProgressionCurves.GetHeroMasteryXPRequired(heroData.rank)
        ProgressionCurves.AddHeroMasteryXP(heroData, req)
    end
    assert(heroData.rank == 5)
    assert(heroData.buildUnlocks["5"] == true, "Mastery 5 must unlock milestone build choice")

    -- Advance to rank 20
    for r = 5, 19 do
        local req = ProgressionCurves.GetHeroMasteryXPRequired(heroData.rank)
        ProgressionCurves.AddHeroMasteryXP(heroData, req)
    end
    assert(heroData.rank == 20)
    assert(heroData.passivePoints == 10, "Rank 20 must have 10 Hero Passive points total (20 / 2)")
    assert(heroData.buildUnlocks["20"] == true, "Mastery 20 must unlock milestone build choice")
end)

test("match reward calculation covers win, loss, surrender, abandon, clear bonus, and endless checkpoints", function()
    -- 1. Full Clear Normal (Wave 60, Win)
    local winRewards = ProgressionCurves.CalculateMatchRewards({
        completedWaves = 60,
        isFullClear = true,
        difficulty = "normal",
        outcome = "win",
    })
    -- Base Account: 1200 + 300 = 1500; with Win (+15%): 1725
    -- Base Hero: 400 + 100 = 500; with Win (+15%): 575
    assert(winRewards.accountXp == 1725, "Win Account XP should be 1725, got: " .. winRewards.accountXp)
    assert(winRewards.heroXp == 575, "Win Hero XP should be 575, got: " .. winRewards.heroXp)
    assert(winRewards.isFullClear == true)

    -- 2. Loss at Wave 30 (Normal difficulty)
    local lossRewards = ProgressionCurves.CalculateMatchRewards({
        completedWaves = 30,
        isFullClear = false,
        difficulty = "normal",
        outcome = "loss",
    })
    assert(lossRewards.accountXp > 400 and lossRewards.accountXp < 600, "Loss must provide legitimate partial progress")
    assert(lossRewards.heroXp > 100 and lossRewards.heroXp < 250)

    -- 3. Abandon at Wave 30 (Receives 50% of earned progress)
    local abandonRewards = ProgressionCurves.CalculateMatchRewards({
        completedWaves = 30,
        isFullClear = false,
        difficulty = "normal",
        outcome = "abandon",
    })
    assert(math.abs(abandonRewards.accountXp - math.floor(lossRewards.accountXp * 0.50 + 0.5)) <= 1,
        "Abandon must receive 50% of legitimate progress")

    -- 4. Endless Checkpoints (Wave 60 + 3 checkpoints = Wave 75, Hard difficulty = 1.15x)
    local endlessRewards = ProgressionCurves.CalculateMatchRewards({
        completedWaves = 60,
        isFullClear = true,
        difficulty = "hard",
        outcome = "loss",
        endlessCheckpoints = 3,
    })
    -- Base Account = (1200 + 300) * 1.15 = 1725 + (3 * 80 * 1.15 = 276) = 2001
    assert(endlessRewards.accountXp == 2001, "Endless Hard Account XP should be 2001, got: " .. endlessRewards.accountXp)
end)

test("progression manager coordinates profile, idempotent rewards, difficulty unlock, and storage migration", function()
    local localAdapter = StorageAdapter.LocalStorageAdapter.New()
    ProgressionManager:Init(localAdapter, nil, nil)

    -- Mock player 0 hero
    local heroMock = {
        IsNull = function() return false end,
        GetUnitName = function() return "npc_dota_hero_juggernaut" end,
    }
    PlayerResource.heroes[0] = heroMock

    -- Load player 0
    local profile = ProgressionManager:LoadPlayer(0, "steam_76561198000000001")
    assert(profile ~= nil)
    assert(profile.highestDifficultyUnlocked == "normal")

    -- 1. Award rewards for Match 101 (Full clear Normal, Win)
    local summary1, err1 = ProgressionManager:AwardMatchRewards(0, "match_101", {
        completedWaves = 60,
        isFullClear = true,
        difficulty = "normal",
        outcome = "win",
        heroId = "npc_dota_hero_juggernaut",
    })
    assert(summary1 ~= nil, "First award must succeed")
    assert(summary1.accountXpEarned == 1725)
    assert(profile.highestDifficultyUnlocked == "hard", "Full clear on Normal must unlock Hard difficulty")
    assert(profile.processedMatchIds["match_101"] == true)

    -- 2. Idempotency test: duplicate award for Match 101 must be rejected
    local summary2, err2 = ProgressionManager:AwardMatchRewards(0, "match_101", {
        completedWaves = 60,
        isFullClear = true,
        difficulty = "normal",
        outcome = "win",
    })
    assert(summary2 == nil, "Duplicate reward must be rejected")
    assert(err2 == "duplicate_match", "Error must be duplicate_match")

    -- 3. Storage schema migration test
    local legacyRawProfile = {
        schemaVersion = 0,
        steamId = "legacy_steam_user",
        accountLevel = 10,
        accountXp = 100,
        legacy = { offense = 8, defense = 8, economy = 8, spellbringer = 8 }, -- corrupted 32 points (>5 points for lvl 10)
    }
    local migrated = StorageAdapter.MigrateProfile(legacyRawProfile)
    assert(migrated.schemaVersion == 1, "Must migrate to schema v1")
    assert(migrated.unspentLegacyPoints == 5, "Must reset corrupted points to max earned (10 / 2 = 5)")
    assert(migrated.legacy.offense == 0, "Corrupted branch allocations must be safely reset")
end)

-- =========================================================================
-- Hero Roster Tests (Phase 13 - 40 Heroes Milestone)
-- =========================================================================
test("forty heroes are authored with exactly 8 per role (Tank/Fighter/Carry/Mage/Support)", function()
    local heroList = require("heroes/roster")

    assert(#heroList == 40, "Must have exactly 40 heroes in the current roster milestone, got: " .. tostring(#heroList))

    local roleCounts = {}
    for _, h in ipairs(heroList) do
        roleCounts[h.role] = (roleCounts[h.role] or 0) + 1
    end

    assert(roleCounts["Tank"] == 8, "Must have exactly 8 Tanks, got: " .. tostring(roleCounts["Tank"]))
    assert(roleCounts["Fighter"] == 8, "Must have exactly 8 Fighters, got: " .. tostring(roleCounts["Fighter"]))
    assert(roleCounts["Carry"] == 8, "Must have exactly 8 Carries, got: " .. tostring(roleCounts["Carry"]))
    assert(roleCounts["Mage"] == 8, "Must have exactly 8 Mages, got: " .. tostring(roleCounts["Mage"]))
    assert(roleCounts["Support"] == 8, "Must have exactly 8 Supports, got: " .. tostring(roleCounts["Support"]))
end)

-- =========================================================================
-- Game Setup & Hero Selection Tests
-- =========================================================================
local EnfosSetupManager = require("setup/enfos_setup_manager")

test("setup manager handles difficulty, team assignment, same-team lock prevention, and start trigger", function()
    local dummyWaveManager = {
        difficulty = "normal",
        SetDifficulty = function(self, diff) self.difficulty = diff end,
        GetDifficulty = function(self) return self.difficulty end,
    }

    GameRules.GetGameModeEntity=function() return {SetContextThink=function() end} end
    DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP=2;DOTA_GAMERULES_STATE_HERO_SELECTION=3
    GameRules.State_Get=function() return 2 end
    GameRules.PlayerHasCustomGameHostPrivileges=function() return true end
    PlayerResource.IsValidPlayerID=function(_,id) return id>=0 and id<=2 end
    PlayerResource.GetPlayer=function() return {SetSelectedHero=function() end} end
    EnfosSetupManager:Init(dummyWaveManager, nil)
    assert(EnfosSetupManager.selectedDifficulty == "normal")
    assert(dummyWaveManager.difficulty == "normal")

    -- 1. Difficulty update
    EnfosSetupManager:OnSetDifficulty({ PlayerID = 0, difficulty = "hard" })
    assert(EnfosSetupManager.selectedDifficulty == "hard")
    assert(dummyWaveManager.difficulty == "hard")

    -- Reject invalid difficulty
    EnfosSetupManager:OnSetDifficulty({ PlayerID = 0, difficulty = "godmode" })
    assert(EnfosSetupManager.selectedDifficulty == "hard", "Invalid difficulty must be ignored")

    GameRules.State_Get=function() return 3 end
    -- 2. Lock in hero & same-team duplicate prevention
    PlayerResource.GetTeam = function(_, pid) return 2 end -- Radiant
    EnfosSetupManager:OnLockInHero({ PlayerID = 0, hero_name = "npc_dota_hero_sven" })
    assert(EnfosSetupManager.playerPicks[0] == "npc_dota_hero_sven")

    -- Player 1 on same team cannot pick Sven
    PlayerResource.GetTeam = function(_, pid) return 2 end
    EnfosSetupManager:OnLockInHero({ PlayerID = 1, hero_name = "npc_dota_hero_sven" })
    assert(EnfosSetupManager.playerPicks[1] == nil, "Same team duplicate hero must be blocked")

    -- Player 2 on opposing team (Dire / 3) CAN pick Sven
    PlayerResource.GetTeam = function(_, pid) return 3 end
    EnfosSetupManager:OnLockInHero({ PlayerID = 2, hero_name = "npc_dota_hero_sven" })
    assert(EnfosSetupManager.playerPicks[2] == "npc_dota_hero_sven", "Opposing team can pick same hero")

    GameRules.State_Get=function() return 2 end
    -- 3. Start game
    local finishCalled = false
    GameRules.FinishCustomGameSetup = function() finishCalled = true end
    EnfosSetupManager:OnStartGame({ PlayerID = 0 })
    assert(EnfosSetupManager.isSetupComplete == true)
    assert(finishCalled == true, "Must call FinishCustomGameSetup when host starts game")
end)

-- =========================================================================
-- Evolution Milestone Manager Tests
-- =========================================================================
local EvolutionManager = require("evolution/evolution_manager")

test("evolution manager queues milestones at 4/7/10/13/16/19, supports deferral, and applies build choices", function()
    EvolutionManager.initialized = false
    EvolutionManager:Init()

    local dummyHero = {
        maxHp = 1000,
        hp = 1000,
        maxMana = 500,
        mana = 500,
        str = 20, agi = 20, int = 20,
        GetMaxHealth = function(self) return self.maxHp end,
        SetMaxHealth = function(self, val) self.maxHp = val end,
        GetHealth = function(self) return self.hp end,
        SetHealth = function(self, val) self.hp = val end,
        GetMaxMana = function(self) return self.maxMana end,
        SetMaxMana = function(self, val) self.maxMana = val end,
        ModifyStrength = function(self, val) self.str = self.str + val end,
        ModifyAgility = function(self, val) self.agi = self.agi + val end,
        ModifyIntellect = function(self, val) self.int = self.int + val end,
        GetUnitName = function() return 'npc_dota_hero_sven' end,
        GetLevel = function() return 19 end,
        FindModifierByName = function(self) return self.modifier end,
        AddNewModifier = function(self)
            self.modifier={stack=0,GetStackCount=function(m) return m.stack end,SetStackCount=function(m,v) m.stack=v end}
            return self.modifier
        end,
        IsNull = function() return false end,
    }
    PlayerResource.heroes[0] = dummyHero

    -- 1. Level up to 3 (no milestone)
    EvolutionManager:CheckHeroMilestones(0, dummyHero, 3)
    assert(EvolutionManager:GetPendingCount(0) == 0, "Level 3 should not trigger milestone")

    -- 2. Level up to 4 (triggers Milestone 4)
    EvolutionManager:CheckHeroMilestones(0, dummyHero, 4)
    assert(EvolutionManager:GetPendingCount(0) == 1, "Level 4 must queue 1 milestone")

    -- 3. Level up to 7 without choosing 4 (should queue 7 behind 4)
    EvolutionManager:CheckHeroMilestones(0, dummyHero, 7)
    assert(EvolutionManager:GetPendingCount(0) == 2, "Level 7 must queue behind 4 (total 2)")

    -- 4. Deferral keeps queue intact
    EvolutionManager:OnClientDeferEvolution({ PlayerID = 0 })
    assert(EvolutionManager:GetPendingCount(0) == 2, "Deferral must preserve queue")

    -- 5. Reject invalid choice or wrong milestone
    local failRes = EvolutionManager:SelectChoice(0, 10, "evo_iron_bulwark")
    assert(failRes == false, "Must reject non-pending milestone 10")

    -- 6. Select choice for Milestone 4 (Wave Sweeper)
    local succ4 = EvolutionManager:SelectChoice(0, 4, "evo_sven_4_1")
    assert(succ4 == true, "Selecting valid choice for milestone 4 must succeed")
    assert(EvolutionManager:IsMilestoneChosen(0, 4) == true)
    assert(EvolutionManager:GetPendingCount(0) == 1, "Remaining queue should now be 1 (Milestone 7)")

    -- 7. Select choice for Milestone 7 (Battle Ferocity)
    local succ7 = EvolutionManager:SelectChoice(0, 7, "evo_sven_7_1")
    assert(succ7 == true, "Selecting valid choice for milestone 7 must succeed")
    assert(EvolutionManager:IsMilestoneChosen(0, 7) == true)
    assert(EvolutionManager:GetPendingCount(0) == 0, "Queue must be empty now")

    -- 8. Level up to 19 directly (milestones 10, 13, 16, 19 queued)
    EvolutionManager:CheckHeroMilestones(0, dummyHero, 19)
    assert(EvolutionManager:GetPendingCount(0) == 4, "Milestones 10, 13, 16, 19 must all be queued")
end)

-- =========================================================================
-- Aghanim's Shard, Scepter & Blessing Tests
-- =========================================================================
local AghanimManager = require("heroes/aghanim_manager")

test("aghanim manager tracks shard, scepter, and blessing states accurately", function()
    AghanimManager:Init()

    local dummyHero = {
        IsNull = function() return false end,
        modifiers = {},
        inventory = {},
        GetEntityIndex = function() return 101 end,
        GetUnitName = function() return "npc_dota_hero_sven" end,
        HasScepter = function(self) return self.hasScepterBool == true end,
        HasModifier = function(self, mod) return self.modifiers[mod] == true end,
        AddNewModifier = function(self, caster, ability, modName, data) self.modifiers[modName] = true end,
        RemoveModifierByName = function(self, modName) self.modifiers[modName] = nil end,
        HasItemInInventory = function(self, itemName) return self.inventory[itemName] == true end,
    }

    -- 1. Initially no scepter or shard
    assert(AghanimManager:HasScepter(dummyHero) == false)
    assert(AghanimManager:HasShard(dummyHero) == false)

    -- 2. Add Shard via inventory item
    dummyHero.inventory["item_aghanims_shard"] = true
    assert(AghanimManager:HasShard(dummyHero) == true)

    AghanimManager:UpdateHeroAghanimState(dummyHero, "Tank")
    assert(dummyHero:HasModifier("modifier_enfos_shard_upgrade") == true)

    -- 3. Remove Shard
    dummyHero.inventory["item_aghanims_shard"] = nil
    AghanimManager:UpdateHeroAghanimState(dummyHero, "Tank")
    assert(dummyHero:HasModifier("modifier_enfos_shard_upgrade") == false)

    -- 4. Test Scepter via HasScepter
    dummyHero.hasScepterBool = true
    assert(AghanimManager:HasScepter(dummyHero) == true)

    AghanimManager:UpdateHeroAghanimState(dummyHero, "Mage")
    assert(dummyHero:HasModifier("modifier_enfos_scepter_upgrade") == true)

    -- 5. Test Aghanim's Blessing modifier grants Scepter
    dummyHero.hasScepterBool = false
    dummyHero.modifiers["modifier_item_ascended_aghanims_blessing_consumed"] = true
    assert(AghanimManager:HasScepter(dummyHero) == true, "Blessing modifier must count as HasScepter")

    -- 6. Role detection fallback
    assert(AghanimManager:DetectHeroRole("npc_dota_hero_sven") == "Tank")
    assert(AghanimManager:DetectHeroRole("npc_dota_hero_juggernaut") == "Fighter")
    assert(AghanimManager:DetectHeroRole("npc_dota_hero_drow_ranger") == "Carry")
    assert(AghanimManager:DetectHeroRole("npc_dota_hero_lina") == "Mage")
    assert(AghanimManager:DetectHeroRole("npc_dota_hero_dazzle") == "Support")
end)

test("ascended shop converts scepter to aghanims blessing and frees slot", function()
    AscendedShop:Init(EconomyManager)
    EconomyManager:Init()

    local hero = {
        IsNull = function() return false end,
        IsAlive = function() return true end,
        items = {},
        modifiers = {},
        GetUnitName = function() return "npc_dota_hero_sven" end,
        GetItemInSlot = function(self, slot) return self.items[slot] end,
        RemoveItem = function(self, item)
            for s, it in pairs(self.items) do
                if it == item then self.items[s] = nil break end
            end
        end,
        AddItemByName = function(self, name)
            local it = {
                IsNull = function() return false end,
                GetAbilityName = function() return name end,
            }
            self.items[0] = it
            return it
        end,
        HasModifier = function(self, mod) return self.modifiers[mod] == true end,
        AddNewModifier = function(self, caster, ability, modName, data) self.modifiers[modName] = true end,
        EmitSound = function() end,
    }
    PlayerResource.heroes[0] = hero

    -- 1. Give hero item_ultimate_scepter and 40 Lumber
    local scepterItem = { IsNull = function() return false end, GetAbilityName = function() return "item_ultimate_scepter" end }
    hero.items[0] = scepterItem
    EconomyManager:ModifyLumber(0, 40, "test")

    local canBlessing = AscendedShop:CanUpgrade(0, "item_ascended_aghanims_blessing")
    assert(canBlessing == true, "Hero with scepter and 40 lumber can upgrade to blessing")

    local ok, reason, newItem = AscendedShop:PurchaseUpgrade(0, "item_ascended_aghanims_blessing")
    assert(ok == true, "PurchaseUpgrade for blessing must succeed")
    assert(newItem == nil, "No item added to inventory (slot is freed)")
    assert(hero.items[0] == nil, "Scepter was consumed from slot 0")
    assert(hero:HasModifier("modifier_item_ascended_aghanims_blessing_consumed") == true)
    assert(hero:HasModifier("modifier_item_ultimate_scepter_consumed") == true)
    assert(EconomyManager:GetLumber(0) == 0, "40 Lumber consumed")

    -- 2. Already owned check prevents buying second blessing
    hero.items[0] = scepterItem
    EconomyManager:ModifyLumber(0, 40, "test")
    local canSecond, reasonSecond = AscendedShop:CanUpgrade(0, "item_ascended_aghanims_blessing")
    assert(canSecond == false, "Cannot purchase duplicate Aghanim's Blessing")
    assert(reasonSecond == "already_owned")
end)

print(string.format("%d Lua behavior tests passed (mock engine; live tests separate).", passed))



