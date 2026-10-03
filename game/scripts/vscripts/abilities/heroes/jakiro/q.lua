-- Jakiro Q: saved traveling ice/fire cones and modifier-owned periodic burn.
local Helpers = require('abilities/shared/pve_helpers')
local value, get_int, damage = Helpers.value, Helpers.get_int, Helpers.damage
local HeroTrace = require('lib/hero_trace')
LinkLuaModifier('modifier_enfos_jakiro_dual_breath_slow', 'abilities/heroes/jakiro/q', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_enfos_jakiro_dual_breath_burn', 'abilities/heroes/jakiro/q', LUA_MODIFIER_MOTION_NONE)
local function valid(entity) return entity and not (entity.IsNull and entity:IsNull()) end
local function immune(unit)
    return (unit.IsDebuffImmune and unit:IsDebuffImmune()) or (unit.IsMagicImmune and unit:IsMagicImmune())
end
local function positive(a,key,fallback) local n=value(a,key);return n>0 and n or fallback end

enfos_jakiro_dual_breath=class({})
function enfos_jakiro_dual_breath:LaunchBreath(c,origin,dir,geometry,data,phase)
    if not valid(self) or not valid(c) then return end
    local payload={phase=phase,duration=data.duration,slow_pct=data.slow_pct,attack_slow=data.attack_slow,dps=data.dps}
    local handle=ProjectileManager:CreateLinearProjectile({
        Ability=self,Source=c,vSpawnOrigin=origin,vVelocity=dir*geometry.speed,
        EffectName=phase==1 and 'particles/units/heroes/hero_jakiro/jakiro_dual_breath_ice.vpcf' or 'particles/units/heroes/hero_jakiro/jakiro_dual_breath_fire.vpcf',
        fDistance=geometry.distance,fStartRadius=geometry.start_radius,fEndRadius=geometry.end_radius,
        bHasFrontalCone=false,bReplaceExisting=false,bDeleteOnHit=false,
        iUnitTargetTeam=DOTA_UNIT_TARGET_TEAM_ENEMY,iUnitTargetType=DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
        iUnitTargetFlags=DOTA_UNIT_TARGET_FLAG_NONE,bProvidesVision=false,ExtraData=payload,
    })
    HeroTrace:Log('JAKIRO','Q','projectile_created phase=%s handle=%s distance=%s speed=%s start_radius=%s end_radius=%s burn_dps=%s',
        tostring(phase),tostring(handle),tostring(geometry.distance),tostring(geometry.speed),tostring(geometry.start_radius),tostring(geometry.end_radius),tostring(data.dps))
end
function enfos_jakiro_dual_breath:OnSpellStart()
    if not IsServer() or not valid(self) then return end
    local c=self:GetCaster()
    if not valid(c) or not c:IsAlive() or (self.GetLevel and self:GetLevel()<=0) then return end
    local origin=c:GetAbsOrigin()
    local dir=self:GetCursorPosition()-origin;dir.z=0
    if dir:Length2D()<1 then dir=c:GetForwardVector();dir.z=0 end
    if dir:Length2D()<1 then return end
    dir=dir:Normalized()
    local duration=positive(self,'duration',5)
    local distance=self.GetEffectiveCastRange and self:GetEffectiveCastRange(origin,nil) or positive(self,'breath_distance',850)
    local geometry={distance=distance,speed=positive(self,'breath_speed',1050),start_radius=positive(self,'start_radius',150),end_radius=positive(self,'end_radius',275)}
    local data={duration=duration,slow_pct=value(self,'slow_pct'),attack_slow=40,dps=(value(self,'damage')+get_int(c)*0.8)/duration}
    local delay=positive(self,'fire_delay',0.2)
    c:EmitSound('Hero_Jakiro.DualBreath.Cast')
    if not valid(self) or not valid(c) then return end
    self:LaunchBreath(c,origin,dir,geometry,data,1)
    if not valid(self) or not valid(c) then return end
    self.breath_serial=(self.breath_serial or 0)+1
    local key='EnfosJakiroFire_'..tostring(self.entindex and self:entindex() or c:entindex())..'_'..tostring(self.breath_serial)
    GameRules:GetGameModeEntity():SetContextThink(key,function()
        if not valid(self) or not valid(c) then return nil end
        if GameRules.IsGamePaused and GameRules:IsGamePaused() then return 0.03 end
        self:LaunchBreath(c,origin,dir,geometry,data,2)
        return nil
    end,delay)
end
function enfos_jakiro_dual_breath:OnProjectileHit_ExtraData(target,location,data)
    if not IsServer() or not valid(self) then return true end
    if not target then
        HeroTrace:Log('JAKIRO','Q','projectile_finished phase=%s cleanup=engine',tostring(data and data.phase))
        return true
    end
    local c=self:GetCaster()
    if not valid(c) then return true end
    if not valid(target) or not target:IsAlive() or target:GetTeamNumber()==c:GetTeamNumber() or immune(target) then return false end
    if not data or not tonumber(data.duration) or tonumber(data.duration)<=0 then return true end
    if tonumber(data.phase)==1 then
        target:AddNewModifier(c,self,'modifier_enfos_jakiro_dual_breath_slow',{
            duration=tonumber(data.duration),slow_pct=tonumber(data.slow_pct) or 0,attack_slow=tonumber(data.attack_slow) or 40})
    elseif tonumber(data.phase)==2 and tonumber(data.dps) then
        target:AddNewModifier(c,self,'modifier_enfos_jakiro_dual_breath_burn',{duration=tonumber(data.duration),dps=tonumber(data.dps)})
    end
    HeroTrace:Log('JAKIRO','Q','impact phase=%s target=%s duration_requested=%s burn_dps=%s',
        tostring(data.phase),HeroTrace:Name(target),tostring(data.duration),tostring(data.dps))
    return false
end

modifier_enfos_jakiro_dual_breath_slow=class({})
function modifier_enfos_jakiro_dual_breath_slow:IsDebuff() return true end
function modifier_enfos_jakiro_dual_breath_slow:IsPurgable() return true end
function modifier_enfos_jakiro_dual_breath_slow:GetEffectName() return 'particles/generic_gameplay/generic_slowed_cold.vpcf' end
function modifier_enfos_jakiro_dual_breath_slow:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
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
function modifier_enfos_jakiro_dual_breath_slow:GetModifierMoveSpeedBonus_Percentage()
    local p=self:GetParent();return valid(p) and not immune(p) and -(self.slow or 0) or 0
end
function modifier_enfos_jakiro_dual_breath_slow:GetModifierAttackSpeedBonus_Constant()
    local p=self:GetParent();return valid(p) and not immune(p) and -(self.attack_slow or 0) or 0
end
function modifier_enfos_jakiro_dual_breath_slow:OnTooltip() return self.slow or 0 end
function modifier_enfos_jakiro_dual_breath_slow:OnTooltip2() return self.attack_slow or 0 end

modifier_enfos_jakiro_dual_breath_burn=class({})
function modifier_enfos_jakiro_dual_breath_burn:IsDebuff() return true end
function modifier_enfos_jakiro_dual_breath_burn:IsPurgable() return true end
function modifier_enfos_jakiro_dual_breath_burn:GetTexture() return 'jakiro_dual_breath' end
function modifier_enfos_jakiro_dual_breath_burn:GetEffectName() return 'particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf' end
function modifier_enfos_jakiro_dual_breath_burn:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_enfos_jakiro_dual_breath_burn:Snapshot(params)
    self.dps=math.max(0,tonumber(params and params.dps) or 0)
    self.last_elapsed=self:GetElapsedTime()
    self.elapsed_limit=self.last_elapsed+(self.GetRemainingTime and math.max(0,self:GetRemainingTime()) or tonumber(params and params.duration) or 5)
end
function modifier_enfos_jakiro_dual_breath_burn:DealThrough(elapsed)
    local stop=math.min(elapsed,self.elapsed_limit or elapsed)
    local slice=math.max(0,stop-(self.last_elapsed or stop))
    self.last_elapsed=stop -- Advance before damage callbacks to prevent recursive payout.
    local parent,c,a=self:GetParent(),self:GetCaster(),self:GetAbility()
    if slice<=0 or not valid(parent) or not parent:IsAlive() or not valid(c) or not valid(a) or parent:GetTeamNumber()==c:GetTeamNumber() or immune(parent) then return end
    local requested=self.dps*slice
    local actual=damage(a,parent,requested,DAMAGE_TYPE_MAGICAL) or 0
    self.requested_total=(self.requested_total or 0)+requested
    self.actual_total=(self.actual_total or 0)+actual
end
function modifier_enfos_jakiro_dual_breath_burn:OnCreated(params)
    if not IsServer() then return end
    self.closed=false;self.requested_total=0;self.actual_total=0
    self:Snapshot(params)
    self:SetHasCustomTransmitterData(true)
    self:GetParent():EmitSound('Hero_Jakiro.DualBreath.Burn')
    if self.closed then return end
    self:StartIntervalThink(0.5)
    HeroTrace:Log('JAKIRO','Q','burn_applied target=%s dps=%s',HeroTrace:Name(self:GetParent()),tostring(self.dps))
end
function modifier_enfos_jakiro_dual_breath_burn:OnRefresh(params)
    if not IsServer() or self.closed then return end
    self:DealThrough(self:GetElapsedTime())
    if self.closed then return end
    self:Snapshot(params)
    self:SendBuffRefreshToClients()
    HeroTrace:Log('JAKIRO','Q','burn_refreshed target=%s dps=%s',HeroTrace:Name(self:GetParent()),tostring(self.dps))
end
function modifier_enfos_jakiro_dual_breath_burn:OnIntervalThink()
    if not IsServer() or self.closed then return end
    local c,a,p=self:GetCaster(),self:GetAbility(),self:GetParent()
    if not valid(c) or not valid(a) or not valid(p) or not p:IsAlive() then self:Destroy();return end
    self:DealThrough(self:GetElapsedTime())
end
function modifier_enfos_jakiro_dual_breath_burn:OnDestroy()
    if not IsServer() or self.closed then return end
    self.closed=true
    self:StartIntervalThink(-1)
    if self.GetRemainingTime and self:GetRemainingTime()<=0 then self:DealThrough(self:GetElapsedTime()) end
    local p=self:GetParent()
    if valid(p) then p:StopSound('Hero_Jakiro.DualBreath.Burn') end
    HeroTrace:Log('JAKIRO','Q','burn_removed target=%s requested_total=%s actual_total=%s',
        HeroTrace:Name(p),tostring(self.requested_total or 0),tostring(self.actual_total or 0))
end
function modifier_enfos_jakiro_dual_breath_burn:AddCustomTransmitterData() return {dps=self.dps or 0} end
function modifier_enfos_jakiro_dual_breath_burn:HandleCustomTransmitterData(data) self.dps=tonumber(data and data.dps) or 0 end
function modifier_enfos_jakiro_dual_breath_burn:DeclareFunctions() return {MODIFIER_PROPERTY_TOOLTIP} end
function modifier_enfos_jakiro_dual_breath_burn:OnTooltip() return self.dps or 0 end
