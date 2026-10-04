require('abilities/heroes/dragon_knight/modifier_links')
local Integration={}
local function restoreBlood(hero)
    local e=hero:FindAbilityByName('enfos_dk_dragon_blood')
    if not e then return true end
    if e:IsNull() or e:GetCaster()~=hero then return false end
    local native=hero:FindAbilityByName('dragon_knight_dragon_blood')
    if native and native:IsNull() then native=nil end
    if not native then native=hero:AddAbility('dragon_knight_dragon_blood') end
    if not native or native:IsNull() or native:GetCaster()~=hero then return false end
    if native:GetLevel()~=1 then native:SetLevel(1) end
    native:SetHidden(true)
    native:SetActivated(e:GetLevel()>0)
    require('lib/hero_trace'):Log('DK','E','native_blood_ready paid_rank=%s native_rank=%s',tostring(e:GetLevel()),tostring(native:GetLevel()))
    return true
end
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
    return restoreBlood(hero)
end
function Integration.RefreshDragonBlood(hero)
    if not Integration.Restore(hero) then return false end
    local e=hero:FindAbilityByName('enfos_dk_dragon_blood')
    if not e or e:IsNull() or e:GetLevel()<1 then return false end
    local native=hero:FindAbilityByName('dragon_knight_dragon_blood')
    if not native or native:IsNull() then return false end
    local name=native:GetIntrinsicModifierName()
    local m=name and name~='' and hero:FindModifierByName(name)
    if not m or m:IsNull() then
        require('lib/hero_trace'):Log('DK','E','native_blood_intrinsic_missing')
        return false
    end
    -- A stat-only native intrinsic; ordinary restore never invokes refresh.
    m:ForceRefresh()
    return true
end
return Integration
