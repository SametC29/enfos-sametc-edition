-- Vengeful Spirit W: isolated existing implementation; review gates remain pending.
local Helpers = require('abilities/shared/pve_helpers')
local value, enemies, is_boss, get_agi, damage = Helpers.value, Helpers.enemies, Helpers.is_boss, Helpers.get_agi, Helpers.damage
LinkLuaModifier('modifier_enfos_vs_wave_debuff', 'abilities/heroes/vengefulspirit/w', LUA_MODIFIER_MOTION_NONE)

enfos_vs_wave_of_terror=class({})
function enfos_vs_wave_of_terror:OnSpellStart()
    local c = self:GetCaster()
    local p = self:GetCursorPosition()
    local origin = c:GetAbsOrigin()
    local dir = p - origin
    dir.z = 0
    if dir:Length2D() < 1 then
        dir = c:GetForwardVector()
        dir.z = 0
    end
    dir = dir:Normalized()
    c:EmitSound('Hero_VengefulSpirit.WaveOfTerror')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_vengeful/vengeful_wave_of_terror.vpcf', PATTACH_ABSORIGIN_FOLLOW, c)
    ParticleManager:SetParticleControl(fx, 0, origin)
    ParticleManager:SetParticleControl(fx, 1, dir * 1400)
    ParticleManager:ReleaseParticleIndex(fx)
    local dmg = value(self, 'damage')
    local agi = get_agi(c)
    local total_dmg = dmg + (agi * 0.6)
    local dur = value(self, 'duration')
    if dur <= 0 then dur = 8.0 end

    for _, u in ipairs(enemies(c, origin + (dir * 700), 800)) do
        local offset = u:GetAbsOrigin() - origin
        local along = offset.x * dir.x + offset.y * dir.y
        local side = (offset - (dir * along)):Length2D()
        if along >= 0 and along <= 1400 and side <= 140 then
        damage(self, u, total_dmg, DAMAGE_TYPE_MAGICAL)
        u:AddNewModifier(c, self, 'modifier_enfos_vs_wave_debuff', { duration = dur })
        end
    end
end

modifier_enfos_vs_wave_debuff=class({})
function modifier_enfos_vs_wave_debuff:IsDebuff() return true end
function modifier_enfos_vs_wave_debuff:DeclareFunctions() return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS } end
function modifier_enfos_vs_wave_debuff:GetModifierPhysicalArmorBonus()
    local ab = self:GetAbility()
    local red = ab and value(ab, 'armor_reduction') or 4
    return -red
end
