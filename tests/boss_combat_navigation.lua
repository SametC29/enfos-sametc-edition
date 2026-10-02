-- Production AI interaction regression; engine presentation is a separate gate.
package.path='game/scripts/vscripts/?.lua;'..package.path
function Vector(x,y,z)
 return setmetatable({x=x,y=y,z=z or 0,Length2D=function(v) return math.sqrt(v.x*v.x+v.y*v.y) end},
 {__sub=function(a,b) return Vector(a.x-b.x,a.y-b.y,a.z-b.z) end})
end
DOTA_UNIT_TARGET_TEAM_FRIENDLY=1;DOTA_UNIT_TARGET_TEAM_ENEMY=2
DOTA_UNIT_TARGET_HERO=1;DOTA_UNIT_TARGET_BASIC=2;DOTA_UNIT_TARGET_FLAG_NONE=0
DOTA_UNIT_TARGET_FLAG_NO_INVIS=16;FIND_CLOSEST=1
DOTA_ABILITY_BEHAVIOR_NO_TARGET=16;DOTA_ABILITY_BEHAVIOR_UNIT_TARGET=8
DOTA_UNIT_ORDER_CAST_NO_TARGET=7;DOTA_UNIT_ORDER_CAST_TARGET=6
DOTA_UNIT_ORDER_ATTACK_MOVE=3;DOTA_UNIT_ORDER_ATTACK_TARGET=4
DOTA_GAMERULES_STATE_POST_GAME=8
bit={band=function(a,b) return math.floor(a/b)%2==1 and b or 0 end,bor=function(a,b) return a+b end}
GameRules={IsGamePaused=function() return false end,State_Get=function() return 7 end}
local Native=require('bosses/native_hero_bosses')
local AI=require('waves/creep_ai')
local orders,present,phase,channel={},false,false,false
local target={pos=Vector(100,0),IsNull=function() return false end,IsAlive=function() return true end,
 GetTeamNumber=function() return 2 end,GetAbsOrigin=function(t) return t.pos end,
 IsInvulnerable=function(t) return t.invulnerable end,IsInvisible=function(t) return t.invisible end,entindex=function() return 2 end}
FindUnitsInRadius=function(_,_,_,radius) return present and target.pos:Length2D()<=radius and {target} or {} end
ExecuteOrderFromTable=function(o) orders[#orders+1]=o end
local ability={behavior=16,team=0,range=0,radius=315,
 IsNull=function() return false end,IsHidden=function() return false end,IsPassive=function() return false end,
 GetLevel=function() return 1 end,IsActivated=function() return true end,IsFullyCastable=function() return true end,
 IsInAbilityPhase=function() return phase end,GetBehaviorInt=function(a) return a.behavior end,
 GetAbilityTargetTeam=function(a) return a.team end,GetCastRange=function(a) return a.range end,
 GetAOERadius=function() return 0 end,GetSpecialValueFor=function(a,key) assert(key=='radius');return a.radius end,
 GetAbilityName=function() return 'axe_berserkers_call' end,
 entindex=function() return 77 end}
local unit={pos=Vector(0,0),isBoss=true,spell=ability,
 IsNull=function() return false end,IsAlive=function() return true end,IsStunned=function() return false end,
 IsRooted=function() return false end,IsChanneling=function() return channel end,
 IsSilenced=function() return false end,IsMuted=function() return false end,HasModifier=function() return false end,
 GetCurrentActiveAbility=function(u) return u.spell end,
 GetAbilityByIndex=function(u,i) return i==0 and u.spell or nil end,GetItemInSlot=function(u,i) return i==0 and u.item or nil end,
 GetAbsOrigin=function(u) return u.pos end,GetAttackTarget=function() return nil end,
 GetUnitName=function() return 'npc_dota_hero_axe' end,entindex=function() return 999 end,
 AddNewModifier=function() end,SetContextThink=function() end}
local state={defendingTeam=2}
Native:Think(unit,state)
assert(#orders==0,'no-target skill with target team NONE must not cast on an empty lane')
unit.spell=nil;unit.item=ability
Native:Think(unit,state)
assert(#orders==0,'no-target item must not interrupt an empty lane')
unit.item=nil;unit.spell=ability;present=true;target.pos=Vector(1000,0)
Native:Think(unit,state)
assert(#orders==0,'local no-target spell must wait for a defender in effect radius')
target.pos=Vector(100,0);Native:Think(unit,state)
assert(#orders==1 and orders[1].AbilityIndex==77,'nearby defender permits native cast')
orders={};present=false
local route=AI:Attach(unit,2,'center',nil,{Vector(0,0),Vector(2000,0)})
AI:OnThink(route);orders={}
unit.creepState.bossCastPending=true;phase=true
AI:OnThink(route);assert(#orders==0,'route orders must preserve cast point')
phase=false;channel=true
AI:OnThink(route);assert(#orders==0,'route orders must preserve channels')
channel=false
AI:OnThink(route)
assert(#orders==1 and orders[1].OrderType==3,'finished cast must resume Core route without waiting four seconds')
AI:OnThink(route);assert(#orders==1,'resume once, preserve attack-move order')
ability.behavior=8;ability.team=2;ability.range=600;present=true;target.pos=Vector(650,0);orders={}
Native:Think(unit,state)
assert(#orders==0,'unit target outside cast range must not drag Boss out of route')
target.pos=Vector(500,0);Native:Think(unit,state)
assert(#orders==1 and unit.creepState.bossCastPending,'targeted cast hands control back to route thinker')
orders={};target.invisible=true;Native:Think(unit,state)
assert(#orders==0,'friendly-relative searches must not cast on invisible defenders')
target.invisible=false;target.invulnerable=true;Native:Think(unit,state)
assert(#orders==0,'invulnerable defenders must not consume cast orders')
target.invulnerable=false;ability.range=1400;target.pos=Vector(1300,0);Native:Think(unit,state)
assert(#orders==1,'enemy-target long-range native casts must retain their range')
orders={};present=false;ability.team=1;Native:Think(unit,state)
assert(#orders==0,'self target is not evidence of combat for friendly skills')
unit.isBoss=false;unit.spell=nil
local normal=AI:Attach(unit,2,'center',nil,{Vector(0,0),Vector(2000,0)})
AI:OnThink(normal);orders={};normal.bossCastPending=true;AI:OnThink(normal)
assert(#orders==0,'Boss handoff must not add move orders to ordinary creeps')
print('PASS Boss empty-lane casts, local radius, cast range, channel and immediate route handoff (mock)')
