import fs from 'node:fs';
import {parseKV} from './lib/kv.mjs';

// A review queue, not a VFX/audio/animation correctness certificate.
const inventory = JSON.parse(fs.readFileSync('docs/audit/HERO_ABILITY_CONTRACTS.json', 'utf8'));
const abilities = parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt', 'utf8')).DOTAAbilities;
const rows = inventory.heroes.map(hero => ({
  hero: hero.id,
  abilities: hero.abilities.map(ability => {
    const kv = abilities[ability.id];
    if (!kv) throw new Error(`Missing production ability ${ability.id}`);
    const passive = ability.behavior.includes('PASSIVE');
    return {
      id: ability.id,
      behavior: ability.behavior,
      explicitCastAnimation: kv.AbilityCastAnimation ?? null,
      sourceSoundSignal: ability.hasSound,
      sourceParticleSignal: ability.hasParticle,
      reviewCandidates: passive ? [] : [
        ...(!kv.AbilityCastAnimation ? ['NO_EXPLICIT_KV_CAST_ANIMATION'] : []),
        ...(!ability.hasSound ? ['NO_SOUND_SIGNAL_IN_CONTRACT_INVENTORY'] : []),
        ...(!ability.hasParticle ? ['NO_PARTICLE_SIGNAL_IN_CONTRACT_INVENTORY'] : []),
      ],
      engineAcceptance: 'PENDING_OWNER_TEST',
    };
  }),
}));
if (rows.length !== 40 || rows.flatMap(h => h.abilities).length !== 200) {
  throw new Error('Expected the release roster of 40 heroes / 200 abilities');
}
const report = {
  scope: 'Desktop items 14–16; initial static presentation review queue',
  limitations: 'No explicit KV field does not prove no animation. Boolean signals do not verify event identity, assets, helpers, precache, attachment or engine result. Run audit_heroes_deep.mjs first to verify inventory freshness.',
  heroes: rows,
};
const file = 'docs/audit/HERO_PRESENTATION_REVIEW_2026-10-01.json';
const json = JSON.stringify(report, null, 2) + '\n';
if (process.argv.includes('--write')) fs.writeFileSync(file, json);
else if (!fs.existsSync(file) || fs.readFileSync(file, 'utf8') !== json) {
  throw new Error('Stale presentation review: node tools/hero_presentation_review.mjs --write');
}
for (const candidate of ['NO_EXPLICIT_KV_CAST_ANIMATION', 'NO_SOUND_SIGNAL_IN_CONTRACT_INVENTORY', 'NO_PARTICLE_SIGNAL_IN_CONTRACT_INVENTORY']) {
  const list = rows.flatMap(h => h.abilities).filter(a => a.reviewCandidates.includes(candidate));
  console.log(`${candidate}: ${list.length} review candidates (not certified bugs)`);
}
console.log('40 heroes / 200 abilities inventoried; all engine acceptance remains pending owner test.');
