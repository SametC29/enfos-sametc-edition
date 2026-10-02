-- Lich isolated kit: preserve stable classes, values and lifecycle behavior.
local Helpers = require('abilities/shared/pve_helpers')
local value, enemies, is_boss, get_int, damage = Helpers.value, Helpers.enemies, Helpers.is_boss, Helpers.get_int, Helpers.damage
local HeroTrace = require('lib/hero_trace')

LinkLuaModifier('modifier_enfos_lich_frost_shield', 'abilities/heroes/lich/w', LUA_MODIFIER_MOTION_NONE)

enfos_lich_frost_shield=class({})
function enfos_lich_frost_shield:Precache(context)
    PrecacheResource('soundfile', 'soundevents/game_sounds_heroes/game_sounds_lich.vsndevts', context)
end
function enfos_lich_frost_shield:OnSpellStart()
    if not IsServer() then return end
    local c = self:GetCaster()
    if not c or c:IsNull() or not c:IsAlive() then return end
    local t = self:GetCursorTarget() or c
    if not t or t:IsNull() or not t:IsAlive() then return end
    local dur = value(self, 'duration')
    if dur <= 0 then dur = 6.0 end
    t:EmitSound('Hero_Lich.IceAge')
    t:AddNewModifier(c, self, 'modifier_enfos_lich_frost_shield', { duration = dur })
    HeroTrace:Log('LICH','W','cast caster=%s recipient=%s duration=%s',HeroTrace:Name(c),HeroTrace:Name(t),tostring(dur))
end

modifier_enfos_lich_frost_shield=class({})
function modifier_enfos_lich_frost_shield:GetTexture() return 'lich_frost_shield' end
function modifier_enfos_lich_frost_shield:OnCreated()
    if not IsServer() then return end
    self:StartIntervalThink(1.0)
end
function modifier_enfos_lich_frost_shield:GetEffectName()
    return 'particles/units/heroes/hero_lich/lich_frost_armor.vpcf'
end
function modifier_enfos_lich_frost_shield:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
function modifier_enfos_lich_frost_shield:OnIntervalThink()
    if not IsServer() then return end
    local p = self:GetParent()
    local c = self:GetCaster()
    local ab = self:GetAbility()
    if not p or p:IsNull() or not p:IsAlive() or not c or c:IsNull()
        or not ab or (ab.IsNull and ab:IsNull()) then
        HeroTrace:Log('LICH','W','pulse_cancelled reason=invalid_source_or_recipient recipient=%s',HeroTrace:Name(p))
        self:Destroy(); return
    end
    local dps = value(ab, 'dps')
    local int = get_int(c)
    local total_dps = dps + (int * 0.25)
    local affected = 0
    for _, u in ipairs(enemies(c, p:GetAbsOrigin(), 600)) do
        damage(ab, u, total_dps, DAMAGE_TYPE_MAGICAL)
        affected = affected + 1
        if c:IsNull() or p:IsNull() or not p:IsAlive() or (ab.IsNull and ab:IsNull()) then break end
    end
    HeroTrace:Log('LICH','W','pulse recipient=%s affected=%d requested_damage=%s',HeroTrace:Name(p),affected,tostring(total_dps))
end
function modifier_enfos_lich_frost_shield:DeclareFunctions() return { MODIFIER_PROPERTY_INCOMING_PHYSICAL_DAMAGE_PERCENTAGE } end
function modifier_enfos_lich_frost_shield:GetModifierIncomingPhysicalDamage_Percentage()
    local ab = self:GetAbility()
    local red = ab and value(ab, 'damage_reduction') or 40
    return -red
end
