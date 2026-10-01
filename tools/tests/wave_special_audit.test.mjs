import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
test('all special-wave definitions resolve and the complete evidence inventory is current',()=>{
 const result=spawnSync(process.execPath,['tools/wave_special_audit.mjs','--check'],{encoding:'utf8'});
 assert.equal(result.status,0,result.stderr);assert.equal(result.stderr,'');
 assert.match(result.stdout,/44 complete special kit definitions/);
});
