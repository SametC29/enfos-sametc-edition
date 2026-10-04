require('abilities/heroes/slark/modifier_links')
local Integration=require('abilities/heroes/slark/integration')
enfos_slark_essence_shift=class({})
function enfos_slark_essence_shift:GetIntrinsicModifierName()
    return 'modifier_enfos_slark_essence_shift_passive'
end
function enfos_slark_essence_shift:OnUpgrade()
    if IsServer() then Integration.RefreshEssence(self:GetCaster()) end
end
