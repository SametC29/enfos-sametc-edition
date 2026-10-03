-- Luna W: isolated Lunar Orbit. Keeps Enfos PvE tuning with native Lunar Orbit presentation.
local Helpers = require('abilities/shared/pve_helpers')
local value, enemies, get_agi, damage = Helpers.value, Helpers.enemies, Helpers.get_agi, Helpers.damage
local HeroTrace = require('lib/hero_trace')

local function alive(unit)
    return unit and not (unit.IsNull and unit:IsNull()) and unit:IsAlive()
end

LinkLuaModifier('modifier_enfos_luna_lunar_orbit_buff', 'abilities/heroes/luna/w', LUA_MODIFIER_MOTION_NONE)

enfos_luna_lunar_orbit = class({})

function enfos_luna_lunar_orbit:Precache(context)
    PrecacheResource('soundfile', 'soundevents/game_sounds_heroes/game_sounds_luna.vsndevts', context)
    PrecacheResource('particle', 'particles/units/heroes/hero_luna/luna_moon_glaive_shield.vpcf', context)
    PrecacheResource('particle', 'particles/units/heroes/hero_luna/luna_base_attack_impact.vpcf', context)
end

function enfos_luna_lunar_orbit:OnSpellStart()
    if not IsServer() or (self.IsNull and self:IsNull()) then return end
    local c = self:GetCaster()
    if not alive(c) then return end
    local duration = value(self, 'duration')
    c:EmitSound('Hero_Luna.LunarOrbit.Cast')
    local mod = c:AddNewModifier(c, self, 'modifier_enfos_luna_lunar_orbit_buff', {
        duration = duration,
        damage_reduction_pct = value(self, 'damage_reduction_pct'),
        bonus_range = value(self, 'bonus_range'),
        bonus_ms = value(self, 'bonus_ms'),
        pulse_interval = value(self, 'pulse_interval'),
        pulse_radius = value(self, 'pulse_radius'),
        pulse_damage = value(self, 'pulse_damage'),
        agility_multiplier = value(self, 'agility_multiplier'),
    })
    HeroTrace:Log('LUNA','W','cast caster=%s rank=%s duration=%s modifier_applied=%s',
        HeroTrace:Name(c),tostring(self.GetLevel and self:GetLevel() or 0),tostring(duration),tostring(mod~=nil))
end

modifier_enfos_luna_lunar_orbit_buff = class({})

function modifier_enfos_luna_lunar_orbit_buff:IsHidden() return false end
function modifier_enfos_luna_lunar_orbit_buff:IsDebuff() return false end
function modifier_enfos_luna_lunar_orbit_buff:IsPurgable() return false end
function modifier_enfos_luna_lunar_orbit_buff:GetTexture() return 'luna_lunar_orbit' end

function modifier_enfos_luna_lunar_orbit_buff:Snapshot(params)
    local a = self:GetAbility()
    self.damage_reduction_pct = tonumber(params and params.damage_reduction_pct) or value(a, 'damage_reduction_pct')
    self.bonus_range = tonumber(params and params.bonus_range) or value(a, 'bonus_range')
    self.bonus_ms = tonumber(params and params.bonus_ms) or value(a, 'bonus_ms')
    self.pulse_interval = tonumber(params and params.pulse_interval) or value(a, 'pulse_interval')
    self.pulse_radius = tonumber(params and params.pulse_radius) or value(a, 'pulse_radius')
    self.pulse_damage = tonumber(params and params.pulse_damage) or value(a, 'pulse_damage')
    self.agility_multiplier = tonumber(params and params.agility_multiplier) or value(a, 'agility_multiplier')
    if self.pulse_interval <= 0 then self.pulse_interval = 0.5 end
    if self.pulse_radius <= 0 then self.pulse_radius = 320 end
end

function modifier_enfos_luna_lunar_orbit_buff:OnCreated(params)
    if not IsServer() then return end
    local c = self:GetParent()
    local a = self:GetAbility()
    if not alive(c) or not a or (a.IsNull and a:IsNull()) then self:Destroy(); return end
    self:Snapshot(params)

    self.pfx = ParticleManager:CreateParticle(
        'particles/units/heroes/hero_luna/luna_moon_glaive_shield.vpcf',
        PATTACH_ABSORIGIN_FOLLOW, c)
    ParticleManager:SetParticleControlEnt(self.pfx, 0, c, PATTACH_ABSORIGIN_FOLLOW, 'attach_hitloc', c:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(self.pfx, 1, Vector(0, self.pulse_radius, self.GetDuration and self:GetDuration() or 0))
    ParticleManager:SetParticleControlEnt(self.pfx, 2, c, PATTACH_ABSORIGIN_FOLLOW, 'attach_hitloc', c:GetAbsOrigin(), true)
    self:StartIntervalThink(self.pulse_interval)
    HeroTrace:Log('LUNA','W','modifier_created owner=%s particle=%s radius=%s interval=%s',
        HeroTrace:Name(c),tostring(self.pfx),tostring(self.pulse_radius),tostring(self.pulse_interval))
end

function modifier_enfos_luna_lunar_orbit_buff:OnRefresh(params)
    if not IsServer() then return end
    self:Snapshot(params)
    if self.pfx then
        ParticleManager:SetParticleControl(self.pfx, 1, Vector(0, self.pulse_radius, self.GetDuration and self:GetDuration() or 0))
    end
    self:StartIntervalThink(self.pulse_interval)
end

function modifier_enfos_luna_lunar_orbit_buff:OnDestroy()
    if not IsServer() then return end
    if self.pfx then
        ParticleManager:DestroyParticle(self.pfx, false)
        ParticleManager:ReleaseParticleIndex(self.pfx)
        self.pfx = nil
    end
    HeroTrace:Log('LUNA','W','modifier_removed owner=%s cleanup=particle',HeroTrace:Name(self:GetParent()))
end

function modifier_enfos_luna_lunar_orbit_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
    }
end
function modifier_enfos_luna_lunar_orbit_buff:GetModifierIncomingDamage_Percentage()
    return -(self.damage_reduction_pct or 0)
end
function modifier_enfos_luna_lunar_orbit_buff:GetModifierAttackRangeBonus()
    return self.bonus_range or 0
end
function modifier_enfos_luna_lunar_orbit_buff:GetModifierMoveSpeedBonus_Constant()
    return self.bonus_ms or 0
end

function modifier_enfos_luna_lunar_orbit_buff:OnIntervalThink()
    if not IsServer() then return end
    local c, a = self:GetParent(), self:GetAbility()
    if not alive(c) or not a or (a.IsNull and a:IsNull()) then self:Destroy(); return end
    local requested = (self.pulse_damage or 0) + get_agi(c) * (self.agility_multiplier or 0)
    local affected = 0
    for _, unit in ipairs(enemies(c, c:GetAbsOrigin(), self.pulse_radius or 0)) do
        if alive(unit) and unit:GetTeamNumber() ~= c:GetTeamNumber() then
            damage(a, unit, requested, DAMAGE_TYPE_PHYSICAL)
            local p = ParticleManager:CreateParticle(
                'particles/units/heroes/hero_luna/luna_base_attack_impact.vpcf',
                PATTACH_ABSORIGIN_FOLLOW, unit)
            ParticleManager:ReleaseParticleIndex(p)
            affected = affected + 1
        end
    end
    if affected > 0 then c:EmitSound('Hero_Luna.MoonGlaive.Impact') end
    HeroTrace:Log('LUNA','W','pulse owner=%s affected=%s requested_damage=%s',
        HeroTrace:Name(c),tostring(affected),tostring(requested))
end
