import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';
test('opening XP reaches the first skill during wave one for teams of 1..5',()=>{
 const kv=parseKV(fs.readFileSync('game/scripts/npc/npc_units_custom.txt','utf8')).DOTAUnits.enfos_wave_01;
 const lua=`package.path='game/scripts/vscripts/?.lua;'..package.path
 local L=require('heroes/match_levels');local R=require('waves/rewards');local W=require('waves/wave_definitions')
 DOTA_ModifyXP_CreepKill=1;DOTA_ModifyGold_CreepKill=1
 for n=1,5 do
  local xp={};local heroes={}
  for id=0,n-1 do xp[id]=0;local pid=id;heroes[id]={IsNull=function()return false end,AddExperience=function(_,v)xp[pid]=xp[pid]+v end} end
  PlayerResource={IsValidPlayerID=function(_,id)return id<n end,GetTeam=function()return 2 end,GetConnectionState=function()return 2 end,GetSelectedHeroEntity=function(_,id)return heroes[id] end,ModifyGold=function()end}
  R.goldCarry={};R.xpCarry={}
  local plan=W:GetSpawnPlan(1,n);local count=0;for _,e in ipairs(plan)do count=count+e.count end
  local needed=math.ceil(L:BuildXPThresholds()[2]*n/${Number(kv.BountyXP)})
  assert(needed<=math.ceil(count*.35),'first skill must arrive before 35 percent of wave one kills')
  for kill=1,count do local u={defendingTeam=2,enfosXP=${Number(kv.BountyXP)},enfosGold=0};assert(R:OnKill(u,nil));assert(not R:OnKill(u,nil));if kill==needed then for id=0,n-1 do assert(xp[id]>=150) end end end
  for id=0,n-1 do assert(xp[id]==460,'shared XP must be team-size invariant after a full wave') end
 end
 print('PASS opening shared XP')`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-e',lua],{encoding:'utf8'});
 assert.equal(r.stderr,'');assert.match(r.stdout,/PASS opening shared XP/);
});
test('normal creep health increases without changing damage or Boss pressure',()=>{
 const lua=`package.path='game/scripts/vscripts/?.lua;'..package.path
 local B=require('waves/balance_config')
 local function unit(boss)return {isBoss=boss,hp=120,lo=10,hi=11,GetMaxHealth=function(s)return s.hp end,SetBaseMaxHealth=function()end,SetMaxHealth=function(s,v)s.hp=v end,SetHealth=function()end,GetBaseDamageMin=function(s)return s.lo end,GetBaseDamageMax=function(s)return s.hi end,SetBaseDamageMin=function(s,v)s.lo=v end,SetBaseDamageMax=function(s,v)s.hi=v end}end
 for _,counts in ipairs({{1,0},{2,0},{1,1},{5,5}})do
  local cfg=B.Snapshot('normal',counts[1],counts[2]);assert(cfg.regularHP==1.5 and cfg.matchXPVersion)
  local u=unit(false);B.Apply(u,cfg,1);assert(u.hp==(cfg.solo and 135 or 180));assert(u.lo==(cfg.solo and 7 or 10))
  local old={};for k,v in pairs(cfg)do old[k]=v end;old.regularHP=nil
  local a,b=unit(true),unit(true);B.Apply(a,cfg,5);B.Apply(b,old,5);assert(a.hp==b.hp and a.lo==b.lo)
  local legacy=unit(false);B.Apply(legacy,old,1);assert(legacy.hp==(cfg.solo and 90 or 120))
 end
 print('PASS opening health')`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-e',lua],{encoding:'utf8'});
 assert.equal(r.stderr,'');assert.match(r.stdout,/PASS opening health/);
});
