-- Read-only owner probe. No restore, training, trace toggle, damage or spawn.
local server=IsServer and IsServer()
print('[SF_HEALTH] server='..tostring(server))
for _,name in ipairs({'enfos_sf_shadowraze','enfos_sf_necromastery','enfos_sf_requiem_of_souls',
    'modifier_enfos_sf_native_scaling','modifier_enfos_sf_feast_of_souls_passive'}) do
    print('[SF_HEALTH] class='..name..' lua_global='..tostring(type(_G[name])=='table'))
end
if not server then print('[SF_HEALTH] server_context_unavailable IsServer=false');return end
if not PlayerResource then print('[SF_HEALTH] player_resource_unavailable');return end
for id=0,9 do
    if PlayerResource:IsValidPlayerID(id) then
        local hero=PlayerResource:GetSelectedHeroEntity(id)
        if hero and not hero:IsNull() and hero:GetUnitName()=='npc_dota_hero_nevermore' then
            print(string.format('[SF_HEALTH] player=%d level=%d points=%d alive=%s',id,hero:GetLevel(),hero:GetAbilityPoints(),tostring(hero:IsAlive())))
            for _,name in ipairs({'enfos_sf_shadowraze','enfos_sf_necromastery','enfos_sf_presence_of_the_dark_lord',
                'enfos_sf_requiem_of_souls','enfos_sf_feast_of_souls','nevermore_shadowraze1','nevermore_shadowraze2',
                'nevermore_shadowraze3','nevermore_necromastery','nevermore_requiem'}) do
                local a=hero:FindAbilityByName(name)
                print(string.format('[SF_HEALTH] ability=%s rank=%s',name,tostring(a and not a:IsNull() and a:GetLevel() or 'missing')))
                if a and not a:IsNull() and name=='nevermore_shadowraze1' then
                    print('[SF_HEALTH] native_raze_damage_query='..tostring(a:GetSpecialValueFor('shadowraze_damage')))
                elseif a and not a:IsNull() and name=='nevermore_requiem' then
                    print('[SF_HEALTH] native_requiem_damage_query='..tostring(a:GetSpecialValueFor('AbilityDamage'))..
                        ' ability_damage_getter='..tostring(a:GetAbilityDamage()))
                end
            end
            for _,name in ipairs({'modifier_enfos_sf_native_scaling','modifier_enfos_sf_feast_of_souls_passive',
                'modifier_nevermore_necromastery'}) do
                local m=hero:FindModifierByName(name)
                print('[SF_HEALTH] modifier='..name..' present='..tostring(m and not m:IsNull() or false)..
                    ' stacks='..tostring(m and not m:IsNull() and m:GetStackCount() or 'missing'))
            end
        end
    end
end
