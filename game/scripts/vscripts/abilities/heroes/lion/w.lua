-- Lion W: byte-preserving isolation; gameplay audit remains pending.
local H = require('abilities/shared/pve_helpers')
local value, enemies, is_boss, get_int, damage, effect = H.value, H.enemies, H.is_boss, H.get_int, H.damage, H.effect
LinkLuaModifier('modifier_enfos_lion_hex_debuff', 'abilities/heroes/lion/w', LUA_MODIFIER_MOTION_NONE)

enfos_lion_hex=class({})
function enfos_lion_hex:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or t:IsNull() or not t:IsAlive() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end

    c:EmitSound('Hero_Lion.Voodoo')
    effect('particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf', t)
    local dur = is_boss(t) and value(self, 'boss_duration') or value(self, 'duration')
    if dur <= 0 then dur = is_boss(t) and 0.8 or 3.0 end
    t:AddNewModifier(c, self, 'modifier_enfos_lion_hex_debuff', { duration = dur })
end

modifier_enfos_lion_hex_debuff=class({})
function modifier_enfos_lion_hex_debuff:IsDebuff() return true end
function modifier_enfos_lion_hex_debuff:CheckState()
    return { [MODIFIER_STATE_SILENCED] = true, [MODIFIER_STATE_DISARMED] = true, [MODIFIER_STATE_MUTED] = true }
end
function modifier_enfos_lion_hex_debuff:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE } end
function modifier_enfos_lion_hex_debuff:GetModifierMoveSpeedOverride() return value(self:GetAbility(), 'base_move_speed') or 140 end
