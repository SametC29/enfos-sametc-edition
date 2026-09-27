import fs from 'node:fs';
import { parseKV } from './lib/kv.mjs';

const heroes = parseKV(fs.readFileSync('game/scripts/npc/npc_heroes_custom.txt', 'utf8')).DOTAHeroes;
const tokens = JSON.parse(fs.readFileSync('localization/english.json', 'utf8')).Tokens;
const rows = Object.entries(heroes).filter(([, v]) => v.Role).map(([id, v]) => ({
  id, name: tokens[id] || id, role: v.Role, primary: v.AttributePrimary,
  abilities: [1, 2, 3, 4, 5].map(n => v['Ability' + n]),
}));
const output = '-- Generated from npc_heroes_custom.txt by tools/roster.mjs.\nreturn {\n' + rows.map(v =>
  '  { id=' + JSON.stringify(v.id) + ', name=' + JSON.stringify(v.name) + ', role=' + JSON.stringify(v.role) +
  ', primary=' + JSON.stringify(v.primary) + ', abilities={' + v.abilities.map(x => JSON.stringify(x)).join(',') + '} },'
).join('\n') + '\n}\n';
const file = 'game/scripts/vscripts/heroes/roster.lua';
if (process.argv.includes('--check')) {
  if (fs.readFileSync(file, 'utf8') !== output) throw new Error('Stale server roster: run node tools/roster.mjs');
} else fs.writeFileSync(file, output);
