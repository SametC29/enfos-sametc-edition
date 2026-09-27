import fs from 'fs';

const pveKits = fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua', 'utf8');
const heroesKv = fs.readFileSync('game/scripts/npc/npc_heroes_custom.txt', 'utf8');

// Parse hero blocks
const heroRegex = /"(npc_dota_hero_[a-z0-9_]+)"\s*\{([\s\S]*?^\t\})/gm;
let match;
const heroes = [];

while ((match = heroRegex.exec(heroesKv)) !== null) {
  const heroName = match[1];
  const block = match[2];
  const roleMatch = block.match(/"Role"\s+"([^"]+)"/);
  const role = roleMatch ? roleMatch[1] : 'Unknown';
  
  const abilities = [];
  for (let i = 1; i <= 5; i++) {
    const abMatch = block.match(new RegExp(`"Ability${i}"\\s+"([^"]+)"`));
    if (abMatch) abilities.push(abMatch[1]);
  }
  heroes.push({ heroName, role, abilities });
}

// Extract ability implementations
for (const h of heroes) {
  console.log(`\n=================== ${h.heroName} [${h.role}] ===================`);
  for (const ab of h.abilities) {
    // Find where ab starts
    const startIdx = pveKits.indexOf(`${ab}=class(`) !== -1 ? pveKits.indexOf(`${ab}=class(`) : pveKits.indexOf(`${ab} = class(`);
    if (startIdx === -1) {
      console.log(`  [MISSING] ${ab}`);
      continue;
    }
    // Take a slice until next class or 1500 chars
    const slice = pveKits.slice(startIdx, startIdx + 1500);
    const endMatch = slice.slice(10).search(/\n[a-zA-Z0-9_]+\s*=\s*class\(/);
    const abCode = endMatch !== -1 ? slice.slice(0, endMatch + 10) : slice;
    
    const hasSound = abCode.includes('EmitSound') || abCode.includes('EmitSoundOn');
    const hasParticle = abCode.includes('ParticleManager') || abCode.includes('effect(');
    const hasDamage = abCode.includes('damage(') || abCode.includes('ApplyDamage');
    const hasModifier = abCode.includes('AddNewModifier') || abCode.includes('GetIntrinsicModifierName');
    const isPassive = abCode.includes('GetIntrinsicModifierName');
    
    const flags = [];
    if (!hasSound && !isPassive) flags.push('NO_SOUND');
    if (!hasParticle && !isPassive) flags.push('NO_PARTICLE');
    if (!hasDamage && !hasModifier) flags.push('NO_EFFECT_AT_ALL');
    
    if (flags.length > 0) {
      console.log(`  [ALERT] ${ab} (${flags.join(', ')})`);
    } else {
      console.log(`  [OK] ${ab} (sound:${hasSound}, pfx:${hasParticle}, dmg:${hasDamage}, mod:${hasModifier})`);
    }
  }
}
