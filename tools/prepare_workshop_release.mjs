// Assemble the existing game files without recompiling maps or changing gameplay.
// SteamCMD owns publishedfileid in workshop.vdf; never reset it on subsequent runs.
import fs from 'node:fs';
import path from 'node:path';
import { createHash } from 'node:crypto';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const release = path.join(root, 'release', 'workshop');
const content = path.join(release, 'content');
const vdf = path.join(release, 'workshop.vdf');
const title = 'Enfos Team Survival - SametC Edition V1.0.0';
const oldVdf = fs.existsSync(vdf) ? fs.readFileSync(vdf, 'utf8') : '';
const id = oldVdf.match(/"publishedfileid"\s+"(\d+)"/)?.[1] ?? '0';
if (id === '3591082091') throw new Error('Reference Workshop ID is not our publication ID');
const integrity = spawnSync(process.execPath, ['tools/check_map.mjs'], { cwd: root, encoding: 'utf8' });
if (integrity.status !== 0) throw new Error(integrity.stderr || integrity.stdout);
fs.mkdirSync(content, { recursive: true });

const files = [];
const allowed = new Set(['.lua', '.txt', '.vpk', '.vxml_c', '.vcss_c', '.vjs_c', '.vmat_c', '.vtex_c', '.vmdl_c', '.vpcf_c', '.vsnd_c', '.vsndevts_c', '.vrman_c', '.vdata_c', '.vmap_c']);
function walk(dir) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (entry.isSymbolicLink()) throw new Error('Unexpected link in game payload: ' + entry.name);
    const absolute = path.join(dir, entry.name);
    if (entry.isDirectory()) { walk(absolute); continue; }
    const relative = path.relative(path.join(root, 'game'), absolute).replaceAll('\\', '/');
    if (relative !== 'addoninfo.txt' && !/^(maps|materials|panorama|resource|scripts)\//.test(relative)) continue;
    if (!allowed.has(path.extname(relative))) continue;
    if (!/^[a-z0-9_./-]+$/.test(relative)) throw new Error('Unexpected archive path: ' + relative);
    const data = fs.readFileSync(absolute);
    files.push({ path: relative, data, sha256: createHash('sha256').update(data).digest('hex') });
  }
}
walk(path.join(root, 'game'));
files.sort((a, b) => a.path.localeCompare(b.path, 'en'));
if (!files.some(f => f.path === 'scripts/vscripts/addon_game_mode.lua')) throw new Error('Missing entrypoint');
// Do not ship stale compiled Panorama or omit a source without a compiled counterpart.
for (const folder of ['layout', 'styles', 'scripts']) {
  const sourceRoot = path.join(root, 'game/panorama', folder, 'custom_game');
  if (!fs.existsSync(sourceRoot)) continue;
  for (const name of fs.readdirSync(sourceRoot)) {
    const ext = path.extname(name);
    const suffix = { '.xml': '.vxml_c', '.css': '.vcss_c', '.js': '.vjs_c' }[ext];
    if (!suffix) continue;
    const compiled = path.join(sourceRoot, path.basename(name, ext) + suffix);
    if (!fs.existsSync(compiled)) throw new Error('Missing compiled Panorama: ' + compiled);
    if (fs.statSync(compiled).mtimeMs < fs.statSync(path.join(sourceRoot, name)).mtimeMs) throw new Error('Stale compiled Panorama: ' + compiled);
  }
}

const crcTable = Array.from({ length: 256 }, (_, n) => {
  let c = n;
  for (let i = 0; i < 8; i++) c = (c & 1) ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
  return c >>> 0;
});
function crc32(data) {
  let c = 0xffffffff;
  for (const byte of data) c = crcTable[(c ^ byte) & 255] ^ (c >>> 8);
  return (c ^ 0xffffffff) >>> 0;
}
const tree = new Map();
let offset = 0;
for (const file of files) {
  const ext = path.posix.extname(file.path).slice(1) || ' ';
  const dir = path.posix.dirname(file.path) === '.' ? ' ' : path.posix.dirname(file.path);
  if (!tree.has(ext)) tree.set(ext, new Map());
  if (!tree.get(ext).has(dir)) tree.get(ext).set(dir, []);
  tree.get(ext).get(dir).push({ ...file, offset });
  offset += file.data.length;
}
if (offset > 0xffffffff) throw new Error('VPK exceeds single archive capacity');
const chunks = [];
const str = s => chunks.push(Buffer.from(s + '\0', 'utf8'));
for (const [ext, directories] of tree) {
  str(ext);
  for (const [dir, entries] of directories) {
    str(dir);
    for (const file of entries) {
      str(path.posix.basename(file.path, '.' + ext));
      const entry = Buffer.alloc(18);
      entry.writeUInt32LE(crc32(file.data), 0);
      entry.writeUInt16LE(0, 4); // No preload bytes.
      entry.writeUInt16LE(0x7fff, 6); // Data is in this archive.
      entry.writeUInt32LE(file.offset, 8);
      entry.writeUInt32LE(file.data.length, 12);
      entry.writeUInt16LE(0xffff, 16);
      chunks.push(entry);
    }
    str('');
  }
  str('');
}
str('');
const treeBuffer = Buffer.concat(chunks);
const header = Buffer.alloc(12);
header.writeUInt32LE(0x55aa1234, 0);
header.writeUInt32LE(1, 4);
header.writeUInt32LE(treeBuffer.length, 8);
const archiveName = (id === '0' ? 'enfos_sametc' : id) + '.vpk';
const archive = Buffer.concat([header, treeBuffer, ...files.map(f => f.data)]);
// Avoid accidentally uploading both the provisional archive and the final ID archive.
const previous = path.join(content, 'enfos_sametc.vpk');
if (id !== '0' && fs.existsSync(previous)) fs.renameSync(previous, path.join(release, 'provisional.vpk'));
fs.writeFileSync(path.join(content, archiveName), archive);
const quote = s => '"' + s.replaceAll('\\', '/').replaceAll('"', "'") + '"';
const now = new Date();
fs.writeFileSync(path.join(content, 'publish_data.txt'), '"publish_data"\n{\n' +
  `\t"title" ${quote(title)}\n\t"source_folder" "enfos_sametc"\n` +
  `\t"publish_time" "${Math.floor(now.getTime() / 1000)}"\n\t"publish_time_readable" "${now.toISOString()}"\n}\n`);
fs.writeFileSync(path.join(release, 'manifest.json'), JSON.stringify({ title, preparedAt: now.toISOString(), publishedfileid: id,
  archive: archiveName, archiveSha256: createHash('sha256').update(archive).digest('hex'),
  files: files.map(({ path, data, sha256 }) => ({ path, size: data.length, sha256 })) }, null, 2) + '\n');
if (!oldVdf) {
  const description = 'Protect your Life Core against enemy waves in this Dota 2 custom survival game. Choose your hero, build items and support your team with Spellbringer abilities. First public test version; gameplay and balance testing are ongoing. / TR: Takiminin Yasam Cekirdegini dusman dalgalarina karsi koru. Kahramanini ve esyalarini gelistir, Spellbringer buyulerini kullan. Ilk herkese acik test surumu; gelistirme ve denge testleri suruyor.';
  fs.writeFileSync(vdf, '"workshopitem"\n{\n' + Object.entries({ appid: '570', publishedfileid: '0',
    contentfolder: content, previewfile: path.join(release, 'preview.png'), visibility: '2',
    title, description, changenote: 'V1.0.0 - Initial public test release.'
  }).map(([key, value]) => `\t"${key}" ${quote(value)}`).join('\n') + '\n}\n');
}
console.log(JSON.stringify({ files: files.length, bytes: archive.length, archive: path.join(content, archiveName), id, visibility: 'VDF preserved; initial preparation is private until package and tags are verified' }));
