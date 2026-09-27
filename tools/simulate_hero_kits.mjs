// Enfos Team Survival — SametC Edition: Hero Kit Wave Combat Simulation
// Simulates wave clearing dynamics, mana sustainability, and survivability across 1P, 2P, and 5P teams.

import fs from 'node:fs';
import { parseKV } from './lib/kv.mjs';

const waveDefinitionsKV = parseKV(fs.readFileSync('game/scripts/npc/npc_units_custom.txt', 'utf8')).DOTAUnits;
const balanceConfig = {
  solo_multiplier: 1.0,
  hero_power_baseline: { hp: 250, damage: 25, spell_amp: 20, cooldown: 15, hp_regen: 4, mana_regen: 2 },
  hero_power_solo: { hp: 600, damage: 45, spell_amp: 35, cooldown: 25, hp_regen: 8, mana_regen: 4 }
};

const heroes = [
  { name: 'Sven', role: 'Tank', baseDps: 85, aoeDps: 220, burstDps: 450, manaCostPerSec: 12, hp: 1250, armor: 18, sustainPerSec: 35 },
  { name: 'Axe', role: 'Tank', baseDps: 90, aoeDps: 260, burstDps: 500, manaCostPerSec: 10, hp: 1300, armor: 20, sustainPerSec: 40 },
  { name: 'Centaur', role: 'Tank', baseDps: 80, aoeDps: 240, burstDps: 480, manaCostPerSec: 8, hp: 1450, armor: 16, sustainPerSec: 45 },
  { name: 'Juggernaut', role: 'Fighter', baseDps: 130, aoeDps: 340, burstDps: 680, manaCostPerSec: 15, hp: 950, armor: 12, sustainPerSec: 45 },
  { name: 'Legion Commander', role: 'Fighter', baseDps: 125, aoeDps: 360, burstDps: 650, manaCostPerSec: 14, hp: 1050, armor: 14, sustainPerSec: 50 },
  { name: 'Drow Ranger', role: 'Carry', baseDps: 160, aoeDps: 380, burstDps: 620, manaCostPerSec: 14, hp: 820, armor: 8, sustainPerSec: 15 },
  { name: 'Luna', role: 'Carry', baseDps: 140, aoeDps: 420, burstDps: 750, manaCostPerSec: 16, hp: 860, armor: 10, sustainPerSec: 20 },
  { name: 'Sniper', role: 'Carry', baseDps: 155, aoeDps: 370, burstDps: 640, manaCostPerSec: 12, hp: 790, armor: 7, sustainPerSec: 12 },
  { name: 'Lina', role: 'Mage', baseDps: 90, aoeDps: 460, burstDps: 850, manaCostPerSec: 28, hp: 780, armor: 6, sustainPerSec: 18 },
  { name: 'Crystal Maiden', role: 'Mage', baseDps: 85, aoeDps: 450, burstDps: 820, manaCostPerSec: 25, hp: 750, armor: 5, sustainPerSec: 22 },
  { name: 'Omniknight', role: 'Support', baseDps: 70, aoeDps: 260, burstDps: 390, manaCostPerSec: 18, hp: 1100, armor: 14, sustainPerSec: 65 },
  { name: 'Dazzle', role: 'Support', baseDps: 75, aoeDps: 280, burstDps: 420, manaCostPerSec: 16, hp: 980, armor: 11, sustainPerSec: 60 },
  { name: 'Bristleback', role: 'Tank', baseDps: 95, aoeDps: 310, burstDps: 520, manaCostPerSec: 12, hp: 1350, armor: 19, sustainPerSec: 42 },
  { name: 'Tidehunter', role: 'Tank', baseDps: 85, aoeDps: 270, burstDps: 510, manaCostPerSec: 11, hp: 1400, armor: 22, sustainPerSec: 48 },
  { name: 'Wraith King', role: 'Fighter', baseDps: 135, aoeDps: 320, burstDps: 710, manaCostPerSec: 12, hp: 1150, armor: 15, sustainPerSec: 55 },
  { name: 'Phantom Assassin', role: 'Carry', baseDps: 170, aoeDps: 390, burstDps: 890, manaCostPerSec: 14, hp: 840, armor: 9, sustainPerSec: 25 },
  { name: 'Zeus', role: 'Mage', baseDps: 80, aoeDps: 480, burstDps: 880, manaCostPerSec: 30, hp: 760, armor: 5, sustainPerSec: 16 },
  { name: 'Witch Doctor', role: 'Support', baseDps: 80, aoeDps: 310, burstDps: 580, manaCostPerSec: 22, hp: 920, armor: 8, sustainPerSec: 58 },
];

const waveArchetypes = [
  { wave: 1, name: 'Troll Recruits', unitCount: 20, creepHp: 160, creepDmg: 12, creepArmor: 1, type: 'normal' },
  { wave: 5, name: 'Boss Stonebreaker', unitCount: 1, creepHp: 4200, creepDmg: 85, creepArmor: 12, type: 'boss' },
  { wave: 6, name: 'Gargoyle Pack (Elite)', unitCount: 22, creepHp: 480, creepDmg: 28, creepArmor: 4, type: 'elite' },
  { wave: 15, name: 'Boss Magma Colossus', unitCount: 1, creepHp: 14500, creepDmg: 190, creepArmor: 22, type: 'boss' },
  { wave: 30, name: 'Abyssal Ravagers', unitCount: 30, creepHp: 2800, creepDmg: 95, creepArmor: 15, type: 'normal' },
  { wave: 60, name: 'Final Boss Archimonde', unitCount: 1, creepHp: 185000, creepDmg: 650, creepArmor: 45, type: 'boss' },
];

console.log('================================================================================');
console.log('ENFOS TEAM SURVIVAL — SAMETC EDITION: HERO KIT WAVE COMBAT SIMULATION');
console.log('Testing 6 Representative Hero Kits (Sven, Juggernaut, Drow, Lina, Omni, Luna)');
console.log('================================================================================\n');

for (const playerCount of [1, 2, 5]) {
  const isSolo = (playerCount === 1);
  const power = isSolo ? balanceConfig.hero_power_solo : balanceConfig.hero_power_baseline;

  console.log(`--------------------------------------------------------------------------------`);
  console.log(`SCENARIO: ${playerCount}P ${isSolo ? 'SOLO SURVIVAL' : 'CO-OP TEAM'} (Enfo Power: +${power.hp} HP, +${power.damage} DMG, +${power.spell_amp}% AMP, -${power.cooldown}% CDR)`);
  console.log(`--------------------------------------------------------------------------------`);

  for (const wave of waveArchetypes) {
    const totalCreepHp = wave.creepHp * wave.unitCount * (wave.type === 'boss' ? (1 + (playerCount - 1) * 0.75) : playerCount);
    const totalIncomingDps = wave.creepDmg * (wave.type === 'boss' ? 1 : Math.min(wave.unitCount, 8)) * (1 + (playerCount - 1) * 0.4);

    console.log(`\n[Wave ${wave.wave}: ${wave.name} (${wave.type.toUpperCase()})] - Total Threat HP: ${Math.round(totalCreepHp)} | Incoming Peak DPS: ${Math.round(totalIncomingDps)}`);

    for (const hero of heroes) {
      // Adjusted stats with Hero Power and Scaling
      const levelFactor = 1 + (wave.wave / 60) * 2.5; // stats scale as hero levels up
      const heroDps = (hero.aoeDps + power.damage) * (1 + power.spell_amp / 100) * levelFactor;
      const teamDps = heroDps * playerCount;

      const clearTimeSec = Math.max(3.0, totalCreepHp / teamDps);
      const manaSpent = hero.manaCostPerSec * clearTimeSec;
      const manaRegenTotal = (3 + power.mana_regen) * clearTimeSec;
      const netManaDelta = Math.round(manaRegenTotal - manaSpent);

      const effectiveHp = (hero.hp + power.hp) * (1 + hero.armor * 0.06);
      const totalDamageTaken = (totalIncomingDps / playerCount) * (1 - (hero.armor * 0.06) / (1 + hero.armor * 0.06)) * (clearTimeSec * 0.5);
      const totalSustain = (hero.sustainPerSec + power.hp_regen) * clearTimeSec;
      const netHpDamage = Math.max(0, Math.round(totalDamageTaken - totalSustain));
      const survivabilityPct = Math.max(0, Math.min(100, Math.round((1 - netHpDamage / effectiveHp) * 100)));

      const status = clearTimeSec <= 35 && survivabilityPct > 20 ? 'VIABLE' : 'STRESSED';

      console.log(`  * ${hero.name.padEnd(14)} [${hero.role.padEnd(7)}]: Clear Time: ${clearTimeSec.toFixed(1)}s | Net Mana: ${netManaDelta >= 0 ? '+' + netManaDelta : netManaDelta} | Net HP Retained: ${survivabilityPct}% | [${status}]`);
    }
  }
  console.log('\n');
}
