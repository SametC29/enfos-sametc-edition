-- Native Q damage scaling and native Eclipse's original-name Beam provider.
local Helpers = require('abilities/shared/pve_helpers')
local Trace = require('lib/hero_trace')
LinkLuaModifier('modifier_enfos_luna_native_scaling','abilities/heroes/luna/scaling',LUA_MODIFIER_MOTION_NONE)

modifier_enfos_luna_native_scaling=class({})
local M=modifier_enfos_luna_native_scaling
function M:IsHidden() return true end
function M:IsPurgable() return false end
function M:RemoveOnDeath() return false end
function M:DeclareFunctions()
    return {MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE}
end
local function handles(params)
    local ability=params and params.ability
    if not ability or (ability.IsNull and ability:IsNull()) then return false end
    local name=ability:GetAbilityName()
    return params.ability_special_value=='beam_damage'
        and (name=='enfos_luna_lucent_beam' or name=='luna_lucent_beam')
end
function M:GetModifierOverrideAbilitySpecial(params) return handles(params) and 1 or 0 end
function M:GetModifierOverrideAbilitySpecialValue(params)
    if not handles(params) then return 0 end
    local hero=self:GetParent()
    local q=hero:FindAbilityByName('enfos_luna_lucent_beam')
    if not q or q:IsNull() or q:GetLevel()<1 then return 0 end
    -- Ignore this modifier on the raw lookup: no recursive special-value call.
    local rank=math.min(10,q:GetLevel())-1
    return q:GetLevelSpecialValueNoOverride('beam_damage',rank)
        + Helpers.get_agi(hero)*q:GetLevelSpecialValueNoOverride('agility_multiplier',rank)
end

local Scaling={}
function Scaling.Restore(hero)
    local q=hero:FindAbilityByName('enfos_luna_lucent_beam')
    if not q then return false end -- Native Boss Luna has no ENFOS Q.
    local peer=hero:FindAbilityByName('luna_lucent_beam')
    if not peer then peer=hero:AddAbility('luna_lucent_beam') end
    if not peer or peer:IsNull() then
        Trace:Log('LUNA','R','native_beam_provider_missing')
        return false
    end
    -- Keep the native provider at its safe first rank. Its beam_damage query
    -- resolves the current paid ENFOS Q rank through the modifier above.
    if peer:GetLevel()~=1 then peer:SetLevel(1) end
    peer:SetHidden(true)
    peer:SetActivated(false)
    if not hero:HasModifier('modifier_enfos_luna_native_scaling') then
        hero:AddNewModifier(hero,q,'modifier_enfos_luna_native_scaling',{})
    end
    Trace:Log('LUNA','Q','native_scaling_ready rank=%s agility_multiplier=1.5',tostring(q:GetLevel()))
    Trace:Log('LUNA','R','native_beam_provider_ready ability=luna_lucent_beam hidden=true rank=1')
    return true
end
return Scaling
