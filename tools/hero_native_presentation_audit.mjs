import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {parseKV} from './lib/kv.mjs';

const args = process.argv.slice(2);
function option(key) {
  const index = args.indexOf(key);
  if (index < 0 || !args[index + 1]) throw new Error(`Missing ${key}`);
  return args[index + 1];
}
const dota = option('--dota-root');
const {Vpk} = await import(pathToFileURL(path.resolve(option('--vpk-module'))));
const archive = await Vpk.open(path.join(dota, 'game/dota/pak01_dir.vpk'));
const build = fs.readFileSync(path.join(dota, 'game/dota/steam.inf'), 'utf8').trim();
const heroes = parseKV(fs.readFileSync('game/scripts/npc/npc_heroes_custom.txt', 'utf8')).DOTAHeroes;
const custom = parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt', 'utf8')).DOTAAbilities;
const fields = ['AbilityBehavior', 'AbilityCastAnimation', 'AbilityChannelAnimation', 'AbilitySound'];

// Isolate the native AbilityDefinitions subtree. Hero Bot/Loadout legitimately
// repeats item keys, so the project's strict parser must not parse the whole file.
function definitions(text) {
  const tokens = [...text.matchAll(/\/\/[^\r\n]*|"((?:\\.|[^"\\])*)"|([{}])/g)].filter(m => !m[0].startsWith('//'));
  const index = tokens.findIndex(t => t[1] === 'AbilityDefinitions');
  if (index < 0 || tokens[index + 1]?.[2] !== '{') throw new Error('Native AbilityDefinitions subtree missing');
  let depth = 0;
  for (let i = index + 1; i < tokens.length; i++) {
    if (tokens[i][2] === '{') depth++;
    if (tokens[i][2] === '}') depth--;
    if (depth === 0) return parseKV(`"AbilityDefinitions" ${text.slice(tokens[index + 1].index, tokens[i].index + 1)}`).AbilityDefinitions;
  }
  throw new Error('Unclosed native AbilityDefinitions');
}
const rows = [];
for (const [id, hero] of Object.entries(heroes).filter(([, h]) => h.Role)) {
  const short = id.replace('npc_dota_hero_', '');
  const dossierFile = `docs/heroes/${short}/ABILITIES.md`;
  const dossier = fs.readFileSync(dossierFile, 'utf8');
  const nativePath = `scripts/npc/heroes/${id}.txt`;
  const text = await archive.readText(nativePath);
  const native = definitions(text);
  const kit = [];
  for (let slot = 1; slot <= 5; slot++) {
    const ability = hero[`Ability${slot}`];
    const section = dossier.split(new RegExp(`^## Slot ${slot}:`, 'm'))[1]?.split(/^## /m)[0] ?? '';
    const counterpart = section.match(/^Native counterpart:\s*`([^`]+)`/m)?.[1] ?? null;
    const original = counterpart ? native[counterpart] : null;
    const metadata = Object.fromEntries(fields.map(field => [field, {custom: custom[ability]?.[field] ?? null, native: original?.[field] ?? null}]));
    kit.push({
      slot, id: ability, counterpart, mappingSource: dossierFile,
      mappingStatus: !counterpart ? 'NO_EXPLICIT_DOSSIER_MAPPING' : original ? 'NATIVE_DEFINITION_FOUND' : 'MAPPED_ID_NOT_IN_HERO_DEFINITIONS',
      metadata,
      reviewCandidates: original ? fields.filter(field => original[field] && !custom[ability]?.[field]).map(field => `NATIVE_${field}_CUSTOM_NOT_EXPLICIT`) : [],
      acceptance: 'STATIC_COMPARISON_ONLY_ENGINE_PENDING',
    });
  }
  rows.push({hero: id, source: nativePath, sha256: crypto.createHash('sha256').update(text).digest('hex'), abilities: kit});
}
if (rows.length !== 40 || rows.flatMap(h => h.abilities).length !== 200) throw new Error('Incomplete release roster');
const report = {
  build,
  policy: 'Use only explicit dossier counterpart IDs, never icon or slot inference. Metadata differences are review candidates; intentional PvE behavior, Lua-owned sounds/gestures and native defaults require manual review. No engine acceptance.',
  heroes: rows,
};
const file = 'docs/audit/HERO_NATIVE_PRESENTATION_2026-10-01.json';
const json = JSON.stringify(report, null, 2) + '\n';
if (args.includes('--write')) fs.writeFileSync(file, json);
else if (!fs.existsSync(file) || fs.readFileSync(file, 'utf8') !== json) throw new Error('Stale native presentation snapshot; rerun with --write');
const kit = rows.flatMap(h => h.abilities);
console.log(`40 heroes / 200 abilities: ${kit.filter(a => a.mappingStatus === 'NATIVE_DEFINITION_FOUND').length} explicit native mappings verified.`);
for (const field of ['AbilityCastAnimation', 'AbilityChannelAnimation']) console.log(`${field}: ${kit.filter(a => a.reviewCandidates.includes(`NATIVE_${field}_CUSTOM_NOT_EXPLICIT`)).length} proven metadata gaps requiring behavior review.`);
console.log(`Unresolved or custom-only mappings: ${kit.filter(a => a.mappingStatus !== 'NATIVE_DEFINITION_FOUND').length}. No IDs inferred; no runtime acceptance.`);
