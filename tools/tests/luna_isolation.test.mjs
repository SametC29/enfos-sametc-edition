import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import luaparse from 'luaparse';
import {parseKV} from '../lib/kv.mjs';
import {readAbilitySources} from '../lib/ability_sources.mjs';

const abilities = parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
const ids = [
  'enfos_luna_lucent_beam',
  'enfos_luna_lunar_orbit',
  'enfos_luna_lunar_blessing',
  'enfos_luna_eclipse',
  'enfos_luna_moon_glaives',
];
const slots = ['q','w','e','r','d'];

test('Luna KV resolves isolated classes once with five owned modifier routes', () => {
  const sources = readAbilitySources(abilities);
  const defined = new Map();
  for (const [file,source] of sources) for (const node of luaparse.parse(source).body) {
    if (node.type !== 'AssignmentStatement') continue;
    const name = node.variables[0]?.name;
    if (!name?.startsWith('enfos_luna_') && !name?.startsWith('modifier_enfos_luna_')) continue;
    assert.ok(!defined.has(name), `duplicate Luna class ${name}: ${file}`);
    defined.set(name,file);
  }
  ids.forEach((id,i)=>{
    assert.equal(abilities[id].ScriptFile,`abilities/heroes/luna/${slots[i]}`);
    assert.equal(defined.get(id),`game/scripts/vscripts/abilities/heroes/luna/${slots[i]}.lua`);
  });
  assert.equal([...defined.keys()].filter(id=>id.startsWith('modifier_enfos_luna_')).length,5);
  assert.ok(sources.has('game/scripts/vscripts/abilities/shared/pve_helpers.lua'));
  assert.ok(sources.has('game/scripts/vscripts/lib/hero_trace.lua'));
});

test('Luna modules cold-load independently and preserve shared bootstrap compatibility', () => {
  const script = `
package.path = 'game/scripts/vscripts/?.lua;' .. package.path
function class(t) t.__index=t; return t end
local links={}
function LinkLuaModifier(name,path)
  assert(not links[name], 'duplicate modifier registration '..name)
  links[name]=path
end
local routes=require('abilities/heroes/luna/init')
assert(package.loaded['abilities/pve_kits']==nil, 'isolated Luna depends on monolith')
local count=0
for name,path in pairs(routes) do
  count=count+1
  assert(links[name]==path)
  assert(type(_G[name])=='table')
  require(path)
end
assert(count==5)
assert(type(enfos_luna_lucent_beam.OnSpellStart)=='function')
assert(type(enfos_luna_lunar_orbit.OnSpellStart)=='function')
assert(type(enfos_luna_lunar_blessing.GetIntrinsicModifierName)=='function')
assert(type(enfos_luna_eclipse.OnSpellStart)=='function')
assert(type(enfos_luna_moon_glaives.OnProjectileHit_ExtraData)=='function')
assert(type(modifier_enfos_luna_lunar_blessing.IsAura)=='function')
require('abilities/pve_kits')
for name,path in pairs(routes) do assert(links[name]==path) end
assert(type(bulwark_shield_slam.OnSpellStart)=='function')
print('isolated Luna bootstrap PASS')
`;
  const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
  assert.equal(r.status,0,r.stderr || r.stdout);
  assert.match(r.stdout,/isolated Luna bootstrap PASS/);
});
