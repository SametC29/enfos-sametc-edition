-- Native Overload owns charging, attack resolution, slows and Shard feedback.
modifier_enfos_storm_native_scaling=class({})
local M=modifier_enfos_storm_native_scaling
function M:IsHidden() return true end
function M:IsPurgable() return false end
function M:RemoveOnDeath() return false end
function M:DeclareFunctions()
    return {MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE}
end
local keys={overload_damage=true,overload_aoe=true}
local function route(mod,p)
    local c,a=mod:GetParent(),p and p.ability
    if not c or c:IsNull() or c:GetUnitName()~='npc_dota_hero_storm_spirit'
        or not a or a:IsNull() or a:GetCaster()~=c or a:GetAbilityName()~='storm_spirit_overload'
        or not keys[p.ability_special_value] then return end
    local e=c:FindAbilityByName('enfos_storm_overload')
    if not e or e:IsNull() or e:GetCaster()~=c then return end
    return c,e
end
function M:GetModifierOverrideAbilitySpecial(p) return route(self,p) and 1 or 0 end
function M:GetModifierOverrideAbilitySpecialValue(p)
    local c,e=route(self,p)
    if not c or e:GetLevel()<1 then return 0 end
    local rank=math.min(10,e:GetLevel())-1
    local value=e:GetLevelSpecialValueNoOverride(p.ability_special_value,rank)
    if p.ability_special_value=='overload_damage' then
        value=value+c:GetIntellect(false)*e:GetLevelSpecialValueNoOverride('intellect_factor',rank)
    end
    return value
end
