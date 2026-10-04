// Independent archive reader supplied by the installed Dota MCP; no engine launch.
import fs from 'node:fs';
import path from 'node:path';
import { createHash } from 'node:crypto';
import { pathToFileURL, fileURLToPath } from 'node:url';
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const reader = process.env.ENFOS_VPK_READER || 'C:/Users/samet/.gemini/antigravity/mcp/dota2_workshop_mcp/dist/dota/vpk.js';
const { Vpk } = await import(pathToFileURL(reader));
const release = path.join(root, 'release/workshop');
const manifest = JSON.parse(fs.readFileSync(path.join(release, 'manifest.json')));
const hash = data => createHash('sha256').update(data).digest('hex');
const archivePath = path.join(release, 'content', manifest.archive);
if (hash(fs.readFileSync(archivePath)) !== manifest.archiveSha256) throw new Error('Archive changed after preparation');
const archive = await Vpk.open(archivePath);
if (archive.entries.size !== manifest.files.length) throw new Error('Entry count mismatch');
for (const file of manifest.files) {
  if (file.path.includes('..') || path.isAbsolute(file.path)) throw new Error('Invalid payload path');
  const bytes = await archive.read(file.path);
  if (bytes.length !== file.size || hash(bytes) !== file.sha256) throw new Error('Archive data mismatch: ' + file.path);
  let source = fs.readFileSync(path.join(root, 'game', file.path));
  // The release builder strips the Tools-only arena from the addon manifest.
  // Compare that production view while checking every other source byte exactly.
  if (file.path === 'addoninfo.txt') {
    source = Buffer.from(source.toString('utf8').replace(/("maps"\s+")[^"]*"/,'$1enfos"').replace(/\s*"enfos_test"\s*\{[^}]*\}/,''));
  }
  if (hash(source) !== file.sha256) throw new Error('Game changed; rebuild package: ' + file.path);
}
const map = JSON.parse(fs.readFileSync(path.join(root, 'game/map-theme-build.json')));
for (const file of map.files) if (hash(await archive.read(file.path)) !== file.sha256) throw new Error('Map integrity failure: ' + file.path);
const expected = [manifest.archive, 'publish_data.txt'].sort();
const actual = fs.readdirSync(path.join(release, 'content')).sort();
if (JSON.stringify(actual) !== JSON.stringify(expected)) throw new Error('Unexpected files in upload directory');
const preview = fs.readFileSync(path.join(release, 'preview.png'));
if (preview.length >= 1024 * 1024 || preview.subarray(0, 8).toString('hex') !== '89504e470d0a1a0a') throw new Error('Invalid PNG preview');
console.log(`Verified ${manifest.files.length} archived files, ${map.files.length} protected map files and PNG preview. Engine gameplay remains untested.`);
