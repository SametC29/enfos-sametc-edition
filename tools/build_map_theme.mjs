import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { createHash } from 'node:crypto';
import { tintMaterial } from './lib/material-tint.mjs';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const config = JSON.parse(await fs.readFile(path.join(root, 'content/map-theme.json'), 'utf8'));
const server = process.env.DOTA2_WORKSHOP_MCP_DIR ?? 'C:\\Users\\samet\\.gemini\\antigravity\\mcp\\dota2_workshop_mcp';
const dota = process.env.DOTA2_PATH ?? 'C:\\Program Files (x86)\\Steam\\steamapps\\common\\dota 2 beta';
if (!server || !dota) throw new Error('Set DOTA2_WORKSHOP_MCP_DIR and DOTA2_PATH; see docs/MAP_THEME.md.');
const { Vpk } = await import(pathToFileURL(path.join(server, 'dist/dota/vpk.js')));
const workshopPath = process.env.ENFOS_REFERENCE_VPK ?? path.resolve(dota, '../../workshop/content/570', config.workshopId, `${config.workshopId}.vpk`);
const reference = await Vpk.open(workshopPath);
const valve = await Vpk.open(path.join(dota, 'game/dota/pak01_dir.vpk'));
const sha = data => createHash('sha256').update(data).digest('hex');
const planned = [];
async function add(source, input, output) {
  const data = await source.read(input);
  planned.push({ output, data, source: input });
}
await add(reference, 'maps/enfos.vpk', 'maps/enfos.vpk');
await add(reference, 'maps/enfos.vpk', 'maps/enfos_sametc.vpk');
for (const name of ['enfos.vmat_c', 'enfos_tga_5c43ce9c.vtex_c']) await add(reference, `materials/overviews/${name}`, `materials/overviews/${name}`);
for (const [output, input] of Object.entries(config.materials)) await add(valve, input, output);
const tints = [];
for (const [output, tint] of Object.entries(config.tints)) {
  const original = await valve.read(output);
  const { output: data, offset } = tintMaterial(original, tint);
  if (!data.subarray(0, offset).equals(original.subarray(0, offset)) || !data.subarray(offset + 12).equals(original.subarray(offset + 12))) throw new Error('Unexpected material mutation');
  planned.push({ output, data, source: output });
  tints.push({ path: output, offset, rgb: tint, originalSha256: sha(original) });
}
// Validate every dependency before changing any installed map.
const manifest = { version: config.version, referenceTitle: config.referenceTitle, workshopId: config.workshopId, theme: config.theme, configSha256: sha(await fs.readFile(path.join(root, 'content/map-theme.json'))), files: planned.map(f => ({ path: f.output, source: f.source, sha256: sha(f.data) })), tints };
for (const file of planned) {
  const target = path.resolve(root, 'game', file.output);
  if (!target.startsWith(path.join(root, 'game') + path.sep)) throw new Error('Invalid output path');
  await fs.mkdir(path.dirname(target), { recursive: true });
  await fs.writeFile(target + '.tmp', file.data);
  await fs.rename(target + '.tmp', target);
}
await fs.writeFile(path.join(root, 'game/map-theme-build.json'), JSON.stringify(manifest, null, 2) + '\n');
console.log(`Built ${config.theme}: ${planned.length} files. Map geometry/navigation VPK is byte-identical to subscribed Enfos survival.`);
