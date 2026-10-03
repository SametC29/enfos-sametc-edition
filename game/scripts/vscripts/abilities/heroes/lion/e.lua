-- Lion E: byte-preserving isolation; gameplay audit remains pending.
local H = require('abilities/shared/pve_helpers')
local value, enemies, is_boss, get_int, damage, effect = H.value, H.enemies, H.is_boss, H.get_int, H.damage, H.effect
LinkLuaModifier('modifier_enfos_lion_mana_drain_channel', 'abilities/heroes/lion/e', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_enfos_lion_mana_drain_debuff', 'abilities/heroes/lion/e', LUA_MODIFIER_MOTION_NONE)

enfos_lion_mana_drain=class({})
function enfos_lion_mana_drain:OnSpellStart()
    local c = self:GetCaster()
    local t = self:GetCursorTarget()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() or not t or t:IsNull() or not t:IsAlive() then return end
    if t.TriggerSpellAbsorb and t:TriggerSpellAbsorb(self) then return end

    c:EmitSound('Hero_Lion.ManaDrain')
    local duration = value(self, 'channel_duration')
    if duration <= 0 then duration = 4.0 end
    c:AddNewModifier(c, self, 'modifier_enfos_lion_mana_drain_channel', { duration = duration, target_idx = t:entindex() })
    t:AddNewModifier(c, self, 'modifier_enfos_lion_mana_drain_debuff', { duration = duration })
end
function enfos_lion_mana_drain:OnChannelFinish(interrupted)
    local c = self:GetCaster()
    c:RemoveModifierByName('modifier_enfos_lion_mana_drain_channel')
end

modifier_enfos_lion_mana_drain_channel=class({})
function modifier_enfos_lion_mana_drain_channel:OnDestroy()
    if not IsServer() then return end
    local caster=self:GetCaster()
    local target=self.target_idx and EntIndexToHScript(self.target_idx)
    if target and not target:IsNull() then target:RemoveModifierByNameAndCaster('modifier_enfos_lion_mana_drain_debuff',caster) end
    if caster and not caster:IsNull() then caster:StopSound('Hero_Lion.ManaDrain') end
end
function modifier_enfos_lion_mana_drain_channel:OnCreated(kv)
    if not IsServer() then return end
    self.target_idx = kv and kv.target_idx or nil
    self:StartIntervalThink(0.5)
end
function modifier_enfos_lion_mana_drain_channel:OnIntervalThink()
    local c = self:GetParent()
    local a = self:GetAbility()
    local t = EntIndexToHScript(self.target_idx or 0)
    if not c or c:IsNull() or not c:IsAlive() or not t or t:IsNull() or not t:IsAlive() then
        if a and a.EndChannel then a:EndChannel(true) else self:Destroy() end
        return
    end

    local base = (a and value(a, 'mana_per_second')) or 120
    local int = get_int(c)
    local tick_dmg = (base + (int * 0.8)) * 0.5

    damage(a, t, tick_dmg, DAMAGE_TYPE_MAGICAL)
    if c.GiveMana then c:GiveMana(tick_dmg) end
    effect('particles/units/heroes/hero_lion/lion_spell_mana_drain.vpcf', t)
end

modifier_enfos_lion_mana_drain_debuff=class({})
function modifier_enfos_lion_mana_drain_debuff:IsDebuff() return true end
function modifier_enfos_lion_mana_drain_debuff:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE } end
function modifier_enfos_lion_mana_drain_debuff:GetModifierMoveSpeedBonus_Percentage() return -value(self:GetAbility(), 'slow_pct') end
