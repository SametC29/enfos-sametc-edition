// Maintain hero dossiers without replacing human decisions or test evidence.
import fs from 'node:fs';
import path from 'node:path';
import { parseKV } from './lib/kv.mjs';

const args = process.argv.slice(2);
const write = args.includes('--init') || args.includes('--refresh');
if (!write && !args.includes('--check')) throw new Error('Use --init, --refresh or --check');
const heroes = parseKV(fs.readFileSync('game/scripts/npc/npc_heroes_custom.txt', 'utf8')).DOTAHeroes;
const abilities = parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt', 'utf8')).DOTAAbilities;
const names = JSON.parse(fs.readFileSync('localization/english.json', 'utf8')).Tokens;
const snapshot = JSON.parse(fs.readFileSync('docs/audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json', 'utf8'));
const contracts = JSON.parse(fs.readFileSync('docs/audit/HERO_ABILITY_CONTRACTS.json', 'utf8'));
const rows = Object.entries(heroes).filter(([, h]) => h.Role);
const start = '<!-- BEGIN GENERATED INVENTORY -->', end = '<!-- END GENERATED INVENTORY -->';
const cell = value => String(value ?? 'NOT_EXPLICIT').replace(/\|/g, '\\|').replace(/\r?\n/g, ' ');
const root = 'docs/heroes';
const evidenceAreas = ['Gameplay', 'Targeting', 'Ranks', 'VFX', 'SFX', 'Animation', 'Modifiers', 'Precache', 'Cleanup', 'Boss', 'Upgrades', 'Localization', 'Performance', 'Reconnect', 'VConsole'];

function inventory(id, hero) {
  const native = snapshot.heroes.find(h => h.id === id);
  if (!native) throw new Error(`Missing native source record: ${id}`);
  const table = [start, '## Current inventory (generated; not certification)', '',
    `Hero: \`${id}\`; role: ${hero.Role}. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.`, '',
    '| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |',
    '| --- | --- | --- | --- | --- | --- |'];
  for (let slot = 1; slot <= 5; slot++) {
    const a = abilities[hero[`Ability${slot}`]];
    if (!a) throw new Error(`Missing ability: ${id}/${slot}`);
    table.push(`| ${slot} | \`${hero[`Ability${slot}`]}\` | ${cell(a.MaxLevel)} | ${cell(a.AbilityBehavior)} | ${cell(a.ScriptFile)} | ${cell(a.AbilityTextureName)} |`);
  }
  const scripts = [...new Set([1,2,3,4,5].map(slot => abilities[hero[`Ability${slot}`]].ScriptFile).filter(Boolean))];
  const luaLinks = scripts.map(script => `[${scripts.length === 1 ? 'Lua' : script}](../../../game/scripts/vscripts/${script}.lua)`).join(', ') || 'native mechanics (no Lua ability wrappers)';
  table.push('', `Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), ${luaLinks}, [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).`, '',
    '### Installed native source (not a custom-slot mapping)', '',
    `Source: \`${native.source}\`; status: ${native.status}; SHA256: \`${native.sha256 ?? 'PENDING'}\`.`,
    `Installed build: ClientVersion=${snapshot.build.ClientVersion}; SourceRevision=${snapshot.build.SourceRevision}; ${snapshot.build.VersionDate}. Snapshot observation UTC: ${snapshot.observedAt}.`,
    'Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.', '',
    '| Native field | Observed value |', '| --- | --- |');
  for (const [key, value] of Object.entries(native.fields ?? {})) table.push(`| ${key} | \`${cell(value)}\` |`);
  table.push('', '### Per-ability review leads', '');
  const contract = contracts.heroes.find(h => h.id === id);
  for (let slot = 1; slot <= 5; slot++) {
    const aid = hero[`Ability${slot}`], a = abilities[aid];
    const c = contract?.abilities.find(a => a.id === aid);
    const hints = [];
    if (slot === 5) hints.push('Enfos passive free starting rank, native innate separation, respawn/point budget');
    if ((a.AbilityBehavior ?? '').includes('PASSIVE')) hints.push('intrinsic modifier, Break/illusion behavior, live rank refresh');
    if ((a.AbilityBehavior ?? '').includes('TOGGLE')) hints.push('toggle state, mana drain, death/respawn cleanup');
    if ((a.AbilityBehavior ?? '').includes('CHANNELLED')) hints.push('channel tick, interrupt, looping audio and thinker expiry');
    if ((a.AbilityBehavior ?? '').includes('AUTOCAST')) hints.push('manual/autocast parity, attack proc and duplicate events');
    if ((a.AbilityBehavior ?? '').includes('UNIT_TARGET')) hints.push('target flags, immunity, spell block/reflect if applicable, target loss');
    if ((a.AbilityBehavior ?? '').includes('POINT')) hints.push('world position, travel/impact timing and radius alignment');
    if (a.AbilityType === 'DOTA_ABILITY_TYPE_ULTIMATE') hints.push('ultimate unlock curve, Scepter/Blessing and boss burst');
    if (c?.unreferencedSpecials?.length) hints.push(`static unreferenced-special candidates: ${c.unreferencedSpecials.join(', ')} (not confirmed defects)`);
    table.push(`- \`${aid}\`: ${hints.join('; ') || 'cast/impact/modifier contract and lifetime'}.`);
  }
  table.push('', end);
  return table.join('\n');
}
function ledger(id, hero) {
  const sections = [];
  for (let slot = 1; slot <= 5; slot++) {
    const aid = hero[`Ability${slot}`];
    sections.push(`## Slot ${slot}: \`${aid}\``, '',
      'Classification: UNASSESSED',
      'Native counterpart: PENDING — verify from current source; do not infer from icon/slot.',
      'Decision and PvE identity rationale: PENDING.',
      'Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.',
      'Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.',
      'Current versus target rank curve; free rank / point cost: PENDING.',
      'Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING.', '',
      '### Resource and implementation evidence', '',
      '- Native ability data source + build + hash/revision: PENDING.',
      '- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: PENDING.',
      '- Sound events + declaring banks + emission target + loop termination: PENDING.',
      '- Model/animation/gesture/icon evidence: PENDING.',
      '- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.',
      '- Precache owner and cold-start test: PENDING.',
      '- One-shot/persistent cleanup owner and repeated-use test: PENDING.',
      '- Localization keys and generated mirrors: PENDING.', '',
      '### Acceptance ledger', '', '| Area | Status | Source/build/test evidence or N/A reason |', '| --- | --- | --- |',
      ...evidenceAreas.map(area => `| ${area} | PENDING | Not evaluated in this dossier setup. |`), '',
      'Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.', '');
  }
  return sections.join('\n');
}
let checked = 0;
for (const [id, hero] of rows) {
  const slug = id.replace('npc_dota_hero_', '');
  const dir = path.join(root, slug);
  const file = path.join(dir, 'ABILITIES.md');
  const agent = path.join(dir, 'AGENTS.md');
  const name = names[id] || id;
  if (write) {
    fs.mkdirSync(dir, {recursive: true});
    if (!fs.existsSync(agent)) fs.writeFileSync(agent, `# ${name}: hero work instructions\n\nHero ID: \`${id}\`. Project role: ${hero.Role}.\n\nRead [the shared hero contract](../AGENTS.md), [technical reference](../../HERO_ABILITY_REFERENCE.md) and [this hero's dossier](ABILITIES.md) before each skill task. The root AGENTS.md explicitly applies this reading requirement to shared gameplay/KV edits.\n\n- Work only on the requested skill or coherent hero unit; shared helper changes require regressions for other affected heroes.\n- Preserve this hero's recognizable Dota identity; verify its original kit in the installed source shown in ABILITIES.md.\n- KEEP/TUNE/PVE-CONVERT/REPLACE needs evidence before implementation; UNASSESSED is discovery only.\n- Current five stable IDs and their KV/Lua mappings are in the generated inventory. Do not guess native counterparts from slot order or icon.\n- Use the per-skill review leads; verify callbacks, assets, CPs, sounds, animation and native modifiers against the exact build.\n- Target is 50 hero levels and 10 total ranks per skill; keep current and target values separate until migrated.\n- Update each affected acceptance row; gameplay, VFX, SFX, modifier, precache, cleanup and tooltip are one acceptance unit.\n- PASS requires the relevant evidence; absent Dota/VConsole/audio/visual tests remain PENDING. A documented N/A must be justified.\n- Restore/reconnect must not duplicate ranks, points, modifiers, items or choices.\n- Reuse other custom-game code only under REFERENCE_ANALYSIS_POLICY.md: verify exact source/version, license, distribution compatibility, notices and dependencies; document imports. Asset rights are separate. Do not publish to Workshop from a dossier update.\n`);
    if (!fs.existsSync(file)) fs.writeFileSync(file, `# ${name}: ability evidence dossier\n\nThis dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.\n\n${inventory(id, hero)}\n\n## Human decisions and runtime evidence (preserve on refresh)\n\n${ledger(id, hero)}`);
    else if (args.includes('--refresh')) {
      const text = fs.readFileSync(file, 'utf8');
      const a = text.indexOf(start), b = text.indexOf(end);
      if (a < 0 || b < a) throw new Error(`Missing inventory markers: ${file}`);
      fs.writeFileSync(file, text.slice(0, a) + inventory(id, hero) + text.slice(b + end.length));
    }
  }
  if (!fs.existsSync(agent) || !fs.existsSync(file)) throw new Error(`Missing hero reference: ${id}`);
  const text = fs.readFileSync(file, 'utf8');
  const a = text.indexOf(start), b = text.indexOf(end);
  if (a < 0 || b < a || text.slice(a, b + end.length) !== inventory(id, hero)) throw new Error(`Stale inventory: ${file}; use --refresh`);
  for (let slot = 1; slot <= 5; slot++) {
    const heading = `## Slot ${slot}: \`${hero[`Ability${slot}`]}\``;
    const begin = text.indexOf(heading);
    if (begin < 0 || text.indexOf(heading, begin + heading.length) >= 0) throw new Error(`Missing/duplicate ledger: ${id}/${slot}`);
    const next = text.indexOf('\n## Slot ', begin + heading.length);
    const section = text.slice(begin, next < 0 ? text.length : next);
    if (!/^Classification: (UNASSESSED|KEEP|TUNE|PVE-CONVERT|REPLACE)\s*$/m.test(section)) throw new Error(`Invalid classification: ${id}/${slot}`);
    for (const area of evidenceAreas) {
      const pattern = new RegExp(`^\\| ${area} \\| (PASS|FAIL|PENDING|N/A) \\| (.+) \\|$`, 'm');
      const row = section.match(pattern);
      if (!row || !row[2].trim()) throw new Error(`Missing acceptance evidence: ${id}/${slot}/${area}`);
      if (row[1] !== 'PENDING' && /^(Not evaluated|PENDING|TODO)/i.test(row[2].trim())) throw new Error(`Unevidenced ${row[1]}: ${id}/${slot}/${area}`);
    }
    checked++;
  }
}
const readme = ['# Kahraman çalışma ve referans dizini', '',
  'Her skill görevinde ilgili kahramanın **AGENTS.md** ve **ABILITIES.md** dosyalarını, ardından [ortak teknik rehberin](../HERO_ABILITY_REFERENCE.md) ilgili bölümünü oku. Root AGENTS.md bu okuma yükümlülüğünü paylaşılan Lua/KV/precache/localization değişiklikleri için de açıkça uygular.', '',
  `${rows.length} kahraman / ${checked} skill için envanter ve ayrı kabul kayıtları hazır. Native yuvalar kurulu Valve kaynağından çıkarıldı; her özel skill eşlemesi ve çalışma kanıtı ilgili dossier'de tutulur. PENDING oyun içi kayıtlar bilinçlidir: kaynak dosyası, VPK varlığı ve mock test, oyunda doğru çalışma iddiası değildir.`, '',
  `İlerleme hedefi için ortak seviye-50 XP/başlangıç sistemi ve ${rows.length} kahramanın tümünde beş yuvaya ait KV rütbe kapıları uygulandı. Q/W/E/pasif 1. seviyede açılır ve her seviyede rütbe kazanır; R 5. seviyede açılır ve her beş seviyede rütbe kazanır. Oyuncu puanı/HUD ve beceri davranışlarının Dota motorundaki kabulü canlı test bekler.`, '',
  '| Kahraman | Proje rolü | Çalışma talimatı | Skill referansı ve kabul kayıtları |', '| --- | --- | --- | --- |',
  ...rows.map(([id,h]) => { const slug = id.replace('npc_dota_hero_', ''); return `| ${names[id] || id} | ${h.Role} | [AGENTS.md](${slug}/AGENTS.md) | [ABILITIES.md](${slug}/ABILITIES.md) |`; }), '',
  '## Bakım', '',
  '`node tools/hero_reference_docs.mjs --check`: kapsam, güncel inventory ve kabul alanlarını doğrular; runtime doğrulamaz.',
  '`--init`: yalnız eksik dosyaları oluşturur. `--refresh`: yalnız generated inventory bloklarını yeniler; insan kararları ve test kayıtlarını korur.', '',
  '[Geniş araştırma ve soruların yanıtları](../audit/HERO_ABILITY_RESEARCH_2026-09-29.md), [mevcut geliştirme standardı](../HERO_ABILITY_DEVELOPMENT_GUIDELINES.md), [kaynak snapshot](../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json).', ''].join('\n');
if (write) fs.writeFileSync(path.join(root, 'README.md'), readme);
else if (fs.readFileSync(path.join(root, 'README.md'), 'utf8') !== readme) throw new Error('Stale hero reference index');
if (checked !== rows.length * 5) throw new Error('Incomplete assigned skill coverage');
console.log(`PASS ${rows.length} hero instructions / ${checked} skill evidence ledgers. Runtime acceptance is separate.`);
