-- Jakiro R: ordinary magical path pulses; no authored Boss-only damage ceiling.
local Helpers = require('abilities/shared/pve_helpers')
local value, enemies, get_int, damage = Helpers.value, Helpers.enemies, Helpers.get_int, Helpers.damage
local effect, ground_effect, remove_ground_effect = Helpers.effect, Helpers.ground_effect, Helpers.remove_ground_effect
LinkLuaModifier('modifier_enfos_jakiro_macropyre_zone', 'abilities/heroes/jakiro/r', LUA_MODIFIER_MOTION_NONE)

enfos_jakiro_macropyre=class({})
function enfos_jakiro_macropyre:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local p = self:GetCursorPosition()
    local dir = (p - c:GetAbsOrigin()):Normalized()
    local length = value(self, 'length')
    if length <= 0 then length = 1200 end
    local duration = value(self, 'duration')
    if duration <= 0 then duration = 6 end
    c:EmitSound('Hero_Jakiro.Macropyre.Cast')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_jakiro/jakiro_macropyre.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(fx, 0, c:GetAbsOrigin())
    ParticleManager:SetParticleControl(fx, 1, c:GetAbsOrigin() + (dir * length))
    ParticleManager:SetParticleControl(fx, 2, Vector(duration, 0, 0))
    ParticleManager:ReleaseParticleIndex(fx)
    ground_effect(c, self, 'modifier_enfos_jakiro_macropyre_zone', {
        duration = duration, dir_x = dir.x, dir_y = dir.y, length = length
    }, c:GetAbsOrigin())
end

modifier_enfos_jakiro_macropyre_zone=class({})
function modifier_enfos_jakiro_macropyre_zone:IsHidden() return true end
function modifier_enfos_jakiro_macropyre_zone:IsPurgable() return false end
function modifier_enfos_jakiro_macropyre_zone:OnCreated(kv)
    if not IsServer() then return end
    self.dir = Vector(tonumber(kv.dir_x) or 1, tonumber(kv.dir_y) or 0, 0):Normalized()
    self.length = tonumber(kv.length) or 1200
    self:StartIntervalThink(0.5)
end
function modifier_enfos_jakiro_macropyre_zone:OnIntervalThink()
    local c, a, parent = self:GetCaster(), self:GetAbility(), self:GetParent()
    if not c or c:IsNull() or not c:IsAlive() or not a or (a.IsNull and a:IsNull()) or not parent or parent:IsNull() then self:Destroy() return end
    local origin = parent:GetAbsOrigin()
    local center = origin + (self.dir * (self.length * 0.5))
    local int = get_int(c)
    local pulse = (value(a, 'damage_per_sec') + (int * 0.7)) * 0.5
    for _, u in ipairs(enemies(c, center, (self.length * 0.5) + 180)) do
        local off = u:GetAbsOrigin() - origin
        local along = off.x * self.dir.x + off.y * self.dir.y
        local side = (off - (self.dir * along)):Length2D()
        if along >= 0 and along <= self.length and side <= 180 then
            damage(a, u, pulse, DAMAGE_TYPE_MAGICAL)
        end
    end
end
function modifier_enfos_jakiro_macropyre_zone:OnDestroy() remove_ground_effect(self) end
