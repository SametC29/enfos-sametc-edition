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
check('production map allowlist', () => {
  const maps = kv('game/addoninfo.txt').AddonInfo.maps.split(/\s+/);
  if (maps.join(' ') !== 'enfos enfos_sametc') throw new Error('Unexpected production map');
  const shipped = fs.existsSync('game/maps') ? fs.readdirSync('game/maps').filter(f => f.endsWith('.vpk')) : [];
  for (const file of shipped) if (!maps.includes(path.basename(file, '.vpk'))) throw new Error(`Unapproved map in game/maps: ${file}`);
  for (const map of maps) if (!fs.existsSync(`content/maps/${map}.vmap`)) throw new Error(`Missing source map ${map}`);
});
check('validator regression tests', () => {
  const result = spawnSync(process.execPath, ['--test', 'tools/tests/kv.test.mjs'], { stdio: 'inherit' });
  if (result.status !== 0) throw new Error('Validator tests failed');
});
if (fs.existsSync('tests/run.lua')) check('Lua behavior tests', () => {
  const result = spawnSync(process.execPath, ['node_modules/fengari-node-cli/src/lua-cli.js', 'tests/run.lua'], { stdio: 'inherit' });
  if (result.status !== 0) throw new Error('Lua behavior tests failed');
});
check('wave and portal runtime regressions', () => {
  const result = spawnSync(process.execPath, ['node_modules/fengari-node-cli/src/lua-cli.js', 'tests/runtime_regressions.lua'], { stdio: 'inherit' });
  if (result.status !== 0) throw new Error('Runtime regression tests failed');
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
  if (!tables.startsWith('<!-- kv3 encoding:text:') || !/custom_net_tables\s*=\s*\[\s*"wave_info"\s*\]/.test(tables)) throw new Error('Missing KV3 wave_info registration');
  for (const lang of languages) if (!fs.readFileSync(`game/resource/addon_${lang}.txt`, 'utf8').startsWith('\uFEFF')) throw new Error('Localization needs a Unicode BOM for Source 2');
  for (const file of walk('content/panorama')) {
    if (fs.readFileSync(file, 'utf8') !== fs.readFileSync(file.replace(/^content/, 'game'), 'utf8')) throw new Error(`Stale runtime UI: ${file}`);
  }
  for (const map of ['enfos', 'enfos_sametc']) {
    const overview = Object.values(kv(`game/resource/overviews/${map}.txt`))[0];
    if (Number(overview.pos_x) !== -12864 || Number(overview.pos_y) !== 12864 || Number(overview.scale) !== 25.125) throw new Error('Overview does not match Survival map');
  }
});
console.log(`${failures} failed check(s). Engine playtests remain separate.`);
process.exitCode = failures ? 1 : 0;
