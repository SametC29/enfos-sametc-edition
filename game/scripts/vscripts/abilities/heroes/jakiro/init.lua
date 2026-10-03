-- Stable bootstrap compatibility; one explicit owner for each modifier.
require('abilities/heroes/jakiro/q')
require('abilities/heroes/jakiro/w')
require('abilities/heroes/jakiro/e')
require('abilities/heroes/jakiro/r')
require('abilities/heroes/jakiro/d')
return {
    ['modifier_enfos_jakiro_dual_breath_slow'] = 'abilities/heroes/jakiro/q',
    ['modifier_enfos_jakiro_liquid_fire_slow'] = 'abilities/heroes/jakiro/e',
    ['modifier_enfos_jakiro_liquid_fire_passive'] = 'abilities/heroes/jakiro/e',
    ['modifier_enfos_jakiro_macropyre_zone'] = 'abilities/heroes/jakiro/r',
    ['modifier_enfos_jakiro_double_trouble'] = 'abilities/heroes/jakiro/d',
}
