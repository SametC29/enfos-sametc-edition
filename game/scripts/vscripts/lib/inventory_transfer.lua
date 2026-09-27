-- Same-entity transfers only: never recreate items or copy charges.
local Transfer = {}

local function valid(entity)
    return entity ~= nil and not entity:IsNull()
end

local function find(unit, item, first, last)
    if not valid(item) then return nil end
    for slot = first, last do
        if unit:GetItemInSlot(slot) == item then return slot end
    end
end

local function freeSlot(unit, first, last)
    for slot = first, last do
        if unit:GetItemInSlot(slot) == nil then return slot end
    end
end

-- Reserve destination capacity before detaching. On rejection restore the exact
-- source slot (especially important for the hero's stash, slots 9..14).
function Transfer.Move(source, destination, sourceSlot, destinationFirst, destinationLast)
    if not valid(source) or not valid(destination) or source == destination then return false end
    local item = source:GetItemInSlot(sourceSlot)
    if not valid(item) or freeSlot(destination, destinationFirst, destinationLast) == nil then return false end
    source:TakeItem(item)
    if find(source, item, 0, 14) ~= nil then return false end
    local ok, accepted = pcall(function() return destination:AddItem(item) end)
    if ok and valid(accepted) and find(destination, accepted, destinationFirst, destinationLast) ~= nil then
        return true
    end
    -- In Dota 2, AddItem can consume recipe components to form a combined item.
    -- If the original item was consumed by destination, this is a successful transfer.
    if not valid(item) then
        return true
    end
    -- If AddItem put the original handle outside the permitted slots, take it back.
    if find(destination, item, 0, 14) ~= nil then destination:TakeItem(item) end
    local restored = source:AddItem(item)
    local slot = find(source, restored, 0, 14)
    if slot ~= nil and slot ~= sourceSlot then source:SwapItems(slot, sourceSlot) end
    return false
end

function Transfer.Range(source, destination, first, last, destinationFirst, destinationLast)
    local count = 0
    for slot = first, last do
        if Transfer.Move(source, destination, slot, destinationFirst, destinationLast) then count = count + 1 end
    end
    return count
end

return Transfer
