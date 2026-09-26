// Strict parser for the quoted KeyValues subset authored by this project.
export function parseKV(text, source = 'KeyValues') {
  const tokens = [];
  const re = /\s+|\/\/[^\r\n]*|"((?:\\.|[^"\\])*)"|([{}])/gy;
  let offset = text.charCodeAt(0) === 0xfeff ? 1 : 0;
  while (offset < text.length) {
    re.lastIndex = offset;
    const m = re.exec(text);
    if (!m) throw new Error(`${source}: invalid token at ${offset}`);
    offset = re.lastIndex;
    if (m[1] !== undefined) tokens.push({ value: m[1], quoted: true });
    else if (m[2]) tokens.push({ value: m[2], quoted: false });
  }
  let i = 0;
  function block(nested) {
    const result = Object.create(null);
    while (i < tokens.length) {
      const key = tokens[i++];
      if (!key.quoted && key.value === '}') {
        if (!nested) throw new Error(`${source}: unexpected closing brace`);
        return result;
      }
      if (!key.quoted) throw new Error(`${source}: expected key`);
      if (Object.hasOwn(result, key.value)) throw new Error(`${source}: duplicate key ${key.value}`);
      const value = tokens[i++];
      if (!value) throw new Error(`${source}: missing value for ${key.value}`);
      if (value.quoted) result[key.value] = value.value;
      else if (value.value === '{') result[key.value] = block(true);
      else throw new Error(`${source}: missing value for ${key.value}`);
    }
    if (nested) throw new Error(`${source}: unclosed block`);
    return result;
  }
  return block(false);
}
