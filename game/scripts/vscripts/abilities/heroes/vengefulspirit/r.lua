-- Vengeful Spirit R: isolated existing implementation; review gates remain pending.
local Helpers = require('abilities/shared/pve_helpers')
local value, enemies, is_boss, get_agi, damage = Helpers.value, Helpers.enemies, Helpers.is_boss, Helpers.get_agi, Helpers.damage
LinkLuaModifier('modifier_enfos_vs_nether_swap_buff', 'abilities/heroes/vengefulspirit/r', LUA_MODIFIER_MOTION_NONE)

enfos_vs_nether_swap=class({})
function enfos_vs_nether_swap:GetCastRange() return value(self, 'cast_range') end
function enfos_vs_nether_swap:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or t:IsNull() or not t:IsAlive() then return end
    if t.TriggerSpellAbsorb and t:GetTeamNumber() ~= c:GetTeamNumber() and t:TriggerSpellAbsorb(self) then return end
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
    if not is_boss(t) then
        t:SetAbsOrigin(p_caster)
        FindClearSpaceForUnit(t, p_caster, true)
    end
    local dmg = value(self, 'damage')
    local agi = get_agi(c)
    local total_dmg = dmg + (agi * 1.2)
    if t:GetTeamNumber() ~= c:GetTeamNumber() then
        if is_boss(t) then total_dmg = math.min(total_dmg, t:GetMaxHealth() * 0.1) end
        damage(self, t, total_dmg, DAMAGE_TYPE_MAGICAL)
    end
    c:AddNewModifier(c, self, 'modifier_enfos_vs_nether_swap_buff', { duration = 4.0 })
end

modifier_enfos_vs_nether_swap_buff=class({})
function modifier_enfos_vs_nether_swap_buff:DeclareFunctions() return { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE } end
function modifier_enfos_vs_nether_swap_buff:GetModifierIncomingDamage_Percentage() return -30 end
