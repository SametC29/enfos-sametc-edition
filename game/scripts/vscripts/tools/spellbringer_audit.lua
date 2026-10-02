-- Owner-only, read-only Tools diagnostic. Does not cast, move or select units.
-- Server console: script require("tools/spellbringer_audit").Run(0)
-- Then select a reinforcement and issue move/attack/stop/hold orders for 30s.
local Audit = {}

local function reinforcement(unit)
    return unit and not unit:IsNull() and unit.is_allied_reinforcement
        and unit:GetUnitName():find("enfos_wave_", 1, true) == 1
end

function Audit.Snapshot(unit)
    local modifiers, abilities = {}, {}
    for i = 0, unit:GetModifierCount() - 1 do
        modifiers[#modifiers + 1] = unit:GetModifierNameByIndex(i)
    end
    for i = 0, unit:GetAbilityCount() - 1 do
        local ability = unit:GetAbilityByIndex(i)
        if ability and not ability:IsNull() then
            abilities[#abilities + 1] = ability:GetAbilityName() .. ":" .. ability:GetLevel()
        end
    end
    local pos = unit:GetAbsOrigin()
    local row = {
        entity = unit:entindex(), name = unit:GetUnitName(), team = unit:GetTeamNumber(),
        owner = unit:GetPlayerOwnerID(), alive = unit:IsAlive(),
        controllable = unit:IsControllableByAnyPlayer(), movable = unit:HasMovementCapability(),
        speed = unit:GetIdealSpeed(), rooted = unit:IsRooted(), stunned = unit:IsStunned(),
        restricted = unit:IsCommandRestricted(), x = pos.x, y = pos.y, z = pos.z,
        traversable = GridNav:IsTraversable(pos), blocked = GridNav:IsBlocked(pos),
        waveAI = unit.creepState ~= nil, modifiers = table.concat(modifiers, ","),
        abilities = table.concat(abilities, ","),
    }
    print(string.format("[SPELLBRINGER_AUDIT] entity=%d name=%s team=%d owner=%d alive=%s controllable=%s movable=%s speed=%.1f rooted=%s stunned=%s restricted=%s pos=%.1f,%.1f,%.1f traversable=%s blocked=%s wave_ai=%s modifiers=[%s] abilities=[%s]",
        row.entity, row.name, row.team, row.owner, tostring(row.alive), tostring(row.controllable),
        tostring(row.movable), row.speed, tostring(row.rooted), tostring(row.stunned),
        tostring(row.restricted), row.x, row.y, row.z, tostring(row.traversable),
        tostring(row.blocked), tostring(row.waveAI), row.modifiers, row.abilities))
    return row
end

function Audit.Run(playerID)
    if not IsServer or not IsServer() or not GameRules or not IsInToolsMode or not IsInToolsMode() then
        print("[SPELLBRINGER_AUDIT] server Tools context required")
        return nil
    end
    playerID = tonumber(playerID) or 0
    if not PlayerResource:IsValidPlayerID(playerID) then
        print("[SPELLBRINGER_AUDIT] invalid player")
        return nil
    end
    local rows = {}
    for _, unit in ipairs(Entities:FindAllByClassname("npc_dota_creature")) do
        if reinforcement(unit) and unit:GetPlayerOwnerID() == playerID then
            rows[#rows + 1] = Audit.Snapshot(unit)
        end
    end
    local deadline = GameRules:GetGameTime() + 30
    -- The regular order filter calls this only while the owner has armed it.
    -- A single delayed read per unit is replaced on repeated orders; no loop.
    _G.EnfosSpellbringerOrderAudit = function(order)
        if GameRules:GetGameTime() >= deadline then
            _G.EnfosSpellbringerOrderAudit = nil
            return
        end
        if order.issuer_player_id_const ~= playerID then return end
        for _, index in pairs(order.units or {}) do
            local unit = EntIndexToHScript(tonumber(index) or -1)
            if reinforcement(unit) and unit:GetPlayerOwnerID() == playerID then
                local before = Audit.Snapshot(unit)
                print(string.format("[SPELLBRINGER_ORDER] entity=%d issuer=%d type=%s target=%s destination=%s,%s,%s",
                    before.entity, playerID, tostring(order.order_type), tostring(order.entindex_target),
                    tostring(order.position_x), tostring(order.position_y), tostring(order.position_z)))
                GameRules:GetGameModeEntity():SetContextThink("SpellbringerOrderAudit_" .. before.entity, function()
                    if unit:IsNull() then
                        print("[SPELLBRINGER_ORDER] entity=" .. before.entity .. " removed before sample")
                        return nil
                    end
                    local after = Audit.Snapshot(unit)
                    local distance = math.sqrt((after.x - before.x)^2 + (after.y - before.y)^2)
                    print(string.format("[SPELLBRINGER_ORDER] entity=%d displacement=%.1f (observation only)", before.entity, distance))
                    return nil
                end, 1)
            end
        end
    end
    print(string.format("[SPELLBRINGER_AUDIT] player=%d found=%d order_watch_seconds=30; issue orders now", playerID, #rows))
    return rows
end

return Audit
