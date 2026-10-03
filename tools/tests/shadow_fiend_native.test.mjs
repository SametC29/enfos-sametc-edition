import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {parseKV} from '../lib/kv.mjs';
import {getAbilityValues} from '../lib/ability_values.mjs';
import {isVerifiedNativeAbility} from '../lib/native_hero_abilities.mjs';
import {readAbilitySources} from '../lib/ability_sources.mjs';

const all=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
const id='enfos_sf_presence_of_the_dark_lord',e=all[id];
const native=JSON.parse(fs.readFileSync('docs/audit/SHADOW_FIEND_NATIVE_SOURCE_2026-10-04.json','utf8')).abilities.nevermore_dark_lord;

test('SF Presence delegates to a reviewed native aura without Lua classes or modifier replicas',()=>{
  assert.ok(isVerifiedNativeAbility(id,e));
  assert.equal(e.BaseClass,'nevermore_dark_lord');
  assert.equal(e.AbilityBehavior,native.AbilityBehavior);
  assert.equal(e.AbilityUnitTargetTeam,native.AbilityUnitTargetTeam);
  assert.equal(e.SpellImmunityType,native.SpellImmunityType);
  assert.equal(e.IsBreakable,native.IsBreakable);
  assert.equal(e.AbilityCastAnimation,native.AbilityCastAnimation);
  for(const [path,source]of readAbilitySources(all)){
    assert.doesNotMatch(source,/enfos_sf_presence_of_the_dark_lord\s*=\s*class|modifier_enfos_sf_presence_(?:aura|debuff)/,path);
  }
});

test('native Presence tuning preserves the authored ten-rank armor magnitudes and radii',()=>{
  const values=getAbilityValues(e);
  assert.deepEqual(values.presence_armor_reduction.split(' ').map(Number),[-4,-6,-8,-10,-11,-12,-13,-14,-15,-16]);
  assert.deepEqual(values.presence_radius.split(' ').map(Number),[900,950,1000,1050,1100,1150,1200,1250,1300,1350]);
  assert.equal(e.AbilityValues.presence_radius.affected_by_aoe_increase,native.AbilityValues.presence_radius.affected_by_aoe_increase);
  assert.equal(e.MaxLevel,'10');assert.equal(e.RequiredLevel,'1');assert.equal(e.LevelsBetweenUpgrades,'1');
  assert.equal(e.Innate,undefined);
  assert.equal(e.AbilityValues.armor_reduction,undefined);assert.equal(e.AbilityValues.radius,undefined);
  assert.equal(values.bonus_armor_per_stack,'0');assert.equal(values.kill_buff_duration,'0');
});

test('SF native exception cannot hide missing Lua classes or alter ordinary Boss identifiers',()=>{
  assert.equal(isVerifiedNativeAbility(id,{BaseClass:'ability_lua'}),false);
  assert.equal(isVerifiedNativeAbility('nevermore_dark_lord',native),false);
  assert.equal(all.nevermore_dark_lord,undefined);
  for(const lang of ['english','turkish','russian','schinese']){
    const tokens=JSON.parse(fs.readFileSync(`localization/${lang}.json`,'utf8')).Tokens;
    const description=tokens[`DOTA_Tooltip_Ability_${id}_Description`];
    assert.ok(description.includes('{{presence_armor_reduction|abs}}'));
    assert.ok(description.includes('{{presence_radius}}'));
    assert.doesNotMatch(description,/%armor_shred%/);
  }
});
