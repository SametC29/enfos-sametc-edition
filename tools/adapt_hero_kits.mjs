// Connect the independently authored Lua implementations to their stable KV IDs.
import fs from 'node:fs';
import { parseKV } from './lib/kv.mjs';
const file = 'game/scripts/npc/npc_abilities_custom.txt';
let text = fs.readFileSync(file, 'utf8');
const abilities = parseKV(text).DOTAAbilities;
const heroes = parseKV(fs.readFileSync('game/scripts/npc/npc_heroes_custom.txt', 'utf8')).DOTAHeroes;
const source = fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua', 'utf8');
const ids = [...source.matchAll(/^(\w+)=class\(\{\}\)/gm)].map(m => m[1]).filter(id => !id.startsWith('modifier_'));
function serialize(object, depth) {
  const pad = '\t'.repeat(depth);
  return Object.entries(object).map(([k, v]) => typeof v === 'object'
    ? `${pad}"${k}"\n${pad}{\n${serialize(v, depth + 1)}\n${pad}}`
    : `${pad}"${k}" "${v}"`).join('\n');
}
function special(a, name, value, type = 'FIELD_INTEGER') {
  const entry = Object.values(a.AbilitySpecial).find(v => name in v);
  if (entry) entry[name] = value;
  else a.AbilitySpecial[String(Object.keys(a.AbilitySpecial).length + 1).padStart(2, '0')] = { var_type: type, [name]: value };
}
const ultimates = new Set(Object.values(heroes).map(h => h.Ability4));
for (const id of new Set([...ids, ...ultimates])) {
  const a = abilities[id];
  if (!a) throw new Error('Missing definition ' + id);
  if (ids.includes(id)) {
    a.BaseClass = 'ability_lua'; a.ScriptFile = 'abilities/pve_kits';
    for (const key of Object.keys(a)) if (key.startsWith('On') || ['Modifiers', 'Orb'].includes(key)) delete a[key];
  }
  if (ultimates.has(id)) a.AbilityType = 'DOTA_ABILITY_TYPE_ULTIMATE';
  if (id === 'enfos_juggernaut_blade_fury') special(a, 'status_resistance', '50');
  if (id === 'enfos_drow_frost_arrows') {
    a.AbilityBehavior = 'DOTA_ABILITY_BEHAVIOR_PASSIVE'; a.AbilityManaCost = '0';
    special(a, 'agility_factor', '0.25 0.35 0.45 0.55', 'FIELD_FLOAT');
  }
  if (id === 'enfos_drow_multishot') special(a, 'arrow_damage_pct', '70 85 100 115');
  const start = text.indexOf('"' + id + '"');
  const open = text.indexOf('{', start); let depth = 1, end = open + 1;
  while (depth && end < text.length) { if (text[end] === '{') depth++; if (text[end] === '}') depth--; end++; }
  text = text.slice(0, start) + `"${id}"\n\t{\n${serialize(a, 2)}\n\t}` + text.slice(end);
}
fs.writeFileSync(file, text);
console.log('Wired ' + ids.length + ' Lua abilities.');
