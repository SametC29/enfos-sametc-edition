-- Delegate the native death-illusion lifecycle to a rank-one native ability.
-- The five authored slots retain their own ten-rank values; native aura damage is zero.
local HeroTrace = require('lib/hero_trace')
local Upgrades = { bridge = 'enfos_vs_scepter_native' }
local function valid(entity) return entity and not (entity.IsNull and entity:IsNull()) end
function Upgrades.Reconcile(hero, has_scepter)
    if not IsServer() or not valid(hero) or not hero.FindAbilityByName then return false end
    local aura = hero:FindAbilityByName('enfos_vs_vengeance_aura')
    if not valid(aura) then return false end
    local bridge = hero:FindAbilityByName(Upgrades.bridge)
    if not valid(bridge) and hero.AddAbility then bridge = hero:AddAbility(Upgrades.bridge) end
    if not valid(bridge) then
        HeroTrace:Log('VENGEFUL_SPIRIT','E','scepter_bridge_missing retry=existing_upgrade_reconciliation')
        return false
    end
    local rank = has_scepter and aura:GetLevel() > 0 and 1 or 0
    local changed = false
    if bridge:GetLevel() ~= rank then bridge:SetLevel(rank); changed = true end
    -- Rank changes can synchronously trigger native modifier callbacks.
    if not valid(hero) or not valid(aura) or not valid(bridge) then return false end
    if not bridge:IsHidden() then bridge:SetHidden(true); changed = true end
    if changed then
        HeroTrace:Log('VENGEFUL_SPIRIT','E','scepter_bridge_reconciled rank=%s hidden=true lifecycle_owner=native',tostring(rank))
    end
    return true
end
return Upgrades
