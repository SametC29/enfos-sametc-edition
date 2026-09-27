-- Universal HOME shop covers both elevated arenas. Do not overlap a SECRET shop:
-- recipes belong to HOME, and universal-shop mode already exposes secret items.
local Shop = {}
function Shop:Init()
    if self.trigger and not self.trigger:IsNull() then return true end
    GameRules:SetUseUniversalShopMode(true)
    if not SpawnDOTAShopTriggerRadiusApproximate then return false end
    -- CDOTA_ShopTrigger inherits CBaseTrigger, not CBaseModelEntity: it has no
    -- SetSize method. Calling it aborts Activate before setup/roster publication.
    -- Let the native radius helper create the bounds around both elevated arenas.
    self.trigger = SpawnDOTAShopTriggerRadiusApproximate(Vector(0,0,256),18000)
    if not self.trigger then return false end
    self.trigger:SetShopType(DOTA_SHOP_HOME or 0)
    return true
end
return Shop
