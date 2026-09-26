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
print(string.format("%d Lua behavior tests passed (mock engine; live tests separate).", passed))
