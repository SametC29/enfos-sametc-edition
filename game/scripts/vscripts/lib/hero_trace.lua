-- Diagnostic only: no gameplay timers, entity searches or lifecycle operations.
local Trace = { convar = 'enfos_hero_trace', window = nil, count = 0, limit = 100 }

if Convars and Convars.RegisterConvar then
    Convars:RegisterConvar(Trace.convar, '0', 'Enable bounded diagnostic hero traces', 0)
end

function Trace:Enabled()
    if IsServer and not IsServer() then return false end
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
