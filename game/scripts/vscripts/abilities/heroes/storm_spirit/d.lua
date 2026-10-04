require('abilities/heroes/storm_spirit/modifier_links')

-- Paid Enfos stats remain separate from the rank-one native innate.
enfos_storm_galvanic_core=class({})
function enfos_storm_galvanic_core:GetIntrinsicModifierName()
    return 'modifier_enfos_storm_galvanic_core_passive'
end
function enfos_storm_galvanic_core:OnUpgrade()
    if IsServer() then
        require('abilities/heroes/storm_spirit/integration').RestoreGalvanized(self:GetCaster())
    end
end
