require('abilities/heroes/storm_spirit/modifier_links')
local Integration={}
function Integration.Restore(hero)
    if not IsServer() or not hero or hero:IsNull() or not hero:IsRealHero() or hero:IsIllusion()
        or hero:GetUnitName()~='npc_dota_hero_storm_spirit' then return false end
    local e=hero:FindAbilityByName('enfos_storm_overload')
    if not e or e:IsNull() or e:GetCaster()~=hero then return false end
    if not hero:HasModifier('modifier_enfos_storm_native_scaling') then
        local m=hero:AddNewModifier(hero,e,'modifier_enfos_storm_native_scaling',{})
        if not m or m:IsNull() then return false end
    end
    local native=hero:FindAbilityByName('storm_spirit_overload')
    if native and native:IsNull() then native=nil end
    if not native then native=hero:AddAbility('storm_spirit_overload') end
    if not native or native:IsNull() then return false end
    local rank=e:GetLevel()>0 and 1 or 0
    if native:GetLevel()~=rank then native:SetLevel(rank) end
    native:SetHidden(true)
    native:SetActivated(rank>0)
    -- Do not refresh native charge state on rank-up, respawn or reconnect.
    require('lib/hero_trace'):Log('STORM','E','native_overload_ready paid_rank=%s native_rank=%s',tostring(e:GetLevel()),tostring(rank))
    return true
end
return Integration
