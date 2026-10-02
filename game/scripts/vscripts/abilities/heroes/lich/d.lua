-- Lich isolated kit: preserve stable classes, values and lifecycle behavior.
local Helpers = require('abilities/shared/pve_helpers')
local value, enemies, is_boss, get_int, damage = Helpers.value, Helpers.enemies, Helpers.is_boss, Helpers.get_int, Helpers.damage
local HeroTrace = require('lib/hero_trace')

LinkLuaModifier('modifier_enfos_lich_ice_aura', 'abilities/heroes/lich/d', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_enfos_lich_ice_aura_buff', 'abilities/heroes/lich/d', LUA_MODIFIER_MOTION_NONE)

enfos_lich_ice_aura=class({})
function enfos_lich_ice_aura:GetIntrinsicModifierName() return 'modifier_enfos_lich_ice_aura' end

modifier_enfos_lich_ice_aura=class({})
local function lich_ice_aura_source(c, a)
    if not c or (c.IsNull and c:IsNull()) or not a or (a.IsNull and a:IsNull())
        or (a.GetLevel and a:GetLevel() <= 0) or (c.PassivesDisabled and c:PassivesDisabled()) then return nil end
    return a
end

local function lich_ice_aura_trace(modifier, event)
    if not HeroTrace:Enabled() then return end
    local c, a = modifier:GetCaster(), modifier:GetAbility()
    local active = lich_ice_aura_source(c, a)
    HeroTrace:Log('LICH','D','%s source=%s recipient=%s active=%s armor=%s mana_regen=%s',
        event,HeroTrace:Name(c),HeroTrace:Name(modifier:GetParent()),tostring(active ~= nil),
        tostring(value(active,'bonus_armor')),tostring(value(active,'mana_regen')))
end

function modifier_enfos_lich_ice_aura:GetTexture() return 'lich_frost_nova' end
function modifier_enfos_lich_ice_aura:OnCreated() lich_ice_aura_trace(self, 'source_created') end
function modifier_enfos_lich_ice_aura:OnRefresh() lich_ice_aura_trace(self, 'source_refreshed') end
function modifier_enfos_lich_ice_aura:OnDestroy() lich_ice_aura_trace(self, 'source_removed') end
function modifier_enfos_lich_ice_aura:IsAura()
    return lich_ice_aura_source(self:GetParent(), self:GetAbility()) ~= nil
end
function modifier_enfos_lich_ice_aura:GetAuraRadius() return value(self:GetAbility(), 'radius') end
function modifier_enfos_lich_ice_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_enfos_lich_ice_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_enfos_lich_ice_aura:GetModifierAura() return 'modifier_enfos_lich_ice_aura_buff' end

modifier_enfos_lich_ice_aura_buff=class({})
function modifier_enfos_lich_ice_aura_buff:GetTexture() return 'lich_frost_nova' end
function modifier_enfos_lich_ice_aura_buff:OnCreated() lich_ice_aura_trace(self, 'recipient_created') end
function modifier_enfos_lich_ice_aura_buff:OnRefresh() lich_ice_aura_trace(self, 'recipient_refreshed') end
function modifier_enfos_lich_ice_aura_buff:OnDestroy() lich_ice_aura_trace(self, 'recipient_removed') end
function modifier_enfos_lich_ice_aura_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT }
end
function modifier_enfos_lich_ice_aura_buff:GetModifierPhysicalArmorBonus()
    local c = self:GetParent()
    if not c or (c.IsNull and c:IsNull()) then return 0 end
    if c and c.IsIllusion and c:IsIllusion() then return 0 end
    local ab = lich_ice_aura_source(self:GetCaster(), self:GetAbility())
    return value(ab, 'bonus_armor')
end
function modifier_enfos_lich_ice_aura_buff:GetModifierConstantManaRegen()
    local c = self:GetParent()
    if not c or (c.IsNull and c:IsNull()) then return 0 end
    if c and c.IsIllusion and c:IsIllusion() then return 0 end
    local ab = lich_ice_aura_source(self:GetCaster(), self:GetAbility())
    return value(ab, 'mana_regen')
end
