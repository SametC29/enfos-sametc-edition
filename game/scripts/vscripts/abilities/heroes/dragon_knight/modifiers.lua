-- Native Breathe Fire owns travel, hits, attack reduction and feedback.
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
        or not a or a:IsNull() or a:GetCaster()~=c
        or a:GetAbilityName()~='enfos_dk_breathe_fire' or p.ability_special_value~='damage' then return end
    return c,a
end
function M:GetModifierOverrideAbilitySpecial(p) return route(self,p) and 1 or 0 end
function M:GetModifierOverrideAbilitySpecialValue(p)
    local c,a=route(self,p)
    if not c or a:GetLevel()<1 then return 0 end
    local rank=math.min(10,a:GetLevel())-1
    local strength=c:GetStrength()
    local value=a:GetLevelSpecialValueNoOverride('damage',rank)+strength*a:GetLevelSpecialValueNoOverride('strength_factor',rank)
    if IsServer() then
        require('lib/hero_trace'):Log('DK','Q','native_damage_query rank=%s str=%s value=%s',tostring(rank+1),tostring(strength),tostring(value))
    end
    return value
end
