import test from 'node:test';
import assert from 'node:assert/strict';
import { parseKV } from '../lib/kv.mjs';
test('nested values, comments and escaped quotes', () => {
  const value = parseKV('// header\n"root" { "text" "a \\"quote\\"" "nested" { "x" "1" } }');
  assert.equal(value.root.nested.x, '1');
  assert.match(value.root.text, /quote/);
});
test('malformed and duplicate content is rejected', () => {
  for (const text of ['"r" {', '"x"', '}', '"r" { "a" "1" "a" "2" }', '"r" { "a" }', '"r" "x" garbage']) {
    assert.throws(() => parseKV(text));
  }
});
