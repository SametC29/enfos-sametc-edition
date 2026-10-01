import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {parseKV} from './lib/kv.mjs';

// Input must be the actual installed VPK's soundevents/game_sounds_heroes
// directory, decompiled by Source2Viewer. No engine or audio playback is used.
const root = process.argv[process.argv.indexOf('--banks') + 1];
if (!process.argv.includes('--banks') || !root) throw new Error('Use --banks <decoded hero-bank directory> [--write]');
const buildFile = process.argv[process.argv.indexOf('--build-file') + 1];
if (!process.argv.includes('--build-file') || !buildFile) throw new Error('Use --build-file <installed game/dota/steam.inf> to record build provenance');
const banks = new Map();
const hashes = [];
for (const file of fs.readdirSync(root).filter(f => f.endsWith('.vsndevts')).sort()) {
  const text = fs.readFileSync(path.join(root, file), 'utf8');
  hashes.push({file, sha256: crypto.createHash('sha256').update(text).digest('hex')});
  for (const match of text.matchAll(/^\s*([A-Za-z0-9_.]+)\s*=\s*\{/gm)) {
    if (!match[1].includes('.')) continue;
    const owners = banks.get(match[1]) ?? [];
    owners.push(`soundevents/game_sounds_heroes/${file}`);
    banks.set(match[1], owners);
  }
}
if (!banks.has('Hero_WitchDoctor.Voodoo_Restoration.Loop')) throw new Error('Incomplete/invalid decoded hero-bank input');
const calls = new Map();
const add = (event, owner) => calls.set(event, [...(calls.get(event) ?? []), owner]);
const source = fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua', 'utf8');
for (const match of source.matchAll(/:(EmitSound|StopSound)\(\s*['"]([^'"]+)['"]/g)) {
  add(match[2], {file: 'game/scripts/vscripts/abilities/pve_kits.lua', line: source.slice(0, match.index).split('\n').length, operation: match[1]});
}
const kv = parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt', 'utf8')).DOTAAbilities;
for (const [id, ability] of Object.entries(kv)) if (ability.AbilitySound) add(ability.AbilitySound, {ability: id, operation: 'AbilitySound'});
const rows = [...calls.entries()].sort(([a], [b]) => a.localeCompare(b)).map(([event, uses]) => {
  const exact = banks.get(event);
  const caseMatches = [...banks.keys()].filter(key => key.toLowerCase() === event.toLowerCase());
  return {event, uses, status: exact ? 'EXACT_EVENT_FOUND' : caseMatches.length ? 'CASE_ONLY_MATCH_REVIEW' : 'NOT_FOUND_IN_DECODED_HERO_BANKS', banks: exact ?? [], caseMatches: exact ? [] : caseMatches, runtime: 'PENDING'};
});
const report = {
  build: fs.readFileSync(buildFile, 'utf8').trim(),
  scope: 'Literal hero ability EmitSound/StopSound and KV AbilitySound against decoded installed hero banks',
  limitations: 'No dynamic event names, other bank directories, sound resource decode, playback or precache certification. Missing in hero banks is a review candidate, not proof absent from the entire game. Case matching requires engine confirmation.',
  banks: hashes, events: rows,
};
const json = JSON.stringify(report, null, 2) + '\n';
const file = 'docs/audit/HERO_SOUND_EVENTS_2026-10-01.json';
if (process.argv.includes('--write')) fs.writeFileSync(file, json);
else if (!fs.existsSync(file) || fs.readFileSync(file, 'utf8') !== json) throw new Error('Stale sound-event audit; rerun with --write');
console.log(`Reviewed ${hashes.length} installed hero banks and ${rows.length} literal events.`);
for (const row of rows.filter(r => r.status !== 'EXACT_EVENT_FOUND')) console.log(`${row.status}: ${row.event}${row.caseMatches.length ? ` -> ${row.caseMatches.join(', ')}` : ''}`);
console.log('Event lookup evidence only; engine/audio acceptance remains pending.');
