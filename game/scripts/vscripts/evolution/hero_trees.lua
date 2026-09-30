-- One replicated modifier encodes six choices as base-3 digits: 0 unset, 1/2 chosen.
-- Engine special overrides keep client tooltips and server ability logic in agreement.
local Trees={choices=require('evolution/hero_choices')}
LinkLuaModifier('modifier_enfos_hero_evolution','evolution/hero_trees',LUA_MODIFIER_MOTION_NONE)
local levels={10,15,20,25}
function Trees:GetChoices(hero,level)
    local name=hero and hero.GetUnitName and hero:GetUnitName()
    return (self.choices[name] or {})[level] or {}
end
function Trees:GetTalentChoice(talent)
    return self.choices._talents and self.choices._talents[talent] or nil
end
function Trees:GetAllChoices(hero)
    local result={}
    for _,level in ipairs(levels) do
        for _,choice in ipairs(self:GetChoices(hero,level)) do result[#result+1]=choice end
    end
    return result
end
function Trees:Apply(hero,choice)
    if not hero or hero:IsNull() or not hero.GetUnitName or hero:GetUnitName()~=choice.hero then return false end
    local canonical=(self.choices[choice.hero] or {})[levels[(choice.tier or -1)+1]]
    canonical=canonical and canonical[choice.side]
    if not canonical or canonical.id~=choice.id then return false end
    local modifier=hero:FindModifierByName('modifier_enfos_hero_evolution')
    if not modifier then modifier=hero:AddNewModifier(hero,nil,'modifier_enfos_hero_evolution',{}) end
    if not modifier then return false end
    local code=modifier:GetStackCount()
    local place=3^canonical.tier
    local old=math.floor(code/place)%3
    if old~=0 then return old==canonical.side end
    modifier:SetStackCount(code+canonical.side*place)
    return true
end
modifier_enfos_hero_evolution=class({})
function modifier_enfos_hero_evolution:IsHidden() return true end
function modifier_enfos_hero_evolution:IsPurgable() return false end
function modifier_enfos_hero_evolution:RemoveOnDeath() return false end
function modifier_enfos_hero_evolution:AllowIllusionDuplicate() return false end
function modifier_enfos_hero_evolution:DeclareFunctions()
    return {MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE}
end
function modifier_enfos_hero_evolution:GetBonuses(ability,special)
    if not ability or ability:IsNull() then return 0,0 end
    local parent=self:GetParent()
    if ability:GetCaster()~=parent then return 0,0 end
    local tree=Trees.choices[parent:GetUnitName()]
    if not tree then return 0,0 end
    local flat,pct=0,0
    local code=self:GetStackCount()
    for tier,level in ipairs(levels) do
        local side=math.floor(code/3^(tier-1))%3
        local choice=tree[level][side]
        if choice and choice.ability==ability:GetAbilityName() and choice.special==special then
            if choice.mode=='+' then flat=flat+choice.amount else pct=pct+choice.amount end
        end
    end
    return flat,pct
end
function modifier_enfos_hero_evolution:GetModifierOverrideAbilitySpecial(event)
    if not event or not event.ability or not event.ability_special_value then return 0 end
    local flat,pct=self:GetBonuses(event.ability,event.ability_special_value)
    return (flat~=0 or pct~=0) and 1 or 0
end
function modifier_enfos_hero_evolution:GetModifierOverrideAbilitySpecialValue(event)
    if not event or not event.ability then return 0 end
    local base=event.ability:GetLevelSpecialValueNoOverride(event.ability_special_value,event.ability_special_level)
    local flat,pct=self:GetBonuses(event.ability,event.ability_special_value)
    return base*(1+pct/100)+flat
end
function modifier_enfos_hero_evolution:GetModifierPercentageCooldown(event)
    local _,pct=self:GetBonuses(event and event.ability,'cooldown')
    return pct
end
return Trees
