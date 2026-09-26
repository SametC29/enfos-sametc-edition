// Patch only a named float vector in a Valve NTRO material DATA block.
// Unlike re-encoding textures, this preserves alpha, UVs, wind and shader flags.
export function tintMaterial(input, tint) {
  if (input.readUInt16LE(4) !== 12) throw new Error('Unsupported resource header');
  const count = input.readUInt32LE(12);
  const table = 8 + input.readUInt32LE(8);
  let data;
  let ntro = false;
  for (let i = 0; i < count; i++) {
    const entry = table + i * 12;
    if (entry + 12 > input.length) throw new Error('Invalid resource block table');
    const type = input.toString('ascii', entry, entry + 4);
    if (type === 'NTRO') ntro = true;
    if (type === 'DATA') {
      const start = entry + 4 + input.readUInt32LE(entry + 4);
      data = { start, end: start + input.readUInt32LE(entry + 8) };
    }
  }
  if (!ntro || !data || data.end > input.length) throw new Error('Expected an NTRO material; audit Dota patch compatibility');
  const candidates = [];
  for (let p = data.start; p + 20 <= data.end; p += 4) {
    const name = p + input.readInt32LE(p);
    if (name >= data.start && name + 13 <= data.end && input.toString('ascii', name, name + 13) === 'g_vColorTint\0') candidates.push(p + 4);
  }
  if (candidates.length !== 1) throw new Error(`Expected one color tint vector, found ${candidates.length}`);
  if (tint.length !== 3 || tint.some(v => !Number.isFinite(v) || v < 0 || v > 4)) throw new Error('Invalid tint');
  const output = Buffer.from(input);
  const offset = candidates[0];
  tint.forEach((v, i) => output.writeFloatLE(v, offset + i * 4));
  return { output, offset };
}
