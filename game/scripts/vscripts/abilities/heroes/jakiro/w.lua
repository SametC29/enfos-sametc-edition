-- Jakiro W: isolated authored implementation; behavior unchanged in extraction.
local Helpers = require('abilities/shared/pve_helpers')
local value, enemies, is_boss, get_int, damage = Helpers.value, Helpers.enemies, Helpers.is_boss, Helpers.get_int, Helpers.damage
local effect, ground_effect, remove_ground_effect = Helpers.effect, Helpers.ground_effect, Helpers.remove_ground_effect

enfos_jakiro_ice_path=class({})
function enfos_jakiro_ice_path:OnSpellStart()
    local c = self:GetCaster()
    if not c or (c.IsNull and c:IsNull()) or not c:IsAlive() then return end
    local origin = c:GetAbsOrigin()
    local p = self:GetCursorPosition()
    local dir = (p - origin):Normalized()
    c:EmitSound('Hero_Jakiro.IcePath.Cast')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_jakiro/jakiro_ice_path.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(fx, 0, origin)
    ParticleManager:SetParticleControl(fx, 1, origin + (dir * 800))
    ParticleManager:SetParticleControl(fx, 2, Vector(2.0, 0, 0))
    ParticleManager:ReleaseParticleIndex(fx)
    local dmg = value(self, 'damage')
    local int = get_int(c)
    local total_dmg = dmg + (int * 0.6)
    local stun_dur = value(self, 'stun_duration')
    if stun_dur <= 0 then stun_dur = 2.0 end
    local path_delay = math.max(0, value(self, 'path_delay'))
    self.cast_serial = (self.cast_serial or 0) + 1
    local owner_id = (self.entindex and self:entindex()) or (c.entindex and c:entindex()) or (c.GetUnitName and c:GetUnitName()) or 'jakiro'
    local context_name = 'EnfosJakiroIcePath_' .. tostring(owner_id) .. '_' .. tostring(self.cast_serial)
    GameRules:GetGameModeEntity():SetContextThink(context_name, function()
        if not c or (c.IsNull and c:IsNull()) then return nil end
        for _, u in ipairs(enemies(c, origin + (dir * 600), 700)) do
            local d = stun_dur
            if is_boss(u) then d = d * 0.35 end
            u:AddNewModifier(c, self, 'modifier_generic_stunned_lua', { duration = d })
            damage(self, u, total_dmg, DAMAGE_TYPE_MAGICAL)
        end
        return nil
    end, path_delay)
end
