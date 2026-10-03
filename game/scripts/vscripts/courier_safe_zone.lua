-- Retirement adapter only: Hammer CallScriptFunction uses this entity's scope.
local Retired = require("map/retired_triggers")

function CourierZone_Enter()
	Retired:Remove(this)
end

function CourierZone_Leave()
	Retired:Remove(this)
end
