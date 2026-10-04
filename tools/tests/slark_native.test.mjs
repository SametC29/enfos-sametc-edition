import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';
import {isVerifiedNativeAbility} from '../lib/native_hero_abilities.mjs';
const all=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
const id='enfos_slark_dark_pact',q=all[id];
const source=JSON.parse(fs.readFileSync('docs/audit/SLARK_NATIVE_SOURCE_2026-10-04.json','utf8')).abilities.slark_dark_pact;
test('Dark Pact has one native owner with verified cast identity and no custom pulses',()=>{
 assert.ok(isVerifiedNativeAbility(id,q));assert.equal(q.BaseClass,'slark_dark_pact');
 for(const key of ['AbilityBehavior','AbilityUnitDamageType','SpellImmunityType','AbilitySound','AbilityCastAnimation'])
  assert.equal(q[key],source[key],key);
 const lua=fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8');
 assert.doesNotMatch(lua,/enfos_slark_dark_pact\s*=\s*class|modifier_enfos_slark_dark_pact_buff/);
 assert.equal(all.slark_dark_pact,undefined);
 assert.equal(isVerifiedNativeAbility(id,{...q,ScriptFile:'abilities/pve_kits'}),false);
});
test('Dark Pact restores native delay and blood cost while preserving authored ten-rank totals and tuning',()=>{
 assert.equal(q.MaxLevel,'10');assert.equal(q.RequiredLevel,'1');assert.equal(q.LevelsBetweenUpgrades,'1');
 const v=q.AbilityValues;
 assert.equal(v.total_damage,'100 150 200 250 300 350 400 450 500 550');
 assert.equal(v.delay,source.AbilityValues.delay);assert.equal(v.self_damage_pct,source.AbilityValues.self_damage_pct);
 assert.equal(Number(v.pulse_duration),Number(v.total_pulses)*Number(v.pulse_interval));
 assert.equal(v.radius,'350');assert.equal(v.agility_factor,'1.0');
 for(const key of ['damage','pulse_count','tick_interval'])assert.equal(v[key],undefined);
 for(const key of Object.keys(v).filter(k=>k!=='agility_factor'))assert.ok(Object.hasOwn(source.AbilityValues,key),key);
 for(const lang of ['english','turkish','russian','schinese']){
  const desc=JSON.parse(fs.readFileSync(`localization/${lang}.json`,'utf8')).Tokens[`DOTA_Tooltip_Ability_${id}_Description`];
  for(const key of ['delay','self_damage_pct','total_damage','total_pulses'])assert.ok(desc.includes(`{{${key}}}`),`${lang}.${key}`);
 }
});
test('native AGI bridge uses raw rank values on client/server and restores once without adding abilities or points',()=>{
 const ranks=q.AbilityValues.total_damage.split(' ').join(',');
 const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{encoding:'utf8',input:`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
local server=true;function IsServer()return server end
function LinkLuaModifier(name,path)assert(name=='modifier_enfos_slark_native_scaling' and path=='abilities/heroes/slark/modifiers')end
local Integration=require('abilities/heroes/slark/integration')
local rank,adds=1,0
local values={${ranks}}
local q={IsNull=function()return false end,GetAbilityName=function()return 'enfos_slark_dark_pact'end,
 GetLevel=function()return rank end,GetLevelSpecialValueNoOverride=function(_,key,level)
  if key=='total_damage'then return values[level+1]end
  assert(key=='agility_factor');return 1
 end}
local handle
local hero={IsNull=function()return false end,IsRealHero=function()return true end,IsIllusion=function()return false end,
 GetUnitName=function()return 'npc_dota_hero_slark'end,GetAgility=function()return 20 end,
 FindAbilityByName=function(_,id)assert(id=='enfos_slark_dark_pact');return q end,
 HasModifier=function()return handle~=nil end,
 AddAbility=function()error('Native alias needs no provider')end,
 SetAbilityPoints=function()error('Scaling must not grant points')end}
local m=setmetatable({IsNull=function()return false end,GetParent=function()return hero end},modifier_enfos_slark_native_scaling)
hero.AddNewModifier=function(_,_,ability,id)assert(ability==q and id=='modifier_enfos_slark_native_scaling');adds=adds+1;handle=m;return m end
assert(Integration.Restore(hero));assert(Integration.Restore(hero));assert(adds==1)
local p={ability=q,ability_special_value='total_damage'}
assert(m:GetModifierOverrideAbilitySpecial(p)==1)
for r=1,10 do rank=r;assert(m:GetModifierOverrideAbilitySpecialValue(p)==values[r]+20)end
server=false;hero.IsAlive=function()error('server-only API')end
hero.FindModifierByName=function()error('server-only API')end
assert(m:GetModifierOverrideAbilitySpecialValue(p)==570)
assert(not Integration.Restore(hero) and adds==1)
rank=0;assert(m:GetModifierOverrideAbilitySpecialValue(p)==0)
p.ability_special_value='self_damage_pct';assert(m:GetModifierOverrideAbilitySpecial(p)==0)
assert(not m:RemoveOnDeath() and not m:IsPurgable())
`});
 assert.equal(result.status,0,result.stderr);assert.equal(result.stderr,'');
});
