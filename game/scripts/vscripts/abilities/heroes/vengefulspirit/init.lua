-- Compatibility loader: stable classes and one modifier owner per slot.
require('abilities/heroes/vengefulspirit/q')
require('abilities/heroes/vengefulspirit/w')
require('abilities/heroes/vengefulspirit/e')
require('abilities/heroes/vengefulspirit/r')
require('abilities/heroes/vengefulspirit/d')
return {
    ['modifier_enfos_vs_wave_debuff'] = 'abilities/heroes/vengefulspirit/w',
    ['modifier_enfos_vs_vengeance_aura'] = 'abilities/heroes/vengefulspirit/e',
    ['modifier_enfos_vs_vengeance_aura_buff'] = 'abilities/heroes/vengefulspirit/e',
    ['modifier_enfos_vs_nether_swap_buff'] = 'abilities/heroes/vengefulspirit/r',
    ['modifier_enfos_vs_retribution'] = 'abilities/heroes/vengefulspirit/d',
}
