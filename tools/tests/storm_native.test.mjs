import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';
const all=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
const native=JSON.parse(fs.readFileSync('docs/audit/STORM_SPIRIT_NATIVE_SOURCE_2026-10-04.json','utf8')).abilities.storm_spirit_overload;
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
GetUnitName=function(self)return self.name end,GetIntellect=function(self)return self.int end,
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
