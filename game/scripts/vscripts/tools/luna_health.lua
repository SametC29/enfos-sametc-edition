-- Read-only probe. Run: script_reload_code tools/luna_health.
-- Do not require integration here: observe the existing registry without repairing it.
local server=IsServer and IsServer() or false
local rules=rawget(_G,'GameRules')
local players=rawget(_G,'PlayerResource')
local function log(message) print('[LUNA_HEALTH] '..message) end
if not server or not rules or not players then
    log('server_context_unavailable IsServer='..tostring(server))
    return
end
log('server=true state='..tostring(rules:State_Get()))
local names={
    'modifier_enfos_luna_native_scaling',
    'modifier_enfos_luna_blessing_extension',
    'modifier_enfos_luna_blessing_extension_buff',
}
for _,name in ipairs(names) do
    log('class='..name..' lua_global='..tostring(type(rawget(_G,name))=='table'))
end
local found=false
for id=0,23 do
    if players:IsValidPlayerID(id) then
        local hero=players:GetSelectedHeroEntity(id)
        if hero and not hero:IsNull() and hero:GetUnitName()=='npc_dota_hero_luna' then
            found=true
            log('player='..id..' level='..hero:GetLevel()..' points='..hero:GetAbilityPoints())
            for _,name in ipairs(names) do
                local modifier=hero:FindModifierByName(name)
                log('player='..id..' modifier='..name..' present='..tostring(modifier~=nil and not modifier:IsNull()))
            end
            for _,name in ipairs({'enfos_luna_lucent_beam','enfos_luna_lunar_orbit',
                'enfos_luna_lunar_blessing','enfos_luna_eclipse','enfos_luna_moon_glaives','luna_lucent_beam'}) do
                local ability=hero:FindAbilityByName(name)
                log('player='..id..' ability='..name..' rank='..tostring(ability and not ability:IsNull() and ability:GetLevel() or 'missing'))
            end
        end
    end
end
if not found then log('no_selected_luna') end
