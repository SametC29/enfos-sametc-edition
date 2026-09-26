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
    GetTeam = function(_, id) return id == 0 and 2 or 3 end,
    GetSelectedHeroEntity = function(self, id) return self.heroes[id] end,
    heroes = {},
}
local function mode()
    return setmetatable({playerCouriers = {}, playerHeroes = {}, deliveryRequested = {}, pendingCouriers = {}}, {__index = EnfosSametC})
end
test("ownerless courier is not assigned to player zero", function()
    local m, courier = mode(), unit()
    function courier:GetPlayerOwnerID() return -1 end
    function courier:GetTeamNumber() return 2 end
    assert(not m:ConfigureCourier(courier, -1))
    assert(m.playerCouriers[0] == nil)
    assert(not m:ConfigureCourier(courier, 0))
end)
test("another player's courier ability cannot trigger delivery", function()
    local m, courier, other = mode(), unit(), unit()
    m.playerCouriers[0] = courier
    fakeEntities[100] = {IsNull = function() return false end, GetAbilityName = function() return "courier_transfer_items" end, GetCaster = function() return other end}
    assert(m:OrderFilter({issuer_player_id_const = 0, entindex_ability = 100}) == false)
    assert(m.deliveryRequested[0] == nil)
end)
test("take-only retrieves without beginning delivery or passing native command", function()
    local m, courier, hero = mode(), unit(), unit(14)
    local original = item(); hero.slots[9] = original
    function courier:GetPlayerOwnerID() return 0 end
    function courier:GetTeamNumber() return 2 end
    function hero:GetTeamNumber() return 2 end
    m.playerCouriers[0] = courier; PlayerResource.heroes[0] = hero
    fakeEntities[101] = {IsNull = function() return false end, GetAbilityName = function() return "courier_take_stash_items" end, GetCaster = function() return courier end}
    assert(m:OrderFilter({issuer_player_id_const = 0, entindex_ability = 101}) == false)
    assert(courier.slots[0] == original and hero.slots[9] == nil)
    assert(m.deliveryRequested[0] == nil)
end)
test("stopping the courier cancels pending delivery", function()
    local m, courier = mode(), unit()
    m.playerCouriers[0] = courier; m.deliveryRequested[0] = true; fakeEntities[102] = courier
    assert(m:OrderFilter({issuer_player_id_const = 0, order_type = DOTA_UNIT_ORDER_STOP, units = {["0"] = 102}}))
    assert(m.deliveryRequested[0] == nil)
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

test("unit cap scales accurately with player count", function()
    assert(WaveDefs:GetUnitCap(1) == 30)
    assert(WaveDefs:GetUnitCap(2) == 60)
    assert(WaveDefs:GetUnitCap(3) == 90)
    assert(WaveDefs:GetUnitCap(4) == 120)
    assert(WaveDefs:GetUnitCap(5) == 150)
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

    local ok = SpellbringerService:CastSpell(0, "spellbringer_purification", Vector(0,0,0), nil)
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
    local ok = SpellbringerService:CastSpell(0, "spellbringer_future_reinforcements", Vector(0,0,0), nil)
    assert(ok == true)
    assert(#spawnedUnits == 5, "Future reinforcements must summon exactly 5 fighters, got: " .. #spawnedUnits)

    for _, unit in ipairs(spawnedUnits) do
        assert(unit.name == "enfos_spellbringer_reinforcement")
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

print(string.format("%d Lua behavior tests passed (mock engine; live tests separate).", passed))


