-- Lich isolated kit: preserve stable classes, values and lifecycle behavior.
local Helpers = require('abilities/shared/pve_helpers')
local value, enemies, get_int, damage = Helpers.value, Helpers.enemies, Helpers.get_int, Helpers.damage
local HeroTrace = require('lib/hero_trace')

LinkLuaModifier('modifier_enfos_lich_frost_blast_slow', 'abilities/heroes/lich/q', LUA_MODIFIER_MOTION_NONE)

enfos_lich_frost_blast=class({})
function enfos_lich_frost_blast:OnSpellStart()
    if not IsServer() then return end
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or t:IsNull() or not t:IsAlive() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then
        HeroTrace:Log('LICH','Q','cast_cancelled reason=spell_absorb target=%s',HeroTrace:Name(t))
        return
    end
    local origin = t:GetAbsOrigin()
    HeroTrace:Log('LICH','Q','cast caster=%s target=%s rank=%s position=%s',
        HeroTrace:Name(c),HeroTrace:Name(t),tostring(self.GetLevel and self:GetLevel() or 0),tostring(origin))
    c:EmitSound('Ability.FrostNova')
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
    damage(self, t, primary, DAMAGE_TYPE_MAGICAL)
    if c:IsNull() or (self.IsNull and self:IsNull()) then
        HeroTrace:Log('LICH','Q','impact_cancelled reason=source_removed_after_primary_damage')
        return
    end
    HeroTrace:Log('LICH','Q','primary target=%s requested_damage=%s slow_duration=%s alive=%s',
        HeroTrace:Name(t),tostring(primary),tostring(primary_slow_duration),tostring(not t:IsNull() and t:IsAlive()))
    if not t:IsNull() and t:IsAlive() then
        t:AddNewModifier(c, self, 'modifier_enfos_lich_frost_blast_slow', { duration = primary_slow_duration })
    end
    local affected = 0
    for _, u in ipairs(enemies(c, origin, radius)) do
        if c:IsNull() or (self.IsNull and self:IsNull()) then break end
        if u ~= t then
        local splash = rdmg + (int * 0.5)
        local dur = slow_duration
        damage(self, u, splash, DAMAGE_TYPE_MAGICAL)
        affected = affected + 1
        if c:IsNull() or (self.IsNull and self:IsNull()) then break end
        if not u:IsNull() and u:IsAlive() then
            u:AddNewModifier(c, self, 'modifier_enfos_lich_frost_blast_slow', { duration = dur })
        end
        end
    end
    HeroTrace:Log('LICH','Q','impact_summary splash_targets=%d radius=%s',affected,tostring(radius))
end

modifier_enfos_lich_frost_blast_slow=class({})
function modifier_enfos_lich_frost_blast_slow:IsDebuff() return true end
function modifier_enfos_lich_frost_blast_slow:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end
function modifier_enfos_lich_frost_blast_slow:GetModifierMoveSpeedBonus_Percentage() return -value(self:GetAbility(), 'slow_pct') end
function modifier_enfos_lich_frost_blast_slow:GetModifierAttackSpeedBonus_Constant()
    local slow = value(self:GetAbility(), 'slow_attack')
    return -(slow > 0 and slow or 40)
end
