-- Lion Q: byte-preserving isolation; gameplay audit remains pending.
local H = require('abilities/shared/pve_helpers')
local value, enemies, is_boss, get_int, damage, effect = H.value, H.enemies, H.is_boss, H.get_int, H.damage, H.effect
LinkLuaModifier('modifier_enfos_lion_earth_spike_stun', 'abilities/heroes/lion/q', LUA_MODIFIER_MOTION_NONE)

enfos_lion_earth_spike=class({})
function enfos_lion_earth_spike:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local dir = (self:GetCursorPosition() - c:GetAbsOrigin()):Normalized()
    local distance = value(self, 'distance')
    if distance <= 0 then distance = 450 end
    local radius = value(self, 'radius')
    if radius <= 0 then radius = 500 end
    c:EmitSound('Hero_Lion.Impale')
    local base = value(self, 'damage')
    local int = get_int(c)
    local dmg = base + (int * value(self, 'int_scaling_pct') / 100)
    local stun_duration = value(self, 'stun_duration')
    if stun_duration <= 0 then stun_duration = 1.8 end
    for _, u in ipairs(enemies(c, c:GetAbsOrigin() + (dir * distance), radius)) do
        if u and u:IsAlive() then
        damage(self, u, dmg, DAMAGE_TYPE_MAGICAL)
        local dur = stun_duration
        if is_boss(u) then dur = dur * 0.35 end
        u:AddNewModifier(c, self, 'modifier_enfos_lion_earth_spike_stun', { duration = dur })
        effect('particles/units/heroes/hero_lion/lion_spell_impale_hit_spikes.vpcf', u)
        end
    end
end

modifier_enfos_lion_earth_spike_stun=class({})
function modifier_enfos_lion_earth_spike_stun:IsDebuff() return true end
function modifier_enfos_lion_earth_spike_stun:CheckState() return { [MODIFIER_STATE_STUNNED] = true } end
