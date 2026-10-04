-- Native Fury Swipes owns attacks and target state; this supplies paid tuning.
modifier_enfos_ursa_native_scaling=class({})
local M=modifier_enfos_ursa_native_scaling
function M:IsHidden() return true end
function M:IsPurgable() return false end
function M:RemoveOnDeath() return false end
function M:DeclareFunctions()
    return {MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE}
end
local keys={['damage_per_stack']=true,['bonus_reset_time']=true,['bonus_reset_time_roshan']=true,
    ['stun_stack_count']=true,['stun_duration']=true}
local function sources(mod,params)
    local c,a=mod:GetParent(),params and params.ability
    if not c or c:IsNull() or c:GetUnitName()~='npc_dota_hero_ursa' or not a or a:IsNull()
        or a:GetAbilityName()~='ursa_fury_swipes' or a:GetCaster()~=c
        or not keys[params.ability_special_value] then return end
    local paid=c:FindAbilityByName('enfos_ursa_fury_swipes')
    if not paid or paid:IsNull() then return end
    return c,paid
end
function M:GetModifierOverrideAbilitySpecial(params)
    return sources(self,params) and 1 or 0
end
function M:GetModifierOverrideAbilitySpecialValue(params)
    local c,paid=sources(self,params)
    if not c or paid:GetLevel()<1 then return 0 end
    local key,rank=params.ability_special_value,math.min(10,paid:GetLevel())-1
    local base=paid:GetLevelSpecialValueNoOverride(key,rank)
    -- Break ownership is native: existing stacks retain their effects.
    if key=='damage_per_stack' then
        return base+c:GetAgility()*paid:GetLevelSpecialValueNoOverride('agility_factor',rank)
    end
    return base
end
