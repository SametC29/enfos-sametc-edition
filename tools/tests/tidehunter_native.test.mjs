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

test('Anchor manual cast is native with exact attack keys, signed reduction and native geometry',()=>{
 const e=all.enfos_tide_anchor_smash,n=snapshot.abilities.tidehunter_anchor_smash;
 assert.ok(isVerifiedNativeAbility('enfos_tide_anchor_smash',e));
 for(const key of ['AbilityBehavior','AbilityUnitDamageType','SpellImmunityType','SpellDispellableType','AbilitySound','AbilityCastAnimation','AbilityCastPoint'])assert.equal(e[key],n[key],key);
 assert.equal(e.MaxLevel,'10');assert.equal(e.RequiredLevel,'1');assert.equal(e.LevelsBetweenUpgrades,'1');
 assert.equal(e.AbilityValues.attack_damage.value,'80 97 113 130 147 163 180 197 213 230');
 assert.equal(e.AbilityValues.damage_reduction.value,'-40 -43 -47 -50 -53 -57 -60 -63 -67 -70');
 assert.equal(e.AbilityValues.additional_range.value,n.AbilityValues.additional_range.value);
 assert.equal(e.AbilityValues.additional_range.affected_by_aoe_increase,'1');
 assert.equal(e.AbilityValues.reduction_duration,'6.0');
 for(const key of ['targets_buildings','building_pct_damage','smash_on_attack'])assert.equal(e.AbilityValues[key],'0');
 for(const key of ['radius','attack_damage_bonus','duration'])assert.equal(e.AbilityValues[key],undefined);
 const old=fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8');
 assert.doesNotMatch(old,/enfos_tide_anchor_smash\s*=\s*class|modifier_enfos_tide_anchor_smash_debuff/);
 for(const lang of ['english','turkish','russian','schinese']){
  const t=JSON.parse(fs.readFileSync(`localization/${lang}.json`)).Tokens;
  for(const key of ['attack_damage','strength_factor','additional_range','damage_reduction|abs','reduction_duration'])assert.ok(t.DOTA_Tooltip_Ability_enfos_tide_anchor_smash_Description.includes(`{{${key}}}`));
  assert.equal(t.DOTA_Tooltip_modifier_enfos_tide_anchor_smash_debuff,undefined);
 }
});

test('Anchor bonus bridge spans all ten ranks on client/server without native getters or recursive lookup',()=>{
 const values=all.enfos_tide_anchor_smash.AbilityValues.attack_damage.value.split(' ').join(',');
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{encoding:'utf8',input:`
function class(t)t.__index=t;return t end
dofile('game/scripts/vscripts/abilities/heroes/tidehunter/modifiers.lua')
local rank,str,removed=0,80,false;local values={${values}}
local c={IsNull=function()return removed end,GetStrength=function()return str end,IsAlive=function()error('Client server-only getter')end}
local a={IsNull=function()return removed end,GetLevel=function()return rank end,GetAbilityName=function()return 'enfos_tide_anchor_smash'end,
 GetSpecialValueFor=function()error('Recursive lookup')end,GetLevelSpecialValueNoOverride=function(_,key,index)if key=='attack_damage'then return values[index+1]end;assert(key=='strength_factor');return 0.75 end}
local m=setmetatable({GetParent=function()return c end},modifier_enfos_tide_native_scaling)
local p={ability=a,ability_special_value='attack_damage'}
assert(m:GetModifierOverrideAbilitySpecialValue(p)==0)
for i=1,10 do rank=i;assert(m:GetModifierOverrideAbilitySpecialValue(p)==values[i]+60)end
str=120;assert(m:GetModifierOverrideAbilitySpecialValue(p)==320)
p.ability_special_value='damage_reduction';assert(m:GetModifierOverrideAbilitySpecial(p)==0)
p.ability_special_value='attack_damage';removed=true;assert(m:GetModifierOverrideAbilitySpecialValue(p)==0)
`});assert.equal(r.status,0,r.stderr);assert.equal(r.stderr,'');
});

test('Reactive half-smash uses native radius and recipient identity, reflection flags and callback guards',()=>{
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{encoding:'utf8',input:`
package.path='game/scripts/vscripts/?.lua;'..package.path
local server=true;function IsServer()return server end
local removed,dead,invalidAbility=false,false,false
DOTA_DAMAGE_FLAG_REFLECTION=16;DAMAGE_TYPE_PHYSICAL=1;DOTA_UNIT_TARGET_TEAM_ENEMY=2
DOTA_UNIT_TARGET_HERO=1;DOTA_UNIT_TARGET_BASIC=2;DOTA_UNIT_TARGET_FLAG_NONE=0;FIND_ANY_ORDER=0;PATTACH_ABSORIGIN_FOLLOW=1
function Vector(x,y,z)return{x=x,y=y,z=z}end
local c={IsNull=function()return removed end,IsAlive=function()return not dead end,
 GetTeamNumber=function()return 2 end,GetAbsOrigin=function()return Vector(0,0,0)end,
 GetAverageTrueAttackDamage=function(_,u)assert(u);return 100 end,EmitSound=function()end}
local radius,rank=375,1
local e={IsNull=function()return invalidAbility end,GetLevel=function()return rank end,
 GetAOERadius=function()assert(server);return radius end,
 GetSpecialValueFor=function(_,key)return assert(({attack_damage=140,reduction_duration=6})[key])end}
local effects,release,damage,mods=0,0,{},{}
ParticleManager={CreateParticle=function(_,path,attach,parent)assert(parent==c);effects=effects+1;return effects end,
 SetParticleControl=function(_,_,cp,v)assert(cp==2 and v.x==radius)end,ReleaseParticleIndex=function()release=release+1 end}
local function unit(team,immune)
 return{IsNull=function()return false end,IsAlive=function()return true end,GetTeamNumber=function()return team end,
 IsAttackImmune=function()return immune end,AddNewModifier=function(self,caster,ability,name,p)
 assert(caster==c and ability==e and name=='modifier_tidehunter_anchor_smash' and p.duration==6);mods[self]=(mods[self] or 0)+1 end}
end
local u,v,ally,immune=unit(3,false),unit(3,false),unit(2,false),unit(3,true)
FindUnitsInRadius=function(_,_,_,r,team,types,flags)assert(r==radius and team==2 and types==3 and flags==0);return{u,v,ally,immune}end
ApplyDamage=function(p)assert(p.damage==120 and p.damage_flags==16 and p.damage_type==1);damage[#damage+1]=p end
local S=require('abilities/heroes/tidehunter/shard')
S.Smash(c,e,0.5);assert(#damage==2 and mods[u]==1 and mods[v]==1 and not mods[ally] and not mods[immune]);assert(effects==1 and release==1)
radius=525;S.Smash(c,e,0.5);assert(#damage==4 and effects==2 and release==2)
for _,mode in ipairs({'target','caster','ability','death'})do
 removed=false;dead=false;invalidAbility=false;mods={};damage={}
 u.IsNull=function()return false end
 ApplyDamage=function(p)damage[#damage+1]=p;if mode=='target'then u.IsNull=function()return true end
 elseif mode=='caster'then removed=true elseif mode=='ability'then invalidAbility=true else dead=true end end
 S.Smash(c,e,0.5);assert(not mods[u]);if mode~='target'then assert(#damage==1 and not mods[v])end
end
removed=false;dead=false;invalidAbility=false;rank=0;local old=effects;S.Smash(c,e,0.5);assert(effects==old)
rank=1;server=false;S.Smash(c,e,0.5);assert(effects==old)
`});assert.equal(r.status,0,r.stderr);assert.equal(r.stderr,'');
});

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
 assert.doesNotMatch(old,/enfos_tide_anchor_smash\s*=\s*class|modifier_enfos_tide_anchor_smash_debuff/);
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
package.loaded['abilities/heroes/tidehunter/shard']={Smash=function(parent,ability,scale)
 assert(parent==c and ability==e and scale==0.5);calls=calls+1
 m:OnTakeDamage({unit=c,damage=900}) -- reflected callbacks cannot recursively trigger
end}
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
