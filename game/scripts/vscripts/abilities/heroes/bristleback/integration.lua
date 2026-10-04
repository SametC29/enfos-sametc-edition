local Ownership=require('abilities/heroes/bristleback/ownership')
local Trace=require('lib/hero_trace')
require('abilities/heroes/bristleback/modifier_links')
local Integration={}
local slots={bristleback_viscous_nasal_goo='enfos_bb_viscous_nasal_goo',
    bristleback_quill_spray='enfos_bb_quill_spray',bristleback_bristleback='enfos_bb_bristleback',
    enfos_bb_native_hairball='enfos_bb_hairball'}
local ids={'bristleback_viscous_nasal_goo','bristleback_quill_spray','bristleback_bristleback','enfos_bb_native_hairball'}
function Integration.Restore(hero)
    if not IsServer() or not Ownership.IsEnfos(hero) or not hero:IsRealHero() or hero:IsIllusion() then return false end
    for _,id in ipairs(ids) do
        local paid=hero:FindAbilityByName(slots[id])
        if not paid or paid:IsNull() then return false end
    end
    local q=hero:FindAbilityByName(slots[ids[1]])
    if not hero:HasModifier('modifier_enfos_bb_native_scaling') then
        local m=hero:AddNewModifier(hero,q,'modifier_enfos_bb_native_scaling',{})
        if not m or m:IsNull() then return false end
    end
    for _,id in ipairs(ids) do
        local a=hero:FindAbilityByName(id) or hero:AddAbility(id)
        if not a or a:IsNull() then return false end
        local trained=hero:FindAbilityByName(slots[id]):GetLevel()>0
        -- Q/W stay at a safe native rank for linked calls; untrained paid values
        -- return zero. E's intrinsic remains off until its paid slot is trained.
        local rank=(id=='bristleback_bristleback' and not trained) and 0 or 1
        if a:GetLevel()~=rank then a:SetLevel(rank) end
        a:SetHidden(true)
        a:SetActivated(trained and (id=='bristleback_quill_spray' or id=='bristleback_bristleback'))
    end
    return true
end
function Integration.Refresh(hero)
    if not Integration.Restore(hero) then return false end
    for _,id in ipairs(ids) do
        local a=hero:FindAbilityByName(id)
        local intrinsic=a:GetIntrinsicModifierName()
        local m=intrinsic and intrinsic~='' and hero:FindModifierByName(intrinsic)
        if m and not m:IsNull() then m:ForceRefresh() end
    end
    return true
end
function Integration.Provider(ability,id)
    local hero=ability:GetCaster()
    if not Integration.Restore(hero) or not hero:IsAlive() or ability:GetLevel()<1 then return end
    return hero:FindAbilityByName(id),hero
end
function Integration.AutocastOrder(order)
    if order.order_type~=DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO or not order.entindex_ability then return end
    local paid=EntIndexToHScript(order.entindex_ability)
    if not paid or paid:IsNull() or paid:GetAbilityName()~='enfos_bb_quill_spray' then return end
    local hero=paid:GetCaster()
    if not hero or hero:IsNull() or hero:GetPlayerID()~=order.issuer_player_id_const then return end
    if not Integration.Restore(hero) then return end
    local native=hero:FindAbilityByName('bristleback_quill_spray')
    local desired=not paid:GetAutoCastState()
    if native:GetAutoCastState()~=desired then native:ToggleAutoCast() end
    Trace:Log('BB','W','native_autocast=%s',tostring(desired))
end
return Integration
