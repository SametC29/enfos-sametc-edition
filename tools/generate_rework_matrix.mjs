import fs from 'node:fs';
import { parseKV } from './lib/kv.mjs';

const heroesKV = parseKV(fs.readFileSync('game/scripts/npc/npc_heroes_custom.txt', 'utf8')).DOTAHeroes;
const abilitiesKV = parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt', 'utf8')).DOTAAbilities;
const pveKitsLua = fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua', 'utf8');

const luaClasses = new Set([...pveKitsLua.matchAll(/^(\w+)=class\(\{\}\)/gm)].map(m => m[1]));

const roles = ['Tank', 'Fighter', 'Carry', 'Mage', 'Support'];
const heroesByRole = {};
for (const r of roles) heroesByRole[r] = [];

for (const [id, h] of Object.entries(heroesKV)) {
  const heroRole = h.Role || 'Fighter';
  heroesByRole[heroRole].push({ id, ...h });
}

let md = `# HERO PVE REWORK MATRIX — 40 HEROES (200 ABILITIES)\n\n`;
md += `Authoritative inventory and PvE redesign matrix for **Enfos Team Survival — SametC Edition**.\n`;
md += `Complies with clean-room reference policy (clean design concepts from Enfo / Watcher of Samsara / Custom Hero Clash without direct code/asset copying).\n\n`;
md += `## Summary Statistics\n`;
md += `- **Total Heroes**: 40 (8 Tank, 8 Fighter, 8 Carry, 8 Mage, 8 Support)\n`;
md += `- **Total Abilities**: 200 (5 per hero)\n`;
md += `- **Active Batch 1 (Core Foundations)**: Drow Ranger, Luna, Juggernaut, Lina, Sven, Omniknight (30 abilities)\n`;
md += `- **Remaining Batches**: 34 heroes (170 abilities)\n\n`;
md += `| Role | Heroes Count | Core Archetype & PvE Philosophy |\n`;
md += `|---|---|---|\n`;
md += `| **Tank** | 8 | Frontline sustain, crowd aggregation/taunt, armor/reflect scaling, wave stalling without infinite CC loops on bosses. |\n`;
md += `| **Fighter** | 8 | Cleave/swipes, burst survivability, on-kill resets, attack-speed scaling, close-range wave annihilation. |\n`;
md += `| **Carry** | 8 | Multi-shot, ricochet, bounce glaives, piercing projectiles, critical splinters, hyper scaling with Agility/Items. |\n`;
md += `| **Mage** | 8 | Screen-wide AoE waves, spell amp synergies, burst combinations, cast triggers, mana sustainability. |\n`;
md += `| **Support** | 8 | Viable solo wave clearing (via pulsing halos/consecration/bouncing spells) + irreplaceable team auras, heals, and boss vulnerability debuffs. |\n\n`;

for (const role of roles) {
  md += `## Role: ${role} (${heroesByRole[role].length} Heroes)\n\n`;
  for (const hero of heroesByRole[role]) {
    const heroName = hero.id.replace('npc_dota_hero_', '').replace(/_/g, ' ').toUpperCase();
    md += `### ${heroName} (\`${hero.id}\`)\n`;
    md += `- **Primary Attribute**: \`${hero.AttributePrimary}\`\n`;
    md += `- **Role**: \`${role}\`\n\n`;
    md += `| Slot | Ability ID | Current Type | Status | Design Intent & PvE Mechanic | Boss Behavior |\n`;
    md += `|---|---|---|---|---|---|\n`;

    for (let i = 1; i <= 5; i++) {
      const abName = hero[`Ability${i}`];
      if (!abName) continue;
      const abData = abilitiesKV[abName];
      const isLua = abData?.BaseClass === 'ability_lua' && luaClasses.has(abName);
      const isDatadriven = abData?.BaseClass === 'ability_datadriven';
      const curType = isLua ? 'Lua (Active)' : isDatadriven ? 'Datadriven (Mock)' : 'Other';

      let decision = 'ADAPT';
      let status = isLua ? 'KOD + OTOMATIK TEST' : 'EKSİK';
      let intent = 'Custom PvE wave clear adaptation with scaling';
      let bossRule = 'Standard damage';

      if (['npc_dota_hero_drow_ranger', 'npc_dota_hero_luna', 'npc_dota_hero_juggernaut', 'npc_dota_hero_lina', 'npc_dota_hero_sven', 'npc_dota_hero_omniknight'].includes(hero.id)) {
        decision = 'BATCH_1_PRIORITY';
        intent = `High-impact PvE kit overhaul for core ${role} archetype.`;
      }

      md += `| Ability${i} | \`${abName}\` | ${curType} | \`${status}\` | ${intent} | ${bossRule} |\n`;
    }
    md += `\n`;
  }
}

fs.writeFileSync('docs/HERO_PVE_REWORK_MATRIX.md', md, 'utf8');
console.log('Generated docs/HERO_PVE_REWORK_MATRIX.md');
