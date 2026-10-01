import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
test('wave curve, unique roster, future reinforcements and bounded special waves',()=>{
 const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','tests/wave_rework.lua'],{encoding:'utf8'});
 assert.equal(result.status,0);
 assert.equal(result.stderr,'');
 assert.match(result.stdout,/wave rework tests passed/);
});
