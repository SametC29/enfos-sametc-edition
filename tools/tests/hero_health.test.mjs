import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
function lua(body){const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{encoding:'utf8',input:`
package.path='game/scripts/vscripts/?.lua;'..package.path
local server=true
function IsServer()return server end
local lines={};print=function(s)lines[#lines+1]=s end
local Health=require('heroes/health')
local selected
PlayerResource={IsValidPlayerID=function(_,id)return id==0 end,GetSelectedHeroEntity=function()return selected end}
local function hero(entry)
 local h={IsNull=function()return false end,IsRealHero=function()return true end,IsIllusion=function()return false end,
 GetPlayerID=function()return 0 end,GetUnitName=function()return entry.id end,GetLevel=function()return 6 end,
 GetAbilityPoints=function()return 5 end,IsAlive=function()return true end,
 FindModifierByName=function()return nil end,
 AddAbility=function()error('diagnostic changed abilities')end,
 AddNewModifier=function()error('diagnostic changed modifiers')end,
 SetAbilityPoints=function()error('diagnostic changed points')end}
 h.FindAbilityByName=function(_,id)
  for _,name in ipairs(entry.abilities)do if id==name then return {IsNull=function()return false end,
   GetLevel=function()return 0 end,GetAbilityDamage=function()return 0 end,
   GetIntrinsicModifierName=function()return nil end}end end
 end
 return h
end
${body}`});assert.equal(r.status,0,r.stderr);assert.equal(r.stderr,'');}
test('selected real hero emits one snapshot after initialization, for every roster hero without gameplay mutation',()=>lua(`
for _,entry in ipairs(require('heroes/roster'))do
 local h=hero(entry);selected=h;local before=#lines
 assert(Health.OnSpawn(h));assert(#lines>before)
 assert(table.concat(lines,'|'):find('points=5',1,true))
 local after=#lines;assert(not Health.OnSpawn(h));assert(#lines==after)
end
`));
test('client, illusions, unselected, ownerless and unknown heroes cannot emit automatic health snapshots',()=>lua(`
local entry=require('heroes/roster')[1];local h=hero(entry);selected=h
server=false;assert(not Health.OnSpawn(h) and not Health.Report(h,0));server=true
h.IsIllusion=function()return true end;assert(not Health.OnSpawn(h));h.IsIllusion=function()return false end
selected=nil;assert(not Health.OnSpawn(h));selected=h
h.GetPlayerID=function()return -1 end;assert(not Health.OnSpawn(h));h.GetPlayerID=function()return 0 end
h.GetUnitName=function()return 'unknown_unit' end;assert(not Health.OnSpawn(h));assert(#lines==0)
`));
test('automatic diagnostic hook runs after the existing free passive and starting point initialization',()=>{
const s=fs.readFileSync('game/scripts/vscripts/enfos_sametc.lua','utf8');
const hook=s.indexOf('require("heroes/health").OnSpawn(spawnedUnit)');
assert.ok(hook>s.indexOf('require("heroes/innates"):Apply(spawnedUnit)'));
assert.ok(hook>s.indexOf('spawnedUnit, self.initializedHeroAbilityPoints)'));
assert.match(s,/for playerId, hero in pairs\(self\.playerHeroes\)[\s\S]*?require\("heroes\/health"\)\.OnSpawn\(hero\)/,
 'existing registered-hero loop retries once selection catches up; no new scan/timer');
});

test('late authoritative selection emits once and BB native query reports stay read-only',()=>lua(`
local entry
for _,row in ipairs(require('heroes/roster'))do if row.id=='npc_dota_hero_bristleback' then entry=row end end
local h=hero(entry);selected=nil
assert(not Health.OnSpawn(h) and not h.enfosHealthReported)
local oldFind=h.FindAbilityByName
h.FindAbilityByName=function(self,id)
 local values={quill_base_damage=80,radius=400,quill_stacks=1,projectile_speed=1200}
 if id=='bristleback_quill_spray' or id=='enfos_bb_native_hairball' then return {
  IsNull=function()return false end,GetLevel=function()return 1 end,
  GetSpecialValueFor=function(_,key)return assert(values[key])end}end
 return oldFind(self,id)
end
selected=h;assert(Health.OnSpawn(h));local after=#lines
assert(table.concat(lines,'|'):find('native_hairball_speed_query=1200',1,true))
assert(not Health.OnSpawn(h) and #lines==after)
`));
