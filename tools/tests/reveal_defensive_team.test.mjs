import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';

test('defensive Reveal validates its source and native aura, arena, expiry and failed casts', () => {
  const result=spawnSync(process.execPath,
    ['node_modules/fengari-node-cli/src/lua-cli.js','tests/reveal_defensive_team.lua'],{encoding:'utf8'});
  assert.equal(result.status,0,result.stdout+result.stderr);
  assert.match(result.stdout,/PASS defensive Reveal/);
});
