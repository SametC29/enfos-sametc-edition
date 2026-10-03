local Trace=require('lib/hero_trace')
enfos_sf_necromastery=class({})
function enfos_sf_necromastery:GetIntrinsicModifierName()
    return 'modifier_enfos_sf_native_scaling'
end
function enfos_sf_necromastery:OnUpgrade()
    if not IsServer() then return end
    local hero=self:GetCaster()
    local Integration=require('abilities/heroes/nevermore/integration')
    if Integration.Restore(hero) then
        local modifier=hero:FindModifierByName('modifier_nevermore_necromastery')
        if modifier and not modifier:IsNull() then modifier:ForceRefresh() end
        Trace:Log('SF','W','native_souls_rank_updated rank=%s',tostring(self:GetLevel()))
    end
end
