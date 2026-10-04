-- Native abilities own damage, passive stats and form behavior.
modifier_enfos_dk_native_scaling=class({})
local M=modifier_enfos_dk_native_scaling
function M:IsHidden() return true end
function M:IsPurgable() return false end
function M:RemoveOnDeath() return false end
function M:DeclareFunctions()
    return {MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE}
end
local function route(mod,p)
    local c,a=mod:GetParent(),p and p.ability
    if not c or c:IsNull() or c:GetUnitName()~='npc_dota_hero_dragon_knight'
        or not a or a:IsNull() or a:GetCaster()~=c then return end
    local id,key=a:GetAbilityName(),p.ability_special_value
    if id=='enfos_dk_breathe_fire' and key=='damage' then return c,a,'Q' end
    if id=='enfos_dk_dragon_tail' and key=='damage' then return c,a,'W' end
    if id=='dragon_knight_dragon_blood' and (key=='armor' or key=='health_regen') then
        return c,c:FindAbilityByName('enfos_dk_dragon_blood'),'E'
    end
    if id=='dragon_knight_wyrms_wrath' and (key=='magic_damage' or key=='bonus_aoe') then
        return c,c:FindAbilityByName('enfos_dk_wyrm_vigor'),'D'
    end
end
function M:GetModifierOverrideAbilitySpecial(p) return route(self,p) and 1 or 0 end
function M:GetModifierOverrideAbilitySpecialValue(p)
    local c,a,slot=route(self,p)
    if not c or not a or a:IsNull() or a:GetCaster()~=c or a:GetLevel()<1 then return 0 end
    local rank=math.min(10,a:GetLevel())-1
    if slot=='E' or slot=='D' then
        if c:PassivesDisabled() or c:IsIllusion() then return 0 end
        local key=p.ability_special_value
        local value=a:GetLevelSpecialValueNoOverride(key,rank)
        if key=='health_regen' then
            value=value+c:GetStrength()*a:GetLevelSpecialValueNoOverride('strength_regen_factor',rank)
        end
        if IsServer() then
            require('lib/hero_trace'):Log('DK',slot,'native_stat_query key=%s rank=%s value=%s',key,tostring(rank+1),tostring(value))
        end
        return value
    end
    local strength=c:GetStrength()
    local value=a:GetLevelSpecialValueNoOverride('damage',rank)+strength*a:GetLevelSpecialValueNoOverride('strength_factor',rank)
    if IsServer() then
        require('lib/hero_trace'):Log('DK',slot,'native_damage_query rank=%s str=%s value=%s',tostring(rank+1),tostring(strength),tostring(value))
    end
    return value
end

-- Authored defensive stats remain separate from native attack/AoE ownership.
modifier_enfos_dk_wyrm_vigor_passive=class({})
local D=modifier_enfos_dk_wyrm_vigor_passive
function D:IsHidden() return false end
function D:IsPurgable() return false end
function D:RemoveOnDeath() return false end
function D:GetTexture() return 'dragon_knight_wyrms_wrath' end
function D:DeclareFunctions()
    return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end
local function stat(mod,key)
    local c,a=mod:GetParent(),mod:GetAbility()
    if not c or c:IsNull() or c:GetUnitName()~='npc_dota_hero_dragon_knight'
        or c:IsIllusion() or c:PassivesDisabled()
        or not a or a:IsNull() or a:GetCaster()~=c
        or a:GetAbilityName()~='enfos_dk_wyrm_vigor' or a:GetLevel()<1 then return 0 end
    return a:GetLevelSpecialValueNoOverride(key,math.min(10,a:GetLevel())-1)
end
function D:GetModifierMagicalResistanceBonus() return stat(self,'magic_resist') end
function D:GetModifierBonusStats_Strength() return stat(self,'bonus_strength') end
