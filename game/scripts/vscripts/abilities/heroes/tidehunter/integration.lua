require('abilities/heroes/tidehunter/modifier_links')
local Trace=require('lib/hero_trace')
local Integration={}
function Integration.Restore(hero)
    if not IsServer() or not hero or hero:IsNull() or not hero:IsRealHero()
        or hero:IsIllusion() or hero:GetUnitName()~='npc_dota_hero_tidehunter' then return false end
    local q=hero:FindAbilityByName('enfos_tide_gush')
    if not q or q:IsNull() then return false end
    if not hero:HasModifier('modifier_enfos_tide_native_scaling') then
        local m=hero:AddNewModifier(hero,q,'modifier_enfos_tide_native_scaling',{})
        if not m or m:IsNull() then return false end
    end
    local w=hero:FindAbilityByName('enfos_tide_kraken_shell')
    if w and not w:IsNull() and not hero:HasModifier('modifier_enfos_tide_shell_extension') then
        local m=hero:AddNewModifier(hero,w,'modifier_enfos_tide_shell_extension',{})
        if not m or m:IsNull() then return false end
    end
    Trace:Log('TIDEHUNTER','Q','native_gush_ready rank=%s',tostring(q:GetLevel()))
    return true
end
return Integration
