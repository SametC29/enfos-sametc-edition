-- Vengeful Spirit E: isolated existing implementation; review gates remain pending.
local Helpers = require('abilities/shared/pve_helpers')
local value = Helpers.value
local HeroTrace = require('lib/hero_trace')
local Aghanim = require('heroes/aghanim_manager')
local Upgrades = require('abilities/heroes/vengefulspirit/upgrades')
local function trained(ability)
    return ability and not (ability.IsNull and ability:IsNull())
        and ability:GetLevel() > 0
end
LinkLuaModifier('modifier_enfos_vs_vengeance_aura', 'abilities/heroes/vengefulspirit/e', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_enfos_vs_vengeance_aura_buff', 'abilities/heroes/vengefulspirit/e', LUA_MODIFIER_MOTION_NONE)

enfos_vs_vengeance_aura=class({})
function enfos_vs_vengeance_aura:GetIntrinsicModifierName() return 'modifier_enfos_vs_vengeance_aura' end
function enfos_vs_vengeance_aura:OnUpgrade()
    if not IsServer() then return end
    local c = self:GetCaster()
    Upgrades.Reconcile(c, Aghanim:HasScepter(c))
end

modifier_enfos_vs_vengeance_aura=class({})
function modifier_enfos_vs_vengeance_aura:IsAura()
    local c = self:GetParent()
    if not c or (c.IsNull and c:IsNull()) or (c.PassivesDisabled and c:PassivesDisabled()) then return false end
    return trained(self:GetAbility()) and true or false
end
function modifier_enfos_vs_vengeance_aura:GetAuraRadius()
    local ab = self:GetAbility()
    return trained(ab) and value(ab, 'radius') or 0
end
function modifier_enfos_vs_vengeance_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_enfos_vs_vengeance_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_enfos_vs_vengeance_aura:GetModifierAura() return 'modifier_enfos_vs_vengeance_aura_buff' end

modifier_enfos_vs_vengeance_aura_buff=class({})
function modifier_enfos_vs_vengeance_aura_buff:DeclareFunctions() return { MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE } end
function modifier_enfos_vs_vengeance_aura_buff:GetModifierBaseDamageOutgoing_Percentage()
    local p = self:GetParent()
    if not p or (p.IsNull and p:IsNull()) then return 0 end
    -- The source owns this passive; recipient Break does not disable external buffs.
    -- Check again while the engine-owned aura modifier lingers after source Break.
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or (c.PassivesDisabled and c:PassivesDisabled()) then return 0 end
    if p.IsIllusion and p:IsIllusion() and not (p == c and p.IsStrongIllusion and p:IsStrongIllusion()) then return 0 end
    local ab = self:GetAbility()
    if not ab or (ab.IsNull and ab:IsNull()) or (ab.GetLevel and ab:GetLevel() <= 0) then return 0 end
    local bonus = value(ab, 'bonus_damage_pct')
    -- Native self_multiplier is an extra fraction of the aura bonus, not flat damage.
    if p == c then
        local multiplier = value(ab, 'self_multiplier')
        if Aghanim:HasScepter(c) then multiplier = multiplier + value(ab, 'scepter_self_bonus') end
        bonus = bonus * (1 + multiplier / 100)
    end
    return bonus
end

function modifier_enfos_vs_vengeance_aura:GetTexture() return 'vengefulspirit_command_aura' end
function modifier_enfos_vs_vengeance_aura:TraceLifecycle(event)
    if not HeroTrace:Enabled() then return end
    HeroTrace:Log('VENGEFUL_SPIRIT','E','%s modifier=modifier_enfos_vs_vengeance_aura source=%s recipient=%s',
        event,HeroTrace:Name(self:GetCaster()),HeroTrace:Name(self:GetParent()))
end
function modifier_enfos_vs_vengeance_aura:OnCreated() self:TraceLifecycle('modifier_applied') end
function modifier_enfos_vs_vengeance_aura:OnRefresh() self:TraceLifecycle('modifier_refreshed') end
function modifier_enfos_vs_vengeance_aura:OnDestroy() self:TraceLifecycle('modifier_removed') end

function modifier_enfos_vs_vengeance_aura_buff:GetTexture() return 'vengefulspirit_command_aura' end
function modifier_enfos_vs_vengeance_aura_buff:TraceLifecycle(event)
    if not HeroTrace:Enabled() then return end
    HeroTrace:Log('VENGEFUL_SPIRIT','E','%s modifier=modifier_enfos_vs_vengeance_aura_buff source=%s recipient=%s',
        event,HeroTrace:Name(self:GetCaster()),HeroTrace:Name(self:GetParent()))
end
function modifier_enfos_vs_vengeance_aura_buff:OnCreated() self:TraceLifecycle('modifier_applied') end
function modifier_enfos_vs_vengeance_aura_buff:OnRefresh() self:TraceLifecycle('modifier_refreshed') end
function modifier_enfos_vs_vengeance_aura_buff:OnDestroy() self:TraceLifecycle('modifier_removed') end
