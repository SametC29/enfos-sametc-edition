// Arithmetic audit of the production wave planner, not an assumed wave model.
import fs from 'node:fs';
import { spawnSync } from 'node:child_process';
import { parseKV } from './lib/kv.mjs';
const lua = `package.path='game/scripts/vscripts/?.lua;'..package.path
local W=require('waves/wave_definitions')
for players=1,5 do for wave=1,60 do
 local def=W:GetWave(wave)
 for _,e in ipairs(W:GetSpawnPlan(wave,players)) do
  print(table.concat({players,wave,e.boss_reward_name or e.unit_name,e.count,0,0},','))
 end
end end`;
const result = spawnSync(process.execPath, ['node_modules/fengari-node-cli/src/lua-cli.js', '-e', lua], { encoding: 'utf8' });
if (result.status || result.stderr) throw new Error(result.stderr || 'Planner failed');
const units = parseKV(fs.readFileSync('game/scripts/npc/npc_units_custom.txt', 'utf8')).DOTAUnits;
const economySource = fs.readFileSync('game/scripts/vscripts/economy/economy_manager.lua', 'utf8');
const shopSource = fs.readFileSync('game/scripts/vscripts/economy/ascended_shop.lua', 'utf8');
const bossBase = Number(economySource.match(/BOSS_LUMBER_BASE\s*=\s*(\d+)/)?.[1]);
const goldPerLumber = Number(economySource.match(/GOLD_TO_LUMBER_RATE\s*=\s*(\d+)/)?.[1]);
const tier3Lumber = Number(shopSource.match(/TIER_3_LUMBER\s*=\s*(\d+)/)?.[1]);
if (![bossBase, goldPerLumber, tier3Lumber].every(Number.isFinite)) throw new Error('Missing economy constants');
const baseCosts = JSON.parse(fs.readFileSync('docs/audit/ASCENDED_NATIVE_SNAPSHOT.json', 'utf8')).items
  .map(x => Number(x.nativeCost)).filter(Number.isFinite).sort((a,b) => a-b);
if (baseCosts.length !== 30) throw new Error('Expected current native costs for 30 Ascended base items');
const fourBaseGoldMin = baseCosts.slice(0,4).reduce((sum,cost) => sum+cost, 0);
const fourBaseGoldMax = baseCosts.slice(-4).reduce((sum,cost) => sum+cost, 0);
const fourTier3Lumber = 4 * tier3Lumber;
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
const sortedRows = [...rows.values()].sort((a,b) => a.players-b.players || a.wave-b.wave);
const economyByPlayers = new Map();
for (const row of sortedRows) {
  const state = economyByPlayers.get(row.players) || { gold: 600, lumber: 0 };
  const killGold = (row.goldMin+row.goldMax)/2/row.players*(1+0.2/row.players);
  state.gold += killGold;
  if (row.wave % 5 === 0) state.lumber += bossBase + Math.floor(row.wave/5);
  row.cumulativeGold = state.gold;
  row.cumulativeBossLumber = state.lumber;
  row.goldForFourTier3 = Math.max(0, fourTier3Lumber-state.lumber)*goldPerLumber;
  row.fourTier3CashMin = fourBaseGoldMin+row.goldForFourTier3;
  row.fourTier3CashMax = fourBaseGoldMax+row.goldForFourTier3;
  economyByPlayers.set(row.players,state);
}
for (const [players,state] of economyByPlayers) {
  const cashNeededMax = fourBaseGoldMax+Math.max(0,fourTier3Lumber-state.lumber)*goldPerLumber;
  if (state.gold < cashNeededMax) throw new Error(`Modeled player ${players} cannot afford four Tier-3 Ascended items by wave 60: ${state.gold.toFixed(2)} < ${cashNeededMax}`);
}
const header = 'players,wave,scheduled_units,team_base_gold_min,team_base_gold_max,team_creep_xp,clear_gold_per_player,clear_xp_per_player,mean_gold_per_player_equal_last_hits,xp_per_player,cumulative_modeled_gold,boss_lumber_this_wave,cumulative_boss_lumber,gold_to_lumber_for_four_tier3,four_tier3_total_gold_min,four_tier3_total_gold_max';
const csv = [header, ...sortedRows.map(r => [r.players,r.wave,r.count,r.goldMin,r.goldMax,r.xp,r.clearGold,r.clearXP,
  ((r.goldMin+r.goldMax)/2/r.players*(1+0.2/r.players)+r.clearGold).toFixed(2),
  (r.xp/r.players+r.clearXP).toFixed(2),
  r.cumulativeGold.toFixed(2),r.wave%5===0?bossBase+Math.floor(r.wave/5):0,r.cumulativeBossLumber,
  r.goldForFourTier3,r.fourTier3CashMin,r.fourTier3CashMax].join(','))].join('\n')+'\n';
const target = 'docs/audit/wave-economy.csv';
if (process.argv.includes('--check')) {
  if (fs.readFileSync(target, 'utf8') !== csv) throw new Error('Stale wave economy audit');
} else { fs.mkdirSync('docs/audit', {recursive:true});fs.writeFileSync(target,csv); }
console.log('Audited 300 production wave/player configurations.');
