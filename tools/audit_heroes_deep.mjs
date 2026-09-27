import fs from 'fs';

const heroesKv = fs.readFileSync('game/scripts/npc/npc_heroes_custom.txt', 'utf8');
const pveKits = fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua', 'utf8');
const abilitiesKv = fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt', 'utf8');

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

console.log(`Auditing ${heroes.length} heroes...`);
heroes.forEach((h, i) => {
  console.log(`${i+1}. ${h.heroName} [${h.role}]: ${h.abilities.join(', ')}`);
});


// Check 1: Extract all AddNewModifier and GetIntrinsicModifierName calls
const modifierRegex = /AddNewModifier\s*\([^,]+,\s*[^,]+,\s*'([^']+)'/g;
const intrinsicRegex = /GetIntrinsicModifierName\(\)\s*return\s*'([^']+)'/g;
const modifiersUsed = new Set();

while ((match = modifierRegex.exec(pveKits)) !== null) {
  modifiersUsed.add(match[1]);
}
while ((match = intrinsicRegex.exec(pveKits)) !== null) {
  modifiersUsed.add(match[1]);
}

// Find all modifier classes in pve_kits
const modClassRegex = /(modifier_[a-z0-9_]+)\s*=\s*class\(/g;
const modifiersDefined = new Set();
while ((match = modClassRegex.exec(pveKits)) !== null) {
  modifiersDefined.add(match[1]);
}

// Find all linked modifiers in modifier_list
const modListMatch = pveKits.match(/local modifier_list = \{([\s\S]*?)\}/);
const linkedModifiers = new Set();
if (modListMatch) {
  const inner = modListMatch[1];
  const itemRegex = /'([^']+)'/g;
  let m;
  while ((m = itemRegex.exec(inner)) !== null) {
    linkedModifiers.add(m[1]);
  }
}

console.log(`Modifiers used: ${modifiersUsed.size}, defined: ${modifiersDefined.size}, linked: ${linkedModifiers.size}`);

for (const mod of modifiersUsed) {
  if (!modifiersDefined.has(mod) && !mod.includes('modifier_generic_') && !mod.includes('modifier_stunned')) {
    console.log(`[UNDEFINED MODIFIER] Used but not defined: ${mod}`);
  }
  if (!linkedModifiers.has(mod) && !mod.includes('modifier_generic_') && !mod.includes('modifier_stunned')) {
    console.log(`[UNLINKED MODIFIER] Defined/Used but not in modifier_list: ${mod}`);
  }
}

// Check 2: Unsafe GetAverageTrueAttackDamage
const lines = pveKits.split('\n');
lines.forEach((line, idx) => {
  if (line.includes('GetAverageTrueAttackDamage') && !line.includes('pcall')) {
    // Check if called with 0 args
    if (line.match(/GetAverageTrueAttackDamage\s*\(\s*\)/)) {
      console.log(`[FATAL C++ CRASH RISK] Line ${idx + 1}: 0-arg GetAverageTrueAttackDamage(): ${line.trim()}`);
    }
  }
  if (line.includes('GetModifierSpellAmplication_Percentage') || line.includes('MODIFIER_PROPERTY_SPELL_AMPLIFICATION_PERCENTAGE')) {
    console.log(`[SPELL AMP TYPO] Line ${idx + 1}: ${line.trim()}`);
  }
});

// Check 3: Heroes with stance / projectile requirements
console.log('\n--- Checking specific hero mechanics ---');
// Troll Warlord
const trollQ = pveKits.slice(pveKits.indexOf('enfos_troll_berserkers_rage=class'), pveKits.indexOf('enfos_troll_whirling_axes=class'));
console.log('Troll Q has SetAttackCapability:', trollQ.includes('SetAttackCapability'));
console.log('Troll Q has ATTACKS_ARE_MELEE:', trollQ.includes('MODIFIER_STATE_ATTACKS_ARE_MELEE'));

// Terrorblade Metamorphosis
const tbMeta = pveKits.slice(pveKits.indexOf('enfos_tb_metamorphosis=class'), pveKits.indexOf('enfos_tb_sunder=class'));
console.log('TB Meta has SetAttackCapability:', tbMeta.includes('SetAttackCapability'));
console.log('TB Meta has projectile:', tbMeta.includes('SetRangedProjectileName'));

// Dragon Knight Elder Dragon Form
const dkDragon = pveKits.slice(pveKits.indexOf('enfos_dk_elder_dragon_form=class'), pveKits.indexOf('enfos_dk_wyrm_vigor=class'));
console.log('DK Elder Dragon has SetAttackCapability:', dkDragon.includes('SetAttackCapability'));
console.log('DK Elder Dragon has projectile:', dkDragon.includes('SetRangedProjectileName'));

