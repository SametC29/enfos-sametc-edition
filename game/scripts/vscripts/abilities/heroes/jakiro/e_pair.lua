-- One paid E rank owns two native-inspired attack components; no extra skill points.
local Trace = require('lib/hero_trace')
local Pair = { frost = 'enfos_jakiro_liquid_frost' }
local function valid(x) return x and not (x.IsNull and x:IsNull()) end
function Pair.Reconcile(c)
    if not IsServer() or not valid(c) or not c.FindAbilityByName then return false end
    local fire=c:FindAbilityByName('enfos_jakiro_liquid_fire')
    if not valid(fire) then return false end
    local frost=c:FindAbilityByName(Pair.frost)
    if not valid(frost) and c.AddAbility then frost=c:AddAbility(Pair.frost) end
    if not valid(frost) then Trace:Log('JAKIRO','E','frost_missing retry=existing_reconcile');return false end
    local rank=math.max(0,math.min(10,fire:GetLevel()))
    local changed=false
    if frost:GetLevel()~=rank then frost:SetLevel(rank);changed=true end
    if not valid(c) or not valid(fire) or not valid(frost) then return false end
    if frost:IsHidden()~=(rank==0) then frost:SetHidden(rank==0);changed=true end
    if not valid(c) or not valid(fire) or not valid(frost) then return false end
    if frost:IsActivated()~=(rank>0) then frost:SetActivated(rank>0);changed=true end
    if rank>0 then Pair.MirrorCooldown(fire) end
    if not valid(c) or not valid(fire) or not valid(frost) then return false end
    if changed then Trace:Log('JAKIRO','E','frost_reconciled rank=%s baseline=true',tostring(rank)) end
    return true
end
function Pair.MirrorCooldown(a)
    if not IsServer() or not valid(a) then return end
    local c=a:GetCaster()
    if not valid(c) or not c.FindAbilityByName or require('heroes/aghanim_manager'):HasShard(c) then return end
    local id=a:GetAbilityName()==Pair.frost and 'enfos_jakiro_liquid_fire' or Pair.frost
    local peer=c:FindAbilityByName(id)
    if not valid(peer) or not a.GetCooldownTimeRemaining then return end
    local remaining=a:GetCooldownTimeRemaining()
    local peer_remaining=peer:GetCooldownTimeRemaining()
    local shared=math.max(remaining,peer_remaining)
    if shared>remaining then a:StartCooldown(shared) end
    if not valid(c) or not valid(a) or not valid(peer) then return end
    if shared>peer_remaining then peer:StartCooldown(shared) end
end
return Pair
