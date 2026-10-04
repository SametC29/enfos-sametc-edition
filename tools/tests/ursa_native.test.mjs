import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';
import {isVerifiedNativeAbility} from '../lib/native_hero_abilities.mjs';
const all=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
const r=all.enfos_ursa_enrage;
const snapshot=JSON.parse(fs.readFileSync('docs/audit/URSA_NATIVE_SOURCE_2026-10-04.json','utf8'));

test('Enrage uses installed native cast, dispel, immunity and effects with no Lua replica',()=>{
 const native=snapshot.abilities.ursa_enrage;
 assert.ok(isVerifiedNativeAbility('enfos_ursa_enrage',r));assert.equal(r.ScriptFile,undefined);
 for(const k of ['AbilityBehavior','SpellImmunityType','SpellDispellableType','FightRecapLevel','HasScepterUpgrade','AbilitySound','AbilityCastAnimation','AbilityCastGestureSlot','AbilityCastRange'])assert.equal(r[k],native[k],k);
 assert.equal(r.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
 assert.equal(r.MaxLevel,'10');assert.equal(r.RequiredLevel,'5');assert.equal(r.LevelsBetweenUpgrades,'5');
 const source=fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8');
 assert.doesNotMatch(source,/enfos_ursa_enrage=class|modifier_enfos_ursa_enrage_buff/);
 assert.equal(all.ursa_enrage,undefined,'No shadowing the native ID');
 const heroes=parseKV(fs.readFileSync('game/scripts/npc/npc_heroes_custom.txt','utf8')).DOTAHeroes;
 assert.equal(heroes.npc_dota_hero_ursa.Ability4,'enfos_ursa_enrage');
});

test('Enrage exposes full ten-rank tuning and explicit Scepter cooldown without deprecated facet grants',()=>{
 assert.equal(r.AbilityValues.AbilityCooldown.value,r.AbilityCooldown);
 const enhanced=r.AbilityValues.AbilityCooldown.special_bonus_scepter.split(' ').map(x=>Number(x.slice(1)));
 const native=snapshot.abilities.ursa_enrage.AbilityValues.AbilityCooldown.special_bonus_scepter.split(' ').map(x=>Number(x.slice(1)));
 assert.equal(enhanced.length,10);assert.equal(enhanced[0],native[0]);assert.equal(enhanced[9],native[2]);
 for(let i=1;i<10;i++){assert.ok(enhanced[i]<=enhanced[i-1]);assert.ok(Math.abs(enhanced[i]-(30-12*i/9))<0.051);}
 assert.equal(r.AbilityValues.duration,'4.5 4.8 5.1 5.4 5.7 6 6.4 6.8 7.4 8');
 assert.equal(r.AbilityValues.damage_reduction,'60 63 66 69 72 75 78 82 86 90');
 assert.equal(r.AbilityValues.status_resistance,'20 24 28 32 36 40 44 48 54 60');
 assert.equal(r.AbilityValues.damage_increase,'0');assert.equal(r.AbilityValues.damage_increase_duration,'0');
 assert.equal(r.AbilityValues.aoe_radius.value,'0');assert.equal(r.AbilityManaCost,'0');
 assert.doesNotMatch(JSON.stringify(r),/special_bonus_facet|special_bonus_unique|DependentOnAbility/);
});

test('Native Enrage ownership is client-safe, scoped and suppresses only generic Enfos ultimate bonuses',()=>{
 const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{encoding:'utf8',input:`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
function LinkLuaModifier()end
function IsServer()return false end
DOTA_ABILITY_TYPE_ULTIMATE=1
local Ownership=require('abilities/heroes/ursa/ownership')
local ability={null=false,IsNull=function(self)return self.null end,GetAbilityType=function()return 1 end}
local hero={name='npc_dota_hero_ursa',has=true,null=false,
 IsNull=function(self)return self.null end,GetUnitName=function(self)return self.name end,
 FindAbilityByName=function(self,id)assert(id=='enfos_ursa_enrage');if self.has then return ability end end,
 IsAlive=function()error('Server-only getter')end,AddNewModifier=function()error('Read-only ownership')end,
 AddAbility=function()error('Read-only ownership')end}
assert(Ownership.UsesNativeScepter(hero));assert(not Ownership.UsesNativeScepter(nil));assert(not Ownership.UsesNativeScepter({}))
hero.null=true;assert(not Ownership.UsesNativeScepter(hero));hero.null=false
ability.null=true;assert(not Ownership.UsesNativeScepter(hero));ability.null=false
hero.has=false;assert(not Ownership.UsesNativeScepter(hero));hero.has=true
hero.name='npc_dota_hero_axe';assert(not Ownership.UsesNativeScepter(hero));hero.name='npc_dota_hero_ursa'
require('heroes/aghanim_manager')
local m=setmetatable({GetParent=function()return hero end},modifier_enfos_scepter_upgrade)
assert(m:IsHidden());assert(m:GetModifierSpellAmplify_Percentage({inflictor=ability})==0)
assert(m:GetModifierPercentageCooldown({ability=ability})==0)
hero.has=false;assert(not m:IsHidden());assert(m:GetModifierSpellAmplify_Percentage({inflictor=ability})==40)
assert(m:GetModifierPercentageCooldown({ability=ability})==25)
hero.name='npc_dota_hero_axe';assert(m:GetModifierSpellAmplify_Percentage({inflictor=ability})==40)
assert(m:GetModifierPercentageCooldown({ability=ability})==25)
assert(not package.loaded['abilities/heroes/ursa/integration'],'No server integration loaded by client ownership')
`});assert.equal(result.status,0,result.stderr);assert.equal(result.stderr,'');
});

test('All locales describe native strong dispel and disabled-cast Scepter without the obsolete generic bonuses',()=>{
 for(const lang of ['english','turkish','russian','schinese']){
 const tokens=JSON.parse(fs.readFileSync('localization/'+lang+'.json','utf8')).Tokens;
 const upgrade=tokens.DOTA_Tooltip_Ability_enfos_ursa_enrage_scepter_description;
 assert.match(upgrade,/30–18/);assert.doesNotMatch(upgrade,/40|25/);
 assert.ok(tokens.DOTA_Tooltip_Ability_enfos_ursa_enrage_Description.includes('{{status_resistance}}'));
 for(const prefix of ['game/resource','game/panorama/localization','content/panorama/localization']){
 const t=parseKV(fs.readFileSync(prefix+'/addon_'+lang+'.txt','utf8')).lang.Tokens;
 assert.equal(t.DOTA_Tooltip_Ability_enfos_ursa_enrage_scepter_description,upgrade);
 }
 }
 assert.ok(snapshot.resources.some(x=>x.path.endsWith('ursa_enrage_buff.vpcf_c')&&x.status==='FILE_VERIFIED'));
 assert.ok(fs.readFileSync('game/scripts/vscripts/addon_game_mode.lua','utf8').includes('hero_ursa/ursa_enrage_buff.vpcf'));
});

test('Paid Fury uses an exact native provider with native metadata and no copied attacks, caps or radial damage',()=>{
 const e=all.enfos_ursa_fury_swipes,n=snapshot.abilities.ursa_fury_swipes;
 assert.equal(e.BaseClass,'ability_lua');assert.equal(e.ScriptFile,'abilities/heroes/ursa/e');
 for(const k of ['AbilityBehavior','AbilityUnitDamageType','SpellImmunityType','SpellDispellableType','IsBreakable'])assert.equal(e[k],n[k]);
 assert.equal(e.MaxLevel,'10');assert.equal(e.RequiredLevel,'1');assert.equal(e.LevelsBetweenUpgrades,'1');
 assert.equal(e.AbilityValues.damage_per_stack,'20 28 36 44 52 60 68 76 84 92');
 assert.equal(e.AbilityValues.bonus_reset_time,'6 6.4 6.8 7.2 7.6 8 8.4 8.8 9.4 10');
 assert.equal(e.AbilityValues.bonus_reset_time_roshan,n.AbilityValues.bonus_reset_time_roshan);
 assert.equal(e.AbilityValues.stun_stack_count,n.AbilityValues.stun_stack_count.value);
 assert.equal(e.AbilityValues.stun_duration,n.AbilityValues.stun_duration.value);
 for(const k of ['max_stacks','boss_max_stacks','cleave_radius','cleave_pct','bonus_damage','debuff_duration'])assert.equal(e.AbilityValues[k],undefined);
 assert.equal(all.ursa_fury_swipes,undefined);
 const shared=fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8');
 assert.doesNotMatch(shared,/modifier_enfos_ursa_fury_swipes_|enfos_ursa_fury_swipes=class/);
 for(const module of ['modifiers','integration','e']){
 const source=fs.readFileSync('game/scripts/vscripts/abilities/heroes/ursa/'+module+'.lua','utf8');
 assert.doesNotMatch(source,/ApplyDamage|FindUnits|OnAttackLanded|SetStackCount|SetDuration|CreateParticle|EmitSound|StartIntervalThink|CreateTimer|is_boss/);
 }
});

const furySetup=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
local server=true;function IsServer()return server end
local links={};function LinkLuaModifier(n,p)assert(p=='abilities/heroes/ursa/modifiers');links[n]=true end
LUA_MODIFIER_MOTION_NONE=0
local paid={rank=0,null=false,IsNull=function(self)return self.null end,
 GetLevel=function(self)return self.rank end,
 GetLevelSpecialValueNoOverride=function(self,k,rank)
  assert(k~='bonus_damage');assert(rank==self.rank-1)
  local data={damage_per_stack={20,28,36,44,52,60,68,76,84,92},bonus_reset_time={6,6.4,6.8,7.2,7.6,8,8.4,8.8,9.4,10},
   agility_factor={.15},bonus_reset_time_roshan={8},stun_stack_count={0},stun_duration={0}}
  local list=data[k];assert(list,k);return list[rank+1] or list[1]
 end,
 GetSpecialValueFor=function()error('Recursive lookup')end}
local adds,mods,refreshes,sets=0,0,0,0
local native={rank=0,hidden=false,active=false,null=false,target_stack_count=17,
 IsNull=function(self)return self.null end,GetLevel=function(self)return self.rank end,
 GetAbilityName=function()return 'ursa_fury_swipes'end,
 SetLevel=function(self,v)assert(server and (v==0 or v==1));sets=sets+1;self.rank=v end,
 SetHidden=function(self,v)assert(server);self.hidden=v end,
 SetActivated=function(self,v)assert(server);self.active=v end,
 GetIntrinsicModifierName=function()assert(server);return 'native_fury_fixture'end}
local hero={agi=100,points=5,name='npc_dota_hero_ursa',null=false,illusion=false,real=true,broken=false,
 abilities={enfos_ursa_fury_swipes=paid},modifiers={},
 GetUnitName=function(self)return self.name end,IsNull=function(self)return self.null end,
 IsRealHero=function(self)return self.real end,IsIllusion=function(self)return self.illusion end,
 PassivesDisabled=function(self)return self.broken end,GetAgility=function(self)return self.agi end,
 IsAlive=function()error('Server-only getter must not be used')end,
 HasModifier=function(self,id)assert(server);return self.modifiers[id]~=nil end,
 FindAbilityByName=function(self,id)return self.abilities[id]end,
 FindModifierByName=function(self,id)assert(server);return self.modifiers[id]end,
 AddAbility=function(self,id)assert(server and id=='ursa_fury_swipes');assert(self.modifiers.modifier_enfos_ursa_native_scaling);adds=adds+1;self.abilities[id]=native;return native end,
 AddNewModifier=function(self,c,a,id)assert(server and c==self and a==paid);mods=mods+1;local m=setmetatable({IsNull=function()return false end,GetParent=function()return self end},modifier_enfos_ursa_native_scaling);self.modifiers[id]=m;return m end}
native.GetCaster=function()return hero end
local integration=require('abilities/heroes/ursa/integration')
local intrinsic={IsNull=function()return false end,ForceRefresh=function()assert(server);refreshes=refreshes+1 end}
hero.modifiers.native_fury_fixture=intrinsic
`;
function furyLua(t){const p=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{encoding:'utf8',input:furySetup+t});assert.equal(p.status,0,p.stderr);assert.equal(p.stderr,'');}

test('Native Fury restore is idempotent, bounded and installs tuning before provider without points or target-state changes',()=>furyLua(`
assert(integration.Restore(hero));assert(adds==1 and mods==1 and native.rank==0 and not native.active and native.hidden)
assert(integration.Restore(hero));assert(adds==1 and mods==1 and sets==0 and refreshes==0)
paid.rank=1;assert(integration.RefreshFury(hero));assert(native.rank==1 and native.active and sets==1 and refreshes==1)
for rank=2,10 do paid.rank=rank;assert(integration.RefreshFury(hero)) end
assert(adds==1 and mods==1 and sets==1 and refreshes==10 and hero.points==5 and native.target_stack_count==17)
assert(integration.Restore(hero));assert(refreshes==10 and sets==1,'Lifecycle restore must not refresh an existing intrinsic')
hero.modifiers.native_fury_fixture=nil;assert(not integration.RefreshFury(hero));assert(native.target_stack_count==17 and hero.points==5)
hero.null=true;assert(not integration.Restore(hero));hero.null=false
hero.illusion=true;assert(not integration.Restore(hero));hero.illusion=false
hero.real=false;assert(not integration.Restore(hero));hero.real=true
hero.name='npc_dota_hero_axe';assert(not integration.Restore(hero));hero.name='npc_dota_hero_ursa'
server=false;assert(not integration.Restore(hero));assert(not integration.RefreshFury(hero))
`));

test('Fury paid bridge covers all ranks and live AGI on client/server while retaining native Break effects and rejecting foreign queries',()=>furyLua(`
assert(integration.Restore(hero));local m=hero.modifiers.modifier_enfos_ursa_native_scaling
local p={ability=native,ability_special_value='damage_per_stack'}
assert(m:GetModifierOverrideAbilitySpecial(p)==1 and m:GetModifierOverrideAbilitySpecialValue(p)==0)
for _,scope in ipairs({true,false})do server=scope
 for rank=1,10 do paid.rank=rank
  for _,agi in ipairs({0,100,250})do hero.agi=agi
   assert(m:GetModifierOverrideAbilitySpecialValue(p)==20+(rank-1)*8+agi*.15)
  end
 end
end
paid.rank=10;hero.agi=100;hero.broken=true
assert(m:GetModifierOverrideAbilitySpecialValue(p)==107,'Break must not zero the effects of existing native stacks')
for _,k in ipairs({'bonus_reset_time','bonus_reset_time_roshan','stun_stack_count','stun_duration'})do
 p.ability_special_value=k;assert(m:GetModifierOverrideAbilitySpecial(p)==1)
 assert(m:GetModifierOverrideAbilitySpecialValue(p)==({bonus_reset_time=10,bonus_reset_time_roshan=8,stun_stack_count=0,stun_duration=0})[k])end
p.ability_special_value='not_a_fury_key';assert(m:GetModifierOverrideAbilitySpecial(p)==0 and m:GetModifierOverrideAbilitySpecialValue(p)==0)
p.ability_special_value='damage_per_stack';native.GetCaster=function()return {}end
assert(m:GetModifierOverrideAbilitySpecial(p)==0);native.GetCaster=function()return hero end
native.GetAbilityName=function()return 'enfos_ursa_overpower'end;assert(m:GetModifierOverrideAbilitySpecial(p)==0)
native.GetAbilityName=function()return 'ursa_fury_swipes'end
paid.null=true;assert(m:GetModifierOverrideAbilitySpecialValue(p)==0);paid.null=false
native.null=true;assert(m:GetModifierOverrideAbilitySpecial(p)==0);native.null=false
hero.null=true;assert(m:GetModifierOverrideAbilitySpecialValue(p)==0);hero.null=false
assert(m:GetModifierOverrideAbilitySpecial(nil)==0 and m:GetModifierOverrideAbilitySpecialValue(nil)==0)
assert(m:GetModifierOverrideAbilitySpecial({})==0)
`));

test('Fury failed provider/modifier creation cannot report readiness and client rank-up never imports restoration',()=>furyLua(`
hero.AddNewModifier=function()return nil end;assert(not integration.Restore(hero));assert(adds==0)
hero.modifiers.modifier_enfos_ursa_native_scaling={};hero.AddAbility=function()return nil end
assert(not integration.Restore(hero));assert(hero.points==5)
hero.abilities.ursa_fury_swipes=native;native.null=true;assert(not integration.Restore(hero))
package.loaded['abilities/heroes/ursa/integration']=nil
server=false;require('abilities/heroes/ursa/e')
local a=setmetatable({GetCaster=function()error('Client rank-up must return first')end},enfos_ursa_fury_swipes)
a:OnUpgrade();assert(not package.loaded['abilities/heroes/ursa/integration'])
assert(a:GetIntrinsicModifierName()=='modifier_enfos_ursa_native_scaling')
`));

test('Fury locales and mirrors retire cleave/cap claims and native resources stay explicitly precached',()=>{
 for(const lang of ['english','turkish','russian','schinese']){
 const tokens=JSON.parse(fs.readFileSync('localization/'+lang+'.json','utf8')).Tokens;
 const desc=tokens.DOTA_Tooltip_Ability_enfos_ursa_fury_swipes_Description;
 assert.ok(desc.includes('{{damage_per_stack}}')&&desc.includes('{{agility_factor}}')&&desc.includes('{{bonus_reset_time}}'));
 assert.doesNotMatch(desc,/max_stacks|boss_max_stacks|cleave_pct|bonus_damage|debuff_duration/);
 assert.equal(tokens.DOTA_Tooltip_modifier_enfos_ursa_fury_swipes_passive_Description,undefined);
 for(const prefix of ['game/resource','game/panorama/localization','content/panorama/localization']){
 const t=parseKV(fs.readFileSync(prefix+'/addon_'+lang+'.txt','utf8')).lang.Tokens;
 assert.doesNotMatch(t.DOTA_Tooltip_Ability_enfos_ursa_fury_swipes_Description,/\{\{|max_stacks|cleave_pct/);
 }
 }
 const precache=fs.readFileSync('game/scripts/vscripts/addon_game_mode.lua','utf8');
 for(const path of ['particles/units/heroes/hero_ursa/ursa_fury_swipes.vpcf','particles/units/heroes/hero_ursa/ursa_fury_swipes_debuff.vpcf']){
 assert.ok(precache.includes(path));assert.ok(snapshot.resources.some(x=>x.path===path+'_c'&&x.status==='FILE_VERIFIED'));
 }
});

test('Automatic Ursa health reads the native Fury provider without restoration or client-only server calls',()=>{
 const run=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{encoding:'utf8',input:`
package.path='game/scripts/vscripts/?.lua;'..package.path
local server=true;function IsServer()return server end
local lines={};print=function(v)lines[#lines+1]=v end
local native={IsNull=function()return false end,GetLevel=function()return 1 end,
 GetIntrinsicModifierName=function()assert(server);return 'native_fury_health_fixture'end,
 GetSpecialValueFor=function(_,key)assert(server and key=='damage_per_stack');return 107 end}
local h={IsNull=function()return false end,GetUnitName=function()return 'npc_dota_hero_ursa'end,
 GetLevel=function()return 6 end,GetAbilityPoints=function()return 5 end,IsAlive=function()assert(server);return true end,
 FindAbilityByName=function(_,id)if id=='ursa_fury_swipes'then return native end end,
 FindModifierByName=function(_,id)assert(server);if id=='native_fury_health_fixture'then return{IsNull=function()return false end}end end,
 AddAbility=function()error('Read-only health')end,AddNewModifier=function()error('Read-only health')end}
local Health=require('heroes/health');assert(Health.Report(h,0))
local s=table.concat(lines,'|');assert(s:find('ability=ursa_fury_swipes rank=1',1,true))
assert(s:find('fury_intrinsic=native_fury_health_fixture present=true',1,true))
assert(s:find('native_fury_damage_query=107',1,true))
local count=#lines;server=false;assert(not Health.Report(h,0) and #lines==count)
`});assert.equal(run.status,0,run.stderr);assert.equal(run.stderr,'');
});

test('Earthshock keeps the installed native hop/magic/Shard contract with authored ten-rank header curves',()=>{
 const q=all.enfos_ursa_earthshock,n=snapshot.abilities.ursa_earthshock;
 assert.ok(isVerifiedNativeAbility('enfos_ursa_earthshock',q));assert.equal(q.ScriptFile,undefined);
 for(const k of ['AbilityBehavior','AbilityUnitDamageType','SpellImmunityType','SpellDispellableType','FightRecapLevel','AbilitySound','HasShardUpgrade','AbilityCastAnimation','AbilityCastGestureSlot','AbilityCastRange'])assert.equal(q[k],n[k],k);
 assert.equal(q.MaxLevel,'10');assert.equal(q.RequiredLevel,'1');assert.equal(q.LevelsBetweenUpgrades,'1');assert.equal(q.AbilityCastPoint,'0');
 assert.equal(q.AbilityDamage,'120 180 240 300 360 420 480 540 600 660');
 assert.equal(q.AbilityDuration,'2.5 2.7 2.9 3.1 3.3 3.5 3.7 3.9 4.2 4.5');
 assert.equal(q.AbilityValues.AbilityCooldown.value,q.AbilityCooldown);assert.equal(q.AbilityValues.AbilityChargeRestoreTime.value,q.AbilityCooldown);
 assert.equal(q.AbilityValues.shock_radius.value,n.AbilityValues.shock_radius.value);assert.equal(q.AbilityValues.shock_radius.affected_by_aoe_increase,'1');
 assert.equal(q.AbilityValues.hop_distance,n.AbilityValues.hop_distance.value);assert.equal(q.AbilityValues.hop_duration,n.AbilityValues.hop_duration);assert.equal(q.AbilityValues.hop_height,n.AbilityValues.hop_height);
 assert.equal(q.AbilityValues.fury_swipe_stacks_on_hit.value,'0');assert.equal(q.AbilityValues.fury_swipe_stacks_on_hit.special_bonus_shard,n.AbilityValues.fury_swipe_stacks_on_hit.special_bonus_shard);
 assert.deepEqual(JSON.parse(JSON.stringify(q.AbilityValues.shard_enrage_duration)),n.AbilityValues.shard_enrage_duration);
 assert.equal(q.AbilityValues.movement_slow,'-20 -24 -28 -32 -36 -40 -44 -48 -52 -56');
 assert.equal(q.AbilityValues.AbilityCharges.value,'0');assert.equal(q.AbilityValues.strength_factor,'1.5');
 for(const k of ['AbilityDamage','damage','radius','slow_pct','slow_duration','boss_slow_duration'])assert.equal(q.AbilityValues[k],undefined);
 assert.doesNotMatch(JSON.stringify(q),/special_bonus_unique|facet/);
 const shared=fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8');assert.doesNotMatch(shared,/enfos_ursa_earthshock=class|modifier_enfos_ursa_earthshock_slow/);
});

test('Earthshock STR factor is server-only, scoped and has no duplicate damage or top-level special override',()=>{
 const q=all.enfos_ursa_earthshock;
 const p=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{encoding:'utf8',input:`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
local server=true;function IsServer()return server end
require('abilities/heroes/ursa/modifiers')
local rank,str,null,illusion,baseOverride=0,80,false,false,nil
local values={${q.AbilityDamage.split(' ').join(',')}}
local c={IsNull=function()return null end,IsIllusion=function()return illusion end,GetStrength=function()return str end,
 IsAlive=function()error('No client/server alive query')end,GetUnitName=function()return 'npc_dota_hero_ursa'end,
 FindAbilityByName=function()return nil end}
local owner=c;local name='enfos_ursa_earthshock'
local a={IsNull=function()return null end,GetAbilityName=function()return name end,GetCaster=function()return owner end,
 GetLevel=function()return rank end,GetAbilityDamage=function()assert(server,'Server-only GetAbilityDamage');return baseOverride or values[rank]end,
 GetSpecialValueFor=function(_,key)assert(key=='strength_factor');return 1.5 end}
local m=setmetatable({GetParent=function()return c end},modifier_enfos_ursa_native_scaling)
local event={inflictor=a,original_damage=660}
assert(m:GetModifierTotalDamageOutgoing_Percentage(event)==0)
for i=1,10 do rank=i;local pct=m:GetModifierTotalDamageOutgoing_Percentage(event)
 assert(math.abs(values[i]*(1+pct/100)-(values[i]+120))<.0001)
end
str=120;assert(math.abs(m:GetModifierTotalDamageOutgoing_Percentage(event)-18000/660)<.0001)
for _,other in ipairs({'ursa_enrage','ursa_fury_swipes','enfos_ursa_enrage','item_dagon','attack'})do name=other;assert(m:GetModifierTotalDamageOutgoing_Percentage(event)==0)end
name='enfos_ursa_earthshock';owner={};assert(m:GetModifierTotalDamageOutgoing_Percentage(event)==0);owner=c
illusion=true;assert(m:GetModifierTotalDamageOutgoing_Percentage(event)==0);illusion=false
baseOverride=0;assert(m:GetModifierTotalDamageOutgoing_Percentage(event)==0);baseOverride=-1;assert(m:GetModifierTotalDamageOutgoing_Percentage(event)==0);baseOverride=nil
null=true;assert(m:GetModifierTotalDamageOutgoing_Percentage(event)==0);null=false
assert(m:GetModifierTotalDamageOutgoing_Percentage(nil)==0 and m:GetModifierTotalDamageOutgoing_Percentage({})==0)
assert(m:GetModifierOverrideAbilitySpecial({ability=a,ability_special_value='AbilityDamage'})==0)
server=false;assert(m:GetModifierTotalDamageOutgoing_Percentage(event)==0)
`});assert.equal(p.status,0,p.stderr);assert.equal(p.stderr,'');
});

test('Q/R exact Enrage compatibility restores once without casts, extra points or native target-state changes',()=>furyLua(`
local q={IsNull=function()return false end}
local r={rank=0,IsNull=function()return false end,GetLevel=function(self)return self.rank end,
 GetLevelSpecialValueNoOverride=function(self,key,rank)assert(rank==self.rank-1)
 local values={duration={4.5,4.8,5.1,5.4,5.7,6,6.4,6.8,7.4,8},damage_reduction={60,63,66,69,72,75,78,82,86,90},
 status_resistance={20,24,28,32,36,40,44,48,54,60},aoe_radius={0},damage_increase={0},damage_increase_duration={0}}
 local v=values[key];assert(v,key);return v[rank+1] or v[1] end,
 GetSpecialValueFor=function()error('Recursive paid lookup')end}
hero.abilities.enfos_ursa_earthshock=q;hero.abilities.enfos_ursa_enrage=r
local helpers,helperSets=0,0
local helper={rank=0,IsNull=function()return false end,GetAbilityName=function()return 'ursa_enrage'end,
 GetCaster=function()return hero end,GetLevel=function(self)return self.rank end,
 SetLevel=function(self,v)assert(server and v==1);helperSets=helperSets+1;self.rank=v end,
 SetHidden=function(self,v)assert(server);self.hidden=v end,SetActivated=function(self,v)assert(server);self.active=v end,
 OnSpellStart=function()error('Compatibility provider cannot be manually cast')end}
local add=hero.AddAbility
hero.AddAbility=function(self,id)if id=='ursa_enrage'then helpers=helpers+1;self.abilities[id]=helper;return helper end;return add(self,id)end
assert(integration.Restore(hero));assert(helpers==1 and helperSets==1 and helper.hidden and not helper.active)
local m=hero.modifiers.modifier_enfos_ursa_native_scaling
local p={ability=helper,ability_special_value='duration'}
assert(m:GetModifierOverrideAbilitySpecial(p)==1 and m:GetModifierOverrideAbilitySpecialValue(p)==0)
for rank=1,10 do r.rank=rank;assert(integration.Restore(hero))
 for _,key in ipairs({'duration','damage_reduction','status_resistance','aoe_radius','damage_increase','damage_increase_duration'})do
  p.ability_special_value=key;assert(m:GetModifierOverrideAbilitySpecialValue(p)==r:GetLevelSpecialValueNoOverride(key,rank-1))
 end
end
assert(helpers==1 and helperSets==1 and adds==1 and mods==1 and hero.points==5 and native.target_stack_count==17)
p.ability_special_value='duration';server=false;assert(m:GetModifierOverrideAbilitySpecialValue(p)==8)
server=true;r.rank=0;assert(m:GetModifierOverrideAbilitySpecialValue(p)==0)
hero.abilities.ursa_enrage=nil;hero.AddAbility=function()return nil end;assert(not integration.Restore(hero))
`));

test('Earthshock canonical header duration/damage render in every locale and mirror without old physical/Boss placeholders',()=>{
 const q=all.enfos_ursa_earthshock;
 for(const lang of ['english','turkish','russian','schinese']){
 const t=JSON.parse(fs.readFileSync('localization/'+lang+'.json','utf8')).Tokens;
 const text=t.DOTA_Tooltip_Ability_enfos_ursa_earthshock_Description;
 for(const key of ['AbilityDamage','AbilityDuration','hop_distance','shock_radius','movement_slow|abs','strength_factor'])assert.ok(text.includes('{{'+key+'}}'));
 assert.doesNotMatch(text,/boss_slow_duration|slow_pct|slow_duration|\{\{damage\}\}/);
 assert.match(t.DOTA_Tooltip_Ability_enfos_ursa_earthshock_shard_description,/3/);
 for(const prefix of ['game/resource','game/panorama/localization','content/panorama/localization']){
 const data=parseKV(fs.readFileSync(prefix+'/addon_'+lang+'.txt','utf8')).lang.Tokens;
 const desc=data.DOTA_Tooltip_Ability_enfos_ursa_earthshock_Description;
 assert.ok(desc.includes(q.AbilityDamage.split(' ').join(' / ')));assert.ok(desc.includes(q.AbilityDuration.split(' ').join(' / ')));
 assert.doesNotMatch(desc,/\{\{|boss_slow_duration/);
 }
 }
});

test('Ursa Health exposes native Q queries and exact R identity without gameplay calls',()=>{
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{encoding:'utf8',input:`
package.path='game/scripts/vscripts/?.lua;'..package.path
local server=true;function IsServer()return server end
local logs={};print=function(v)logs[#logs+1]=v end
local q={IsNull=function()return false end,GetLevel=function()return 10 end,
 GetAbilityDamage=function()assert(server);return 660 end,GetAssociatedSecondaryAbilities=function()assert(server);return 'ursa_enrage'end}
local helper={IsNull=function()return false end,GetLevel=function()return 1 end}
local hero={IsNull=function()return false end,GetUnitName=function()return 'npc_dota_hero_ursa'end,
 GetLevel=function()return 50 end,GetAbilityPoints=function()return 0 end,IsAlive=function()assert(server);return true end,
 FindAbilityByName=function(_,id)if id=='enfos_ursa_earthshock'then return q elseif id=='ursa_enrage'then return helper end end,
 AddAbility=function()error('Health must not restore')end,AddNewModifier=function()error('Health must not mutate')end}
local H=require('heroes/health');assert(H.Report(hero,0));local s=table.concat(logs,'|')
assert(s:find('native_earthshock_damage_getter=660',1,true));assert(s:find('earthshock_secondary=ursa_enrage',1,true))
assert(s:find('ability=ursa_enrage rank=1',1,true));local before=#logs;server=false;assert(not H.Report(hero,0)and#logs==before)
`});assert.equal(r.status,0,r.stderr);assert.equal(r.stderr,'');
});
