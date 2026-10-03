import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import luaparse from 'luaparse';
import {parseKV} from '../lib/kv.mjs';
import {readAbilitySources} from '../lib/ability_sources.mjs';

const abilities=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
const ids=['magic_missile','wave_of_terror','vengeance_aura','nether_swap','retribution'].map(x=>'enfos_vs_'+x);
const slots=['q','w','e','r','d'];

test('Vengeful Spirit production slots resolve unique isolated classes and shared dependencies',()=>{
  const sources=readAbilitySources(abilities),defined=new Map();
  for(const [file,source] of sources) for(const node of luaparse.parse(source).body){
    if(node.type!=='AssignmentStatement')continue;
    const name=node.variables[0]?.name;
    if(!name?.startsWith('enfos_vs_')&&!name?.startsWith('modifier_enfos_vs_'))continue;
    assert.ok(!defined.has(name),`duplicate class ${name}`);defined.set(name,file);
  }
  ids.forEach((id,i)=>{
    assert.equal(abilities[id].ScriptFile,`abilities/heroes/vengefulspirit/${slots[i]}`);
    assert.equal(defined.get(id),`game/scripts/vscripts/${abilities[id].ScriptFile}.lua`);
  });
  assert.equal([...defined.keys()].filter(x=>x.startsWith('modifier_')).length,5);
  assert.ok(sources.has('game/scripts/vscripts/abilities/shared/pve_helpers.lua'));
});

test('Vengeful Spirit cold-loads without monolith and bootstrap cannot relink its modifiers',()=>{
  const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t) t.__index=t;return t end
local links={}
function LinkLuaModifier(name,path)
 assert(not links[name],'duplicate modifier link '..name);links[name]=path
end
local routes=require('abilities/heroes/vengefulspirit/init')
assert(not package.loaded['abilities/pve_kits'],'isolated kit imports monolith')
local count=0
for name,path in pairs(routes) do
 count=count+1;assert(links[name]==path);assert(type(_G[name])=='table');require(path)
end
assert(count==5)
${ids.map(id=>`assert(type(${id})=='table')`).join('\n')}
require('abilities/pve_kits')
for name,path in pairs(routes) do assert(links[name]==path) end
-- Q's pre-existing generic stun is unresolved; isolation must not invent its owner.
assert(type(enfos_vs_magic_missile.OnProjectileHit)=='function')
local h=require('abilities/shared/pve_helpers')
assert(h.get_agi(nil)==0)
assert(h.get_agi({IsNull=function()return true end,GetAgility=function()error('removed')end})==0)
assert(h.get_agi({GetAgility=function()error('engine error')end})==0)
assert(h.get_agi({GetAgility=function()return 73 end})==73)
assert(h.get_agi({GetAgility=function()return 'not numeric' end})==0)
print('Vengeful Spirit isolated bootstrap PASS')
`;
  const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
  assert.equal(r.status,0,r.stderr||r.stdout);
  assert.match(r.stdout,/Vengeful Spirit isolated bootstrap PASS/,r.stderr);
});
