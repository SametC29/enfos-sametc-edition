-- Native Gush owns cast, impact and upgrades; this only adds authored STR damage.
modifier_enfos_tide_native_scaling=class({})
local M=modifier_enfos_tide_native_scaling
function M:IsHidden() return true end
function M:IsPurgable() return false end
function M:RemoveOnDeath() return false end
function M:DeclareFunctions()
    return {MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE}
end
local function matches(params)
    local a=params and params.ability
    return a and not a:IsNull() and a:GetAbilityName()=='enfos_tide_gush'
        and params.ability_special_value=='gush_damage'
end
function M:GetModifierOverrideAbilitySpecial(params)
    return matches(params) and 1 or 0
end
function M:GetModifierOverrideAbilitySpecialValue(params)
    if not matches(params) then return 0 end
    local c,a=self:GetParent(),params.ability
    if not c or c:IsNull() or a:GetLevel()<1 then return 0 end
    local rank=math.min(10,a:GetLevel())-1
    return a:GetLevelSpecialValueNoOverride('gush_damage',rank)
        +c:GetStrength()*a:GetLevelSpecialValueNoOverride('strength_factor',rank)
end
