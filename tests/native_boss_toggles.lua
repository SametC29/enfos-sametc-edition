-- Isolated regression for native Boss toggle orders, not engine effects.
package.path='game/scripts/vscripts/?.lua;'..package.path
local Native=require('bosses/native_hero_bosses')
DOTA_UNIT_TARGET_TEAM_FRIENDLY=1;DOTA_UNIT_TARGET_TEAM_ENEMY=2
DOTA_UNIT_TARGET_HERO=1;DOTA_UNIT_TARGET_BASIC=2
DOTA_UNIT_TARGET_FLAG_NONE=0;DOTA_UNIT_TARGET_FLAG_NO_INVIS=16
DOTA_ABILITY_BEHAVIOR_TOGGLE=32;DOTA_ABILITY_BEHAVIOR_NO_TARGET=16
DOTA_UNIT_ORDER_CAST_NO_TARGET=7;FIND_CLOSEST=1
bit={band=function(a,b) return math.floor(a/b)%2==1 and b or 0 end,bor=function(a,b) return a+b end}
local present,on,castable=true,false,false
local orders={}
local target={IsNull=function() return false end,IsAlive=function() return true end,
 GetTeamNumber=function() return 2 end}
FindUnitsInRadius=function(team,origin,cache,radius,filter)
 assert(team==2 and filter==DOTA_UNIT_TARGET_TEAM_FRIENDLY)
 return present and {target} or {}
end
ExecuteOrderFromTable=function(order) orders[#orders+1]=order end
local ability={IsNull=function() return false end,IsHidden=function() return false end,
 IsPassive=function() return false end,GetLevel=function() return 1 end,
 IsActivated=function() return true end,IsFullyCastable=function() return castable end,
 GetBehaviorInt=function() return 48 end,GetToggleState=function() return on end,
 GetAbilityTargetTeam=function() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end,
 entindex=function() return 77 end}
local unit={IsNull=function() return false end,IsAlive=function() return true end,
 IsStunned=function() return false end,IsChanneling=function() return false end,
 IsSilenced=function() return false end,IsMuted=function() return false end,
 GetAbilityByIndex=function(_,slot) return slot==0 and ability or nil end,
 GetItemInSlot=function() return nil end,GetAbsOrigin=function() return {} end,
 entindex=function() return 999 end}
local state={defendingTeam=2}
assert(Native:Think(unit,state)==0.4 and #orders==0,'insufficient mana must block enabling')
castable=true;Native:Think(unit,state)
assert(#orders==1 and orders[1].AbilityIndex==77 and orders[1].OrderType==7,'enable once in combat')
on=true;Native:Think(unit,state)
assert(#orders==1,'do not repeatedly toggle an active spell')
present=false;castable=false;Native:Think(unit,state)
assert(#orders==2,'allow disabling outside combat with insufficient mana')
on=false;Native:Think(unit,state)
assert(#orders==2,'friendly self target must not imply combat')
print('PASS: native Boss toggle activation, stable state, resource gate and deactivation (mock engine).')
