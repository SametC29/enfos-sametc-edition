-- Vengeful Spirit E: isolated existing implementation; review gates remain pending.
local Helpers = require('abilities/shared/pve_helpers')
local value, enemies, is_boss, get_agi, damage = Helpers.value, Helpers.enemies, Helpers.is_boss, Helpers.get_agi, Helpers.damage
LinkLuaModifier('modifier_enfos_vs_vengeance_aura', 'abilities/heroes/vengefulspirit/e', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_enfos_vs_vengeance_aura_buff', 'abilities/heroes/vengefulspirit/e', LUA_MODIFIER_MOTION_NONE)

enfos_vs_vengeance_aura=class({})
function enfos_vs_vengeance_aura:GetIntrinsicModifierName() return 'modifier_enfos_vs_vengeance_aura' end

modifier_enfos_vs_vengeance_aura=class({})
function modifier_enfos_vs_vengeance_aura:IsAura()
    local c = self:GetParent()
    return c and not (c.IsNull and c:IsNull()) and not (c.PassivesDisabled and c:PassivesDisabled())
end
function modifier_enfos_vs_vengeance_aura:GetAuraRadius() return value(self:GetAbility(), 'radius') end
function modifier_enfos_vs_vengeance_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_enfos_vs_vengeance_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_enfos_vs_vengeance_aura:GetModifierAura() return 'modifier_enfos_vs_vengeance_aura_buff' end

modifier_enfos_vs_vengeance_aura_buff=class({})
function modifier_enfos_vs_vengeance_aura_buff:DeclareFunctions() return { MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE } end
function modifier_enfos_vs_vengeance_aura_buff:GetModifierBaseDamageOutgoing_Percentage()
    local p = self:GetParent()
    if p and ((p.PassivesDisabled and p:PassivesDisabled()) or (p.IsIllusion and p:IsIllusion())) then return 0 end
    local ab = self:GetAbility()
    return ab and value(ab, 'bonus_damage_pct') or 20
end
