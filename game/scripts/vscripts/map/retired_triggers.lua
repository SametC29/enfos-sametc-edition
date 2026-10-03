-- Compatibility boundary for obsolete I/O in the approved compiled Survival map.
-- No wood shop or courier gameplay is restored. Never remove native trigger_shop.
local Retired = {}
local names = {
	"treeshopradiant", "[PR#]treeshopradiant",
	"courier_safe_zone", "[PR#]courier_safe_zone",
}
local allowed = {}
for _, name in ipairs(names) do allowed[name] = true end

function Retired:Remove(entity)
	if not IsServer() or not entity or entity:IsNull() then return false end
	if entity:GetClassname() ~= "trigger_dota" or not allowed[entity:GetName()] then return false end
	if entity._enfosRetiredTrigger then return false end
	entity._enfosRetiredTrigger = true
	UTIL_Remove(entity)
	return true
end

function Retired:Init()
	if not IsServer() then return 0 end
	local removed = 0
	-- Bounded, once at game-mode startup; include both authored and runtime names.
	for _, name in ipairs(names) do
		for _, entity in ipairs(Entities:FindAllByName(name)) do
			if self:Remove(entity) then removed = removed + 1 end
		end
	end
	Log:Info("map", "Retired legacy TreeShop/CourierZone triggers: removed=%d", removed)
	return removed
end

return Retired
