import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
test('Boss resources finish loading before scheduled entities and combat deadline',()=>{
 const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','tests/boss_resource_gate.lua'],{encoding:'utf8'});
 assert.equal(result.status,0,result.stdout+result.stderr);
 assert.match(result.stdout,/PASS Boss resource loading gates/);
});
