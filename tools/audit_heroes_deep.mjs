import fs from 'node:fs';
import luaparse from 'luaparse';
import {parseKV} from './lib/kv.mjs';
import {getAbilityValues} from './lib/ability_values.mjs';
import {readAbilitySources} from './lib/ability_sources.mjs';
import {isVerifiedNativeAbility} from './lib/native_hero_abilities.mjs';

// Structural inventory is evidence of coverage, not a certificate of engine behavior.
const abilities=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
const sources=readAbilitySources(abilities);
const source=[...sources.values()].join('\n');
const heroes=parseKV(fs.readFileSync('game/scripts/npc/npc_heroes_custom.txt','utf8')).DOTAHeroes;
const functions=new Map(), ownerSource=new Map(), classSource=new Map(), helperSource=new Map();
for (const source of sources.values()) {
let owner;
for(const n of luaparse.parse(source,{ranges:true}).body){
  if(n.type==='AssignmentStatement' && abilities[n.variables[0]?.name]) owner=n.variables[0].name;
  if(n.type==='LocalFunctionDeclaration' || (n.type==='FunctionDeclaration' && n.isLocal && n.identifier?.type==='Identifier')){
    const name=n.identifier?.name;
    if(name)helperSource.set(name,source.slice(...n.range));
    continue;
  }
  if(n.type!=='FunctionDeclaration' || n.identifier?.type!=='MemberExpression') continue;
  const cls=n.identifier.base.name, method=n.identifier.identifier.name, body=source.slice(...n.range);
  if(!functions.has(cls)) functions.set(cls,new Set());
  functions.get(cls).add(method);
  classSource.set(cls,(classSource.get(cls)||'')+'\n'+body);
  if(owner) ownerSource.set(owner,(ownerSource.get(owner)||'')+'\n'+body);
}
}
const rows=[];
for(const [id,hero] of Object.entries(heroes).filter(([,h])=>h.Role)){
  const kit=[];
  for(let slot=1;slot<=5;slot++){
    const ability=hero['Ability'+slot],kv=abilities[ability],native=isVerifiedNativeAbility(ability,kv);
    const methods=native ? new Set() : functions.get(ability);
    if(!kv || !methods) throw new Error(`Missing implementation: ${id}/${ability}`);
    const behavior=kv.AbilityBehavior||'';
    if(!native && behavior.includes('PASSIVE')&&!methods.has('GetIntrinsicModifierName')) throw new Error(`Passive has no intrinsic: ${ability}`);
    if(!native && behavior.includes('TOGGLE')&&!methods.has('OnToggle')) throw new Error(`Toggle has no handler: ${ability}`);
    if(!native && !behavior.includes('PASSIVE')&&!behavior.includes('TOGGLE')&&!methods.has('OnSpellStart')) throw new Error(`Active has no cast handler: ${ability}`);
    const ownText=ownerSource.get(ability)||'';
    // Value lookups often live in modifiers or shared local helpers rather
    // than the ability class. Follow direct modifier-name and helper calls so
    // valid data is not incorrectly reported as unused.
    const relatedModifiers=new Set([...ownText.matchAll(/['"](modifier_[A-Za-z0-9_]+)['"]/g)].map(m=>m[1]));
    const relatedHelpers=new Set([...ownText.matchAll(/\b([A-Za-z_]\w*)\s*\(/g)].map(m=>m[1]).filter(name=>helperSource.has(name)));
    for(const [name,body] of helperSource) if(body.includes(`'${ability}'`)||body.includes(`\"${ability}\"`)) relatedHelpers.add(name);
    const externalReaders=[...ownerSource.entries()].filter(([otherAbility,body])=>otherAbility!==ability&&(body.includes(`'${ability}'`)||body.includes(`\"${ability}\"`))).map(([,body])=>body);
    const helperBodies=[...relatedHelpers].map(name=>helperSource.get(name)||'');
    for(const body of helperBodies) for(const match of body.matchAll(/['\"](modifier_[A-Za-z0-9_]+)['\"]/g)) relatedModifiers.add(match[1]);
    const text=ownText+'\n'+externalReaders.join('\n')+'\n'+[...relatedModifiers].map(name=>classSource.get(name)||'').join('\n')+'\n'+helperBodies.join('\n');
    if(behavior.includes('PASSIVE')&&/PassivesDisabled/.test(text)&&kv.IsBreakable!=='1')
      throw new Error(`Passive checks PassivesDisabled but is not marked IsBreakable: ${id}`);
    const specials=getAbilityValues(kv);
    // AbilityValues can be selected through conditional expressions, e.g.
    // value(a, is_boss(unit) and 'boss_cap' or 'normal_cap'). Match the key
    // literals against this ability's declared fields instead of assuming the
    // key is the first argument after the comma. This remains a static hint,
    // not proof that the branch executes.
    const literals=new Set([...text.matchAll(/['"]([A-Za-z_]\w*)['"]/g)].map(m=>m[1]));
    const read=new Set(Object.keys(getAbilityValues(kv)).filter(key=>literals.has(key)));
    const legacyKeys=new Set(Object.values(kv.AbilitySpecial||{}).flatMap(row=>Object.keys(row||{}))
      .filter(key=>key!=='var_type'&&key!=='LinkedSpecialBonus'));
    const legacyLuaSpecials=[...read].filter(key=>legacyKeys.has(key)&&kv.AbilityValues?.[key]===undefined);
    kit.push({slot,id:ability,maxLevel:Number(kv.MaxLevel)||1,behavior,callbacks:[...methods].sort(),
      ...(native ? {implementationOwner:'NATIVE',nativeBaseClass:kv.BaseClass,engineAcceptance:'PENDING OWNER TEST'} : {}),
      specials,unreferencedSpecials:native ? [] : Object.keys(specials).filter(k=>!read.has(k)),legacyLuaSpecials,
      hasSound:Boolean(kv.AbilitySound)||/EmitSound|StopSound/.test(text),hasParticle:/\.vpcf/.test(text)});
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
console.log(`PASS 40 heroes / 200 ability entrypoints; ${rows.flatMap(h=>h.abilities).filter(a=>a.unreferencedSpecials.length).length} abilities retain unreferenced-field review candidates (not certified bugs); ${rows.flatMap(h=>h.abilities).filter(a=>a.legacyLuaSpecials.length).length} abilities have Lua-read values only in legacy AbilitySpecial rows (static warning, verify in engine).`);
