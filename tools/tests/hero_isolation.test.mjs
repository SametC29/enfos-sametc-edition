import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import luaparse from 'luaparse';
import {parseKV} from '../lib/kv.mjs';
import {readAbilitySources} from '../lib/ability_sources.mjs';

const abilities = parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
const ids = ['frost_blast','frost_shield','sinister_gaze','chain_frost','ice_aura'].map(id=>'enfos_lich_'+id);
const slots = ['q','w','e','r','d'];

test('Lich KV resolves isolated classes once, with reachable shared dependencies', () => {
  const sources = readAbilitySources(abilities);
  const defined = new Map();
  for (const [file,source] of sources) for (const node of luaparse.parse(source).body) {
    if(node.type !== 'AssignmentStatement') continue;
    const name = node.variables[0]?.name;
    if (!name?.startsWith('enfos_lich_') && !name?.startsWith('modifier_enfos_lich_')) continue;
    assert.ok(!defined.has(name),`duplicate class ${name}: ${file}`);
    defined.set(name,file);
  }
  ids.forEach((id,i)=>{
    assert.equal(abilities[id].ScriptFile,`abilities/heroes/lich/${slots[i]}`);
    assert.equal(defined.get(id),`game/scripts/vscripts/${abilities[id].ScriptFile}.lua`);
  });
  assert.equal([...defined.keys()].filter(id=>id.startsWith('modifier_')).length,6);
  assert.ok(sources.has('game/scripts/vscripts/abilities/shared/pve_helpers.lua'));
  assert.ok(sources.has('game/scripts/vscripts/lib/hero_trace.lua'));
});

test('Lich modules cold-load independently and preserve the shared bootstrap registration path', () => {
  const script = `
package.path = 'game/scripts/vscripts/?.lua;' .. package.path
function class(t) t.__index=t; return t end
local links={}
function LinkLuaModifier(name,path)
  assert(not links[name], 'duplicate modifier registration '..name)
  links[name]=path
end
local routes=require('abilities/heroes/lich/init')
assert(package.loaded['abilities/pve_kits']==nil, 'isolated hero depends on monolith')
local count=0
for name,path in pairs(routes) do
  count=count+1
  assert(links[name]==path)
  assert(type(_G[name])=='table')
  require(path)
end
assert(count==6)
${ids.map(id=>`assert(type(${id})=='table')`).join('\n')}
assert(type(enfos_lich_frost_blast.OnSpellStart)=='function')
assert(type(enfos_lich_sinister_gaze.OnChannelFinish)=='function')
assert(type(modifier_enfos_lich_ice_aura_buff.GetModifierPhysicalArmorBonus)=='function')
require('abilities/pve_kits')
for name,path in pairs(routes) do assert(links[name]==path) end
assert(type(bulwark_shield_slam.OnSpellStart)=='function')
print('isolated Lich bootstrap PASS')
`;
  const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
  assert.equal(r.status,0,r.stderr || r.stdout);
  assert.match(r.stdout,/isolated Lich bootstrap PASS/);
});
