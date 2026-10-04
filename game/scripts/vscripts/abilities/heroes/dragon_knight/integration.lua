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
local function restoreWrath(hero)
    local d=hero:FindAbilityByName('enfos_dk_wyrm_vigor')
    if not d then return true end
    if d:IsNull() or d:GetCaster()~=hero then return false end
    local native=hero:FindAbilityByName('dragon_knight_wyrms_wrath')
    if native and native:IsNull() then native=nil end
    if not native then native=hero:AddAbility('dragon_knight_wyrms_wrath') end
    if not native or native:IsNull() or native:GetCaster()~=hero then return false end
    local rank=d:GetLevel()>0 and 1 or 0
    if native:GetLevel()~=rank then native:SetLevel(rank) end
    native:SetHidden(true)
    native:SetActivated(rank>0)
    require('lib/hero_trace'):Log('DK','D','native_wrath_ready paid_rank=%s native_rank=%s',tostring(d:GetLevel()),tostring(rank))
    return true
end
local function restoreForm(hero)
    local r=hero:FindAbilityByName('enfos_dk_elder_dragon_form')
    if not r then return true end
    if r:IsNull() or r:GetCaster()~=hero then return false end
    local native=hero:FindAbilityByName('dragon_knight_elder_dragon_form')
    if native and native:IsNull() then native=nil end
    if not native then native=hero:AddAbility('dragon_knight_elder_dragon_form') end
    if not native or native:IsNull() or native:GetCaster()~=hero then return false end
    local rank=math.min(3,r:GetLevel())
    if native:GetLevel()~=rank then native:SetLevel(rank) end
    native:SetHidden(true)
    native:SetActivated(rank>0)
    require('lib/hero_trace'):Log('DK','R','native_form_ready paid_rank=%s native_rank=%s',tostring(r:GetLevel()),tostring(rank))
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
    return restoreBlood(hero) and restoreWrath(hero) and restoreForm(hero)
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
function Integration.RefreshWyrmsWrath(hero)
    if not Integration.Restore(hero) then return false end
    local native=hero:FindAbilityByName('dragon_knight_wyrms_wrath')
    if not native or native:IsNull() or native:GetLevel()<1 then return false end
    local name=native:GetIntrinsicModifierName()
    local m=name and name~='' and hero:FindModifierByName(name)
    if not m or m:IsNull() then
        require('lib/hero_trace'):Log('DK','D','native_wrath_intrinsic_missing')
        return false
    end
    m:ForceRefresh()
    return true
end
function Integration.FormProvider(ability)
    if not IsServer() or not ability or ability:IsNull() or ability:GetAbilityName()~='enfos_dk_elder_dragon_form'
        or ability:GetLevel()<1 then return end
    local hero=ability:GetCaster()
    if not Integration.Restore(hero) or not hero:IsAlive() then return end
    return hero:FindAbilityByName('dragon_knight_elder_dragon_form')
end
function Integration.ReconcileFireball(hero,hasShard)
    if not IsServer() or not require('abilities/heroes/dragon_knight/ownership').UsesNativeShard(hero)
        or not hero:IsRealHero() or hero:IsIllusion() then return false end
    local a=hero:FindAbilityByName('dragon_knight_fireball')
    if a and a:IsNull() then a=nil end
    if not a and hasShard then a=hero:AddAbility('dragon_knight_fireball') end
    if not a then return not hasShard end
    if a:IsNull() or a:GetCaster()~=hero then return false end
    if hasShard and a:GetLevel()~=1 then a:SetLevel(1) end
    a:SetHidden(not hasShard)
    a:SetActivated(hasShard and true or false)
    require('lib/hero_trace'):Log('DK','R','native_fireball_ready shard=%s rank=%s',tostring(hasShard),tostring(a:GetLevel()))
    return true
end
return Integration
