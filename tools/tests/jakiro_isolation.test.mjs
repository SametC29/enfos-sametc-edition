import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import luaparse from 'luaparse';
import {parseKV} from '../lib/kv.mjs';
import {readAbilitySources} from '../lib/ability_sources.mjs';

const abilities=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
const ids=['dual_breath','ice_path','liquid_fire','macropyre','double_trouble'].map(x=>'enfos_jakiro_'+x);
const slots=['q','w','e','r','d'];

test('Jakiro production slots resolve unique isolated classes and shared dependencies',()=>{
  const sources=readAbilitySources(abilities),defined=new Map();
  for(const [file,source] of sources) for(const node of luaparse.parse(source).body){
    if(node.type!=='AssignmentStatement')continue;
    const name=node.variables[0]?.name;
    if(!name?.startsWith('enfos_jakiro_')&&!name?.startsWith('modifier_enfos_jakiro_'))continue;
    assert.ok(!defined.has(name),`duplicate class ${name}`);defined.set(name,file);
  }
  ids.forEach((id,i)=>{
    assert.equal(abilities[id].ScriptFile,`abilities/heroes/jakiro/${slots[i]}`);
    assert.equal(defined.get(id),`game/scripts/vscripts/${abilities[id].ScriptFile}.lua`);
  });
  assert.equal([...defined.keys()].filter(x=>x.startsWith('modifier_')).length,7);
  assert.ok(sources.has('game/scripts/vscripts/abilities/shared/pve_helpers.lua'));
});

test('Jakiro cold-loads without monolith and bootstrap cannot relink its modifiers',()=>{
  const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t) t.__index=t;return t end
local links={}
function LinkLuaModifier(name,path)
 assert(not links[name],'duplicate modifier link '..name);links[name]=path
end
local routes=require('abilities/heroes/jakiro/init')
assert(not package.loaded['abilities/pve_kits'],'isolated kit imports monolith')
local count=0
for name,path in pairs(routes) do
 count=count+1;assert(links[name]==path);assert(type(_G[name])=='table');require(path)
end
assert(count==7)
${ids.map(id=>`assert(type(${id})=='table')`).join('\n')}
require('abilities/pve_kits')
for name,path in pairs(routes) do assert(links[name]==path) end
assert(type(enfos_jakiro_ice_path.OnSpellStart)=='function')
local h=require('abilities/shared/pve_helpers')
assert(type(h.effect)=='function' and type(h.ground_effect)=='function' and type(h.remove_ground_effect)=='function')
function IsServer() return true end
local spawned,removed,released={}, {}, {}
function CreateModifierThinker(c,a,m,p,pos,team,phantom)
 assert(team==2 and phantom==false)
 local e={IsNull=function(self)return self.removed==true end}
 spawned[#spawned+1]=e;return e
end
function UTIL_Remove(e) e.removed=true;removed[#removed+1]=e end
local caster={GetTeamNumber=function()return 2 end}
local ability={}
for i=1,20 do h.ground_effect(caster,ability,'zone',{}, {}) end
assert(#ability.enfosGroundEffects==3 and #removed==17 and #spawned==20)
assert(ability.enfosGroundEffects[1]==spawned[18] and ability.enfosGroundEffects[3]==spawned[20])
spawned[18].removed=true
h.ground_effect(caster,ability,'zone',{}, {})
assert(#ability.enfosGroundEffects==3 and #removed==17, 'prune removed handles without double-remove')
h.remove_ground_effect({GetParent=function()return spawned[21] end})
assert(spawned[21].removed and #removed==18)
ParticleManager={CreateParticle=function(self,path,attach,target)return 71 end,
 ReleaseParticleIndex=function(self,id) released[#released+1]=id end}
h.effect('native',caster);h.effect('native',nil)
assert(#released==1 and released[1]==71)
print('Jakiro isolated bootstrap PASS')
`;
  const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
  assert.equal(r.status,0,r.stderr||r.stdout);
  assert.match(r.stdout,/Jakiro isolated bootstrap PASS/,r.stderr);
});
