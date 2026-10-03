// Smoke tests with actual maximum-rank KV values, not a universal fake 100.
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from './lib/kv.mjs';
import {getAbilityValues} from './lib/ability_values.mjs';
import luaparse from 'luaparse';
import {readAbilitySources} from './lib/ability_sources.mjs';
import {isVerifiedNativeAbility} from './lib/native_hero_abilities.mjs';
const abilities=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
const owners={};
for (const source of readAbilitySources(abilities).values()) {
let current;
for(const node of luaparse.parse(source).body){
  if(node.type==='AssignmentStatement' && abilities[node.variables[0]?.name]) current=node.variables[0].name;
  if(node.type==='FunctionDeclaration' && node.identifier?.type==='MemberExpression'){
    const name=node.identifier.base.name;
    if(current && name?.startsWith('modifier_')) owners[name]=current;
  }
}
}
const ownerLua=Object.entries(owners).map(([k,v])=>`["${k}"]="${v}"`).join(',');
const nativeLua=Object.entries(abilities).filter(([id,a])=>isVerifiedNativeAbility(id,a))
  .map(([id,a])=>`["${id}"]="${a.BaseClass}"`).join(',');
const maxRank=Math.max(...Object.values(abilities).map(a=>Number(a.MaxLevel)||1));
for(let rank=1;rank<=maxRank;rank++){
  const rows=Object.entries(abilities).map(([id,a])=>{
    const specials=getAbilityValues(a);
    return `["${id}"]={${Object.entries(specials).map(([k,v])=>{
      const values=String(v).trim().split(/\s+/);
      const value=Number(values[Math.min(rank,Number(a.MaxLevel)||1,values.length)-1]);
      if(!Number.isFinite(value)) throw new Error(`Non-numeric special ${id}.${k}`);
      return `["${k}"]=${value}`;
    }).join(',')}}`;
  });
  const levels=Object.entries(abilities).map(([id,a])=>`["${id}"]=${Math.min(rank,Number(a.MaxLevel)||1)}`).join(',');
  const lionRange=Number(String(abilities.enfos_lion_earth_spike.AbilityCastRange).split(/\s+/)[0]);
  if(!Number.isFinite(lionRange))throw new Error('Invalid Lion engine cast range');
  const script=`ENFOS_NATIVE_ABILITIES={${nativeLua}}\nENFOS_LION_ENGINE_CAST_RANGE=${lionRange}\nENFOS_MAX_RANK_PASS=${rank===maxRank}\nENFOS_REAL_LEVELS={${levels}}\nENFOS_REAL_SPECIALS={${rows.join(',')}}\nENFOS_MODIFIER_OWNERS={${ownerLua}}\ndofile("tests/test_all_200_abilities.lua")`;
  const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
  if(result.status!==0 || result.stderr || !result.stdout?.includes('Ability/modifier smoke checks passed')){
    process.stdout.write(result.stdout||'');process.stderr.write(result.stderr||'');
    process.exitCode=1;break;
  }
  console.log(`PASS Lua hero abilities and owned modifiers at rank ${rank}; native slots require owner engine tests`);
  if(rank===maxRank) process.stdout.write(result.stdout);
}
