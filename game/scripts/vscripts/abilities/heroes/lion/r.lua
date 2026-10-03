-- Lion R: byte-preserving isolation; gameplay audit remains pending.
local H = require('abilities/shared/pve_helpers')
local value, enemies, is_boss, get_int, damage, effect = H.value, H.enemies, H.is_boss, H.get_int, H.damage, H.effect
LinkLuaModifier('modifier_enfos_lion_finger_counter', 'abilities/heroes/lion/r', LUA_MODIFIER_MOTION_NONE)

enfos_lion_finger_of_death=class({})
function enfos_lion_finger_of_death:GetIntrinsicModifierName() return 'modifier_enfos_lion_finger_counter' end
function enfos_lion_finger_of_death:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or t:IsNull() or not t:IsAlive() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end

    c:EmitSound('Hero_Lion.FingerOfDeath')
    effect('particles/units/heroes/hero_lion/lion_spell_finger_of_death.vpcf', t)

    local base = value(self, 'damage')
    if base <= 0 then base = 850 end
    local int = get_int(c)
    local mod = c:FindModifierByName('modifier_enfos_lion_finger_counter')
    local stacks = mod and mod:GetStackCount() or 0
    local cappedStacks = math.min(math.max(0, stacks), value(self, 'kill_stack_cap'))
    local total_dmg = base + (int * value(self, 'int_scaling_pct') / 100) + (cappedStacks * value(self, 'kill_stack_damage'))

    local splash_radius = value(self, 'splash_radius')
    if splash_radius <= 0 then splash_radius = 325 end
    for _, u in ipairs(enemies(c, t:GetAbsOrigin(), splash_radius)) do
        local hit = total_dmg
        if is_boss(u) then hit = math.min(hit, u:GetMaxHealth() * value(self, 'boss_damage_cap_pct') / 100) end
        damage(self, u, hit, DAMAGE_TYPE_MAGICAL)
        if not u:IsAlive() and mod and mod.SetStackCount then
            mod:SetStackCount(math.min(value(self, 'kill_stack_cap'), mod:GetStackCount() + 1))
        end
    end
end

modifier_enfos_lion_finger_counter=class({})
function modifier_enfos_lion_finger_counter:DeclareFunctions() return { MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE } end
function modifier_enfos_lion_finger_counter:GetModifierSpellAmplify_Percentage()
    return math.min(math.max(0, self:GetStackCount() or 0), value(self:GetAbility(), 'kill_stack_cap'))
        * value(self:GetAbility(), 'kill_stack_spell_amp_pct')
end
