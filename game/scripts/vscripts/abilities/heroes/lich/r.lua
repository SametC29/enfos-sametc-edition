-- Lich isolated Chain Frost: stable ID and authored PvE hit budget.
local Helpers = require('abilities/shared/pve_helpers')
local value, enemies, is_boss, get_int, damage = Helpers.value, Helpers.enemies, Helpers.is_boss, Helpers.get_int, Helpers.damage
local HeroTrace = require('lib/hero_trace')

LinkLuaModifier('modifier_enfos_lich_chain_frost_slow', 'abilities/heroes/lich/r', LUA_MODIFIER_MOTION_NONE)

enfos_lich_chain_frost=class({})
function enfos_lich_chain_frost:Precache(context)
    PrecacheResource('soundfile', 'soundevents/game_sounds_heroes/game_sounds_lich.vsndevts', context)
    PrecacheResource('particle', 'particles/units/heroes/hero_lich/lich_chain_frost.vpcf', context)
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
    local slow_duration = value(self, 'slow_duration')
    if slow_duration <= 0 then slow_duration = 2.5 end
    -- Numeric ExtraData carries this chain's bounded history; no retained cast table
    -- or expiry timer is needed if the engine drops a projectile callback.
    local data = { hits = 0, limit = math.min(18, math.floor(jumps)), damage = total_dmg, slow_duration = slow_duration }
    if HeroTrace:Enabled() then HeroTrace:Log('LICH','R','cast target=%s rank=%s jumps=%s requested_damage=%s',HeroTrace:Name(t),tostring(self:GetLevel()),tostring(data.limit),tostring(total_dmg)) end
    self:LaunchChainProjectile(t, c:GetAbsOrigin(), data)
end

function enfos_lich_chain_frost:LaunchChainProjectile(target, origin, data)
    if self.IsNull and self:IsNull() then return end
    local c = self:GetCaster()
    if not c or c:IsNull() or not target or target:IsNull() or not target:IsAlive() then return end
    local speed = data.hits == 0 and 1050 or 850 -- Installed native Lich projectile speeds, build 6943.
    local id = ProjectileManager:CreateTrackingProjectile({
        Target = target, Source = c, Ability = self, vSourceLoc = origin,
        EffectName = 'particles/units/heroes/hero_lich/lich_chain_frost.vpcf',
        iMoveSpeed = speed, bDodgeable = false, bIsAttack = false,
        bProvidesVision = false, ExtraData = data,
    })
    HeroTrace:Log('LICH','R','projectile_launch id=%s target=%s hit_index=%s speed=%s particle_owner=engine',tostring(id),HeroTrace:Name(target),tostring(data.hits + 1),tostring(speed))
end

function enfos_lich_chain_frost:OnProjectileHit_ExtraData(target, location, data)
    if not IsServer() then return true end
    if self.IsNull and self:IsNull() then return true end
    local c = self:GetCaster()
    if not c or c:IsNull() then
        HeroTrace:Log('LICH','R','chain_end reason=source_removed')
        return true
    end
    if not data or type(data.hits) ~= 'number' or type(data.limit) ~= 'number'
        or type(data.damage) ~= 'number' or type(data.slow_duration) ~= 'number'
        or data.hits < 0 or data.hits ~= math.floor(data.hits) or data.hits >= data.limit or data.limit > 18 then return true end
    if not target or target:IsNull() or not target:IsAlive() or target:GetTeamNumber() == c:GetTeamNumber() then
        HeroTrace:Log('LICH','R','chain_end reason=target_lost_or_invalid hit_index=%s',tostring(data.hits + 1))
        return true
    end
    local targetId = target:entindex()
    for i = 1, data.hits do if data['hit_' .. i] == targetId then return true end end
    local origin = target:GetAbsOrigin()
    local duration = is_boss(target) and data.slow_duration * 0.35 or data.slow_duration
    data.hits = data.hits + 1
    data['hit_' .. data.hits] = targetId
    target:EmitSound(target:IsHero() and 'Hero_Lich.ChainFrostImpact.Hero' or 'Hero_Lich.ChainFrostImpact.Creep')
    HeroTrace:Log('LICH','R','projectile_impact target=%s index=%s boss=%s requested_damage=%s slow_duration=%s',HeroTrace:Name(target),tostring(data.hits),tostring(is_boss(target)),tostring(data.damage),tostring(duration))
    local dealt = damage(self, target, data.damage, DAMAGE_TYPE_MAGICAL)
    HeroTrace:Log('LICH','R','damage_result actual=%s',tostring(dealt))
    if c:IsNull() or (self.IsNull and self:IsNull()) then
        HeroTrace:Log('LICH','R','chain_end reason=source_removed_after_damage')
        return true
    end
    if not target:IsNull() and target:IsAlive() then
        target:AddNewModifier(c, self, 'modifier_enfos_lich_chain_frost_slow', { duration = duration })
    end
    if data.hits >= data.limit then
        HeroTrace:Log('LICH','R','chain_end reason=hit_limit hits=%s',tostring(data.hits))
        return true
    end
    for _, u in ipairs(enemies(c, origin, 600)) do
        if u and not u:IsNull() and u:IsAlive() then
            local visited = false
            for i = 1, data.hits do if data['hit_' .. i] == u:entindex() then visited = true; break end end
            if not visited then self:LaunchChainProjectile(u, origin, data); return true end
        end
    end
    HeroTrace:Log('LICH','R','chain_end reason=no_unvisited_target hits=%s',tostring(data.hits))
    return true
end

modifier_enfos_lich_chain_frost_slow=class({})
function modifier_enfos_lich_chain_frost_slow:OnCreated()
    if IsServer() then HeroTrace:Log('LICH','R','slow_created target=%s owner=%s',HeroTrace:Name(self:GetParent()),HeroTrace:Name(self:GetCaster())) end
end
function modifier_enfos_lich_chain_frost_slow:OnRefresh()
    if IsServer() then HeroTrace:Log('LICH','R','slow_refreshed target=%s owner=%s',HeroTrace:Name(self:GetParent()),HeroTrace:Name(self:GetCaster())) end
end
function modifier_enfos_lich_chain_frost_slow:OnDestroy()
    if IsServer() then HeroTrace:Log('LICH','R','slow_removed target=%s owner=%s',HeroTrace:Name(self:GetParent()),HeroTrace:Name(self:GetCaster())) end
end
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
