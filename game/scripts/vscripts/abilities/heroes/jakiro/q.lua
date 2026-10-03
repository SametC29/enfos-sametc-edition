-- Jakiro Q: isolated authored implementation; behavior unchanged in extraction.
local Helpers = require('abilities/shared/pve_helpers')
local value, enemies, is_boss, get_int, damage = Helpers.value, Helpers.enemies, Helpers.is_boss, Helpers.get_int, Helpers.damage
local effect, ground_effect, remove_ground_effect = Helpers.effect, Helpers.ground_effect, Helpers.remove_ground_effect
LinkLuaModifier('modifier_enfos_jakiro_dual_breath_slow', 'abilities/heroes/jakiro/q', LUA_MODIFIER_MOTION_NONE)

enfos_jakiro_dual_breath=class({})
function enfos_jakiro_dual_breath:OnSpellStart()
    local c = self:GetCaster()
    local p = self:GetCursorPosition()
    local dir = (p - c:GetAbsOrigin()):Normalized()
    c:EmitSound('Hero_Jakiro.DualBreath.Cast')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_jakiro/jakiro_dual_breath_fire.vpcf', PATTACH_ABSORIGIN_FOLLOW, c)
    ParticleManager:SetParticleControl(fx, 0, c:GetAbsOrigin())
    ParticleManager:SetParticleControl(fx, 1, dir * 500)
    ParticleManager:ReleaseParticleIndex(fx)
    local dmg = value(self, 'damage')
    local int = get_int(c)
    local total_dmg = dmg + (int * 0.8)
    local dur = value(self, 'duration')
    if dur <= 0 then dur = 5.0 end

    for _, u in ipairs(enemies(c, c:GetAbsOrigin() + (dir * 400), 500)) do
        damage(self, u, total_dmg, DAMAGE_TYPE_MAGICAL)
        u:AddNewModifier(c, self, 'modifier_enfos_jakiro_dual_breath_slow', { duration = dur })
    end
end

modifier_enfos_jakiro_dual_breath_slow=class({})
function modifier_enfos_jakiro_dual_breath_slow:IsDebuff() return true end
function modifier_enfos_jakiro_dual_breath_slow:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end
function modifier_enfos_jakiro_dual_breath_slow:GetModifierMoveSpeedBonus_Percentage() return -value(self:GetAbility(), 'slow_pct') end
function modifier_enfos_jakiro_dual_breath_slow:GetModifierAttackSpeedBonus_Constant() return -40 end
