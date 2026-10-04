import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
test('Boss prioritizes players in creep crowds and attacks in the test arena',()=>{
 const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','tests/boss_target_priority.lua'],{encoding:'utf8'});
 assert.equal(result.status,0,result.stdout+result.stderr);
 assert.equal(result.stderr,'',result.stderr);
 assert.match(result.stdout,/PASS Boss hero priority/);
});
test('Boss combat focus changes preserve native toggle resource and combat gates',()=>{
 const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','tests/native_boss_toggles.lua'],{encoding:'utf8'});
 assert.equal(result.status,0,result.stdout+result.stderr);
 assert.equal(result.stderr,'',result.stderr);
 assert.match(result.stdout,/PASS: native Boss toggle/);
});
