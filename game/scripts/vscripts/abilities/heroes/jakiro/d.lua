-- Jakiro fifth Enfos passive: authored ten-rank stats, not the native innate attack.
local value = require('abilities/shared/pve_helpers').value
local HeroTrace = require('lib/hero_trace')
local function passive_value(modifier, key)
    local c = modifier:GetParent()
    if not c or (c.IsNull and c:IsNull()) or (c.PassivesDisabled and c:PassivesDisabled()) or (c.IsIllusion and c:IsIllusion()) then return 0 end
    local a = modifier:GetAbility()
    if not a or (a.IsNull and a:IsNull()) or (a.GetLevel and a:GetLevel() <= 0) then return 0 end
    return value(a, key)
end
LinkLuaModifier('modifier_enfos_jakiro_double_trouble', 'abilities/heroes/jakiro/d', LUA_MODIFIER_MOTION_NONE)
enfos_jakiro_double_trouble=class({})
function enfos_jakiro_double_trouble:GetIntrinsicModifierName() return 'modifier_enfos_jakiro_double_trouble' end
modifier_enfos_jakiro_double_trouble=class({})
function modifier_enfos_jakiro_double_trouble:IsHidden() return false end
function modifier_enfos_jakiro_double_trouble:IsPurgable() return false end
function modifier_enfos_jakiro_double_trouble:IsPurgeException() return false end
function modifier_enfos_jakiro_double_trouble:RemoveOnDeath() return false end
function modifier_enfos_jakiro_double_trouble:GetTexture() return 'jakiro_liquid_fire' end
function modifier_enfos_jakiro_double_trouble:DeclareFunctions()
    return { MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_TOOLTIP, MODIFIER_PROPERTY_TOOLTIP2 }
end
function modifier_enfos_jakiro_double_trouble:GetModifierBonusStats_Intellect() return passive_value(self, 'bonus_int') end
function modifier_enfos_jakiro_double_trouble:GetModifierAttackSpeedBonus_Constant() return passive_value(self, 'bonus_as') end
function modifier_enfos_jakiro_double_trouble:OnTooltip() return passive_value(self, 'bonus_int') end
function modifier_enfos_jakiro_double_trouble:OnTooltip2() return passive_value(self, 'bonus_as') end
function modifier_enfos_jakiro_double_trouble:TraceLifecycle(event)
    if not HeroTrace:Enabled() then return end
    HeroTrace:Log('JAKIRO','D','%s source=%s intellect_bonus=%s attack_speed_bonus=%s', event,
        HeroTrace:Name(self:GetParent()), tostring(passive_value(self,'bonus_int')), tostring(passive_value(self,'bonus_as')))
end
function modifier_enfos_jakiro_double_trouble:OnCreated() self:TraceLifecycle('modifier_applied') end
function modifier_enfos_jakiro_double_trouble:OnRefresh() self:TraceLifecycle('modifier_refreshed') end
function modifier_enfos_jakiro_double_trouble:OnDestroy() self:TraceLifecycle('modifier_removed') end
