-- Luna R: isolated Eclipse with native presentation and ordinary-target Boss policy.
-- Core Eclipse state/lifecycle follows Dota's beam-count/radius model; no authored Boss-only cap.
local Helpers = require('abilities/shared/pve_helpers')
local value, enemies, damage = Helpers.value, Helpers.enemies, Helpers.damage
local HeroTrace = require('lib/hero_trace')

local function alive(unit)
    return unit and not (unit.IsNull and unit:IsNull()) and unit:IsAlive()
end

LinkLuaModifier('modifier_enfos_luna_eclipse_thinker', 'abilities/heroes/luna/r', LUA_MODIFIER_MOTION_NONE)

enfos_luna_eclipse = class({})

function enfos_luna_eclipse:Precache(context)
    PrecacheResource('soundfile', 'soundevents/game_sounds_heroes/game_sounds_luna.vsndevts', context)
    PrecacheResource('particle', 'particles/units/heroes/hero_luna/luna_eclipse.vpcf', context)
    PrecacheResource('particle', 'particles/units/heroes/hero_luna/luna_eclipse_cast.vpcf', context)
    PrecacheResource('particle', 'particles/units/heroes/hero_luna/luna_eclipse_impact_notarget.vpcf', context)
    PrecacheResource('particle', 'particles/units/heroes/hero_luna/luna_lucent_beam.vpcf', context)
end

function enfos_luna_eclipse:OnSpellStart()
    if not IsServer() or (self.IsNull and self:IsNull()) then return end
    local c = self:GetCaster()
    if not alive(c) then return end
    local duration = value(self, 'duration')
    local cast = ParticleManager:CreateParticle(
        'particles/units/heroes/hero_luna/luna_eclipse_cast.vpcf',
        PATTACH_ABSORIGIN_FOLLOW, c)
    ParticleManager:ReleaseParticleIndex(cast)
    c:EmitSound('Hero_Luna.Eclipse.Cast')
    if GameRules and GameRules.BeginTemporaryNight then
        GameRules:BeginTemporaryNight(duration)
    end
    local mod = c:AddNewModifier(c, self, 'modifier_enfos_luna_eclipse_thinker', { duration = duration })
    HeroTrace:Log('LUNA','R','cast caster=%s rank=%s duration=%s modifier_applied=%s',
        HeroTrace:Name(c),tostring(self.GetLevel and self:GetLevel() or 0),tostring(duration),tostring(mod~=nil))
end

modifier_enfos_luna_eclipse_thinker = class({})
function modifier_enfos_luna_eclipse_thinker:IsHidden() return false end
function modifier_enfos_luna_eclipse_thinker:IsPurgable() return false end
function modifier_enfos_luna_eclipse_thinker:GetTexture() return 'luna_eclipse' end

function modifier_enfos_luna_eclipse_thinker:OnCreated()
    if not IsServer() then return end
    local c, a = self:GetParent(), self:GetAbility()
    if not alive(c) or not a or (a.IsNull and a:IsNull()) then self:Destroy(); return end
    self.hit_counts = {}
    self.radius = value(a, 'radius')
    self.beam_damage = value(a, 'beam_damage')
    self.max_hits = math.max(1, math.floor(value(a, 'max_hits_per_target')))
    self.interval = value(a, 'beam_interval')
    if self.interval <= 0 then self.interval = 0.3 end
    self.pfx = ParticleManager:CreateParticle(
        'particles/units/heroes/hero_luna/luna_eclipse.vpcf',
        PATTACH_ABSORIGIN_FOLLOW, c)
    self:StartIntervalThink(self.interval)
    HeroTrace:Log('LUNA','R','modifier_created owner=%s radius=%s beam_damage=%s max_hits=%s interval=%s particle=%s',
        HeroTrace:Name(c),tostring(self.radius),tostring(self.beam_damage),tostring(self.max_hits),tostring(self.interval),tostring(self.pfx))
end

function modifier_enfos_luna_eclipse_thinker:OnDestroy()
    if not IsServer() then return end
    if self.pfx then
        ParticleManager:DestroyParticle(self.pfx, false)
        ParticleManager:ReleaseParticleIndex(self.pfx)
        self.pfx = nil
    end
    HeroTrace:Log('LUNA','R','modifier_removed owner=%s cleanup=particle',HeroTrace:Name(self:GetParent()))
end

function modifier_enfos_luna_eclipse_thinker:PlayBeam(target)
    local c = self:GetParent()
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

function modifier_enfos_luna_eclipse_thinker:PlayNoTarget()
    local c = self:GetParent()
    if not alive(c) then return end
    local angle = RandomFloat(0, math.pi * 2)
    local distance = RandomFloat(0, math.max(0, self.radius or 0))
    local point = c:GetAbsOrigin() + Vector(math.cos(angle) * distance, math.sin(angle) * distance, 0)
    EmitSoundOnLocationWithCaster(point, 'Hero_Luna.Eclipse.NoTarget', c)
    local p = ParticleManager:CreateParticle(
        'particles/units/heroes/hero_luna/luna_eclipse_impact_notarget.vpcf',
        PATTACH_WORLDORIGIN, c)
    ParticleManager:SetParticleControl(p, 1, point)
    ParticleManager:SetParticleControl(p, 5, point)
    ParticleManager:ReleaseParticleIndex(p)
end

function modifier_enfos_luna_eclipse_thinker:OnIntervalThink()
    if not IsServer() then return end
    local c, a = self:GetParent(), self:GetAbility()
    if not alive(c) or not a or (a.IsNull and a:IsNull()) then self:Destroy(); return end
    local valid_targets = {}
    for _, unit in ipairs(enemies(c, c:GetAbsOrigin(), self.radius or 0)) do
        if alive(unit) and unit:GetTeamNumber() ~= c:GetTeamNumber() then
            local id = unit:entindex()
            if (self.hit_counts[id] or 0) < (self.max_hits or 1) then
                valid_targets[#valid_targets + 1] = unit
            end
        end
    end
    if #valid_targets == 0 then
        self:PlayNoTarget()
        return
    end

    local target = valid_targets[RandomInt(1, #valid_targets)]
    local id = target:entindex()
    self.hit_counts[id] = (self.hit_counts[id] or 0) + 1
    self:PlayBeam(target)
    local dealt = damage(a, target, self.beam_damage or 0, DAMAGE_TYPE_MAGICAL)
    HeroTrace:Log('LUNA','R','beam target=%s hit_index=%s requested_damage=%s actual_damage=%s',
        HeroTrace:Name(target),tostring(self.hit_counts[id]),tostring(self.beam_damage),
        type(dealt)=='number' and tostring(dealt) or '<unavailable>')
end
