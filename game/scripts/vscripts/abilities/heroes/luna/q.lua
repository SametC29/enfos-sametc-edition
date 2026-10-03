-- Luna Q: isolated Lucent Beam with native presentation and Enfos PvE resonance.
-- Lucent Beam particle-control layout adapted from Elfansoer/dota-2-lua-abilities (MIT).
-- See docs/reference-analysis/licenses/Elfansoer-dota-2-lua-abilities-MIT.txt.
local Helpers = require('abilities/shared/pve_helpers')
local value, enemies, get_agi, damage = Helpers.value, Helpers.enemies, Helpers.get_agi, Helpers.damage
local HeroTrace = require('lib/hero_trace')

local function alive(unit)
    return unit and not (unit.IsNull and unit:IsNull()) and unit:IsAlive()
end

local function special(ability, key, fallback)
    local v = value(ability, key)
    if v == nil or v <= 0 then return fallback end
    return v
end

enfos_luna_lucent_beam = class({})

function enfos_luna_lucent_beam:Precache(context)
    PrecacheResource('soundfile', 'soundevents/game_sounds_heroes/game_sounds_luna.vsndevts', context)
    PrecacheResource('particle', 'particles/units/heroes/hero_luna/luna_lucent_beam_precast.vpcf', context)
    PrecacheResource('particle', 'particles/units/heroes/hero_luna/luna_lucent_beam.vpcf', context)
end

function enfos_luna_lucent_beam:OnAbilityPhaseStart()
    if not IsServer() then return true end
    local c = self:GetCaster()
    if not alive(c) then return false end

    local p = ParticleManager:CreateParticle(
        'particles/units/heroes/hero_luna/luna_lucent_beam_precast.vpcf',
        PATTACH_ABSORIGIN_FOLLOW, c)
    ParticleManager:SetParticleControlEnt(
        p, 0, c, PATTACH_POINT_FOLLOW, 'attach_attack1', c:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(p, 1, Vector(self.GetCastPoint and self:GetCastPoint() or 0.4, 0, 0))
    ParticleManager:ReleaseParticleIndex(p)
    HeroTrace:Log('LUNA','Q','precast caster=%s particle=%s',HeroTrace:Name(c),tostring(p))
    return true
end

function enfos_luna_lucent_beam:PlayBeam(target)
    local c = self:GetCaster()
    if not alive(c) or not alive(target) then return end
    local origin = target:GetAbsOrigin()
    local p = ParticleManager:CreateParticle(
        'particles/units/heroes/hero_luna/luna_lucent_beam.vpcf',
        PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(p, 0, origin)
    ParticleManager:SetParticleControlEnt(p, 1, target, PATTACH_ABSORIGIN_FOLLOW, 'attach_hitloc', origin, true)
    ParticleManager:SetParticleControlEnt(p, 5, target, PATTACH_POINT_FOLLOW, 'attach_hitloc', origin, true)
    ParticleManager:SetParticleControlEnt(p, 6, c, PATTACH_POINT_FOLLOW, 'attach_attack1', c:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(p)
    target:EmitSound('Hero_Luna.LucentBeam.Target')
end

function enfos_luna_lucent_beam:OnSpellStart()
    if not IsServer() or (self.IsNull and self:IsNull()) then return end
    local c = self:GetCaster()
    local target = self:GetCursorTarget()
    if not alive(c) or not alive(target) or target:GetTeamNumber() == c:GetTeamNumber() then return end
    if target.TriggerSpellAbsorb and target:TriggerSpellAbsorb(self) then
        HeroTrace:Log('LUNA','Q','cast_cancelled reason=spell_absorb target=%s',HeroTrace:Name(target))
        return
    end
    if not alive(c) or not alive(target) or (self.IsNull and self:IsNull())
        or target:GetTeamNumber() == c:GetTeamNumber() then return end

    local beam_damage = value(self, 'beam_damage')
    local agi_multiplier = special(self, 'agility_multiplier', 1.5)
    local stun_duration = value(self, 'stun_duration')
    local resonance_radius = special(self, 'resonance_radius', 450)
    local resonance_targets = math.max(0, math.floor(special(self, 'resonance_targets', 3)))
    local resonance_pct = special(self, 'resonance_damage_pct', 60)
    local total_damage = beam_damage + get_agi(c) * agi_multiplier
    local origin = target:GetAbsOrigin()

    c:EmitSound('Hero_Luna.LucentBeam.Cast')
    self:PlayBeam(target)
    local dealt = damage(self, target, total_damage, DAMAGE_TYPE_MAGICAL)
    if alive(c) and alive(target) and not (self.IsNull and self:IsNull())
        and target:GetTeamNumber() ~= c:GetTeamNumber() then
        target:AddNewModifier(c, self, 'modifier_stunned', { duration = stun_duration })
    end

    local count = 0
    for _, unit in ipairs(enemies(c, origin, resonance_radius)) do
        if count >= resonance_targets or not alive(c) or (self.IsNull and self:IsNull()) then break end
        if unit ~= target and alive(unit) and unit:GetTeamNumber() ~= c:GetTeamNumber() then
            local secondary = total_damage * resonance_pct / 100
            self:PlayBeam(unit)
            damage(self, unit, secondary, DAMAGE_TYPE_MAGICAL)
            count = count + 1
        end
    end
    HeroTrace:Log('LUNA','Q','impact target=%s rank=%s requested_damage=%s actual_damage=%s resonance_targets=%s',
        HeroTrace:Name(target),tostring(self.GetLevel and self:GetLevel() or 0),tostring(total_damage),
        type(dealt)=='number' and tostring(dealt) or '<unavailable>',tostring(count))
end
