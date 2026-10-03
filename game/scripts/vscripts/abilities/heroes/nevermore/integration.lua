local Trace=require('lib/hero_trace')
local Ownership=require('abilities/heroes/nevermore/ownership')
require('abilities/heroes/nevermore/modifier_links')
local Integration={}
local ids={'nevermore_shadowraze1','nevermore_shadowraze2','nevermore_shadowraze3',
    'nevermore_necromastery','nevermore_requiem'}
function Integration.Razes(hero)
    return {hero:FindAbilityByName(ids[1]),hero:FindAbilityByName(ids[2]),hero:FindAbilityByName(ids[3])}
end
function Integration.Restore(hero)
    if not IsServer() or not Ownership.IsEnfos(hero) or not hero:IsRealHero() or hero:IsIllusion() then return false end
    local w=hero:FindAbilityByName('enfos_sf_necromastery')
    local r=hero:FindAbilityByName('enfos_sf_requiem_of_souls')
    if not w or w:IsNull() or not r or r:IsNull() then return false end
    -- Overrides must exist before native soul intrinsic reads/caches its values.
    if not hero:HasModifier('modifier_enfos_sf_native_scaling') then
        local modifier=hero:AddNewModifier(hero,w,'modifier_enfos_sf_native_scaling',{})
        if not modifier or modifier:IsNull() then return false end
    end
    for _,id in ipairs(ids) do
        local provider=hero:FindAbilityByName(id) or hero:AddAbility(id)
        if not provider or provider:IsNull() then
            Log:Warn('hero','SF native provider missing: ability=%s',id)
            return false
        end
        -- Keep C++ within its original rank range. Paid values come from the
        -- ENFOS slots, without native provider skill points or duplicate souls.
        local rank=(id=='nevermore_requiem' and r:GetLevel()==0) and 0 or 1
        if provider:GetLevel()~=rank then provider:SetLevel(rank) end
        provider:SetHidden(true)
        -- The one native Requiem owner stays active when trained so its native
        -- death-release path is not disabled alongside the hidden cast helpers.
        provider:SetActivated(id=='nevermore_requiem' and rank>0)
    end
    Trace:Log('SF','W','native_souls_provider_ready rank=%s',tostring(w:GetLevel()))
    Trace:Log('SF','E','native_presence_ready')
    Trace:Log('SF','D','passive_restore_ready')
    return true
end
return Integration
