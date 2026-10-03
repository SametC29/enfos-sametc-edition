-- Jakiro E: existing authored impact, with explicit resource and callback safety.
local Helpers = require('abilities/shared/pve_helpers')
local value, enemies, get_int, damage = Helpers.value, Helpers.enemies, Helpers.get_int, Helpers.damage
local effect = Helpers.effect
local HeroTrace = require('lib/hero_trace')
LinkLuaModifier('modifier_enfos_jakiro_liquid_fire_slow', 'abilities/heroes/jakiro/e', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_enfos_jakiro_liquid_fire_passive', 'abilities/heroes/jakiro/e', LUA_MODIFIER_MOTION_NONE)
local function valid(entity) return entity and not (entity.IsNull and entity:IsNull()) end
local function enemy(c,target) return valid(c) and valid(target) and target:GetTeamNumber()~=c:GetTeamNumber() end
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
    target:EmitSound('Hero_Jakiro.LiquidFire')
    if not valid(self) or not enemy(c,target) then return false end
    effect('particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf',target)
    if not valid(self) or not valid(c) then return false end
    for _,u in ipairs(enemies(c,origin,radius)) do
        if not valid(self) or not valid(c) then break end
        if enemy(c,u) and u:IsAlive() and not immune(u) then
            local actual=damage(self,u,total,DAMAGE_TYPE_MAGICAL)
            if valid(self) and enemy(c,u) and u:IsAlive() and not immune(u) then
                u:AddNewModifier(c,self,'modifier_enfos_jakiro_liquid_fire_slow',{duration=4,slow_as=slow})
            end
            HeroTrace:Log('JAKIRO','E','impact target=%s requested_damage=%s actual_damage=%s attack_slow=%s',
                HeroTrace:Name(u),tostring(total),tostring(actual),tostring(slow))
        end
    end
    return true
end

modifier_enfos_jakiro_liquid_fire_slow=class({})
function modifier_enfos_jakiro_liquid_fire_slow:IsDebuff() return true end
function modifier_enfos_jakiro_liquid_fire_slow:IsPurgable() return true end
function modifier_enfos_jakiro_liquid_fire_slow:GetTexture() return 'jakiro_liquid_fire' end
function modifier_enfos_jakiro_liquid_fire_slow:ReadApplication(params)
    local a=self:GetAbility()
    local slow=tonumber(params and params.slow_as)
    if slow==nil then slow=valid(a) and value(a,'slow_as') or 0 end
    self.slow=math.max(0,slow)
end
function modifier_enfos_jakiro_liquid_fire_slow:OnCreated(params)
    if not IsServer() then return end
    self:ReadApplication(params);self:SetHasCustomTransmitterData(true)
    HeroTrace:Log('JAKIRO','E','slow_applied target=%s attack_slow=%s',HeroTrace:Name(self:GetParent()),tostring(self.slow))
end
function modifier_enfos_jakiro_liquid_fire_slow:OnRefresh(params)
    if not IsServer() then return end
    self:ReadApplication(params);self:SendBuffRefreshToClients()
    HeroTrace:Log('JAKIRO','E','slow_refreshed target=%s attack_slow=%s',HeroTrace:Name(self:GetParent()),tostring(self.slow))
end
function modifier_enfos_jakiro_liquid_fire_slow:AddCustomTransmitterData() return {slow=self.slow or 0} end
function modifier_enfos_jakiro_liquid_fire_slow:HandleCustomTransmitterData(data) self.slow=tonumber(data and data.slow) or 0 end
function modifier_enfos_jakiro_liquid_fire_slow:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_TOOLTIP} end
function modifier_enfos_jakiro_liquid_fire_slow:GetModifierAttackSpeedBonus_Constant()
    local p=self:GetParent();return valid(p) and not immune(p) and -(self.slow or 0) or 0
end
function modifier_enfos_jakiro_liquid_fire_slow:OnTooltip() return self.slow or 0 end
function modifier_enfos_jakiro_liquid_fire_slow:OnDestroy()
    HeroTrace:Log('JAKIRO','E','slow_removed target=%s',HeroTrace:Name(self:GetParent()))
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
