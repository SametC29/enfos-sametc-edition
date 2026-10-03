import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import crypto from 'node:crypto';
import {spawnSync} from 'node:child_process';

function lua(body) {
  const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{
    encoding:'utf8',input:`
package.path='game/scripts/vscripts/?.lua;'..package.path
local server=true
function IsServer()return server end
local removed={}
function UTIL_Remove(entity)removed[#removed+1]=entity end
Log={Info=function()end}
local function entity(name,kind)
 return {GetName=function()return name end,GetClassname=function()return kind or 'trigger_dota' end,
 IsNull=function()return false end}
end
local retired=require('map/retired_triggers')
${body}`});
  assert.equal(result.status,0,result.stderr);
  assert.equal(result.stderr,'');
}

test('startup retires both courier areas and old wood area, preserving all native shop triggers',()=>lua(`
local wood=entity('treeshopradiant')
local courier1,courier2=entity('courier_safe_zone'),entity('courier_safe_zone')
local prefixed=entity('[PR#]treeshopradiant')
local shop=entity('treeshopradiant','trigger_shop')
local dire=entity('treeshopdire','trigger_shop')
local unrelated=entity('portal')
local queries=0
Entities={FindAllByName=function(self,name)
 queries=queries+1
 if name=='treeshopradiant' then return {wood,shop,unrelated} end
 if name=='courier_safe_zone' then return {courier1,courier2} end
 if name=='[PR#]treeshopradiant' then return {prefixed} end
 return {}
end}
server=false;assert(retired:Init()==0 and queries==0)
server=true;assert(retired:Init()==4 and queries==4 and #removed==4)
assert(not retired:Remove(shop) and not retired:Remove(dire) and not retired:Remove(unrelated))
assert(retired:Init()==0 and #removed==4) -- pending native deletion/reload is idempotent
`));

test('map entity scripts load before Activate and old I/O callbacks safely retire only their trigger',()=>lua(`
dofile('game/scripts/vscripts/wood_system.lua')
dofile('game/scripts/vscripts/courier_safe_zone.lua')
local hero=entity('hero','npc_dota_hero_luna')
local wood=entity('treeshopradiant')
TreeShop_OnStartTouch(wood,hero);TreeShop_OnEndTouch(wood,hero)
assert(#removed==1 and removed[1]==wood)
this=entity('[PR#]courier_safe_zone')
CourierZone_Enter({activator=hero});CourierZone_Leave({activator=hero})
assert(#removed==2 and removed[2]==this)
this=nil;CourierZone_Enter();TreeShop_OnEndTouch(nil,hero)
this=hero;CourierZone_Leave();assert(#removed==2)
server=false;TreeShop_OnStartTouch(entity('treeshopradiant'),hero);assert(#removed==2)
`));

test('retirement evidence is bound to the approved compiled map and initialized before the native shop',()=>{
  const evidence=JSON.parse(fs.readFileSync('docs/audit/RETIRED_MAP_TRIGGERS.json','utf8'));
  assert.equal(crypto.createHash('sha256').update(fs.readFileSync(evidence.map)).digest('hex'),evidence.mapSha256);
  assert.deepEqual(evidence.retired.map(e=>e.sourceId),[22,140,141]);
  assert.equal(evidence.preserved.classname,'trigger_shop');
  const source=fs.readFileSync('game/scripts/vscripts/enfos_sametc.lua','utf8');
  assert.ok(source.indexOf('require("map/retired_triggers"):Init()')<source.indexOf('require("economy/native_shop"):Init()'));
});
