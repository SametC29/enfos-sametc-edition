import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
test('talent slots and active talent-point/profile hooks are disabled; match levels remain',()=>{
 const kv=spawnSync(process.execPath,['tools/check_talent_tree_removed.mjs'],{encoding:'utf8'});
 assert.equal(kv.status,0,kv.stdout+kv.stderr);
 assert.match(kv.stdout,/PASS talent tree disabled for 40 heroes/);
 for(const file of ['addon_game_mode.lua','enfos_sametc.lua','setup/enfos_setup_manager.lua'])
  assert.doesNotMatch(fs.readFileSync('game/scripts/vscripts/'+file,'utf8'),/require\(["'](?:evolution|progression)\//);
 for(const prefix of ['game','content'])
  assert.doesNotMatch(fs.readFileSync(prefix+'/panorama/layout/custom_game/custom_ui_manifest.xml','utf8'),/evolution\.xml|progression\.xml/);
 const match=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','tests/match_levels.lua'],{encoding:'utf8'});
 assert.equal(match.status,0,match.stdout+match.stderr);
 assert.match(match.stdout,/Match hero level progression tests passed/);
});
