local Rewards = {goldCarry={}, xpCarry={}}

function Rewards:Players(team)
    local result = {}
    for id=0,(DOTA_MAX_TEAM_PLAYERS or 24)-1 do
        if PlayerResource:IsValidPlayerID(id) and PlayerResource:GetTeam(id)==team then
            local connState = PlayerResource:GetConnectionState(id)
            local hasHero = PlayerResource.GetSelectedHeroEntity and (PlayerResource:GetSelectedHeroEntity(id) ~= nil)
            if connState == (DOTA_CONNECTION_STATE_CONNECTED or 2) or hasHero then
                result[#result+1] = id
            end
        end
    end
    return result
end

function Rewards:Init()
    self.units = LoadKeyValues("scripts/npc/npc_units_custom.txt") or {}
    self.goldCarry, self.xpCarry = {}, {}
end

function Rewards:Configure(unit, name)
    local kv = self.units[name] or {}
    unit.enfosGold = RandomInt(tonumber(kv.BountyGoldMin) or 0, tonumber(kv.BountyGoldMax) or 0)
    unit.enfosXP = tonumber(kv.BountyXP) or 0
    -- Native last-hit/radius payouts would duplicate the shared award.
    unit:SetMinimumGoldBounty(0); unit:SetMaximumGoldBounty(0); unit:SetDeathXP(0)
end

function Rewards:Estimate(plan)
    local out={count=0,goldMin=0,goldMax=0,xp=0}
    for _,entry in ipairs(plan) do
        local kv=(self.units or {})[entry.unit_name] or {}
        out.count=out.count+entry.count
        out.goldMin=out.goldMin+entry.count*(tonumber(kv.BountyGoldMin) or 0)
        out.goldMax=out.goldMax+entry.count*(tonumber(kv.BountyGoldMax) or 0)
        out.xp=out.xp+entry.count*(tonumber(kv.BountyXP) or 0)
    end
    return out
end

function Rewards:Credit(id, gold, xp)
    local g = (self.goldCarry[id] or 0)+gold
    local x = (self.xpCarry[id] or 0)+xp
    local gi, xi = math.floor(g+0.000001), math.floor(x+0.000001)
    self.goldCarry[id], self.xpCarry[id] = g-gi, x-xi
    if gi>0 then PlayerResource:ModifyGold(id,gi,true,DOTA_ModifyGold_CreepKill) end
    local hero = PlayerResource:GetSelectedHeroEntity(id)
    if hero and not hero:IsNull() and xi>0 then hero:AddExperience(xi,DOTA_ModifyXP_CreepKill,false,true) end
end

function Rewards:OnKill(unit, killer)
    if unit.enfosRewardResolved then return false end
    unit.enfosRewardResolved = true
    if unit.enfosLeaked then return false end
    local ids = self:Players(unit.defendingTeam)
    if #ids==0 then return false end
    local killerID = killer and not killer:IsNull() and killer:GetPlayerOwnerID() or -1
    for _, id in ipairs(ids) do
        local share=(unit.enfosGold or 0)/#ids
        self:Credit(id,share*(id==killerID and 1.2 or 1),(unit.enfosXP or 0)/#ids)
    end
    return true
end
return Rewards
