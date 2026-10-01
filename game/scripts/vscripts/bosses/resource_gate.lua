-- Load the actual scheduled Boss unit, including its native model resources,
-- before the synchronous spawn. Requests are shared by both defending teams.
require('lib/log')
local Gate = {}
Gate.__index = Gate

function Gate.New()
    return setmetatable({units = {}}, Gate)
end

function Gate:RequestPlan(plan)
    for _, entry in ipairs(plan or {}) do
        local name = entry.unit_name
        if not self.units[name] then
            local state = {ready = false}
            self.units[name] = state
            Log:Info('boss_resources', 'Precache requested: %s', name)
            local ok, err = pcall(function()
                PrecacheUnitByNameAsync(name, function()
                    state.ready = true
                    Log:Info('boss_resources', 'Precache completed: %s', name)
                end)
            end)
            if not ok then
                state.failed = true
                Log:Error('boss_resources', 'Precache failed for %s: %s', name, tostring(err))
            end
        end
    end
end

function Gate:IsPlanReady(plan)
    for _, entry in ipairs(plan or {}) do
        local state = self.units[entry.unit_name]
        if not state or not state.ready then return false end
    end
    return true
end

return Gate
