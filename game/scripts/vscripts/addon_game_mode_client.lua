-- Engine client entry point: register hero extensions without server gameplay setup.
if not IsClient or not IsClient() then return end
require('abilities/heroes/luna/modifier_links')
require('abilities/heroes/nevermore/modifier_links')
require('abilities/heroes/bristleback/modifier_links')
require('abilities/heroes/slark/modifier_links')
require('abilities/heroes/tidehunter/modifier_links')
require('abilities/heroes/ursa/modifier_links')
require('abilities/heroes/antimage/modifier_links')
require('abilities/heroes/storm_spirit/modifier_links')
require('abilities/heroes/dragon_knight/modifier_links')
