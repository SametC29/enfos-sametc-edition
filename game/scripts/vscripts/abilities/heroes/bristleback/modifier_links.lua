-- Same minimal server/client registration pattern as the Luna/SF pilots.
require('abilities/heroes/bristleback/controllers')
require('abilities/heroes/bristleback/modifiers')
LinkLuaModifier('modifier_enfos_bb_native_scaling','abilities/heroes/bristleback/modifiers',LUA_MODIFIER_MOTION_NONE)
