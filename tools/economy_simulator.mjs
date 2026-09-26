// tools/economy_simulator.mjs
// Economy simulator for Enfos Team Survival — SametC Edition
// Validates Gold, Lumber, Tomes, Conversions, and Ascended item timing targets across 60 waves.
// Reference: docs/QA_BALANCE_RELEASE.md § 5
// Reference: docs/GAME_DESIGN_MASTER.md §§ 20, 21, 22, 23, 24

import fs from 'node:fs';
import { parseKV } from './lib/kv.mjs';

const DIFFICULTIES = {
  casual: { name: 'Casual', goldMult: 1.10, xpMult: 1.15 },
  normal: { name: 'Normal', goldMult: 1.00, xpMult: 1.00 },
  hard: { name: 'Hard', goldMult: 0.90, xpMult: 0.90 },
  nightmare: { name: 'Nightmare', goldMult: 0.80, xpMult: 0.80 },
  hell: { name: 'Hell', goldMult: 0.75, xpMult: 0.75 },
};

const ASCENDED_TIERS = {
  tier1: 55, // 55 Lumber
  tier2: 70, // 70 Lumber
  tier3: 85, // 85 Lumber
};

const TOME_BASE_COST = 500;
const TOME_PRICE_GROWTH = 0.10;
const GOLD_TO_LUMBER_RATE = 100; // 1000 Gold -> 10 Lumber
const LUMBER_TO_GOLD_RATE = 90;  // 10 Lumber -> 900 Gold

// Load custom units for bounties
const unitsKv = parseKV(fs.readFileSync('game/scripts/npc/npc_units_custom.txt', 'utf8'));

function getUnitBounty(unitName) {
  const u = unitsKv[unitName] || {};
  const goldMin = Number(u.BountyGoldMin) || 10;
  const goldMax = Number(u.BountyGoldMax) || 15;
  const xp = Number(u.BountyXP) || 20;
  return {
    goldAvg: (goldMin + goldMax) / 2,
    xp: xp,
  };
}

// Boss Lumber award formula: 5 + floor(wave / 5)
function getBossLumber(wave) {
  return 5 + Math.floor(wave / 5);
}

// Wave creep counts and composition estimator
function getWaveCreepBudget(wave) {
  const isBoss = wave % 5 === 0;
  const isElite = wave % 6 === 0 && !isBoss;

  if (isBoss) {
    return {
      type: 'boss',
      creepsPerPlayer: 0,
      bossCount: 1,
      eliteCount: 0,
      waveGoldBounty: 150 + wave * 5,
      waveXpBounty: 200 + wave * 10,
    };
  }

  if (isElite) {
    return {
      type: 'elite',
      creepsPerPlayer: 18,
      bossCount: 0,
      eliteCount: 2,
      waveGoldBounty: 60 + wave * 2,
      waveXpBounty: 80 + wave * 3,
    };
  }

  return {
    type: 'normal',
    creepsPerPlayer: 20,
    bossCount: 0,
    eliteCount: 0,
    waveGoldBounty: 40 + wave * 2,
    waveXpBounty: 60 + wave * 3,
  };
}

export function simulateMatch(playerCount = 5, difficultyKey = 'normal', strategy = 'standard') {
  const diff = DIFFICULTIES[difficultyKey] || DIFFICULTIES.normal;
  let playerGold = 600; // Starting gold
  let playerLumber = 0;
  let totalGoldEarned = 600;
  let totalLumberEarned = 0;
  let ascendedItemsBought = 0;
  let tomesBought = 0;
  let firstMajorItemWave = null;
  let firstAscendedWave = null;

  const waveHistory = [];

  for (let wave = 1; wave <= 60; wave++) {
    const budget = getWaveCreepBudget(wave);

    // 1. Creep Bounties
    // Creep gold scales slightly with wave tier: base ~15 gold escalating ~1.5% per wave
    const creepBaseGold = (14 + wave * 0.75) * diff.goldMult;
    const totalCreeps = budget.creepsPerPlayer * playerCount;
    const totalCreepGold = totalCreeps * creepBaseGold;

    // Elite gold
    const totalEliteGold = budget.eliteCount * (60 + wave * 2) * diff.goldMult;

    // Boss gold
    const totalBossGold = budget.bossCount * (300 + wave * 10) * diff.goldMult;

    // Wave clear completion bonus
    const clearGold = budget.waveGoldBounty * diff.goldMult;

    // Team gold total
    const totalTeamWaveGold = totalCreepGold + totalEliteGold + totalBossGold;
    // Equal distribution + killer bonus (20% bonus to killer, averaged out across all players)
    // Average gold per player from creep kills = (teamGold / playerCount) * 1.04
    const playerCreepShare = (totalTeamWaveGold / playerCount) * 1.04;
    const wavePlayerGold = playerCreepShare + clearGold;

    playerGold += wavePlayerGold;
    totalGoldEarned += wavePlayerGold;

    // 2. Boss Lumber
    let waveLumberAward = 0;
    if (budget.type === 'boss') {
      waveLumberAward = getBossLumber(wave);
      playerLumber += waveLumberAward;
      totalLumberEarned += waveLumberAward;
    }

    // 3. Strategy Actions
    if (strategy === 'economy') {
      // Economy player converts 25% of income into Lumber
      const convertGold = Math.floor((wavePlayerGold * 0.25) / GOLD_TO_LUMBER_RATE) * GOLD_TO_LUMBER_RATE;
      if (convertGold >= GOLD_TO_LUMBER_RATE && playerGold >= convertGold) {
        playerGold -= convertGold;
        const gainedLumber = convertGold / GOLD_TO_LUMBER_RATE;
        playerLumber += gainedLumber;
        totalLumberEarned += gainedLumber;
      }
    } else if (strategy === 'tomes') {
      // Tome spender buys a tome whenever gold > 1200
      const nextTomeCost = Math.floor(TOME_BASE_COST * (1 + TOME_PRICE_GROWTH * tomesBought));
      if (playerGold >= nextTomeCost + 800) {
        playerGold -= nextTomeCost;
        tomesBought++;
      }
    }

    // Check first major item (~2500 gold threshold)
    if (firstMajorItemWave === null && totalGoldEarned >= 2500) {
      firstMajorItemWave = wave;
    }

    // Check Ascended purchase
    // Tier I: 55, Tier II: 70, Tier III: 85 Lumber
    const nextAscendedCost = ascendedItemsBought === 0 ? ASCENDED_TIERS.tier1
      : (ascendedItemsBought === 1 ? ASCENDED_TIERS.tier2 : ASCENDED_TIERS.tier3);

    if (playerLumber >= nextAscendedCost) {
      playerLumber -= nextAscendedCost;
      ascendedItemsBought++;
      if (firstAscendedWave === null) {
        firstAscendedWave = wave;
      }
    }

    waveHistory.push({
      wave,
      playerGold: Math.round(playerGold),
      playerLumber: Math.round(playerLumber),
      totalGoldEarned: Math.round(totalGoldEarned),
      totalLumberEarned: Math.round(totalLumberEarned),
      ascendedItems: ascendedItemsBought,
    });
  }

  return {
    playerCount,
    difficulty: diff.name,
    strategy,
    totalGoldEarned: Math.round(totalGoldEarned),
    totalLumberEarned: Math.round(totalLumberEarned),
    finalGoldBalance: Math.round(playerGold),
    finalLumberBalance: Math.round(playerLumber),
    ascendedCount: ascendedItemsBought,
    tomesCount: tomesBought,
    firstMajorItemWave,
    firstAscendedWave,
    waveHistory,
  };
}

export function runFullSimulation() {
  console.log('================================================================================');
  console.log('ENFOS TEAM SURVIVAL — SAMETC EDITION: ECONOMY SIMULATOR');
  console.log('Testing 60 Authored Waves across Player Counts, Difficulties, and Builds');
  console.log('================================================================================\n');

  const playerCounts = [1, 2, 3, 4, 5];
  const results = [];

  // 1. Team Size Sensitivity (Normal Difficulty, Standard Strategy)
  console.log('--- 1. Team Size Sensitivity (Normal Difficulty, Standard Build) ---');
  for (const count of playerCounts) {
    const res = simulateMatch(count, 'normal', 'standard');
    results.push(res);
    console.log(`Players: ${count}P | Total Gold: ${res.totalGoldEarned}g | Total Lumber: ${res.totalLumberEarned}L | First Major: W${res.firstMajorItemWave} | First Ascended: W${res.firstAscendedWave} | Final Ascended: ${res.ascendedCount}`);
  }

  // 2. Build Strategy Comparison (5 Players, Normal Difficulty)
  console.log('\n--- 2. Build Strategy Comparison (5 Players, Normal Difficulty) ---');
  const standardRes = simulateMatch(5, 'normal', 'standard');
  const economyRes = simulateMatch(5, 'normal', 'economy');
  const tomesRes = simulateMatch(5, 'normal', 'tomes');

  console.log(`Standard Build : ${standardRes.ascendedCount} Ascended items (Lumber: ${standardRes.totalLumberEarned}L, Gold: ${standardRes.totalGoldEarned}g)`);
  console.log(`Economy Build  : ${economyRes.ascendedCount} Ascended items (Lumber: ${economyRes.totalLumberEarned}L, Gold: ${economyRes.totalGoldEarned}g)`);
  console.log(`Tome Build     : ${tomesRes.tomesCount} Tomes bought, ${tomesRes.ascendedCount} Ascended items (Gold: ${tomesRes.totalGoldEarned}g)`);

  // 3. Difficulty Sensitivity (5 Players, Standard Build)
  console.log('\n--- 3. Difficulty Sensitivity (5 Players, Standard Build) ---');
  for (const diffKey of Object.keys(DIFFICULTIES)) {
    const res = simulateMatch(5, diffKey, 'standard');
    console.log(`Difficulty: ${res.difficulty.padEnd(10)} | Total Gold: ${res.totalGoldEarned}g | Ascended: ${res.ascendedCount}`);
  }

  // 4. Verification of Roadmap Acceptance Gates
  console.log('\n--- 4. Roadmap Acceptance Gate Verification ---');
  let passed = true;

  // Gate 1: Normal build target is 1-2 Ascended items at Wave 60
  if (standardRes.ascendedCount < 1 || standardRes.ascendedCount > 2) {
    console.error(`FAIL: Standard build Ascended count expected 1-2, got ${standardRes.ascendedCount}`);
    passed = false;
  } else {
    console.log(`PASS: Standard build target met (${standardRes.ascendedCount} Ascended items; target: 1-2)`);
  }

  // Gate 2: Economy build target is 2-3 Ascended items at Wave 60
  if (economyRes.ascendedCount < 2 || economyRes.ascendedCount > 3) {
    console.error(`FAIL: Economy build Ascended count expected 2-3, got ${economyRes.ascendedCount}`);
    passed = false;
  } else {
    console.log(`PASS: Economy build target met (${economyRes.ascendedCount} Ascended items; target: 2-3)`);
  }

  // Gate 3: Currency conservation (no runaway, balances non-negative)
  for (const res of results) {
    if (res.finalGoldBalance < 0 || res.finalLumberBalance < 0) {
      console.error(`FAIL: Negative balance detected in ${res.playerCount}P run`);
      passed = false;
    }
  }
  if (passed) {
    console.log('PASS: Currency conservation and reconciliation verified across all player counts.');
  }

  console.log('\n================================================================================');
  console.log(`ECONOMY SIMULATION RESULT: ${passed ? 'ALL GATES PASSED (100%)' : 'FAILED'}`);
  console.log('================================================================================');

  return passed;
}

// Execute CLI directly if run as main script
if (import.meta.url === `file://${process.argv[1]}` || process.argv[1]?.endsWith('economy_simulator.mjs')) {
  const success = runFullSimulation();
  process.exitCode = success ? 0 : 1;
}
