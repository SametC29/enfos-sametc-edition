-- Luna D: isolated Moon Glaives. Sequential engine tracking-projectile bounces.
local Helpers = require('abilities/shared/pve_helpers')
local value, enemies, damage = Helpers.value, Helpers.enemies, Helpers.damage
local HeroTrace = require('lib/hero_trace')

local function alive(unit)
    return unit and not (unit.IsNull and unit:IsNull()) and unit:IsAlive()
end

local function get_attack(caster, target)
    if not caster or (caster.IsNull and caster:IsNull()) then return 0 end
    if caster.GetAverageTrueAttackDamage then
        local ok, amount = pcall(caster.GetAverageTrueAttackDamage, caster, target or caster)
        if ok and type(amount) == 'number' and amount > 0 then return amount end
    end
    if caster.GetAttackDamage then
        local ok, amount = pcall(caster.GetAttackDamage, caster)
        if ok and type(amount) == 'number' and amount > 0 then return amount end
    end
    return 0
end

local function passive_source(modifier)
    local c, a = modifier:GetParent(), modifier:GetAbility()
    if not alive(c) or not a or (a.IsNull and a:IsNull())
        or (a.GetLevel and a:GetLevel() <= 0)
        or (c.PassivesDisabled and c:PassivesDisabled())
        or (c.IsIllusion and c:IsIllusion()) then return nil, nil end
    return c, a
end

local function copy_data(data)
    local out = {}
    for k, v in pairs(data or {}) do out[k] = v end
    return out
end

LinkLuaModifier('modifier_enfos_luna_moon_glaives_passive', 'abilities/heroes/luna/d', LUA_MODIFIER_MOTION_NONE)

enfos_luna_moon_glaives = class({})

function enfos_luna_moon_glaives:Precache(context)
    PrecacheResource('soundfile', 'soundevents/game_sounds_heroes/game_sounds_luna.vsndevts', context)
    PrecacheResource('particle', 'particles/units/heroes/hero_luna/luna_ambient_moon_glaive.vpcf', context)
    PrecacheResource('particle', 'particles/units/heroes/hero_luna/luna_base_attack.vpcf', context)
    PrecacheResource('particle', 'particles/units/heroes/hero_luna/luna_base_attack_impact.vpcf', context)
end

function enfos_luna_moon_glaives:GetIntrinsicModifierName()
    return 'modifier_enfos_luna_moon_glaives_passive'
end

function enfos_luna_moon_glaives:LaunchBounce(target, origin, data)
    local c = self:GetCaster()
    if not alive(c) or not alive(target) or (self.IsNull and self:IsNull()) then return end
    local payload = copy_data(data)
    local handle = ProjectileManager:CreateTrackingProjectile({
        Target = target,
        Source = c,
        Ability = self,
        vSourceLoc = origin,
        EffectName = 'particles/units/heroes/hero_luna/luna_base_attack.vpcf',
        iMoveSpeed = 900,
        bDodgeable = false,
        bVisibleToEnemies = true,
        bProvidesVision = false,
        ExtraData = payload,
    })
    HeroTrace:Log('LUNA','D','projectile_launch handle=%s target=%s remaining=%s damage=%s',
        tostring(handle),HeroTrace:Name(target),tostring(payload.remaining),tostring(payload.damage))
end

function enfos_luna_moon_glaives:FindNext(origin, data)
    local c = self:GetCaster()
    if not alive(c) then return nil end
    for _, unit in ipairs(enemies(c, origin, 500)) do
        if alive(unit) and unit:GetTeamNumber() ~= c:GetTeamNumber() then
            local visited = false
            for i = 1, tonumber(data.hits) or 0 do
                if tonumber(data['hit_' .. i]) == unit:entindex() then visited = true; break end
            end
            if not visited then return unit end
        end
    end
end

function enfos_luna_moon_glaives:OnProjectileHit_ExtraData(target, location, data)
    if not IsServer() or (self.IsNull and self:IsNull()) then return true end
    local c = self:GetCaster()
    if not alive(c) or not alive(target) or target:GetTeamNumber() == c:GetTeamNumber()
        or not data or type(tonumber(data.damage)) ~= 'number' or type(tonumber(data.remaining)) ~= 'number' then
        return true
    end
    local remaining = math.max(0, math.floor(tonumber(data.remaining)))
    local hits = math.max(0, math.floor(tonumber(data.hits) or 0))
    if remaining <= 0 or hits > 16 then return true end

    local id = target:entindex()
    for i = 1, hits do
        if tonumber(data['hit_' .. i]) == id then return true end
    end

    hits = hits + 1
    data.hits = hits
    data['hit_' .. hits] = id
    local amount = tonumber(data.damage) or 0
    local origin = target:GetAbsOrigin()
    target:EmitSound('Hero_Luna.MoonGlaive.Impact')
    local impact = ParticleManager:CreateParticle(
        'particles/units/heroes/hero_luna/luna_base_attack_impact.vpcf',
        PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:ReleaseParticleIndex(impact)
    local dealt = damage(self, target, amount, DAMAGE_TYPE_PHYSICAL)
    HeroTrace:Log('LUNA','D','impact target=%s requested_damage=%s actual_damage=%s remaining_before=%s',
        HeroTrace:Name(target),tostring(amount),type(dealt)=='number' and tostring(dealt) or '<unavailable>',tostring(remaining))

    remaining = remaining - 1
    if remaining <= 0 or not alive(c) or (self.IsNull and self:IsNull()) then return true end
    data.remaining = remaining
    data.damage = amount * 0.85
    local next_target = self:FindNext(origin, data)
    if next_target then self:LaunchBounce(next_target, origin, data) end
    return true
end

modifier_enfos_luna_moon_glaives_passive = class({})
function modifier_enfos_luna_moon_glaives_passive:IsHidden() return true end
function modifier_enfos_luna_moon_glaives_passive:IsPurgable() return false end
function modifier_enfos_luna_moon_glaives_passive:IsPurgeException() return false end
function modifier_enfos_luna_moon_glaives_passive:RemoveOnDeath() return false end
function modifier_enfos_luna_moon_glaives_passive:GetTexture() return 'luna_moon_glaive' end
function modifier_enfos_luna_moon_glaives_passive:DeclareFunctions()
    return { MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_enfos_luna_moon_glaives_passive:RefreshVisual()
    if not IsServer() then return end
    local c, a = passive_source(self)
    if c and a and not self.pfx then
        self.pfx = ParticleManager:CreateParticle(
            'particles/units/heroes/hero_luna/luna_ambient_moon_glaive.vpcf',
            PATTACH_ABSORIGIN_FOLLOW, c)
        ParticleManager:SetParticleControlEnt(self.pfx, 0, c, PATTACH_POINT_FOLLOW, 'attach_attack1', c:GetAbsOrigin(), true)
    elseif (not c or not a) and self.pfx then
        ParticleManager:DestroyParticle(self.pfx, false)
        ParticleManager:ReleaseParticleIndex(self.pfx)
        self.pfx = nil
    end
end
function modifier_enfos_luna_moon_glaives_passive:OnCreated() self:RefreshVisual() end
function modifier_enfos_luna_moon_glaives_passive:OnRefresh() self:RefreshVisual() end
function modifier_enfos_luna_moon_glaives_passive:OnDestroy()
    if not IsServer() then return end
    if self.pfx then
        ParticleManager:DestroyParticle(self.pfx, false)
        ParticleManager:ReleaseParticleIndex(self.pfx)
        self.pfx = nil
    end
end

function modifier_enfos_luna_moon_glaives_passive:OnAttackLanded(event)
    if not IsServer() or not event then return end
    local c, a = passive_source(self)
    local primary = event.target
    if not c or not a or event.attacker ~= c or not alive(primary)
        or primary:GetTeamNumber() == c:GetTeamNumber() then return end

    local bounces = math.max(0, math.min(16, math.floor(value(a, 'bounce_count'))))
    if bounces <= 0 then return end
    local origin = primary:GetAbsOrigin()
    local data = {
        remaining = bounces,
        damage = get_attack(c, primary) * 0.85 + value(a, 'bonus_damage'),
        hits = 1,
        hit_1 = primary:entindex(),
    }
    local next_target = a:FindNext(origin, data)
    if next_target then a:LaunchBounce(next_target, origin, data) end
end
