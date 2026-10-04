require('abilities/heroes/dragon_knight/modifier_links')

-- Paid Enfos defense tunes one exact native Wyrm's Wrath attack/AoE provider.
enfos_dk_wyrm_vigor=class({})
function enfos_dk_wyrm_vigor:GetIntrinsicModifierName() return 'modifier_enfos_dk_wyrm_vigor_passive' end
function enfos_dk_wyrm_vigor:OnUpgrade()
    if IsServer() then require('abilities/heroes/dragon_knight/integration').RefreshWyrmsWrath(self:GetCaster()) end
end
