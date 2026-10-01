import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';
test('all native Boss identities preserve preparation, rewards, registration and Boss leaks',()=>{
 const units=parseKV(fs.readFileSync('game/scripts/npc/npc_units_custom.txt','utf8')).DOTAUnits;
 const rows=Object.entries(units).filter(([id])=>id.startsWith('enfos_boss_'));
 const lua='{'+rows.map(([id,u])=>'['+JSON.stringify(id)+']={BountyGoldMin='+Number(u.BountyGoldMin)+',BountyGoldMax='+Number(u.BountyGoldMax)+',BountyXP='+Number(u.BountyXP)+'}').join(',')+'}';
 const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-e',
  'ENFOS_TEST_UNITS='+lua+';dofile("tests/native_boss_pipeline.lua")'],{encoding:'utf8'});
 assert.equal(result.status,0,result.stdout+result.stderr);
 assert.match(result.stdout,/PASS twelve native Boss/);
});
