// Compiled maps are ignored by Git. Detect an accidental placeholder rebuild.
import fs from 'node:fs';
import path from 'node:path';
import { createHash } from 'node:crypto';
import { fileURLToPath } from 'node:url';
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const manifest = JSON.parse(fs.readFileSync(path.join(root, 'game/map-theme-build.json'), 'utf8'));
for (const file of manifest.files) {
  const target = path.resolve(root, 'game', file.path);
  if (!target.startsWith(path.join(root, 'game') + path.sep)) throw new Error('Invalid manifest path');
  if (!fs.existsSync(target)) throw new Error('Missing local map dependency: ' + file.path);
  const actual = createHash('sha256').update(fs.readFileSync(target)).digest('hex');
  if (actual !== file.sha256) throw new Error(file.path + ': differs from approved map/theme; do not compile the old placeholder VMAP');
}
console.log('Map/theme integrity: all ' + manifest.files.length + ' recorded files match.');
