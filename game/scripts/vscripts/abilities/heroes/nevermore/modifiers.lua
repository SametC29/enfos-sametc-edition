-- Engine classes only: no restore service, self-link or server managers.
local Helpers=require('abilities/shared/pve_helpers')
modifier_enfos_sf_native_scaling=class({})
local M=modifier_enfos_sf_native_scaling
function M:IsHidden() return true end
function M:IsPurgable() return false end
function M:RemoveOnDeath() return false end
function M:DeclareFunctions()
    return {MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end
local razes={nevermore_shadowraze1=true,nevermore_shadowraze2=true,nevermore_shadowraze3=true}
local qkeys={shadowraze_damage='damage',shadowraze_radius='radius'}
local wkeys={necromastery_damage_per_soul='damage_per_soul',necromastery_max_souls='max_souls',
    souls_per_kill='souls_per_kill',souls_per_hero_kill='souls_per_hero_kill'}
local rkeys={AbilityDamage='damage_per_wave',requiem_radius='radius'}
local function route(params)
    local a=params and params.ability
    if not a or a:IsNull() then return end
    local name,key=a:GetAbilityName(),params.ability_special_value
    if razes[name] and qkeys[key] then return 'enfos_sf_shadowraze',qkeys[key],key end
    if name=='nevermore_necromastery' and wkeys[key] then return 'enfos_sf_necromastery',wkeys[key],key end
    if name=='nevermore_requiem' and rkeys[key] then return 'enfos_sf_requiem_of_souls',rkeys[key],key end
    if name=='nevermore_requiem' and key=='max_soul_release' then return 'enfos_sf_necromastery','max_souls',key end
end
function M:GetModifierOverrideAbilitySpecial(params) return route(params) and 1 or 0 end
function M:GetModifierOverrideAbilitySpecialValue(params)
    local id,key,nativeKey=route(params)
    if not id then return 0 end
    local hero=self:GetParent()
    local source=hero:FindAbilityByName(id)
    if not source or source:IsNull() or source:GetLevel()<1 then return 0 end
    local rank=math.min(10,source:GetLevel())-1
    local result=source:GetLevelSpecialValueNoOverride(key,rank)
    if nativeKey=='shadowraze_damage' or nativeKey=='AbilityDamage' then
        result=result+Helpers.get_int(hero)*source:GetLevelSpecialValueNoOverride('intelligence_multiplier',rank)
    end
    return result
end
function M:GetModifierSpellAmplify_Percentage()
    local hero=self:GetParent()
    if not hero or hero:IsNull() or hero:PassivesDisabled() or hero:IsIllusion() then return 0 end
    local w=hero:FindAbilityByName('enfos_sf_necromastery')
    if not w or w:IsNull() or w:GetLevel()<1 then return 0 end
    -- Name verified in installed resource/localization/abilities_english.txt.
    -- GetIntrinsicModifierName is server-only, so never call it in this getter.
    local native=hero:FindModifierByName('modifier_nevermore_necromastery')
    if not native or native:IsNull() then return 0 end
    return native:GetStackCount()*w:GetLevelSpecialValueNoOverride('spell_amp_per_soul',math.min(10,w:GetLevel())-1)
end
