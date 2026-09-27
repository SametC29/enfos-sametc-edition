import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { parseKV } from './lib/kv.mjs';
const server = process.env.DOTA2_WORKSHOP_MCP_DIR || 'C:/Users/samet/.gemini/antigravity/mcp/dota2_workshop_mcp';
const dota = process.env.DOTA2_PATH || 'C:/Program Files (x86)/Steam/steamapps/common/dota 2 beta';
const { Vpk } = await import(pathToFileURL(path.join(server, 'dist/dota/vpk.js')));
const valve = await Vpk.open(path.join(dota, 'game/dota/pak01_dir.vpk'));
const read = p => fs.readFileSync(p, 'utf8');
const abilities = parseKV(read('game/scripts/npc/npc_abilities_custom.txt')).DOTAAbilities;
const heroes = parseKV(read('game/scripts/npc/npc_heroes_custom.txt')).DOTAHeroes;
const items = parseKV(read('game/scripts/npc/npc_items_custom.txt')).DOTAItems;
const report = { heroCount: Object.keys(heroes).length, abilities: [], items: [], missingAssets: [] };
function walk(p) { return fs.readdirSync(p, { withFileTypes: true }).flatMap(e => e.isDirectory() ? walk(path.join(p, e.name)) : [path.join(p, e.name)]); }
const files = [...walk('game/scripts/vscripts'), 'game/scripts/npc/npc_abilities_custom.txt', 'game/scripts/npc/npc_items_custom.txt'];
const assets = new Map();
for (const file of files) for (const m of read(file).matchAll(/["'](particles\/[^"']+\.vpcf)["']/g)) {
  if (!assets.has(m[1])) assets.set(m[1], []);
  assets.get(m[1]).push(file);
}
for (const [asset, files] of assets) if (!valve.entries.has(asset + '_c') && !fs.existsSync('game/' + asset + '_c')) report.missingAssets.push({ asset, files: [...new Set(files)] });
const ignoredActions = new Set(['FireSound','AttachEffect','RemoveEffect','FireEffect']);
function meaningful(v) {
  return Object.entries(v || {}).some(([k, x]) => !ignoredActions.has(k) && (typeof x !== 'object' || meaningful(x)));
}
for (const [id, a] of Object.entries(abilities)) {
  const passive = (a.AbilityBehavior || '').includes('PASSIVE');
  const modifiers = Object.values(a.Modifiers || {});
  const implemented = a.BaseClass === 'ability_lua' || (passive
    ? modifiers.some(m => m.Properties || m.States || m.IsAura || Object.keys(m).some(k => k.startsWith('On')))
    : Object.entries(a).some(([k, v]) => k.startsWith('On') && meaningful(v)));
  report.abilities.push({ id, base: a.BaseClass, passive, needsImplementation: !implemented });
  const icon = 'panorama/images/spellicons/' + a.AbilityTextureName + '_png.vtex_c';
  if (a.AbilityTextureName && !valve.entries.has(icon)) report.missingAssets.push({ asset: icon, files: [id] });
}
for (const [id, a] of Object.entries(items)) if (id.startsWith('item_ascended_')) report.items.push({ id, active: !(a.AbilityBehavior || '').includes('PASSIVE'), hasCastHandler: !!a.OnSpellStart || a.BaseClass === 'item_lua' });
fs.mkdirSync('docs/audit', { recursive: true });
fs.writeFileSync('docs/audit/content-audit.json', JSON.stringify(report, null, 2) + '\n');
console.log(JSON.stringify({ heroes: report.heroCount, abilities: report.abilities.length, emptyAbilities: report.abilities.filter(a => a.needsImplementation).map(a => a.id), activeItemsWithoutHandler: report.items.filter(i => i.active && !i.hasCastHandler).map(i => i.id), missingAssets: report.missingAssets }, null, 2));
