import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {parseKV} from '../lib/kv.mjs';
import {isVerifiedNativeAbility} from '../lib/native_hero_abilities.mjs';
const all=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
const hero=parseKV(fs.readFileSync('game/scripts/npc/npc_heroes_custom.txt','utf8')).DOTAHeroes.npc_dota_hero_bristleback;
const id='enfos_bb_warpath',d=all[id];
const source=JSON.parse(fs.readFileSync('docs/audit/BRISTLEBACK_NATIVE_SOURCE_2026-10-04.json','utf8')).abilities.bristleback_warpath;

test('Warpath has one reviewed native owner, no Lua buff or ultimate slot collision',()=>{
  assert.ok(isVerifiedNativeAbility(id,d));
  assert.equal(d.AbilityBehavior,source.AbilityBehavior);
  assert.equal(d.SpellDispellableType,source.SpellDispellableType);
  assert.equal(d.IsBreakable,source.IsBreakable);
  assert.equal(d.AbilityCastAnimation,source.AbilityCastAnimation);
  assert.equal(d.AbilityType,'DOTA_ABILITY_TYPE_BASIC');
  assert.equal(hero.Ability5,id);
  assert.equal(hero.Ability4,'enfos_bb_hairball');
  assert.equal(all.bristleback_warpath,undefined);
  const lua=fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8');
  assert.doesNotMatch(lua,/enfos_bb_warpath\s*=\s*class|modifier_enfos_bb_warpath_(?:passive|buff)/);
  assert.equal(isVerifiedNativeAbility(id,{...d,ScriptFile:'abilities/pve_kits'}),false);
  assert.equal(isVerifiedNativeAbility('unreviewed',{BaseClass:'bristleback_warpath'}),false);
});

test('Warpath retains paid ten-rank tuning using native keys and suppresses facet attack-speed substitution',()=>{
  assert.equal(d.MaxLevel,'10');assert.equal(d.RequiredLevel,'1');assert.equal(d.LevelsBetweenUpgrades,'1');
  assert.equal(d.Innate,undefined);
  const v=d.AbilityValues;
  assert.equal(v.damage_per_stack,'15 17 19 22 24 26 28 31 33 35');
  assert.equal(v.move_speed_per_stack,'2 2.2 2.4 2.7 2.9 3.1 3.3 3.6 3.8 4');
  for(const key of Object.keys(v)) assert.ok(Object.hasOwn(source.AbilityValues,key),`${key} is declared by the installed native source`);
  assert.equal(v.aspd_per_stack,'0');assert.equal(v.max_stacks,'10');assert.equal(v.stack_duration,'10.0');
  assert.equal(v.ms_per_stack,undefined);
  for(const lang of ['english','turkish','russian','schinese']){
    const desc=JSON.parse(fs.readFileSync(`localization/${lang}.json`,'utf8')).Tokens[`DOTA_Tooltip_Ability_${id}_Description`];
    assert.ok(desc.includes('{{move_speed_per_stack}}'));
    assert.ok(!desc.includes('{{ms_per_stack}}'));
  }
});
