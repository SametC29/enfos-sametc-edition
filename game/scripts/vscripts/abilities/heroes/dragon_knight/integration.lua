require('abilities/heroes/dragon_knight/modifier_links')
local Integration={}
function Integration.Restore(hero)
    if not IsServer() or not hero or hero:IsNull() or not hero:IsRealHero() or hero:IsIllusion()
        or hero:GetUnitName()~='npc_dota_hero_dragon_knight' then return false end
    local q=hero:FindAbilityByName('enfos_dk_breathe_fire')
    if not q or q:IsNull() or q:GetCaster()~=hero then return false end
    if not hero:HasModifier('modifier_enfos_dk_native_scaling') then
        local m=hero:AddNewModifier(hero,q,'modifier_enfos_dk_native_scaling',{})
        if not m or m:IsNull() then return false end
    end
    require('lib/hero_trace'):Log('DK','Q','native_scaling_ready paid_rank=%s',tostring(q:GetLevel()))
    return true
end
return Integration
