-- Read-only Tools probe. Run: script_reload_code tools/p0_health.
-- This console reload executes in a client script scope on some Dota builds.
local isServer = IsServer and IsServer() or false
local rules = rawget(_G, "GameRules")
if not isServer or not rules then
    print("[ENFOS_P0] server game context unavailable (IsServer=" .. tostring(isServer)
        .. ", GameRules=" .. tostring(rules ~= nil) .. ")")
    return
end

if isServer then
    print("[ENFOS_P0] state=" .. tostring(rules:State_Get()) .. " map=" .. tostring(GetMapName()))
    for playerID = 0, 23 do
        if PlayerResource:IsValidPlayerID(playerID) then
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            if hero then
                print("[ENFOS_P0] player=" .. playerID .. " hero=" .. hero:GetUnitName()
                    .. " level=" .. hero:GetLevel() .. " alive=" .. tostring(hero:IsAlive())
                    .. " points=" .. hero:GetAbilityPoints())
            end
        end
    end
end
