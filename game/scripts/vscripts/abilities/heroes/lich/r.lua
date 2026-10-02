-- Lich isolated kit: preserve stable classes, values and lifecycle behavior.
local Helpers = require('abilities/shared/pve_helpers')
local value, enemies, is_boss, get_int, damage = Helpers.value, Helpers.enemies, Helpers.is_boss, Helpers.get_int, Helpers.damage
local HeroTrace = require('lib/hero_trace')

LinkLuaModifier('modifier_enfos_lich_chain_frost_slow', 'abilities/heroes/lich/r', LUA_MODIFIER_MOTION_NONE)

enfos_lich_chain_frost=class({})
function enfos_lich_chain_frost:Precache(context)
    PrecacheResource('soundfile', 'soundevents/game_sounds_heroes/game_sounds_lich.vsndevts', context)
end
function enfos_lich_chain_frost:OnSpellStart()
    if not IsServer() then return end
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or c:IsNull() or not c:IsAlive() or not t or t:IsNull() or not t:IsAlive() then return end
    if t:GetTeamNumber() == c:GetTeamNumber() then
        HeroTrace:Log('LICH','R','cast_cancelled reason=friendly_primary target=%s',HeroTrace:Name(t))
        return
    end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then
        HeroTrace:Log('LICH','R','cast_cancelled reason=spell_absorb target=%s',HeroTrace:Name(t))
        return
    end
    c:EmitSound('Hero_Lich.ChainFrost')
    local jumps = value(self, 'jump_count')
    if jumps <= 0 then jumps = 10 end
    local dmg = value(self, 'damage')
    local int = get_int(c)
    local total_dmg = dmg + (int * 1.0)
    local current = t
    local hit_targets = {}
    local slow_duration = value(self, 'slow_duration')
    if slow_duration <= 0 then slow_duration = 2.5 end
    HeroTrace:Log('LICH','R','cast target=%s jumps=%s requested_damage=%s',HeroTrace:Name(t),tostring(jumps),tostring(total_dmg))

    for i = 1, jumps do
        if not current or (current.IsNull and current:IsNull()) or not current:IsAlive() or hit_targets[current] then break end
        hit_targets[current] = true
        local origin = current:GetAbsOrigin()
        local duration = is_boss(current) and (slow_duration * 0.35) or slow_duration
        local impactSound = current:IsHero() and 'Hero_Lich.ChainFrostImpact.Hero' or 'Hero_Lich.ChainFrostImpact.Creep'
        current:EmitSound(impactSound)
        local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_lich/lich_chain_frost.vpcf', PATTACH_ABSORIGIN_FOLLOW, current)
        ParticleManager:ReleaseParticleIndex(fx)
        HeroTrace:Log('LICH','R','hit target=%s index=%d requested_damage=%s slow_duration=%s',HeroTrace:Name(current),i,tostring(total_dmg),tostring(duration))
        damage(self, current, total_dmg, DAMAGE_TYPE_MAGICAL)
        if c:IsNull() or (self.IsNull and self:IsNull()) then
            HeroTrace:Log('LICH','R','spread_cancelled reason=source_removed')
            break
        end
        if not current:IsNull() and current:IsAlive() then
            current:AddNewModifier(c, self, 'modifier_enfos_lich_chain_frost_slow', { duration = duration })
        end
        local candidates = enemies(c, origin, 600)
        local next_target = nil
        for _, u in ipairs(candidates) do
            if u and not u:IsNull() and u ~= current and not hit_targets[u] and u:IsAlive() then
                next_target = u
                break
            end
        end
        HeroTrace:Log('LICH','R','spread_next target=%s',HeroTrace:Name(next_target))
        current = next_target
    end
end

modifier_enfos_lich_chain_frost_slow=class({})
function modifier_enfos_lich_chain_frost_slow:IsDebuff() return true end
function modifier_enfos_lich_chain_frost_slow:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end
function modifier_enfos_lich_chain_frost_slow:GetModifierMoveSpeedBonus_Percentage()
    local a = self:GetAbility()
    local slow = a and value(a, 'slow_pct') or 50
    if slow <= 0 then slow = 50 end
    return -slow
end
function modifier_enfos_lich_chain_frost_slow:GetModifierAttackSpeedBonus_Constant()
    local a = self:GetAbility()
    local slow = a and value(a, 'slow_attack_pct') or 50
    if slow <= 0 then slow = 50 end
    return -slow
end
