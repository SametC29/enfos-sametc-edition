-- Diagnostic only: no gameplay timers, entity searches or lifecycle operations.
local Trace = { convar = 'enfos_hero_trace', override = nil, window = nil, count = 0, limit = 100 }

-- Never register an engine ConVar from an ability/module import. The owner
-- observed a Source 2 fatal error in RegisterConVar on this path. Lua pcall
-- cannot be relied on to recover from a native fatal dialog.
-- Server console: script require('lib/hero_trace'):SetEnabled(true/false)
function Trace:SetEnabled(enabled)
    if not IsServer or not IsServer() or type(enabled) ~= 'boolean' then return false end
    self.override = enabled
    return true
end

function Trace:Enabled()
    if not IsServer or not IsServer() then return false end
    if self.override ~= nil then return self.override end
    -- Read-only compatibility if an older host already owns this optional cvar.
    -- Missing cvar/API stays disabled; this module never creates or sets one.
    if not Convars or not Convars.GetBool then return false end
    local ok, enabled = pcall(Convars.GetBool, Convars, self.convar)
    return ok and enabled == true
end

function Trace:Name(entity)
    if not entity then return '<none>' end
    local ok, name = pcall(function()
        if entity.IsNull and entity:IsNull() then return '<removed>' end
        return entity.GetUnitName and entity:GetUnitName() or '<unnamed>'
    end)
    return ok and tostring(name) or '<invalid>'
end

function Trace:Log(hero, slot, fmt, ...)
    if not self:Enabled() then return end
    -- Use the existing game clock, never create a thinker/timer for diagnostics.
    if GameRules and GameRules.GetGameTime then
        local ok, time = pcall(GameRules.GetGameTime, GameRules)
        if ok and type(time) == 'number' then
            local window = math.floor(time)
            if self.window ~= window then self.window, self.count = window, 0 end
        end
    end
    -- Without a clock the conservative cap persists for this module lifetime.
    if self.count >= self.limit then return end
    local ok, message = pcall(string.format, fmt, ...)
    if not ok then return end -- Malformed diagnostics must never break gameplay.
    self.count = self.count + 1
    print(string.format('[%s_TRACE][%s] %s', hero, slot, message))
end

return Trace
