-- Lion D: byte-preserving isolation; gameplay audit remains pending.
local H = require('abilities/shared/pve_helpers')
local value, enemies, is_boss, get_int, damage, effect = H.value, H.enemies, H.is_boss, H.get_int, H.damage, H.effect
LinkLuaModifier('modifier_enfos_lion_demon_soul_passive', 'abilities/heroes/lion/d', LUA_MODIFIER_MOTION_NONE)

enfos_lion_demon_soul=class({})
function enfos_lion_demon_soul:GetIntrinsicModifierName() return 'modifier_enfos_lion_demon_soul_passive' end

modifier_enfos_lion_demon_soul_passive=class({})
function modifier_enfos_lion_demon_soul_passive:DeclareFunctions()
    return { MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE }
end
function modifier_enfos_lion_demon_soul_passive:GetModifierCastRangeBonusStacking()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    return value(self:GetAbility(), 'cast_range_bonus')
end
function modifier_enfos_lion_demon_soul_passive:GetModifierSpellAmplify_Percentage()
    local c = self:GetParent()
    if c and ((c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion())) then return 0 end
    return value(self:GetAbility(), 'spell_amp')
end
