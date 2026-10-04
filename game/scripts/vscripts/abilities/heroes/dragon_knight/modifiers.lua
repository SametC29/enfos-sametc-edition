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
    if id=='dragon_knight_dragon_blood' and (key=='armor' or key=='health_regen') then
        return c,c:FindAbilityByName('enfos_dk_dragon_blood'),'E'
    end
end
function M:GetModifierOverrideAbilitySpecial(p) return route(self,p) and 1 or 0 end
function M:GetModifierOverrideAbilitySpecialValue(p)
    local c,a,slot=route(self,p)
    if not c or not a or a:IsNull() or a:GetCaster()~=c or a:GetLevel()<1 then return 0 end
    local rank=math.min(10,a:GetLevel())-1
    if slot=='E' then
        if c:PassivesDisabled() or c:IsIllusion() then return 0 end
        local key=p.ability_special_value
        local value=a:GetLevelSpecialValueNoOverride(key,rank)
        if key=='health_regen' then
            value=value+c:GetStrength()*a:GetLevelSpecialValueNoOverride('strength_regen_factor',rank)
        end
        if IsServer() then
            require('lib/hero_trace'):Log('DK','E','native_stat_query key=%s rank=%s value=%s',key,tostring(rank+1),tostring(value))
        end
        return value
    end
    local strength=c:GetStrength()
    local value=a:GetLevelSpecialValueNoOverride('damage',rank)+strength*a:GetLevelSpecialValueNoOverride('strength_factor',rank)
    if IsServer() then
        require('lib/hero_trace'):Log('DK','Q','native_damage_query rank=%s str=%s value=%s',tostring(rank+1),tostring(strength),tostring(value))
    end
    return value
end
