local Helpers=require('abilities/shared/pve_helpers')
local Trace=require('lib/hero_trace')
modifier_enfos_slark_native_scaling=class({})
local M=modifier_enfos_slark_native_scaling
function M:IsHidden() return true end
function M:IsPurgable() return false end
function M:RemoveOnDeath() return false end
function M:DeclareFunctions()
    return {MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE}
end
local essence_keys={agi_gain='bonus_agi',stat_loss='stat_loss',duration='duration',steal_radius='steal_radius'}
local function essence_query(params)
    local a=params and params.ability
    return a and not a:IsNull() and a:GetAbilityName()=='slark_essence_shift'
        and essence_keys[params.ability_special_value]
end
local function essence_paid(mod,params)
    local a=params and params.ability
    local key=params and essence_keys[params.ability_special_value]
    if not a or a:IsNull() or a:GetAbilityName()~='slark_essence_shift' or not key then return end
    local parent=mod:GetParent()
    if not parent or parent:IsNull() then return end
    local paid=parent:FindAbilityByName('enfos_slark_essence_shift')
    if paid and not paid:IsNull() then return paid,key end
end
local function matches(params)
    local a=params and params.ability
    return a and not a:IsNull() and a:GetAbilityName()=='enfos_slark_dark_pact'
        and params.ability_special_value=='total_damage'
end
function M:GetModifierOverrideAbilitySpecial(params)
    return (matches(params) or essence_query(params)) and 1 or 0
end
function M:GetModifierOverrideAbilitySpecialValue(params)
    local paid,key=essence_paid(self,params)
    if essence_query(params) then
        if not paid or paid:GetLevel()<1 then return 0 end
        return paid:GetLevelSpecialValueNoOverride(key,math.min(10,paid:GetLevel())-1)
    end
    if not matches(params) then return 0 end
    local a=params.ability
    if a:GetLevel()<1 then return 0 end
    local rank=math.min(10,a:GetLevel())-1
    return a:GetLevelSpecialValueNoOverride('total_damage',rank)
        +Helpers.get_agi(self:GetParent())*a:GetLevelSpecialValueNoOverride('agility_factor',rank)
end

-- Native owns hero essence. This bounded addition applies only to enemy creeps.
modifier_enfos_slark_essence_shift_passive=class({})
local E=modifier_enfos_slark_essence_shift_passive
function E:IsHidden() return true end
function E:IsPurgable() return false end
function E:RemoveOnDeath() return false end
function E:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end
function E:OnAttackLanded(params)
    if not IsServer() or not params then return end
    local c,a=self:GetParent(),self:GetAbility()
    if not c or c:IsNull() or not a or a:IsNull() or a:GetLevel()<1
        or params.attacker~=c or not c:IsRealHero() or c:IsIllusion()
        or c:PassivesDisabled() then return end
    local t=params.target
    if not t or t:IsNull() or t:IsHero() or not t:IsCreep()
        or t:GetTeamNumber()==c:GetTeamNumber() then return end
    local duration,cap=a:GetSpecialValueFor('duration'),a:GetSpecialValueFor('max_stacks')
    if duration<=0 or cap<1 then return end
    local buff=c:FindModifierByName('modifier_enfos_slark_essence_shift_buff')
    if not buff or buff:IsNull() then
        buff=c:AddNewModifier(c,a,'modifier_enfos_slark_essence_shift_buff',{duration=duration})
    end
    if not buff or buff:IsNull() then return end
    buff:SetStackCount(math.min(cap,buff:GetStackCount()+1))
    buff:SetDuration(duration,true)
    Helpers.effect('particles/units/heroes/hero_slark/slark_essence_shift_hit_glow.vpcf',t)
    Trace:Log('SLARK','E','creep_essence stacks=%s rank=%s',tostring(buff:GetStackCount()),tostring(a:GetLevel()))
end

modifier_enfos_slark_essence_shift_buff=class({})
local B=modifier_enfos_slark_essence_shift_buff
function B:IsPurgable() return false end
function B:GetTexture() return 'slark_essence_shift' end
function B:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS} end
function B:GetModifierBonusStats_Agility()
    local c,a=self:GetParent(),self:GetAbility()
    if not c or c:IsNull() or c:IsIllusion() or not a or a:IsNull() or a:GetLevel()<1 then return 0 end
    -- Break stops new gains; native Note4 preserves existing temporary bonuses.
    return math.min(self:GetStackCount(),a:GetSpecialValueFor('max_stacks'))*a:GetSpecialValueFor('bonus_agi')
end
