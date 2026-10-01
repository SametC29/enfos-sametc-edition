import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
test('Spellbringer +5 profiles and difficulty/solo stats across all 60 waves, resource failure refund and accepted effect event',()=>{
 const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','tests/spellbringer_future.lua'],{encoding:'utf8'});
 assert.equal(result.status,0);assert.equal(result.stderr,'');
 assert.match(result.stdout,/spellbringer future tests passed/);
});
