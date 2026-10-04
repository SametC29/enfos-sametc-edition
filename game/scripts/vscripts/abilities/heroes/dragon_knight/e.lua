require('abilities/heroes/dragon_knight/modifier_links')

-- Learnable paid ranks tune the exact native innate without copying its stats.
enfos_dk_dragon_blood=class({})
function enfos_dk_dragon_blood:GetIntrinsicModifierName() return 'modifier_enfos_dk_native_scaling' end
function enfos_dk_dragon_blood:OnUpgrade()
    if IsServer() then require('abilities/heroes/dragon_knight/integration').RefreshDragonBlood(self:GetCaster()) end
end
