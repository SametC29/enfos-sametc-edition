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
function LinkLuaModifier(name,path)assert(path=='abilities/heroes/slark/modifiers')end
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
 FindAbilityByName=function(_,id)if id=='enfos_slark_dark_pact' then return q end end,
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

test('Shadow Dance delegates concealment, passive visibility and cleanup to native without a Lua buff replica',()=>{
 const r=all.enfos_slark_shadow_dance;
 const native=JSON.parse(fs.readFileSync('docs/audit/SLARK_NATIVE_SOURCE_2026-10-04.json','utf8')).abilities.slark_shadow_dance;
 assert.ok(isVerifiedNativeAbility('enfos_slark_shadow_dance',r));
 for(const key of ['AbilityBehavior','SpellDispellableType','AbilitySound','AbilityCastAnimation'])assert.equal(r[key],native[key],key);
 assert.equal(r.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
 assert.equal(r.MaxLevel,'10');assert.equal(r.RequiredLevel,'5');assert.equal(r.LevelsBetweenUpgrades,'5');
 const lua=fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8');
 assert.doesNotMatch(lua,/enfos_slark_shadow_dance\s*=\s*class|modifier_enfos_slark_shadow_dance_buff/);
 assert.equal(all.slark_shadow_dance,undefined);
});
test('Shadow Dance flat regen uses native endpoints rather than treating authored percentages as native units',()=>{
 const snapshot=JSON.parse(fs.readFileSync('docs/audit/SLARK_NATIVE_SOURCE_2026-10-04.json','utf8'));
 assert.equal(snapshot.localization.tokens.DOTA_Tooltip_ability_slark_shadow_dance_bonus_regen,'HEALTH GAINED PER SECOND:');
 const values=all.enfos_slark_shadow_dance.AbilityValues;
 const native=snapshot.abilities.slark_shadow_dance.AbilityValues;
 const endpoints=native.bonus_regen.value.split(' ').map(Number);
 assert.deepEqual(values.bonus_regen.split(' ').map(Number),Array.from({length:10},(_,i)=>Math.round(endpoints[0]+i*(endpoints.at(-1)-endpoints[0])/9)));
 assert.equal(values.bonus_movement_speed,'40 47 53 60 67 73 80 87 93 100');
 assert.equal(values.duration,'4.5 4.9 5.3 5.7 6.1 6.4 6.8 7.2 7.6 8');
 assert.equal(values.health_regen_pct,undefined);assert.equal(values.bonus_ms,undefined);
 for(const lang of ['english','turkish','russian','schinese']){
  const tokens=JSON.parse(fs.readFileSync(`localization/${lang}.json`,'utf8')).Tokens;
  const desc=tokens.DOTA_Tooltip_Ability_enfos_slark_shadow_dance_Description;
  assert.ok(desc.includes('{{bonus_regen}}')&&desc.includes('{{bonus_movement_speed}}'));
  assert.ok(!desc.includes('{{health_regen_pct}}'));
  assert.ok(!tokens.DOTA_Tooltip_Ability_enfos_slark_shadow_dance_scepter_description.includes('40%'));
 }
});

function runLua(input){
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{encoding:'utf8',input});
 assert.equal(r.status,0,r.stderr);assert.equal(r.stderr,'');
}
const essenceSetup=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
local server=true;function IsServer()return server end
function LinkLuaModifier(name,path)assert(path=='abilities/heroes/slark/modifiers')end
local I=require('abilities/heroes/slark/integration')
local rank=1;local broke,illusion,removed=false,false,false
local v={bonus_agi={1,1,2,2,2,3,3,3,4,4},max_stacks={30,35,40,45,50,55,60,65,70,75},duration={30},stat_loss={1},steal_radius={300}}
local e={IsNull=function()return removed end,GetLevel=function()return rank end,GetAbilityName=function()return 'enfos_slark_essence_shift'end,
 GetLevelSpecialValueNoOverride=function(_,key,level)return v[key][level+1] or v[key][1]end,
 GetSpecialValueFor=function(_,key)return v[key][rank] or v[key][1]end}
local q={IsNull=function()return false end,GetLevel=function()return 1 end}
local mods,providers={},{};local adds,refreshes=0,0
local hero={IsNull=function()return false end,IsRealHero=function()return true end,IsIllusion=function()return illusion end,
 GetUnitName=function()return 'npc_dota_hero_slark'end,GetTeamNumber=function()return 2 end,PassivesDisabled=function()return broke end,
 FindAbilityByName=function(_,id)if id=='enfos_slark_dark_pact'then return q elseif id=='enfos_slark_essence_shift'then return e else return providers[id]end end,
 HasModifier=function(_,id)return mods[id]~=nil end,FindModifierByName=function(_,id)return mods[id]end,
 SetAbilityPoints=function()error('No free points')end}
hero.AddAbility=function(_,id)assert(id=='slark_essence_shift' and not providers[id]);adds=adds+1
 local a={level=0,IsNull=function()return false end,GetAbilityName=function()return id end,GetLevel=function(self)return self.level end,
 SetLevel=function(self,level)assert(level==1);self.level=level end,SetHidden=function(_,value)assert(value)end,
 SetActivated=function(_,value)assert(not value)end,GetIntrinsicModifierName=function()return 'native_engine_name'end}
 providers[id]=a;mods.native_engine_name={IsNull=function()return false end,ForceRefresh=function()refreshes=refreshes+1 end};return a end
hero.AddNewModifier=function(_,_,a,id,p)
 assert(id=='modifier_enfos_slark_native_scaling' or id=='modifier_enfos_slark_essence_shift_buff')
 local m=setmetatable({count=0,IsNull=function()return false end,GetParent=function()return hero end,GetAbility=function()return a end,
 GetStackCount=function(self)return self.count end,SetStackCount=function(self,n)self.count=n end,
 SetDuration=function(self,n,refresh)assert(n==30 and refresh);self.duration=n end},_G[id]);mods[id]=m;return m end
assert(I.Restore(hero) and I.Restore(hero) and adds==1)
local listener=setmetatable({GetParent=function()return hero end,GetAbility=function()return e end},modifier_enfos_slark_essence_shift_passive)
local target={IsNull=function()return false end,IsHero=function()return false end,IsCreep=function()return true end,GetTeamNumber=function()return 3 end,
 IsAlive=function()error('Killing blows still count')end}
`;

test('paid Essence controller keeps native provider rank1 and native hero ownership with ten-rank authored tuning',()=>{
 const e=all.enfos_slark_essence_shift;assert.equal(e.BaseClass,'ability_lua');assert.equal(e.ScriptFile,'abilities/heroes/slark/essence_shift');
 assert.equal(e.Innate,'0');assert.equal(e.MaxLevel,'10');assert.equal(e.RequiredLevel,'1');assert.equal(e.LevelsBetweenUpgrades,'1');
 assert.equal(all.slark_essence_shift,undefined);
 const native=JSON.parse(fs.readFileSync('docs/audit/SLARK_NATIVE_SOURCE_2026-10-04.json','utf8')).abilities.slark_essence_shift;
 assert.equal(e.AbilityValues.stat_loss,native.AbilityValues.stat_loss);assert.equal(e.AbilityValues.steal_radius,native.AbilityValues.steal_radius.value);
 const lua=fs.readFileSync('game/scripts/vscripts/abilities/heroes/slark/modifiers.lua','utf8');
 assert.doesNotMatch(lua,/StartIntervalThink|ApplyDamage|FindUnitsInRadius|SetAbilityPoints/);
 assert.doesNotMatch(fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8'),/enfos_slark_essence_shift=class|modifier_enfos_slark_essence_shift_passive=class/);
 runLua(essenceSetup+`
 local scaler=mods.modifier_enfos_slark_native_scaling
 local p={ability=providers.slark_essence_shift,ability_special_value='agi_gain'}
 for r=1,10 do rank=r;assert(scaler:GetModifierOverrideAbilitySpecial(p)==1 and scaler:GetModifierOverrideAbilitySpecialValue(p)==v.bonus_agi[r]);assert(I.RefreshEssence(hero))end
 assert(adds==1 and refreshes==10)
 mods.native_engine_name=nil;assert(not I.RefreshEssence(hero) and refreshes==10)
 rank=0;for _,key in ipairs({'agi_gain','stat_loss','duration','steal_radius'})do p.ability_special_value=key;assert(scaler:GetModifierOverrideAbilitySpecialValue(p)==0)end
 server=false;hero.FindModifierByName=function()error('Client has no server modifier lookup')end
 rank=10;p.ability_special_value='agi_gain';assert(scaler:GetModifierOverrideAbilitySpecialValue(p)==4)
 assert(not I.Restore(hero))
 removed=true;assert(scaler:GetModifierOverrideAbilitySpecial(p)==1 and scaler:GetModifierOverrideAbilitySpecialValue(p)==0)
 hero.FindAbilityByName=function()return nil end
 assert(scaler:GetModifierOverrideAbilitySpecial(p)==1 and scaler:GetModifierOverrideAbilitySpecialValue(p)==0)
 `);
});

test('creep essence is bounded, ignores native hero hits, preserves existing stacks under Break and handles invalid sources on client',()=>{
 runLua(essenceSetup+`
 listener:OnAttackLanded({attacker=hero,target=target})
 local buff=mods.modifier_enfos_slark_essence_shift_buff;assert(buff and buff.count==1 and buff:GetModifierBonusStats_Agility()==1)
 for i=1,100 do listener:OnAttackLanded({attacker=hero,target=target})end
 assert(buff.count==30 and buff.duration==30)
 rank=10;listener:OnAttackLanded({attacker=hero,target=target});assert(buff.count==31 and buff:GetModifierBonusStats_Agility()==124)
 broke=true;listener:OnAttackLanded({attacker=hero,target=target});assert(buff.count==31 and buff:GetModifierBonusStats_Agility()==124)
 broke=false;target.IsHero=function()return true end;listener:OnAttackLanded({attacker=hero,target=target});assert(buff.count==31)
 target.IsHero=function()return false end;target.IsCreep=function()return false end;listener:OnAttackLanded({attacker=hero,target=target});assert(buff.count==31)
 target.IsCreep=function()return true end;target.GetTeamNumber=function()return 2 end;listener:OnAttackLanded({attacker=hero,target=target});assert(buff.count==31)
 illusion=true;assert(buff:GetModifierBonusStats_Agility()==0);listener:OnAttackLanded({attacker=hero,target=target});assert(buff.count==31);illusion=false
 rank=0;assert(buff:GetModifierBonusStats_Agility()==0);rank=10;removed=true;assert(buff:GetModifierBonusStats_Agility()==0);removed=false
 server=false;hero.IsAlive=function()error('Server only')end;hero.FindModifierByName=function()error('Server only')end;hero.PassivesDisabled=function()error('Existing bonus need not query Break')end
 assert(buff:GetModifierBonusStats_Agility()==124);listener:OnAttackLanded({attacker=hero,target=target});assert(buff.count==31)
 `);
});

test('Pounce native alias keeps motion, hero-only contact and cleanup with no custom endpoint dash',()=>{
 const w=all.enfos_slark_pounce;const native=JSON.parse(fs.readFileSync('docs/audit/SLARK_NATIVE_SOURCE_2026-10-04.json','utf8')).abilities.slark_pounce;
 assert.ok(isVerifiedNativeAbility('enfos_slark_pounce',w));
 for(const key of ['AbilityBehavior','SpellImmunityType','AbilityUnitDamageType','SpellDispellableType','AbilitySound','AbilityCastAnimation','HasScepterUpgrade'])assert.equal(w[key],native[key],key);
 for(const key of ['pounce_damage','pounce_distance','pounce_speed','pounce_acceleration','pounce_radius','leash_radius'])
  assert.equal(w.AbilityValues[key],native.AbilityValues[key].value??native.AbilityValues[key],key);
 assert.equal(w.MaxLevel,'10');assert.equal(w.RequiredLevel,'1');assert.equal(w.LevelsBetweenUpgrades,'1');
 assert.equal(w.AbilityValues.leash_duration,'2.5 2.7 2.9 3.1 3.3 3.5 3.7 3.9 4.1 4.3');
 assert.equal(w.AbilityValues.AbilityCooldown,w.AbilityCooldown);
 for(const key of ['damage','agility_factor','boss_leash_duration','impact_radius','dash_speed'])assert.equal(w.AbilityValues[key],undefined);
 assert.doesNotMatch(fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8'),/enfos_slark_pounce=class|modifier_enfos_slark_pounce_dash|modifier_enfos_slark_pounce_leash/);
 assert.equal(all.slark_pounce,undefined);
});

test('Pounce owns native Scepter charge keys and all languages describe directional hero latch without endpoint damage',()=>{
 const w=all.enfos_slark_pounce;const native=JSON.parse(fs.readFileSync('docs/audit/SLARK_NATIVE_SOURCE_2026-10-04.json','utf8')).abilities.slark_pounce;
 for(const key of ['max_charges','charge_restore_time','pounce_distance_scepter'])assert.deepEqual({...w.AbilityValues[key]},native.AbilityValues[key],key);
 const levels=native.AbilityValues.essence_stacks.value.split(' ').map(Number);
 assert.deepEqual(w.AbilityValues.essence_stacks.split(' ').map(Number),Array.from({length:10},(_,i)=>Math.round(levels[0]+i*(levels.at(-1)-levels[0])/9)));
 assert.equal(all.enfos_slark_shadow_dance.HasScepterUpgrade,undefined);
 for(const lang of ['english','turkish','russian','schinese']){
  const tokens=JSON.parse(fs.readFileSync('localization/'+lang+'.json','utf8')).Tokens,desc=tokens.DOTA_Tooltip_Ability_enfos_slark_pounce_Description;
  for(const key of ['pounce_distance','pounce_radius','leash_duration','leash_radius','essence_stacks'])assert.ok(desc.includes('{{'+key+'}}'),lang+'.'+key);
  assert.ok(!desc.includes('{{damage}}')&&!desc.includes('{{agility_factor}}'));
  const upgrade=tokens.DOTA_Tooltip_Ability_enfos_slark_pounce_scepter_description;
  for(const n of ['2','12','900'])assert.ok(upgrade.includes(n),lang+'.'+n);
 }
});

test('native Pounce Scepter suppresses old generic ultimate bonuses only for owned Slark kit',()=>runLua(`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
function LinkLuaModifier()end
require('heroes/aghanim_manager')
DOTA_ABILITY_TYPE_ULTIMATE=1
local unit='npc_dota_hero_slark';local present=true
local w={IsNull=function()return false end}
local hero={IsNull=function()return false end,GetUnitName=function()return unit end,FindAbilityByName=function(_,id)if id=='enfos_slark_pounce' and present then return w end end}
local m=setmetatable({GetParent=function()return hero end},modifier_enfos_scepter_upgrade)
local r={GetAbilityType=function()return 1 end};local event={inflictor=r,ability=r}
assert(m:IsHidden() and m:GetModifierSpellAmplify_Percentage(event)==0 and m:GetModifierPercentageCooldown(event)==0)
present=false;assert(not m:IsHidden() and m:GetModifierSpellAmplify_Percentage(event)==40 and m:GetModifierPercentageCooldown(event)==25)
present=true;unit='npc_dota_hero_drow_ranger';assert(m:GetModifierSpellAmplify_Percentage(event)==40 and m:GetModifierPercentageCooldown(event)==25)
unit='npc_dota_hero_slark';w.IsNull=function()return true end;assert(not m:IsHidden() and m:GetModifierPercentageCooldown(event)==25)
`));
