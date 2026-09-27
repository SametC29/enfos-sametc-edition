// Smoke tests with actual maximum-rank KV values, not a universal fake 100.
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from './lib/kv.mjs';
const abilities=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
const rows=Object.entries(abilities).map(([id,a])=>{
  const specials=Object.assign({},...Object.values(a.AbilitySpecial||{}));
  delete specials.var_type;
  return `["${id}"]={${Object.entries(specials).map(([k,v])=>`["${k}"]=${Number(String(v).trim().split(/\s+/).at(-1))||0}`).join(',')}}`;
});
const script='ENFOS_REAL_SPECIALS={'+rows.join(',')+'}\ndofile("tests/test_all_200_abilities.lua")';
const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
process.stdout.write(result.stdout||'');process.stderr.write(result.stderr||'');
process.exitCode=result.status|| (result.stderr?1:0);
