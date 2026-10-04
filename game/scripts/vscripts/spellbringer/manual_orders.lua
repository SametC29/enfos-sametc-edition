-- Player orders for Future Reinforcements reach the order filter but the
-- engine's ordinary order path leaves these controllable creeps stationary.
-- Forward only ground movement to the NPC motor on the next tick, after the
-- original group order has completed. Other selected units keep their order.
local ManualOrders = {}

function ManualOrders.Forward(filterTable)
    if not filterTable or not filterTable.units then return 0 end
    local orderType = filterTable.order_type
    if orderType ~= DOTA_UNIT_ORDER_MOVE_TO_POSITION and orderType ~= DOTA_UNIT_ORDER_ATTACK_MOVE then return 0 end

    local playerID = filterTable.issuer_player_id_const
    local x, y = tonumber(filterTable.position_x), tonumber(filterTable.position_y)
    if not x or not y or x ~= x or y ~= y then return 0 end

    local forwarded = 0
    for _, index in pairs(filterTable.units) do
        local unit = EntIndexToHScript(tonumber(index) or -1)
        if unit and not unit:IsNull() and unit:IsAlive() and unit.is_allied_reinforcement
            and unit:GetUnitName():find("enfos_wave_", 1, true) == 1
            and unit:GetPlayerOwnerID() == playerID then
            local z = tonumber(filterTable.position_z) or unit:GetAbsOrigin().z
            local destination = Vector(x, y, z)
            unit:SetContextThink("SpellbringerManualMove", function()
                if unit:IsNull() or not unit:IsAlive() or unit:GetPlayerOwnerID() ~= playerID then return nil end
                if orderType == DOTA_UNIT_ORDER_ATTACK_MOVE then
                    unit:MoveToPositionAggressive(destination)
                else
                    unit:MoveToPosition(destination)
                end
                return nil
            end, 0.03)
            forwarded = forwarded + 1
        end
    end
    return forwarded
end

return ManualOrders
