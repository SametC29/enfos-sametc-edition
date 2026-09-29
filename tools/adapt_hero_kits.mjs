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
    a.MaxLevel = '10';
    a.AbilityBehavior = 'DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | DOTA_ABILITY_BEHAVIOR_AOE';
    a.AbilityUnitDamageType = 'DAMAGE_TYPE_MAGICAL';
    a.AbilityCastRange = '600';
    a.AbilityCastAnimation = 'ACT_DOTA_CAST_ABILITY_1';
    a.AbilityCooldown = '16 15.5 15 14.5 14 13.5 13 12.5 12 11';
    a.AbilityManaCost = '80 85 90 95 100 105 110 115 120 125';
    a.AbilitySpecial = {
      '01': { var_type: 'FIELD_INTEGER', radius: '250 260 270 280 290 300 310 320 330 340' },
      '02': { var_type: 'FIELD_INTEGER', damage: '140 175 210 245 280 315 350 390 430 470' },
      '03': { var_type: 'FIELD_FLOAT', stun_duration: '1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9' },
      '04': { var_type: 'FIELD_FLOAT', boss_stun_cap: '0.6' },
      '05': { var_type: 'FIELD_INTEGER', bolt_speed: '1000' },
    };
  }
  if (id === 'bulwark_challenge') {
    a.MaxLevel = '10';
    a.AbilityCastAnimation = 'ACT_DOTA_OVERRIDE_ABILITY_3';
    a.AbilityCooldown = '18 17.5 17 16.5 16 15.5 15 14.5 14 13.5';
    a.AbilityManaCost = '65 70 75 80 85 90 95 100 105 110';
    a.AbilitySpecial = {
      '01': { var_type: 'FIELD_INTEGER', radius: '500' },
      '02': { var_type: 'FIELD_INTEGER', bonus_armor: '6 8 10 12 14 16 18 20 22 24' },
      '03': { var_type: 'FIELD_FLOAT', duration: '3.0 3.5 4.0 4.5 5.0 5.5 6.0 6.5 7.0 7.5' },
      '04': { var_type: 'FIELD_INTEGER', bonus_ms_pct: '15 17 19 21 23 25 27 29 31 33' },
      '05': { var_type: 'FIELD_INTEGER', barrier_hp: '100 150 200 250 300 350 400 450 500 550' },
      '06': { var_type: 'FIELD_INTEGER', boss_taunt_pct: '25' },
    };
  }
  if (id === 'bulwark_iron_guard') {
    a.MaxLevel = '10';
    a.AbilitySpecial = {
      '01': { var_type: 'FIELD_INTEGER', cleave_pct: '30 37 44 51 58 65 72 78 84 90' },
      '02': { var_type: 'FIELD_INTEGER', cleave_starting_width: '150' },
      '03': { var_type: 'FIELD_INTEGER', cleave_ending_width: '240 253 266 280 293 306 320 333 346 360' },
      '04': { var_type: 'FIELD_INTEGER', cleave_distance: '400 433 467 500 533 567 600 633 667 700' },
    };
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
