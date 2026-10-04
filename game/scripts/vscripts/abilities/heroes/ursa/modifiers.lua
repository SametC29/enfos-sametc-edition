-- Native abilities own combat; these supply paid tuning and mobility.
modifier_enfos_ursa_native_scaling=class({})
local M=modifier_enfos_ursa_native_scaling
function M:IsHidden() return true end
function M:IsPurgable() return false end
function M:RemoveOnDeath() return false end
function M:DeclareFunctions()
    return {MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,MODIFIER_EVENT_ON_ATTACK_RECORD,
        MODIFIER_EVENT_ON_ATTACK_LANDED,MODIFIER_EVENT_ON_ATTACK_FAIL,
        MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,MODIFIER_EVENT_ON_DEATH}
end
function M:OnAttackRecord(p) if IsServer() then require('abilities/heroes/ursa/w_heal').Record(self,p) end end
function M:OnAttackLanded(p) if IsServer() then require('abilities/heroes/ursa/w_heal').Landed(self,p) end end
function M:OnAttackFail(p) if IsServer() then require('abilities/heroes/ursa/w_heal').Forget(self,p) end end
function M:OnAttackRecordDestroy(p) if IsServer() then require('abilities/heroes/ursa/w_heal').Forget(self,p) end end
function M:OnDeath(p) if IsServer() then require('abilities/heroes/ursa/w_heal').Death(self,p) end end
local keys={['damage_per_stack']=true,['bonus_reset_time']=true,['bonus_reset_time_roshan']=true,
    ['stun_stack_count']=true,['stun_duration']=true}
local enrage_keys={['duration']=true,['damage_reduction']=true,['status_resistance']=true,
    ['aoe_radius']=true,['damage_increase']=true,['damage_increase_duration']=true}
local function sources(mod,params)
    local c,a=mod:GetParent(),params and params.ability
    if not c or c:IsNull() or c:GetUnitName()~='npc_dota_hero_ursa' or not a or a:IsNull()
        or a:GetCaster()~=c then return end
    local id,key=a:GetAbilityName(),params.ability_special_value
    local paid
    if id=='ursa_fury_swipes' and keys[key] then paid=c:FindAbilityByName('enfos_ursa_fury_swipes')
    elseif id=='ursa_enrage' and enrage_keys[key] then paid=c:FindAbilityByName('enfos_ursa_enrage') end
    if not paid or paid:IsNull() then return end
    return c,paid
end
-- Header AbilityDamage is server-only and distinct from special values.
function M:GetModifierTotalDamageOutgoing_Percentage(params)
    if not IsServer() or not params then return 0 end
    local c,a=self:GetParent(),params.inflictor
    if not c or c:IsNull() or c:GetUnitName()~='npc_dota_hero_ursa' or c:IsIllusion() or not a or a:IsNull()
        or a:GetAbilityName()~='enfos_ursa_earthshock' or a:GetCaster()~=c or a:GetLevel()<1 then return 0 end
    local base=a:GetAbilityDamage()
    if base<=0 then return 0 end
    local strength=c:GetStrength()
    local pct=100*strength*a:GetSpecialValueFor('strength_factor')/base
    require('lib/hero_trace'):Log('URSA','Q','native_outgoing_query base=%s str=%s percent=%s original=%s',
        tostring(base),tostring(strength),tostring(pct),tostring(params.original_damage))
    return pct
end
function M:GetModifierOverrideAbilitySpecial(params)
    return sources(self,params) and 1 or 0
end
function M:GetModifierOverrideAbilitySpecialValue(params)
    local c,paid=sources(self,params)
    if not c or paid:GetLevel()<1 then return 0 end
    local key,rank=params.ability_special_value,math.min(10,paid:GetLevel())-1
    local base=paid:GetLevelSpecialValueNoOverride(key,rank)
    -- Break ownership is native: existing stacks retain their effects.
    if key=='damage_per_stack' then
        return base+c:GetAgility()*paid:GetLevelSpecialValueNoOverride('agility_factor',rank)
    end
    return base
end

modifier_enfos_ursa_minor_passive=class({})
function modifier_enfos_ursa_minor_passive:IsHidden() return true end
function modifier_enfos_ursa_minor_passive:IsPurgable() return false end
function modifier_enfos_ursa_minor_passive:RemoveOnDeath() return false end
function modifier_enfos_ursa_minor_passive:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT} end
function modifier_enfos_ursa_minor_passive:GetModifierMoveSpeedBonus_Constant()
    local c,a=self:GetParent(),self:GetAbility()
    if not c or c:IsNull() or c:IsIllusion() or c:PassivesDisabled() or not a or a:IsNull() or a:GetLevel()<1 then return 0 end
    return a:GetSpecialValueFor('bonus_ms')
end
