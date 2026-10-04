-- Shared Boss modifier registration; safe to load in either VScript context.
local BossModifier = { STATUS_RESISTANCE = 60, MAX_REFLECT_DAMAGE = 150 }
local class = _G.class or function()
	local c = {}
	c.__index = c
	setmetatable(c, { __call = function(cls) return setmetatable({}, cls) end })
	return c
end

modifier_enfos_boss_base = class({})
function modifier_enfos_boss_base:IsHidden() return true end
function modifier_enfos_boss_base:IsPurgable() return false end
function modifier_enfos_boss_base:DeclareFunctions()
	return { MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING, MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK }
end
function modifier_enfos_boss_base:GetModifierStatusResistanceStacking()
	return BossModifier.STATUS_RESISTANCE
end
function modifier_enfos_boss_base:GetModifierTotal_ConstantBlock(kv)
	if IsServer and not IsServer() then return 0 end
	local incoming = kv.damage or 0
	local isReflect = false
	if kv.damage_flags then
		if bit and bit.band then
			isReflect = bit.band(kv.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION or 16) ~= 0
		else
			isReflect = (kv.damage_flags == (DOTA_DAMAGE_FLAG_REFLECTION or 16))
		end
	end
	if isReflect and incoming > BossModifier.MAX_REFLECT_DAMAGE then
		return incoming - BossModifier.MAX_REFLECT_DAMAGE
	end
	return 0
end

if LinkLuaModifier then
	LinkLuaModifier("modifier_enfos_boss_base", "bosses/boss_modifier", LUA_MODIFIER_MOTION_NONE)
end

return BossModifier
