import fs from 'node:fs';
import path from 'node:path';

// Static source discovery follows production KV and literal module imports.
// It inventories files; it does not certify runtime registration or engine behavior.
export function readAbilitySources(abilities, root = '.') {
  const sources = new Map();
  function load(script) {
    if (!/^[a-zA-Z0-9_/-]+$/.test(script) || script.split('/').includes('..')) throw Error(`Unsafe Lua module path: ${script}`);
    const file = `game/scripts/vscripts/${script}.lua`;
    if (sources.has(file)) return;
    const source = fs.readFileSync(path.join(root, file), 'utf8');
    sources.set(file, source);
    for (const match of source.matchAll(/\brequire\s*\(?\s*['"]([a-zA-Z0-9_/-]+)['"]/g)) load(match[1]);
  }
  load('abilities/pve_kits'); // Existing bootstrap remains supported during incremental extraction.
  for (const ability of Object.values(abilities)) if (ability.BaseClass === 'ability_lua') load(ability.ScriptFile);
  return sources;
}
