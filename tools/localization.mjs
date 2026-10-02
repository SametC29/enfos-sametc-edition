import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseKV } from './lib/kv.mjs';
import { getAbilityValues } from './lib/ability_values.mjs';
import { readAbilitySources } from './lib/ability_sources.mjs';

export const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

// Turkish is the source of truth.  Other languages auto-mirror Turkish
// tokens until real translations are provided.
export const SOURCE_LANG = 'turkish';
export const languages = ['english', 'turkish', 'russian', 'schinese'];
const langDisplayName = { english: 'English', turkish: 'Turkish', russian: 'Russian', schinese: 'SChinese' };

export function generateLocalization(check = false) {
  const abilities = parseKV(fs.readFileSync(path.join(root, 'game/scripts/npc/npc_abilities_custom.txt'), 'utf8')).DOTAAbilities;
  const items = parseKV(fs.readFileSync(path.join(root, 'game/scripts/npc/npc_items_custom.txt'), 'utf8')).DOTAItems;

  // Load Turkish source first
  const sourceData = JSON.parse(fs.readFileSync(path.join(root, `localization/${SOURCE_LANG}.json`), 'utf8'));
  const sourceKeys = Object.keys(sourceData.Tokens).sort();

  const escape = value => value.replaceAll('"', '\\"');

  const resolveSpecials = (key, rawValue, abilityIdOverride = null) => {
    if (!rawValue || typeof rawValue !== 'string') return rawValue ?? '';
    const id = abilityIdOverride ?? key.match(/^DOTA_Tooltip_[Aa]bility_(.+)_(?:Description|SummaryDescription|DesignDescription)$/)?.[1];
    const definition = abilities[id] ?? items[id];
    if (!definition) return rawValue;
    const specials = getAbilityValues(definition);
    return rawValue.replace(/\{\{(\w+)(?:\|(\w+))?\}\}/g, (_, name, format) => {
      if (specials[name] === undefined) throw new Error(`${key}: unknown special ${name}`);
      const values = specials[name].split(/\s+/);
      if (format === 'abs') return values.map(v => Math.abs(Number(v))).join(' / ');
      if (format === 'percent') return values.map(v => `${Math.abs(Number(v))}%`).join(' / ');
      if (format === 'plus') return values.join(' / +');
      if (format) throw new Error(`Unknown format: ${format}`);
      return values.join(' / ');
    });
  };

  for (const lang of languages) {
    let data;
    if (lang === SOURCE_LANG) {
      data = sourceData;
    } else {
      // Mirror: use existing lang file but fill missing tokens from Turkish
      const langFile = path.join(root, `localization/${lang}.json`);
      data = JSON.parse(fs.readFileSync(langFile, 'utf8'));
      for (const key of sourceKeys) {
        if (!(key in data.Tokens)) {
          data.Tokens[key] = sourceData.Tokens[key]; // Turkish placeholder
        }
      }
    }

    // Native tooltips request lowercase 'ability'; cover names and descriptions
    // as well as special labels. Modern compact tooltips also need SummaryDescription.
    for (const id of [...Object.keys(abilities), ...Object.keys(items)]) {
      const prefix = `DOTA_Tooltip_Ability_${id}`;
      if (!data.Tokens[`${prefix}_Description`]) {
        data.Tokens[`${prefix}_Description`] = data.Tokens[prefix] || '';
      }
      if (!data.Tokens[`${prefix}_SummaryDescription`]) {
        data.Tokens[`${prefix}_SummaryDescription`] = data.Tokens[`${prefix}_Description`];
      }
    }
    for (const [key, value] of Object.entries(data.Tokens)) {
      if (key.startsWith('DOTA_Tooltip_Ability_')) data.Tokens[key.replace('DOTA_Tooltip_Ability_', 'DOTA_Tooltip_ability_')] = value;
    }

    // Alias modifier tooltips suffixed with _passive or _active
    for (const [key, value] of Object.entries(data.Tokens)) {
      if (key.startsWith('DOTA_Tooltip_modifier_')) {
        if (key.endsWith('_passive')) {
          const direct = key.replace(/_passive$/, '');
          if (!data.Tokens[direct]) data.Tokens[direct] = value;
        } else if (key.endsWith('_passive_Description')) {
          const direct = key.replace(/_passive_Description$/, '_Description');
          if (!data.Tokens[direct]) data.Tokens[direct] = value;
        } else if (key.endsWith('_active')) {
          const direct = key.replace(/_active$/, '');
          if (!data.Tokens[direct]) data.Tokens[direct] = value;
        } else if (key.endsWith('_active_Description')) {
          const direct = key.replace(/_active_Description$/, '_Description');
          if (!data.Tokens[direct]) data.Tokens[direct] = value;
        }
      }
    }

    // Follow actual KV/import ownership, including isolated hero modules.
    const pveKitsContent = [...readAbilitySources(abilities, root).values()].join('\n');
    const abRegex = /function\s+([a-zA-Z0-9_]+):GetIntrinsicModifierName\(\)\s*return\s*['"]([^'"]+)['"]/g;
    let abM;
    while ((abM = abRegex.exec(pveKitsContent)) !== null) {
      const abName = abM[1];
      const modName = abM[2];
      const modKey = `DOTA_Tooltip_${modName}`;
      const modDescKey = `${modKey}_Description`;
      if (!data.Tokens[modKey]) {
        const abTitle = data.Tokens[`DOTA_Tooltip_Ability_${abName}`] ?? data.Tokens[`DOTA_Tooltip_ability_${abName}`];
        if (abTitle) data.Tokens[modKey] = abTitle;
      }
      if (!data.Tokens[modDescKey]) {
        const rawDesc = data.Tokens[`DOTA_Tooltip_Ability_${abName}_Description`] ?? data.Tokens[`DOTA_Tooltip_ability_${abName}_Description`];
        if (rawDesc) {
          data.Tokens[modDescKey] = resolveSpecials(`DOTA_Tooltip_Ability_${abName}_Description`, rawDesc, abName);
        }
      }
    }
    const keys = Object.keys(data.Tokens).sort();
    const lines = keys.map(key => {
      const modifierOwners={modifier_bulwark_unbreakable:'bulwark_unbreakable',modifier_bulwark_iron_guard:'bulwark_iron_guard',modifier_enfos_pve_warcry:'bulwark_challenge',modifier_bulwark_fortress:'bulwark_fortress',modifier_enfos_dk_dragon_blood:'enfos_dk_dragon_blood',modifier_enfos_dk_dragon_blood_passive:'enfos_dk_dragon_blood'};
      const modifier=key.match(/^DOTA_Tooltip_(modifier_\w+)_Description$/)?.[1];
      const value = resolveSpecials(key, data.Tokens[key],modifierOwners[modifier]||null);
      if (!value || value.includes('{{')) throw new Error(`${lang}/${key}: empty or unresolved text`);
      return `\t\t"${key}" "${escape(value)}"`;
    });
    const displayLang = langDisplayName[lang] ?? lang;
    const output = `\uFEFF// Generated by tools/localization.mjs; edit localization/${SOURCE_LANG}.json.\n"lang"\n{\n\t"Language" "${displayLang}"\n\t"Tokens"\n\t{\n${lines.join('\n')}\n\t}\n}\n`;
    for (const dir of ['game/resource', 'game/panorama/localization', 'content/panorama/localization']) {
      const target = path.join(root, dir, `addon_${lang}.txt`);
      if (check) {
        if (fs.readFileSync(target, 'utf8') !== output) throw new Error(`${target}: generated localization is stale`);
      } else fs.writeFileSync(target, output);
    }
  }
}
if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  generateLocalization(process.argv.includes('--check'));
  console.log(`Localization: Turkish source → all ${languages.length} languages synchronized.`);
}
