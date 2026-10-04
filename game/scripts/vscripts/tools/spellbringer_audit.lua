-- Read-only observation automatically armed by Future Reinforcements.
-- Compare is a separate, explicit owner-run Tools experiment with temporary units.
-- Does not cast, move or select units. A Tools-only comparison command is
-- registered when the first reinforcement group is observed.
-- Then select a reinforcement and issue move/attack/stop/hold orders for 30s.
local Audit = {}
local latest, comparisonUntil = {}, {}
local comparisonCommandRegistered = false

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
    local active = unit:GetCurrentActiveAbility()
    local row = {
        entity = unit:entindex(), name = unit:GetUnitName(), team = unit:GetTeamNumber(),
        owner = unit:GetPlayerOwnerID(), alive = unit:IsAlive(),
        controllable = unit:IsControllableByAnyPlayer(), movable = unit:HasMovementCapability(),
        speed = unit:GetIdealSpeed(), rooted = unit:IsRooted(), stunned = unit:IsStunned(),
        restricted = unit:IsCommandRestricted(), x = pos.x, y = pos.y, z = pos.z,
        traversable = GridNav:IsTraversable(pos), blocked = GridNav:IsBlocked(pos),
        waveAI = unit.creepState ~= nil, modifiers = table.concat(modifiers, ","),
        abilities = table.concat(abilities, ","),
        moving = unit:IsMoving(), idle = unit:IsIdle(), frozen = unit:IsFrozen(),
        active = active and not active:IsNull() and active:GetAbilityName() or "none",
    }
    print(string.format("[SPELLBRINGER_AUDIT] entity=%d name=%s team=%d owner=%d alive=%s controllable=%s movable=%s speed=%.1f rooted=%s stunned=%s restricted=%s pos=%.1f,%.1f,%.1f traversable=%s blocked=%s wave_ai=%s modifiers=[%s] abilities=[%s]",
        row.entity, row.name, row.team, row.owner, tostring(row.alive), tostring(row.controllable),
        tostring(row.movable), row.speed, tostring(row.rooted), tostring(row.stunned),
        tostring(row.restricted), row.x, row.y, row.z, tostring(row.traversable),
        tostring(row.blocked), tostring(row.waveAI), row.modifiers, row.abilities))
    print(string.format("[SPELLBRINGER_MOTOR] entity=%d moving=%s idle=%s frozen=%s active=%s",
        row.entity, tostring(row.moving), tostring(row.idle), tostring(row.frozen), row.active))
    return row
end

function Audit.Run(playerID, spawnedUnits)
    if not IsServer or not IsServer() or not GameRules or not IsInToolsMode or not IsInToolsMode() then
        print("[SPELLBRINGER_AUDIT] server Tools context required")
        return nil
    end
    playerID = tonumber(playerID) or 0
    if not PlayerResource:IsValidPlayerID(playerID) then
        print("[SPELLBRINGER_AUDIT] invalid player")
        return nil
    end
    if not comparisonCommandRegistered and Convars and Convars.RegisterCommand then
        local ok, err = pcall(function()
            Convars:RegisterCommand("enfos_spellbringer_compare", function(_, requestedPlayerID)
                Audit.Compare(requestedPlayerID or playerID)
            end, "Compare reinforcement movement in Workshop Tools only", 0)
        end)
        if ok then
            comparisonCommandRegistered = true
        else
            print("[SPELLBRINGER_AUDIT] comparison command registration failed: " .. tostring(err))
        end
    end
    local rows, watched = {}, {}
    for _, unit in ipairs(spawnedUnits or Entities:FindAllByClassname("npc_dota_creature")) do
        if reinforcement(unit) and (spawnedUnits or unit:GetPlayerOwnerID() == playerID) then
            watched[unit:entindex()] = unit
            rows[#rows + 1] = Audit.Snapshot(unit)
        end
    end
    local deadline = GameRules:GetGameTime() + 30
    latest[playerID] = {units = watched}
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
            if reinforcement(unit) and watched[unit:entindex()] == unit then
                local before = Audit.Snapshot(unit)
                local destination
                if (order.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION or order.order_type == DOTA_UNIT_ORDER_ATTACK_MOVE)
                    and tonumber(order.position_x) and tonumber(order.position_y) then
                    destination = Vector(tonumber(order.position_x), tonumber(order.position_y), tonumber(order.position_z) or before.z)
                    latest[playerID].destination = destination
                    print(string.format("[SPELLBRINGER_PATH] entity=%d reachable=%s destination_traversable=%s destination_blocked=%s queued=%s",
                        before.entity, tostring(GridNav:CanFindPath(unit:GetAbsOrigin(), destination)),
                        tostring(GridNav:IsTraversable(destination)), tostring(GridNav:IsBlocked(destination)), tostring(order.queue)))
                end
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

-- Explicit owner-run experiment, never invoked by a cast or normal gameplay.
-- Server console after casting wave-6 reinforcements and trying a move:
-- enfos_spellbringer_compare 0
-- Compare the actual summon with fresh copies with/without its native heal,
-- and the installed native priest. This is evidence collection, not a fix.
function Audit.Compare(playerID)
    if not IsServer or not IsServer() or not IsInToolsMode or not IsInToolsMode() then return false end
    playerID = tonumber(playerID) or 0
    if not PlayerResource:IsValidPlayerID(playerID) then return false end
    local now = GameRules:GetGameTime()
    if (comparisonUntil[playerID] or 0) > now then
        print("[SPELLBRINGER_COMPARE] previous comparison still active")
        return false
    end
    local attempt = latest[playerID]
    local anchor
    for _, unit in pairs(attempt and attempt.units or {}) do
        if reinforcement(unit) and unit:IsAlive() and unit:GetUnitName() == "enfos_wave_06" then anchor = unit; break end
    end
    local owner = PlayerResource:GetSelectedHeroEntity(playerID)
    if not anchor or not attempt.destination or not owner or owner:IsNull() then
        print("[SPELLBRINGER_COMPARE] cast early wave-6 reinforcements and issue a move before comparing")
        return false
    end
    local p = anchor:GetAbsOrigin()
    local origin = Vector(p.x, p.y, p.z)
    local destination = attempt.destination
    local dx, dy = destination.x-origin.x, destination.y-origin.y
    if dx*dx+dy*dy < 128*128 or not GridNav:CanFindPath(origin, destination) then
        print("[SPELLBRINGER_COMPARE] need a reachable move destination at least 128 units away")
        return false
    end
    -- One group of three fixtures per player, eight-second expiry, no rewards.
    comparisonUntil[playerID] = now + 10
    local cases = {
        {label="original", unit=anchor},
        {label="custom_bare", name="enfos_wave_06"},
        {label="custom_heal", name="enfos_wave_06", heal=true},
        {label="native_priest", name="npc_dota_neutral_forest_troll_high_priest"},
    }
    for i, case in ipairs(cases) do
        if not case.unit then
            case.unit = CreateUnitByName(case.name, origin+Vector(160*(i-2),160,0), true, owner, owner, anchor:GetTeamNumber())
            if case.unit then
                local u = case.unit
                u.enfosNoReward = true
                u:SetMinimumGoldBounty(0); u:SetMaximumGoldBounty(0); u:SetDeathXP(0)
                u:AddNewModifier(u,nil,"modifier_kill",{duration=8})
                u:SetOwner(owner); u:SetControllableByPlayer(playerID,true)
                u:SetBaseMoveSpeed(anchor:GetIdealSpeed())
                u:SetMaxMana(300); u:SetMana(300); u:SetBaseManaRegen(3)
                u:SetIdleAcquire(true); u:SetAcquisitionRange(700)
                if case.heal then require("waves/special_creeps").Configure(u,6,u:GetTeamNumber(),true) end
            end
        end
        local u = case.unit
        if u then
            local start = Audit.Snapshot(u)
            if GridNav:CanFindPath(u:GetAbsOrigin(),destination) then
                print(string.format("[SPELLBRINGER_COMPARE] case=%s entity=%d reachable=true",case.label,u:entindex()))
                ExecuteOrderFromTable({UnitIndex=u:entindex(),OrderType=DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                    Position=destination,Queue=false,PlayerID=playerID})
                GameRules:GetGameModeEntity():SetContextThink("SpellbringerCompare_"..u:entindex(),function()
                    if u:IsNull() or not u:IsAlive() then
                        print("[SPELLBRINGER_COMPARE] case="..case.label.." inconclusive=removed_or_dead")
                        return nil
                    end
                    local after = Audit.Snapshot(u)
                    local distance = math.sqrt((after.x-start.x)^2+(after.y-start.y)^2)
                    print(string.format("[SPELLBRINGER_COMPARE] case=%s entity=%d displacement=%.1f",case.label,u:entindex(),distance))
                    -- If the normal server order fails, use the NPC movement
                    -- method on temporary fixtures only. This distinguishes
                    -- order acceptance from the unit motor/navigation itself.
                    if case.label == "custom_bare" or case.label == "native_priest" then
                        local directStart = u:GetAbsOrigin()
                        local directX, directY = directStart.x, directStart.y
                        u:MoveToPosition(destination)
                        GameRules:GetGameModeEntity():SetContextThink("SpellbringerDirect_"..u:entindex(),function()
                            if u:IsNull() or not u:IsAlive() then
                                print("[SPELLBRINGER_COMPARE] case="..case.label.." direct=inconclusive_removed_or_dead")
                                return nil
                            end
                            local directEnd = u:GetAbsOrigin()
                            local directDistance = math.sqrt((directEnd.x-directX)^2+(directEnd.y-directY)^2)
                            print(string.format("[SPELLBRINGER_COMPARE] case=%s entity=%d direct_displacement=%.1f",case.label,u:entindex(),directDistance))
                            return nil
                        end,2)
                    end
                    return nil
                end,3)
            else
                print("[SPELLBRINGER_COMPARE] case="..case.label.." inconclusive=no_path")
            end
        else
            print("[SPELLBRINGER_COMPARE] case="..case.label.." inconclusive=spawn_failed")
        end
    end
    return true
end

return Audit
