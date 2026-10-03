-- Engine-loaded modifier classes only: no restore service, self-link or module export.
local Helpers=require('abilities/shared/pve_helpers')

-- IsAlive is server-only. Client properties read replicated health instead.
local function is_alive(unit)
    if IsServer() then return unit:IsAlive() end
    return unit:GetHealth()>0
end

modifier_enfos_luna_native_scaling=class({})
local M=modifier_enfos_luna_native_scaling
function M:IsHidden() return true end
function M:IsPurgable() return false end
function M:RemoveOnDeath() return false end
function M:DeclareFunctions()
    return {MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE}
end
local function handles(params)
    local ability=params and params.ability
    if not ability or (ability.IsNull and ability:IsNull()) then return false end
    local name=ability:GetAbilityName()
    return params.ability_special_value=='beam_damage'
        and (name=='enfos_luna_lucent_beam' or name=='luna_lucent_beam')
end
function M:GetModifierOverrideAbilitySpecial(params) return handles(params) and 1 or 0 end
function M:GetModifierOverrideAbilitySpecialValue(params)
    if not handles(params) then return 0 end
    local hero=self:GetParent()
    local q=hero:FindAbilityByName('enfos_luna_lucent_beam')
    if not q or q:IsNull() or q:GetLevel()<1 then return 0 end
    -- Ignore this modifier on the raw lookup: no recursive special-value call.
    local rank=math.min(10,q:GetLevel())-1
    return q:GetLevelSpecialValueNoOverride('beam_damage',rank)
        + Helpers.get_agi(hero)*q:GetLevelSpecialValueNoOverride('agility_multiplier',rank)
end


modifier_enfos_luna_blessing_extension=class({})
local Aura=modifier_enfos_luna_blessing_extension
function Aura:IsHidden() return true end
function Aura:IsPurgable() return false end
function Aura:RemoveOnDeath() return false end
function Aura:IsAura()
    local parent=self:GetParent()
    local ability=self:GetAbility()
    return ability and not ability:IsNull() and ability:GetLevel()>0
        and parent and not parent:IsNull() and is_alive(parent) and not parent:PassivesDisabled()
end
function Aura:GetAuraRadius() return Helpers.value(self:GetAbility(),'radius') end
function Aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function Aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function Aura:GetModifierAura() return 'modifier_enfos_luna_blessing_extension_buff' end
function Aura:GetAuraDuration() return 0.1 end

modifier_enfos_luna_blessing_extension_buff=class({})
local B=modifier_enfos_luna_blessing_extension_buff
function B:IsHidden() return true end
function B:IsPurgable() return false end
function B:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
local function bonus(self,key)
    local caster=self:GetCaster()
    local ability=self:GetAbility()
    if not caster or caster:IsNull() or not is_alive(caster) or caster:PassivesDisabled()
        or not ability or ability:IsNull() or ability:GetLevel()<1 then return 0 end
    return Helpers.value(ability,key)
end
function B:GetModifierPhysicalArmorBonus() return bonus(self,'bonus_armor') end
function B:GetModifierMoveSpeedBonus_Percentage() return bonus(self,'bonus_ms_pct') end
