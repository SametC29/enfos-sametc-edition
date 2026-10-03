-- Native hostile mana transfer; only mana-less PvE units use conversion damage.
local H=require('abilities/shared/pve_helpers')
local Economy={}
local function valid(x) return x and not (x.IsNull and x:IsNull()) end
function Economy.Take(a,t,amount)
    if not IsServer() or not valid(a) or not valid(t) or not t:IsAlive() or amount<=0 then return 0,'none' end
    local c=a:GetCaster()
    if not valid(c) or not c:IsAlive() or a:GetLevel()<=0 or t:GetTeamNumber()==c:GetTeamNumber()
        or t:IsBuilding() or t:IsMagicImmune() or t:IsDebuffImmune() then return 0,'none' end
    if t:GetMaxMana()<=0 then
        H.damage(a,t,amount,DAMAGE_TYPE_MAGICAL)
        return amount,'conversion'
    end
    local before=math.max(0,t:GetMana())
    local requested=math.min(amount,before)
    if requested<=0 then return 0,'transfer' end
    t:Script_ReduceMana(requested,a)
    -- Native callbacks may remove the recipient; do not dereference a stale unit.
    if not valid(t) then return 0,'transfer' end
    return math.min(requested,math.max(0,before-t:GetMana())),'transfer'
end
return Economy
