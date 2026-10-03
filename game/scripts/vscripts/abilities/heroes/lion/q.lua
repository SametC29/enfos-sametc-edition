-- Lion Q: engine-owned finite travel with saved authored damage and stun.
local H = require('abilities/shared/pve_helpers')
local Trace = require('lib/hero_trace')
LinkLuaModifier('modifier_enfos_lion_earth_spike_stun', 'abilities/heroes/lion/q', LUA_MODIFIER_MOTION_NONE)
local function valid(x) return x and not (x.IsNull and x:IsNull()) end
local function immune(t)
    return (t.IsDebuffImmune and t:IsDebuffImmune()) or (t.IsMagicImmune and t:IsMagicImmune())
end
local function positive(a,k,fallback) local n=H.value(a,k);return n>0 and n or fallback end

enfos_lion_earth_spike=class({})
function enfos_lion_earth_spike:OnSpellStart()
    if not IsServer() or not valid(self) then return end
    local c=self:GetCaster()
    if not valid(c) or not c:IsAlive() then return end
    local origin=c:GetAbsOrigin()
    local t=self.GetCursorTarget and self:GetCursorTarget()
    local destination=valid(t) and t:GetAbsOrigin() or self:GetCursorPosition()
    local dir=destination-origin;dir.z=0
    if dir:Length2D()<0.01 then dir=c:GetForwardVector();dir.z=0 end
    dir=dir:Normalized()
    local width,speed=positive(self,'width',140),positive(self,'speed',2800)
    local distance=math.max(0,self:GetCastRange(origin,t))+positive(self,'length_buffer',275)
    local data={damage=H.value(self,'damage')+H.get_int(c)*H.value(self,'int_scaling_pct')/100,
        stun_duration=H.value(self,'stun_duration')}
    c:EmitSound('Hero_Lion.Impale')
    if not valid(self) or not valid(c) then return end
    local handle=ProjectileManager:CreateLinearProjectile({
        Ability=self,Source=c,vSpawnOrigin=origin,vVelocity=dir*speed,
        EffectName='particles/units/heroes/hero_lion/lion_spell_impale.vpcf',
        fDistance=distance,fStartRadius=width,fEndRadius=width,
        bHasFrontalCone=false,bReplaceExisting=false,bDeleteOnHit=false,
        iUnitTargetTeam=DOTA_UNIT_TARGET_TEAM_ENEMY,iUnitTargetType=DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
        iUnitTargetFlags=DOTA_UNIT_TARGET_FLAG_NONE,bProvidesVision=false,
        fExpireTime=GameRules:GetGameTime()+distance/speed+0.2,ExtraData=data,
    })
    Trace:Log('LION','Q','projectile_created handle=%s distance=%s width=%s speed=%s damage=%s stun=%s',
        tostring(handle),tostring(distance),tostring(width),tostring(speed),tostring(data.damage),tostring(data.stun_duration))
end
function enfos_lion_earth_spike:OnProjectileHit_ExtraData(t,location,data)
    if not IsServer() or not valid(self) then return true end
    if not t then Trace:Log('LION','Q','projectile_finished cleanup=engine');return true end
    local c=self:GetCaster()
    if not valid(c) then return true end
    if not valid(t) or not t:IsAlive() or t:GetTeamNumber()==c:GetTeamNumber() or immune(t) then
        Trace:Log('LION','Q','impact_skipped target=%s reason=ordinary_target_gate',Trace:Name(t))
        return false
    end
    if not data or not tonumber(data.damage) or not tonumber(data.stun_duration) then return true end
    local origin=t:GetAbsOrigin()
    local p=ParticleManager:CreateParticle('particles/units/heroes/hero_lion/lion_spell_impale_hit_spikes.vpcf',PATTACH_WORLDORIGIN,t)
    ParticleManager:SetParticleControl(p,0,origin)
    ParticleManager:ReleaseParticleIndex(p) -- Installed instantaneous emitter, finite4.5s lifetime.
    if not valid(self) or not valid(c) or not valid(t) or not t:IsAlive() or immune(t) then return false end
    t:EmitSound('Hero_Lion.ImpaleHitTarget')
    if not valid(self) or not valid(c) or not valid(t) or not t:IsAlive() or immune(t) then return false end
    local dealt=H.damage(self,t,tonumber(data.damage),DAMAGE_TYPE_MAGICAL) or 0
    if valid(self) and valid(c) and valid(t) and t:IsAlive() and not immune(t) and tonumber(data.stun_duration)>0 then
        t:AddNewModifier(c,self,'modifier_enfos_lion_earth_spike_stun',{duration=tonumber(data.stun_duration)})
    end
    Trace:Log('LION','Q','impact target=%s requested=%s actual=%s stun_requested=%s',
        Trace:Name(t),tostring(data.damage),tostring(dealt),tostring(data.stun_duration))
    return false
end
modifier_enfos_lion_earth_spike_stun=class({})
function modifier_enfos_lion_earth_spike_stun:IsDebuff() return true end
function modifier_enfos_lion_earth_spike_stun:IsPurgable() return false end
function modifier_enfos_lion_earth_spike_stun:IsPurgeException() return true end
function modifier_enfos_lion_earth_spike_stun:GetTexture() return 'lion_impale' end
function modifier_enfos_lion_earth_spike_stun:CheckState() return { [MODIFIER_STATE_STUNNED] = true } end
function modifier_enfos_lion_earth_spike_stun:OnCreated()
    if IsServer() then Trace:Log('LION','Q','stun_applied target=%s',Trace:Name(self:GetParent())) end
end
function modifier_enfos_lion_earth_spike_stun:OnRefresh()
    if IsServer() then Trace:Log('LION','Q','stun_refreshed target=%s',Trace:Name(self:GetParent())) end
end
function modifier_enfos_lion_earth_spike_stun:OnDestroy()
    if IsServer() then Trace:Log('LION','Q','stun_removed target=%s',Trace:Name(self:GetParent())) end
end
