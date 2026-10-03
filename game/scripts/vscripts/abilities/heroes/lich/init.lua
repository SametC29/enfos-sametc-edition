-- Compatibility loader for the existing shared bootstrap.
require('abilities/heroes/lich/q')
require('abilities/heroes/lich/w')
require('abilities/heroes/lich/e')
require('abilities/heroes/lich/r')
require('abilities/heroes/lich/d')
return {
    ['modifier_enfos_lich_frost_blast_slow'] = 'abilities/heroes/lich/q',
    ['modifier_enfos_lich_frost_shield'] = 'abilities/heroes/lich/w',
    ['modifier_enfos_lich_frost_shield_slow'] = 'abilities/heroes/lich/w',
    ['modifier_enfos_lich_sinister_gaze_debuff'] = 'abilities/heroes/lich/e',
    ['modifier_enfos_lich_chain_frost_slow'] = 'abilities/heroes/lich/r',
    ['modifier_enfos_lich_ice_aura'] = 'abilities/heroes/lich/d',
    ['modifier_enfos_lich_ice_aura_buff'] = 'abilities/heroes/lich/d',
}
