require('abilities/heroes/ursa/modifier_links')

-- Paid mobility is separate from the native rank-one Maul innate.
enfos_ursa_ursa_minor=class({})
function enfos_ursa_ursa_minor:GetIntrinsicModifierName() return 'modifier_enfos_ursa_minor_passive' end
