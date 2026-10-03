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
    if not p or (p.IsNull and p:IsNull()) or (p.IsIllusion and p:IsIllusion()) then return 0 end
    -- The source owns this passive; recipient Break does not disable external buffs.
    -- Check again while the engine-owned aura modifier lingers after source Break.
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or (c.PassivesDisabled and c:PassivesDisabled()) then return 0 end
    local ab = self:GetAbility()
    if not ab or (ab.IsNull and ab:IsNull()) or (ab.GetLevel and ab:GetLevel() <= 0) then return 0 end
    return value(ab, 'bonus_damage_pct')
end
