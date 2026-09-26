package.path = "game/scripts/vscripts/?.lua;" .. package.path
local n = 0
local function test(name, fn) fn(); n=n+1; print("PASS "..name) end
local vec = {}
vec.__index = vec
function vec:Length2D() return math.sqrt(self.x*self.x+self.y*self.y) end
vec.__sub = function(a,b) return Vector(a.x-b.x,a.y-b.y,a.z-b.z) end
function Vector(x,y,z) return setmetatable({x=x,y=y,z=z},vec) end
DOTA_GAMERULES_STATE_GAME_IN_PROGRESS=7
DOTA_GAMERULES_STATE_POST_GAME=8
DOTA_GAMERULES_STATE_PRE_GAME=6
DOTA_CONNECTION_STATE_CONNECTED=2
function Dynamic_Wrap(t,k) return t[k] end
function ListenToGameEvent() end
function EmitGlobalSound() end
local thinker
local mode={SetContextThink=function(_,name,fn,delay) assert(type(fn)=='function'); thinker=fn end}
GameRules={state=7,paused=false,GetGameModeEntity=function() return mode end,
 State_Get=function(self) return self.state end, IsGamePaused=function(self) return self.paused end}
CustomNetTables={SetTableValue=function() end}
CustomGameEventManager={RegisterListener=function() end,Send_ServerToAllClients=function() end}
PlayerResource={IsValidPlayerID=function(_,id) return id==0 end,GetTeam=function() return 2 end,
 GetConnectionState=function() return 2 end}
local W=require('waves/wave_manager')
local L=require('waves/life_core')
test('registered wave thinker starts preparation, pauses, then spawns', function()
 W:Init(); assert(thinker); thinker(); assert(W.state=='PREPARATION')
 local timer=W.stateTimer; GameRules.paused=true; thinker(); assert(W.stateTimer==timer)
 GameRules.paused=false
 for i=1,30 do thinker() end
 assert(W.currentWave==1 and W.state=='SPAWNING' and #W.pendingBatches>0)
 GameRules.state=8; assert(thinker()==nil); GameRules.state=7
end)
test('next-wave rejects spectators, active enemies and repeat clicks', function()
 W:Init(); W.currentWave=1; W:StartPreparation()
 assert(not W:RequestNextWave(99))
 W.activeCreeps[2][1]={IsNull=function() return false end,IsAlive=function() return true end}
 assert(not W:RequestNextWave(0)); W.activeCreeps[2]={}
 assert(W:RequestNextWave(0)); assert(W.currentWave==2)
 assert(not W:RequestNextWave(0)); assert(W.currentWave==2)
end)
test('early boss retains warning and final wave cannot be skipped', function()
 W:Init(); W.currentWave=4; W:StartPreparation()
 assert(W:RequestNextWave(0)); assert(W.state=='BOSS_INCOMING' and W.currentWave==4)
 assert(not W:RequestNextWave(0))
 W.currentWave=60; W:StartPreparation(); assert(not W:RequestNextWave(0))
end)
test('batches conserve exact counts and never spawn for an empty team', function()
 W:Init(); W.currentWave=1
 local count=0; local original=W.SpawnCreepEntity
 W.SpawnCreepEntity=function(_,_,team) assert(team==2); count=count+1 end
 local def={creeps={{unit_name='enfos_creep_soldier',count_per_player=2,lane='both'}}}
 for i=1,5 do W.pendingBatches[i]={batchIndex=i,totalBatches=5,waveDef=def} end
 for i=1,5 do W:SpawnNextBatch() end
 W.SpawnCreepEntity=original; assert(count==2)
end)
test('multiplayer boss spawns once with player scaling input', function()
 W:Init(); W.currentWave=5
 local count=0;local original=W.SpawnCreepEntity;local players=W.GetActivePlayerCount
 W.GetActivePlayerCount=function(_,team) return team==2 and 5 or 0 end
 W.SpawnCreepEntity=function(_,_,team,lane,boss,active) assert(team==2 and lane=='center' and boss and active==5);count=count+1 end
 W.pendingBatches={{batchIndex=1,totalBatches=1,waveDef={creeps={{unit_name='enfos_boss_stonebreaker',count_per_player=1}}}}}
 W:SpawnNextBatch(); W.SpawnCreepEntity=original;W.GetActivePlayerCount=players;assert(count==1)
end)
local P=require('map/portals')
function EmitSoundOn() end
function FindClearSpaceForUnit(hero,pos) hero.pos=pos end
local function hero(team,pos)
 return {pos=pos,IsNull=function() return false end,IsRealHero=function() return true end,
 IsAlive=function() return true end,IsIllusion=function() return false end,IsChanneling=function() return false end,
 IsStunned=function() return false end,IsRooted=function() return false end,
 GetTeamNumber=function() return team end,GetAbsOrigin=function(self) return self.pos end,Stop=function() end}
end
test('all eight portals teleport only their team and suppress bounce',function()
 for _,p in ipairs(P.points) do
  local h=hero(p.team,p.from);assert(P:TryTeleport(h,10));assert(h.pos==p.to)
  h.pos=p.from;assert(not P:TryTeleport(h,11));assert(not P:TryTeleport(h,14))
  h.pos=Vector(0,0,0);assert(not P:TryTeleport(h,15));h.pos=p.from;assert(P:TryTeleport(h,16))
  assert(not P:TryTeleport(hero(p.team==2 and 3 or 2,p.from),20))
 end
end)
print(n..' runtime regression tests passed (mock engine).')
