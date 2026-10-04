require('abilities/heroes/ursa/modifier_links')
local Trace=require('lib/hero_trace')
local Integration={}
function Integration.Restore(hero)
    if not IsServer() or not hero or hero:IsNull() or not hero:IsRealHero() or hero:IsIllusion()
        or hero:GetUnitName()~='npc_dota_hero_ursa' then return false end
    local e=hero:FindAbilityByName('enfos_ursa_fury_swipes')
    if not e or e:IsNull() then return false end
    -- Install tuning before a native intrinsic can cache its fields.
    if not hero:HasModifier('modifier_enfos_ursa_native_scaling') then
        local m=hero:AddNewModifier(hero,e,'modifier_enfos_ursa_native_scaling',{})
        if not m or m:IsNull() then return false end
    end
    local native=hero:FindAbilityByName('ursa_fury_swipes')
    if native and native:IsNull() then native=nil end
    if not native then native=hero:AddAbility('ursa_fury_swipes') end
    if not native or native:IsNull() then return false end
    local rank=e:GetLevel()>0 and 1 or 0
    if native:GetLevel()~=rank then native:SetLevel(rank) end
    native:SetHidden(true)
    native:SetActivated(rank>0)
    -- Installed AbilityDraft note names Enrage as a Q Shard dependency.
    -- Supply identity without another player cast or manual Shard effects.
    local q,r=hero:FindAbilityByName('enfos_ursa_earthshock'),hero:FindAbilityByName('enfos_ursa_enrage')
    if q and not q:IsNull() and r and not r:IsNull() then
        local helper=hero:FindAbilityByName('ursa_enrage')
        if helper and helper:IsNull() then helper=nil end
        if not helper then helper=hero:AddAbility('ursa_enrage') end
        if not helper or helper:IsNull() then return false end
        if helper:GetLevel()~=1 then helper:SetLevel(1) end
        helper:SetHidden(true)
        helper:SetActivated(false)
    end
    local d=hero:FindAbilityByName('enfos_ursa_ursa_minor')
    if d and not d:IsNull() then
        local maul=hero:FindAbilityByName('ursa_maul')
        if maul and maul:IsNull() then maul=nil end
        if not maul then maul=hero:AddAbility('ursa_maul') end
        if not maul or maul:IsNull() then return false end
        if maul:GetLevel()~=1 then maul:SetLevel(1) end
        maul:SetHidden(true)
        Trace:Log('URSA','D','native_maul_ready rank=%s paid_rank=%s',tostring(maul:GetLevel()),tostring(d:GetLevel()))
    end
    Trace:Log('URSA','E','native_fury_ready paid_rank=%s native_rank=%s',tostring(e:GetLevel()),tostring(rank))
    return true
end
function Integration.RefreshFury(hero)
    if not Integration.Restore(hero) then return false end
    local a=hero:FindAbilityByName('ursa_fury_swipes')
    if a:GetLevel()<1 then return true end
    local name=a:GetIntrinsicModifierName()
    local m=name and name~='' and hero:FindModifierByName(name)
    if not m or m:IsNull() then
        Trace:Log('URSA','E','native_fury_intrinsic_missing')
        return false
    end
    -- Refresh the caster's field cache only, never target stacks or debuffs.
    m:ForceRefresh()
    return true
end
return Integration
