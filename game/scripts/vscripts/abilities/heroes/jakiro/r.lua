-- Jakiro R: saved planar path with finite modifier-owned effect and ordinary damage.
local Helpers = require('abilities/shared/pve_helpers')
local value, get_int, damage = Helpers.value, Helpers.get_int, Helpers.damage
local HeroTrace = require('lib/hero_trace')
LinkLuaModifier('modifier_enfos_jakiro_macropyre_zone', 'abilities/heroes/jakiro/r', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_enfos_jakiro_macropyre_burn', 'abilities/heroes/jakiro/r', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_enfos_jakiro_macropyre_ice_slow', 'abilities/heroes/jakiro/r', LUA_MODIFIER_MOTION_NONE)
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
    local scepter=require('heroes/aghanim_manager'):HasScepter(c)
    local params={pierce=scepter and 1 or 0,damage_type=scepter and DAMAGE_TYPE_PURE or DAMAGE_TYPE_MAGICAL,duration=positive(self,'duration',10)+(scepter and positive(self,'scepter_duration_bonus',5) or 0),dir_x=dir.x,dir_y=dir.y,
        length=positive(self,'length',1400),radius=positive(self,'path_radius',250),
        linger=positive(self,'linger_duration',1),interval=positive(self,'burn_interval',0.5),dps=value(self,'damage_per_sec')+get_int(c)*0.7}
    if scepter then
        params.edge_radius=positive(self,'ice_edge_path_radius',50)
        params.edge_offset=positive(self,'ice_edge_path_offset',20)
        params.edge_linger=positive(self,'ice_edge_linger_duration',0.4)
        params.edge_slow=positive(self,'ice_edge_movement_slow',60)
    end
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
    self.closed=false
    self.pierce=tonumber(params.pierce)==1
    self.damage_type=tonumber(params.damage_type) or DAMAGE_TYPE_MAGICAL
    self.origin=parent:GetAbsOrigin()
    self.last=self.origin+Vector(tonumber(params.dir_x) or 1,tonumber(params.dir_y) or 0,0)*(tonumber(params.length) or 1400)
    self.radius=tonumber(params.radius) or positive(a,'path_radius',250)
    self.duration=tonumber(params.duration) or positive(a,'duration',10)
    self.tick=tonumber(params.interval) or positive(a,'burn_interval',0.5)
    self.linger=tonumber(params.linger) or positive(a,'linger_duration',1)
    self.dps=tonumber(params.dps) or (value(a,'damage_per_sec')+get_int(c)*0.7)
    self.particle=ParticleManager:CreateParticle('particles/units/heroes/hero_jakiro/jakiro_macropyre.vpcf',PATTACH_WORLDORIGIN,nil)
    ParticleManager:SetParticleControl(self.particle,0,self.origin)
    ParticleManager:SetParticleControl(self.particle,1,self.last)
    ParticleManager:SetParticleControl(self.particle,2,Vector(self.duration,0,0))
    ParticleManager:SetParticleControl(self.particle,4,Vector(self.radius,0,0))
    self.edges={};self.next_fire=0
    self.edge_radius=math.max(0,tonumber(params.edge_radius) or 0)
    self.edge_linger=tonumber(params.edge_linger) or 0.4
    self.edge_slow=tonumber(params.edge_slow) or 60
    if self.edge_radius>0 then
        local direction=(self.last-self.origin):Normalized()
        local normal=Vector(-direction.y,direction.x,0)
        local offset=self.radius+(tonumber(params.edge_offset) or 20)
        for _,side in ipairs({1,-1}) do
            local first,last=self.origin+normal*(offset*side),self.last+normal*(offset*side)
            local particle=ParticleManager:CreateParticle('particles/units/heroes/hero_jakiro/jakiro_macropyre_ice_edge.vpcf',PATTACH_WORLDORIGIN,nil)
            self.edges[#self.edges+1]={first=first,last=last,particle=particle}
            ParticleManager:SetParticleControl(particle,0,first)
            ParticleManager:SetParticleControl(particle,1,last)
            ParticleManager:SetParticleControl(particle,2,Vector(self.duration,0,0))
        end
    end
    self:StartIntervalThink(self.edge_radius>0 and 0.1 or self.tick)
    HeroTrace:Log('JAKIRO','R','path_created origin=%s end=%s radius=%s duration=%s dps=%s type=%s pierce=%s',
        tostring(self.origin),tostring(self.last),tostring(self.radius),tostring(self.duration),tostring(self.dps),tostring(self.damage_type),tostring(self.pierce))
    self:OnIntervalThink()
end
function modifier_enfos_jakiro_macropyre_zone:OnIntervalThink()
    if not IsServer() or self.closed then return end
    local c,a,parent=self:GetCaster(),self:GetAbility(),self:GetParent()
    if not valid(c) or not valid(a) or not valid(parent) then self:Destroy();return end
    if self:GetElapsedTime()>=self.duration then self:Destroy();return end
    if self:GetElapsedTime()+0.000001>=self.next_fire then
        self.next_fire=self:GetElapsedTime()+self.tick
        local targets=FindUnitsInLine(c:GetTeamNumber(),self.origin,self.last,nil,self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,self.pierce and DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES or DOTA_UNIT_TARGET_FLAG_NONE) or {}
        for _,u in ipairs(targets) do
            if self.closed then return end
            if not valid(c) or not valid(a) or not valid(parent) then self:Destroy();return end
            if valid(u) and u:IsAlive() and u:GetTeamNumber()~=c:GetTeamNumber() and (self.pierce or not immune(u)) then
                u:AddNewModifier(c,a,'modifier_enfos_jakiro_macropyre_burn',{duration=self.linger,dps=self.dps,interval=self.tick,damage_type=self.damage_type,pierce=self.pierce and 1 or 0})
            end
        end
    end
    self:ApplyEdges(c,a,parent)
end
function modifier_enfos_jakiro_macropyre_zone:ApplyEdges(c,a,parent)
    for _,edge in ipairs(self.edges or {}) do
        if self.closed then return end
        if not valid(c) or not valid(a) or not valid(parent) then self:Destroy();return end
        local targets=FindUnitsInLine(c:GetTeamNumber(),edge.first,edge.last,nil,self.edge_radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES) or {}
        for _,u in ipairs(targets) do
            if self.closed then return end
            if not valid(c) or not valid(a) or not valid(parent) then self:Destroy();return end
            if valid(u) and u:IsAlive() and u:GetTeamNumber()~=c:GetTeamNumber() then
                u:AddNewModifier(c,a,'modifier_enfos_jakiro_macropyre_ice_slow',{duration=self.edge_linger,slow=self.edge_slow})
            end
        end
    end
end
function modifier_enfos_jakiro_macropyre_zone:OnDestroy()
    if not IsServer() or self.closed then return end
    self.closed=true;self:StartIntervalThink(-1)
    if self.particle then
        ParticleManager:DestroyParticle(self.particle,false)
        ParticleManager:ReleaseParticleIndex(self.particle)
        self.particle=nil
    end
    for _,edge in ipairs(self.edges or {}) do
        if edge.particle then
            ParticleManager:DestroyParticle(edge.particle,false)
            ParticleManager:ReleaseParticleIndex(edge.particle)
            edge.particle=nil
        end
    end
    self.edges={}
    HeroTrace:Log('JAKIRO','R','path_removed')
    Helpers.remove_ground_effect(self)
end

modifier_enfos_jakiro_macropyre_burn=class({})
function modifier_enfos_jakiro_macropyre_burn:IsDebuff() return true end
function modifier_enfos_jakiro_macropyre_burn:IsPurgable() return false end
function modifier_enfos_jakiro_macropyre_burn:IsPurgeException() return false end
function modifier_enfos_jakiro_macropyre_burn:GetTexture() return 'jakiro_macropyre' end
function modifier_enfos_jakiro_macropyre_burn:GetEffectName() return 'particles/units/heroes/hero_jakiro/jakiro_macropyre_firehit.vpcf' end
function modifier_enfos_jakiro_macropyre_burn:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_enfos_jakiro_macropyre_burn:ExtendExpiry(params)
    local elapsed=self:GetElapsedTime()
    self.elapsed_limit=elapsed+(self.GetRemainingTime and math.max(0,self:GetRemainingTime()) or tonumber(params and params.duration) or 1)
end
function modifier_enfos_jakiro_macropyre_burn:DealThrough(elapsed)
    local stop=math.min(elapsed,self.elapsed_limit or elapsed)
    local slice=math.max(0,stop-(self.last_elapsed or stop))
    self.last_elapsed=stop
    local p,c,a=self:GetParent(),self:GetCaster(),self:GetAbility()
    if slice<=0 or not valid(p) or not valid(c) or not valid(a) or not p:IsAlive() or p:GetTeamNumber()==c:GetTeamNumber() or (not self.pierce and immune(p)) then return end
    local requested=(self.dps or 0)*slice
    local actual=damage(a,p,requested,self.damage_type or DAMAGE_TYPE_MAGICAL) or 0
    self.requested_total=(self.requested_total or 0)+requested
    self.actual_total=(self.actual_total or 0)+actual
end
function modifier_enfos_jakiro_macropyre_burn:OnCreated(params)
    if not IsServer() then return end
    self.closed=false;self.dps=math.max(0,tonumber(params and params.dps) or 0)
    self.damage_type=tonumber(params and params.damage_type) or DAMAGE_TYPE_MAGICAL
    self.pierce=tonumber(params and params.pierce)==1
    self.last_elapsed=self:GetElapsedTime();self:ExtendExpiry(params)
    self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(math.max(0.1,tonumber(params and params.interval) or 0.5))
    HeroTrace:Log('JAKIRO','R','burn_applied target=%s dps=%s type=%s pierce=%s',HeroTrace:Name(self:GetParent()),tostring(self.dps),tostring(self.damage_type),tostring(self.pierce))
end
function modifier_enfos_jakiro_macropyre_burn:OnRefresh(params)
    if not IsServer() or self.closed then return end
    local c,a,p=self:GetCaster(),self:GetAbility(),self:GetParent()
    if not valid(c) or not valid(a) or not valid(p) or not p:IsAlive() then self:Destroy();return end
    local dps=math.max(0,tonumber(params and params.dps) or self.dps)
    local kind=tonumber(params and params.damage_type) or DAMAGE_TYPE_MAGICAL
    local pierce=tonumber(params and params.pierce)==1
    if dps~=self.dps or kind~=self.damage_type or pierce~=self.pierce then
        self:DealThrough(self:GetElapsedTime())
        if self.closed then return end
        if not valid(c) or not valid(a) or not valid(p) or not p:IsAlive() then self:Destroy();return end
        self.dps=dps;self.damage_type=kind;self.pierce=pierce;self.last_elapsed=self:GetElapsedTime()
        self:SendBuffRefreshToClients()
    end
    -- Reapplying the same burn never restarts its tick or grants an extra burst.
    self:ExtendExpiry(params)
end
function modifier_enfos_jakiro_macropyre_burn:OnIntervalThink()
    if not IsServer() or self.closed then return end
    local c,a,p=self:GetCaster(),self:GetAbility(),self:GetParent()
    if not valid(c) or not valid(a) or not valid(p) or not p:IsAlive() then self:Destroy();return end
    self:DealThrough(self:GetElapsedTime())
end
function modifier_enfos_jakiro_macropyre_burn:OnDestroy()
    if not IsServer() or self.closed then return end
    self.closed=true;self:StartIntervalThink(-1)
    if self.elapsed_limit and self.GetRemainingTime and self:GetRemainingTime()<=0 then self:DealThrough(self:GetElapsedTime()) end
    HeroTrace:Log('JAKIRO','R','burn_removed target=%s requested_total=%s actual_total=%s',
        HeroTrace:Name(self:GetParent()),tostring(self.requested_total or 0),tostring(self.actual_total or 0))
end
function modifier_enfos_jakiro_macropyre_burn:AddCustomTransmitterData() return {dps=self.dps or 0} end
function modifier_enfos_jakiro_macropyre_burn:HandleCustomTransmitterData(data) self.dps=tonumber(data and data.dps) or 0 end
function modifier_enfos_jakiro_macropyre_burn:DeclareFunctions() return {MODIFIER_PROPERTY_TOOLTIP} end
function modifier_enfos_jakiro_macropyre_burn:OnTooltip() return self.dps or 0 end

modifier_enfos_jakiro_macropyre_ice_slow=class({})
function modifier_enfos_jakiro_macropyre_ice_slow:IsDebuff() return true end
function modifier_enfos_jakiro_macropyre_ice_slow:IsPurgable() return false end
function modifier_enfos_jakiro_macropyre_ice_slow:IsPurgeException() return false end
function modifier_enfos_jakiro_macropyre_ice_slow:GetTexture() return 'jakiro_macropyre' end
function modifier_enfos_jakiro_macropyre_ice_slow:OnCreated(params)
    if not IsServer() then return end
    self.slow=math.max(0,tonumber(params and params.slow) or 0)
    self:SetHasCustomTransmitterData(true)
    HeroTrace:Log('JAKIRO','R','ice_slow_applied target=%s slow=%s',HeroTrace:Name(self:GetParent()),tostring(self.slow))
end
function modifier_enfos_jakiro_macropyre_ice_slow:OnRefresh(params)
    if not IsServer() then return end
    local slow=math.max(0,tonumber(params and params.slow) or self.slow or 0)
    if slow~=self.slow then self.slow=slow;self:SendBuffRefreshToClients() end
end
function modifier_enfos_jakiro_macropyre_ice_slow:AddCustomTransmitterData() return {slow=self.slow or 0} end
function modifier_enfos_jakiro_macropyre_ice_slow:HandleCustomTransmitterData(data) self.slow=tonumber(data and data.slow) or 0 end
function modifier_enfos_jakiro_macropyre_ice_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,MODIFIER_PROPERTY_TOOLTIP} end
function modifier_enfos_jakiro_macropyre_ice_slow:GetModifierMoveSpeedBonus_Percentage()
    local p,c,a=self:GetParent(),self:GetCaster(),self:GetAbility()
    return valid(p) and valid(c) and valid(a) and p:IsAlive() and -(self.slow or 0) or 0
end
function modifier_enfos_jakiro_macropyre_ice_slow:OnTooltip() return self.slow or 0 end
function modifier_enfos_jakiro_macropyre_ice_slow:OnDestroy()
    if IsServer() then HeroTrace:Log('JAKIRO','R','ice_slow_removed target=%s',HeroTrace:Name(self:GetParent())) end
end
