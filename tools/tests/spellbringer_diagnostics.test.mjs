import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
test('Spellbringer diagnostics separate missing orders, displacement and immobilization without altering orders',()=>{
    const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','tests/spellbringer_diagnostics.lua'],{encoding:'utf8'});
    assert.equal(r.status,0,r.stdout+r.stderr);
    assert.match(r.stdout,/PASS Spellbringer read-only movement diagnostics/);
});
