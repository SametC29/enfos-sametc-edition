-- Universal HOME shop covers both elevated arenas. Do not overlap a SECRET shop:
-- recipes belong to HOME, and universal-shop mode already exposes secret items.
local Shop = {}
function Shop:Init()
    if self.trigger and not self.trigger:IsNull() then return true end
    GameRules:SetUseUniversalShopMode(true)
    if not SpawnDOTAShopTriggerRadiusApproximate then return false end
    self.trigger = SpawnDOTAShopTriggerRadiusApproximate(Vector(0,0,0),18000)
    if not self.trigger then return false end
    self.trigger:SetShopType(DOTA_SHOP_HOME or 0)
    self.trigger:SetSize(Vector(-18000,-18000,-2048),Vector(18000,18000,4096))
    return true
end
return Shop
