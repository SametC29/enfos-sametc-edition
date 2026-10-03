-- Vengeful Spirit R: isolated existing implementation; review gates remain pending.
local Helpers = require('abilities/shared/pve_helpers')
local value, get_agi, damage = Helpers.value, Helpers.get_agi, Helpers.damage
local HeroTrace = require('lib/hero_trace')
local function alive(unit)
    return unit and not (unit.IsNull and unit:IsNull()) and unit:IsAlive()
end
LinkLuaModifier('modifier_enfos_vs_nether_swap_buff', 'abilities/heroes/vengefulspirit/r', LUA_MODIFIER_MOTION_NONE)

enfos_vs_nether_swap=class({})
function enfos_vs_nether_swap:GetCastRange() return value(self, 'cast_range') end
function enfos_vs_nether_swap:OnSpellStart()
    if not IsServer() or (self.IsNull and self:IsNull()) then return end
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not alive(c) or not alive(t) or c == t then return end
    if t.TriggerSpellAbsorb and t:GetTeamNumber() ~= c:GetTeamNumber() and t:TriggerSpellAbsorb(self) then
        HeroTrace:Log('VENGEFUL_SPIRIT','R','cast_cancelled reason=spell_absorb')
        return
    end
    if not alive(c) or not alive(t) or (self.IsNull and self:IsNull()) then return end
    t:Interrupt()
    HeroTrace:Log('VENGEFUL_SPIRIT','R','target_interrupted target=%s',HeroTrace:Name(t))
    -- Interrupt can synchronously run a channel-end callback that removes an entity.
    if not alive(c) or not alive(t) or (self.IsNull and self:IsNull()) then return end
    HeroTrace:Log('VENGEFUL_SPIRIT','R','cast caster=%s target=%s rank=%s allied=%s',HeroTrace:Name(c),HeroTrace:Name(t),tostring(self.GetLevel and self:GetLevel() or 0),tostring(t:GetTeamNumber()==c:GetTeamNumber()))
    c:EmitSound('Hero_VengefulSpirit.NetherSwap')
    t:EmitSound('Hero_VengefulSpirit.NetherSwap')
    local p_target = t:GetAbsOrigin()
    local p_caster = c:GetAbsOrigin()

    local fx1 = ParticleManager:CreateParticle('particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(fx1, 0, p_caster)
    ParticleManager:SetParticleControl(fx1, 1, p_target)
    ParticleManager:ReleaseParticleIndex(fx1)

    local fx2 = ParticleManager:CreateParticle('particles/units/heroes/hero_vengeful/vengeful_nether_swap_target.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(fx2, 0, p_target)
    ParticleManager:SetParticleControl(fx2, 1, p_caster)
    ParticleManager:ReleaseParticleIndex(fx2)

    c:SetAbsOrigin(p_target)
    FindClearSpaceForUnit(c, p_target, true)
    if not alive(c) or not alive(t) or (self.IsNull and self:IsNull()) then return end
    t:SetAbsOrigin(p_caster)
    FindClearSpaceForUnit(t, p_caster, true)
    if not alive(c) or not alive(t) or (self.IsNull and self:IsNull()) then return end
    HeroTrace:Log('VENGEFUL_SPIRIT','R','swap caster_destination=%s target_destination=%s',tostring(p_target),tostring(p_caster))
    local dmg = value(self, 'damage')
    local agi = get_agi(c)
    local total_dmg = dmg + (agi * 1.2)
    if t:GetTeamNumber() ~= c:GetTeamNumber() then
        local dealt = damage(self, t, total_dmg, DAMAGE_TYPE_MAGICAL)
        HeroTrace:Log('VENGEFUL_SPIRIT','R','impact target=%s requested_damage=%s actual_damage=%s',HeroTrace:Name(t),tostring(total_dmg),tostring(dealt))
    end
    if not alive(c) or (self.IsNull and self:IsNull()) then return end
    local buff = c:AddNewModifier(c, self, 'modifier_enfos_vs_nether_swap_buff', { duration = 4.0 })
    HeroTrace:Log('VENGEFUL_SPIRIT','R','defense duration=4 incoming_damage_pct=-30 modifier_applied=%s',tostring(buff~=nil))
end

modifier_enfos_vs_nether_swap_buff=class({})
function modifier_enfos_vs_nether_swap_buff:GetTexture() return 'vengefulspirit_nether_swap' end
function modifier_enfos_vs_nether_swap_buff:IsPurgable() return true end
function modifier_enfos_vs_nether_swap_buff:DeclareFunctions() return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE } end
function modifier_enfos_vs_nether_swap_buff:GetModifierIncomingDamage_Percentage() return -30 end
