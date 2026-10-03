-- Jakiro R: saved planar path with finite modifier-owned effect and ordinary damage.
local Helpers = require('abilities/shared/pve_helpers')
local value, get_int, damage = Helpers.value, Helpers.get_int, Helpers.damage
local HeroTrace = require('lib/hero_trace')
LinkLuaModifier('modifier_enfos_jakiro_macropyre_zone', 'abilities/heroes/jakiro/r', LUA_MODIFIER_MOTION_NONE)
local function valid(e) return e and not (e.IsNull and e:IsNull()) end
local function positive(a,key,fallback) local n=value(a,key);return n>0 and n or fallback end
local function immune(u) return (u.IsDebuffImmune and u:IsDebuffImmune()) or (u.IsMagicImmune and u:IsMagicImmune()) end

enfos_jakiro_macropyre=class({})
function enfos_jakiro_macropyre:OnSpellStart()
    if not IsServer() or not valid(self) or (self.GetLevel and self:GetLevel()<1) then return end
    local c=self:GetCaster()
    if not valid(c) or not c:IsAlive() then return end
    local origin=c:GetAbsOrigin()
    local dir=self:GetCursorPosition()-origin;dir.z=0
    if dir:Length2D()<1 then dir=c:GetForwardVector();dir.z=0 end
    if dir:Length2D()<1 then return end
    dir=dir:Normalized()
    local params={duration=positive(self,'duration',10),dir_x=dir.x,dir_y=dir.y,
        length=positive(self,'length',1400),radius=positive(self,'path_radius',250),
        interval=positive(self,'burn_interval',0.5),dps=value(self,'damage_per_sec')+get_int(c)*0.7}
    c:EmitSound('Hero_Jakiro.Macropyre.Cast')
    if not valid(self) or not valid(c) then return end
    Helpers.ground_effect(c,self,'modifier_enfos_jakiro_macropyre_zone',params,origin)
end

modifier_enfos_jakiro_macropyre_zone=class({})
function modifier_enfos_jakiro_macropyre_zone:IsHidden() return true end
function modifier_enfos_jakiro_macropyre_zone:IsPurgable() return false end
function modifier_enfos_jakiro_macropyre_zone:OnCreated(params)
    if not IsServer() then return end
    local c,a,parent=self:GetCaster(),self:GetAbility(),self:GetParent()
    if not valid(c) or not valid(a) or not valid(parent) then self:Destroy();return end
    params=params or {}
    self.closed=false;self.last_elapsed=0
    self.origin=parent:GetAbsOrigin()
    self.last=self.origin+Vector(tonumber(params.dir_x) or 1,tonumber(params.dir_y) or 0,0)*(tonumber(params.length) or 1400)
    self.radius=tonumber(params.radius) or positive(a,'path_radius',250)
    self.duration=tonumber(params.duration) or positive(a,'duration',10)
    self.tick=tonumber(params.interval) or positive(a,'burn_interval',0.5)
    self.dps=tonumber(params.dps) or (value(a,'damage_per_sec')+get_int(c)*0.7)
    self.particle=ParticleManager:CreateParticle('particles/units/heroes/hero_jakiro/jakiro_macropyre.vpcf',PATTACH_WORLDORIGIN,nil)
    ParticleManager:SetParticleControl(self.particle,0,self.origin)
    ParticleManager:SetParticleControl(self.particle,1,self.last)
    ParticleManager:SetParticleControl(self.particle,2,Vector(self.duration,0,0))
    ParticleManager:SetParticleControl(self.particle,4,Vector(self.radius,0,0))
    self:StartIntervalThink(self.tick)
    HeroTrace:Log('JAKIRO','R','path_created origin=%s end=%s radius=%s duration=%s dps=%s',
        tostring(self.origin),tostring(self.last),tostring(self.radius),tostring(self.duration),tostring(self.dps))
end
function modifier_enfos_jakiro_macropyre_zone:PulseThrough(elapsed)
    local stop=math.min(elapsed,self.duration)
    local slice=math.max(0,stop-self.last_elapsed)
    self.last_elapsed=stop
    if slice<=0 then return end
    local c,a,parent=self:GetCaster(),self:GetAbility(),self:GetParent()
    if not valid(c) or not valid(a) or not valid(parent) then return end
    local targets=FindUnitsInLine(c:GetTeamNumber(),self.origin,self.last,nil,self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_NONE) or {}
    for _,u in ipairs(targets) do
        if self.closed then return end
        if not valid(c) or not valid(a) or not valid(parent) then return end
        if valid(u) and u:IsAlive() and u:GetTeamNumber()~=c:GetTeamNumber() and not immune(u) then
            local requested=self.dps*slice
            local actual=damage(a,u,requested,DAMAGE_TYPE_MAGICAL) or 0
            self.requested_total=(self.requested_total or 0)+requested
            self.actual_total=(self.actual_total or 0)+actual
        end
    end
end
function modifier_enfos_jakiro_macropyre_zone:OnIntervalThink()
    if not IsServer() or self.closed then return end
    local c,a,parent=self:GetCaster(),self:GetAbility(),self:GetParent()
    if not valid(c) or not valid(a) or not valid(parent) then self:Destroy();return end
    local elapsed=self:GetElapsedTime()
    self:PulseThrough(elapsed)
    if elapsed>=self.duration and not self.closed then self:Destroy() end
end
function modifier_enfos_jakiro_macropyre_zone:OnDestroy()
    if not IsServer() or self.closed then return end
    -- Engine expiry can remove the modifier before its last scheduled pulse.
    if self.duration and self:GetElapsedTime()>=self.duration then self:PulseThrough(self:GetElapsedTime()) end
    if self.closed then return end
    self.closed=true;self:StartIntervalThink(-1)
    if self.particle then
        ParticleManager:DestroyParticle(self.particle,false)
        ParticleManager:ReleaseParticleIndex(self.particle)
        self.particle=nil
    end
    HeroTrace:Log('JAKIRO','R','path_removed requested_total=%s actual_total=%s',tostring(self.requested_total or 0),tostring(self.actual_total or 0))
    Helpers.remove_ground_effect(self)
end
