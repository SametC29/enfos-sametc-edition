-- Minimal shared registration: no game-mode services or class self-linking.
require('abilities/heroes/nevermore/d')
LinkLuaModifier('modifier_enfos_sf_feast_of_souls_passive',
    'abilities/heroes/nevermore/d',LUA_MODIFIER_MOTION_NONE)
