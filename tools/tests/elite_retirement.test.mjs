import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';
test('Elite scheduling, NPCs, runtime framework and Boon are retired',()=>{
 const units=parseKV(fs.readFileSync('game/scripts/npc/npc_units_custom.txt','utf8')).DOTAUnits;
 assert.deepEqual(Object.keys(units).filter(x=>x.startsWith('enfos_elite_')),[]);
 assert(!fs.existsSync('game/scripts/vscripts/bosses/elite_framework.lua'));
 for(const path of ['waves/wave_manager.lua','waves/wave_definitions.lua','boons/boon_manager.lua'])
  assert.doesNotMatch(fs.readFileSync('game/scripts/vscripts/'+path,'utf8'),/enfos_elite_|EliteFramework|IsEliteWave|is_elite|elite_hunters/);
 const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','tests/elite_retirement.lua'],{encoding:'utf8'});
 assert.equal(result.status,0,result.stdout+result.stderr);
 assert.match(result.stdout,/PASS all 60 waves/);
});
