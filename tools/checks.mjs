import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import luaparse from 'luaparse';
import { parseKV } from './lib/kv.mjs';
import { generateLocalization, root, languages } from './localization.mjs';

process.chdir(root);
let failures = 0;
function check(name, fn) {
  try { fn(); console.log(`PASS ${name}`); }
  catch (error) { failures++; console.error(`FAIL ${name}: ${error.message}`); }
}
function walk(dir) {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap(entry => {
    const file = path.join(dir, entry.name);
    return entry.isDirectory() ? walk(file) : [file];
  });
}
function kv(file) { return parseKV(fs.readFileSync(file, 'utf8'), file); }
for (const file of [...walk('game/scripts/npc'), 'game/addoninfo.txt', ...walk('game/resource'), ...walk('game/panorama/localization')].filter(f => f.endsWith('.txt'))) {
  check(`KeyValues ${file}`, () => kv(file));
}
for (const file of walk('game/scripts/vscripts').filter(f => f.endsWith('.lua'))) {
  check(`Lua syntax ${file}`, () => luaparse.parse(fs.readFileSync(file, 'utf8'), { luaVersion: '5.1' }));
}
check('localization values and mirror files', () => generateLocalization(true));
check('Sven Q and W define ten-rank combat curves', () => {
  const abilities = kv('game/scripts/npc/npc_abilities_custom.txt').DOTAAbilities;
  for (const [id, keys] of Object.entries({
    bulwark_shield_slam: ['radius', 'damage', 'stun_duration'],
    bulwark_challenge: ['bonus_armor', 'duration', 'bonus_ms_pct', 'barrier_hp'],
    bulwark_iron_guard: ['cleave_pct', 'cleave_ending_width', 'cleave_distance'],
  })) {
    const ability = abilities[id];
    if (Number(ability.MaxLevel) !== 10) throw new Error(`${id}: MaxLevel must be 10`);
    const specials = Object.assign({}, ...Object.values(ability.AbilitySpecial));
    for (const key of keys) {
      if ((specials[key] || '').trim().split(/\s+/).length !== 10) throw new Error(`${id}.${key}: expected exactly 10 ranks`);
    }
    if (id !== 'bulwark_iron_guard' && (ability.AbilityCooldown.trim().split(/\s+/).length !== 10 || ability.AbilityManaCost.trim().split(/\s+/).length !== 10)) {
      throw new Error(`${id}: cooldown and mana curves must each define ten rank values`);
    }
  }
});
check('localization tokens do not conflict after engine case folding', () => {
  for (const lang of languages) {
    const seen = new Map();
    for (const [key, value] of Object.entries(kv(`game/resource/addon_${lang}.txt`).lang.Tokens)) {
      const folded = key.toLowerCase();
      if (seen.has(folded) && seen.get(folded) !== value) throw new Error(`${lang}: conflicting token ${key}`);
      seen.set(folded, value);
    }
  }
});
check('hero / ability / localization references', () => {
  const heroes = kv('game/scripts/npc/npc_heroes_custom.txt').DOTAHeroes;
  const abilities = kv('game/scripts/npc/npc_abilities_custom.txt').DOTAAbilities;
  const items = kv('game/scripts/npc/npc_items_custom.txt').DOTAItems;
  const whitelist = kv('game/scripts/npc/herolist.txt').CustomHeroList;
  for (const hero of Object.keys(whitelist)) if (!heroes[hero]) throw new Error(`Unknown hero ${hero}`);
  for (const hero of Object.values(heroes)) {
    for (const [key, ability] of Object.entries(hero)) {
      if (/^Ability\d+$/.test(key) && ability !== 'generic_hidden' && !abilities[ability]) throw new Error(`Unknown ability ${ability}`);
    }
  }
  for (const lang of languages) {
    const tokens = kv(`game/resource/addon_${lang}.txt`).lang.Tokens;
    for (const id of [...Object.keys(abilities), ...Object.keys(items)]) {
      for (const suffix of ['', '_Description']) {
        if (!tokens[`DOTA_Tooltip_Ability_${id}${suffix}`]) throw new Error(`${lang}: missing ${id}${suffix}`);
      }
    }
  }
});
check('hero-specific evolution contracts', () => {
  const localization=spawnSync(process.execPath,['tools/evolution_localization.mjs','--check'],{encoding:'utf8'});
  if(localization.status!==0) throw new Error(localization.stderr);
  for (const args of [['tools/hero_evolutions.mjs','--check'],['node_modules/fengari-node-cli/src/lua-cli.js','tests/hero_evolution.lua']]) {
    const result=spawnSync(process.execPath,args,{encoding:'utf8'});
    if(result.status!==0 || result.stderr || !result.stdout.includes(args[0].includes('hero_evolutions')?'480':'Hero evolution tests passed')) throw new Error(result.stderr || result.stdout);
    console.log(result.stdout.trim());
  }
});
check('all-hero structural inventory is current', () => {
  const result=spawnSync(process.execPath,['tools/audit_heroes_deep.mjs'],{encoding:'utf8'});
  if(result.status!==0) throw new Error(result.stderr || result.stdout);
  console.log(result.stdout.trim());
});
check('production map allowlist', () => {
  const maps = kv('game/addoninfo.txt').AddonInfo.maps.split(/\s+/);
  if (maps.join(' ') !== 'enfos') throw new Error('Only the canonical enfos map may be published');
  const shipped = fs.existsSync('game/maps') ? fs.readdirSync('game/maps').filter(f => f.endsWith('.vpk')) : [];
  for (const file of shipped) if (!maps.includes(path.basename(file, '.vpk'))) throw new Error(`Unapproved map in game/maps: ${file}`);
  for (const map of maps) if (fs.existsSync(`content/maps/${map}.vmap`)) throw new Error(`Unsafe placeholder source in active build tree: ${map}`);
});
check('installed map/theme matches recorded playable version', () => {
  const result = spawnSync(process.execPath, ['tools/check_map.mjs'], {encoding:'utf8'});
  if (result.status !== 0) throw new Error(result.stderr || result.stdout);
});
check('validator regression tests', () => {
  const result = spawnSync(process.execPath, ['--test', 'tools/tests/kv.test.mjs', 'tools/tests/hero_selection.test.mjs', 'tools/tests/ascended_shop.test.mjs', 'tools/tests/spellbringer.test.mjs', 'tools/tests/content_contracts.test.mjs', 'tools/tests/hud_release.test.mjs'], { stdio: 'inherit' });
  if (result.status !== 0) throw new Error('Validator tests failed');
});
if (fs.existsSync('tests/run.lua')) check('Lua behavior tests', () => {
  const result = spawnSync(process.execPath, ['node_modules/fengari-node-cli/src/lua-cli.js', 'tests/run.lua'], { encoding: 'utf8' });
  console.log(result.stdout);
  if (result.status !== 0 || result.stderr || !result.stdout.includes('Lua behavior tests passed')) throw new Error('Lua behavior tests failed: ' + result.stderr);
});
check('player feedback regressions', () => {
  const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','tests/player_feedback_regressions.lua'],{encoding:'utf8'});
  console.log(result.stdout);
  if(result.status!==0 || result.stderr || !result.stdout.includes('Player feedback regression tests passed')) throw new Error(result.stderr || result.stdout);
});
check('wave and portal runtime regressions', () => {
  const result = spawnSync(process.execPath, ['node_modules/fengari-node-cli/src/lua-cli.js', 'tests/runtime_regressions.lua'], { encoding: 'utf8' });
  console.log(result.stdout);
  if (result.status !== 0 || result.stderr || !result.stdout.includes('runtime regression tests passed')) throw new Error('Runtime regression tests failed: ' + result.stderr);
});
check('hero spawn regressions', () => {
  const result = spawnSync(process.execPath, ['node_modules/fengari-node-cli/src/lua-cli.js', 'tests/hero_spawns.lua'], { encoding: 'utf8' });
  console.log(result.stdout);
  if (result.status !== 0 || result.stderr || !result.stdout.includes('hero spawn tests passed')) throw new Error('Hero spawn tests failed: ' + result.stderr);
});
check('hero empowerment regressions', () => {
  const result = spawnSync(process.execPath, ['node_modules/fengari-node-cli/src/lua-cli.js', 'tests/hero_power.lua'], { encoding: 'utf8' });
  console.log(result.stdout);
  if (result.status !== 0 || result.stderr || !result.stdout.includes('hero power tests passed')) throw new Error('Hero power tests failed: ' + result.stderr);
});
check('hero kit behavior regressions', () => {
  const result = spawnSync(process.execPath, ['node_modules/fengari-node-cli/src/lua-cli.js', 'tests/hero_kit_regressions.lua'], { encoding: 'utf8' });
  console.log(result.stdout);
  if (result.status !== 0 || result.stderr || !result.stdout.includes('hero kit regression tests passed')) throw new Error('Hero kit regression tests failed: ' + result.stderr);
});
check('all 200 abilities and owned modifiers mock execution (not engine acceptance)', () => {
  const result = spawnSync(process.execPath, ['tools/test_real_abilities.mjs'], { encoding: 'utf8' });
  console.log(result.stdout);
  if (result.status !== 0 || result.stderr || !result.stdout.includes('Ability/modifier smoke checks passed; engine behavior not certified.')) {
    throw new Error('All abilities mock execution failed: ' + (result.stderr || result.stdout));
  }
});
check('native tooltip name, description and compact tooltip aliases', () => {
  const abilities = kv('game/scripts/npc/npc_abilities_custom.txt').DOTAAbilities;
  for (const lang of languages) {
    const tokens = kv(`game/resource/addon_${lang}.txt`).lang.Tokens;
    for (const id of Object.keys(abilities)) for (const suffix of ['', '_Description', '_SummaryDescription']) {
      const key = `DOTA_Tooltip_ability_${id}${suffix}`;
      if (!tokens[key] || tokens[key] !== tokens[key.replace('_ability_', '_Ability_')]) throw new Error(`Missing native tooltip ${key}`);
    }
  }
});
check('Panorama source mirrors and overview mapping', () => {
  const tables = fs.readFileSync('game/scripts/custom_net_tables.txt', 'utf8');
  const tableList = tables.match(/custom_net_tables\s*=\s*\[([\s\S]*?)\]/)?.[1];
  if (!tables.startsWith('<!-- kv3 encoding:text:') || !tableList) throw new Error('Missing KV3 table registration');
  const registered = new Set([...tableList.matchAll(/"([^"]+)"/g)].map(m => m[1]));
  for (const file of [...walk('game/scripts/vscripts'), ...walk('content/panorama/scripts')]) {
    const code = fs.readFileSync(file, 'utf8');
    for (const match of code.matchAll(/CustomNetTables[.:](?:SetTableValue|GetTableValue|SubscribeNetTableListener)\s*\(\s*["']([^"']+)["']/g)) {
      if (!registered.has(match[1])) throw new Error(`${file}: unregistered nettable ${match[1]}`);
    }
  }
  for (const lang of languages) if (!fs.readFileSync(`game/resource/addon_${lang}.txt`, 'utf8').startsWith('\uFEFF')) throw new Error('Localization needs a Unicode BOM for Source 2');
  for (const file of walk('content/panorama')) {
    if (fs.readFileSync(file, 'utf8') !== fs.readFileSync(file.replace(/^content/, 'game'), 'utf8')) throw new Error(`Stale runtime UI: ${file}`);
  }
  for (const map of ['enfos']) {
    const overview = Object.values(kv(`game/resource/overviews/${map}.txt`))[0];
    if (Number(overview.pos_x) !== -12864 || Number(overview.pos_y) !== 12864 || Number(overview.scale) !== 25.125) throw new Error('Overview does not match Survival map');
  }
});
check('production roster and wave economy are current', () => {
  for (const file of ['tools/roster.mjs', 'tools/wave_economy.mjs', 'tools/item_tooltips.mjs']) {
    const result = spawnSync(process.execPath, [file, '--check'], { encoding: 'utf8' });
    if (result.status !== 0 || result.stderr) throw new Error(result.stderr || file);
  }
});
check('audit behavior regressions', () => {
  const result = spawnSync(process.execPath, ['node_modules/fengari-node-cli/src/lua-cli.js', 'tests/audit_regressions.lua'], {encoding:'utf8'});
  console.log(result.stdout);
  if (result.status !== 0 || result.stderr || !result.stdout.includes('audit regression tests passed')) throw new Error(result.stderr || 'Audit regressions did not finish');
});
check('scoreboard stats regressions',()=>{
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','tests/scoreboard_regressions.lua'],{encoding:'utf8'});
 if(r.status!==0||r.stderr||!r.stdout.includes('Scoreboard regression tests passed'))throw Error(r.stderr||r.stdout);
});
check('match hero level progression',()=>{
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','tests/match_levels.lua'],{cwd:root,encoding:'utf8'});
 if(r.status!==0||r.stderr||!r.stdout.includes('Match hero level progression tests passed'))throw Error(r.stderr||r.stdout);
});
check('Lua ability entrypoints and authoritative hero references', () => {
  const abilities=kv('game/scripts/npc/npc_abilities_custom.txt').DOTAAbilities;
  const roster=kv('game/scripts/npc/npc_heroes_custom.txt').DOTAHeroes;
  const bootstrap=fs.readFileSync('game/scripts/vscripts/addon_game_mode.lua','utf8');
  if (!bootstrap.includes('require("abilities/pve_kits")')
      || !bootstrap.includes('assertAbilityCallback("bulwark_shield_slam", "OnSpellStart")')
      || !bootstrap.includes('assertAbilityCallback("bulwark_challenge", "OnSpellStart")')
      || !bootstrap.includes('assertAbilityCallback("modifier_bulwark_iron_guard", "OnAttackLanded")')) {
    throw new Error('Sven Q/W/E shared ability callbacks must load and validate at addon startup');
  }
  const counts={};
  for (const h of Object.values(roster)) counts[h.Role]=(counts[h.Role]||0)+1;
  if (Object.keys(roster).length!==40 || Object.values(counts).some(n=>n!==8)) throw new Error('Expected 8 heroes per role');
  for (const [id,a] of Object.entries(abilities)) if (a.BaseClass==='ability_lua') {
    const source=fs.readFileSync('game/scripts/vscripts/'+a.ScriptFile+'.lua','utf8');
    if (!source.includes(id+'=class({})')) throw new Error('Missing Lua entrypoint '+id);
  }
});
check('hero instructions, current references and skill evidence ledgers', () => {
  const result = spawnSync(process.execPath, ['tools/hero_reference_docs.mjs', '--check'], { encoding: 'utf8' });
  console.log(result.stdout);
  if (result.status !== 0 || result.stderr) throw new Error(result.stderr || result.stdout);
});
console.log(`${failures} failed check(s). Engine playtests remain separate.`);
process.exitCode = failures ? 1 : 0;
