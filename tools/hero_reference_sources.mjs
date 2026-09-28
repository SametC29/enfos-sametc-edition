// Read-only installed-Valve evidence collection; never imports a custom-game kit.
// Optional host reader, like verify_particles.mjs; normal checks do not require it.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { pathToFileURL } from 'node:url';
import { parseKV } from './lib/kv.mjs';

const args = process.argv.slice(2);
const option = name => args[args.indexOf(name) + 1];
if (!args.includes('--write') || !args.includes('--dota-root') || !args.includes('--vpk-module')) {
  throw new Error('Use --write --dota-root <installed Dota root> --vpk-module <existing VPK reader module>');
}
const dotaRoot = path.resolve(option('--dota-root'));
const { Vpk } = await import(pathToFileURL(path.resolve(option('--vpk-module'))));
const archivePath = path.join(dotaRoot, 'game/dota/pak01_dir.vpk');
const archive = await Vpk.open(archivePath);
const sha = text => crypto.createHash('sha256').update(text).digest('hex');
const build = Object.fromEntries(fs.readFileSync(path.join(dotaRoot, 'game/dota/steam.inf'), 'utf8')
  .trim().split(/\r?\n/).map(line => { const i = line.indexOf('='); return [line.slice(0, i), line.slice(i + 1)]; }));
const heroes = parseKV(fs.readFileSync('game/scripts/npc/npc_heroes_custom.txt', 'utf8')).DOTAHeroes;

// Only direct scalar fields in DOTAHeroes/<id>; nested draft/facet/talent blocks
// cannot overwrite the actual hero slots. Native repeated nested KV keys are valid.
function directHeroFields(text, id) {
  const tokens = [...text.matchAll(/\/\/[^\r\n]*|"((?:\\.|[^"\\])*)"|([{}])/g)]
    .filter(m => !m[0].startsWith('//')).map(m => ({value: m[1] ?? m[2], quoted: m[1] !== undefined}));
  if (tokens[0]?.value !== 'DOTAHeroes' || tokens[2]?.value !== id) throw new Error(`Unexpected native root: ${id}`);
  const result = {};
  let depth = 0;
  for (let i = 0; i < tokens.length; i++) {
    const token = tokens[i];
    if (!token.quoted) { depth += token.value === '{' ? 1 : -1; continue; }
    if (depth === 2 && tokens[i + 1]?.quoted) {
      const key = token.value, val = tokens[++i].value;
      if (/^Ability\d+$/.test(key) || ['Model', 'SoundSet', 'AttributeStrengthGain', 'AttributeAgilityGain', 'AttributeIntelligenceGain'].includes(key)) {
        if (Object.hasOwn(result, key)) throw new Error(`Duplicate selected native scalar: ${id}/${key}`);
        result[key] = val;
      }
    }
  }
  return result;
}
const rows = [];
for (const [id, hero] of Object.entries(heroes).filter(([, h]) => h.Role)) {
  const source = `scripts/npc/heroes/${id}.txt`;
  if (!archive.entries.has(source.toLowerCase())) { rows.push({id, source, status: 'PENDING', reason: 'Native split hero file not found'}); continue; }
  const text = await archive.readText(source);
  rows.push({id, source, sha256: sha(text), status: 'FILE_VERIFIED', fields: directHeroFields(text, id)});
}
const sourcePaths = ['game/scripts/vscripts/abilities/pve_kits.lua', 'game/scripts/vscripts/addon_game_mode.lua', 'game/scripts/npc/npc_abilities_custom.txt'];
const resources = new Map();
for (const source of sourcePaths) {
  const text = fs.readFileSync(source, 'utf8');
  for (const m of text.matchAll(/["']((?:particles|models|soundevents)\/[^"'\r\n]+\.(?:vpcf|vmdl|vsndevts))["']/g)) {
    const resource = m[1];
    const row = resources.get(resource) || {resource, compiledPath: `${resource}_c`, present: archive.entries.has(`${resource}_c`.toLowerCase()), sources: []};
    row.sources.push({file: source, line: text.slice(0, m.index).split('\n').length});
    resources.set(resource, row);
  }
}
const snapshot = {schemaVersion: 1, observedAt: new Date().toISOString(), build,
  scope: 'Installed Valve hero scalar slots and literal asset existence only. No native counterpart mapping, CP semantics, sound-event validation or runtime acceptance. Dynamic resource paths are not covered.',
  archive: {file: 'game/dota/pak01_dir.vpk', sha256: sha(fs.readFileSync(archivePath))},
  heroes: rows, resources: [...resources.values()].sort((a,b) => a.resource.localeCompare(b.resource))};
fs.writeFileSync('docs/audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json', JSON.stringify(snapshot, null, 2) + '\n');
console.log(`Recorded ${rows.length} installed hero sources; ${resources.size} literal resources; ${[...resources.values()].filter(r => !r.present).length} missing archive entries. Runtime remains PENDING.`);
