// Static/content evidence only; does not certify Dota ability execution.
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from './lib/kv.mjs';
const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-e',`package.path='game/scripts/vscripts/?.lua;'..package.path
local S=require('waves/special_creeps')
for w=1,60 do if w%5~=0 then print(w..':'..table.concat(S.KITS[w] or {},',')) end end`],{encoding:'utf8'});
if(result.status!==0||result.stderr)throw Error(result.stderr||'Kit inventory failed');
const native=new Map(JSON.parse(fs.readFileSync('docs/audit/NATIVE_WAVE_SKILLS_2026-10-01.json','utf8')).records.map(x=>[x.name,x.value]));
const custom=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
const traits=new Set(['invisible','silence','root','reflect']);
const records=result.stdout.trim().split(/\r?\n/).map(line=>{
 const [wave,list]=line.split(':');
 const skills=list?list.split(',').map(id=>{
  if(traits.has(id))return {id,implementation:'synchronized Lua modifier'};
  const definition=native.get(id)||custom[id];
  if(!definition)throw Error(`Wave ${wave} unresolved ability ${id}`);
  const passive=(definition.AbilityBehavior||'').includes('PASSIVE');
  if((definition.AbilityBehavior||'').includes('VECTOR_TARGETING'))throw Error(`Wave ${wave} ability ${id} needs a two-stage vector order unsupported by creep AI`);
  if(definition.BaseClass==='ability_datadriven'&&passive&&!Object.values(definition.Modifiers||{}).some(x=>x.Passive==='1'))throw Error(`No passive modifier for ${id}`);
  const warnings=[];
  if(id==='gnoll_assassin_envenomed_weapon')warnings.push('Installed rank-1 damage_per_second=0; regeneration reduction remains 75%. Do not claim damage-over-time.');
  return {id,implementation:native.has(id)?'native Valve ability':definition.BaseClass,rank:1,behavior:definition.AbilityBehavior,targetTeam:definition.AbilityUnitTargetTeam||'not specified',targetType:definition.AbilityUnitTargetType||'not specified',warnings};
 }):[];
 return {wave:Number(wave),distribution:skills.length?'every authored creep':Number(wave)===37?'Rally quarantined after client crash evidence':'basic opening',skills};
});
if(records.length!==48||records.filter(x=>x.skills.length).length!==43)throw Error('Expected 48 normal profiles, 43 special waves and quarantined wave 37');
if(records.some(x=>x.skills.some(s=>s.id==='hill_troll_rally')))throw Error('Crashing native Rally must remain quarantined');
const json=JSON.stringify({evidence:'Static definitions and production kit inventory; engine execution pending',normalWaves:48,specialWaves:43,basicOpeningWaves:[1,2,3,4],quarantinedSpecialWaves:[37],records},null,2)+'\n';
const file='docs/audit/WAVE_SPECIAL_CONTRACTS_2026-10-01.json';
if(process.argv.includes('--check')){if(fs.readFileSync(file,'utf8')!==json)throw Error('Stale special wave audit');}
else fs.writeFileSync(file,json);
console.log('PASS: 48 normal waves, 43 complete special kit definitions, 4 basic opening waves, wave 37 Rally quarantined; engine execution remains pending.');
