-- Jakiro E: isolated authored implementation; behavior unchanged in extraction.
local Helpers = require('abilities/shared/pve_helpers')
local value, enemies, is_boss, get_int, damage = Helpers.value, Helpers.enemies, Helpers.is_boss, Helpers.get_int, Helpers.damage
local effect, ground_effect, remove_ground_effect = Helpers.effect, Helpers.ground_effect, Helpers.remove_ground_effect
LinkLuaModifier('modifier_enfos_jakiro_liquid_fire_slow', 'abilities/heroes/jakiro/e', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_enfos_jakiro_liquid_fire_passive', 'abilities/heroes/jakiro/e', LUA_MODIFIER_MOTION_NONE)

enfos_jakiro_liquid_fire=class({})
function enfos_jakiro_liquid_fire:GetIntrinsicModifierName() return 'modifier_enfos_jakiro_liquid_fire_passive' end
function enfos_jakiro_liquid_fire:OnSpellStart()
    local target=self:GetCursorTarget()
    if target and not target:IsNull() and not target:TriggerSpellAbsorb(self) then self:FireAt(target) end
end
function enfos_jakiro_liquid_fire:FireAt(target)
    if not IsServer() or not target or target:IsNull() then return end
    local c=self:GetCaster()
    if target:GetTeamNumber()==c:GetTeamNumber() then return end
    target:EmitSound('Hero_Jakiro.LiquidFire')
    effect('particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf', target)
    for _,u in ipairs(enemies(c,target:GetAbsOrigin(),value(self,'radius'))) do
        damage(self,u,value(self,'bonus_damage')+get_int(c)*0.3,DAMAGE_TYPE_MAGICAL)
        u:AddNewModifier(c,self,'modifier_enfos_jakiro_liquid_fire_slow',{duration=4})
    end
end

modifier_enfos_jakiro_liquid_fire_slow=class({})
function modifier_enfos_jakiro_liquid_fire_slow:IsDebuff() return true end
function modifier_enfos_jakiro_liquid_fire_slow:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_enfos_jakiro_liquid_fire_slow:GetModifierAttackSpeedBonus_Constant() return -value(self:GetAbility(),'slow_as') end

modifier_enfos_jakiro_liquid_fire_passive=class({})
function modifier_enfos_jakiro_liquid_fire_passive:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_enfos_jakiro_liquid_fire_passive:OnAttackLanded(params)
    if not IsServer() then return end
    local c,a=self:GetParent(),self:GetAbility()
    if params.attacker~=c or c:PassivesDisabled() or c:IsIllusion() or not params.target
        or params.target:GetTeamNumber()==c:GetTeamNumber() then return end
    if not a or a:GetLevel()<1 or not a:GetAutoCastState() or not a:IsCooldownReady() then return end
    a:UseResources(false,false,false,true)
    a:FireAt(params.target)
end
