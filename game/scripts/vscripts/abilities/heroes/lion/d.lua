-- Lion D: authored Enfos numeric passive, distinct from native To Hell and Back.
local value=require('abilities/shared/pve_helpers').value
local Trace=require('lib/hero_trace')
local function valid(x) return x and not (x.IsNull and x:IsNull()) end
local function bonus(m,key)
    if m.closed then return 0 end
    local c=m:GetParent()
    if not valid(c) or c:PassivesDisabled() or c:IsIllusion() then return 0 end
    local a=m:GetAbility()
    if not valid(a) or a:GetLevel()<=0 then return 0 end
    return value(a,key)
end
LinkLuaModifier('modifier_enfos_lion_demon_soul_passive','abilities/heroes/lion/d',LUA_MODIFIER_MOTION_NONE)
enfos_lion_demon_soul=class({})
function enfos_lion_demon_soul:GetIntrinsicModifierName() return 'modifier_enfos_lion_demon_soul_passive' end
modifier_enfos_lion_demon_soul_passive=class({})
function modifier_enfos_lion_demon_soul_passive:IsHidden() return false end
function modifier_enfos_lion_demon_soul_passive:IsPurgable() return false end
function modifier_enfos_lion_demon_soul_passive:IsPurgeException() return false end
function modifier_enfos_lion_demon_soul_passive:RemoveOnDeath() return false end
function modifier_enfos_lion_demon_soul_passive:GetTexture() return 'lion_mana_drain' end
function modifier_enfos_lion_demon_soul_passive:DeclareFunctions()
    return {MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,MODIFIER_PROPERTY_TOOLTIP,MODIFIER_PROPERTY_TOOLTIP2}
end
function modifier_enfos_lion_demon_soul_passive:GetModifierCastRangeBonusStacking() return bonus(self,'cast_range_bonus') end
function modifier_enfos_lion_demon_soul_passive:GetModifierSpellAmplify_Percentage() return bonus(self,'spell_amp') end
function modifier_enfos_lion_demon_soul_passive:OnTooltip() return bonus(self,'cast_range_bonus') end
function modifier_enfos_lion_demon_soul_passive:OnTooltip2() return bonus(self,'spell_amp') end
function modifier_enfos_lion_demon_soul_passive:TraceLifecycle(event)
    if not Trace:Enabled() then return end
    Trace:Log('LION','D','%s range=%.1f spell_amp=%.1f',event,bonus(self,'cast_range_bonus'),bonus(self,'spell_amp'))
end
function modifier_enfos_lion_demon_soul_passive:OnCreated()
    self.closed=false
    self:TraceLifecycle('passive applied')
end
function modifier_enfos_lion_demon_soul_passive:OnRefresh()
    if not self.closed then self:TraceLifecycle('passive refreshed') end
end
function modifier_enfos_lion_demon_soul_passive:OnDestroy()
    if self.closed then return end
    self:TraceLifecycle('passive removed')
    self.closed=true
end
