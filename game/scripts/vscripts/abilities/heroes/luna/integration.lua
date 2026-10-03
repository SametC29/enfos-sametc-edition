-- Diagnostics at existing ENFOS integration points; native abilities have no Lua wrappers.
local Trace = require('lib/hero_trace')
local Integration = {}

function Integration.UsesNativeShard(hero)
    return hero and hero.GetUnitName and hero:GetUnitName()=='npc_dota_hero_luna'
        and hero.FindAbilityByName and hero:FindAbilityByName('enfos_luna_lunar_orbit') ~= nil
end

function Integration.OnPassiveRankRestored(ability)
    Trace:Log('LUNA','D','passive_rank_restored level=%s owner=native', tostring(ability:GetLevel()))
    Trace:Log('LUNA','W','native_integration_ready ability=enfos_luna_lunar_orbit shard=orbit')
end

return Integration
