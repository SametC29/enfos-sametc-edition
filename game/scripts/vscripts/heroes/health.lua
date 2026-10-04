-- Read-only selected-hero diagnostics. No gameplay restoration or periodic scan.
local Health={}
local roster={}
for _,entry in ipairs(require('heroes/roster')) do roster[entry.id]=entry end
function Health.Report(hero,id)
    if not IsServer() or not hero or hero:IsNull() then return false end
    local entry=roster[hero:GetUnitName()]
    if not entry then return false end
    if hero:GetUnitName()=='npc_dota_hero_nevermore' then
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
        
    else
        print(string.format('[HERO_HEALTH] player=%d hero=%s level=%d points=%d alive=%s',
            id,entry.id,hero:GetLevel(),hero:GetAbilityPoints(),tostring(hero:IsAlive())))
        for _,name in ipairs(entry.abilities) do
            local a=hero:FindAbilityByName(name)
            print('[HERO_HEALTH] ability='..name..' rank='..tostring(a and not a:IsNull() and a:GetLevel() or 'missing'))
            if a and not a:IsNull() and a.GetIntrinsicModifierName then
                local intrinsic=a:GetIntrinsicModifierName()
                if intrinsic and intrinsic~='' then
                    local m=hero:FindModifierByName(intrinsic)
                    print('[HERO_HEALTH] modifier='..intrinsic..' present='..tostring(m and not m:IsNull() or false))
                end
            end
        end
        if entry.id=='npc_dota_hero_ursa' then
            local a=hero:FindAbilityByName('ursa_fury_swipes')
            print('[HERO_HEALTH] ability=ursa_fury_swipes rank='..tostring(a and not a:IsNull() and a:GetLevel() or 'missing'))
            if a and not a:IsNull() then
                local name=a:GetIntrinsicModifierName()
                local m=name and name~='' and hero:FindModifierByName(name)
                print('[HERO_HEALTH] fury_intrinsic='..tostring(name)..' present='..tostring(m and not m:IsNull() or false))
                print('[HERO_HEALTH] native_fury_damage_query='..tostring(a:GetSpecialValueFor('damage_per_stack')))
            end
            local q=hero:FindAbilityByName('enfos_ursa_earthshock')
            if q and not q:IsNull() then
                print('[HERO_HEALTH] native_earthshock_damage_getter='..tostring(q:GetAbilityDamage()))
                if q.GetAssociatedSecondaryAbilities then
                    print('[HERO_HEALTH] earthshock_secondary='..tostring(q:GetAssociatedSecondaryAbilities()))
                end
            end
            local r=hero:FindAbilityByName('ursa_enrage')
            print('[HERO_HEALTH] ability=ursa_enrage rank='..tostring(r and not r:IsNull() and r:GetLevel() or 'missing'))
            local w=hero:FindAbilityByName('enfos_ursa_overpower')
            if w and not w:IsNull() and hero.FindAllModifiers then
                local buff=require('abilities/heroes/ursa/w_heal').NativeBuff(hero,w)
                print('[HERO_HEALTH] native_overpower_buff='..tostring(buff~=nil)..
                    ' charges='..tostring(buff and buff:GetStackCount() or 'missing'))
            end
        elseif entry.id=='npc_dota_hero_tidehunter' then
            local a=hero:FindAbilityByName('tidehunter_leviathans_catch')
            print('[HERO_HEALTH] ability=tidehunter_leviathans_catch rank='..tostring(a and not a:IsNull() and a:GetLevel() or 'missing'))
            if a and not a:IsNull() then
                local name=a:GetIntrinsicModifierName()
                local m=name and name~='' and hero:FindModifierByName(name)
                print('[HERO_HEALTH] catch_intrinsic='..tostring(name)..' present='..tostring(m and not m:IsNull() or false))
            end
            local m=hero:FindModifierByName('modifier_enfos_tide_wave_catch')
            print('[HERO_HEALTH] wave_catch_stacks='..tostring(m and not m:IsNull() and m:GetStackCount() or 'missing'))
        elseif entry.id=='npc_dota_hero_bristleback' then
            for _,name in ipairs({'bristleback_viscous_nasal_goo','bristleback_quill_spray',
                'bristleback_bristleback','enfos_bb_native_hairball'}) do
                local a=hero:FindAbilityByName(name)
                print('[HERO_HEALTH] ability='..name..' rank='..tostring(a and not a:IsNull() and a:GetLevel() or 'missing'))
                if a and not a:IsNull() then
                    if name=='bristleback_quill_spray' then
                        print('[HERO_HEALTH] native_quill_damage_query='..tostring(a:GetSpecialValueFor('quill_base_damage')))
                    elseif name=='enfos_bb_native_hairball' then
                        print('[HERO_HEALTH] native_hairball_radius_query='..tostring(a:GetSpecialValueFor('radius')))
                        print('[HERO_HEALTH] native_hairball_quills_query='..tostring(a:GetSpecialValueFor('quill_stacks')))
                        print('[HERO_HEALTH] native_hairball_speed_query='..tostring(a:GetSpecialValueFor('projectile_speed')))
                    end
                end
            end
        end
    end
    return true
end
function Health.OnSpawn(hero)
    if not IsServer() or not hero or hero:IsNull() or not hero:IsRealHero() or hero:IsIllusion()
        or hero.enfosHealthReported then return false end
    local id=hero:GetPlayerID()
    if not id or id<0 or not PlayerResource or not PlayerResource:IsValidPlayerID(id)
        or PlayerResource:GetSelectedHeroEntity(id)~=hero then return false end
    if not Health.Report(hero,id) then return false end
    hero.enfosHealthReported=true
    return true
end
return Health
