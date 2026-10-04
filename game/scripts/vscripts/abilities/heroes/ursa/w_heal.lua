-- Independent Enfos sustain. Native Overpower alone owns buff and charges.
local Heal={}
local MAX_RECORDS=32
local function valid(h) return h and not h:IsNull() end
function Heal.NativeBuff(c,a)
    if not IsServer() or not valid(c) or not valid(a) then return end
    for _,m in ipairs(c:FindAllModifiers()) do
        if valid(m) and m:GetAbility()==a and m:GetStackCount()>0 and m:GetRemainingTime()>0 then return m end
    end
end
function Heal.Record(mod,p)
    if not IsServer() or not p or p.record==nil then return end
    local c,t=mod:GetParent(),p.target
    if not valid(c) or c:GetUnitName()~='npc_dota_hero_ursa' or c:IsIllusion()
        or p.attacker~=c or not valid(t) or t:GetTeamNumber()==c:GetTeamNumber() then return end
    local a=c:FindAbilityByName('enfos_ursa_overpower')
    if not valid(a) or a:GetLevel()<1 or not Heal.NativeBuff(c,a) then return end
    mod.overpowerRecords=mod.overpowerRecords or {}
    if mod.overpowerRecords[p.record] then return end
    local count,oldest,serial=0,nil,math.huge
    for id,row in pairs(mod.overpowerRecords) do
        count=count+1
        if row.serial<serial then oldest,serial=id,row.serial end
    end
    if count>=MAX_RECORDS then mod.overpowerRecords[oldest]=nil end
    mod.overpowerSerial=(mod.overpowerSerial or 0)+1
    mod.overpowerRecords[p.record]={target=t,ability=a,pct=a:GetSpecialValueFor('attack_heal_pct'),serial=mod.overpowerSerial}
end
function Heal.Forget(mod,p)
    if not IsServer() or not p or p.attacker~=mod:GetParent() or p.record==nil then return end
    if mod.overpowerRecords then mod.overpowerRecords[p.record]=nil end
end
function Heal.Landed(mod,p)
    if not IsServer() or not p or p.record==nil or p.attacker~=mod:GetParent() then return end
    local row=mod.overpowerRecords and mod.overpowerRecords[p.record]
    if not row then return end
    mod.overpowerRecords[p.record]=nil -- Claim before heal callbacks.
    local c,t=mod:GetParent(),p.target
    if not valid(c) or not c:IsAlive() or c:IsIllusion() or not valid(t) or t~=row.target
        or t:GetTeamNumber()==c:GetTeamNumber() or not valid(row.ability) or row.ability:GetCaster()~=c then return end
    local damage=tonumber(p.damage) or 0
    if damage<=0 or row.pct<=0 then return end
    local amount=damage*row.pct/100
    c:Heal(amount,row.ability)
    require('lib/hero_trace'):Log('URSA','W','attack_heal record=%s landed_damage=%s requested_heal=%s',
        tostring(p.record),tostring(damage),tostring(amount))
end
function Heal.Death(mod,p)
    if IsServer() and p and p.unit==mod:GetParent() then mod.overpowerRecords=nil;mod.overpowerSerial=0 end
end
return Heal
