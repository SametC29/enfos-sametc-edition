import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';
test('all native Boss identities preserve preparation, rewards, registration and Boss leaks',()=>{
 const units=parseKV(fs.readFileSync('game/scripts/npc/npc_units_custom.txt','utf8')).DOTAUnits;
 const rows=Object.entries(units).filter(([id])=>id.startsWith('enfos_boss_'));
 const lua='{'+rows.map(([id,u])=>'['+JSON.stringify(id)+']={BountyGoldMin='+Number(u.BountyGoldMin)+',BountyGoldMax='+Number(u.BountyGoldMax)+',BountyXP='+Number(u.BountyXP)+'}').join(',')+'}';
 const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-e',
  'ENFOS_TEST_UNITS='+lua+';dofile("tests/native_boss_pipeline.lua")'],{encoding:'utf8'});
 assert.equal(result.status,0,result.stdout+result.stderr);
 assert.match(result.stdout,/PASS twelve native Boss/);
});

test('Boss safety modifier links on the client as well as the server',()=>{
 const lua=`package.path='game/scripts/vscripts/?.lua;'..package.path
 function IsServer() return false end
 LUA_MODIFIER_MOTION_NONE=0
 local linked=false
 function LinkLuaModifier(name,path,motion)
  assert(name=='modifier_enfos_boss_base' and path=='bosses/boss_modifier' and motion==0)
  linked=true
 end
 for _,name in ipairs({'luna','nevermore','bristleback','slark','tidehunter','ursa','antimage','storm_spirit','dragon_knight'})do
  package.loaded['abilities/heroes/'..name..'/modifier_links']={}
 end
 function IsClient() return true end
 dofile('game/scripts/vscripts/addon_game_mode_client.lua')
 assert(linked and type(modifier_enfos_boss_base)=='table')
 assert(modifier_enfos_boss_base:GetModifierStatusResistanceStacking()==60)
 print('PASS client Boss modifier link')`;
 const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-e',lua],{encoding:'utf8'});
 assert.equal(result.status,0,result.stdout+result.stderr);
 assert.match(result.stdout,/PASS client Boss modifier link/);
});

test('player spawn lifecycle ignores neutral Boss heroes',()=>{
 const lua=`package.path='game/scripts/vscripts/?.lua;'..package.path
 function class(t) return t end
 function IsServer() return true end
 DOTA_TEAM_GOODGUYS=2;DOTA_TEAM_BADGUYS=3
 local calls=0
 for _,entry in ipairs({{'map/hero_spawns','ConfigureHero'},{'heroes/hero_power','Apply'},
  {'heroes/innates','Apply'},{'heroes/match_levels','InitializeStartingAbilityPoints'}}) do
  package.loaded[entry[1]]={[entry[2]]=function() calls=calls+1 end}
 end
 package.loaded['heroes/health']={OnSpawn=function() end}
 require('enfos_sametc')
 local hero={team=4,id=-1}
 function hero:IsNull() return false end
 function hero:IsCourier() return false end
 function hero:IsRealHero() return true end
 function hero:GetTeamNumber() return self.team end
 function hero:GetPlayerID() return self.id end
 function EntIndexToHScript() return hero end
 local mode=setmetatable({playerHeroes={},initializedHeroAbilityPoints={}},{__index=EnfosSametC})
 mode:OnNPCSpawned({entindex=1});assert(calls==0)
 hero.team=2;hero.id=0;mode:OnNPCSpawned({entindex=1})
 assert(calls==4 and mode.playerHeroes[0]==hero)
 hero.team=3;hero.id=1;mode:OnNPCSpawned({entindex=1})
 assert(calls==8 and mode.playerHeroes[1]==hero)
 print('PASS neutral Boss and player spawn separation')`;
 const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-e',lua],{encoding:'utf8'});
 assert.equal(result.status,0,result.stdout+result.stderr);
 assert.match(result.stdout,/PASS neutral Boss and player spawn separation/);
});
