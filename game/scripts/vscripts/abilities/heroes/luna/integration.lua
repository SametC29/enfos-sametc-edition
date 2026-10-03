-- Diagnostics at existing ENFOS integration points; native abilities have no Lua wrappers.
local Trace = require('lib/hero_trace')
-- Register engine-only classes independently from the server restore modules.
require('abilities/heroes/luna/modifiers')
LinkLuaModifier('modifier_enfos_luna_native_scaling','abilities/heroes/luna/modifiers',LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_enfos_luna_blessing_extension','abilities/heroes/luna/modifiers',LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_enfos_luna_blessing_extension_buff','abilities/heroes/luna/modifiers',LUA_MODIFIER_MOTION_NONE)
local Scaling = require('abilities/heroes/luna/scaling')
local Blessing = require('abilities/heroes/luna/e')
local Integration = {}

function Integration.UsesNativeShard(hero)
    return hero and hero.GetUnitName and hero:GetUnitName()=='npc_dota_hero_luna'
        and hero.FindAbilityByName and hero:FindAbilityByName('enfos_luna_lunar_orbit') ~= nil
end

function Integration.OnPassiveRankRestored(ability)
    Trace:Log('LUNA','D','passive_rank_restored level=%s owner=native', tostring(ability:GetLevel()))
    Trace:Log('LUNA','W','native_integration_ready ability=enfos_luna_lunar_orbit shard=orbit')
end

function Integration.Restore(hero)
    if not IsServer() or not hero or hero:IsNull() or not hero:IsRealHero()
        or hero:IsIllusion() or hero:GetUnitName()~='npc_dota_hero_luna' then return false end
    local scalingReady=Scaling.Restore(hero)
    local blessingReady=Blessing.Restore(hero)
    return scalingReady and blessingReady
end

function Integration.UsesNativeScepter(hero)
    return hero and hero.GetUnitName and hero:GetUnitName()=='npc_dota_hero_luna'
        and hero.FindAbilityByName and hero:FindAbilityByName('enfos_luna_eclipse') ~= nil
end

return Integration
