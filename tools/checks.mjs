import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import luaparse from 'luaparse';
import { parseKV } from './lib/kv.mjs';
import { getAbilityValues } from './lib/ability_values.mjs';
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
check('Sven and Juggernaut expose ten-rank combat curves', () => {
  const abilities = kv('game/scripts/npc/npc_abilities_custom.txt').DOTAAbilities;
  const curves = {
    bulwark_shield_slam: ['radius', 'damage', 'stun_duration'],
    bulwark_challenge: ['bonus_armor', 'duration', 'bonus_ms_pct', 'barrier_hp'],
    bulwark_iron_guard: ['cleave_pct', 'cleave_ending_width', 'cleave_distance'],
    enfos_juggernaut_blade_fury: ['damage_per_sec'],
    enfos_juggernaut_healing_ward: ['heal_pct'],
    enfos_juggernaut_blade_dance: ['crit_chance', 'crit_mult'],
    enfos_juggernaut_omni_slash: ['duration', 'bonus_damage'],
    enfos_juggernaut_duelist: ['bonus_attack_speed', 'bonus_ms_pct'],
  };
  for (const [id, keys] of Object.entries(curves)) {
    const ability = abilities[id];
    if (Number(ability.MaxLevel) !== 10) throw new Error(`${id}: MaxLevel must be 10`);
    const specials = getAbilityValues(ability);
    for (const key of keys) {
      if ((specials[key] || '').trim().split(/\s+/).length !== 10) throw new Error(`${id}.${key}: expected exactly 10 ranks`);
    }
    if (['bulwark_shield_slam', 'bulwark_challenge', 'enfos_juggernaut_blade_fury',
      'enfos_juggernaut_healing_ward', 'enfos_juggernaut_omni_slash'].includes(id)
      && ability.AbilityManaCost.trim().split(/\s+/).length !== 10) {
      throw new Error(`${id}: cooldown and mana curves must each define ten rank values`);
    }
  }
  if (!abilities.enfos_juggernaut_healing_ward.AbilityBehavior.includes('POINT')) {
    throw new Error('Healing Ward reads a cursor point but is not a point-target ability');
  }
});
check('Drow exposes five ten-rank abilities without mislabeling the Enfos passive as Dota innate', () => {
  const abilities = kv('game/scripts/npc/npc_abilities_custom.txt').DOTAAbilities;
  const curves = {
    enfos_drow_frost_arrows: ['slow_pct', 'bonus_damage', 'agility_factor'],
    enfos_drow_gust: ['silence_duration'],
    enfos_drow_multishot: ['arrow_count', 'arrow_damage_pct'],
    enfos_drow_marksmanship: ['proc_chance', 'bonus_damage'],
    enfos_drow_precision_aura: ['bonus_agility_pct', 'bonus_range'],
  };
  for (const [id, keys] of Object.entries(curves)) {
    const ability = abilities[id];
    if (Number(ability.MaxLevel) !== 10) throw new Error(`${id}: MaxLevel must be 10`);
    const specials = getAbilityValues(ability);
    for (const key of keys) {
      if ((specials[key] || '').trim().split(/\s+/).length !== 10) throw new Error(`${id}.${key}: expected exactly 10 ranks`);
    }
  }
  if (abilities.enfos_drow_multishot.AbilityManaCost.trim().split(/\s+/).length !== 10) {
    throw new Error('Drow Multishot mana curve must define ten ranks');
  }
  if (abilities.enfos_drow_precision_aura.Innate) throw new Error('The Enfos passive must not be marked as a Dota innate ability');
  if (!abilities.enfos_drow_multishot.AbilityUnitTargetFlags.includes('MAGIC_IMMUNE_ENEMIES')
      || abilities.enfos_drow_multishot.SpellImmunityType !== 'SPELL_IMMUNITY_ENEMIES_YES') {
    throw new Error('Drow Multishot must preserve native magic-immunity targeting');
  }
});
check('Pudge preserves native cast/channel animations and preloads its native sound bank', () => {
  const abilities = kv('game/scripts/npc/npc_abilities_custom.txt').DOTAAbilities;
  const expectedAnimations = {
    enfos_pudge_meat_hook: ['ACT_DOTA_CAST_ABILITY_1', undefined],
    enfos_pudge_rot: ['ACT_DOTA_CAST_ABILITY_2', undefined],
    enfos_pudge_dismember: ['ACT_DOTA_CAST_ABILITY_4', 'ACT_DOTA_CHANNEL_ABILITY_4'],
  };
  for (const [id, [cast, channel]] of Object.entries(expectedAnimations)) {
    const ability = abilities[id];
    if (ability.AbilityCastAnimation !== cast) throw new Error(`${id}: expected native cast animation ${cast}`);
    if ((ability.AbilityChannelAnimation || undefined) !== channel) throw new Error(`${id}: expected channel animation ${channel || 'none'}`);
  }
  if (!abilities.enfos_pudge_dismember.AbilityUnitTargetFlags.includes('MAGIC_IMMUNE_ENEMIES')
      || abilities.enfos_pudge_dismember.SpellImmunityType !== 'SPELL_IMMUNITY_ENEMIES_YES') {
    throw new Error('Dismember must keep its native magic-immune target filter and immunity capability aligned');
  }
  const startup = fs.readFileSync('game/scripts/vscripts/addon_game_mode.lua', 'utf8');
  const soundLoop = startup.match(/for _,name in ipairs\(\{([^}]+)\}\) do\s*\n\s*PrecacheResource\("soundfile"[\s\S]*?\n\s*end/);
  if (!soundLoop || !/"pudge"/.test(soundLoop[1])) throw new Error('Pudge native sound bank is missing from startup precache');
});
check('Underlord preserves native active-spell animations and preloads its native sound bank', () => {
  const abilities = kv('game/scripts/npc/npc_abilities_custom.txt').DOTAAbilities;
  const expected = {
    enfos_underlord_firestorm: 'ACT_DOTA_CAST_ABILITY_1',
    enfos_underlord_pit_of_malice: 'ACT_DOTA_CAST_ABILITY_2',
    enfos_underlord_dark_rift: 'ACT_DOTA_CAST_ABILITY_4',
  };
  for (const [id, animation] of Object.entries(expected)) {
    if (abilities[id].AbilityCastAnimation !== animation) throw new Error(`${id}: expected native cast animation ${animation}`);
  }
  const startup = fs.readFileSync('game/scripts/vscripts/addon_game_mode.lua', 'utf8');
  const soundLoop = startup.match(/for _,name in ipairs\(\{([^}]+)\}\) do\s*\n\s*PrecacheResource\("soundfile"[\s\S]*?\n\s*end/);
  if (!soundLoop || !/"abyssal_underlord"/.test(soundLoop[1])) throw new Error('Underlord native sound bank is missing from startup precache');
});
check('Ursa preserves native active-spell animations and preloads its native sound bank', () => {
  const abilities = kv('game/scripts/npc/npc_abilities_custom.txt').DOTAAbilities;
  const expected = {
    enfos_ursa_earthshock: 'ACT_DOTA_CAST_ABILITY_1',
    enfos_ursa_overpower: 'ACT_DOTA_OVERRIDE_ABILITY_3',
    enfos_ursa_enrage: 'ACT_DOTA_OVERRIDE_ABILITY_4',
  };
  for (const [id, animation] of Object.entries(expected)) {
    if (abilities[id].AbilityCastAnimation !== animation) throw new Error(`${id}: expected native cast animation ${animation}`);
  }
  const startup = fs.readFileSync('game/scripts/vscripts/addon_game_mode.lua', 'utf8');
  const soundLoop = startup.match(/for _,name in ipairs\(\{([^}]+)\}\) do\s*\n\s*PrecacheResource\("soundfile"[\s\S]*?\n\s*end/);
  if (!soundLoop || !/"ursa"/.test(soundLoop[1])) throw new Error('Ursa native sound bank is missing from startup precache');
});
check('Monkey King Boundless Strike keeps its native cast animation and sound bank is preloaded', () => {
  const ability = kv('game/scripts/npc/npc_abilities_custom.txt').DOTAAbilities.enfos_mk_boundless_strike;
  if (ability.AbilityCastAnimation !== 'ACT_DOTA_MK_STRIKE') throw new Error('Boundless Strike must use the verified native staff-strike animation');
  const startup = fs.readFileSync('game/scripts/vscripts/addon_game_mode.lua', 'utf8');
  const soundLoop = startup.match(/for _,name in ipairs\(\{([^}]+)\}\) do\s*\n\s*PrecacheResource\("soundfile"[\s\S]*?\n\s*end/);
  if (!soundLoop || !/"monkey_king"/.test(soundLoop[1])) throw new Error('Monkey King native sound bank is missing from startup precache');
});
check('Troll Warlord preserves native active-spell animations and preloads its native sound bank', () => {
  const abilities = kv('game/scripts/npc/npc_abilities_custom.txt').DOTAAbilities;
  const expected = {
    enfos_troll_berserkers_rage: 'ACT_DOTA_CAST_ABILITY_1',
    enfos_troll_whirling_axes: 'ACT_DOTA_CAST_ABILITY_3',
    enfos_troll_battle_trance: 'ACT_DOTA_CAST_ABILITY_4',
  };
  for (const [id, animation] of Object.entries(expected)) {
    if (abilities[id].AbilityCastAnimation !== animation) throw new Error(`${id}: expected native cast animation ${animation}`);
  }
  const startup = fs.readFileSync('game/scripts/vscripts/addon_game_mode.lua', 'utf8');
  const soundLoop = startup.match(/for _,name in ipairs\(\{([^}]+)\}\) do\s*\n\s*PrecacheResource\("soundfile"[\s\S]*?\n\s*end/);
  if (!soundLoop || !/"troll_warlord"/.test(soundLoop[1])) throw new Error('Troll Warlord native sound bank is missing from startup precache');
});
check('Chaos Knight preserves native active-spell animations and preloads its native sound bank', () => {
  const abilities = kv('game/scripts/npc/npc_abilities_custom.txt').DOTAAbilities;
  const expected = {
    enfos_ck_chaos_bolt: 'ACT_DOTA_CAST_ABILITY_1',
    enfos_ck_reality_rift: 'ACT_DOTA_OVERRIDE_ABILITY_2',
    enfos_ck_phantasm: 'ACT_DOTA_CAST_ABILITY_4',
  };
  for (const [id, animation] of Object.entries(expected)) {
    if (abilities[id].AbilityCastAnimation !== animation) throw new Error(`${id}: expected native cast animation ${animation}`);
  }
  const startup = fs.readFileSync('game/scripts/vscripts/addon_game_mode.lua', 'utf8');
  const soundLoop = startup.match(/for _,name in ipairs\(\{([^}]+)\}\) do\s*\n\s*PrecacheResource\("soundfile"[\s\S]*?\n\s*end/);
  if (!soundLoop || !/"chaos_knight"/.test(soundLoop[1])) throw new Error('Chaos Knight native sound bank is missing from startup precache');
});
check('Anti-Mage preserves native active-spell animations and preloads its native sound bank', () => {
  const abilities = kv('game/scripts/npc/npc_abilities_custom.txt').DOTAAbilities;
  const expected = {
    enfos_am_blink: 'ACT_DOTA_CAST_ABILITY_2',
    enfos_am_counterspell: 'ACT_DOTA_CAST_ABILITY_3',
    enfos_am_mana_void: 'ACT_DOTA_CAST_ABILITY_4',
  };
  for (const [id, animation] of Object.entries(expected)) {
    if (abilities[id].AbilityCastAnimation !== animation) throw new Error(`${id}: expected native cast animation ${animation}`);
  }
  const startup = fs.readFileSync('game/scripts/vscripts/addon_game_mode.lua', 'utf8');
  const soundLoop = startup.match(/for _,name in ipairs\(\{([^}]+)\}\) do\s*\n\s*PrecacheResource\("soundfile"[\s\S]*?\n\s*end/);
  if (!soundLoop || !/"antimage"/.test(soundLoop[1])) throw new Error('Anti-Mage native sound bank is missing from startup precache');
});
check('Lina exposes five ten-rank abilities, delayed Light Strike Array and a separate Enfos passive', () => {
  const abilities = kv('game/scripts/npc/npc_abilities_custom.txt').DOTAAbilities;
  const curves = {
    enfos_lina_dragon_slave: ['damage'],
    enfos_lina_light_strike_array: ['damage', 'stun_duration'],
    enfos_lina_fiery_soul: ['fiery_soul_attack_speed_bonus', 'fiery_soul_max_stacks'],
    enfos_lina_laguna_blade: ['damage'],
    enfos_lina_combustion: ['spell_amp', 'burn_dps'],
  };
  for (const [id, keys] of Object.entries(curves)) {
    const ability = abilities[id];
    if (Number(ability.MaxLevel) !== 10) throw new Error(`${id}: MaxLevel must be 10`);
    const specials = getAbilityValues(ability);
    for (const key of keys) {
      if ((specials[key] || '').trim().split(/\s+/).length !== 10) throw new Error(`${id}.${key}: expected exactly 10 ranks`);
    }
  }
  if (abilities.enfos_lina_combustion.Innate) throw new Error('The Enfos fifth-slot passive must not be marked as a Dota innate');
  const strike = getAbilityValues(abilities.enfos_lina_light_strike_array);
  if (Number(strike.light_strike_array_delay_time) !== 0.5) throw new Error('Light Strike Array must delay impact by 0.5 seconds');
  if (Number(getAbilityValues(abilities.enfos_lina_dragon_slave).dragon_slave_speed) !== 1200) throw new Error('Dragon Slave projectile speed must match the verified native speed');
  if (Number(getAbilityValues(abilities.enfos_lina_combustion).burn_int_pct) !== 30) throw new Error('Combustion Intelligence burn scaling must be explicitly configured');
});
check('Omniknight exposes five ten-rank abilities and keeps the Enfos passive outside Dota innate metadata', () => {
  const abilities = kv('game/scripts/npc/npc_abilities_custom.txt').DOTAAbilities;
  const curves = {
    enfos_omni_purification: ['heal_amount'],
    enfos_omni_repel: ['bonus_hp_regen', 'bonus_strength', 'bonus_armor'],
    enfos_omni_degen_aura: ['slow_pct', 'attack_slow'],
    enfos_omni_guardian_angel: ['duration', 'bonus_hp_regen'],
    enfos_omni_hammer_of_purity: ['bonus_pure_damage', 'slow_pct'],
  };
  for (const [id, keys] of Object.entries(curves)) {
    const ability = abilities[id];
    if (Number(ability.MaxLevel) !== 10) throw new Error(`${id}: MaxLevel must be 10`);
    const specials = getAbilityValues(ability);
    for (const key of keys) {
      if ((specials[key] || '').trim().split(/\s+/).length !== 10) throw new Error(`${id}.${key}: expected exactly 10 ranks`);
    }
  }
  for (const id of ['enfos_omni_purification', 'enfos_omni_repel', 'enfos_omni_guardian_angel']) {
    for (const field of ['AbilityCooldown', 'AbilityManaCost']) {
      if ((abilities[id][field] || '').trim().split(/\s+/).length !== 10) throw new Error(`${id}.${field}: expected exactly 10 ranks`);
    }
  }
  if (abilities.enfos_omni_hammer_of_purity.Innate) throw new Error('The Enfos fifth-slot passive must not use Dota innate metadata');
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
  const nativeTide = JSON.parse(fs.readFileSync('docs/audit/TIDEHUNTER_NATIVE_SOURCE_2026-10-04.json', 'utf8')).abilities;
  const nativeMaul = JSON.parse(fs.readFileSync('docs/audit/URSA_NATIVE_SOURCE_2026-10-04.json','utf8')).abilities.ursa_maul;
  for (const [heroId, hero] of Object.entries(heroes)) {
    for (const [key, ability] of Object.entries(hero)) {
      const verifiedCatch = heroId === 'npc_dota_hero_tidehunter' && key === 'Ability7'
        && ability === 'tidehunter_leviathans_catch'
        && nativeTide[ability]?.MaxLevel === '1' && nativeTide[ability]?.Innate === '1'
        && nativeTide[ability]?.AbilityBehavior.includes('DOTA_ABILITY_BEHAVIOR_HIDDEN');
      const verifiedMaul = heroId === 'npc_dota_hero_ursa' && key === 'Ability7'
        && ability === 'ursa_maul'
        && nativeMaul.MaxLevel === '1' && nativeMaul.Innate === '1'
        && nativeMaul.AbilityBehavior.includes('DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE');
      if (/^Ability\d+$/.test(key) && ability !== 'generic_hidden' && !abilities[ability] && !verifiedCatch && !verifiedMaul) throw new Error(`Unknown ability ${ability}`);
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
check('talent tree removal contract', () => {
  const result=spawnSync(process.execPath,['tools/check_talent_tree_removed.mjs'],{encoding:'utf8'});
  if(result.status!==0) throw new Error(result.stderr || result.stdout);
  console.log(result.stdout.trim());
});
check('all-hero structural inventory is current', () => {
  const result=spawnSync(process.execPath,['tools/audit_heroes_deep.mjs'],{encoding:'utf8'});
  if(result.status!==0) throw new Error(result.stderr || result.stdout);
  console.log(result.stdout.trim());
});
check('production and local Tools map allowlist', () => {
  const maps = kv('game/addoninfo.txt').AddonInfo.maps.split(/\s+/);
  if (maps.join(' ') !== 'enfos enfos_test') throw new Error('Only canonical Enfos and the local test arena are approved');
  const info=kv('game/addoninfo.txt').AddonInfo;
  if(info.DefaultMap!=='enfos'||info.enfos_test.MaxPlayers!=='1')throw new Error('Test map must remain separate and single-player');
  const shipped = fs.existsSync('game/maps') ? fs.readdirSync('game/maps').filter(f => f.endsWith('.vpk')) : [];
  for (const file of shipped) if (!maps.includes(path.basename(file, '.vpk'))) throw new Error(`Unapproved map in game/maps: ${file}`);
  if (fs.existsSync('content/maps/enfos.vmap')) throw new Error('Unsafe placeholder source in canonical Enfos build tree');
});
check('isolated hero test room', () => {
  const result=spawnSync(process.execPath,['--test','tools/tests/hero_test_room.test.mjs','tools/tests/tidehunter_shard_guard.test.mjs'],{encoding:'utf8'});
  if(result.status!==0)throw new Error(result.stderr||result.stdout);
});
check('installed map/theme matches recorded playable version', () => {
  const result = spawnSync(process.execPath, ['tools/check_map.mjs'], {encoding:'utf8'});
  if (result.status !== 0) throw new Error(result.stderr || result.stdout);
});
check('validator regression tests', () => {
  const result = spawnSync(process.execPath, ['--test', 'tools/tests/luna_native.test.mjs', 'tools/tests/luna_native_integration.test.mjs', 'tools/tests/hero_trace_startup.test.mjs', 'tools/tests/hero_isolation.test.mjs', 'tools/tests/vengefulspirit_isolation.test.mjs', 'tools/tests/lion_spike.test.mjs', 'tools/tests/lion_spike_motion.test.mjs', 'tools/tests/lion_hex.test.mjs', 'tools/tests/lion_drain_visual.test.mjs', 'tools/tests/lion_drain_cast.test.mjs', 'tools/tests/lion_drain_economy.test.mjs', 'tools/tests/lion_drain_slow.test.mjs', 'tools/tests/lion_shard_detection.test.mjs', 'tools/tests/lion_shard_channel.test.mjs', 'tools/tests/lion_shard_targets.test.mjs', 'tools/tests/lion_shard_role.test.mjs', 'tools/tests/lion_scepter.test.mjs', 'tools/tests/lion_punch.test.mjs', 'tools/tests/lion_punch_credit.test.mjs', 'tools/tests/lion_finger_targets.test.mjs', 'tools/tests/lion_finger_grace.test.mjs', 'tools/tests/lion_counter.test.mjs', 'tools/tests/lion_passive.test.mjs', 'tools/tests/lion_isolation.test.mjs', 'tools/tests/jakiro_isolation.test.mjs', 'tools/tests/jakiro_macropyre.test.mjs', 'tools/tests/jakiro_macropyre_lifecycle.test.mjs', 'tools/tests/jakiro_macropyre_burn.test.mjs', 'tools/tests/jakiro_ice_path.test.mjs', 'tools/tests/jakiro_path_lifecycle.test.mjs', 'tools/tests/jakiro_passive.test.mjs', 'tools/tests/jakiro_breath_slow.test.mjs', 'tools/tests/jakiro_dual_breath.test.mjs', 'tools/tests/jakiro_liquid_fire_safety.test.mjs', 'tools/tests/jakiro_liquid_fire_burn.test.mjs', 'tools/tests/jakiro_liquid_fire_impact.test.mjs', 'tools/tests/jakiro_shard_mana.test.mjs', 'tools/tests/jakiro_frost_pair.test.mjs', 'tools/tests/jakiro_scepter_core.test.mjs', 'tools/tests/jakiro_scepter_edges.test.mjs', 'tools/tests/jakiro_ready_visuals.test.mjs', 'tools/tests/jakiro_orb_projectile.test.mjs', 'tools/tests/jakiro_orb_records.test.mjs', 'tools/tests/jakiro_manual_attack.test.mjs', 'tools/tests/vengefulspirit_aura.test.mjs', 'tools/tests/vengefulspirit_targets.test.mjs', 'tools/tests/vengefulspirit_wave.test.mjs', 'tools/tests/vengefulspirit_passive.test.mjs', 'tools/tests/vengefulspirit_presentation.test.mjs', 'tools/tests/vengefulspirit_shard.test.mjs', 'tools/tests/vengefulspirit_scepter.test.mjs', 'tools/tests/vengefulspirit_projectile.test.mjs', 'tools/tests/vengefulspirit_swap.test.mjs', 'tools/tests/lich_ordinary_targets.test.mjs', 'tools/tests/lich_scepter.test.mjs', 'tools/tests/lich_spire.test.mjs', 'tools/tests/kv.test.mjs', 'tools/tests/hero_selection.test.mjs', 'tools/tests/ascended_shop.test.mjs', 'tools/tests/spellbringer.test.mjs', 'tools/tests/content_contracts.test.mjs', 'tools/tests/hud_release.test.mjs'], { stdio: 'inherit' });
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
  for (const dir of ['game/resource', 'game/panorama/localization', 'content/panorama/localization']) {
    for (const lang of languages) {
      if (!fs.readFileSync(`${dir}/addon_${lang}.txt`, 'utf8').startsWith('\uFEFF')) {
        throw new Error(`${dir}/addon_${lang}.txt needs a Unicode BOM for Source 2`);
      }
    }
  }
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
check('opening balance regressions',()=>{
 const r=spawnSync(process.execPath,['--test','tools/tests/opening_balance.test.mjs'],{stdio:'inherit'});
 if(r.status!==0) throw new Error('Opening balance regressions failed');
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
  if (abilities.bulwark_shield_slam?.AbilitySound!=='Hero_Sven.StormBolt'
      || abilities.bulwark_challenge?.AbilitySound!=='Hero_Sven.WarCry'
      || abilities.bulwark_shield_slam.AbilitySound===abilities.bulwark_challenge.AbilitySound) {
    throw new Error('Sven Q/W need distinct engine-level cast sound events');
  }
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
check('retired compiled-map TreeShop and CourierZone compatibility', () => {
  const result = spawnSync(process.execPath, ['--test', 'tools/tests/retired_map_triggers.test.mjs'], { stdio: 'inherit' });
  if (result.status !== 0) throw new Error('Retired map trigger regressions failed');
});
check('Shadow Fiend reviewed native ability contracts', () => {
  const result = spawnSync(process.execPath, ['--test', 'tools/tests/shadow_fiend_native.test.mjs', 'tools/tests/bristleback_native.test.mjs', 'tools/tests/bristleback_integration.test.mjs', 'tools/tests/slark_native.test.mjs', 'tools/tests/tidehunter_native.test.mjs', 'tools/tests/ursa_native.test.mjs', 'tools/tests/ursa_overpower_native.test.mjs', 'tools/tests/ursa_maul_native.test.mjs', 'tools/tests/antimage_native.test.mjs', 'tools/tests/storm_native.test.mjs', 'tools/tests/dragon_knight_native.test.mjs', 'tools/tests/shadow_fiend_sustain.test.mjs', 'tools/tests/shadow_fiend_integration.test.mjs', 'tools/tests/hero_health.test.mjs', 'tools/tests/hero_runtime_log_report.test.mjs'], { stdio: 'inherit' });
  if (result.status !== 0) throw new Error('Shadow Fiend native contracts failed');
});
console.log(`${failures} failed check(s). Engine playtests remain separate.`);
process.exitCode = failures ? 1 : 0;
