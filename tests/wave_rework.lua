package.path = "game/scripts/vscripts/?.lua;" .. package.path
local Curve=require("waves/difficulty_curve")
local Roster=require("waves/native_roster")
local seen,count={},0
local previous=Curve.Normal(1)
assert(previous.hp==120 and previous.damage==10)
for wave=1,60 do
 local stats=Curve.Normal(wave)
 assert(stats.hp>=previous.hp and stats.damage>=previous.damage)
 assert(stats.speed>=previous.speed and stats.magicResistance>=previous.magicResistance)
 previous=stats
 local entry=Roster.Get(wave)
 if wave%5==0 then assert(entry==nil,"Boss slot must not become a normal wave")
 else
  assert(entry and entry.wave==wave)
  assert(not seen[entry.model],"Duplicate model at wave "..wave)
  seen[entry.model]=true;count=count+1
 end
 local future,power=Roster.Future(wave)
 assert(power==math.min(60,wave+5))
 local expected=math.min(59,wave+5)
 if expected%5==0 then expected=expected-1 end
 assert(future.wave==expected)
end
assert(count==48)
local hp,damage=Curve.Solo(1);assert(hp==0.75 and damage==0.70)
hp,damage=Curve.Solo(30);assert(hp==1 and damage==1)
local earlyHp,earlyDamage=Curve.Boss(5)
local lateHp,lateDamage=Curve.Boss(60)
assert(lateHp>earlyHp and lateDamage>earlyDamage)
assert(Curve.Normal(60).hp>Curve.Normal(40).hp*3,"Ending must accelerate")

local S=require("waves/special_creeps")
local function unit()
 local u={mods={},abilities={}}
 function u:AddNewModifier(_,_,name,kv) self.mods[#self.mods+1]={name=name,kind=kv.kind} end
 function u:AddAbility(name)
  self.abilities[#self.abilities+1]=name
  return {SetLevel=function(_,level) assert(level==1) end}
 end
 function u:SetMaxMana(mana) assert(mana==300) end
 function u:SetMana(mana) assert(mana==300) end
 function u:SetBaseManaRegen(regen) assert(regen==3) end
 return u
end
S.Reset()
local invisible=0
for i=1,12 do local u=unit();S.Configure(u,11,2,false);invisible=invisible+#u.mods end
assert(invisible==3,"Only one quarter of Ghosts should require detection")
for _,wave in ipairs({12,31,36,49}) do
 S.Reset()
 for i=1,6 do
  local u=unit();S.Configure(u,wave,2,false)
  assert((u.enfosSpecials~=nil)==(i<=2),"Specialist cap")
 end
 local other=unit();S.Configure(other,wave,3,false);assert(other.enfosSpecials)
 local ally=unit();S.Configure(ally,wave,2,true);assert(ally.enfosSpecials)
end
MODIFIER_STATE_INVISIBLE=1
local invisibleModifier=setmetatable({kind=1},{__index=modifier_enfos_wave_special})
assert(invisibleModifier:CheckState()[MODIFIER_STATE_INVISIBLE]==true)
invisibleModifier.kind=2;assert(next(invisibleModifier:CheckState())==nil)
function IsServer() return true end
GameRules={GetGameTime=function() return 10 end}
local source={}
local target={calls=0}
function target:IsNull() return false end
function target:IsRealHero() return true end
function target:IsMagicImmune() return false end
function target:AddNewModifier(_,_,name,kv)
 self.calls=self.calls+1;assert(name=="modifier_silence" and kv.duration==1.5)
end
local silence=setmetatable({kind=2,GetParent=function() return source end},{__index=modifier_enfos_wave_special})
silence:OnAttackLanded({attacker=source,target=target})
silence:OnAttackLanded({attacker=source,target=target})
assert(target.calls==1,"Repeated attacks must not chain silence")
GameRules.GetGameTime=function() return 17 end
silence:OnAttackLanded({attacker=source,target=target});assert(target.calls==2)
local child={is_wave_child=true}
S.SpawnMinions(child) -- Must return before accessing unit APIs or spawning recursively.
local spawned={}
package.loaded["waves/wave_manager"]={activeCreeps={[2]={}}}
local routes=0
package.loaded["waves/creep_ai"]={Attach=function(_,u,team,lane,leak)
 assert(team==2 and lane=="center");routes=routes+1;leak(u)
end,RouteFromPosition=function() return {} end}
function RandomVector() return 0 end
function CreateUnitByName(name,pos,_,owner,_,team)
 local u={alive=true,id=#spawned+1}
 function u:IsNull() return false end
 function u:IsAlive() return self.alive end
 function u:entindex() return self.id end
 function u:GetAbsOrigin() return pos end
 function u:SetBaseMaxHealth(hp) assert(hp==300) end
 function u:SetMaxHealth(hp) assert(hp==300) end
 function u:SetHealth(hp) assert(hp==300) end
 function u:SetBaseDamageMin(damage) assert(damage==30) end
 function u:SetBaseDamageMax(damage) assert(damage==33) end
 function u:SetMinimumGoldBounty(gold) assert(gold==0) end
 function u:SetMaximumGoldBounty(gold) assert(gold==0) end
 function u:SetDeathXP(xp) assert(xp==0) end
 function u:AddNewModifier(_,_,modifier,kv) assert(modifier=="modifier_kill" and kv.duration==20) end
 function u:SetIdleAcquire() end
 function u:SetAcquisitionRange() end
 function u:ForceKill(reincarnate) assert(reincarnate==false) end
 function u:SetControllableByPlayer(id) self.player=id end
 spawned[#spawned+1]=u;return u
end
local caster={defendingTeam=2,waveNumber=36}
function caster:GetUnitName() return "enfos_wave_36" end
function caster:GetAbsOrigin() return 0 end
function caster:GetTeamNumber() return 4 end
function caster:GetMaxHealth() return 1000 end
function caster:GetBaseDamageMin() return 100 end
function caster:GetBaseDamageMax() return 110 end
function caster:GetPlayerOwnerID() return 7 end
for i=1,6 do S.SpawnMinions(caster) end
assert(#spawned==4 and routes==4,"Summoner must cap living children at four")
for _,u in ipairs(spawned) do
 assert(u.is_wave_child and u.enfosNoReward and u.waveNumber==36)
 assert(package.loaded["waves/wave_manager"].activeCreeps[2][u.id]==u)
end
spawned[1].alive=false;S.SpawnMinions(caster);assert(#spawned==5,"Dead child frees one slot")
caster.enfosWaveChildren={};caster.is_allied_reinforcement=true
S.SpawnMinions(caster)
assert(spawned[6].player==7 and spawned[7].player==7)
assert(routes==5,"Allied children must not follow hostile leak routes")
print("wave rework tests passed")
