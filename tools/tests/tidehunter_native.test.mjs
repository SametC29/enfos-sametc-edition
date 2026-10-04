import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';
import {isVerifiedNativeAbility} from '../lib/native_hero_abilities.mjs';
const all=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
const q=all.enfos_tide_gush;
const snapshot=JSON.parse(fs.readFileSync('docs/audit/TIDEHUNTER_NATIVE_SOURCE_2026-10-04.json','utf8'));
const native=snapshot.abilities.tidehunter_gush;

test('Gush has one native cast/projectile/debuff owner with installed identity',()=>{
 assert.ok(isVerifiedNativeAbility('enfos_tide_gush',q));
 for(const key of ['AbilityBehavior','AbilityUnitTargetTeam','AbilityUnitTargetType','AbilityUnitDamageType',
  'SpellImmunityType','SpellDispellableType','AbilitySound','AbilityCastAnimation','AbilityDuration'])assert.equal(q[key],native[key],key);
 assert.equal(all.tidehunter_gush,undefined,'Do not shadow the native ID');
 const lua=fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8');
 assert.doesNotMatch(lua,/enfos_tide_gush\s*=\s*class|modifier_enfos_tide_gush_debuff/);
 assert.equal(isVerifiedNativeAbility('enfos_tide_gush',{...q,ScriptFile:'abilities/pve_kits'}),false);
});
test('Gush retains authored ten-rank tuning using exact signed native fields and native Scepter metadata',()=>{
 assert.equal(q.MaxLevel,'10');assert.equal(q.RequiredLevel,'1');assert.equal(q.LevelsBetweenUpgrades,'1');
 assert.equal(q.AbilityCastRange,'750');assert.equal(q.AbilityCastPoint,'0.3');
 assert.equal(q.AbilityCooldown,'12.0 11.3 10.7 10.0 9.3 8.7 8.0 7.3 6.7 6.0');
 assert.equal(q.AbilityValues.gush_damage,'110 137 163 190 217 243 270 297 323 350');
 assert.equal(q.AbilityValues.negative_armor,'4 5 5 6 6 7 8 8 9 10');
 assert.equal(q.AbilityValues.movement_speed,'-30 -32 -33 -35 -37 -38 -40 -42 -43 -45');
 assert.equal(q.AbilityValues.projectile_speed,native.AbilityValues.projectile_speed);
 for(const key of ['cast_range_scepter','aoe_scepter','speed_scepter','cooldown_scepter'])assert.deepEqual(JSON.parse(JSON.stringify(q.AbilityValues[key])),native.AbilityValues[key]);
 for(const key of Object.keys(q.AbilityValues).filter(k=>k!=='strength_factor'))assert.ok(Object.hasOwn(native.AbilityValues,key),key);
 for(const key of ['armor_reduction','slow_pct','duration','scepter_cooldown'])assert.equal(q.AbilityValues[key],undefined);
 for(const lang of ['english','turkish','russian','schinese']){
  const tokens=JSON.parse(fs.readFileSync(`localization/${lang}.json`,'utf8')).Tokens;
  for(const key of ['gush_damage','negative_armor','movement_speed|abs','strength_factor'])assert.ok(tokens.DOTA_Tooltip_Ability_enfos_tide_gush_Description.includes(`{{${key}}}`));
  assert.equal(tokens.DOTA_Tooltip_modifier_enfos_tide_gush_debuff,undefined);
 }
});
test('STR bridge is live, rank-correct and client-safe; restore is idempotent and never grants abilities or points',()=>{
 const ranks=q.AbilityValues.gush_damage.split(' ').join(',');
 const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{encoding:'utf8',input:`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
local server=true;function IsServer()return server end
function LinkLuaModifier(name,path)assert((name=='modifier_enfos_tide_native_scaling' or name=='modifier_enfos_tide_shell_extension') and path=='abilities/heroes/tidehunter/modifiers')end
local Integration=require('abilities/heroes/tidehunter/integration')
local rank,adds,str=0,0,40;local qnull,parentnull=false,false
local values={${ranks}}
local q={IsNull=function()return qnull end,GetAbilityName=function()return 'enfos_tide_gush'end,
 GetLevel=function()return rank end,GetSpecialValueFor=function()error('Recursive special lookup')end,
 GetLevelSpecialValueNoOverride=function(_,key,level)
  assert(level>=0 and level<=9)
  if key=='gush_damage'then return values[level+1]end
  assert(key=='strength_factor');return 1
 end}
local handle
local hero={IsNull=function()return parentnull end,IsRealHero=function()return true end,IsIllusion=function()return false end,
 GetUnitName=function()return 'npc_dota_hero_tidehunter'end,GetStrength=function()assert(not parentnull);return str end,
 FindAbilityByName=function(_,id)if id=='enfos_tide_gush' then return q end;assert(id=='enfos_tide_kraken_shell')end,
 HasModifier=function()return handle~=nil end,
 AddAbility=function()error('No provider required')end,SetAbilityPoints=function()error('No point grants')end}
local m=setmetatable({IsNull=function()return false end,GetParent=function()return hero end},modifier_enfos_tide_native_scaling)
hero.AddNewModifier=function(_,_,ability,id)assert(ability==q and id=='modifier_enfos_tide_native_scaling');adds=adds+1;handle=m;return m end
assert(Integration.Restore(hero));assert(Integration.Restore(hero));assert(adds==1)
local p={ability=q,ability_special_value='gush_damage'}
assert(m:GetModifierOverrideAbilitySpecial(p)==1)
assert(m:GetModifierOverrideAbilitySpecialValue(p)==0)
for r=1,10 do rank=r;assert(m:GetModifierOverrideAbilitySpecialValue(p)==values[r]+str)end
str=85;assert(m:GetModifierOverrideAbilitySpecialValue(p)==435)
server=false;hero.IsAlive=function()error('Server-only getter')end
hero.FindModifierByName=function()error('Server-only modifier lookup')end
assert(m:GetModifierOverrideAbilitySpecialValue(p)==435)
assert(not Integration.Restore(hero) and adds==1)
parentnull=true;assert(m:GetModifierOverrideAbilitySpecialValue(p)==0);parentnull=false
qnull=true;assert(m:GetModifierOverrideAbilitySpecial(p)==0 and m:GetModifierOverrideAbilitySpecialValue(p)==0);qnull=false
p.ability_special_value='negative_armor';assert(m:GetModifierOverrideAbilitySpecial(p)==0)
p.ability=nil;assert(m:GetModifierOverrideAbilitySpecial(p)==0)
assert(not m:RemoveOnDeath() and not m:IsPurgable() and m:IsHidden())
server=true;handle=nil;hero.AddNewModifier=function()return nil end
assert(not Integration.Restore(hero))
`});
 assert.equal(result.status,0,result.stderr);assert.equal(result.stderr,'');
});

test('Kraken Shell delegates active/block/cleanse to native while Shard stays an explicit Enfos threshold extension',()=>{
 const w=all.enfos_tide_kraken_shell,n=snapshot.abilities.tidehunter_kraken_shell;
 assert.ok(isVerifiedNativeAbility('enfos_tide_kraken_shell',w));
 for(const key of ['AbilityBehavior','AbilitySound','SpellDispellableType','IsBreakable','AbilityManaCost','AbilityCastAnimation'])assert.equal(w[key],n[key]);
 assert.equal(w.AbilityCooldown,n.AbilityValues.AbilityCooldown.value);
 assert.equal(w.MaxLevel,'10');assert.equal(w.RequiredLevel,'1');assert.equal(w.LevelsBetweenUpgrades,'1');
 for(const key of ['active_duration','active_pct_effectiveness','active_move_speed_penalty_pct','creep_reduction_penalty_pct','damage_reset_interval'])assert.equal(w.AbilityValues[key],n.AbilityValues[key]);
 assert.equal(w.AbilityValues.smash_on_purge,'0');assert.equal(w.AbilityValues.bonus_reduction_per_kill,'0');
 const old=fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8');
 assert.doesNotMatch(old,/enfos_tide_kraken_shell\s*=\s*class|modifier_enfos_tide_kraken_shell_passive/);
 const extension=fs.readFileSync('game/scripts/vscripts/abilities/heroes/tidehunter/modifiers.lua','utf8');
 assert.doesNotMatch(extension,/Purge\(|MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK/);
 assert.match(old,/damage\(self, u, dmg, DAMAGE_TYPE_PHYSICAL, damage_flags\)/);
});
test('Shell extension bounds reflected Shard smashes without purging, handles Break/source loss and has client-safe regen',()=>{
 const w=all.enfos_tide_kraken_shell.AbilityValues;
 const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{encoding:'utf8',input:`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
require('abilities/heroes/tidehunter/modifiers')
local server=true;function IsServer()return server end
local now=0;GameRules={GetGameTime=function()return now end}
DOTA_DAMAGE_FLAG_REFLECTION=16
local broken,shard,removed,untrained=false,true,false,false
local calls=0
local e={IsNull=function()return removed end,GetLevel=function()return untrained and 0 or 1 end}
local rank=1;local regen={${w.bonus_hp_regen.split(' ').join(',')}}
local block={${w.damage_reduction.split(' ').join(',')}}
local vals={shard_reset_interval=7,shard_damage_threshold=450,shard_smash_cooldown=5,shard_smash_damage_pct=50}
local a={IsNull=function()return removed end,GetLevel=function()return rank end,
 GetAbilityName=function()return 'enfos_tide_kraken_shell'end,
 GetLevelSpecialValueNoOverride=function(_,key,index)if key=='damage_reduction'then return block[index+1]end;assert(key=='strength_factor');return 0.05 end,
 GetSpecialValueFor=function(_,key)if key=='bonus_hp_regen'then return regen[rank]end;return assert(vals[key])end}
local c={IsNull=function()return removed end,IsIllusion=function()return false end,
 GetStrength=function()return 100 end,
 PassivesDisabled=function()return broken end,HasShard=function()return shard end,IsAlive=function()assert(server);return true end,
 FindAbilityByName=function(_,id)assert(id=='enfos_tide_anchor_smash');return e end,
 StartGesture=function()end,Purge=function()error('Native alone owns cleanse')end}
local m=setmetatable({GetParent=function()return c end,GetAbility=function()return a end,
 IsNull=function()return removed end},modifier_enfos_tide_shell_extension)
e.ApplyAnchorSmash=function(_,scale,flags)
 assert(scale==0.5 and flags==16);calls=calls+1
 m:OnTakeDamage({unit=c,damage=900}) -- reflected callbacks cannot recursively trigger
end
local scaling=setmetatable({GetParent=function()return c end},modifier_enfos_tide_native_scaling)
local query={ability=a,ability_special_value='damage_reduction'}
for r=1,10 do rank=r;assert(m:GetModifierConstantHealthRegen()==regen[r]);assert(scaling:GetModifierOverrideAbilitySpecialValue(query)==block[r]+5)end
m:OnTakeDamage({unit=c,damage=449});assert(calls==0)
m:OnTakeDamage({unit=c,damage=1});assert(calls==1)
m:OnTakeDamage({unit=c,damage=900});assert(calls==1)
now=5;m:OnTakeDamage({unit=c,damage=450});assert(calls==2)
now=6;m:OnTakeDamage({unit=c,damage=449});now=13;m:OnTakeDamage({unit=c,damage=1});assert(calls==2)
broken=true;m:OnTakeDamage({unit=c,damage=900});assert(m:GetModifierConstantHealthRegen()==0 and calls==2);broken=false
m.damage_counter=400;m:OnDeath({unit=c});assert(m.damage_counter==0 and m.last_damage_time==nil)
shard=false;m:OnTakeDamage({unit=c,damage=900});assert(calls==2);shard=true
untrained=true;now=20;m:OnTakeDamage({unit=c,damage=450});assert(calls==2);untrained=false
server=false;c.IsAlive=function()error('Client server-only call')end
assert(m:GetModifierConstantHealthRegen()==20);m:OnTakeDamage({unit=c,damage=450});assert(calls==2)
removed=true;assert(m:GetModifierConstantHealthRegen()==0)
`});
 assert.equal(result.status,0,result.stderr);assert.equal(result.stderr,'');
});
