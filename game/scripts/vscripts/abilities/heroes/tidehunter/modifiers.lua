-- Native owns gameplay; this only supplies authored STR tuning.
modifier_enfos_tide_native_scaling=class({})
local M=modifier_enfos_tide_native_scaling
function M:IsHidden() return true end
function M:IsPurgable() return false end
function M:RemoveOnDeath() return false end
function M:DeclareFunctions()
    return {MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

-- Ravage's top-level AbilityDamage is not read through the special-value bridge.
function M:GetModifierTotalDamageOutgoing_Percentage(params)
    if not IsServer() or not params then return 0 end
    local c,a=self:GetParent(),params.inflictor
    if not c or c:IsNull() or c:IsIllusion() or not a or a:IsNull()
        or a:GetAbilityName()~='enfos_tide_ravage' or a:GetCaster()~=c or a:GetLevel()<1 then return 0 end
    local base=a:GetAbilityDamage()
    if base<=0 then return 0 end
    local strength=c:GetStrength()
    local pct=100*strength*a:GetSpecialValueFor('strength_factor')/base
    require('lib/hero_trace'):Log('TIDEHUNTER','R',
        'native_outgoing_query base=%s str=%s percent=%s original=%s',
        tostring(base),tostring(strength),tostring(pct),tostring(params.original_damage))
    return pct
end
local function matches(params)
    local a=params and params.ability
    return a and not a:IsNull() and ((a:GetAbilityName()=='enfos_tide_gush'
        and params.ability_special_value=='gush_damage') or (a:GetAbilityName()=='enfos_tide_kraken_shell'
        and params.ability_special_value=='damage_reduction') or (a:GetAbilityName()=='enfos_tide_anchor_smash'
        and params.ability_special_value=='attack_damage'))
end
function M:GetModifierOverrideAbilitySpecial(params)
    return matches(params) and 1 or 0
end
function M:GetModifierOverrideAbilitySpecialValue(params)
    if not matches(params) then return 0 end
    local c,a=self:GetParent(),params.ability
    if not c or c:IsNull() or a:GetLevel()<1 then return 0 end
    local rank=math.min(10,a:GetLevel())-1
    return a:GetLevelSpecialValueNoOverride(params.ability_special_value,rank)
        +c:GetStrength()*a:GetLevelSpecialValueNoOverride('strength_factor',rank)
end

-- Enfos regeneration and bounded Shard utility only; native owns block/purge.
modifier_enfos_tide_shell_extension=class({})
local S=modifier_enfos_tide_shell_extension
function S:IsHidden() return true end
function S:IsPurgable() return false end
function S:RemoveOnDeath() return false end
function S:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,MODIFIER_EVENT_ON_TAKEDAMAGE,MODIFIER_EVENT_ON_DEATH} end
function S:OnDeath(params)
    if IsServer() and params and params.unit==self:GetParent() then
        self.damage_counter=0;self.last_damage_time=nil
    end
end
local function sources(mod)
    local c,a=mod:GetParent(),mod:GetAbility()
    if not c or c:IsNull() or c:IsIllusion() or c:PassivesDisabled()
        or not a or a:IsNull() or a:GetLevel()<1 then return end
    return c,a
end
function S:GetModifierConstantHealthRegen()
    local c,a=sources(self)
    return c and a:GetSpecialValueFor('bonus_hp_regen') or 0
end
function S:OnTakeDamage(params)
    if not IsServer() or not params or self.triggering then return end
    local c,a=sources(self)
    if not c or not c:HasShard() then self.damage_counter=0;self.last_damage_time=nil;return end
    if params.unit~=c or not c:IsAlive() or (params.damage or 0)<=0 then return end
    local now=GameRules:GetGameTime()
    if self.last_damage_time and now-self.last_damage_time>=a:GetSpecialValueFor('shard_reset_interval') then self.damage_counter=0 end
    self.last_damage_time=now
    self.damage_counter=(self.damage_counter or 0)+params.damage
    local threshold=a:GetSpecialValueFor('shard_damage_threshold')
    if threshold<=0 or self.damage_counter<threshold then return end
    self.damage_counter=self.damage_counter%threshold
    if now<(self.next_smash or 0) then return end
    local e=c:FindAbilityByName('enfos_tide_anchor_smash')
    if not e or e:IsNull() or e:GetLevel()<1 then return end
    local scale=a:GetSpecialValueFor('shard_smash_damage_pct')/100
    self.next_smash=now+a:GetSpecialValueFor('shard_smash_cooldown')
    self.triggering=true
    c:StartGesture(ACT_DOTA_CAST_ABILITY_3)
    if self:IsNull() then return end
    if c:IsNull() or not c:IsAlive() or a:IsNull() or e:IsNull() then self.triggering=false;return end
    require('abilities/heroes/tidehunter/shard').Smash(c,e,scale)
    if not self:IsNull() then self.triggering=false end
end
