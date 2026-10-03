-- Only authored ENFOS armor/movement remain custom; native Blessing owns damage/vision.
local Helpers=require('abilities/shared/pve_helpers')
local Trace=require('lib/hero_trace')
LinkLuaModifier('modifier_enfos_luna_blessing_extension','abilities/heroes/luna/e',LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_enfos_luna_blessing_extension_buff','abilities/heroes/luna/e',LUA_MODIFIER_MOTION_NONE)

modifier_enfos_luna_blessing_extension=class({})
local M=modifier_enfos_luna_blessing_extension
function M:IsHidden() return true end
function M:IsPurgable() return false end
function M:RemoveOnDeath() return false end
function M:IsAura()
    local parent=self:GetParent()
    local ability=self:GetAbility()
    return ability and not ability:IsNull() and ability:GetLevel()>0
        and parent and not parent:IsNull() and parent:IsAlive() and not parent:PassivesDisabled()
end
function M:GetAuraRadius() return Helpers.value(self:GetAbility(),'radius') end
function M:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function M:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function M:GetModifierAura() return 'modifier_enfos_luna_blessing_extension_buff' end
function M:GetAuraDuration() return 0.1 end

modifier_enfos_luna_blessing_extension_buff=class({})
local B=modifier_enfos_luna_blessing_extension_buff
function B:IsHidden() return true end
function B:IsPurgable() return false end
function B:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
local function bonus(self,key)
    local caster=self:GetCaster()
    local ability=self:GetAbility()
    if not caster or caster:IsNull() or not caster:IsAlive() or caster:PassivesDisabled()
        or not ability or ability:IsNull() or ability:GetLevel()<1 then return 0 end
    return Helpers.value(ability,key)
end
function B:GetModifierPhysicalArmorBonus() return bonus(self,'bonus_armor') end
function B:GetModifierMoveSpeedBonus_Percentage() return bonus(self,'bonus_ms_pct') end

local Extension={}
function Extension.Restore(hero)
    local ability=hero:FindAbilityByName('enfos_luna_lunar_blessing')
    if not ability then return false end
    if not hero:HasModifier('modifier_enfos_luna_blessing_extension') then
        hero:AddNewModifier(hero,ability,'modifier_enfos_luna_blessing_extension',{})
    end
    Trace:Log('LUNA','E','native_blessing_extension_ready rank=%s damage_owner=native armor_speed_owner=enfos',tostring(ability:GetLevel()))
    return true
end
return Extension
