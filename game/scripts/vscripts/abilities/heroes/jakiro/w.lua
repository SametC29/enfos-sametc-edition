-- Jakiro W: finite persistent path with snapshot geometry and once-per-cast hits.
local Helpers = require('abilities/shared/pve_helpers')
local value, get_int, damage = Helpers.value, Helpers.get_int, Helpers.damage
local HeroTrace = require('lib/hero_trace')
LinkLuaModifier('modifier_enfos_jakiro_ice_path_zone', 'abilities/heroes/jakiro/w', LUA_MODIFIER_MOTION_NONE)
local function valid(entity) return entity and not (entity.IsNull and entity:IsNull()) end

enfos_jakiro_ice_path=class({})
function enfos_jakiro_ice_path:OnSpellStart()
    if not IsServer() or not valid(self) then return end
    local c = self:GetCaster()
    if not valid(c) or not c:IsAlive() then return end
    local origin = c:GetAbsOrigin()
    local dir = self:GetCursorPosition() - origin
    dir.z = 0
    if dir:Length2D() < 1 then dir = c:GetForwardVector(); dir.z = 0 end
    if dir:Length2D() < 1 then return end
    dir = dir:Normalized()
    local length, radius = value(self, 'path_length'), value(self, 'path_radius')
    if length <= 0 then length = 1200 end
    if radius <= 0 then radius = 150 end
    local stun = value(self, 'stun_duration')
    if stun <= 0 then stun = 2 end
    local delay, lifetime = math.max(0, value(self, 'path_delay')), value(self, 'path_duration')
    if lifetime <= 0 then lifetime = 3 end
    c:EmitSound('Hero_Jakiro.IcePath.Cast')
    Helpers.ground_effect(c, self, 'modifier_enfos_jakiro_ice_path_zone', {
        duration = delay + lifetime, delay = delay, path_duration = lifetime,
        dir_x = dir.x, dir_y = dir.y, length = length, radius = radius,
        damage = value(self, 'damage') + get_int(c) * 0.6, stun = stun,
    }, origin)
end

modifier_enfos_jakiro_ice_path_zone=class({})
function modifier_enfos_jakiro_ice_path_zone:IsHidden() return true end
function modifier_enfos_jakiro_ice_path_zone:IsPurgable() return false end
function modifier_enfos_jakiro_ice_path_zone:OnCreated(params)
    if not IsServer() then return end
    local parent = self:GetParent()
    if not valid(parent) then self:Destroy(); return end
    self.origin = parent:GetAbsOrigin()
    self.last = self.origin + Vector(tonumber(params.dir_x) or 1, tonumber(params.dir_y) or 0, 0) * (tonumber(params.length) or 1200)
    self.radius, self.delay = tonumber(params.radius) or 150, tonumber(params.delay) or 0.5
    self.total_duration = self.delay + (tonumber(params.path_duration) or 3)
    self.hit_damage, self.stun = tonumber(params.damage) or 0, tonumber(params.stun) or 2
    self.seen, self.active, self.closed = {}, false, false
    self.particle = ParticleManager:CreateParticle('particles/units/heroes/hero_jakiro/jakiro_ice_path.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(self.particle, 0, self.origin)
    ParticleManager:SetParticleControl(self.particle, 1, self.last)
    ParticleManager:SetParticleControl(self.particle, 2, Vector(self.total_duration, 0, 0))
    ParticleManager:SetParticleControl(self.particle, 3, Vector(self.radius, 0, 0))
    HeroTrace:Log('JAKIRO', 'W', 'warning origin=%s end=%s radius=%s delay=%s lifetime=%s stun=%s requested_damage=%s',
        tostring(self.origin), tostring(self.last), tostring(self.radius), tostring(self.delay), tostring(self.total_duration-self.delay), tostring(self.stun), tostring(self.hit_damage))
    self:StartIntervalThink(self.delay > 0 and self.delay or 0.1)
    if self.delay == 0 then self:OnIntervalThink() end
end
function modifier_enfos_jakiro_ice_path_zone:OnIntervalThink()
    if not IsServer() or self.closed then return end
    local c, a, parent = self:GetCaster(), self:GetAbility(), self:GetParent()
    if not valid(c) or not valid(a) or not valid(parent) then self:Destroy(); return end
    local elapsed = self:GetElapsedTime()
    if elapsed < self.delay then return end
    local remaining = self.total_duration - elapsed
    if remaining <= 0 then self:Destroy(); return end
    if not self.active then
        self.active = true
        parent:EmitSound('Hero_Jakiro.IcePath')
        if self.closed then return end
        if not valid(c) or not valid(a) or not valid(parent) then self:Destroy(); return end
        self:StartIntervalThink(0.1)
        HeroTrace:Log('JAKIRO', 'W', 'path_active lifetime=%s', tostring(remaining))
    end
    local targets = FindUnitsInLine(c:GetTeamNumber(), self.origin, self.last, nil, self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE) or {}
    for _, u in ipairs(targets) do
        if self.closed then return end
        if not valid(c) or not valid(a) or not valid(parent) then self:Destroy(); return end
        if valid(u) and u:IsAlive() and u:GetTeamNumber() ~= c:GetTeamNumber() and not self.seen[u] then
            self.seen[u] = true -- Before callbacks: re-entry cannot duplicate this cast's hit.
            local duration = math.min(self.stun, remaining)
            u:AddNewModifier(c, a, 'modifier_stunned', { duration = duration })
            if self.closed then return end
            if not valid(c) or not valid(a) or not valid(parent) then self:Destroy(); return end
            if valid(u) and u:IsAlive() and u:GetTeamNumber() ~= c:GetTeamNumber() then
                local dealt = damage(a, u, self.hit_damage, DAMAGE_TYPE_MAGICAL)
                HeroTrace:Log('JAKIRO', 'W', 'hit target=%s requested_damage=%s applied_damage=%s stun=%s',
                    HeroTrace:Name(u), tostring(self.hit_damage), tostring(dealt or 'unavailable'), tostring(duration))
            end
        end
    end
end
function modifier_enfos_jakiro_ice_path_zone:OnDestroy()
    if not IsServer() or self.closed then return end
    self.closed = true
    self:StartIntervalThink(-1)
    if self.particle then
        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex(self.particle)
        self.particle = nil
    end
    local parent = self:GetParent()
    if self.active and valid(parent) then parent:StopSound('Hero_Jakiro.IcePath') end
    self.seen = nil
    HeroTrace:Log('JAKIRO', 'W', 'path_removed')
    Helpers.remove_ground_effect(self)
end
