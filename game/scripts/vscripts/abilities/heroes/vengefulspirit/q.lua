-- Vengeful Spirit Q: isolated existing implementation; review gates remain pending.
local Helpers = require('abilities/shared/pve_helpers')
local value, enemies, is_boss, get_agi, damage = Helpers.value, Helpers.enemies, Helpers.is_boss, Helpers.get_agi, Helpers.damage

enfos_vs_magic_missile=class({})
function enfos_vs_magic_missile:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or t:IsNull() or not t:IsAlive() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end
    c:EmitSound('Hero_VengefulSpirit.MagicMissile')
    local proj = {
        Target = t,
        Source = c,
        Ability = self,
        EffectName = 'particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf',
        iMoveSpeed = 1250,
        bDodgeable = true,
        bVisibleToEnemies = true,
        bProvidesVision = false
    }
    ProjectileManager:CreateTrackingProjectile(proj)
end
function enfos_vs_magic_missile:OnProjectileHit(target, loc)
    if not target or target:IsNull() or not target:IsAlive() then return true end
    local c = self:GetCaster()
    target:EmitSound('Hero_VengefulSpirit.MagicMissileImpact')
    local dmg = value(self, 'damage')
    local agi = get_agi(c)
    local total_dmg = dmg + (agi * 0.9)
    if is_boss(target) then total_dmg = math.min(total_dmg, target:GetMaxHealth() * 0.1) end
    local stun_dur = value(self, 'stun_duration')
    if stun_dur <= 0 then stun_dur = 1.6 end
    if is_boss(target) then stun_dur = stun_dur * 0.4 end
    target:AddNewModifier(c, self, 'modifier_generic_stunned_lua', { duration = stun_dur })
    damage(self, target, total_dmg, DAMAGE_TYPE_MAGICAL)
    return true
end
