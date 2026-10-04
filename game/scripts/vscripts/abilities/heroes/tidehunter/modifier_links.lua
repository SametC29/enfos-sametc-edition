-- Client-safe classes only; do not import server integration here.
require('abilities/heroes/tidehunter/modifiers')
LinkLuaModifier('modifier_enfos_tide_native_scaling','abilities/heroes/tidehunter/modifiers',LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_enfos_tide_shell_extension','abilities/heroes/tidehunter/modifiers',LUA_MODIFIER_MOTION_NONE)
require('abilities/heroes/tidehunter/d')
LinkLuaModifier('modifier_enfos_tide_wave_catch','abilities/heroes/tidehunter/d',LUA_MODIFIER_MOTION_NONE)
