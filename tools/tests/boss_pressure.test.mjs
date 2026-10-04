import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
test('Boss-only pressure respects difficulty, solo scaling and match snapshots',()=>{
 const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','tests/boss_pressure.lua'],{encoding:'utf8'});
 assert.equal(result.status,0,result.stdout+result.stderr);
 assert.equal(result.stderr,'',result.stderr);
 assert.match(result.stdout,/PASS Boss pressure snapshot/);
});
