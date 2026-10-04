require('abilities/heroes/ursa/modifier_links')
enfos_ursa_fury_swipes=class({})
function enfos_ursa_fury_swipes:GetIntrinsicModifierName() return 'modifier_enfos_ursa_native_scaling' end
function enfos_ursa_fury_swipes:OnUpgrade()
    if not IsServer() then return end
    require('abilities/heroes/ursa/integration').RefreshFury(self:GetCaster())
end
