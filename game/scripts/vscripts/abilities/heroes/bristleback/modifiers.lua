-- Engine special-value bridge only; no replica damage, projectile or debuff.
modifier_enfos_bb_native_scaling=class({})
local M=modifier_enfos_bb_native_scaling
function M:IsHidden() return true end
function M:IsPurgable() return false end
function M:RemoveOnDeath() return false end
function M:DeclareFunctions()
    return {MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end
local routes={
    bristleback_viscous_nasal_goo={'enfos_bb_viscous_nasal_goo',{
        goo_duration='duration',armor_per_stack='armor_reduction',base_move_slow='base_slow_pct',
        move_slow_per_stack='slow_per_stack',stack_limit='max_stacks',AbilityCastRange='AbilityCastRange',base_armor=false}},
    bristleback_quill_spray={'enfos_bb_quill_spray',{
        radius='radius',quill_base_damage='base_damage',quill_stack_damage='stack_damage',
        quill_stack_duration='debuff_duration',max_damage='max_damage'}},
    bristleback_bristleback={'enfos_bb_bristleback',{
        side_damage_reduction='side_damage_reduction',back_damage_reduction='back_damage_reduction',
        side_angle='side_angle',back_angle='rear_angle',quill_release_threshold='quill_damage_threshold',goo_radius=false}},
    enfos_bb_native_hairball={'enfos_bb_hairball',{radius='radius',goo_stacks='goo_stacks',quill_stacks='quill_stacks'}},
}
local function route(params)
    local a=params and params.ability
    if not a or a:IsNull() then return end
    local entry=routes[a:GetAbilityName()]
    local key=params.ability_special_value
    if entry and entry[2][key]~=nil then return entry[1],entry[2][key],key end
end
function M:GetModifierOverrideAbilitySpecial(params) return route(params) and 1 or 0 end
function M:GetModifierOverrideAbilitySpecialValue(params)
    local id,key,nativeKey=route(params)
    if not id or key==false then return 0 end
    local hero=self:GetParent()
    local source=hero:FindAbilityByName(id)
    if not source or source:IsNull() or source:GetLevel()<1 then return 0 end
    local rank=math.min(10,source:GetLevel())-1
    local result=source:GetLevelSpecialValueNoOverride(key,rank)
    if nativeKey=='quill_base_damage' then
        result=result+hero:GetStrength()*source:GetLevelSpecialValueNoOverride('strength_damage_factor',rank)
    elseif nativeKey=='quill_stack_damage' then
        result=result+hero:GetStrength()*source:GetLevelSpecialValueNoOverride('stack_strength_factor',rank)
    end
    return result
end
function M:OnAbilityFullyCast(params)
    if not IsServer() or not params or params.unit~=self:GetParent() then return end
    local native=params.ability
    if not native or native:IsNull() or native:GetAbilityName()~='bristleback_quill_spray' then return end
    local paid=self:GetParent():FindAbilityByName('enfos_bb_quill_spray')
    if paid and not paid:IsNull() then
        paid:EndCooldown();paid:StartCooldown(native:GetCooldownTimeRemaining())
    end
end
