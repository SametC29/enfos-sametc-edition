-- The compiled map loads this path before addon Activate. Keep its old I/O
-- entry points resolvable until map/retired_triggers removes the obsolete area.
local Retired = require("map/retired_triggers")

function TreeShop_OnStartTouch(trigger, activator)
	Retired:Remove(trigger)
end

function TreeShop_OnEndTouch(trigger, activator)
	Retired:Remove(trigger)
end
