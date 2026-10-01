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
function LoadKeyValues() return {} end
function PrecacheUnitByNameAsync(_, callback) callback() end -- Mock only; delayed callback coverage is separate.
local thinker
local mode={SetContextThink=function(_,name,fn,delay) assert(type(fn)=='function'); thinker=fn end}
GameRules={state=7,paused=false,GetGameModeEntity=function() return mode end,
 State_Get=function(self) return self.state end, IsGamePaused=function(self) return self.paused end}
CustomNetTables={SetTableValue=function() end}
CustomGameEventManager={RegisterListener=function() end,Send_ServerToAllClients=function() end}
PlayerResource={IsValidPlayerID=function(_,id) return id==0 end,GetTeam=function() return 2 end,
 GetConnectionState=function() return 2 end,GetSelectedHeroEntity=function() return nil end}
local W=require('waves/wave_manager')
local L=require('waves/life_core')
test('registered wave thinker starts wave one immediately when match is live', function()
	W:Init(); assert(thinker); thinker()
	assert(W.currentWave==1 and W.state=='SPAWNING' and #W.pendingBatches>0)
	local timer=W.stateTimer; GameRules.paused=true; thinker(); assert(W.stateTimer==timer)
	GameRules.paused=false
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
 W.spawnPlans[2]={{unit_name='enfos_creep_soldier',count=2,lane='both'}}
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
 W.spawnPlans[2]={{unit_name='enfos_boss_stonebreaker',count=1,lane='center'}}
 W:SpawnNextBatch(); W.SpawnCreepEntity=original;W.GetActivePlayerCount=players;assert(count==1)
end)
test('crowded lanes spawn every scheduled unit without population Life damage', function()
 local originalSpawn=W.SpawnCreepEntity
 local originalDamage=L.ApplyDamage
 local originalPlayers=W.GetActivePlayerCount
 L.ApplyDamage=function() error('Population must never cost Life') end
 for _,players in ipairs({1,5}) do
  W.GetActivePlayerCount=function(_,team) return team==2 and players or 0 end
  W:Init();W:StartWave(59)
  for i=1,1000 do W.activeCreeps[2][i]={IsNull=function() return false end,IsAlive=function() return true end} end
  local count=0
  W.SpawnCreepEntity=function(_,_,team,lane,boss)
   assert(team==2 and not boss and (lane=='left' or lane=='right'));count=count+1
  end
  while #W.pendingBatches>0 do W:SpawnNextBatch() end
  assert(count==(20+2*58)*players)
  assert(W:GetActiveCreepCount(2)==1000)
 end
 W.SpawnCreepEntity=originalSpawn;L.ApplyDamage=originalDamage;W.GetActivePlayerCount=originalPlayers
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
test('solo softens opening enemies and retains hero empowerment while difficulty ramps',function()
 local B=require('waves/balance_config');local cfg=B.Snapshot('normal',1,0)
 local unit={hp=280,lo=18,hi=24}
 function unit:GetMaxHealth() return self.hp end
 function unit:SetMaxHealth(v) self.hp=v end
 function unit:SetBaseMaxHealth(v) self.baseHP=v end
 function unit:SetHealth(v) self.currentHP=v end
 function unit:GetBaseDamageMin() return self.lo end
 function unit:GetBaseDamageMax() return self.hi end
 function unit:SetBaseDamageMin(v) self.lo=v end
 function unit:SetBaseDamageMax(v) self.hi=v end
 B.Apply(unit,cfg,1)
 assert(unit.hp==210 and unit.currentHP==210 and unit.lo==12 and unit.hi==16)
 local h,d=B.Multipliers(cfg,30);assert(h==1 and d==1)
 for wave=1,60 do local hp,dmg=B.Multipliers(cfg,wave);assert(hp>=0.75 and hp<=1 and dmg>=0.70 and dmg<=1) end
 assert(cfg.heroPower.health==600 and cfg.heroPower.spellAmp==15 and cfg.heroPower.cooldown==10)
end)
test('solo support is symmetric and never applies to two-player coop or PvPvE',function()
 local B=require('waves/balance_config')
 assert(B.Snapshot('normal',0,1).solo)
 for _,counts in ipairs({{1,1},{2,0},{0,2},{0,0}}) do
  local cfg=B.Snapshot('normal',counts[1],counts[2]);assert(not cfg.solo)
  local h,d=B.Multipliers(cfg,1);assert(h==1 and d==1)
 end
end)
test('solo match configuration is frozen across disconnects and difficulty requests',function()
	W:Init();W:StartPreparation();local cfg=W.matchConfig;assert(cfg.solo and W.stateTimer==20)
 local original=W.GetActivePlayerCount;W.GetActivePlayerCount=function() return 5 end
 assert(not W:SetDifficulty('hell'));W.currentWave=1;W:StartPreparation()
 assert(W.matchConfig==cfg and W:GetDifficulty()=='normal' and W.stateTimer==20)
	W.currentWave=10;W:StartPreparation();assert(W.stateTimer==15)
 W.GetActivePlayerCount=original
end)

test('all 360 wave/player plans conserve requested counts and bounded batches finish before deadline',function()
 local D=require('waves/wave_definitions')
 for players=0,5 do for wave=1,60 do
  local count=0
  for _,entry in ipairs(D:GetSpawnPlan(wave,players)) do count=count+entry.count end
  assert(count==(wave%5==0 and (players>0 and 1 or 0) or (20+2*(wave-1))*players))
  if wave%5~=0 then
   local batches=math.ceil(D:GetScheduledCount(wave,1)/6)
   local interval=math.ceil((D:GetDuration(wave)*0.6/(batches-1))/0.5)*0.5
   assert((batches-1)*interval<D:GetDuration(wave))
  end
 end end
end)
test('deadline advances with living enemies but pauses freeze the clock',function()
 W:Init();W:StartWave(1);W.state=W.STATE_ACTIVE;W.pendingBatches={};W.stateTimer=0.5
 local enemy={IsNull=function() return false end,IsAlive=function() return true end}
 W.activeCreeps[2][77]=enemy
 GameRules.paused=true;W:OnThink();assert(W.currentWave==1 and W.stateTimer==0.5)
 GameRules.paused=false;W:OnThink();assert(W.currentWave==2 and W.activeCreeps[2][77]==enemy)
end)
test('early clear preserves deadline and pays no duplicate completion gold',function()
 W:Init();W.currentWave=2;W.state=W.STATE_ACTIVE;W.pendingBatches={};W.stateTimer=9
 local R=require('waves/rewards');local old=R.Credit;R.Credit=function() error('No clear payout') end
 W:OnWaveCleared();assert(W.state==W.STATE_PREPARATION and W.stateTimer==9)
 R.Credit=old
end)
test('bosses no longer clamp health at former phase floors',function()
 local B=require('bosses/boss_framework')
 local u={bossState={name='enfos_boss_stonebreaker',wave=5,abilityTimer=10},hp=2800,
  GetMaxHealth=function() return 4000 end,GetHealth=function(self) return self.hp end,
  entindex=function() return 9001 end,IsNull=function() return false end,IsAlive=function() return true end,
  EmitSound=function() end,AddNewModifier=function() end}
 local modifier=setmetatable({GetParent=function() return u end},{__index=modifier_enfos_boss_base})
 assert(modifier.GetMinHealth==nil,'Boss must not expose a phase minimum-health gate')
 assert(modifier:GetModifierTotal_ConstantBlock({damage=2800,damage_flags=0})==0,
  'Large ordinary damage must not be capped at the old phase threshold')
 B:OnBossThink(u)
 assert(u.bossState.phase==nil,'Boss AI must not advance or store health phases')
end)
print(n..' runtime regression tests passed (mock engine).')
