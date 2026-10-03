import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';
import {getAbilityValues} from '../lib/ability_values.mjs';
const all=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
const luaTable=o=>'{'+Object.entries(o).map(([key,value])=>'['+JSON.stringify(key)+']='+(typeof value==='object'?luaTable(value):JSON.stringify(value))).join(',')+'}';
const data=luaTable(Object.fromEntries(['shadowraze','necromastery','requiem_of_souls'].map(key=>{
 const id='enfos_sf_'+key;return [id,getAbilityValues(all[id])];
})));
function lua(body){
const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{encoding:'utf8',input:`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
local server=true
function IsServer()return server end
function LinkLuaModifier()end
Log={Warn=function()end}
MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL=1;MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE=2
MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE=3
local Integration=require('abilities/heroes/nevermore/integration')
local values=${data}
local qrank,wrank,rrank=1,1,1
local adds,modAdds,refreshes,casts,phase,interrupts,refund=0,0,0,0,0,0,0
local abilities,modifiers={},{}
local broken,illusion,alive=false,false,true
local hero={IsNull=function()return false end,IsRealHero=function()return true end,
 IsIllusion=function()return illusion end,IsAlive=function()return alive end,PassivesDisabled=function()return broken end,
 GetUnitName=function()return 'npc_dota_hero_nevermore' end,GetIntellect=function()return 100 end,
 FindAbilityByName=function(_,id)return abilities[id]end,HasModifier=function(_,id)return modifiers[id]~=nil end,
 FindModifierByName=function(_,id)return modifiers[id]end}
local function raw(id,rank)
 return function(_,key,level)
  local text=assert(values[id][key],'missing raw source '..key)
  local numbers={};for part in text:gmatch('%S+')do numbers[#numbers+1]=tonumber(part)end
  return numbers[math.min(#numbers,level+1)]
 end
end
local function slot(id,rank)
 local a=setmetatable({IsNull=function()return false end,GetLevel=rank,GetCaster=function()return hero end,
 GetLevelSpecialValueNoOverride=raw(id,rank)},_G[id]);abilities[id]=a;return a
end
local q=slot('enfos_sf_shadowraze',function()return qrank end)
local w=slot('enfos_sf_necromastery',function()return wrank end)
local r=slot('enfos_sf_requiem_of_souls',function()return rrank end)
local cd=6
q.GetCooldownTimeRemaining=function()return cd end;q.EndCooldown=function()cd=0 end
q.StartCooldown=function(_,n)cd=n end;q.RefundManaCost=function()refund=refund+1 end
r.EndCooldown=q.EndCooldown;r.RefundManaCost=q.RefundManaCost
local scaler=setmetatable({GetParent=function()return hero end,GetStackCount=function()return 0 end},modifier_enfos_sf_native_scaling)
hero.AddNewModifier=function(_,_,_,id)modAdds=modAdds+1;assert(id=='modifier_enfos_sf_native_scaling');modifiers[id]=scaler;scaler.IsNull=function()return false end;return scaler end
hero.AddAbility=function(_,id)
 adds=adds+1
 local a={level=0,IsNull=function()return false end,GetAbilityName=function()return id end,
 GetLevel=function(self)return self.level end,SetLevel=function(self,n)self.level=n end,
 SetHidden=function(self,n)self.hidden=n end,SetActivated=function(self,n)self.active=n end,
 StartCooldown=function(self,n)self.cd=n end,GetCooldownTimeRemaining=function(self)return self.cd or 0 end,
 OnSpellStart=function()casts=casts+1 end,OnAbilityPhaseStart=function()phase=phase+1;return true end,
 OnAbilityPhaseInterrupted=function()interrupts=interrupts+1 end}
 abilities[id]=a
 if id=='nevermore_necromastery' then modifiers.modifier_nevermore_necromastery={
  IsNull=function()return false end,GetStackCount=function()return 12 end,ForceRefresh=function()refreshes=refreshes+1 end}end
 return a
end
${body}`});
 assert.equal(result.status,0,result.stderr);assert.equal(result.stderr,'');
}

test('native provider restore is bounded, idempotent, preserves soul handle and never uses high C++ ranks',()=>lua(`
rrank=0;assert(Integration.Restore(hero));assert(adds==5 and modAdds==1)
assert(abilities.nevermore_requiem.level==0)
local souls=modifiers.modifier_nevermore_necromastery
qrank=10;wrank=10;rrank=10;assert(Integration.Restore(hero));assert(Integration.Restore(hero))
assert(adds==5 and modAdds==1 and modifiers.modifier_nevermore_necromastery==souls)
for id,a in pairs(abilities)do if id:find('nevermore_',1,true)==1 then assert(a.level==1 and a.hidden and a.active==(id=='nevermore_requiem'),id)end end
server=false;assert(not Integration.Restore(hero));assert(adds==5)
server=true;hero.GetUnitName=function()return 'npc_dota_hero_luna'end;assert(not Integration.Restore(hero))
hero.GetUnitName=function()return 'npc_dota_hero_nevermore'end;abilities.enfos_sf_shadowraze=nil;assert(not Integration.Restore(hero))
`));

test('paid Q/R cast controllers delegate mechanics and relay native cooldown/phase state',()=>lua(`
assert(Integration.Restore(hero))
abilities.nevermore_shadowraze1.OnSpellStart=function(self)casts=casts+1;self.cd=self.cd-2 end
q:OnSpellStart();assert(casts==3 and cd==4 and refund==0)
assert(r:OnAbilityPhaseStart());r:OnAbilityPhaseInterrupted();r:OnSpellStart()
assert(casts==4 and phase==1 and interrupts==1)
alive=false;q:OnSpellStart();assert(casts==4)
server=false;r:OnSpellStart();q:OnSpellStart();assert(casts==4)
`));

test('native special overrides use paid raw values and INT without recursive native queries',()=>lua(`
assert(Integration.Restore(hero))
local function query(id,key)
 local p={ability=abilities[id],ability_special_value=key};assert(scaler:GetModifierOverrideAbilitySpecial(p)==1)
 return scaler:GetModifierOverrideAbilitySpecialValue(p)
end
assert(query('nevermore_shadowraze1','shadowraze_damage')==220)
assert(query('nevermore_necromastery','necromastery_damage_per_soul')==3)
assert(query('nevermore_requiem','AbilityDamage')==300)
qrank=10;wrank=10;rrank=10
assert(query('nevermore_shadowraze3','shadowraze_damage')==580)
assert(query('nevermore_necromastery','necromastery_max_souls')==54)
assert(query('nevermore_requiem','AbilityDamage')==680 and query('nevermore_requiem','max_soul_release')==54)
assert(query('nevermore_necromastery','souls_per_kill')==2 and query('nevermore_necromastery','souls_per_hero_kill')==4)
wrank=0;assert(query('nevermore_necromastery','necromastery_max_souls')==0)
local p={ability=abilities.nevermore_requiem,ability_special_value='requiem_line_speed'}
assert(scaler:GetModifierOverrideAbilitySpecial(p)==0)
`));

test('W refresh preserves native soul state; client amplification avoids server-only intrinsic lookup',()=>lua(`
assert(Integration.Restore(hero));w:OnUpgrade();assert(refreshes==1)
server=false;abilities.nevermore_necromastery.GetIntrinsicModifierName=function()error('server-only API')end
assert(scaler:GetModifierSpellAmplify_Percentage()==12)
broken=true;assert(scaler:GetModifierSpellAmplify_Percentage()==0)
broken=false;illusion=true;assert(scaler:GetModifierSpellAmplify_Percentage()==0)
illusion=false;wrank=0;assert(scaler:GetModifierSpellAmplify_Percentage()==0)
assert(not scaler:RemoveOnDeath() and not scaler:IsPurgable())
`));

test('native upgrade ownership skips generic Mage bonuses only for the ENFOS SF kit',()=>lua(`
require('heroes/aghanim_manager')
DOTA_ABILITY_TYPE_ULTIMATE=1
r.GetAbilityType=function()return 1 end
local s=setmetatable({GetParent=function()return hero end},modifier_enfos_scepter_upgrade)
local shard=setmetatable({role='Mage',GetParent=function()return hero end},modifier_enfos_shard_upgrade)
assert(s:GetModifierSpellAmplify_Percentage({inflictor=r})==0)
assert(s:GetModifierPercentageCooldown({ability=r})==0 and shard:GetModifierSpellAmplify_Percentage()==0)
abilities.enfos_sf_shadowraze=nil
assert(s:GetModifierSpellAmplify_Percentage({inflictor=r})==40)
assert(s:GetModifierPercentageCooldown({ability=r})==25 and shard:GetModifierSpellAmplify_Percentage()==15)
r.GetLevelSpecialValueFor=function()return -7 end;assert(r:GetCooldown(9)==1)
r.GetLevelSpecialValueFor=function()return 50 end;assert(r:GetCooldown(0)==50)
`));

test('SF probe reads both native damage query surfaces without restoring or changing the kit',()=>lua(`
local lines={};print=function(s)lines[#lines+1]=s end
server=false;PlayerResource=nil
assert(loadfile('game/scripts/vscripts/tools/sf_health.lua'))()
assert(lines[#lines]:find('server_context_unavailable',1,true))
server=true;assert(Integration.Restore(hero))
hero.GetLevel=function()return 6 end;hero.GetAbilityPoints=function()return 5 end
PlayerResource={IsValidPlayerID=function(_,id)return id==0 end,GetSelectedHeroEntity=function()return hero end}
abilities.nevermore_shadowraze1.GetSpecialValueFor=function()return 220 end
abilities.nevermore_requiem.GetSpecialValueFor=function()return 300 end
abilities.nevermore_requiem.GetAbilityDamage=function()return 80 end
assert(loadfile('game/scripts/vscripts/tools/sf_health.lua'))()
assert(adds==5 and modAdds==1 and casts==0 and refreshes==0)
assert(table.concat(lines,'|'):find('native_requiem_damage_query=300 ability_damage_getter=80',1,true))
`));
