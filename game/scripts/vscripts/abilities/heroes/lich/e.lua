-- Lich isolated kit: preserve stable classes, values and lifecycle behavior.
local Helpers = require('abilities/shared/pve_helpers')
local value, enemies, is_boss, get_int, damage = Helpers.value, Helpers.enemies, Helpers.is_boss, Helpers.get_int, Helpers.damage
local HeroTrace = require('lib/hero_trace')

LinkLuaModifier('modifier_enfos_lich_sinister_gaze_debuff', 'abilities/heroes/lich/e', LUA_MODIFIER_MOTION_NONE)

enfos_lich_sinister_gaze=class({})
function enfos_lich_sinister_gaze:GetChannelTime()
    local duration = value(self, 'duration')
    if duration <= 0 then duration = 2.0 end
    return duration
end
function enfos_lich_sinister_gaze:OnSpellStart()
    if not IsServer() then return end
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or t:IsNull() or not t:IsAlive() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end
    c:EmitSound('Hero_Lich.SinisterGaze.Cast')
    local dur = value(self, 'duration')
    if dur <= 0 then dur = 2.0 end
    self.gazeTarget = t
    HeroTrace:Log('LICH', 'E', 'channel_start target=%s duration=%.2f boss=%s', HeroTrace:Name(t), dur, tostring(is_boss(t)))
    t:AddNewModifier(c, self, 'modifier_enfos_lich_sinister_gaze_debuff', { duration = dur })
end
function enfos_lich_sinister_gaze:OnChannelFinish(interrupted)
    if not IsServer() then return end
    local c = self:GetCaster()
    local t = self.gazeTarget
    self.gazeTarget = nil
    HeroTrace:Log('LICH', 'E', 'channel_finish target=%s interrupted=%s', HeroTrace:Name(t), tostring(interrupted))
    if t and not t:IsNull() and c and not c:IsNull() then
        t:RemoveModifierByNameAndCaster('modifier_enfos_lich_sinister_gaze_debuff', c)
    end
end

modifier_enfos_lich_sinister_gaze_debuff=class({})
function modifier_enfos_lich_sinister_gaze_debuff:IsDebuff() return true end
-- Native Gaze allows basic dispel. Hypnosis blocks actions but is not a
-- strong-dispel-only stun for purge classification.
function modifier_enfos_lich_sinister_gaze_debuff:IsPurgable() return true end
function modifier_enfos_lich_sinister_gaze_debuff:IsStunDebuff() return false end
function modifier_enfos_lich_sinister_gaze_debuff:GetTexture() return 'lich_sinister_gaze' end
function modifier_enfos_lich_sinister_gaze_debuff:CheckState()
    return { [MODIFIER_STATE_STUNNED] = true }
end
function modifier_enfos_lich_sinister_gaze_debuff:GetEffectName()
    return 'particles/units/heroes/hero_lich/lich_gaze.vpcf'
end
function modifier_enfos_lich_sinister_gaze_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_enfos_lich_sinister_gaze_debuff:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(0.5)
end
function modifier_enfos_lich_sinister_gaze_debuff:OnIntervalThink()
    if not IsServer() then return end
    local p = self:GetParent()
    local c = self:GetCaster()
    local ab = self:GetAbility()
    if not ab or (ab.IsNull and ab:IsNull()) or not c or c:IsNull() or not c:IsAlive() or not p or p:IsNull() or not p:IsAlive() then
        HeroTrace:Log('LICH', 'E', 'control_cancel target=%s invalid_source_or_recipient=true', HeroTrace:Name(p))
        self:Destroy()
        return
    end
    local drain = value(ab, 'mana_drain_pct')
    local drained = math.min(p:GetMana(), p:GetMaxMana() * drain * 0.01 * 0.5)
    if drained > 0 then
        if p.ReduceMana then
            p:ReduceMana(drained)
            if c.GiveMana then c:GiveMana(drained) end
        elseif p.SetMana and p.GetMana then
            local actual = math.min(drained, p:GetMana())
            p:SetMana(math.max(0, p:GetMana() - actual))
            if c.GiveMana then c:GiveMana(actual) end
        end
    end
    local dir = (c:GetAbsOrigin() - p:GetAbsOrigin()):Normalized()
    local pulled = false
    if (p:GetAbsOrigin() - c:GetAbsOrigin()):Length2D() > 100 then
        p:SetAbsOrigin(p:GetAbsOrigin() + (dir * 40))
        FindClearSpaceForUnit(p, p:GetAbsOrigin(), true)
        pulled = true
    end
    HeroTrace:Log('LICH', 'E', 'control_tick target=%s mana=%.2f pulled=%s', HeroTrace:Name(p), drained, tostring(pulled))
end
function modifier_enfos_lich_sinister_gaze_debuff:OnDestroy()
    if not IsServer() then return end
    local ab = self:GetAbility()
    local c = self:GetCaster()
    local p = self:GetParent()
    if not ab or (ab.IsNull and ab:IsNull()) or ab.gazeTarget ~= p then return end
    -- ChannelFinish clears ownership before removing this modifier. An old
    -- recipient must not interrupt another cast or erase a newer target.
    ab.gazeTarget = nil
    local ownsChannel = c and not c:IsNull() and c.GetCurrentActiveAbility and c:GetCurrentActiveAbility() == ab
    HeroTrace:Log('LICH', 'E', 'control_removed target=%s matching_channel=%s', HeroTrace:Name(p), tostring(not not ownsChannel))
    if ownsChannel and ab.EndChannel then ab:EndChannel(true) end
end
