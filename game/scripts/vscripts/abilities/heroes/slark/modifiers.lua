local Helpers=require('abilities/shared/pve_helpers')
modifier_enfos_slark_native_scaling=class({})
local M=modifier_enfos_slark_native_scaling
function M:IsHidden() return true end
function M:IsPurgable() return false end
function M:RemoveOnDeath() return false end
function M:DeclareFunctions()
    return {MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE}
end
local function matches(params)
    local a=params and params.ability
    return a and not a:IsNull() and a:GetAbilityName()=='enfos_slark_dark_pact'
        and params.ability_special_value=='total_damage'
end
function M:GetModifierOverrideAbilitySpecial(params) return matches(params) and 1 or 0 end
function M:GetModifierOverrideAbilitySpecialValue(params)
    if not matches(params) then return 0 end
    local a=params.ability
    if a:GetLevel()<1 then return 0 end
    local rank=math.min(10,a:GetLevel())-1
    return a:GetLevelSpecialValueNoOverride('total_damage',rank)
        +Helpers.get_agi(self:GetParent())*a:GetLevelSpecialValueNoOverride('agility_factor',rank)
end
