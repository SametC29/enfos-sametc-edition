-- Read-only Tools probe. Run: script_reload_code tools/p0_health
if IsServer() then
    print("[ENFOS_P0] state=" .. tostring(GameRules:State_Get()) .. " map=" .. tostring(GetMapName()))
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
