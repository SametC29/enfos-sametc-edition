-- Engine classes only on both sides; no server services from client bootstrap.
require('abilities/heroes/slark/modifiers')
LinkLuaModifier('modifier_enfos_slark_native_scaling','abilities/heroes/slark/modifiers',LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_enfos_slark_essence_shift_passive','abilities/heroes/slark/modifiers',LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_enfos_slark_essence_shift_buff','abilities/heroes/slark/modifiers',LUA_MODIFIER_MOTION_NONE)
