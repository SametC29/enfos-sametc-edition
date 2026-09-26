import path from 'node:path';
import { pathToFileURL } from 'node:url';

const server = 'C:/Users/samet/.gemini/antigravity/mcp/dota2_workshop_mcp';
const dota = 'C:/Program Files (x86)/Steam/steamapps/common/dota 2 beta';
const { Vpk } = await import(pathToFileURL(path.join(server, 'dist/dota/vpk.js')));
const valve = await Vpk.open(path.join(dota, 'game/dota/pak01_dir.vpk'));

const unitModels = {
  soldier: 'models/creeps/lane_creeps/creep_radiant_melee/radiant_melee.vmdl_c',
  archer: 'models/creeps/lane_creeps/creep_radiant_ranged/radiant_ranged.vmdl_c',
  runner: 'models/creeps/neutral_creeps/n_creep_kobold/kobold_b/n_creep_kobold_b.vmdl_c',
  frostguard: 'models/creeps/neutral_creeps/n_creep_ghost_a/n_creep_ghost_a.vmdl_c',
  venomous: 'models/creeps/neutral_creeps/n_creep_gnoll/n_creep_gnoll.vmdl_c',
  healer: 'models/creeps/neutral_creeps/n_creep_forest_trolls/n_creep_forest_troll_high_priest.vmdl_c',
  shieldbearer: 'models/creeps/neutral_creeps/n_creep_centaur_lrg/n_creep_centaur_lrg.vmdl_c',
  mindstealer: 'models/creeps/neutral_creeps/n_creep_satyr_a/n_creep_satyr_a.vmdl_c',
  conqueror: 'models/creeps/neutral_creeps/n_creep_golem_a/neutral_creep_golem_a.vmdl_c',
  assassin: 'models/creeps/neutral_creeps/n_creep_harpy_a/n_creep_harpy_a.vmdl_c',
  summoner: 'models/creeps/neutral_creeps/n_creep_troll_dark_a/n_creep_troll_dark_a.vmdl_c',
  spellguard: 'models/creeps/neutral_creeps/n_creep_gargoyle/n_creep_gargoyle.vmdl_c',
  reflector: 'models/creeps/neutral_creeps/n_creep_furbolg/n_creep_furbolg_disrupter.vmdl_c',
  exploder: 'models/creeps/neutral_creeps/n_creep_ogre_med/n_creep_ogre_med.vmdl_c',
  splitter: 'models/creeps/neutral_creeps/n_creep_tadpole/n_creep_tadpole_v2.vmdl_c',
  bloodbeast: 'models/creeps/neutral_creeps/n_creep_worg_large/n_creep_worg_large.vmdl_c',
  cursecaster: 'models/creeps/neutral_creeps/n_creep_vulture_a/n_creep_vulture_a.vmdl_c',
  boss_stonebreaker: 'models/heroes/tiny_01/tiny_01.vmdl_c',
  boss_brood_matron: 'models/heroes/broodmother/broodmother.vmdl_c',
  boss_bloodfang: 'models/heroes/lycan/lycan.vmdl_c',
  boss_frost_warden: 'models/heroes/ancient_apparition/ancient_apparition.vmdl_c',
  boss_mind_devourer: 'models/heroes/invoker/invoker.vmdl_c',
  boss_iron_colossus: 'models/heroes/earthshaker/earthshaker.vmdl_c',
  boss_gravecaller: 'models/heroes/undying/undying.vmdl_c',
  boss_storm_tyrant: 'models/heroes/razor/razor.vmdl_c',
  boss_shadow_huntress: 'models/heroes/phantom_assassin/phantom_assassin.vmdl_c',
  boss_plague_behemoth: 'models/heroes/venomancer/venomancer.vmdl_c',
  boss_rift_lord: 'models/heroes/enigma/enigma.vmdl_c',
  boss_gatekeeper: 'models/heroes/faceless_void/faceless_void.vmdl_c',
  spiderling: 'models/heroes/broodmother/spiderling.vmdl_c',
  skeleton: 'models/creeps/neutral_creeps/n_creep_troll_skeleton/n_creep_skeleton_melee.vmdl_c'
};

let allOk = true;
for (const [k, v] of Object.entries(unitModels)) {
  const has = valve.entries.has(v);
  console.log(`${k.padEnd(24)}: ${has ? 'OK' : 'MISSING (' + v + ')'}`);
  if (!has) allOk = false;
}
if (!allOk) process.exit(1);
console.log('ALL MODELS VERIFIED IN VALVE PAK01 VPK!');
