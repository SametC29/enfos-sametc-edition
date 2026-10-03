-- Jakiro Q: isolated authored cast; application-owned slow snapshots.
local Helpers = require('abilities/shared/pve_helpers')
local value, enemies, is_boss, get_int, damage = Helpers.value, Helpers.enemies, Helpers.is_boss, Helpers.get_int, Helpers.damage
local HeroTrace = require('lib/hero_trace')
LinkLuaModifier('modifier_enfos_jakiro_dual_breath_slow', 'abilities/heroes/jakiro/q', LUA_MODIFIER_MOTION_NONE)

enfos_jakiro_dual_breath=class({})
function enfos_jakiro_dual_breath:OnSpellStart()
    local c = self:GetCaster()
    local p = self:GetCursorPosition()
    local dir = (p - c:GetAbsOrigin()):Normalized()
    c:EmitSound('Hero_Jakiro.DualBreath.Cast')
    local fx = ParticleManager:CreateParticle('particles/units/heroes/hero_jakiro/jakiro_dual_breath_fire.vpcf', PATTACH_ABSORIGIN_FOLLOW, c)
    ParticleManager:SetParticleControl(fx, 0, c:GetAbsOrigin())
    ParticleManager:SetParticleControl(fx, 1, dir * 500)
    ParticleManager:ReleaseParticleIndex(fx)
    local dmg = value(self, 'damage')
    local int = get_int(c)
    local total_dmg = dmg + (int * 0.8)
    local slow = value(self, 'slow_pct')
    local dur = value(self, 'duration')
    if dur <= 0 then dur = 5.0 end

    for _, u in ipairs(enemies(c, c:GetAbsOrigin() + (dir * 400), 500)) do
        damage(self, u, total_dmg, DAMAGE_TYPE_MAGICAL)
        u:AddNewModifier(c, self, 'modifier_enfos_jakiro_dual_breath_slow', { duration = dur, slow_pct = slow, attack_slow = 40 })
    end
end

modifier_enfos_jakiro_dual_breath_slow=class({})
function modifier_enfos_jakiro_dual_breath_slow:IsDebuff() return true end
function modifier_enfos_jakiro_dual_breath_slow:IsPurgable() return true end
function modifier_enfos_jakiro_dual_breath_slow:GetTexture() return 'jakiro_dual_breath' end
function modifier_enfos_jakiro_dual_breath_slow:ReadApplication(params)
    -- Actual engine calls supply snapshots; legacy fixtures may omit parameters.
    local a = self:GetAbility()
    local slow = tonumber(params and params.slow_pct)
    if slow == nil then
        slow = a and not (a.IsNull and a:IsNull()) and value(a, 'slow_pct') or 0
    end
    self.slow = math.max(0, slow)
    self.attack_slow = math.max(0, tonumber(params and params.attack_slow) or 40)
end
function modifier_enfos_jakiro_dual_breath_slow:OnCreated(params)
    if not IsServer() then return end
    self:ReadApplication(params)
    self:SetHasCustomTransmitterData(true)
    HeroTrace:Log('JAKIRO','Q','slow_applied target=%s move_slow=%s attack_slow=%s',
        HeroTrace:Name(self:GetParent()), tostring(self.slow), tostring(self.attack_slow))
end
function modifier_enfos_jakiro_dual_breath_slow:OnRefresh(params)
    if not IsServer() then return end
    self:ReadApplication(params)
    self:SendBuffRefreshToClients()
    HeroTrace:Log('JAKIRO','Q','slow_refreshed target=%s move_slow=%s attack_slow=%s',
        HeroTrace:Name(self:GetParent()), tostring(self.slow), tostring(self.attack_slow))
end
function modifier_enfos_jakiro_dual_breath_slow:AddCustomTransmitterData()
    return { slow = self.slow or 0, attack_slow = self.attack_slow or 0 }
end
function modifier_enfos_jakiro_dual_breath_slow:HandleCustomTransmitterData(data)
    self.slow = tonumber(data and data.slow) or 0
    self.attack_slow = tonumber(data and data.attack_slow) or 0
end
function modifier_enfos_jakiro_dual_breath_slow:OnDestroy()
    HeroTrace:Log('JAKIRO','Q','slow_removed target=%s',HeroTrace:Name(self:GetParent()))
end
function modifier_enfos_jakiro_dual_breath_slow:DeclareFunctions()
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_TOOLTIP, MODIFIER_PROPERTY_TOOLTIP2 }
end
function modifier_enfos_jakiro_dual_breath_slow:GetModifierMoveSpeedBonus_Percentage() return -(self.slow or 0) end
function modifier_enfos_jakiro_dual_breath_slow:GetModifierAttackSpeedBonus_Constant() return -(self.attack_slow or 0) end
function modifier_enfos_jakiro_dual_breath_slow:OnTooltip() return self.slow or 0 end
function modifier_enfos_jakiro_dual_breath_slow:OnTooltip2() return self.attack_slow or 0 end
