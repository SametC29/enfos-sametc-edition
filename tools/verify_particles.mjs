import path from 'node:path';
import { pathToFileURL } from 'node:url';

const server = 'C:/Users/samet/.gemini/antigravity/mcp/dota2_workshop_mcp';
const dota = 'C:/Program Files (x86)/Steam/steamapps/common/dota 2 beta';
const { Vpk } = await import(pathToFileURL(path.join(server, 'dist/dota/vpk.js')));
const valve = await Vpk.open(path.join(dota, 'game/dota/pak01_dir.vpk'));

const particles = [
  'particles/units/heroes/hero_juggernaut/juggernaut_blade_fury.vpcf',
  'particles/units/heroes/hero_juggernaut/juggernaut_healing_ward.vpcf',
  'particles/units/heroes/hero_juggernaut/jugg_crit_blur.vpcf',
  'particles/units/heroes/hero_juggernaut/juggernaut_omni_slash.vpcf',
  'particles/units/heroes/hero_drow/drow_frost_arrow.vpcf',
  'particles/units/heroes/hero_drow/drow_silence_wave.vpcf',
  'particles/units/heroes/hero_drow/drow_multishot_proj_linear_proj.vpcf',
  'particles/units/heroes/hero_drow/drow_marksmanship_frost_arrow.vpcf',
  'particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf',
  'particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf',
  'particles/units/heroes/hero_lina/lina_fiery_soul.vpcf',
  'particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf',
  'particles/units/heroes/hero_omniknight/omniknight_purification.vpcf',
  'particles/units/heroes/hero_omniknight/omniknight_repel_buff.vpcf',
  'particles/units/heroes/hero_omniknight/omniknight_degen_aura.vpcf',
  'particles/units/heroes/hero_omniknight/omniknight_guardian_angel_omni.vpcf'
];

let allOk = true;
for (const p of particles) {
  const c = p + '_c';
  const exists = valve.entries.has(c);
  console.log(p, exists ? 'OK' : 'MISSING');
  if (!exists) allOk = false;
}
if (!allOk) process.exit(1);
console.log('All particles verified in Valve VPK.');
