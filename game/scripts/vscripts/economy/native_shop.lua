-- Universal HOME shop covers both elevated arenas. Do not overlap a SECRET shop:
-- recipes belong to HOME, and universal-shop mode already exposes secret items.
local Shop = {playerTriggers={}}
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

-- A flat radius trigger at world origin does not establish HOME access on all
-- elevations. Reuse one small trigger per player at the real hero's position.
-- Normal Dota purchase/recipe handling remains entirely engine-owned.
function Shop:FollowHero(hero)
    if not hero or hero:IsNull() or not hero:IsRealHero() or hero:IsIllusion() then return false end
    local id=hero:GetPlayerID()
    if not id or id<0 or not PlayerResource:IsValidPlayerID(id) then return false end
    local trigger=self.playerTriggers[id]
    if not trigger or trigger:IsNull() then
        trigger=SpawnDOTAShopTriggerRadiusApproximate(hero:GetAbsOrigin(),256)
        if not trigger then return false end
        trigger:SetShopType(DOTA_SHOP_HOME or 0)
        self.playerTriggers[id]=trigger
    end
    trigger:SetAbsOrigin(hero:GetAbsOrigin())
    return true
end
return Shop
