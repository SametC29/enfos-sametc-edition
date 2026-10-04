require('abilities/heroes/dragon_knight/modifier_links')

enfos_dk_elder_dragon_form=class({})
function enfos_dk_elder_dragon_form:OnUpgrade()
    if IsServer() then require('abilities/heroes/dragon_knight/integration').Restore(self:GetCaster()) end
end
function enfos_dk_elder_dragon_form:OnSpellStart()
    if not IsServer() then return end
    local native=require('abilities/heroes/dragon_knight/integration').FormProvider(self)
    if not native then self:EndCooldown();self:RefundManaCost();return end
    native:OnSpellStart()
    if self:IsNull() or native:IsNull() then return end
    native:StartCooldown(self:GetCooldownTimeRemaining())
    require('lib/hero_trace'):Log('DK','R','native_form_cast paid_rank=%s native_rank=%s',tostring(self:GetLevel()),tostring(native:GetLevel()))
end
