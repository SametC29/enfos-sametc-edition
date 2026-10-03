-- Diagnostics at existing ENFOS integration points; native abilities have no Lua wrappers.
local Trace = require('lib/hero_trace')
local Integration = {}

function Integration.OnPassiveRankRestored(ability)
    Trace:Log('LUNA','D','passive_rank_restored level=%s owner=native', tostring(ability:GetLevel()))
end

return Integration
