-- Lich isolated kit: preserve stable classes, values and lifecycle behavior.
local Helpers = require('abilities/shared/pve_helpers')
local value, enemies, is_boss, get_int, damage = Helpers.value, Helpers.enemies, Helpers.is_boss, Helpers.get_int, Helpers.damage
local HeroTrace = require('lib/hero_trace')

LinkLuaModifier('modifier_enfos_lich_frost_shield', 'abilities/heroes/lich/w', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_enfos_lich_frost_shield_slow', 'abilities/heroes/lich/w', LUA_MODIFIER_MOTION_NONE)

enfos_lich_frost_shield=class({})
function enfos_lich_frost_shield:Precache(context)
    PrecacheResource('soundfile', 'soundevents/game_sounds_heroes/game_sounds_lich.vsndevts', context)
    PrecacheResource('particle', 'particles/units/heroes/hero_lich/lich_ice_age.vpcf', context)
end
function enfos_lich_frost_shield:OnSpellStart()
    if not IsServer() then return end
    local c = self:GetCaster()
    if not c or c:IsNull() or not c:IsAlive() then return end
    local t = self:GetCursorTarget() or c
    if not t or t:IsNull() or not t:IsAlive() then return end
    if t:GetTeamNumber() ~= c:GetTeamNumber() then
        HeroTrace:Log('LICH','W','cast_cancelled reason=enemy_recipient target=%s',HeroTrace:Name(t))
        return
    end
    local dur = value(self, 'duration')
    if dur <= 0 then dur = 6.0 end
    t:EmitSound('Hero_Lich.IceAge')
    t:AddNewModifier(c, self, 'modifier_enfos_lich_frost_shield', { duration = dur })
    if HeroTrace:Enabled() then HeroTrace:Log('LICH','W','cast caster=%s recipient=%s rank=%s duration=%s reduction=%s',HeroTrace:Name(c),HeroTrace:Name(t),tostring(self:GetLevel()),tostring(dur),tostring(value(self,'damage_reduction'))) end
end

modifier_enfos_lich_frost_shield=class({})
function modifier_enfos_lich_frost_shield:IsDebuff() return false end
function modifier_enfos_lich_frost_shield:IsPurgable() return true end
function modifier_enfos_lich_frost_shield:GetTexture() return 'lich_frost_shield' end
function modifier_enfos_lich_frost_shield:OnCreated()
    if not IsServer() then return end
    local p, c, ab = self:GetParent(), self:GetCaster(), self:GetAbility()
    if not p or p:IsNull() or not p:IsAlive() or not c or c:IsNull()
        or p:GetTeamNumber() ~= c:GetTeamNumber() or not ab or (ab.IsNull and ab:IsNull()) then self:Destroy(); return end
    local radius = value(ab, 'radius')
    if radius <= 0 then radius = 600 end
    local interval = value(ab, 'pulse_interval')
    if interval <= 0 then interval = 1 end
    -- Installed Ice Age root: CP1 is the recipient, CP2.x is the ring radius.
    -- The modifier owns this persistent resource, including dispel/death cleanup.
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_lich/lich_ice_age.vpcf', PATTACH_ABSORIGIN_FOLLOW, p)
    for _, cp in ipairs({0, 1, 5}) do
        ParticleManager:SetParticleControlEnt(fx, cp, p, PATTACH_ABSORIGIN_FOLLOW, '', p:GetAbsOrigin(), true)
    end
    ParticleManager:SetParticleControl(fx, 2, Vector(radius, radius, radius))
    self:AddParticle(fx, false, false, -1, false, false)
    HeroTrace:Log('LICH','W','shield_created recipient=%s owner=%s particle=%s particle_owner=modifier radius=%s interval=%s',HeroTrace:Name(p),HeroTrace:Name(c),tostring(fx),tostring(radius),tostring(interval))
    self:StartIntervalThink(interval)
end
function modifier_enfos_lich_frost_shield:OnRefresh()
    if not IsServer() or not HeroTrace:Enabled() then return end
    HeroTrace:Log('LICH','W','shield_refreshed recipient=%s owner=%s reduction=%s dps=%s',HeroTrace:Name(self:GetParent()),HeroTrace:Name(self:GetCaster()),tostring(value(self:GetAbility(),'damage_reduction')),tostring(value(self:GetAbility(),'dps')))
end
function modifier_enfos_lich_frost_shield:OnDestroy()
    if IsServer() then HeroTrace:Log('LICH','W','shield_removed recipient=%s owner=%s particle_cleanup=modifier_engine',HeroTrace:Name(self:GetParent()),HeroTrace:Name(self:GetCaster())) end
end
function modifier_enfos_lich_frost_shield:OnIntervalThink()
    if not IsServer() then return end
    local p = self:GetParent()
    local c = self:GetCaster()
    local ab = self:GetAbility()
    if not p or p:IsNull() or not p:IsAlive() or not c or c:IsNull()
        or p:GetTeamNumber() ~= c:GetTeamNumber()
        or not ab or (ab.IsNull and ab:IsNull()) then
        HeroTrace:Log('LICH','W','pulse_cancelled reason=invalid_source_or_recipient recipient=%s',HeroTrace:Name(p))
        self:Destroy(); return
    end
    local dps = value(ab, 'dps')
    local int = get_int(c)
    local total_dps = dps + (int * 0.25)
    local affected, bosses, actual = 0, 0, 0
    local measured = true
    local tracing = HeroTrace:Enabled()
    local radius = value(ab, 'radius')
    if radius <= 0 then radius = 600 end
    for _, u in ipairs(enemies(c, p:GetAbsOrigin(), radius)) do
        if u and not u:IsNull() and u:IsAlive() then
            local boss = tracing and is_boss(u)
            local dealt = damage(ab, u, total_dps, DAMAGE_TYPE_MAGICAL)
            if type(dealt)=='number' then actual=actual+dealt else measured=false end
            if boss then bosses=bosses+1 end
            affected = affected + 1
            if c:IsNull() or p:IsNull() or not p:IsAlive() or (ab.IsNull and ab:IsNull()) then break end
            if not u:IsNull() and u:IsAlive() then
                u:AddNewModifier(c, ab, 'modifier_enfos_lich_frost_shield_slow',
                    { duration = value(ab, 'slow_duration') })
            end
        end
    end
    HeroTrace:Log('LICH','W','pulse recipient=%s owner=%s affected=%d bosses=%d requested_damage=%s actual_total=%s',HeroTrace:Name(p),HeroTrace:Name(c),affected,bosses,tostring(total_dps),measured and tostring(actual) or '<unavailable>')
end

modifier_enfos_lich_frost_shield_slow=class({})
function modifier_enfos_lich_frost_shield_slow:IsDebuff() return true end
function modifier_enfos_lich_frost_shield_slow:IsPurgable() return true end
function modifier_enfos_lich_frost_shield_slow:GetTexture() return 'lich_frost_shield' end
function modifier_enfos_lich_frost_shield_slow:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end
function modifier_enfos_lich_frost_shield_slow:GetModifierMoveSpeedBonus_Percentage()
    return -value(self:GetAbility(), 'movement_slow')
end
local function shield_slow_trace(modifier,event)
    if IsServer() and HeroTrace:Enabled() then
        HeroTrace:Log('LICH','W',event..' target=%s owner=%s slow=%s',
            HeroTrace:Name(modifier:GetParent()),HeroTrace:Name(modifier:GetCaster()),
            tostring(value(modifier:GetAbility(),'movement_slow')))
    end
end
function modifier_enfos_lich_frost_shield_slow:OnCreated() shield_slow_trace(self,'slow_created') end
function modifier_enfos_lich_frost_shield_slow:OnRefresh() shield_slow_trace(self,'slow_refreshed') end
function modifier_enfos_lich_frost_shield_slow:OnDestroy() shield_slow_trace(self,'slow_removed') end
function modifier_enfos_lich_frost_shield:DeclareFunctions() return { MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE } end
function modifier_enfos_lich_frost_shield:GetModifierIncomingPhysicalDamage_Percentage()
    local p, c, ab = self:GetParent(), self:GetCaster(), self:GetAbility()
    -- Property evaluation may precede the next pulse's ownership/cleanup check.
    if not p or p:IsNull() or not p:IsAlive() or not c or c:IsNull()
        or p:GetTeamNumber() ~= c:GetTeamNumber()
        or not ab or (ab.IsNull and ab:IsNull()) then return 0 end
    return -value(ab, 'damage_reduction')
end
