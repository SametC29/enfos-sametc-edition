-- Read-only owner probe. No restore, training, trace toggle, damage or spawn.
local server=IsServer and IsServer()
print('[SF_HEALTH] server='..tostring(server))
for _,name in ipairs({'enfos_sf_shadowraze','enfos_sf_necromastery','enfos_sf_requiem_of_souls',
    'modifier_enfos_sf_native_scaling','modifier_enfos_sf_feast_of_souls_passive'}) do
    print('[SF_HEALTH] class='..name..' lua_global='..tostring(type(_G[name])=='table'))
end
if not server then print('[SF_HEALTH] server_context_unavailable IsServer=false');return end
if not PlayerResource then print('[SF_HEALTH] player_resource_unavailable');return end
local Health=require('heroes/health')
for id=0,9 do
    if PlayerResource:IsValidPlayerID(id) then
        local hero=PlayerResource:GetSelectedHeroEntity(id)
        if hero and not hero:IsNull() and hero:GetUnitName()=='npc_dota_hero_nevermore' then
            Health.Report(hero,id)
        end
    end
end
