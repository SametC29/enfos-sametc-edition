import fs from 'fs';
import { parseKV } from './lib/kv.mjs';

const heroesKV = parseKV(fs.readFileSync('game/scripts/npc/npc_heroes_custom.txt', 'utf8')).DOTAHeroes;
const abilitiesKV = parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt', 'utf8')).DOTAAbilities;
const pveKitsLua = fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua', 'utf8');

function extractTokens(filepath) {
  const content = fs.readFileSync(filepath, 'utf8');
  const tokens = new Map();
  const re = /"([^"\r\n]+)"\s*"([^"\r\n]*)"/g;
  let m;
  while ((m = re.exec(content)) !== null) {
    tokens.set(m[1], m[2]);
  }
  return tokens;
}

const englishTokens = extractTokens('game/resource/addon_english.txt');
const turkishTokens = extractTokens('game/resource/addon_turkish.txt');

// Extract registered modifiers from modifier_list at the top of pve_kits.lua
const modListMatch = pveKitsLua.match(/local modifier_list = \{([\s\S]*?)\}\r?\n/);
const registeredModifiers = new Set();
if (modListMatch) {
  const modLines = modListMatch[1].match(/'([^']+)'/g) || [];
  for (const m of modLines) {
    registeredModifiers.add(m.replace(/'/g, ''));
  }
}

// Find all Lua class definitions
const luaClasses = new Set();
const classMatches = pveKitsLua.matchAll(/^([a-zA-Z0-9_]+)\s*=\s*class\(\{\}\)/gm);
for (const m of classMatches) {
  luaClasses.add(m[1]);
}

const issues = [];
const heroReports = [];

let totalHeroes = 0;
let totalAbilities = 0;

for (const [heroId, heroData] of Object.entries(heroesKV)) {
  if (heroId === 'Version') continue;
  totalHeroes++;
  const heroName = heroData.override_hero || heroId;
  const role = heroData.Role || 'Unknown';
  const heroAbilities = [];
  const heroIssues = [];

  for (let slot = 1; slot <= 5; slot++) {
    const abilityName = heroData[`Ability${slot}`];
    if (!abilityName) {
      heroIssues.push({ level: 'ERROR', ability: `Ability${slot}`, msg: `Hero is missing Ability${slot}` });
      continue;
    }
    totalAbilities++;
    const abilityIssues = [];

    // 1. KV Definition Check
    const kvDef = abilitiesKV[abilityName];
    if (!kvDef) {
      abilityIssues.push({ level: 'ERROR', msg: `Missing definition in npc_abilities_custom.txt` });
    } else {
      if (kvDef.BaseClass !== 'ability_lua') {
        abilityIssues.push({ level: 'WARN', msg: `BaseClass is not ability_lua: ${kvDef.BaseClass}` });
      }
      if (kvDef.ScriptFile !== 'abilities/pve_kits') {
        abilityIssues.push({ level: 'WARN', msg: `ScriptFile is not abilities/pve_kits: ${kvDef.ScriptFile}` });
      }
    }

    // 2. Lua Class Check
    if (!luaClasses.has(abilityName)) {
      abilityIssues.push({ level: 'ERROR', msg: `Missing Lua class '${abilityName}=class({})' in pve_kits.lua` });
    } else {
      // Find class body in pve_kits.lua
      const classStart = pveKitsLua.indexOf(`${abilityName}=class({})`);
      let nextClassIdx = pveKitsLua.length;
      const nextMatch = pveKitsLua.slice(classStart + abilityName.length + 12).search(/^[a-zA-Z0-9_]+=\s*class\(\{\}\)/m);
      if (nextMatch !== -1) {
        nextClassIdx = classStart + abilityName.length + 12 + nextMatch;
      }
      const abilityCode = pveKitsLua.slice(classStart, nextClassIdx);

      // Check if active, toggle, channel or passive
      const hasOnSpellStart = abilityCode.includes(':OnSpellStart');
      const hasOnChannelFinish = abilityCode.includes(':OnChannelFinish');
      const hasOnToggle = abilityCode.includes(':OnToggle');
      const hasIntrinsicModifier = abilityCode.includes(':GetIntrinsicModifierName');

      if (!hasOnSpellStart && !hasOnChannelFinish && !hasOnToggle && !hasIntrinsicModifier) {
        abilityIssues.push({ level: 'WARN', msg: `Ability has neither OnSpellStart, OnToggle, OnChannelFinish nor GetIntrinsicModifierName` });
      }

      // Check intrinsic modifier registration
      if (hasIntrinsicModifier) {
        const modMatch = abilityCode.match(/GetIntrinsicModifierName\(\)\s*return\s*['"]([^'"]+)['"]/);
        if (modMatch) {
          const modName = modMatch[1];
          if (!luaClasses.has(modName)) {
            abilityIssues.push({ level: 'ERROR', msg: `Intrinsic modifier '${modName}' class not defined in Lua` });
          }
          if (!registeredModifiers.has(modName)) {
            abilityIssues.push({ level: 'WARN', msg: `Intrinsic modifier '${modName}' not in LinkLuaModifier list` });
          }
        }
      }

      // Check special values consistency with KV
      if (kvDef && kvDef.AbilitySpecial) {
        const kvSpecials = new Set();
        for (const spec of Object.values(kvDef.AbilitySpecial)) {
          for (const k of Object.keys(spec)) {
            if (k !== 'var_type' && k !== 'LinkedSpecialBonus') kvSpecials.add(k);
          }
        }

        // Find value(self, 'key') or value(a, 'key')
        const valMatches = abilityCode.matchAll(/value\([^,]+,\s*['"]([^'"]+)['"]\)/g);
        for (const vm of valMatches) {
          const valKey = vm[1];
          if (!kvSpecials.has(valKey)) {
            abilityIssues.push({ level: 'WARN', msg: `Lua reads special value '${valKey}' but it is not in KV AbilitySpecial` });
          }
        }
      }

      // Check particle usage
      const createPfxMatches = abilityCode.matchAll(/ParticleManager:CreateParticle\(['"]([^'"]+)['"]/g);
      for (const pm of createPfxMatches) {
        const pfxPath = pm[1];
        if (!pfxPath.endsWith('.vpcf')) {
          abilityIssues.push({ level: 'WARN', msg: `Invalid particle path '${pfxPath}'` });
        }
      }

      // Check for raw un-pcalled stat getters
      if (abilityCode.match(/c:GetIntellect\(\)/) || abilityCode.match(/c:GetAgility\(\)/) || abilityCode.match(/c:GetStrength\(\)/)) {
        abilityIssues.push({ level: 'WARN', msg: `Contains un-pcalled raw stat getter` });
      }
    }

    // 3. Tooltips Check
    const titleKey = `DOTA_Tooltip_Ability_${abilityName}`;
    const descKey = `DOTA_Tooltip_Ability_${abilityName}_Description`;
    const hasEnTitle = englishTokens.has(titleKey);
    const hasEnDesc = englishTokens.has(descKey);
    const hasTrTitle = turkishTokens.has(titleKey);
    const hasTrDesc = turkishTokens.has(descKey);

    if (!hasEnTitle || !hasEnDesc) {
      abilityIssues.push({ level: 'WARN', msg: `Missing English localization for tooltip (${!hasEnTitle ? 'title' : ''} ${!hasEnDesc ? 'desc' : ''})` });
    }
    if (!hasTrTitle || !hasTrDesc) {
      abilityIssues.push({ level: 'WARN', msg: `Missing Turkish localization for tooltip (${!hasTrTitle ? 'title' : ''} ${!hasTrDesc ? 'desc' : ''})` });
    }

    heroAbilities.push({
      slot,
      name: abilityName,
      issues: abilityIssues
    });

    if (abilityIssues.length > 0) {
      heroIssues.push(...abilityIssues.map(i => ({ ...i, ability: abilityName })));
    }
  }

  heroReports.push({
    heroId,
    name: heroName,
    role,
    abilities: heroAbilities,
    issues: heroIssues
  });
}

console.log(`\n======================================================================`);
console.log(`PVE HERO KIT AUDIT REPORT: ${totalHeroes} Heroes / ${totalAbilities} Abilities`);
console.log(`======================================================================\n`);

let totalErrors = 0;
let totalWarnings = 0;

for (const report of heroReports) {
  const errors = report.issues.filter(i => i.level === 'ERROR');
  const warnings = report.issues.filter(i => i.level === 'WARN');
  totalErrors += errors.length;
  totalWarnings += warnings.length;

  const status = errors.length > 0 ? '❌ ERROR' : (warnings.length > 0 ? '⚠️ WARN' : '✅ HEALTHY');
  console.log(`[${status}] ${report.name.padEnd(20)} (${report.role.padEnd(8)}) - ${report.abilities.length} abilities`);

  if (report.issues.length > 0) {
    for (const iss of report.issues) {
      console.log(`    [${iss.level}] ${iss.ability}: ${iss.msg}`);
    }
  }
}

console.log(`\n----------------------------------------------------------------------`);
console.log(`SUMMARY: Total Heroes: ${totalHeroes} | Total Abilities: ${totalAbilities}`);
console.log(`         Errors: ${totalErrors} | Warnings: ${totalWarnings}`);
console.log(`----------------------------------------------------------------------\n`);
