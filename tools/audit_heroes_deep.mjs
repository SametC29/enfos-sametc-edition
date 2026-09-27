import fs from 'node:fs';
import luaparse from 'luaparse';
import {parseKV} from './lib/kv.mjs';

// Structural inventory is evidence of coverage, not a certificate of engine behavior.
const source=fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8');
const abilities=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
const heroes=parseKV(fs.readFileSync('game/scripts/npc/npc_heroes_custom.txt','utf8')).DOTAHeroes;
const functions=new Map(), ownerSource=new Map();
let owner;
for(const n of luaparse.parse(source,{ranges:true}).body){
  if(n.type==='AssignmentStatement' && abilities[n.variables[0]?.name]) owner=n.variables[0].name;
  if(n.type!=='FunctionDeclaration' || n.identifier?.type!=='MemberExpression') continue;
  const cls=n.identifier.base.name, method=n.identifier.identifier.name;
  if(!functions.has(cls)) functions.set(cls,new Set());
  functions.get(cls).add(method);
  if(owner) ownerSource.set(owner,(ownerSource.get(owner)||'')+'\n'+source.slice(...n.range));
}
const rows=[];
for(const [id,hero] of Object.entries(heroes).filter(([,h])=>h.Role)){
  const kit=[];
  for(let slot=1;slot<=5;slot++){
    const ability=hero['Ability'+slot],kv=abilities[ability],methods=functions.get(ability);
    if(!kv || !methods) throw new Error(`Missing implementation: ${id}/${ability}`);
    const behavior=kv.AbilityBehavior||'';
    if(behavior.includes('PASSIVE')&&!methods.has('GetIntrinsicModifierName')) throw new Error(`Passive has no intrinsic: ${ability}`);
    if(behavior.includes('TOGGLE')&&!methods.has('OnToggle')) throw new Error(`Toggle has no handler: ${ability}`);
    if(!behavior.includes('PASSIVE')&&!behavior.includes('TOGGLE')&&!methods.has('OnSpellStart')) throw new Error(`Active has no cast handler: ${ability}`);
    const text=ownerSource.get(ability)||'';
    const specials=Object.assign({},...Object.values(kv.AbilitySpecial||{}));delete specials.var_type;
    const read=new Set([...text.matchAll(/(?:value\([^\n]*?,\s*|GetSpecialValueFor\(\s*)['"](\w+)['"]/g)].map(m=>m[1]));
    kit.push({slot,id:ability,maxLevel:Number(kv.MaxLevel)||1,behavior,callbacks:[...methods].sort(),
      specials,unreferencedSpecials:Object.keys(specials).filter(k=>!read.has(k)),
      hasSound:/EmitSound|StopSound/.test(text),hasParticle:/\.vpcf/.test(text)});
  }
  rows.push({id,role:hero.Role,abilities:kit});
}
if(rows.length!==40 || rows.flatMap(h=>h.abilities).length!==200) throw new Error('Expected 40 heroes and 200 abilities');
if(/GetAverageTrueAttackDamage\s*\(\s*\)/.test(source)) throw new Error('Unsafe zero-argument attack damage query');
const report={scope:'Structural inventory and follow-up candidates; see rank-matrix tests for mocked runtime coverage. Unreferenced fields may be legacy aliases or native metadata, not necessarily bugs.',heroes:rows};
const json=JSON.stringify(report,null,2)+'\n';
const file='docs/audit/HERO_ABILITY_CONTRACTS.json';
if(process.argv.includes('--write'))fs.writeFileSync(file,json);
else if(fs.readFileSync(file,'utf8')!==json)throw new Error('Stale hero inventory: node tools/audit_heroes_deep.mjs --write');
console.log(`PASS 40 heroes / 200 ability entrypoints; ${rows.flatMap(h=>h.abilities).filter(a=>a.unreferencedSpecials.length).length} abilities retain unreferenced-field review candidates (not certified bugs).`);
