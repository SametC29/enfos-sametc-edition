-- Engine client entry point: register Luna extensions without server gameplay setup.
if not IsClient or not IsClient() then return end
require('abilities/heroes/luna/modifier_links')
