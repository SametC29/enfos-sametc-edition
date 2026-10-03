local Trace=require('lib/hero_trace')
enfos_sf_shadowraze=class({})
function enfos_sf_shadowraze:OnSpellStart()
    if not IsServer() then return end
    local hero=self:GetCaster()
    local Integration=require('abilities/heroes/nevermore/integration')
    if not Integration.Restore(hero) then
        self:EndCooldown();self:RefundManaCost()
        return
    end
    local providers=Integration.Razes(hero)
    local remaining=self:GetCooldownTimeRemaining()
    -- Mirror the paid slot's existing cooldown; native linked-Raze/Shard
    -- handling changes the providers. Relay only a native reduction afterwards.
    for _,provider in ipairs(providers) do provider:StartCooldown(remaining) end
    for _,provider in ipairs(providers) do
        if hero:IsNull() or not hero:IsAlive() or provider:IsNull() then break end
        provider:OnSpellStart()
    end
    if self:IsNull() then return end
    local reduced=remaining
    for _,provider in ipairs(providers) do
        if not provider:IsNull() then reduced=math.min(reduced,provider:GetCooldownTimeRemaining()) end
    end
    if reduced<remaining then self:EndCooldown();self:StartCooldown(reduced) end
    Trace:Log('SF','Q','native_triple_raze rank=%s providers=3',tostring(self:GetLevel()))
end
