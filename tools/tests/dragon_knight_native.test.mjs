import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';
import {isVerifiedNativeAbility} from '../lib/native_hero_abilities.mjs';
const all=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
const source=JSON.parse(fs.readFileSync('docs/audit/DRAGON_KNIGHT_NATIVE_SOURCE_2026-10-04.json','utf8'));
const setup=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
local server=true;function IsServer()return server end
LUA_MODIFIER_MOTION_NONE=0;function LinkLuaModifier(n,p)assert(n=='modifier_enfos_dk_native_scaling' and p=='abilities/heroes/dragon_knight/modifiers')end
package.loaded['lib/hero_trace']={Log=function()end}
local hero={null=false,real=true,illusion=false,name='npc_dota_hero_dragon_knight',str=80,
IsNull=function(self)return self.null end,IsRealHero=function(self)return self.real end,IsIllusion=function(self)return self.illusion end,
GetUnitName=function(self)return self.name end,GetStrength=function(self,...)assert(select('#',...)==0);return self.str end,
IsAlive=function()error('server-only getter')end,AddAbility=function()error('unneeded provider')end,
SetAbilityPoints=function()error('points mutation')end}
local q={rank=0,null=false,IsNull=function(self)return self.null end,GetCaster=function()return hero end,
GetAbilityName=function()return 'enfos_dk_breathe_fire'end,GetLevel=function(self)return self.rank end,
GetSpecialValueFor=function()error('recursive raw query')end,
GetLevelSpecialValueNoOverride=function(self,key,rank)assert(rank==math.min(10,self.rank)-1);if key=='strength_factor' then return 1.2 end;assert(key=='damage');return 120+rank*60 end}
local mods=0;hero.FindAbilityByName=function(_,id)if id=='enfos_dk_breathe_fire' then return q end end
hero.HasModifier=function(self,id)assert(id=='modifier_enfos_dk_native_scaling');return self.mod~=nil end
hero.AddNewModifier=function(self,c,a,id)assert(server and c==hero and a==q and id=='modifier_enfos_dk_native_scaling');mods=mods+1
 self.mod=setmetatable({IsNull=function()return false end,GetParent=function()return hero end},{__index=modifier_enfos_dk_native_scaling});return self.mod end
local integration=require('abilities/heroes/dragon_knight/integration')
`;
function lua(body){const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:setup+body,encoding:'utf8'});assert.equal(r.status,0,r.stderr);assert.equal(r.stderr,'');}

test('Breathe Fire is a pure native cone alias with exact targeting/dispel/travel fields and consistent ten-rank tuning',()=>{
 const q=all.enfos_dk_breathe_fire,n=source.abilities.dragon_knight_breathe_fire;
 assert.ok(isVerifiedNativeAbility('enfos_dk_breathe_fire',q));assert.equal(q.ScriptFile,undefined);assert.equal(q.MaxLevel,'10');assert.equal(q.RequiredLevel,'1');assert.equal(q.LevelsBetweenUpgrades,'1');assert.equal(all.dragon_knight_breathe_fire,undefined);
 for(const key of ['AbilityBehavior','AbilityUnitTargetTeam','AbilityUnitTargetType','SpellImmunityType','SpellDispellableType','AbilityUnitDamageType','AbilitySound','AbilityCastPoint','AbilityCastAnimation'])assert.equal(q[key],n[key],key);
 for(const key of ['range','speed','AbilityCastRange'])assert.equal(q.AbilityValues[key],n.AbilityValues[key],key);assert.equal(q.AbilityCastRange,q.AbilityValues.AbilityCastRange);assert.equal(q.AbilityCooldown,q.AbilityValues.AbilityCooldown.value);
 for(const [key,value]of [['start_radius','150'],['end_radius','250']]){assert.equal(q.AbilityValues[key].value,value);assert.equal(q.AbilityValues[key].affected_by_aoe_increase,n.AbilityValues[key].affected_by_aoe_increase);}
 assert.equal(q.AbilityValues.damage.value,'120 180 240 300 360 420 480 540 600 660');assert.equal(q.AbilityValues.strength_factor,'1.2');assert.equal(q.AbilityValues.reduction.value,'35 38 41 44 47 50 53 56 59 62');assert.equal(q.AbilityValues.duration,'6 6.3 6.7 7 7.3 7.7 8 8.3 8.7 9');assert.equal(q.AbilityManaCost,'90 99 108 117 126 135 144 153 162 170');assert.equal(q.AbilityValues.width,undefined);assert.equal(q.AbilityValues.reduction_pct,undefined);
 const kits=fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8');assert.doesNotMatch(kits,/enfos_dk_breathe_fire=class|modifier_enfos_dk_breathe_fire_debuff/);
 for(const name of ['modifiers','integration'])assert.doesNotMatch(fs.readFileSync('game/scripts/vscripts/abilities/heroes/dragon_knight/'+name+'.lua','utf8'),/ApplyDamage|OnSpellStart|CreateParticle|EmitSound|FindUnits|CreateLinearProjectile|StartIntervalThink|ForceRefresh|SetAbilityPoints/);
});

test('Q live raw STR damage covers all ranks on both contexts and rejects wrong keys/owner/ability without suppressing active casts under Break',()=>lua(`
assert(integration.Restore(hero));local m,p=hero.mod,{ability=q,ability_special_value='damage'}
assert(m:GetModifierOverrideAbilitySpecial(p)==1 and m:GetModifierOverrideAbilitySpecialValue(p)==0)
hero.PassivesDisabled=function()return true end
for _,context in ipairs({true,false})do server=context;for rank=1,10 do q.rank=rank;assert(m:GetModifierOverrideAbilitySpecialValue(p)==120+60*(rank-1)+96)end end
hero.str=100;assert(m:GetModifierOverrideAbilitySpecialValue(p)==780)
p.ability_special_value='reduction';assert(m:GetModifierOverrideAbilitySpecial(p)==0);p.ability_special_value='damage'
q.GetCaster=function()return {}end;assert(m:GetModifierOverrideAbilitySpecial(p)==0);q.GetCaster=function()return hero end
q.GetAbilityName=function()return 'enfos_dk_dragon_tail'end;assert(m:GetModifierOverrideAbilitySpecial(p)==0);q.GetAbilityName=function()return 'enfos_dk_breathe_fire'end
hero.null=true;assert(m:GetModifierOverrideAbilitySpecialValue(p)==0);hero.null=false;q.null=true;assert(m:GetModifierOverrideAbilitySpecialValue(p)==0);q.null=false
assert(m:GetModifierOverrideAbilitySpecial(nil)==0);assert(mods==1)
`));

test('Q integration restore is idempotent and respects real-owned server guards without native grants/ranks/points writes',()=>lua(`
assert(integration.Restore(hero));assert(integration.Restore(hero));assert(mods==1)
assert(hero.mod:IsHidden() and not hero.mod:IsPurgable() and not hero.mod:RemoveOnDeath())
q.rank=10;assert(integration.Restore(hero));assert(mods==1 and q.rank==10)
server=false;assert(not integration.Restore(hero));server=true
hero.illusion=true;assert(not integration.Restore(hero));hero.illusion=false;hero.real=false;assert(not integration.Restore(hero));hero.real=true
q.GetCaster=function()return {}end;assert(not integration.Restore(hero));q.GetCaster=function()return hero end
hero.mod=nil;hero.AddNewModifier=function()return nil end;assert(not integration.Restore(hero))
`));

test('Q Health reads native damage/cone/speed without invoking gameplay; client does not report',()=>lua(`
hero.GetLevel=function()return 6 end;hero.GetAbilityPoints=function()return 5 end;hero.IsAlive=function()return true end
q.GetIntrinsicModifierName=function()return ''end;q.GetSpecialValueFor=function(_,key)return assert(({damage=216,start_radius=150,end_radius=250,speed=1050})[key])end
hero.AddNewModifier=function()error('Health restores')end
local out={};print=function(s)out[#out+1]=s end;assert(require('heroes/health').Report(hero,0));assert(table.concat(out,'|'):find('native_breathe_damage_query=216 native_breathe_start_radius_query=150 native_breathe_end_radius_query=250 native_breathe_speed_query=1050',1,true))
server=false;local count=#out;assert(not require('heroes/health').Report(hero,0) and #out==count)
`));

test('Four Q locale descriptions/mirrors use native cone and reduction keys; verified native particle precache stays available',()=>{
 for(const lang of ['english','turkish','russian','schinese']){const t=JSON.parse(fs.readFileSync('localization/'+lang+'.json','utf8')).Tokens;for(const suffix of ['Description','SummaryDescription']){const desc=t['DOTA_Tooltip_Ability_enfos_dk_breathe_fire_'+suffix];for(const key of ['damage','strength_factor','reduction','duration','range','speed','start_radius','end_radius'])assert.ok(desc.includes('{{'+key+'}}'),key);assert.doesNotMatch(desc,/225|reduction_pct/);}for(const dir of ['game/resource','game/panorama/localization','content/panorama/localization']){const text=fs.readFileSync(dir+'/addon_'+lang+'.txt','utf8');assert.doesNotMatch(text,/\{\{/);assert.ok(text.includes('120 / 180 / 240 / 300 / 360 / 420 / 480 / 540 / 600 / 660'));}}
 const precache=fs.readFileSync('game/scripts/vscripts/addon_game_mode.lua','utf8');for(const end of ['breathe_fire','breathe_fire_explosion']){const path='particles/units/heroes/hero_dragon_knight/dragon_knight_'+end+'.vpcf';assert.ok(precache.includes(path)&&source.assets.find(x=>x.path===path));}
});
