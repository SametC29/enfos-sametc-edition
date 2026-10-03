-- Minimal shared registration: no game-mode services or class self-linking.
require('abilities/heroes/nevermore/d')
require('abilities/heroes/nevermore/q')
require('abilities/heroes/nevermore/w')
require('abilities/heroes/nevermore/r')
require('abilities/heroes/nevermore/modifiers')
LinkLuaModifier('modifier_enfos_sf_feast_of_souls_passive',
    'abilities/heroes/nevermore/d',LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_enfos_sf_native_scaling',
    'abilities/heroes/nevermore/modifiers',LUA_MODIFIER_MOTION_NONE)
