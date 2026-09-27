// Arithmetic audit of the production wave planner, not an assumed wave model.
import fs from 'node:fs';
import { spawnSync } from 'node:child_process';
import { parseKV } from './lib/kv.mjs';
const lua = `package.path='game/scripts/vscripts/?.lua;'..package.path
local W=require('waves/wave_definitions')
for players=1,5 do for wave=1,60 do
 local def=W:GetWave(wave)
 for _,e in ipairs(W:GetSpawnPlan(wave,players)) do
  print(table.concat({players,wave,e.unit_name,e.count,0,0},','))
 end
end end`;
const result = spawnSync(process.execPath, ['node_modules/fengari-node-cli/src/lua-cli.js', '-e', lua], { encoding: 'utf8' });
if (result.status || result.stderr) throw new Error(result.stderr || 'Planner failed');
const units = parseKV(fs.readFileSync('game/scripts/npc/npc_units_custom.txt', 'utf8')).DOTAUnits;
const rows = new Map();
for (const line of result.stdout.trim().split(/\r?\n/)) {
  const [players, wave, unit, count, clearGold, clearXP] = line.split(',');
  const key = `${players},${wave}`;
  const row = rows.get(key) || { players: +players, wave: +wave, count: 0, goldMin: 0, goldMax: 0, xp: 0, clearGold: +clearGold, clearXP: +clearXP };
  const kv = units[unit]; if (!kv) throw new Error('Unknown unit ' + unit);
  row.count += +count; row.goldMin += count * Number(kv.BountyGoldMin || 0);
  row.goldMax += count * Number(kv.BountyGoldMax || 0); row.xp += count * Number(kv.BountyXP || 0);
  rows.set(key, row);
}
const header = 'players,wave,scheduled_units,team_base_gold_min,team_base_gold_max,team_creep_xp,clear_gold_per_player,clear_xp_per_player,mean_gold_per_player_equal_last_hits,xp_per_player';
const csv = [header, ...[...rows.values()].map(r => [r.players,r.wave,r.count,r.goldMin,r.goldMax,r.xp,r.clearGold,r.clearXP,
  ((r.goldMin+r.goldMax)/2/r.players*(1+0.2/r.players)+r.clearGold).toFixed(2),
  (r.xp/r.players+r.clearXP).toFixed(2)].join(','))].join('\n')+'\n';
const target = 'docs/audit/wave-economy.csv';
if (process.argv.includes('--check')) {
  if (fs.readFileSync(target, 'utf8') !== csv) throw new Error('Stale wave economy audit');
} else { fs.mkdirSync('docs/audit', {recursive:true});fs.writeFileSync(target,csv); }
console.log('Audited 300 production wave/player configurations.');
