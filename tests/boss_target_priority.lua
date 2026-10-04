-- Focus regression: neutral Boss sees a hero behind a nearer defender creep.
dofile('tests/boss_combat_navigation.lua')
local Native=require('bosses/native_hero_bosses')
local AI=require('waves/creep_ai')
local orders,found={},{}
ExecuteOrderFromTable=function(order) orders[#orders+1]=order end
FindUnitsInRadius=function(_,origin,_,radius)
 local result={}
 for _,target in ipairs(found) do
  if (target:GetAbsOrigin()-origin):Length2D()<=radius then result[#result+1]=target end
 end
 return result
end
local function defender(index,x,hero)
 return {pos=Vector(x,0),team=2,hero=hero,IsNull=function() return false end,
 IsAlive=function(t) return not t.dead end,GetTeamNumber=function(t) return t.team end,
 GetAbsOrigin=function(t) return t.pos end,IsRealHero=function(t) return t.hero end,
 IsInvulnerable=function(t) return t.invulnerable end,IsInvisible=function(t) return t.invisible end,
 IsOutOfGame=function(t) return t.outOfGame end,IsAttackImmune=function(t) return t.attackImmune end,
 entindex=function() return index end}
end
local creep,hero,second=defender(10,100,false),defender(11,500,true),defender(12,400,true)
local unit={pos=Vector(0,0),isBoss=true,attack=creep,
 IsNull=function() return false end,IsAlive=function() return true end,
 IsStunned=function() return false end,IsRooted=function() return false end,
 IsChanneling=function() return false end,IsSilenced=function() return false end,
 IsMuted=function() return false end,HasModifier=function() return false end,
 GetCurrentActiveAbility=function() return nil end,
 GetAbilityByIndex=function(u,i) return i==0 and u.spell or nil end,GetItemInSlot=function() return nil end,
 GetAbsOrigin=function(u) return u.pos end,GetAttackTarget=function(u) return u.attack end,
 GetUnitName=function() return 'npc_dota_hero_sven' end,entindex=function() return 999 end,
 AddNewModifier=function() end,SetContextThink=function() end}
local state={unit=unit,defendingTeam=2,isBoss=true,route={Vector(0,0),Vector(2000,0)},
 waypointIndex=2,lastPos=unit.pos,stuckTimer=0}
unit.creepState=state;found={creep,hero}
AI:OnThink(state)
assert(#orders==1 and orders[1].TargetIndex==11,'Boss must leave its creep target to attack the player behind it')
unit.attack=hero;orders={};found={creep,second,hero};AI:OnThink(state)
assert(#orders==0,'retain a valid hero focus without restarting the attack every think')
unit.IsCommandRestricted=function() return true end;unit.attack=creep;AI:OnThink(state)
assert(#orders==0,'Boss focus must respect native command restrictions')
unit.IsCommandRestricted=nil;unit.attack=hero
hero.dead=true;AI:OnThink(state)
assert(orders[#orders].TargetIndex==12,'dead hero focus must acquire another player')
hero.dead=nil;second.attackImmune=true;hero.invisible=true;orders={};AI:OnThink(state)
assert(orders[1].TargetIndex==10,'unattackable heroes must allow basic defender fallback')
hero.invisible=nil;second.attackImmune=nil;hero.pos=Vector(500,1200);second.team=3;orders={};AI:OnThink(state)
assert(orders[1].TargetIndex==10,'wrong-team and out-of-corridor targets must not pull Boss off its route')
found={};orders={};AI:OnThink(state)
assert(#orders==1 and orders[1].OrderType==DOTA_UNIT_ORDER_ATTACK_MOVE,'stale focus must resume Core route immediately')
hero.pos=Vector(500,0);unit.creepState=nil;unit.attack=creep;orders={};found={creep,hero}
Native:Think(unit,{defendingTeam=2})
assert(#orders==1 and orders[1].TargetIndex==11,'test arena Boss must issue attacks when no spell can be cast')
unit.attack=hero;orders={};Native:Think(unit,{defendingTeam=2})
assert(#orders==0,'arena attack focus must not be spammed')
unit.spell={IsNull=function() return false end,IsHidden=function() return false end,
 IsPassive=function() return false end,GetLevel=function() return 1 end,
 IsActivated=function() return true end,IsFullyCastable=function() return true end,
 GetBehaviorInt=function() return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET end,
 GetAbilityTargetTeam=function() return 2 end,GetCastRange=function() return 600 end,
 entindex=function() return 77 end}
Native:Think(unit,{defendingTeam=2})
assert(#orders==1 and orders[1].AbilityIndex==77 and orders[1].TargetIndex==11,'native targeted spell must prioritize player over nearer creep')
print('PASS Boss hero priority, stable focus, eligible fallback, corridor and arena attacks (mock)')
