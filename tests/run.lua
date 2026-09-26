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
-- Exercise the actual game-mode order filter, not a copy of its implementation.
function class() return {} end
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
-- =========================================================================
function Vector(x, y, z) return {x = x, y = y, z = z} end
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

print(string.format("%d Lua behavior tests passed (mock engine; live tests separate).", passed))

