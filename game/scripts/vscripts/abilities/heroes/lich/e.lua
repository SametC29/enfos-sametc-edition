-- Lich isolated kit: preserve stable classes, values and lifecycle behavior.
local Helpers = require('abilities/shared/pve_helpers')
local value, enemies, is_boss, get_int, damage = Helpers.value, Helpers.enemies, Helpers.is_boss, Helpers.get_int, Helpers.damage
local HeroTrace = require('lib/hero_trace')
local Upgrades = require('abilities/heroes/lich/upgrades')
local function owns_gaze_target(ab,p)
    if ab.gazeTargets then return ab.gazeTargets[p] == true end
    return ab.gazeTarget == p
end

LinkLuaModifier('modifier_enfos_lich_sinister_gaze_debuff', 'abilities/heroes/lich/e', LUA_MODIFIER_MOTION_NONE)

enfos_lich_sinister_gaze=class({})
function enfos_lich_sinister_gaze:GetBehavior()
    if Upgrades.HasScepter(self:GetCaster()) then
        return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_CHANNELLED
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_CHANNELLED
end
function enfos_lich_sinister_gaze:GetAOERadius()
    return Upgrades.HasScepter(self:GetCaster()) and value(self,'aoe_scepter') or 0
end
function enfos_lich_sinister_gaze:BeginAreaGaze(c)
    if not c or c:IsNull() or not c:IsAlive() then return end
    -- Snapshot and clean any prior controls before publishing the new ownership.
    if self.gazeTargets or self.gazeTarget then self:OnChannelFinish(true) end
    local selected = enemies(c,self:GetCursorPosition(),self:GetAOERadius())
    local targets = {}
    for _,target in ipairs(selected) do
        if target and not target:IsNull() and target:IsAlive() and target:GetTeamNumber() ~= c:GetTeamNumber() then
            targets[target] = true
        end
    end
    self.gazeTargets = targets
    self.gazeStarting = true
    local duration, applied = self:GetChannelTime(), 0
    if next(targets) then c:EmitSound('Hero_Lich.SinisterGaze.Cast') end
    for target in pairs(targets) do
        if c:IsNull() or not c:IsAlive() or (self.IsNull and self:IsNull()) then break end
        if target:IsNull() or not target:IsAlive() or target:GetTeamNumber() == c:GetTeamNumber() then
            targets[target] = nil
        else
            local control = target:AddNewModifier(c,self,'modifier_enfos_lich_sinister_gaze_debuff',{duration=duration})
            if control and targets[target] then applied = applied + 1 else targets[target] = nil end
        end
    end
    self.gazeStarting = nil
    if self.IsNull and self:IsNull() then self.gazeTargets = nil;return end
    HeroTrace:Log('LICH','E','channel_start scepter=true affected=%s duration=%s radius=%s',tostring(applied),tostring(duration),tostring(value(self,'aoe_scepter')))
    if not next(targets) or c:IsNull() or not c:IsAlive() then
        if not c:IsNull() and c.GetCurrentActiveAbility and c:GetCurrentActiveAbility()==self then
            self:EndChannel(true)
        else
            self:OnChannelFinish(true)
        end
    end
end

function enfos_lich_sinister_gaze:GetChannelTime()
    local duration = value(self, 'duration')
    if duration <= 0 then duration = 2.0 end
    return duration
end
function enfos_lich_sinister_gaze:OnSpellStart()
    if not IsServer() then return end
    local c = self:GetCaster()
    if Upgrades.HasScepter(c) then self:BeginAreaGaze(c);return end
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
    local c, primary, targets = self:GetCaster(), self.gazeTarget, self.gazeTargets
    self.gazeTarget, self.gazeTargets, self.gazeStarting = nil, nil, nil
    HeroTrace:Log('LICH','E','channel_finish target=%s interrupted=%s area=%s',HeroTrace:Name(primary),tostring(interrupted),tostring(targets~=nil))
    if not c or c:IsNull() then return end
    if targets then
        for target in pairs(targets) do
            if not target:IsNull() then target:RemoveModifierByNameAndCaster('modifier_enfos_lich_sinister_gaze_debuff',c) end
        end
    elseif primary and not primary:IsNull() then
        primary:RemoveModifierByNameAndCaster('modifier_enfos_lich_sinister_gaze_debuff',c)
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
    if not ab or (ab.IsNull and ab:IsNull()) or not owns_gaze_target(ab,p) then return end
    -- ChannelFinish clears ownership before removing this modifier. An old
    -- recipient must not interrupt another cast or erase a newer target.
    if ab.gazeTargets then
        ab.gazeTargets[p] = nil
        if ab.gazeStarting or next(ab.gazeTargets) then return end
        ab.gazeTargets = nil
    end
    ab.gazeTarget = nil
    local ownsChannel = c and not c:IsNull() and c.GetCurrentActiveAbility and c:GetCurrentActiveAbility() == ab
    HeroTrace:Log('LICH', 'E', 'control_removed target=%s matching_channel=%s', HeroTrace:Name(p), tostring(not not ownsChannel))
    if ownsChannel and ab.EndChannel then ab:EndChannel(true) end
end
