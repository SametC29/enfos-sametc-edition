require('abilities/heroes/slark/modifier_links')
local Trace=require('lib/hero_trace')
local Integration={}
function Integration.Restore(hero)
    if not IsServer() or not hero or hero:IsNull() or not hero:IsRealHero()
        or hero:IsIllusion() or hero:GetUnitName()~='npc_dota_hero_slark' then return false end
    local q=hero:FindAbilityByName('enfos_slark_dark_pact')
    if not q or q:IsNull() then return false end
    if not hero:HasModifier('modifier_enfos_slark_native_scaling') then
        local m=hero:AddNewModifier(hero,q,'modifier_enfos_slark_native_scaling',{})
        if not m or m:IsNull() then return false end
    end
    local e=hero:FindAbilityByName('enfos_slark_essence_shift')
    if e and not e:IsNull() then
        local native=hero:FindAbilityByName('slark_essence_shift') or hero:AddAbility('slark_essence_shift')
        if not native or native:IsNull() then return false end
        if native:GetLevel()~=1 then native:SetLevel(1) end
        native:SetHidden(true)
        native:SetActivated(false)
    end
    Trace:Log('SLARK','Q','native_pact_ready rank=%s',tostring(q:GetLevel()))
    return true
end
function Integration.RefreshEssence(hero)
    if not Integration.Restore(hero) then return false end
    local native=hero:FindAbilityByName('slark_essence_shift')
    if not native or native:IsNull() then return false end
    local name=native:GetIntrinsicModifierName()
    local m=name and name~='' and hero:FindModifierByName(name)
    if not m or m:IsNull() then
        Trace:Log('SLARK','E','native_essence_intrinsic_missing')
        return false
    end
    m:ForceRefresh()
    Trace:Log('SLARK','E','native_essence_ready')
    return true
end
return Integration
