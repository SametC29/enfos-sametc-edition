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
for wave=1,4 do
 local u=unit();S.Configure(u,wave,2,false)
 assert(#u.mods==0 and #u.abilities==0 and u.enfosSpecials==nil)
end
local invisible=0
for i=1,12 do local u=unit();S.Configure(u,11,2,false);invisible=invisible+#u.mods end
assert(invisible==12,"Every Ghost in the authored invisible wave must be invisible")
for wave,kit in pairs(S.KITS) do
 S.Reset()
 for i=1,6 do
  local u=unit();S.Configure(u,wave,2,false)
  assert(u.enfosSpecials~=nil,"Every creep must receive wave "..wave.." kit")
  assert(#u.mods+#u.abilities==#kit,"Incomplete kit for wave "..wave)
 end
 local other=unit();S.Configure(other,wave,3,false);assert(other.enfosSpecials)
 local ally=unit();S.Configure(ally,wave,2,true);assert(ally.enfosSpecials)
end
MODIFIER_STATE_INVISIBLE=1
local invisibleModifier=setmetatable({stack=1,GetStackCount=function(self) return self.stack end},{__index=modifier_enfos_wave_special})
assert(invisibleModifier:CheckState()[MODIFIER_STATE_INVISIBLE]==true)
assert(invisibleModifier:GetModifierInvisibilityLevel()==1)
function IsServer() return false end
invisibleModifier:OnCreated({}) -- Client receives no custom creation parameter.
assert(invisibleModifier:CheckState()[MODIFIER_STATE_INVISIBLE]==true)
invisibleModifier.stack=2;assert(next(invisibleModifier:CheckState())==nil)
assert(invisibleModifier:GetModifierInvisibilityLevel()==0)
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
local silence=setmetatable({GetStackCount=function() return 2 end,GetParent=function() return source end},{__index=modifier_enfos_wave_special})
silence:OnAttackLanded({attacker=source,target=target})
silence:OnAttackLanded({attacker=source,target=target})
assert(target.calls==1,"Repeated attacks must not chain silence")
GameRules.GetGameTime=function() return 17 end
silence:OnAttackLanded({attacker=source,target=target});assert(target.calls==2)
local child={is_wave_child=true}
S.SpawnMinions(child) -- Must return before accessing unit APIs or spawning recursively.
-- Exercise production target selection, rather than merely checking kit IDs.
DOTA_ABILITY_BEHAVIOR_UNIT_TARGET=1;DOTA_ABILITY_BEHAVIOR_POINT=2
DOTA_UNIT_TARGET_NONE=0;DOTA_UNIT_TARGET_HERO=1;DOTA_UNIT_TARGET_BASIC=2
DOTA_UNIT_TARGET_TEAM_FRIENDLY=1;DOTA_UNIT_TARGET_FLAG_NONE=0;FIND_CLOSEST=0
DOTA_UNIT_ORDER_CAST_TARGET=1;DOTA_UNIT_ORDER_CAST_POSITION=2;DOTA_UNIT_ORDER_CAST_NO_TARGET=3
bit={band=function(a,b) return a & b end}
local orders,queries={},0
function ExecuteOrderFromTable(order) orders[#orders+1]=order end
local candidate={defendingTeam=2,hp=100}
function candidate:IsAlive() return true end
function candidate:IsInvulnerable() return false end
function candidate:GetHealth() return self.hp end
function candidate:GetMaxHealth() return 100 end
function candidate:GetTeamNumber() return 4 end
function candidate:entindex() return 99 end
function candidate:GetAbsOrigin() return 0 end
local function casterWith(name,friendly,behavior)
 local a={}
 function a:GetAbilityName() return name end
 function a:IsNull() return false end
 function a:IsFullyCastable() return true end
 function a:IsPassive() return false end
 function a:GetBehaviorInt() return behavior or 1 end
 function a:GetCastRange() return 600 end
 function a:GetAOERadius() return 0 end
 function a:GetAbilityTargetTeam() return friendly and 1 or 2 end
 function a:GetAbilityTargetType() return 3 end
 function a:entindex() return 5 end
 local u={enfosSpecials={a},enfosSpecialWave=6}
 function u:IsSilenced() return false end
 function u:IsReincarnating() return false end
 function u:GetAbsOrigin() return 0 end
 function u:GetTeamNumber() return 4 end
 function u:entindex() return 10 end
 return u
end
function FindUnitsInRadius(team,_,_,range,_,types)
 queries=queries+1;assert(types==3)
 return {candidate}
end
S.Reset();orders={}
assert(S.TryCast(casterWith('buff',true),2),'Full-health friendly buff must cast')
S.Reset();orders={}
local healer=casterWith('forest_troll_high_priest_heal',true)
assert(not S.TryCast(healer,2),'Healing must not waste mana on full health')
candidate.hp=50;GameRules.GetGameTime=function() return 18 end
assert(S.TryCast(healer,2))
S.Reset();orders={}
assert(S.TryCast(casterWith('offensive',false),2),'Native target types include summons')
assert(not S.TryCast(casterWith('offensive',false),2),'Team/wave cast gate must survive all-creep kits')
S.Reset();orders={}
local support=casterWith('enfos_wave_raise',false,0)
local previousFind=FindUnitsInRadius
function FindUnitsInRadius(team,pos,cache,range,flags,types) assert(range==750);return previousFind(team,pos,cache,range,flags,types) end
assert(S.TryCast(support,2),'No-target support activates at the engagement distance')
local beforeQueries=queries
assert(not S.TryCast(support,2) and queries==beforeQueries,'Per-unit search throttle')
local function audited(wave,invisible,loaded)
 return {waveNumber=wave,IsNull=function() return false end,IsAlive=function() return true end,
  IsInvisible=function() return invisible end,
  FindModifierByName=function() return {IsNull=function() return false end,GetStackCount=function() return loaded and 1 or 0 end} end,
  FindAbilityByName=function() return {IsNull=function() return false end,GetLevel=function() return loaded and 1 or 0 end} end}
end
local audit=S.Audit({activeCreeps={[2]={audited(49,true,true),audited(49,false,false),audited(13,false,false),audited(1,false,true)}}})
assert(audit[2].alive==4 and audit[2].special==3)
assert(audit[2].invisibleExpected==2 and audit[2].invisibleActual==1 and audit[2].missing==2,'Audit must report actual missing engine state')
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
