-- Native Mana Break owns burn, upgrades and feedback; no duplicate damage cast.
modifier_enfos_am_native_scaling=class({})
local M=modifier_enfos_am_native_scaling
function M:IsHidden() return true end
function M:IsPurgable() return false end
function M:RemoveOnDeath() return false end
function M:DeclareFunctions()
    return {MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL}
end
local keys={['mana_per_hit']=true,['mana_per_hit_pct']=true}
local function source(mod)
    local c=mod:GetParent()
    if not c or c:IsNull() or c:GetUnitName()~='npc_dota_hero_antimage' then return end
    local q=c:FindAbilityByName('enfos_am_mana_break')
    if not q or q:IsNull() or q:GetCaster()~=c then return end
    return c,q
end
local function route(mod,p)
    local c,q=source(mod)
    local a=p and p.ability
    if not c or not a or a:IsNull() or a:GetCaster()~=c or a:GetAbilityName()~='antimage_mana_break'
        or not keys[p.ability_special_value] then return end
    return c,q
end
function M:GetModifierOverrideAbilitySpecial(p) return route(self,p) and 1 or 0 end
function M:GetModifierOverrideAbilitySpecialValue(p)
    local c,q=route(self,p)
    if not c or q:GetLevel()<1 then return 0 end
    local rank=math.min(10,q:GetLevel())-1
    local result=q:GetLevelSpecialValueNoOverride(p.ability_special_value,rank)
    if p.ability_special_value=='mana_per_hit_pct' and c:HasScepter() then
        result=result+q:GetLevelSpecialValueNoOverride('native_scepter_mana_pct_bonus',rank)
    end
    return result
end
function M:GetModifierProcAttack_BonusDamage_Physical(p)
    if not IsServer() or not p then return 0 end
    local c,q=source(self)
    local t=p.target
    if not c or not c:IsRealHero() or c:IsIllusion() or c:PassivesDisabled() or q:GetLevel()<1 or not t or t:IsNull()
        or t:GetTeamNumber()==c:GetTeamNumber() or not (t:IsHero() or t:IsCreep() or t:IsCreature()) then return 0 end
    local rank=math.min(10,q:GetLevel())-1
    local result=q:GetLevelSpecialValueNoOverride('bonus_damage',rank)
        +c:GetAgility()*q:GetLevelSpecialValueNoOverride('agility_factor',rank)
    require('lib/hero_trace'):Log('ANTIMAGE','Q','pve_proc_query bonus=%s rank=%s',tostring(result),tostring(rank+1))
    return result
end
