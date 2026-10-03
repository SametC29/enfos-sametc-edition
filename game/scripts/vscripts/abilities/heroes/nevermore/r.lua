local Trace=require('lib/hero_trace')
enfos_sf_requiem_of_souls=class({})
function enfos_sf_requiem_of_souls:GetCooldown(level)
    -- Installed Scepter subtracts30 seconds; authored late ranks are below30.
    -- Keep the upgraded ten-rank ENFOS cast finite rather than a negative timer.
    return math.max(1,self:GetLevelSpecialValueFor('AbilityCooldown',level))
end
function enfos_sf_requiem_of_souls:OnUpgrade()
    if IsServer() then require('abilities/heroes/nevermore/integration').Restore(self:GetCaster()) end
end
function enfos_sf_requiem_of_souls:OnAbilityPhaseStart()
    if not IsServer() then return true end
    local hero=self:GetCaster()
    if not require('abilities/heroes/nevermore/integration').Restore(hero) then return false end
    return hero:FindAbilityByName('nevermore_requiem'):OnAbilityPhaseStart()
end
function enfos_sf_requiem_of_souls:OnAbilityPhaseInterrupted()
    if not IsServer() then return end
    local hero=self:GetCaster()
    local provider=hero and not hero:IsNull() and hero:FindAbilityByName('nevermore_requiem')
    if provider and not provider:IsNull() then provider:OnAbilityPhaseInterrupted() end
end
function enfos_sf_requiem_of_souls:OnSpellStart()
    if not IsServer() then return end
    local hero=self:GetCaster()
    local Integration=require('abilities/heroes/nevermore/integration')
    if not Integration.Restore(hero) then self:EndCooldown();self:RefundManaCost();return end
    hero:FindAbilityByName('nevermore_requiem'):OnSpellStart()
    Trace:Log('SF','R','native_requiem_cast rank=%s',tostring(self:GetLevel()))
end
