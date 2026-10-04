require('abilities/heroes/antimage/modifier_links')
local Trace=require('lib/hero_trace')
local Integration={}
function Integration.RestorePersecutor(hero)
    if not IsServer() or not hero or hero:IsNull() or not hero:IsRealHero() or hero:IsIllusion()
        or hero:GetUnitName()~='npc_dota_hero_antimage' then return false end
    local d=hero:FindAbilityByName('enfos_am_spellbreaker')
    if not d or d:IsNull() then return false end
    local native=hero:FindAbilityByName('antimage_persectur')
    if native and native:IsNull() then native=nil end
    if not native then native=hero:AddAbility('antimage_persectur') end
    if not native or native:IsNull() then return false end
    if native:GetLevel()~=1 then native:SetLevel(1) end
    native:SetHidden(true)
    native:SetActivated(true)
    Trace:Log('ANTIMAGE','D','native_persecutor_ready paid_rank=%s',tostring(d:GetLevel()))
    return true
end
function Integration.Restore(hero)
    if not IsServer() or not hero or hero:IsNull() or not hero:IsRealHero() or hero:IsIllusion()
        or hero:GetUnitName()~='npc_dota_hero_antimage' then return false end
    local q=hero:FindAbilityByName('enfos_am_mana_break')
    if not q or q:IsNull() then return false end
    if not hero:HasModifier('modifier_enfos_am_native_scaling') then
        local m=hero:AddNewModifier(hero,q,'modifier_enfos_am_native_scaling',{})
        if not m or m:IsNull() then return false end
    end
    local native=hero:FindAbilityByName('antimage_mana_break')
    if native and native:IsNull() then native=nil end
    if not native then native=hero:AddAbility('antimage_mana_break') end
    if not native or native:IsNull() then return false end
    local rank=q:GetLevel()>0 and 1 or 0
    if native:GetLevel()~=rank then native:SetLevel(rank) end
    native:SetHidden(true)
    native:SetActivated(rank>0)
    Trace:Log('ANTIMAGE','Q','native_mana_break_ready paid_rank=%s native_rank=%s',tostring(q:GetLevel()),tostring(rank))
    local d=hero:FindAbilityByName('enfos_am_spellbreaker')
    if d and not d:IsNull() then return Integration.RestorePersecutor(hero) end
    return true
end
function Integration.RefreshManaBreak(hero)
    if not Integration.Restore(hero) then return false end
    local a=hero:FindAbilityByName('antimage_mana_break')
    if a:GetLevel()<1 then return true end
    local name=a:GetIntrinsicModifierName()
    local m=name and name~='' and hero:FindModifierByName(name)
    if not m or m:IsNull() then
        Trace:Log('ANTIMAGE','Q','native_mana_break_intrinsic_missing')
        return false
    end
    m:ForceRefresh()
    return true
end
return Integration
