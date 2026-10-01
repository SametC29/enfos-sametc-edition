--------------------------------------------------------------------------------
-- lib/log.lua
-- Structured logging utility for Enfos Team Survival — SametC Edition
--
-- Usage:
--   Log:Info("system", "Game started with build %s", version)
--   Log:Warn("economy", "Gold overflow for player %d: %d", playerId, amount)
--   Log:Error("wave", "Invalid creep ID: %s", creepId)
--   Log:Debug("boss", "Phase transition to %d", phase)
--
-- Log levels: ERROR > WARN > INFO > DEBUG
-- Subsystems: system, wave, boss, economy, spellbringer, hero, creep,
--             boon, progression, ui, persistence, telemetry
--------------------------------------------------------------------------------

if Log == nil then
	Log = {}
end

-- Log level constants
Log.LEVEL_DEBUG = 0
Log.LEVEL_INFO  = 1
Log.LEVEL_WARN  = 2
Log.LEVEL_ERROR = 3

-- Current minimum log level (configurable)
Log._minLevel = Log.LEVEL_DEBUG

-- Subsystem filter (nil = all, or set of enabled subsystem names)
Log._enabledSubsystems = nil

--------------------------------------------------------------------------------
-- Configuration
--------------------------------------------------------------------------------

--- Set the minimum log level.
-- @param level number One of Log.LEVEL_DEBUG, Log.LEVEL_INFO, Log.LEVEL_WARN, Log.LEVEL_ERROR
function Log:SetLevel(level)
	self._minLevel = level
end

--- Enable only specific subsystems. Pass nil to enable all.
-- @param subsystems table|nil Array of subsystem name strings, or nil for all.
function Log:SetSubsystems(subsystems)
	if subsystems == nil then
		self._enabledSubsystems = nil
		return
	end
	self._enabledSubsystems = {}
	for _, name in ipairs(subsystems) do
		self._enabledSubsystems[name] = true
	end
end

--------------------------------------------------------------------------------
-- Internal
--------------------------------------------------------------------------------

local LEVEL_NAMES = {
	[0] = "DEBUG",
	[1] = "INFO",
	[2] = "WARN",
	[3] = "ERROR",
}

local function FormatMessage(level, subsystem, fmt, ...)
	local levelName = LEVEL_NAMES[level] or "???"
	local timestamp = ""
	-- Use GameRules time if available, otherwise omit
	if GameRules and GameRules.GetGameTime then
		local ok, t = pcall(function() return GameRules:GetGameTime() end)
		if ok and t then
			timestamp = string.format("[%.1f] ", t)
		end
	end

	local msg
	local args = {...}
	if #args > 0 then
		local ok, formatted = pcall(string.format, fmt, ...)
		msg = ok and formatted or (fmt .. " [LOG_FORMAT_ERROR]")
	else
		msg = fmt
	end

	return string.format("%s[%s][%s] %s", timestamp, levelName, subsystem, msg)
end

local function ShouldLog(self, level, subsystem)
	if level < self._minLevel then
		return false
	end
	if self._enabledSubsystems and not self._enabledSubsystems[subsystem] then
		return false
	end
	return true
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

--- Log a debug message.
-- @param subsystem string The subsystem name (e.g. "wave", "boss", "economy")
-- @param fmt string Format string (Lua string.format style)
-- @param ... any Format arguments
function Log:Debug(subsystem, fmt, ...)
	if not ShouldLog(self, self.LEVEL_DEBUG, subsystem) then return end
	print(FormatMessage(self.LEVEL_DEBUG, subsystem, fmt, ...))
end

--- Log an info message.
function Log:Info(subsystem, fmt, ...)
	if not ShouldLog(self, self.LEVEL_INFO, subsystem) then return end
	print(FormatMessage(self.LEVEL_INFO, subsystem, fmt, ...))
end

--- Log a warning message.
function Log:Warn(subsystem, fmt, ...)
	if not ShouldLog(self, self.LEVEL_WARN, subsystem) then return end
	print(FormatMessage(self.LEVEL_WARN, subsystem, fmt, ...))
end

--- Log an error message.
function Log:Error(subsystem, fmt, ...)
	if not ShouldLog(self, self.LEVEL_ERROR, subsystem) then return end
	-- Use Dota's warning output if available for errors
	local msg = FormatMessage(self.LEVEL_ERROR, subsystem, fmt, ...)
	if Warning then
		Warning(msg .. "\n")
	else
		print(msg)
	end
end

return Log
