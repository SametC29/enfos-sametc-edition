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
assert(grants:Apply(hero));assert(prints==2)
`;
  const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
  assert.equal(r.status,0,r.stderr);assert.equal(r.stderr,'');
});
test('Luna W uses native collisions and preserves bounded explicit rank and Shard values',()=>{
  const a=abilities.enfos_luna_lunar_orbit;
  assert.ok(isVerifiedNativeAbility('enfos_luna_lunar_orbit',a));
  assert.equal(a.MaxLevel,'10');assert.equal(a.RequiredLevel,'1');assert.equal(a.LevelsBetweenUpgrades,'1');
  assert.equal(a.HasShardUpgrade,'1');assert.equal(a.SpellDispellableType,'SPELL_DISPELLABLE_NO');
  const values=a.AbilityValues;
  assert.equal(values.rotating_glaives_duration.value,'8');
  assert.equal(values.rotating_glaives_damage_reduction.value,'25');
  assert.equal(values.rotating_glaives_damage_reduction.special_bonus_shard,'+10');
  assert.equal(values.bonus_movement_speed.special_bonus_shard,'+20');
  assert.equal(values.rotating_glaives.value,'4');
  for(const key of ['rotating_glaives_collision_damage','AbilityCooldown','AbilityManaCost'])
    assert.equal(values[key].value.split(' ').length,10,key);
  for(const key of ['pulse_interval','pulse_damage','agility_multiplier','bonus_range'])assert.equal(values[key],undefined);
  for(const source of readAbilitySources(abilities).values()){
    assert.doesNotMatch(source,/enfos_luna_lunar_orbit=class|modifier_enfos_luna_lunar_orbit_buff/);
  }
});
test('Luna native Shard routing excludes native Boss kit and other heroes',()=>{
  const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
local integration=require('abilities/heroes/luna/integration')
local hero={GetUnitName=function()return 'npc_dota_hero_luna' end,FindAbilityByName=function()return {} end}
assert(integration.UsesNativeShard(hero))
hero.FindAbilityByName=function()return nil end
assert(not integration.UsesNativeShard(hero))
hero.GetUnitName=function()return 'npc_dota_hero_lion' end
hero.FindAbilityByName=function()return {} end
assert(not integration.UsesNativeShard(hero))
`;
  const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
  assert.equal(r.status,0,r.stderr);assert.equal(r.stderr,'');
});
test('Native Orbit replaces Luna generic Shard speed and extra damage without changing other kits',()=>{
  const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
function LinkLuaModifier()end
function IsServer()return true end
local hits=0
function ApplyDamage()hits=hits+1 end
require('heroes/aghanim_manager')
local hero={GetUnitName=function()return 'npc_dota_hero_luna' end,
 FindAbilityByName=function(_,id)assert(id=='enfos_luna_lunar_orbit');return {} end,
 GetTeamNumber=function()return 2 end}
local target={IsNull=function()return false end,IsAlive=function()return true end,GetTeamNumber=function()return 3 end}
local mod=setmetatable({role='Carry',GetParent=function()return hero end},modifier_enfos_shard_upgrade)
assert(mod:GetModifierMoveSpeedBonus_Percentage()==0 and mod:IsHidden())
mod:OnAttackLanded({attacker=hero,target=target,damage=100});assert(hits==0)
hero.GetUnitName=function()return 'npc_dota_hero_luna' end
hero.FindAbilityByName=function()return nil end
assert(mod:GetModifierMoveSpeedBonus_Percentage()==15 and not mod:IsHidden(),'Native Boss kit must be unaffected')
hero.GetUnitName=function()return 'npc_dota_hero_drow_ranger' end
assert(mod:GetModifierMoveSpeedBonus_Percentage()==15)
mod:OnAttackLanded({attacker=hero,target=target,damage=100});assert(hits==1)
`;
  const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
  assert.equal(r.status,0,r.stderr);assert.equal(r.stderr,'');
});
