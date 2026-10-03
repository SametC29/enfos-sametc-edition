-- Vengeful Spirit Q: isolated existing implementation; review gates remain pending.
local Helpers = require('abilities/shared/pve_helpers')
local value, get_agi, damage = Helpers.value, Helpers.get_agi, Helpers.damage
local HeroTrace = require('lib/hero_trace')
local Aghanim = require('heroes/aghanim_manager')
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
        bProvidesVision = false,
        ExtraData = { remaining = Aghanim:HasShard(c) and 1 or 0 }
    }
    local handle = ProjectileManager:CreateTrackingProjectile(proj)
    HeroTrace:Log('VENGEFUL_SPIRIT','Q','projectile_created handle=%s speed=%s dodgeable=true',tostring(handle),tostring(proj.iMoveSpeed))
end
function enfos_vs_magic_missile:OnProjectileHit(target, loc)
    return self:OnProjectileHit_ExtraData(target, loc, { remaining = 0 })
end
function enfos_vs_magic_missile:OnProjectileHit_ExtraData(target, loc, data)
    if not IsServer() or (self.IsNull and self:IsNull()) then return true end
    local c = self:GetCaster()
    if not alive(c) or not alive(target) or target:GetTeamNumber()==c:GetTeamNumber() then
        HeroTrace:Log('VENGEFUL_SPIRIT','Q','impact_cancelled reason=invalid_source_or_target target=%s',HeroTrace:Name(target))
        return true
    end
    local impact_origin = target:GetAbsOrigin()
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
    if data and tonumber(data.remaining)==1 and alive(c) and not (self.IsNull and self:IsNull()) then
        self:LaunchShardBounce(target, impact_origin)
    end
    return true
end

function enfos_vs_magic_missile:LaunchShardBounce(first_target, origin)
    local c = self:GetCaster()
    if not alive(c) or (self.IsNull and self:IsNull()) then return end
    local cast_range = self.GetEffectiveCastRange and self:GetEffectiveCastRange(origin, nil) or 650
    local pct = value(self, 'bounce_range_pct')
    if pct <= 0 then pct = 75 end
    local radius = math.max(0, cast_range) * pct / 100
    local candidates = FindUnitsInRadius(c:GetTeamNumber(),origin,nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_NONE,FIND_CLOSEST,false) or {}
    local fallback, selected
    for _,unit in ipairs(candidates) do
        if unit~=first_target and alive(unit) and unit:GetTeamNumber()~=c:GetTeamNumber() then
            if unit.IsHero and unit:IsHero() then selected=unit;break end
            if not fallback then fallback=unit end
        end
    end
    selected = selected or fallback
    if not selected then
        HeroTrace:Log('VENGEFUL_SPIRIT','Q','shard_bounce_cancelled reason=no_target radius=%s',tostring(radius))
        return
    end
    local speed = value(self,'magic_missile_speed')
    if speed<=0 then speed=1350 end
    local handle = ProjectileManager:CreateTrackingProjectile({
        Target=selected,Source=c,Ability=self,vSourceLoc=origin,
        EffectName='particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf',
        iMoveSpeed=speed,bDodgeable=true,bVisibleToEnemies=true,bProvidesVision=false,
        ExtraData={remaining=0},
    })
    HeroTrace:Log('VENGEFUL_SPIRIT','Q','shard_bounce target=%s origin=%s radius=%s handle=%s remaining=0',
        HeroTrace:Name(selected),tostring(origin),tostring(radius),tostring(handle))
end
