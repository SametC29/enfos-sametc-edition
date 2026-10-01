import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
test('all 60 curve entries and 48 unique normal-wave models with +5 boundary handling',()=>{
 const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','tests/wave_curve_roster.lua'],{encoding:'utf8'});
 assert.equal(result.status,0);
 assert.equal(result.stderr,'');
 assert.match(result.stdout,/wave curve and roster tests passed/);
});
