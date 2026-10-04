import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';
import {isVerifiedNativeAbility} from '../lib/native_hero_abilities.mjs';
const kv=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
const w=kv.enfos_ursa_overpower;
test('Overpower delegates cast, charge consumption and presentation to installed native definition',()=>{
 const native=JSON.parse(fs.readFileSync('docs/audit/URSA_NATIVE_SOURCE_2026-10-04.json','utf8')).abilities.ursa_overpower;
 assert.ok(isVerifiedNativeAbility('enfos_ursa_overpower',w));assert.equal(w.ScriptFile,undefined);
 for(const key of ['AbilityBehavior','SpellDispellableType','AbilitySound','AbilityCastAnimation','AbilityCastGestureSlot','AbilityCastRange'])assert.equal(w[key],native[key]);
 assert.equal(Number(w.AbilityCastPoint),Number(native.AbilityCastPoint.split(' ')[0]));
 assert.equal(w.AbilityValues.slow_resist,native.AbilityValues.slow_resist);
 for(const field of [w.AbilityDuration,w.AbilityCooldown,w.AbilityManaCost,w.AbilityValues.max_attacks,w.AbilityValues.attack_speed_bonus_pct,w.AbilityValues.attack_heal_pct])assert.equal(field.split(' ').length,10);
 assert.equal(w.MaxLevel,'10');assert.equal(w.RequiredLevel,'1');assert.equal(w.LevelsBetweenUpgrades,'1');
 assert.equal(w.AbilityValues.attack_speed,undefined);assert.equal(w.AbilityValues.buff_duration,undefined);
 assert.doesNotMatch(fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8'),/enfos_ursa_overpower=class|modifier_enfos_ursa_overpower_buff/);
 assert.doesNotMatch(fs.readFileSync('game/scripts/vscripts/abilities/heroes/ursa/w_heal.lua','utf8'),/SetStackCount|DecrementStackCount|ApplyDamage|CreateParticle|EmitSound|StartIntervalThink|CreateTimer|FindUnits/);
});
function run(body){const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{encoding:'utf8',input:`
package.path='game/scripts/vscripts/?.lua;'..package.path
local server=true;function IsServer()return server end
package.loaded['lib/hero_trace']={Log=function()end}
local H=require('abilities/heroes/ursa/w_heal')
local c={null=false,illusion=false,alive=true,team=2,heals=0,IsNull=function(self)return self.null end,
GetUnitName=function()return 'npc_dota_hero_ursa'end,IsIllusion=function(self)return self.illusion end,
IsAlive=function(self)return self.alive end,GetTeamNumber=function(self)return self.team end}
local a={rank=1,pct=10,IsNull=function()return false end,GetLevel=function(self)return self.rank end,
GetCaster=function()return c end,GetSpecialValueFor=function(self,key)assert(key=='attack_heal_pct');return self.pct end}
local buff={charges=1,time=8,IsNull=function()return false end,GetAbility=function()return a end,
GetStackCount=function(self)return self.charges end,GetRemainingTime=function(self)return self.time end}
c.FindAbilityByName=function(_,id)assert(id=='enfos_ursa_overpower');return a end
c.FindAllModifiers=function()assert(server);return {buff} end
c.Heal=function(self,amount,ability)assert(server and ability==a);self.heals=self.heals+amount end
local t={team=3,alive=false,IsNull=function()return false end,GetTeamNumber=function(self)return self.team end,
IsAlive=function()error('killing hit must not be rejected')end}
local mod={GetParent=function()return c end}
local function event(id,damage)return {record=id,attacker=c,target=t,damage=damage}end
${body}`});assert.equal(r.status,0,r.stderr);assert.equal(r.stderr,'');}
test('Healing snapshots each rank, includes last charge and killing hits, rejects duplicates and foreign records',()=>run(`
for rank=1,10 do
 a.rank=rank;a.pct=8+2*rank;buff.charges=1;buff.time=8
 local p=event(rank,100);H.Record(mod,p);H.Record(mod,p)
 buff.charges=0;buff.time=0;a.pct=0
 local before=c.heals;H.Landed(mod,p);assert(c.heals-before==8+2*rank)
 H.Landed(mod,p);assert(c.heals-before==8+2*rank)
end
buff.charges=1;buff.time=8;a.pct=28
local p=event(20,100);H.Record(mod,p)
local foreign={IsNull=function()return false end,GetTeamNumber=function()return 3 end}
p.target=foreign;local before=c.heals;H.Landed(mod,p);assert(c.heals==before)
H.Landed(mod,event(99,100));assert(c.heals==before)
`));
test('Healing record memory is bounded and clears on misses, destruction and death without client APIs',()=>run(`
for i=1,40 do H.Record(mod,event(i,100)) end
local n=0;for _ in pairs(mod.overpowerRecords)do n=n+1 end;assert(n==32)
assert(not mod.overpowerRecords[1] and mod.overpowerRecords[40])
H.Forget(mod,event(40));assert(not mod.overpowerRecords[40])
H.Death(mod,{unit=t});assert(mod.overpowerRecords)
H.Death(mod,{unit=c});assert(not mod.overpowerRecords)
server=false;c.FindAllModifiers=function()error('client enumeration')end
H.Record(mod,event(50));H.Landed(mod,event(50,100));H.Forget(mod,event(50));H.Death(mod,{unit=c});assert(not H.NativeBuff(c,a))
server=true;c.FindAllModifiers=function()return {buff}end
for _,condition in ipairs({'ally','illusion','zero','expired','untrained'})do
 t.team=condition=='ally' and 2 or 3;c.illusion=condition=='illusion'
 buff.charges=condition=='zero' and 0 or 1;buff.time=condition=='expired' and 0 or 8
 a.rank=condition=='untrained' and 0 or 1;H.Record(mod,event(60));assert(not mod.overpowerRecords or not mod.overpowerRecords[60])
end
`));
test('Overpower sustain rejects dead caster/zero damage/failed attacks and client hooks load no server code',()=>run(`
H.Record(mod,event(1));H.Forget(mod,event(1));H.Landed(mod,event(1,100));assert(c.heals==0)
H.Record(mod,event(2));c.alive=false;H.Landed(mod,event(2,100));assert(c.heals==0);c.alive=true
H.Record(mod,event(3));H.Landed(mod,event(3,0));assert(c.heals==0)
H.Record(mod,event(4));H.Landed(mod,event(4,-10));assert(c.heals==0)
function class(t)return t end
require('abilities/heroes/ursa/modifiers')
server=false;package.loaded['abilities/heroes/ursa/w_heal']=nil
package.preload['abilities/heroes/ursa/w_heal']=function()error('client imported server healing')end
for _,name in ipairs({'OnAttackRecord','OnAttackLanded','OnAttackFail','OnAttackRecordDestroy','OnDeath'})do
 modifier_enfos_ursa_native_scaling[name](mod,event(5,100))
end
`));
test('Overpower locales and generated mirrors use native fields and describe missed charges and killing hits',()=>{
 const descriptions=[];
 for(const lang of ['english','turkish','russian','schinese']){
  const tokens=JSON.parse(fs.readFileSync('localization/'+lang+'.json','utf8')).Tokens;
  const desc=tokens.DOTA_Tooltip_Ability_enfos_ursa_overpower_Description;descriptions.push(desc);
  for(const field of ['AbilityDuration','attack_speed_bonus_pct','slow_resist','max_attacks','attack_heal_pct'])assert.ok(desc.includes('{{'+field+'}}'));
  assert.doesNotMatch(desc,/buff_duration|\{\{attack_speed\}\}/);
  for(const root of ['game/resource','game/panorama/localization','content/panorama/localization']){
   const text=fs.readFileSync(root+'/addon_'+lang+'.txt','utf8');assert.ok(text.includes('DOTA_Tooltip_Ability_enfos_ursa_overpower_Description'));assert.doesNotMatch(text,/\{\{/);
  }
 }
 assert.equal(new Set(descriptions).size,4);
});
