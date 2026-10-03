-- Lich isolated kit: preserve stable classes, values and lifecycle behavior.
local Helpers = require('abilities/shared/pve_helpers')
local value, enemies, get_int, damage = Helpers.value, Helpers.enemies, Helpers.get_int, Helpers.damage
local HeroTrace = require('lib/hero_trace')
local Upgrades = require('abilities/heroes/lich/upgrades')

LinkLuaModifier('modifier_enfos_lich_frost_blast_slow', 'abilities/heroes/lich/q', LUA_MODIFIER_MOTION_NONE)

enfos_lich_frost_blast=class({})
function enfos_lich_frost_blast:GetBehavior() return Upgrades.CastBehavior(self) end
function enfos_lich_frost_blast:OnSpellStart()
    if not IsServer() then return end
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or t:IsNull() or not t:IsAlive() then return end
    if t:GetTeamNumber() == c:GetTeamNumber() then
        HeroTrace:Log('LICH','Q','cast_cancelled reason=friendly_target target=%s',HeroTrace:Name(t))
        return
    end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then
        HeroTrace:Log('LICH','Q','cast_cancelled reason=spell_absorb target=%s',HeroTrace:Name(t))
        return
    end
    local origin = t:GetAbsOrigin()
    HeroTrace:Log('LICH','Q','cast caster=%s target=%s rank=%s position=%s',
        HeroTrace:Name(c),HeroTrace:Name(t),tostring(self.GetLevel and self:GetLevel() or 0),tostring(origin))
    t:EmitSound('Ability.FrostNova')
    local radius = value(self, 'radius')
    if radius <= 0 then radius = 250 end
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_lich/lich_frost_nova.vpcf', PATTACH_ABSORIGIN_FOLLOW, t)
    ParticleManager:SetParticleControl(fx, 0, origin)
    -- Installed Frost Nova children read CP1.xyz for ring size/thickness/speed.
    ParticleManager:SetParticleControl(fx, 1, Vector(radius, radius, radius))
    ParticleManager:ReleaseParticleIndex(fx)
    HeroTrace:Log('LICH','Q','nova_particle index=%s radius=%s position=%s cleanup=finite_resource_release',tostring(fx),tostring(radius),tostring(origin))
    local tdmg = value(self, 'target_damage')
    local rdmg = value(self, 'radius_damage')
    local int = get_int(c)
    local primary = tdmg + (int * 0.8)
    local slow_duration = value(self, 'duration')
    if slow_duration <= 0 then slow_duration = 4 end
    local primary_slow_duration = slow_duration
    local primary_dealt = damage(self, t, primary, DAMAGE_TYPE_MAGICAL)
    HeroTrace:Log('LICH','Q','damage_result target=%s requested_damage=%s actual_damage=%s',
        HeroTrace:Name(t),tostring(primary),type(primary_dealt)=='number' and tostring(primary_dealt) or '<unavailable>')
    if c:IsNull() or (self.IsNull and self:IsNull()) then
        HeroTrace:Log('LICH','Q','impact_cancelled reason=source_removed_after_primary_damage')
        return
    end
    HeroTrace:Log('LICH','Q','primary target=%s requested_damage=%s slow_duration=%s alive=%s',
        HeroTrace:Name(t),tostring(primary),tostring(primary_slow_duration),tostring(not t:IsNull() and t:IsAlive()))
    if not t:IsNull() and t:IsAlive() then
        t:AddNewModifier(c, self, 'modifier_enfos_lich_frost_blast_slow', { duration = primary_slow_duration })
    end
    -- Preserve the pre-primary snapshot even if a damage callback changes rank/INT.
    local affected, splash_actual = self:ApplySplashAtPoint(origin, t,
        {radius=radius, damage=rdmg + int * 0.5, duration=slow_duration})
    HeroTrace:Log('LICH','Q','impact_summary splash_targets=%d radius=%s splash_actual_total=%s',
        affected,tostring(radius),type(splash_actual)=='number' and tostring(splash_actual) or '<unavailable>')
end

-- Shared splash calculation for targeted Q and the native-style Shard death Nova.
-- No primary target bonus, resource payment, spell block, or extra cast is added.
function enfos_lich_frost_blast:ApplySplashAtPoint(origin, excluded, snapshot)
    if not IsServer() or (self.IsNull and self:IsNull()) then return 0, 0 end
    local c = self:GetCaster()
    if not origin or not c or c:IsNull() then return 0, 0 end
    local affected, actual, measured = 0, 0, true
    for _, u in ipairs(enemies(c, origin, snapshot.radius)) do
        if c:IsNull() or (self.IsNull and self:IsNull()) then break end
        -- Damage callbacks can delete/kill later members of the search snapshot.
        if u ~= excluded and u and not u:IsNull() and u:IsAlive()
            and u:GetTeamNumber() ~= c:GetTeamNumber() then
            local dealt = damage(self, u, snapshot.damage, DAMAGE_TYPE_MAGICAL)
            if type(dealt)=='number' then actual=actual+dealt else measured=false end
            affected=affected+1
            if c:IsNull() or (self.IsNull and self:IsNull()) then break end
            if not u:IsNull() and u:IsAlive() then
                u:AddNewModifier(c, self, 'modifier_enfos_lich_frost_blast_slow',
                    {duration=snapshot.duration})
            end
        end
    end
    return affected, measured and actual or nil
end

function enfos_lich_frost_blast:BlastAtPoint(origin)
    if not IsServer() or (self.IsNull and self:IsNull()) or self:GetLevel() < 1 then return 0, 0 end
    local c = self:GetCaster()
    -- A surviving Spire may detonate after its owner dies; deleted owners cannot.
    if not origin or not c or c:IsNull() then return 0, 0 end
    local radius = value(self, 'radius')
    if radius <= 0 then radius=250 end
    local duration = value(self, 'duration')
    if duration <= 0 then duration=4 end
    local snapshot = {radius=radius, duration=duration,
        damage=value(self, 'radius_damage') + get_int(c) * 0.5}
    EmitSoundOnLocationWithCaster(origin, 'Ability.FrostNova', c)
    -- The dead/removed Spire is not used as particle owner or attachment.
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_lich/lich_frost_nova.vpcf', PATTACH_WORLDORIGIN, c)
    ParticleManager:SetParticleControl(fx, 0, origin)
    ParticleManager:SetParticleControl(fx, 1, Vector(radius, radius, radius))
    ParticleManager:ReleaseParticleIndex(fx)
    local affected, actual = self:ApplySplashAtPoint(origin, nil, snapshot)
    HeroTrace:Log('LICH','Q','spire_nova position=%s rank=%s affected=%d requested_damage=%s actual_total=%s particle=%s cleanup=finite_resource_release',
        tostring(origin),tostring(self:GetLevel()),affected,tostring(snapshot.damage),
        type(actual)=='number' and tostring(actual) or '<unavailable>',tostring(fx))
    return affected, actual
end

modifier_enfos_lich_frost_blast_slow=class({})
local function lich_frost_blast_slow_trace(modifier, event)
    if not IsServer() or not HeroTrace:Enabled() then return end
    HeroTrace:Log('LICH','Q','%s target=%s owner=%s',event,
        HeroTrace:Name(modifier:GetParent()),HeroTrace:Name(modifier:GetCaster()))
end
function modifier_enfos_lich_frost_blast_slow:OnCreated() lich_frost_blast_slow_trace(self, 'slow_created') end
function modifier_enfos_lich_frost_blast_slow:OnRefresh() lich_frost_blast_slow_trace(self, 'slow_refreshed') end
function modifier_enfos_lich_frost_blast_slow:OnDestroy() lich_frost_blast_slow_trace(self, 'slow_removed') end
function modifier_enfos_lich_frost_blast_slow:IsDebuff() return true end
function modifier_enfos_lich_frost_blast_slow:IsPurgable() return true end
function modifier_enfos_lich_frost_blast_slow:GetTexture() return 'lich_frost_nova' end
function modifier_enfos_lich_frost_blast_slow:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end
function modifier_enfos_lich_frost_blast_slow:GetModifierMoveSpeedBonus_Percentage() return -value(self:GetAbility(), 'slow_pct') end
function modifier_enfos_lich_frost_blast_slow:GetModifierAttackSpeedBonus_Constant()
    local ab = self:GetAbility()
    if not ab or (ab.IsNull and ab:IsNull()) then return 0 end
    local slow = value(ab, 'slow_attack')
    return -(slow > 0 and slow or 40)
end
