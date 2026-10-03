-- Luna E: isolated Lunar Blessing aura with explicit learned-rank and Break ownership.
local value = require('abilities/shared/pve_helpers').value
local HeroTrace = require('lib/hero_trace')

local function source_ability(caster, ability)
    if not caster or (caster.IsNull and caster:IsNull())
        or not ability or (ability.IsNull and ability:IsNull())
        or (ability.GetLevel and ability:GetLevel() <= 0)
        or (caster.PassivesDisabled and caster:PassivesDisabled())
        or (caster.IsIllusion and caster:IsIllusion()) then return nil end
    return ability
end

LinkLuaModifier('modifier_enfos_luna_lunar_blessing', 'abilities/heroes/luna/e', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_enfos_luna_lunar_blessing_aura', 'abilities/heroes/luna/e', LUA_MODIFIER_MOTION_NONE)

enfos_luna_lunar_blessing = class({})

function enfos_luna_lunar_blessing:Precache(context)
    PrecacheResource('particle', 'particles/units/heroes/hero_luna/luna_ambient_lunar_blessing.vpcf', context)
end
function enfos_luna_lunar_blessing:GetIntrinsicModifierName()
    return 'modifier_enfos_luna_lunar_blessing'
end

modifier_enfos_luna_lunar_blessing = class({})
function modifier_enfos_luna_lunar_blessing:IsHidden() return true end
function modifier_enfos_luna_lunar_blessing:IsPurgable() return false end
function modifier_enfos_luna_lunar_blessing:IsPurgeException() return false end
function modifier_enfos_luna_lunar_blessing:RemoveOnDeath() return false end
function modifier_enfos_luna_lunar_blessing:IsAuraActiveOnDeath() return false end
function modifier_enfos_luna_lunar_blessing:GetTexture() return 'luna_lunar_blessing' end
function modifier_enfos_luna_lunar_blessing:IsAura()
    return source_ability(self:GetParent(), self:GetAbility()) ~= nil
end
function modifier_enfos_luna_lunar_blessing:GetAuraRadius()
    local a = source_ability(self:GetParent(), self:GetAbility())
    return a and value(a, 'radius') or 0
end
function modifier_enfos_luna_lunar_blessing:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_enfos_luna_lunar_blessing:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_enfos_luna_lunar_blessing:GetModifierAura() return 'modifier_enfos_luna_lunar_blessing_aura' end
function modifier_enfos_luna_lunar_blessing:GetEffectName()
    if source_ability(self:GetParent(), self:GetAbility()) then
        return 'particles/units/heroes/hero_luna/luna_ambient_lunar_blessing.vpcf'
    end
end
function modifier_enfos_luna_lunar_blessing:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

modifier_enfos_luna_lunar_blessing_aura = class({})
function modifier_enfos_luna_lunar_blessing_aura:IsHidden() return false end
function modifier_enfos_luna_lunar_blessing_aura:IsPurgable() return false end
function modifier_enfos_luna_lunar_blessing_aura:IsPurgeException() return false end
function modifier_enfos_luna_lunar_blessing_aura:RemoveOnDeath() return true end
function modifier_enfos_luna_lunar_blessing_aura:GetTexture() return 'luna_lunar_blessing' end
function modifier_enfos_luna_lunar_blessing_aura:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
end

local function recipient_value(modifier, key)
    local p = modifier:GetParent()
    if not p or (p.IsNull and p:IsNull()) or (p.IsIllusion and p:IsIllusion()) then return 0 end
    local a = source_ability(modifier:GetCaster(), modifier:GetAbility())
    return a and value(a, key) or 0
end

function modifier_enfos_luna_lunar_blessing_aura:GetModifierPreAttack_BonusDamage()
    return recipient_value(self, 'bonus_damage')
end
function modifier_enfos_luna_lunar_blessing_aura:GetModifierMoveSpeedBonus_Percentage()
    return recipient_value(self, 'bonus_ms_pct')
end
function modifier_enfos_luna_lunar_blessing_aura:GetModifierPhysicalArmorBonus()
    return recipient_value(self, 'bonus_armor')
end

local function trace(modifier, event)
    if not IsServer() or not HeroTrace:Enabled() then return end
    HeroTrace:Log('LUNA','E','%s source=%s recipient=%s active=%s',
        event,HeroTrace:Name(modifier:GetCaster()),HeroTrace:Name(modifier:GetParent()),
        tostring(source_ability(modifier:GetCaster(), modifier:GetAbility()) ~= nil))
end
function modifier_enfos_luna_lunar_blessing:OnCreated() trace(self,'source_created') end
function modifier_enfos_luna_lunar_blessing:OnRefresh() trace(self,'source_refreshed') end
function modifier_enfos_luna_lunar_blessing:OnDestroy() trace(self,'source_removed') end
function modifier_enfos_luna_lunar_blessing_aura:OnCreated() trace(self,'recipient_created') end
function modifier_enfos_luna_lunar_blessing_aura:OnRefresh() trace(self,'recipient_refreshed') end
function modifier_enfos_luna_lunar_blessing_aura:OnDestroy() trace(self,'recipient_removed') end
