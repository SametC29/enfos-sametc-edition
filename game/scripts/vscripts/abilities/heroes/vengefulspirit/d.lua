-- Vengeful Spirit D: isolated existing implementation; review gates remain pending.
local Helpers = require('abilities/shared/pve_helpers')
local value = Helpers.value
local HeroTrace = require('lib/hero_trace')
local function passive_value(modifier, key)
    local c = modifier:GetParent()
    if not c or (c.IsNull and c:IsNull()) or (c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion()) then return 0 end
    local a = modifier:GetAbility()
    if not a or (a.IsNull and a:IsNull()) or (a.GetLevel and a:GetLevel() <= 0) then return 0 end
    return value(a, key)
end
LinkLuaModifier('modifier_enfos_vs_retribution', 'abilities/heroes/vengefulspirit/d', LUA_MODIFIER_MOTION_NONE)

enfos_vs_retribution=class({})
function enfos_vs_retribution:GetIntrinsicModifierName() return 'modifier_enfos_vs_retribution' end

modifier_enfos_vs_retribution=class({})
function modifier_enfos_vs_retribution:DeclareFunctions()
    return { MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end
function modifier_enfos_vs_retribution:GetModifierBonusStats_Agility()
    return passive_value(self, 'bonus_agi')
end
function modifier_enfos_vs_retribution:GetModifierAttackSpeedBonus_Constant()
    return passive_value(self, 'bonus_as')
end

function modifier_enfos_vs_retribution:GetTexture() return 'vengefulspirit_command_aura' end
function modifier_enfos_vs_retribution:TraceLifecycle(event)
    if not HeroTrace:Enabled() then return end
    HeroTrace:Log('VENGEFUL_SPIRIT','D','%s source=%s agility_bonus=%s attack_speed_bonus=%s',
        event,HeroTrace:Name(self:GetParent()),tostring(passive_value(self,'bonus_agi')),tostring(passive_value(self,'bonus_as')))
end
function modifier_enfos_vs_retribution:OnCreated() self:TraceLifecycle('modifier_applied') end
function modifier_enfos_vs_retribution:OnRefresh() self:TraceLifecycle('modifier_refreshed') end
function modifier_enfos_vs_retribution:OnDestroy() self:TraceLifecycle('modifier_removed') end
