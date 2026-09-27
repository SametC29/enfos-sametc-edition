// Connect the independently authored Lua implementations to their stable KV IDs.
import fs from 'node:fs';
import { parseKV } from './lib/kv.mjs';

const file = 'game/scripts/npc/npc_abilities_custom.txt';
let text = fs.readFileSync(file, 'utf8');
const abilities = parseKV(text).DOTAAbilities;
const heroes = parseKV(fs.readFileSync('game/scripts/npc/npc_heroes_custom.txt', 'utf8')).DOTAHeroes;
const source = fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua', 'utf8');

const ids = [...source.matchAll(/^(\w+)\s*=\s*(?:\w+\s*or\s*)?class\(\{\}\)/gm)]
  .map(m => m[1])
  .filter(id => !id.startsWith('modifier_'));

console.log(`Found ${ids.length} ability classes in pve_kits.lua:`, ids);

function serialize(object, depth) {
  const pad = '\t'.repeat(depth);
  return Object.entries(object).map(([k, v]) => typeof v === 'object'
    ? `${pad}"${k}"\n${pad}{\n${serialize(v, depth + 1)}\n${pad}}`
    : `${pad}"${k}" "${v}"`).join('\n');
}

function special(a, name, value, type = 'FIELD_INTEGER') {
  if (!a.AbilitySpecial) a.AbilitySpecial = {};
  const entry = Object.values(a.AbilitySpecial).find(v => name in v);
  if (entry) entry[name] = value;
  else a.AbilitySpecial[String(Object.keys(a.AbilitySpecial).length + 1).padStart(2, '0')] = { var_type: type, [name]: value };
}

const ultimates = new Set(Object.values(heroes).map(h => h.Ability4));

for (const id of new Set([...ids, ...ultimates])) {
  const a = abilities[id];
  if (!a) {
    console.warn('Warning: Missing definition ' + id);
    continue;
  }
  if (ids.includes(id)) {
    a.BaseClass = 'ability_lua';
    a.ScriptFile = 'abilities/pve_kits';
    for (const key of Object.keys(a)) {
      if (key.startsWith('On') || ['Modifiers', 'Orb'].includes(key)) delete a[key];
    }
  }
  if (ultimates.has(id)) a.AbilityType = 'DOTA_ABILITY_TYPE_ULTIMATE';

  // Tuning specials
  if (id === 'bulwark_shield_slam') {
    special(a, 'radius', '400');
    special(a, 'damage', '140 220 300 380');
    special(a, 'slow_duration', '3.0', 'FIELD_FLOAT');
    special(a, 'slow_pct', '-50');
  }
  if (id === 'bulwark_iron_guard') {
    special(a, 'bonus_armor', '8 14 20 26');
    special(a, 'damage_block', '35 55 75 95');
  }
  if (id === 'bulwark_fortress') {
    special(a, 'duration', '8.0', 'FIELD_FLOAT');
    special(a, 'damage_reduction_pct', '30 40 50 60');
    special(a, 'shockwave_damage', '100 160 220 280');
    special(a, 'radius', '450');
  }
  if (id === 'bulwark_unbreakable') {
    special(a, 'cleave_pct', '40 60 80');
    special(a, 'gods_strength_duration', '20.0', 'FIELD_FLOAT');
    special(a, 'bonus_damage_pct', '120 170 220');
  }
  if (id === 'enfos_juggernaut_blade_fury') {
    special(a, 'status_resistance', '70');
  }
  if (id === 'enfos_juggernaut_healing_ward') {
    special(a, 'duration', '12.0', 'FIELD_FLOAT');
    special(a, 'radius', '500');
    special(a, 'heal_pct', '3 4 5 6');
  }
  if (id === 'enfos_drow_frost_arrows') {
    a.AbilityBehavior = 'DOTA_ABILITY_BEHAVIOR_PASSIVE';
    a.AbilityManaCost = '0';
    special(a, 'agility_factor', '0.25 0.35 0.45 0.55', 'FIELD_FLOAT');
  }
  if (id === 'enfos_drow_gust') {
    special(a, 'wave_speed', '1200');
    special(a, 'wave_distance', '1000');
    special(a, 'silence_duration', '3.0 4.0 5.0 6.0', 'FIELD_FLOAT');
  }
  if (id === 'enfos_drow_multishot') {
    special(a, 'arrow_damage_pct', '70 85 100 115');
  }
  if (id === 'enfos_lina_dragon_slave') {
    special(a, 'damage', '180 280 380 480');
    special(a, 'dragon_slave_distance', '1200');
  }
  if (id === 'enfos_lina_light_strike_array') {
    special(a, 'radius', '350');
    special(a, 'damage', '150 230 310 390');
    special(a, 'stun_duration', '2.0 2.4 2.8 3.2', 'FIELD_FLOAT');
  }
  if (id === 'enfos_omni_purification') {
    special(a, 'heal_amount', '180 300 420 540');
    special(a, 'radius', '400');
  }
  if (id === 'enfos_omni_repel') {
    special(a, 'duration', '8.0', 'FIELD_FLOAT');
    special(a, 'bonus_hp_regen', '15 25 35 45');
    special(a, 'bonus_strength', '12 20 28 36');
    special(a, 'bonus_armor', '6 9 12 15');
  }
  if (id === 'enfos_omni_degen_aura') {
    special(a, 'radius', '500');
    special(a, 'slow_pct', '-25 -35 -45 -55');
    special(a, 'attack_slow', '-30 -45 -60 -75');
  }
  if (id === 'enfos_omni_hammer_of_purity') {
    special(a, 'bonus_pure_damage', '80 140 200 260');
  }
  if (id === 'enfos_luna_lucent_beam') {
    special(a, 'beam_damage', '150 250 350 450');
    special(a, 'stun_duration', '0.4', 'FIELD_FLOAT');
  }
  if (id === 'enfos_luna_moon_glaives') {
    a.AbilityBehavior = 'DOTA_ABILITY_BEHAVIOR_PASSIVE';
    special(a, 'bounce_count', '4 6 8 10');
  }
  if (id === 'enfos_luna_lunar_blessing') {
    a.AbilityBehavior = 'DOTA_ABILITY_BEHAVIOR_PASSIVE | DOTA_ABILITY_BEHAVIOR_AURA';
    special(a, 'bonus_damage', '20 35 50 65');
  }
  if (id === 'enfos_luna_eclipse') {
    a.AbilityBehavior = 'DOTA_ABILITY_BEHAVIOR_NO_TARGET';
    special(a, 'radius', '750');
    special(a, 'duration', '6.0', 'FIELD_FLOAT');
  }
  if (id === 'enfos_luna_lunar_orbit') {
    a.AbilityBehavior = 'DOTA_ABILITY_BEHAVIOR_NO_TARGET | DOTA_ABILITY_BEHAVIOR_IMMEDIATE';
    special(a, 'duration', '8.0', 'FIELD_FLOAT');
  }

  const start = text.indexOf('"' + id + '"');
  if (start === -1) {
    console.warn(`Ability ${id} not found in text, appending.`);
    text += `\n\t"${id}"\n\t{\n${serialize(a, 2)}\n\t}`;
    continue;
  }
  const open = text.indexOf('{', start);
  let depth = 1, end = open + 1;
  while (depth && end < text.length) {
    if (text[end] === '{') depth++;
    if (text[end] === '}') depth--;
    end++;
  }
  text = text.slice(0, start) + `"${id}"\n\t{\n${serialize(a, 2)}\n\t}` + text.slice(end);
}

fs.writeFileSync(file, text);
console.log('Successfully wired ' + ids.length + ' Lua abilities in npc_abilities_custom.txt');
