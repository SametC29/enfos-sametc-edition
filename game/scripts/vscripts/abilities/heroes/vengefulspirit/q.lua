-- Vengeful Spirit Q: isolated existing implementation; review gates remain pending.
local Helpers = require('abilities/shared/pve_helpers')
local value, get_agi, damage = Helpers.value, Helpers.get_agi, Helpers.damage
local HeroTrace = require('lib/hero_trace')
local function alive(unit)
    return unit and not (unit.IsNull and unit:IsNull()) and unit:IsAlive()
end

enfos_vs_magic_missile=class({})
function enfos_vs_magic_missile:OnSpellStart()
    if not IsServer() or (self.IsNull and self:IsNull()) then return end
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not alive(c) or not alive(t) or c == t then return end
    if t:GetTeamNumber()==c:GetTeamNumber() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then
        HeroTrace:Log('VENGEFUL_SPIRIT','Q','cast_cancelled reason=spell_absorb')
        return
    end
    if not alive(c) or not alive(t) or (self.IsNull and self:IsNull()) or t:GetTeamNumber()==c:GetTeamNumber() then return end
    HeroTrace:Log('VENGEFUL_SPIRIT','Q','cast caster=%s target=%s rank=%s',HeroTrace:Name(c),HeroTrace:Name(t),tostring(self.GetLevel and self:GetLevel() or 0))
    c:EmitSound('Hero_VengefulSpirit.MagicMissile')
    local speed = value(self, 'magic_missile_speed')
    if speed <= 0 then speed = 1350 end
    local proj = {
        Target = t,
        Source = c,
        Ability = self,
        EffectName = 'particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf',
        iMoveSpeed = speed,
        bDodgeable = true,
        bVisibleToEnemies = true,
        bProvidesVision = false
    }
    local handle = ProjectileManager:CreateTrackingProjectile(proj)
    HeroTrace:Log('VENGEFUL_SPIRIT','Q','projectile_created handle=%s speed=%s dodgeable=true',tostring(handle),tostring(proj.iMoveSpeed))
end
function enfos_vs_magic_missile:OnProjectileHit(target, loc)
    if not IsServer() or (self.IsNull and self:IsNull()) then return true end
    local c = self:GetCaster()
    if not alive(c) or not alive(target) or target:GetTeamNumber()==c:GetTeamNumber() then
        HeroTrace:Log('VENGEFUL_SPIRIT','Q','impact_cancelled reason=invalid_source_or_target target=%s',HeroTrace:Name(target))
        return true
    end
    target:EmitSound('Hero_VengefulSpirit.MagicMissileImpact')
    local dmg = value(self, 'damage')
    local agi = get_agi(c)
    local total_dmg = dmg + (agi * 0.9)
    local stun_dur = value(self, 'stun_duration')
    if stun_dur <= 0 then stun_dur = 1.6 end
    local stun = target:AddNewModifier(c, self, 'modifier_stunned', { duration = stun_dur })
    if not alive(c) or not alive(target) or (self.IsNull and self:IsNull()) or target:GetTeamNumber()==c:GetTeamNumber() then return true end
    local dealt = damage(self, target, total_dmg, DAMAGE_TYPE_MAGICAL)
    HeroTrace:Log('VENGEFUL_SPIRIT','Q','impact target=%s requested_damage=%s actual_damage=%s stun_requested=%s modifier_applied=%s',HeroTrace:Name(target),tostring(total_dmg),tostring(dealt),tostring(stun_dur),tostring(stun~=nil))
    return true
end
