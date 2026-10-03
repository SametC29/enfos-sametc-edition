-- Jakiro W: one saved path for warning and delayed engine line targeting.
local Helpers = require('abilities/shared/pve_helpers')
local value, get_int, damage = Helpers.value, Helpers.get_int, Helpers.damage
local HeroTrace = require('lib/hero_trace')
local function valid(entity) return entity and not (entity.IsNull and entity:IsNull()) end

enfos_jakiro_ice_path=class({})
function enfos_jakiro_ice_path:OnSpellStart()
    if not IsServer() or not valid(self) then return end
    local c = self:GetCaster()
    if not valid(c) or not c:IsAlive() then return end
    local origin = c:GetAbsOrigin()
    local dir = self:GetCursorPosition() - origin
    dir.z = 0
    if dir:Length2D() < 1 then dir = c:GetForwardVector(); dir.z = 0 end
    if dir:Length2D() < 1 then return end
    dir = dir:Normalized()
    local length, radius = value(self, 'path_length'), value(self, 'path_radius')
    if length <= 0 then length = 1200 end
    if radius <= 0 then radius = 150 end
    local last = origin + dir * length
    local total_dmg = value(self, 'damage') + get_int(c) * 0.6
    local stun_dur = value(self, 'stun_duration')
    if stun_dur <= 0 then stun_dur = 2 end
    local path_delay = math.max(0, value(self, 'path_delay'))
    c:EmitSound('Hero_Jakiro.IcePath.Cast')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_jakiro/jakiro_ice_path.vpcf', PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(fx, 0, origin)
    ParticleManager:SetParticleControl(fx, 1, last)
    ParticleManager:SetParticleControl(fx, 2, Vector(path_delay + stun_dur, 0, 0))
    ParticleManager:SetParticleControl(fx, 3, Vector(radius, 0, 0))
    ParticleManager:ReleaseParticleIndex(fx)
    self.cast_serial = (self.cast_serial or 0) + 1
    local owner_id = (self.entindex and self:entindex()) or (c.entindex and c:entindex()) or 'jakiro'
    local context_name = 'EnfosJakiroIcePath_' .. tostring(owner_id) .. '_' .. tostring(self.cast_serial)
    HeroTrace:Log('JAKIRO', 'W', 'warning rank=%s origin=%s end=%s radius=%s delay=%s stun=%s requested_damage=%s',
        tostring(self.GetLevel and self:GetLevel() or 0), tostring(origin), tostring(last), tostring(radius), tostring(path_delay), tostring(stun_dur), tostring(total_dmg))
    GameRules:GetGameModeEntity():SetContextThink(context_name, function()
        if not valid(self) or not valid(c) then
            HeroTrace:Log('JAKIRO', 'W', 'delayed_hit_cancelled invalid_source')
            return nil
        end
        local targets = FindUnitsInLine(c:GetTeamNumber(), origin, last, nil, radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE) or {}
        for _, u in ipairs(targets) do
            if not valid(self) or not valid(c) then return nil end
            if valid(u) and u:IsAlive() and u:GetTeamNumber() ~= c:GetTeamNumber() then
                u:AddNewModifier(c, self, 'modifier_stunned', { duration = stun_dur })
                -- Modifier creation can remove an owner via engine/script callbacks.
                if not valid(self) or not valid(c) then return nil end
                if valid(u) and u:IsAlive() and u:GetTeamNumber() ~= c:GetTeamNumber() then
                    local dealt = damage(self, u, total_dmg, DAMAGE_TYPE_MAGICAL)
                    HeroTrace:Log('JAKIRO', 'W', 'hit target=%s requested_damage=%s applied_damage=%s stun=%s',
                        HeroTrace:Name(u), tostring(total_dmg), tostring(dealt or 'unavailable'), tostring(stun_dur))
                end
            end
        end
        return nil
    end, path_delay)
end
