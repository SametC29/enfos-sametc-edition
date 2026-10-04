require('abilities/heroes/antimage/modifier_links')

-- Stable paid ranks tune one exact native Mana Break provider.
enfos_am_mana_break=class({})
function enfos_am_mana_break:GetIntrinsicModifierName() return 'modifier_enfos_am_native_scaling' end
function enfos_am_mana_break:OnUpgrade()
    if IsServer() then require('abilities/heroes/antimage/integration').RefreshManaBreak(self:GetCaster()) end
end
