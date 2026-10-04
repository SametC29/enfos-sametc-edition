import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';
import {isVerifiedNativeAbility} from '../lib/native_hero_abilities.mjs';
const all=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
const native=JSON.parse(fs.readFileSync('docs/audit/STORM_SPIRIT_NATIVE_SOURCE_2026-10-04.json','utf8')).abilities.storm_spirit_overload;
const remnant=JSON.parse(fs.readFileSync('docs/audit/STORM_SPIRIT_NATIVE_SOURCE_2026-10-04.json','utf8')).abilities.storm_spirit_static_remnant;
const setup=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
local server=true;function IsServer()return server end
LUA_MODIFIER_MOTION_NONE=0;function LinkLuaModifier(n,p)assert(n=='modifier_enfos_storm_native_scaling' and p=='abilities/heroes/storm_spirit/modifiers')end
package.loaded['lib/hero_trace']={Log=function()end}
DOTA_ABILITY_BEHAVIOR_PASSIVE=2;DOTA_ABILITY_BEHAVIOR_HIDDEN=4
bit={band=function(a,b)return a & b end,bnot=function(a)return ~a end}
local hero={null=false,real=true,illusion=false,name='npc_dota_hero_storm_spirit',int=100,
IsNull=function(self)return self.null end,IsRealHero=function(self)return self.real end,IsIllusion=function(self)return self.illusion end,
GetUnitName=function(self)return self.name end,GetIntellect=function(self,skipNoConsume)assert(skipNoConsume==false);return self.int end,
IsAlive=function()error('server-only getter')end,SetAbilityPoints=function()error('point mutation')end}
local paid={rank=0,null=false,IsNull=function(self)return self.null end,GetLevel=function(self)return self.rank end,GetCaster=function()return hero end,
GetLevelSpecialValueNoOverride=function(self,key,rank)
 assert(rank==math.min(10,self.rank)-1)
 local rows={overload_damage={25,40,55,70,85,100,120,140,165,190},overload_aoe={220,235,250,265,280,295,310,325,340,360},intellect_factor={.6}}
 local row=assert(rows[key],key);return row[rank+1] or row[1]
end,GetSpecialValueFor=function()error('recursive raw bridge')end}
local adds,mods,sets,casts=0,0,0,0
local n={rank=0,null=false,shard=false,charge=7,cooldown=9,IsNull=function(self)return self.null end,GetLevel=function(self)return self.rank end,
GetAbilityName=function()return 'storm_spirit_overload'end,GetCaster=function()return hero end,
SetLevel=function(self,rank)assert(server and hero.mod);self.rank=rank;sets=sets+1 end,
SetHidden=function(self,v)assert(server);self.hidden=v end,SetActivated=function(self,v)assert(server);self.active=v end,
GetBehavior=function(self)return (self.shard and 8 or 2)+4 end,
GetSpecialValueFor=function(self,key)local rows={shard_manacost=100,shard_cooldown=30,shard_activation_radius=750,shard_activation_charges=3};return self.shard and assert(rows[key],key) or 0 end,
OnSpellStart=function(self)assert(server and self.shard);casts=casts+1 end,
StartCooldown=function(self,value)assert(server and value==9);self.cooldown=value end}
hero.FindAbilityByName=function(self,id)if id=='enfos_storm_overload' then return paid elseif id=='storm_spirit_overload' then return self.native end end
hero.HasModifier=function(self,id)assert(id=='modifier_enfos_storm_native_scaling');return self.mod~=nil end
hero.AddNewModifier=function(self,c,a,id)assert(server and c==hero and a==paid and id=='modifier_enfos_storm_native_scaling');mods=mods+1
 self.mod=setmetatable({GetParent=function()return hero end,IsNull=function()return false end},{__index=modifier_enfos_storm_native_scaling});return self.mod end
hero.AddAbility=function(self,id)assert(server and id=='storm_spirit_overload' and self.mod);adds=adds+1;self.native=n;return n end
local integration=require('abilities/heroes/storm_spirit/integration')
require('abilities/heroes/storm_spirit/e')
`;
function lua(body){const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:setup+body,encoding:'utf8'});assert.equal(r.status,0,r.stderr);assert.equal(r.stderr,'');}
test('Paid E retains ten ranks, native immunity/dispelling/Shard metadata and one raw damage bridge',()=>{
 const e=all.enfos_storm_overload;assert.equal(e.MaxLevel,'10');assert.equal(e.RequiredLevel,'1');assert.equal(e.LevelsBetweenUpgrades,'1');assert.equal(e.ScriptFile,'abilities/heroes/storm_spirit/e');
 for(const key of ['AbilityUnitDamageType','SpellImmunityType','SpellDispellableType','AbilityCastAnimation','HasShardUpgrade','IsBreakable'])assert.equal(e[key],native[key],key);
 assert.equal(e.AbilityValues.overload_damage,'25 40 55 70 85 100 120 140 165 190');assert.equal(e.AbilityValues.overload_aoe,'220 235 250 265 280 295 310 325 340 360');assert.equal(e.AbilityValues.intellect_factor,'0.6');assert.equal(all.storm_spirit_overload,undefined);assert.equal(all.enfos_storm_galvanic_core.HasShardUpgrade,undefined);
 const kits=fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8');assert.doesNotMatch(kits,/enfos_storm_overload=class|modifier_enfos_storm_overload_(passive|slow)/);
 for(const file of ['modifiers','integration','e'])assert.doesNotMatch(fs.readFileSync('game/scripts/vscripts/abilities/heroes/storm_spirit/'+file+'.lua','utf8'),/ApplyDamage|OnAttackLanded|OnAbilityFullyCast|FindUnits|CreateParticle|EmitSound|StartIntervalThink|ForceRefresh|SetStackCount|SetAbilityPoints/);
});
test('Exact native E restore is idempotent, untrained rank zero, no charge/cooldown/points reset',()=>lua(`
assert(integration.Restore(hero));assert(adds==1 and mods==1 and sets==0 and n.rank==0 and n.hidden and not n.active)
for rank=1,10 do paid.rank=rank;assert(integration.Restore(hero));assert(integration.Restore(hero));assert(n.rank==1 and n.active)end
assert(adds==1 and mods==1 and sets==1 and n.charge==7 and n.cooldown==9)
hero.illusion=true;assert(not integration.Restore(hero));hero.illusion=false;hero.real=false;assert(not integration.Restore(hero));hero.real=true
server=false;assert(not integration.Restore(hero));assert(adds==1)
`));
test('All ten paid ranks use raw native-key values on both contexts without recursive queries or target writes',()=>lua(`
assert(integration.Restore(hero));local m=hero.mod
assert(m:IsHidden() and not m:IsPurgable() and not m:RemoveOnDeath())
local p={ability=n,ability_special_value='overload_damage'}
assert(m:GetModifierOverrideAbilitySpecial(p)==1 and m:GetModifierOverrideAbilitySpecialValue(p)==0)
for _,context in ipairs({true,false})do server=context;for rank=1,10 do paid.rank=rank
assert(m:GetModifierOverrideAbilitySpecialValue(p)==paid:GetLevelSpecialValueNoOverride('overload_damage',rank-1)+60)
p.ability_special_value='overload_aoe';assert(m:GetModifierOverrideAbilitySpecialValue(p)==paid:GetLevelSpecialValueNoOverride('overload_aoe',rank-1));p.ability_special_value='overload_damage'
end end
hero.int=150;assert(m:GetModifierOverrideAbilitySpecialValue(p)==280)
for _,key in ipairs({'overload_move_slow','overload_attack_slow','shard_activation_charges','overload_bounces'})do p.ability_special_value=key;assert(m:GetModifierOverrideAbilitySpecial(p)==0)end
p.ability_special_value='overload_damage';local caster=n.GetCaster;n.GetCaster=function()return {}end;assert(m:GetModifierOverrideAbilitySpecial(p)==0);n.GetCaster=caster
hero.name='npc_dota_hero_lina';assert(m:GetModifierOverrideAbilitySpecial(p)==0)
`));
test('Shard HUD delegates native behavior and conditional costs on client without HasShard or server-only getters',()=>lua(`
local a=setmetatable({GetCaster=function()return hero end,GetLevel=function()return paid.rank end},{__index=enfos_storm_overload})
assert(a:GetBehavior()==2 and a:GetManaCost()==0 and a:GetCooldown()==0)
paid.rank=1;assert(integration.Restore(hero));server=false
assert(a:GetBehavior()==2 and a:GetAOERadius()==0)
n.shard=true;assert(a:GetBehavior()==8 and a:GetManaCost()==100 and a:GetCooldown()==30 and a:GetAOERadius()==750 and a:GetCastRange()==0)
hero.native=nil;assert(a:GetBehavior()==2 and a:GetManaCost()==0)
`));
test('Shard cast delegates once, synchronizes cooldown and refunds unavailable casts; client never restores',()=>lua(`
paid.rank=10;assert(integration.Restore(hero));local refunds,ends=0,0
local a=setmetatable({GetCaster=function()return hero end,GetLevel=function()return paid.rank end,IsNull=function()return false end,
EndCooldown=function()ends=ends+1 end,RefundManaCost=function()refunds=refunds+1 end,GetCooldownTimeRemaining=function()return 9 end},{__index=enfos_storm_overload})
a:OnSpellStart();assert(casts==0 and refunds==1 and ends==1)
n.shard=true;a:OnSpellStart();assert(casts==1 and n.cooldown==9 and n.charge==7)
server=false;package.loaded['abilities/heroes/storm_spirit/integration']=nil
package.preload['abilities/heroes/storm_spirit/integration']=function()error('client restoration')end
a:OnUpgrade();a:OnSpellStart();assert(casts==1 and adds==1)
`));
test('Shard ownership suppresses only Storm Mage amp; other Mage stays unchanged on both contexts',()=>lua(`
function LinkLuaModifier()end
local ownership=require('abilities/heroes/storm_spirit/ownership');assert(ownership.UsesNativeShard(hero));assert(not ownership.UsesNativeShard(nil))
require('heroes/aghanim_manager')
local m=setmetatable({GetParent=function()return hero end,role='Mage'},{__index=modifier_enfos_shard_upgrade})
for _,context in ipairs({true,false})do server=context;assert(m:IsHidden() and m:GetModifierSpellAmplify_Percentage()==0)end
hero.name='npc_dota_hero_lina';assert(not ownership.UsesNativeShard(hero));assert(not m:IsHidden() and m:GetModifierSpellAmplify_Percentage()==15)
`));
test('Automatic Health only reads native provider rank, actual intrinsic name and special queries',()=>lua(`
hero.GetLevel=function()return 6 end;hero.GetAbilityPoints=function()return 5 end;hero.IsAlive=function()return true end
assert(integration.Restore(hero));n.GetIntrinsicModifierName=function()return 'fixture_intrinsic'end
hero.FindModifierByName=function(_,name)assert(name=='fixture_intrinsic' or name=='modifier_enfos_storm_native_scaling');return {IsNull=function()return false end}end
n.GetSpecialValueFor=function(_,key)return ({overload_damage=0,overload_aoe=0,shard_activation_charges=0})[key]end
hero.AddAbility=function()error('Health grants')end;hero.AddNewModifier=function()error('Health mutates')end
local lines={};print=function(s)lines[#lines+1]=s end
local h=require('heroes/health');assert(h.Report(hero,0));local out=table.concat(lines,'|');assert(out:find('ability=storm_spirit_overload rank=0',1,true));assert(out:find('overload_intrinsic=fixture_intrinsic present=true',1,true))
server=false;local count=#lines;assert(not h.Report(hero,0) and #lines==count)
`));
test('Four locale descriptions and twelve mirrors use new canonical keys and native Shard values',()=>{
 for(const lang of ['english','turkish','russian','schinese']){const t=JSON.parse(fs.readFileSync('localization/'+lang+'.json','utf8')).Tokens;
 assert.ok(t.DOTA_Tooltip_Ability_enfos_storm_overload_Description.includes('{{overload_damage}}'));assert.ok(t.DOTA_Tooltip_Ability_enfos_storm_overload_shard_description.includes('750'));assert.equal(t.DOTA_Tooltip_Ability_enfos_storm_galvanic_core_shard_description,undefined);
 for(const dir of ['game/resource','game/panorama/localization','content/panorama/localization']){const s=fs.readFileSync(dir+'/addon_'+lang+'.txt','utf8');assert.doesNotMatch(s,/\{\{/);assert.ok(s.includes('25 / 40 / 55 / 70 / 85 / 100 / 120 / 140 / 165 / 190'));}
 }
});

test('Remnant is a pure native alias retaining verified dynamic point fields and ten-rank authored curves',()=>{
 const q=all.enfos_storm_static_remnant;assert.ok(isVerifiedNativeAbility('enfos_storm_static_remnant',q));assert.equal(q.ScriptFile,undefined);assert.equal(q.MaxLevel,'10');assert.equal(q.RequiredLevel,'1');assert.equal(q.LevelsBetweenUpgrades,'1');
 for(const key of ['AbilityBehavior','AbilityUnitDamageType','SpellImmunityType','FightRecapLevel','AbilitySound','AbilityCastPoint','AbilityCastAnimation'])assert.equal(q[key],remnant[key],key);
 for(const key of ['is_point_targeted','AbilityCastRange','static_remnant_travel_speed','static_remnant_delay','static_remnant_radius','static_remnant_vision_radius_day','static_remnant_vision_radius_night'])assert.deepEqual(JSON.parse(JSON.stringify(q.AbilityValues[key])),remnant.AbilityValues[key],key);
 assert.equal(q.AbilityValues.static_remnant_damage.value,'100 130 160 190 220 250 280 315 350 390');assert.equal(q.AbilityValues.intellect_factor,'1.2');assert.equal(q.AbilityDuration,'8 8.5 9 9.5 10 10.5 11 11.5 12 12');assert.equal(q.AbilityCooldown,'3.5 3.4 3.3 3.2 3.1 3.0 2.9 2.8 2.7 2.6');assert.equal(q.AbilityValues.AbilityCooldown.value,q.AbilityCooldown);assert.equal(q.AbilityManaCost,'70 75 80 85 90 95 100 105 110 115');
 assert.equal(q.AbilityValues.static_remnant_damage_radius.affected_by_aoe_increase,remnant.AbilityValues.static_remnant_damage_radius.affected_by_aoe_increase);assert.equal(q.AbilityValues.static_remnant_damage_radius.DamageTypeTooltip,remnant.AbilityValues.static_remnant_damage_radius.DamageTypeTooltip);
 const radius=q.AbilityValues.static_remnant_damage_radius.value.split(' ').map(Number);assert.equal(radius.length,10);assert.deepEqual(radius,[240,250,260,270,280,290,300,310,320,330]);assert.ok(radius.every(r=>r>Number(q.AbilityValues.static_remnant_radius.value)));
 assert.equal(all.storm_spirit_static_remnant,undefined);
 const kits=fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8');assert.doesNotMatch(kits,/enfos_storm_static_remnant=class|modifier_enfos_storm_static_remnant_thinker/);
 const row=JSON.parse(fs.readFileSync('docs/audit/HERO_ABILITY_CONTRACTS.json','utf8')).heroes.find(x=>x.id==='npc_dota_hero_storm_spirit').abilities.find(x=>x.id==='enfos_storm_static_remnant');assert.equal(row.implementationOwner,'NATIVE');assert.equal(row.engineAcceptance,'PENDING OWNER TEST');
});

test('Q raw native damage scales through rank ten on both contexts; Break/death do not disable this active spell or alter Overload',()=>lua(`
assert(integration.Restore(hero));local m=hero.mod
local q={rank=0,null=false,IsNull=function(self)return self.null end,GetLevel=function(self)return self.rank end,
GetCaster=function()return hero end,GetAbilityName=function()return 'enfos_storm_static_remnant'end,
GetLevelSpecialValueNoOverride=function(self,key,rank)assert(rank==self.rank-1);if key=='intellect_factor' then return 1.2 end;assert(key=='static_remnant_damage');return ({100,130,160,190,220,250,280,315,350,390})[rank+1]end,
GetSpecialValueFor=function()error('recursive Q query')end}
local p={ability=q,ability_special_value='static_remnant_damage'}
assert(m:GetModifierOverrideAbilitySpecial(p)==1 and m:GetModifierOverrideAbilitySpecialValue(p)==0)
hero.PassivesDisabled=function()error('Break cannot suppress active Q damage')end
for _,context in ipairs({true,false})do server=context;for rank=1,10 do q.rank=rank;assert(m:GetModifierOverrideAbilitySpecialValue(p)==q:GetLevelSpecialValueNoOverride('static_remnant_damage',rank-1)+120)end end
hero.int=150;assert(m:GetModifierOverrideAbilitySpecialValue(p)==570);assert(n.charge==7 and n.rank==0 and adds==1 and mods==1)
for _,key in ipairs({'static_remnant_radius','static_remnant_damage_radius','AbilityCooldown','is_point_targeted'})do p.ability_special_value=key;assert(m:GetModifierOverrideAbilitySpecial(p)==0)end
p.ability_special_value='static_remnant_damage';q.GetCaster=function()return {}end;assert(m:GetModifierOverrideAbilitySpecial(p)==0)
`));

test('Native Q Health queries remain read-only even when the native special returns zero',()=>lua(`
assert(integration.Restore(hero));local lookup=hero.FindAbilityByName
local q={IsNull=function()return false end,GetLevel=function()return 0 end,
GetIntrinsicModifierName=function()return ''end,GetSpecialValueFor=function(_,key)return ({static_remnant_damage=0,static_remnant_radius=235,static_remnant_damage_radius=240,is_point_targeted=1})[key]end}
hero.FindAbilityByName=function(self,id)if id=='enfos_storm_static_remnant' then return q end;return lookup(self,id)end
hero.GetLevel=function()return 6 end;hero.GetAbilityPoints=function()return 5 end;hero.IsAlive=function()return true end
n.GetIntrinsicModifierName=function()return ''end;n.GetSpecialValueFor=function()return 0 end
hero.AddAbility=function()error('Health grants')end;hero.AddNewModifier=function()error('Health mutates')end
local out={};print=function(s)out[#out+1]=s end;assert(require('heroes/health').Report(hero,0))
assert(table.concat(out,'|'):find('native_remnant_damage_query=0 native_remnant_trigger_query=235 native_remnant_damage_radius_query=240 native_remnant_point_query=1',1,true))
`));

test('Native remnant text uses verified point, arming, trigger/damage and duration keys in four locales and twelve mirrors',()=>{
 for(const lang of ['english','turkish','russian','schinese']){const t=JSON.parse(fs.readFileSync('localization/'+lang+'.json','utf8')).Tokens;
 const desc=t.DOTA_Tooltip_Ability_enfos_storm_static_remnant_Description;
 for(const key of ['AbilityDuration','static_remnant_delay','static_remnant_radius','static_remnant_damage','static_remnant_damage_radius','intellect_factor'])assert.ok(desc.includes('{{'+key+'}}'),key);
 for(const dir of ['game/resource','game/panorama/localization','content/panorama/localization']){const s=fs.readFileSync(dir+'/addon_'+lang+'.txt','utf8');assert.doesNotMatch(s,/\{\{/);assert.ok(s.includes('100 / 130 / 160 / 190 / 220 / 250 / 280 / 315 / 350 / 390'));}
 }
});

test('Vortex is a complete native alias with ten-rank tuning and conditional Scepter radius; no copied stun or absorb',()=>{
 const w=all.enfos_storm_electric_vortex,n=JSON.parse(fs.readFileSync('docs/audit/STORM_SPIRIT_NATIVE_SOURCE_2026-10-04.json','utf8')).abilities.storm_spirit_electric_vortex;
 assert.ok(isVerifiedNativeAbility('enfos_storm_electric_vortex',w));assert.equal(w.ScriptFile,undefined);assert.equal(w.MaxLevel,'10');assert.equal(w.RequiredLevel,'1');assert.equal(w.LevelsBetweenUpgrades,'1');
 for(const key of ['AbilityBehavior','AbilityUnitTargetTeam','AbilityUnitTargetType','SpellImmunityType','SpellDispellableType','FightRecapLevel','HasScepterUpgrade','AbilitySound','AbilityCastPoint','AbilityCastAnimation'])assert.equal(w[key],n[key],key);
 for(const key of ['electric_vortex_pull_tether_range','electric_vortex_self_slow','electric_vortex_self_slow_duration','radius_scepter','enemy_overload_duration'])assert.deepEqual(JSON.parse(JSON.stringify(w.AbilityValues[key])),n.AbilityValues[key],key);
 assert.equal(w.AbilityValues.radius_scepter.value,undefined);assert.equal(w.AbilityValues.radius_scepter.special_bonus_scepter,'475');assert.equal(w.AbilityDuration,'0.8 1 1.2 1.4 1.6 1.8 2 2.2 2.4 2.6');assert.equal(w.AbilityValues.AbilityDuration.value,w.AbilityDuration);assert.equal(w.AbilityCooldown,'16 15 14 13 12 11 10 9 8 7');assert.equal(w.AbilityManaCost,'80 90 100 110 120 130 140 150 160 170');assert.equal(w.AbilityCastRange,'450');
 const pull=w.AbilityValues.electric_vortex_pull_distance.split(' ').map(Number);assert.equal(pull.length,10);for(let i=0;i<10;i++)assert.ok(Math.abs(pull[i]-(180+120*i/9))<.051);
 for(const key of ['radius','duration','boss_duration'])assert.equal(w.AbilityValues[key],undefined);assert.equal(all.enfos_storm_ball_lightning.HasScepterUpgrade,undefined);assert.equal(all.storm_spirit_electric_vortex,undefined);
 assert.doesNotMatch(fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8'),/enfos_storm_electric_vortex=class|modifier_enfos_storm_electric_vortex_debuff/);
});

test('Scepter ownership replaces generic R amp/CDR only for Storm kit, safely on client and when native W is untrained',()=>lua(`
local lookup=hero.FindAbilityByName;local w={IsNull=function()return false end}
hero.FindAbilityByName=function(self,id)if id=='enfos_storm_electric_vortex' then return w end;return lookup(self,id)end
function LinkLuaModifier()end;require('heroes/aghanim_manager');local owner=require('abilities/heroes/storm_spirit/ownership')
local m=setmetatable({GetParent=function()return hero end},{__index=modifier_enfos_scepter_upgrade})
for _,context in ipairs({true,false})do server=context;assert(owner.UsesNativeScepter(hero));assert(m:IsHidden());assert(m:GetModifierSpellAmplify_Percentage({})==0 and m:GetModifierPercentageCooldown({})==0)end
w.IsNull=function()return true end;assert(not owner.UsesNativeScepter(hero));assert(not owner.UsesNativeScepter(nil));w.IsNull=function()return false end
hero.name='npc_dota_hero_lina';DOTA_ABILITY_TYPE_ULTIMATE=1;local r={GetAbilityType=function()return 1 end}
assert(not owner.UsesNativeScepter(hero));assert(not m:IsHidden());assert(m:GetModifierSpellAmplify_Percentage({inflictor=r})==40 and m:GetModifierPercentageCooldown({ability=r})==25)
`));

test('Vortex Health reads real pull/duration/conditional Scepter values without repair or extra native grants',()=>lua(`
local lookup=hero.FindAbilityByName;local w={IsNull=function()return false end,GetLevel=function()return 0 end,GetIntrinsicModifierName=function()return ''end,
GetSpecialValueFor=function(_,key)return ({electric_vortex_pull_distance=180,AbilityDuration=.8,radius_scepter=0})[key]end}
hero.FindAbilityByName=function(self,id)if id=='enfos_storm_electric_vortex' then return w end;return lookup(self,id)end
hero.GetLevel=function()return 6 end;hero.GetAbilityPoints=function()return 5 end;hero.IsAlive=function()return true end
hero.AddAbility=function()error('Health native grant')end;hero.AddNewModifier=function()error('Health mutation')end
local out={};print=function(s)out[#out+1]=s end;assert(require('heroes/health').Report(hero,0));assert(table.concat(out,'|'):find('native_vortex_pull_query=180 native_vortex_duration_query=0.8 native_vortex_scepter_radius_query=0',1,true))
`));

test('Vortex localization describes pull and Scepter, retires the generic R upgrade in all locales/mirrors',()=>{
 for(const lang of ['english','turkish','russian','schinese']){const t=JSON.parse(fs.readFileSync('localization/'+lang+'.json','utf8')).Tokens;
 const desc=t.DOTA_Tooltip_Ability_enfos_storm_electric_vortex_Description;assert.ok(desc.includes('{{AbilityDuration}}')&&desc.includes('{{electric_vortex_pull_distance}}'));assert.ok(t.DOTA_Tooltip_Ability_enfos_storm_electric_vortex_scepter_description.includes('475'));assert.equal(t.DOTA_Tooltip_Ability_enfos_storm_ball_lightning_scepter_description,undefined);
 for(const dir of ['game/resource','game/panorama/localization','content/panorama/localization']){const s=fs.readFileSync(dir+'/addon_'+lang+'.txt','utf8');assert.doesNotMatch(s,/\{\{/);assert.ok(s.includes('180 / 193.3 / 206.7 / 220 / 233.3 / 246.7 / 260 / 273.3 / 286.7 / 300'));}
 }
});

test('Ball Lightning uses exact native flight/root/self/optional-target fields and named percentage mana keys, not copied teleport or Boss cap',()=>{
 const r=all.enfos_storm_ball_lightning,n=JSON.parse(fs.readFileSync('docs/audit/STORM_SPIRIT_NATIVE_SOURCE_2026-10-04.json','utf8')).abilities.storm_spirit_ball_lightning;
 assert.ok(isVerifiedNativeAbility('enfos_storm_ball_lightning',r));assert.equal(r.ScriptFile,undefined);assert.equal(r.MaxLevel,'10');assert.equal(r.RequiredLevel,'5');assert.equal(r.LevelsBetweenUpgrades,'5');assert.equal(r.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');assert.equal(r.HasScepterUpgrade,undefined);
 for(const key of ['AbilityBehavior','AbilityUnitDamageType','SpellImmunityType','AbilitySound','AbilityCastPoint','AbilityCastAnimation','AbilityManaCost'])assert.equal(r[key],n[key],key);
 for(const key of ['ball_lightning_initial_mana_base','ball_lightning_initial_mana_percentage','ball_lightning_travel_cost_percent','ball_lightning_vision_radius','blocker_duration','scepter_remnant_interval','auto_remnant_interval'])assert.deepEqual(JSON.parse(JSON.stringify(r.AbilityValues[key])),n.AbilityValues[key],key);
 assert.equal(r.AbilityDamage,'35 40 45 50 55 60 65 70 75 80');assert.equal(r.AbilityValues.intellect_factor,'0.1');assert.equal(r.AbilityValues.ball_lightning_travel_cost_base,'18 17 16 15 14 13 12 11 10 9');assert.equal(r.AbilityValues.ball_lightning_move_speed,'1400 1500 1600 1700 1800 1900 2000 2100 2200 2300');assert.equal(r.AbilityValues.ball_lightning_aoe.value,'240 250 260 270 280 290 300 310 320 330');assert.equal(r.AbilityValues.ball_lightning_aoe.affected_by_aoe_increase,'1');
 assert.equal(r.AbilityCastRange,undefined);for(const key of ['max_distance','boss_damage_cap_pct','damage_per_100','mana_per_100'])assert.equal(r.AbilityValues[key],undefined,key);assert.equal(all.storm_spirit_ball_lightning,undefined);
 assert.doesNotMatch(fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8'),/enfos_storm_ball_lightning=class/);
 const m=fs.readFileSync('game/scripts/vscripts/abilities/heroes/storm_spirit/modifiers.lua','utf8');assert.doesNotMatch(m,/ApplyDamage|SpendMana|FindClearSpace|GetAbsOrigin|FindUnits|CreateParticle|StartIntervalThink/);
});

test('R outgoing multiplier preserves authored INT coefficient at all ranks for a proportional native input without calculating flight or adding damage',()=>lua(`
assert(integration.Restore(hero));local m=hero.mod;local base=0;local a={rank=0,null=false,
IsNull=function(self)return self.null end,GetCaster=function()return hero end,GetAbilityName=function()return 'enfos_storm_ball_lightning'end,
GetLevel=function(self)return self.rank end,GetAbilityDamage=function()assert(server);return base end,
GetSpecialValueFor=function(_,key)assert(key=='intellect_factor');return .1 end}
local p={inflictor=a,original_damage=100};assert(m:GetModifierTotalDamageOutgoing_Percentage(p)==0)
for rank=1,10 do a.rank=rank;base=35+5*(rank-1)
local percent=m:GetModifierTotalDamageOutgoing_Percentage(p);assert(math.abs(percent-100*100*.1/base)<.000001)
for _,multiple in ipairs({1,5,10})do local original=base*multiple
assert(math.abs(original*(1+percent/100)-(base+10)*multiple)<.000001)end end
hero.int=150;assert(math.abs(m:GetModifierTotalDamageOutgoing_Percentage(p)-18.75)<.000001)
base=0;assert(m:GetModifierTotalDamageOutgoing_Percentage(p)==0);base=80
hero.illusion=true;assert(m:GetModifierTotalDamageOutgoing_Percentage(p)==0);hero.illusion=false
a.GetCaster=function()return {}end;assert(m:GetModifierTotalDamageOutgoing_Percentage(p)==0);a.GetCaster=function()return hero end
a.GetAbilityName=function()return 'enfos_storm_electric_vortex'end;assert(m:GetModifierTotalDamageOutgoing_Percentage(p)==0)
server=false;a.GetAbilityDamage=function()error('client header query')end;assert(m:GetModifierTotalDamageOutgoing_Percentage(p)==0)
assert(n.charge==7 and adds==1 and mods==1)
`));

test('R Health exposes server header and percentage mana inputs without manually consuming mana or starting flight',()=>lua(`
local lookup=hero.FindAbilityByName;local r={IsNull=function()return false end,GetLevel=function()return 1 end,
GetIntrinsicModifierName=function()return ''end,GetAbilityDamage=function()assert(server);return 35 end,
GetSpecialValueFor=function(_,key)return ({ball_lightning_initial_mana_base=25,ball_lightning_initial_mana_percentage=7.5,ball_lightning_travel_cost_base=18,ball_lightning_travel_cost_percent=.65})[key]end}
hero.FindAbilityByName=function(self,id)if id=='enfos_storm_ball_lightning' then return r end;return lookup(self,id)end
hero.GetLevel=function()return 6 end;hero.GetAbilityPoints=function()return 5 end;hero.IsAlive=function()return true end
hero.AddAbility=function()error('Health grants')end;hero.AddNewModifier=function()error('Health mutates')end;hero.SpendMana=function()error('Health mana')end
local out={};print=function(s)out[#out+1]=s end;local h=require('heroes/health');assert(h.Report(hero,0));assert(table.concat(out,'|'):find('native_ball_damage_getter=35 native_ball_initial_base_query=25 native_ball_initial_pct_query=7.5 native_ball_travel_base_query=18 native_ball_travel_pct_query=0.65',1,true))
server=false;local count=#out;assert(not h.Report(hero,0) and #out==count)
`));

test('Native R four-locale text and twelve mirrors resolve damage header and actual named mana fields',()=>{
 for(const lang of ['english','turkish','russian','schinese']){const t=JSON.parse(fs.readFileSync('localization/'+lang+'.json','utf8')).Tokens,desc=t.DOTA_Tooltip_Ability_enfos_storm_ball_lightning_Description;
 for(const key of ['AbilityDamage','intellect_factor','ball_lightning_aoe','ball_lightning_initial_mana_base','ball_lightning_initial_mana_percentage','ball_lightning_travel_cost_base','ball_lightning_travel_cost_percent'])assert.ok(desc.includes('{{'+key+'}}'),key);
 for(const dir of ['game/resource','game/panorama/localization','content/panorama/localization']){const s=fs.readFileSync(dir+'/addon_'+lang+'.txt','utf8');assert.doesNotMatch(s,/\{\{/);assert.ok(s.includes('35 / 40 / 45 / 50 / 55 / 60 / 65 / 70 / 75 / 80'));}
 }
});
