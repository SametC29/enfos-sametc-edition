import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';
const all=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
const d=all.enfos_ursa_ursa_minor;
test('Ursa paid mobility and exact rank-one Maul stay separate with no duplicate HP damage or native shadow',()=>{
 const h=parseKV(fs.readFileSync('game/scripts/npc/npc_heroes_custom.txt','utf8')).DOTAHeroes.npc_dota_hero_ursa;
 assert.equal(h.Ability7,'ursa_maul');assert.equal(h.Ability5,'enfos_ursa_ursa_minor');assert.equal(all.ursa_maul,undefined);
 const native=JSON.parse(fs.readFileSync('docs/audit/URSA_NATIVE_SOURCE_2026-10-04.json','utf8')).abilities.ursa_maul;
 assert.equal(native.MaxLevel,'1');assert.equal(native.Innate,'1');assert.equal(native.IsBreakable,'1');assert.match(native.AbilityBehavior,/NOT_LEARNABLE/);
 assert.equal(native.AbilityValues.health_as_damage_pct.value,'1.75');assert.equal(native.AbilityDraftUltScepterAbility,undefined);
 assert.equal(d.ScriptFile,'abilities/heroes/ursa/d');assert.equal(d.Innate,undefined);assert.equal(d.MaxLevel,'10');assert.equal(d.RequiredLevel,'1');assert.equal(d.LevelsBetweenUpgrades,'1');
 assert.equal(d.AbilityValues.bonus_ms,'8 10 12 14 16 18 20 23 26 30');
 const kit=fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8');assert.doesNotMatch(kit,/enfos_ursa_ursa_minor=class|modifier_enfos_ursa_minor_passive=class/);
 const src=fs.readFileSync('game/scripts/vscripts/abilities/heroes/ursa/d.lua','utf8');assert.doesNotMatch(src,/ApplyDamage|GetHealth|GetMaxHealth|SetAbilityPoints|AddAbility|FindUnits|CreateParticle|EmitSound/);
 assert.ok(fs.readFileSync('game/scripts/vscripts/abilities/heroes/ursa/modifier_links.lua','utf8').includes("LinkLuaModifier('modifier_enfos_ursa_minor_passive','abilities/heroes/ursa/modifiers'"));
});
function lua(body){const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{encoding:'utf8',input:`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
local server=true;function IsServer()return server end
LUA_MODIFIER_MOTION_NONE=0;function LinkLuaModifier()end
package.loaded['lib/hero_trace']={Log=function()end}
${body}`});assert.equal(r.status,0,r.stderr);assert.equal(r.stderr,'');}
test('Maul restore preserves native handle and intrinsic through repeated respawn/reconnect/free-rank grants without points or refresh',()=>lua(`
local adds,sets,mods=0,0,0
local d={rank=0,IsNull=function()return false end,GetLevel=function(self)return self.rank end,
SetLevel=function(self,r)self.rank=r end}
local e={IsNull=function()return false end,GetLevel=function()return 0 end}
local h={null=false,real=true,illusion=false,name='npc_dota_hero_ursa',points=5,
IsNull=function(self)return self.null end,IsRealHero=function(self)return self.real end,
IsIllusion=function(self)return self.illusion end,GetUnitName=function(self)return self.name end,
SetAbilityPoints=function()error('point mutation')end,AddNewModifier=function()mods=mods+1;return {IsNull=function()return false end}end,
HasModifier=function()return true end}
local providers={enfos_ursa_ursa_minor=d,enfos_ursa_fury_swipes=e}
h.FindAbilityByName=function(_,id)return providers[id]end
h.AddAbility=function(_,id)
 assert(server and (id=='ursa_maul' or id=='ursa_fury_swipes'));adds=adds+1
 local a={rank=0,stack_state=13,IsNull=function()return false end,GetLevel=function(self)return self.rank end,
 SetLevel=function(self,r)self.rank=r;sets=sets+1 end,SetHidden=function(self,v)assert(server);self.hidden=v end,
 SetActivated=function()end,GetIntrinsicModifierName=function()return 'fixture_native_maul'end}
 providers[id]=a;return a
end
local integration=require('abilities/heroes/ursa/integration');assert(integration.Restore(h))
local maul=providers.ursa_maul;assert(maul.rank==1 and maul.hidden and adds==2 and sets==1)
local innates=require('heroes/innates')
for rank=1,10 do d.rank=rank;assert(innates:Apply(h));assert(integration.Restore(h)) end
assert(providers.ursa_maul==maul and adds==2 and sets==1 and mods==0 and maul.stack_state==13 and h.points==5)
d.rank=0;assert(innates:Apply(h));assert(d.rank==1 and adds==2 and sets==1)
providers.ursa_maul=nil;assert(integration.Restore(h));assert(adds==3 and sets==2)
providers.ursa_maul=nil;h.AddAbility=function()return nil end;assert(not integration.Restore(h))
server=false;assert(not integration.Restore(h));server=true
h.illusion=true;assert(not integration.Restore(h));h.illusion=false
h.real=false;assert(not integration.Restore(h));h.real=true
h.null=true;assert(not integration.Restore(h));h.null=false
h.name='npc_dota_hero_axe';assert(not integration.Restore(h))
`));
test('Mobility getter is client-safe at every rank and suppresses Break/illusions/unlearned/null without server API',()=>lua(`
require('abilities/heroes/ursa/modifier_links')
local c={broken=false,illusion=false,IsNull=function()return false end,
IsIllusion=function(self)return self.illusion end,PassivesDisabled=function(self)return self.broken end,
IsAlive=function()error('server-only client call')end}
local values={8,10,12,14,16,18,20,23,26,30}
local a={rank=1,null=false,IsNull=function(self)return self.null end,GetLevel=function(self)return self.rank end,
GetSpecialValueFor=function(self,k)assert(k=='bonus_ms');return values[self.rank]end}
local m=setmetatable({GetParent=function()return c end,GetAbility=function()return a end},{__index=modifier_enfos_ursa_minor_passive})
for _,scope in ipairs({true,false})do server=scope
 for rank=1,10 do a.rank=rank;assert(m:GetModifierMoveSpeedBonus_Constant()==values[rank])end
 c.broken=true;assert(m:GetModifierMoveSpeedBonus_Constant()==0);c.broken=false
 c.illusion=true;assert(m:GetModifierMoveSpeedBonus_Constant()==0);c.illusion=false
 a.rank=0;assert(m:GetModifierMoveSpeedBonus_Constant()==0);a.rank=1
 a.null=true;assert(m:GetModifierMoveSpeedBonus_Constant()==0);a.null=false
end
assert(m:IsHidden() and not m:IsPurgable() and not m:RemoveOnDeath())
assert(not package.loaded['abilities/heroes/ursa/integration'])
`));
test('Maul description is localized as current HP independent of paid ranks in all four languages',()=>{
 const expected={english:'current HP',turkish:'mevcut can',russian:'текущего здоровья',schinese:'当前生命值'};
 const native=JSON.parse(fs.readFileSync('docs/audit/URSA_NATIVE_SOURCE_2026-10-04.json','utf8')).abilities.ursa_maul;
 for(const [lang,phrase]of Object.entries(expected)){
 const desc=JSON.parse(fs.readFileSync('localization/'+lang+'.json','utf8')).Tokens.DOTA_Tooltip_Ability_enfos_ursa_ursa_minor_Description;
 assert.ok(desc.includes(phrase));assert.ok(desc.includes('{{bonus_ms}}'));assert.ok(desc.replace(/(\d),(\d)/g,'$1.$2').includes(native.AbilityValues.health_as_damage_pct.value));
 }
});
test('Automatic Health reads native Maul rank/intrinsic/value without gameplay restore or client server calls',()=>lua(`
local out={};print=function(s)out[#out+1]=s end
local maul={IsNull=function()return false end,GetLevel=function()return 1 end,
GetIntrinsicModifierName=function()return 'maul_fixture'end,
GetSpecialValueFor=function(_,key)assert(server and key=='health_as_damage_pct');return 1.75 end}
local h={IsNull=function()return false end,GetUnitName=function()return 'npc_dota_hero_ursa'end,
GetLevel=function()return 6 end,GetAbilityPoints=function()return 5 end,IsAlive=function()return true end,
FindAbilityByName=function(_,id)if id=='ursa_maul' then return maul end end,
FindModifierByName=function(_,id)if id=='maul_fixture' then return {IsNull=function()return false end}end end,
AddAbility=function()error('diagnostic grant')end,AddNewModifier=function()error('diagnostic modifier')end,
SetAbilityPoints=function()error('diagnostic points')end}
local health=require('heroes/health');assert(health.Report(h,0))
local lines=table.concat(out,'|');assert(lines:find('ability=ursa_maul rank=1',1,true))
assert(lines:find('maul_intrinsic=maul_fixture present=true health_damage_pct_query=1.75',1,true))
server=false;h.GetUnitName=function()error('client server work')end;assert(not health.Report(h,0))
assert(not package.loaded['abilities/heroes/ursa/integration'])
`));
