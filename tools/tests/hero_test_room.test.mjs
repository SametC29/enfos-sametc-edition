import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import {spawnSync} from 'node:child_process';
const setup=`
package.path='game/scripts/vscripts/?.lua;'..package.path
local tools=true;function IsInToolsMode()return tools end
local map='enfos';function GetMapName()return map end
Log={Info=function()end,Warn=function()end};package.loaded['lib/log']=Log
local ready=false;local plans=0
package.loaded['bosses/resource_gate']={New=function()return {RequestPlan=function(_,p)assert(#p==2);plans=plans+1 end,IsPlanReady=function()return ready end}end}
package.loaded['waves/native_roster']={Get=function(n)assert(n==1);return {unit='fixture_creep'}end}
package.loaded['waves/wave_definitions']={BOSS_HEROES={fixture_reward='fixture_boss'},GetWave=function(_,n)assert(n==5);return {boss_name='fixture_reward'}end}
package.loaded['heroes/roster']={{id='fixture_hero'},{id='fixture_next'}}
local bossPrepared,bossRegistered,bossRemoved=0,0,0
package.loaded['bosses/boss_framework']={PrepareBoss=function(_,u,name,wave,team)assert(u.bossRewardName=='fixture_reward'and name=='fixture_boss'and wave==5 and team==2);bossPrepared=bossPrepared+1;return true end,RegisterBoss=function()bossRegistered=bossRegistered+1;return true end,OnBossKilled=function()bossRemoved=bossRemoved+1 end}
local V={};V.__index=V;function Vector(x,y,z)return setmetatable({x=x,y=y,z=z},V)end;function V.__add(a,b)return Vector(a.x+b.x,a.y+b.y,a.z+b.z)end
function GetGroundPosition(p)return p end;GridNav={IsTraversable=function()return true end,IsBlocked=function()return false end,CanFindPath=function()return true end}
package.loaded['waves/creep_ai']={ROUTES={[2]={center={Vector(0,0,0),Vector(1000,1000,0)}}}}
local level,points,xp,adds,consumes,reconciles,health=6,5,500,0,0,0,0
local hero={pos=Vector(0,0,0),alive=true,
IsNull=function()return false end,IsRealHero=function()return true end,IsIllusion=function()return false end,GetPlayerID=function()return 0 end,GetTeamNumber=function()return 2 end,
GetUnitName=function()return 'fixture_hero'end,GetLevel=function()return level end,GetAbilityPoints=function()return points end,GetCurrentXP=function()return xp end,
AddExperience=function(_,gain)assert(gain==400);xp=xp+gain;level=10;points=points+4 end,
SetAbilityPoints=function()error('points overwritten')end,SetLevel=function()error('hero level bypass')end,
GetAbsOrigin=function(self)return self.pos end,SetRespawnPosition=function(self,p)self.respawn=p end,
IsAlive=function(self)return self.alive end,RespawnHero=function(self)self.alive=true end,
GetMaxHealth=function()return 1000 end,GetMaxMana=function()return 500 end,SetHealth=function(self,n)self.hp=n end,SetMana=function(self,n)self.mana=n end,
GetAbilityByIndex=function(_,index)assert(index<=22);return nil end,GetItemInSlot=function()return nil end,
AddItemByName=function(self,name)adds=adds+1;if name=='item_ultimate_scepter'then self.scepter=true else assert(name=='item_aghanims_shard')end;return {IsNull=function()return false end,OnSpellStart=function()consumes=consumes+1;self.shard=true end}end}
function FindClearSpaceForUnit(h,p)h.pos=p end
package.loaded['heroes/match_levels']={BuildXPThresholds=function()return {[10]=900}end}
package.loaded['heroes/aghanim_manager']={HasScepter=function(_,h)return h.scepter end,HasShard=function(_,h)return h.shard end,UpdateHeroAghanimState=function()reconciles=reconciles+1 end}
package.loaded['heroes/health']={Report=function()health=health+1;return true end}
local selectedHero=hero;local replacementCalls=0;local precached,finishPrecache
function PrecacheUnitByNameAsync(name,callback,id)precached=name;finishPrecache=callback;assert(id==0)end
PlayerResource={IsValidPlayerID=function(_,id)return id==0 end,GetSelectedHeroEntity=function(_,id)if id==0 then return selectedHero end end,
ReplaceHeroWith=function(_,id,name,gold,experience)assert(id==0 and name=='fixture_next' and gold==0 and experience==0);replacementCalls=replacementCalls+1;selectedHero=setmetatable({GetUnitName=function()return name end},{__index=hero});return selectedHero end}
DOTA_MAX_TEAM_PLAYERS=1;DOTA_GAMERULES_STATE_PRE_GAME=8;DOTA_ModifyXP_Unspecified=0;DOTA_TEAM_NEUTRALS=4
local time=0;GameRules={State_Get=function()return 10 end,GetGameTime=function()return time end,EnfosSametC={initializedHeroAbilityPoints={[0]=true}}}
local net={};CustomNetTables={SetTableValue=function(_,table,key,v)net[key]=v end};CustomGameEventManager={RegisterListener=function()end}
local created,removed={},{};local failAt
function CreateUnitByName(name,pos,clear,a,b,team)
 if #created+1==failAt then return nil end;assert(team==4)
 local u={name=name,pos=pos,IsNull=function()return false end,SetRespawnsDisabled=function()end,
SetDeathXP=function(self,n)self.xp=n end,SetMinimumGoldBounty=function(self,n)self.minGold=n end,SetMaximumGoldBounty=function(self,n)self.maxGold=n end,SetIdleAcquire=function()end,SetAcquisitionRange=function()end};created[#created+1]=u;return u
end
function UTIL_Remove(u)removed[#removed+1]=u end
local room=require('tools/hero_test_room');room:Init()
assert(not room:IsEnabled());assert(not room:Enable());map='enfos_test'
`;
function lua(body){const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:setup+body,encoding:'utf8'});assert.equal(r.status,0,r.stderr);assert.equal(r.stderr,'');}
test('Return to selection reuses the roster, rejects forged picks and swaps only after precache',()=>lua(`
assert(not room:Action({PlayerID=0,action='selection'}));assert(replacementCalls==0)
room:Enable();ready=true;room:Tick()
assert(not room:Action({PlayerID=1,action='selection'}));assert(replacementCalls==0)
map='enfos';assert(not room:Action({PlayerID=0,action='selection'}));map='enfos_test'
assert(room:Action({PlayerID=0,action='selection',map='enfos',command='arbitrary'}))
assert(room.selection[0].open and #removed==11 and bossRemoved==1 and replacementCalls==0)
assert(not room:Pick({PlayerID=0,hero_name='npc_dota_hero_invalid'}))
assert(not room:Pick({PlayerID=1,hero_name='fixture_next'}))
assert(room:Pick({PlayerID=0,hero_name='fixture_next'}));assert(precached=='fixture_next' and replacementCalls==0)
assert(not room:Pick({PlayerID=0,hero_name='fixture_next'}));finishPrecache()
assert(replacementCalls==1 and selectedHero:GetUnitName()=='fixture_next')
assert(not room.selection[0].open and GameRules.EnfosSametC.initializedHeroAbilityPoints[0]==nil)
assert(not room:Action({PlayerID=0,action='selection'}))
`));
test('Separate test map automatically enables Tools mode; switching to normal map rejects actions and spawns',()=>lua(`
room:Init();assert(room:IsEnabled() and plans==1);ready=true;room:Tick();assert(#created==11)
map='enfos';assert(not room:IsEnabled());time=1;assert(not room:Action({PlayerID=0,action='reset'}));room:Tick();assert(#created==11)
tools=false;map='enfos_test';room:Init();assert(not room:IsEnabled() and plans==1)
`));
test('Tools activation and resource gate isolate ordinary matches; native leveling keeps nine points and never mutates ranks',()=>lua(`
assert(not room:IsEnabled());tools=false;assert(not room:Enable() and plans==0);tools=true
assert(room:Enable());room:Tick();assert(level==6 and #created==0);ready=true;room:Tick()
assert(level==10 and points==9 and adds==2 and consumes==1 and reconciles==1 and health==1)
assert(#created==11 and bossPrepared==1 and bossRegistered==1 and hero.pos.x==0)
for _,u in ipairs(created)do assert(u.enfosNoReward and u.enfosTestTarget and u.xp==0 and u.minGold==0 and u.maxGold==0)end
assert(created[11].isBoss);room:Tick();assert(#created==11 and adds==2 and points==9)
tools=false;assert(not room:IsEnabled())
`));
test('Reset removes the previous eleven targets and Boss registration without granting more XP/items/points',()=>lua(`
room:Enable();ready=true;room:Tick();assert(room:Action({PlayerID=0,action='reset'}))
assert(#created==22 and #removed==11 and bossRemoved==1 and adds==2 and consumes==1 and points==9)
assert(not room:Action({PlayerID=0,action='reset'}));time=1
hero.alive=false;assert(room:Action({PlayerID=0,action='refresh'}));assert(hero.alive and hero.hp==1000 and hero.mana==500)
room:OnSpawn(hero);assert(hero.pos.x==0 and points==9 and adds==2)
`));
test('Partial spawn failure clears only owned targets; explicit retry is bounded and does not repeat upgrade grants',()=>lua(`
room:Enable();ready=true;failAt=4;room:Tick();assert(#created==3 and #removed==3 and not room.rooms[0].ready)
room:Tick();assert(#created==3);failAt=nil;time=1;assert(room:Action({PlayerID=0,action='reset'}))
assert(#room.rooms[0].units==11 and adds==2 and consumes==1 and level==10 and points==9)
`));
test('Forged/unknown actions and missing hero are rejected without changes',()=>lua(`
assert(not room:Action({PlayerID=0,action='reset'}));room:Enable();ready=true;room:Tick()
assert(not room:Action({PlayerID=1,action='reset'}));assert(not room:Action({PlayerID=0,action='spawn_10000'}));assert(#created==11)
hero.IsIllusion=function()return true end;assert(not room:Action({PlayerID=0,action='refresh'}))
`));
test('Test HUD is controlled by authoritative mode and sends only the selected fixed action',()=>{
 let enabled=false,state=10;const panel={visible:false},listeners={},sent=[];
 const context={CustomNetTables:{GetTableValue:(table)=>table==='game_setup'?({enabled}):({open:false}),SubscribeNetTableListener:(table,fn)=>listeners[table]=fn},GameEvents:{Subscribe:(name,fn)=>listeners.state=fn,SendCustomGameEventToServer:(name,data)=>sent.push({name,data})},Game:{GetState:()=>state},Players:{GetLocalPlayer:()=>0},$:()=>panel};
 vm.runInNewContext(fs.readFileSync('content/panorama/scripts/custom_game/hero_test_room.js','utf8'),context);
 assert.equal(panel.visible,false);enabled=true;listeners.game_setup('game_setup','hero_test_room');assert.equal(panel.visible,true);
 context.EnfosHeroTest.Action('reset');assert.equal(sent[0].name,'enfos_test_room_action');assert.equal(sent[0].data.action,'reset');state=11;listeners.state();assert.equal(panel.visible,false);
 context.EnfosHeroTest.Action('selection');assert.equal(sent[1].data.action,'selection');
 for(const lang of ['english','turkish','russian','schinese']){const t=JSON.parse(fs.readFileSync('localization/'+lang+'.json','utf8')).Tokens;for(const key of ['title','details','reset','refresh','health','selection'])assert.ok(t['enfos_test_'+key]);}
});
