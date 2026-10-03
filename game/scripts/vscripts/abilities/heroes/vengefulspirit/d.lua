-- Vengeful Spirit D: isolated existing implementation; review gates remain pending.
local Helpers = require('abilities/shared/pve_helpers')
local value, enemies, is_boss, get_agi, damage = Helpers.value, Helpers.enemies, Helpers.is_boss, Helpers.get_agi, Helpers.damage
LinkLuaModifier('modifier_enfos_vs_retribution', 'abilities/heroes/vengefulspirit/d', LUA_MODIFIER_MOTION_NONE)

enfos_vs_retribution=class({})
function enfos_vs_retribution:GetIntrinsicModifierName() return 'modifier_enfos_vs_retribution' end

modifier_enfos_vs_retribution=class({})
function modifier_enfos_vs_retribution:DeclareFunctions()
    return { MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end
function modifier_enfos_vs_retribution:GetModifierBonusStats_Agility()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    return value(self:GetAbility(), 'bonus_agi')
end
function modifier_enfos_vs_retribution:GetModifierAttackSpeedBonus_Constant()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    return value(self:GetAbility(), 'bonus_as')
end
