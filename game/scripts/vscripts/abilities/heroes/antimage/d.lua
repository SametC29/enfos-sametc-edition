require('abilities/heroes/antimage/modifier_links')

-- Paid stats are separate from the exact rank-one native Persecutor innate.
enfos_am_spellbreaker=class({})
function enfos_am_spellbreaker:GetIntrinsicModifierName() return 'modifier_enfos_am_spellbreaker_passive' end
function enfos_am_spellbreaker:OnUpgrade()
    if IsServer() then require('abilities/heroes/antimage/integration').RestorePersecutor(self:GetCaster()) end
end
