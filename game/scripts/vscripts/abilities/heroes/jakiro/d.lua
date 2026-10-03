-- Jakiro D: isolated authored implementation; behavior unchanged in extraction.
local Helpers = require('abilities/shared/pve_helpers')
local value, enemies, is_boss, get_int, damage = Helpers.value, Helpers.enemies, Helpers.is_boss, Helpers.get_int, Helpers.damage
local effect, ground_effect, remove_ground_effect = Helpers.effect, Helpers.ground_effect, Helpers.remove_ground_effect
LinkLuaModifier('modifier_enfos_jakiro_double_trouble', 'abilities/heroes/jakiro/d', LUA_MODIFIER_MOTION_NONE)

enfos_jakiro_double_trouble=class({})
function enfos_jakiro_double_trouble:GetIntrinsicModifierName() return 'modifier_enfos_jakiro_double_trouble' end

modifier_enfos_jakiro_double_trouble=class({})
function modifier_enfos_jakiro_double_trouble:DeclareFunctions()
    return { MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end
function modifier_enfos_jakiro_double_trouble:GetModifierBonusStats_Intellect()
    local c = self:GetParent()
    if not c or (c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion()) then return 0 end
    return value(self:GetAbility(), 'bonus_int')
end
function modifier_enfos_jakiro_double_trouble:GetModifierAttackSpeedBonus_Constant()
    local c = self:GetParent()
    if not c or (c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion()) then return 0 end
    return value(self:GetAbility(), 'bonus_as')
end
