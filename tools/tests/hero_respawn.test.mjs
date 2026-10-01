import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
test('player death timer rises from 30 to 50 seconds and preserves native revival',()=>{
 const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','tests/hero_respawn.lua'],{encoding:'utf8'});
 assert.equal(result.status,0,result.stdout+result.stderr);
 assert.equal(result.stderr,'');
 assert.match(result.stdout,/PASS hero respawn curve/);
 assert.match(fs.readFileSync('game/scripts/vscripts/enfos_sametc.lua','utf8'),/require\("heroes\/respawn"\):Init\(\)/);
});
