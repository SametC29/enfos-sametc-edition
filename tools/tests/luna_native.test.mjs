import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import luaparse from 'luaparse';
import {spawnSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';
import {isVerifiedNativeAbility} from '../lib/native_hero_abilities.mjs';
import {readAbilitySources} from '../lib/ability_sources.mjs';

const abilities=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
const id='enfos_luna_moon_glaives';
test('Luna D owns no custom attack, projectile or modifier replica',()=>{
  assert.ok(isVerifiedNativeAbility(id,abilities[id]));
  const native=JSON.parse(fs.readFileSync('docs/audit/LUNA_NATIVE_SOURCE_2026-10-03.json','utf8'));
  assert.ok(native.abilities[abilities[id].BaseClass]);
  assert.equal(abilities[id].HasShardUpgrade,undefined);
  for(const [path,source] of readAbilitySources(abilities)) {
    const ast=luaparse.parse(source);
    for(const n of ast.body) if(n.type==='AssignmentStatement') {
      assert.notEqual(n.variables[0]?.name,id,`${path}: obsolete Lua class`);
      assert.notEqual(n.variables[0]?.name,'modifier_enfos_luna_moon_glaives_passive',`${path}: obsolete attack hook`);
    }
  }
});
test('Luna native D preserves authored bounded ten-rank bounce progression and ordinary rules',()=>{
  const a=abilities[id];
  assert.equal(a.MaxLevel,'10');assert.equal(a.RequiredLevel,'1');assert.equal(a.LevelsBetweenUpgrades,'1');
  assert.equal(a.Innate,undefined);assert.equal(a.IsBreakable,'1');
  assert.equal(a.SpellImmunityType,'SPELL_IMMUNITY_ENEMIES_YES');
  assert.deepEqual(a.AbilityValues.bounces.split(' ').map(Number),[4,6,8,10,11,12,13,14,15,16]);
  assert.equal(a.AbilityValues.damage_reduction_percent,'15');assert.equal(a.AbilityValues.range,'500');
  assert.equal(a.AbilityValues.bonus_damage,undefined);assert.equal(a.AbilityValues.bounce_count,undefined);
});
test('Native ownership cannot mask missing Lua or an unreviewed BaseClass',()=>{
  assert.equal(isVerifiedNativeAbility(id,{BaseClass:'ability_lua'}),false);
  assert.equal(isVerifiedNativeAbility('unreviewed',{BaseClass:'luna_moon_glaive'}),false);
  assert.equal(isVerifiedNativeAbility(id,{BaseClass:'luna_moon_glaive',ScriptFile:'abilities/pve_kits'}),false);
});
test('Luna D free-rank restore never consumes points, resets paid ranks or duplicates the ability',()=>{
  const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function IsServer() return true end
local prints=0
print=function() prints=prints+1 end
local ability={rank=0,GetLevel=function(self)return self.rank end,SetLevel=function(self,n)self.rank=n end}
local hero={points=5,IsNull=function()return false end,IsRealHero=function()return true end,
 IsIllusion=function()return false end,GetUnitName=function()return 'npc_dota_hero_luna' end,
 FindAbilityByName=function(_,id)assert(id=='enfos_luna_moon_glaives');return ability end}
local grants=require('heroes/innates')
assert(grants:Apply(hero));assert(ability.rank==1 and hero.points==5)
ability.rank=10
assert(grants:Apply(hero));assert(ability.rank==10 and hero.points==5)
assert(prints==0,'Trace must remain default off')
require('lib/hero_trace'):SetEnabled(true)
assert(grants:Apply(hero));assert(prints==1)
`;
  const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
  assert.equal(r.status,0,r.stderr);assert.equal(r.stderr,'');
});
