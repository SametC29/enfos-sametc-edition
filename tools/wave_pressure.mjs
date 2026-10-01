// Measures the authored regular-wave pressure from the production planner.
// This is a raw KV proxy, not a combat simulation or engine certification.
import fs from 'node:fs';
import { spawnSync } from 'node:child_process';
import { parseKV } from './lib/kv.mjs';

const lua = `package.path='game/scripts/vscripts/?.lua;'..package.path
local W=require('waves/wave_definitions')
for wave=1,60 do
 if wave%5~=0 then
  for _,entry in ipairs(W:GetSpawnPlan(wave,1)) do
   print(table.concat({wave,entry.unit_name,entry.count},','))
  end
 end
end`;
const plan = spawnSync(process.execPath, ['node_modules/fengari-node-cli/src/lua-cli.js', '-e', lua], { encoding: 'utf8' });
if (plan.status || plan.stderr) throw new Error(plan.stderr || 'Production wave planner failed');

const units = parseKV(fs.readFileSync('game/scripts/npc/npc_units_custom.txt', 'utf8')).DOTAUnits;
const waves = Array.from({ length: 60 }, (_, index) => ({
  wave: index + 1, act: Math.floor(index / 10) + 1, scheduled_units: 0,
  raw_total_health: 0, raw_base_attack_output_per_second: 0,
}));
for (const line of plan.stdout.trim().split(/\r?\n/)) {
  const [waveText, unitName, countText] = line.split(',');
  const unit = units[unitName];
  if (!unit) throw new Error(`Wave planner references unknown unit ${unitName}`);
  const row = waves[Number(waveText) - 1];
  const count = Number(countText);
  const meanAttack = (Number(unit.AttackDamageMin || 0) + Number(unit.AttackDamageMax || 0)) / 2;
  const attackRate = Number(unit.AttackRate || 1);
  row.scheduled_units += count;
  row.raw_total_health += count * Number(unit.StatusHealth || 0);
  row.raw_base_attack_output_per_second += count * meanAttack / attackRate;
}

const normalWaves = waves.filter(row => row.wave % 5 !== 0);
const acts = Array.from({ length: 6 }, (_, index) => {
  const rows = normalWaves.filter(row => row.act === index + 1);
  const total = key => rows.reduce((sum, row) => sum + row[key], 0);
  return {
    act: index + 1,
    regular_waves: rows.length,
    average_scheduled_units: total('scheduled_units') / rows.length,
    average_raw_total_health: total('raw_total_health') / rows.length,
    average_raw_base_attack_output_per_second: total('raw_base_attack_output_per_second') / rows.length,
  };
});
for (const metric of ['average_scheduled_units', 'average_raw_total_health', 'average_raw_base_attack_output_per_second']) {
  for (let index = 1; index < acts.length; index++) {
    if (!(acts[index][metric] > acts[index - 1][metric])) {
      throw new Error(`${metric} must rise between acts ${index} and ${index + 1}`);
    }
  }
}

const header = 'wave,act,scheduled_units,raw_total_health,raw_base_attack_output_per_second';
const csv = [header, ...normalWaves.map(row => [row.wave, row.act, row.scheduled_units,
  row.raw_total_health, row.raw_base_attack_output_per_second.toFixed(2)].join(','))].join('\n') + '\n';
const output = 'docs/audit/wave-pressure.csv';
if (process.argv.includes('--write')) {
  fs.writeFileSync(output, csv);
} else {
  if (!fs.existsSync(output) || fs.readFileSync(output, 'utf8') !== csv) {
    throw new Error('Wave pressure audit is stale; run node tools/wave_pressure.mjs --write');
  }
}
console.log('PASS: 52 normal waves measured; count, raw health and raw base attack output rise across all six acts.');
for (const act of acts) console.log(`Act ${act.act}: ${act.average_scheduled_units.toFixed(1)} units, ${act.average_raw_total_health.toFixed(0)} raw HP, ${act.average_raw_base_attack_output_per_second.toFixed(0)} raw attack output/s`);
