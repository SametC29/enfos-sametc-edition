import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {execFileSync,spawnSync} from 'node:child_process';
import luaparse from 'luaparse';
import {parseKV} from '../lib/kv.mjs';
import {readAbilitySources} from '../lib/ability_sources.mjs';

const names=['earth_spike','hex','mana_drain','finger_of_death','demon_soul'];
const ids=names.map(x=>'enfos_lion_'+x),slots=['q','w','e','r','d'];
const abilities=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
test('Lion passive preserves authored ten-rank KV after its individual source repair',()=>{
 const old=parseKV(execFileSync('git',['show','3044af6:game/scripts/npc/npc_abilities_custom.txt'],{encoding:'utf8'})).DOTAAbilities.enfos_lion_demon_soul;
 delete old.HasShardUpgrade;old.ScriptFile='abilities/heroes/lion/d';assert.deepEqual(abilities.enfos_lion_demon_soul,old);
});
test('Lion production classes have unique owners and cold loading cannot relink modifiers',()=>{
 const defined=new Map();
 for(const [path,source] of readAbilitySources(abilities))for(const n of luaparse.parse(source).body){
  if(n.type!=='AssignmentStatement')continue;const name=n.variables[0]?.name;
  if(!name?.startsWith('enfos_lion_')&&!name?.startsWith('modifier_enfos_lion_'))continue;
  assert.ok(!defined.has(name),'duplicate '+name);defined.set(name,path);
 }
 ids.forEach((id,i)=>assert.equal(defined.get(id),`game/scripts/vscripts/abilities/heroes/lion/${slots[i]}.lua`));
 assert.equal([...defined.keys()].filter(x=>x.startsWith('modifier_')).length,7);
 const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
local links={};function LinkLuaModifier(n,p)assert(not links[n],'duplicate modifier '..n);links[n]=p end
local routes=require('abilities/heroes/lion/init')
assert(not package.loaded['abilities/pve_kits'])
local count=0;for n,p in pairs(routes)do count=count+1;assert(links[n]==p and type(_G[n])=='table');require(p)end;assert(count==7)
${ids.map(id=>`assert(type(${id})=='table')`).join('\n')}
require('abilities/pve_kits');for n,p in pairs(routes)do assert(links[n]==p)end
assert(type(enfos_lion_mana_drain.OnChannelFinish)=='function')
print('Lion isolated bootstrap PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.match(r.stdout,/Lion isolated bootstrap PASS/);
});
