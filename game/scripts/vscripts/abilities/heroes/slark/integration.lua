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
    Trace:Log('SLARK','Q','native_pact_ready rank=%s',tostring(q:GetLevel()))
    return true
end
return Integration
