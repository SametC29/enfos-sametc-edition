-- Jakiro E: impact-snapshotted periodic Liquid Fire, with ordinary resource rules.
local Helpers = require('abilities/shared/pve_helpers')
local value, get_int, damage = Helpers.value, Helpers.get_int, Helpers.damage
local effect = Helpers.effect
local HeroTrace = require('lib/hero_trace')
LinkLuaModifier('modifier_enfos_jakiro_liquid_fire_slow', 'abilities/heroes/jakiro/e', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_enfos_jakiro_liquid_fire_passive', 'abilities/heroes/jakiro/e', LUA_MODIFIER_MOTION_NONE)
local function valid(entity) return entity and not (entity.IsNull and entity:IsNull()) end
local function enemy(c,target) return valid(c) and valid(target) and target:GetTeamNumber()~=c:GetTeamNumber() end
local function positive(a,key,fallback) local n=value(a,key);return n>0 and n or fallback end
local function immune(target) return (target.IsDebuffImmune and target:IsDebuffImmune()) or (target.IsMagicImmune and target:IsMagicImmune()) end

enfos_jakiro_liquid_fire=class({})
function enfos_jakiro_liquid_fire:GetIntrinsicModifierName() return 'modifier_enfos_jakiro_liquid_fire_passive' end
function enfos_jakiro_liquid_fire:OnSpellStart()
    if not IsServer() or not valid(self) or (self.GetLevel and self:GetLevel()<1) then return end
    local c,target=self:GetCaster(),self:GetCursorTarget()
    if not enemy(c,target) or not c:IsAlive() or not target:IsAlive() then return end
    if target.TriggerSpellAbsorb and target:TriggerSpellAbsorb(self) then
        HeroTrace:Log('JAKIRO','E','manual_cancelled reason=spell_absorb')
        return
    end
    -- Spell block may synchronously remove a unit/ability even when returning false.
    if not valid(self) or not enemy(c,target) or not c:IsAlive() or not target:IsAlive() then return end
    self:FireAt(target) -- Manual casting is already funded by the engine.
end
function enfos_jakiro_liquid_fire:FireAt(target)
    if not IsServer() or not valid(self) then return false end
    local c=self:GetCaster()
    if not enemy(c,target) then return false end
    -- An attack can kill its target before OnAttackLanded. Keep its valid corpse
    -- position for the area impact; do not invent a lethal-hit exclusion.
    local origin=target:GetAbsOrigin()
    local radius,total,slow=value(self,'radius'),value(self,'bonus_damage')+get_int(c)*0.3,value(self,'slow_as')
    local duration,tick=positive(self,'duration',5),positive(self,'tick_rate',0.5)
    local building_pct=positive(self,'building_dmg_pct',75)
    target:EmitSound('Hero_Jakiro.LiquidFire')
    if not valid(self) or not enemy(c,target) then return false end
    effect('particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf',target)
    if not valid(self) or not valid(c) then return false end
    local targets=FindUnitsInRadius(c:GetTeamNumber(),origin,nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_BUILDING,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
    for _,u in ipairs(targets) do
        if not valid(self) or not valid(c) then break end
        if enemy(c,u) and u:IsAlive() and not immune(u) then
            local dps=total/duration
            if u.IsBuilding and u:IsBuilding() then dps=dps*building_pct/100 end
            u:AddNewModifier(c,self,'modifier_enfos_jakiro_liquid_fire_slow',{
                duration=duration,slow_as=slow,dps=dps,tick_rate=tick})
            HeroTrace:Log('JAKIRO','E','impact target=%s burn_dps=%s duration=%s attack_slow=%s',
                HeroTrace:Name(u),tostring(dps),tostring(duration),tostring(slow))
        end
    end
    return true
end

modifier_enfos_jakiro_liquid_fire_slow=class({})
function modifier_enfos_jakiro_liquid_fire_slow:IsDebuff() return true end
function modifier_enfos_jakiro_liquid_fire_slow:IsPurgable() return true end
function modifier_enfos_jakiro_liquid_fire_slow:GetTexture() return 'jakiro_liquid_fire' end
function modifier_enfos_jakiro_liquid_fire_slow:GetEffectName() return 'particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf' end
function modifier_enfos_jakiro_liquid_fire_slow:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_enfos_jakiro_liquid_fire_slow:ReadApplication(params)
    local a=self:GetAbility()
    local slow=tonumber(params and params.slow_as)
    if slow==nil then slow=valid(a) and value(a,'slow_as') or 0 end
    self.slow=math.max(0,slow)
    self.dps=math.max(0,tonumber(params and params.dps) or 0)
    self.last_elapsed=self:GetElapsedTime()
    self.elapsed_limit=self.last_elapsed+(self.GetRemainingTime and math.max(0,self:GetRemainingTime()) or tonumber(params and params.duration) or 5)
    self.tick=math.max(0.1,tonumber(params and params.tick_rate) or 0.5)
end
function modifier_enfos_jakiro_liquid_fire_slow:DealThrough(elapsed)
    local stop=math.min(elapsed,self.elapsed_limit or elapsed)
    local slice=math.max(0,stop-(self.last_elapsed or stop))
    self.last_elapsed=stop -- Advance before callbacks; no recursive or immunity catch-up payout.
    local p,c,a=self:GetParent(),self:GetCaster(),self:GetAbility()
    if slice<=0 or not enemy(c,p) or not valid(a) or not p:IsAlive() or immune(p) then return end
    local requested=self.dps*slice
    local actual=damage(a,p,requested,DAMAGE_TYPE_MAGICAL) or 0
    self.requested_total=(self.requested_total or 0)+requested
    self.actual_total=(self.actual_total or 0)+actual
end
function modifier_enfos_jakiro_liquid_fire_slow:OnCreated(params)
    if not IsServer() then return end
    self.closed=false;self.requested_total=0;self.actual_total=0
    self:ReadApplication(params);self:SetHasCustomTransmitterData(true)
    self:StartIntervalThink(self.tick)
    HeroTrace:Log('JAKIRO','E','burn_applied target=%s attack_slow=%s dps=%s',HeroTrace:Name(self:GetParent()),tostring(self.slow),tostring(self.dps))
end
function modifier_enfos_jakiro_liquid_fire_slow:OnRefresh(params)
    if not IsServer() or self.closed then return end
    self:DealThrough(self:GetElapsedTime())
    if self.closed then return end
    local c,a,p=self:GetCaster(),self:GetAbility(),self:GetParent()
    if not valid(c) or not valid(a) or not valid(p) or not p:IsAlive() then self:Destroy();return end
    self:ReadApplication(params);self:StartIntervalThink(self.tick);self:SendBuffRefreshToClients()
    HeroTrace:Log('JAKIRO','E','burn_refreshed target=%s attack_slow=%s dps=%s',HeroTrace:Name(p),tostring(self.slow),tostring(self.dps))
end
function modifier_enfos_jakiro_liquid_fire_slow:OnIntervalThink()
    if not IsServer() or self.closed then return end
    local c,a,p=self:GetCaster(),self:GetAbility(),self:GetParent()
    if not valid(c) or not valid(a) or not valid(p) or not p:IsAlive() then self:Destroy();return end
    self:DealThrough(self:GetElapsedTime())
end
function modifier_enfos_jakiro_liquid_fire_slow:AddCustomTransmitterData() return {slow=self.slow or 0,dps=self.dps or 0} end
function modifier_enfos_jakiro_liquid_fire_slow:HandleCustomTransmitterData(data)
    self.slow=tonumber(data and data.slow) or 0;self.dps=tonumber(data and data.dps) or 0
end
function modifier_enfos_jakiro_liquid_fire_slow:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_TOOLTIP,MODIFIER_PROPERTY_TOOLTIP2} end
function modifier_enfos_jakiro_liquid_fire_slow:GetModifierAttackSpeedBonus_Constant()
    local p=self:GetParent();return valid(p) and not immune(p) and -(self.slow or 0) or 0
end
function modifier_enfos_jakiro_liquid_fire_slow:OnTooltip() return self.slow or 0 end
function modifier_enfos_jakiro_liquid_fire_slow:OnTooltip2() return self.dps or 0 end
function modifier_enfos_jakiro_liquid_fire_slow:OnDestroy()
    if not IsServer() or self.closed then return end
    self.closed=true;self:StartIntervalThink(-1)
    -- Early dispel/death cancels remaining damage; expiry settles the final partial interval.
    if self.GetRemainingTime and self:GetRemainingTime()<=0 then self:DealThrough(self:GetElapsedTime()) end
    HeroTrace:Log('JAKIRO','E','burn_removed target=%s requested_total=%s actual_total=%s',
        HeroTrace:Name(self:GetParent()),tostring(self.requested_total or 0),tostring(self.actual_total or 0))
end

modifier_enfos_jakiro_liquid_fire_passive=class({})
function modifier_enfos_jakiro_liquid_fire_passive:IsHidden() return true end
function modifier_enfos_jakiro_liquid_fire_passive:IsPurgable() return false end
function modifier_enfos_jakiro_liquid_fire_passive:IsPurgeException() return false end
function modifier_enfos_jakiro_liquid_fire_passive:RemoveOnDeath() return false end
function modifier_enfos_jakiro_liquid_fire_passive:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_enfos_jakiro_liquid_fire_passive:OnAttackLanded(params)
    if not IsServer() or not params or self.proccing then return end
    local c,a=self:GetParent(),self:GetAbility()
    if not valid(c) or not valid(a) or params.attacker~=c or not enemy(c,params.target) then return end
    if c:PassivesDisabled() or c:IsIllusion() or a:GetLevel()<1 or not a:GetAutoCastState() then return end
    if not a.IsFullyCastable or not a:IsFullyCastable() then return end
    self.proccing=true
    a:UseResources(true,false,false,true)
    self.proccing=false
    -- Resource hooks can invalidate owners; FireAt validates everything again.
    if not valid(a) or not enemy(c,params.target) then return end
    HeroTrace:Log('JAKIRO','E','autocast_resources mana=true cooldown=true target=%s',HeroTrace:Name(params.target))
    a:FireAt(params.target)
end
