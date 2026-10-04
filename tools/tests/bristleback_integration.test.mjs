import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';
import {getAbilityValues} from '../lib/ability_values.mjs';
const all=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
const ids=['enfos_bb_viscous_nasal_goo','enfos_bb_quill_spray','enfos_bb_bristleback','enfos_bb_hairball'];
const table=o=>'{'+Object.entries(o).map(([k,v])=>`[${JSON.stringify(k)}]=`+(typeof v==='object'?table(v):JSON.stringify(v))).join(',')+'}';
const values=table(Object.fromEntries(ids.map(id=>[id,{...getAbilityValues(all[id]),AbilityCastRange:all[id].AbilityCastRange||'0'}])));
function lua(body){
 const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{encoding:'utf8',input:`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
local server=true
function IsServer()return server end
function LinkLuaModifier()end
MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL=1;MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE=2
MODIFIER_EVENT_ON_ABILITY_FULLY_CAST=3;LUA_MODIFIER_MOTION_NONE=0
DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO=20
ApplyDamage=function()error('Bridge must not implement damage')end
FindUnitsInRadius=function()error('Bridge must not scan targets')end
local Integration=require('abilities/heroes/bristleback/integration')
local values=${values}
local abilities,modifiers,ranks={},{},{}
local adds,modAdds,casts,refunds,refreshes=0,0,0,0,0
local alive,illusion,scepter=true,false,false
local hero={IsNull=function()return false end,IsRealHero=function()return true end,
 IsIllusion=function()return illusion end,IsAlive=function()return alive end,
 GetUnitName=function()return 'npc_dota_hero_bristleback'end,GetPlayerID=function()return 0 end,
 GetStrength=function()return 100 end,HasScepter=function()return scepter end,
 FindAbilityByName=function(_,id)return abilities[id]end,
 HasModifier=function(_,id)return modifiers[id]~=nil end,
 FindModifierByName=function(_,id)return modifiers[id]end,
 SetCursorCastTarget=function(self,t)self.target=t end,SetCursorPosition=function(self,p)self.point=p end}
local function raw(id,key,level)
 local text=assert(values[id][key],'missing value '..id..'.'..key)
 local n={};for part in text:gmatch('%S+')do n[#n+1]=tonumber(part)end
 return n[math.min(#n,level+1)]
end
for id in pairs(values)do
 ranks[id]=1
 abilities[id]=setmetatable({IsNull=function()return false end,GetCaster=function()return hero end,
 GetAbilityName=function()return id end,GetLevel=function()return ranks[id]end,
 GetLevelSpecialValueNoOverride=function(_,key,level)return raw(id,key,level)end,
 GetSpecialValueFor=function(_,key)return raw(id,key,ranks[id]-1)end,
 EndCooldown=function(self)self.cd=0 end,StartCooldown=function(self,n)self.cd=n end,
 GetCooldownTimeRemaining=function(self)return self.cd or 3 end,
 RefundManaCost=function()refunds=refunds+1 end,GetAutoCastState=function()return false end},_G[id])
end
abilities.enfos_bb_warpath={}
local scaler=setmetatable({IsNull=function()return false end,GetParent=function()return hero end},modifier_enfos_bb_native_scaling)
hero.AddNewModifier=function(_,_,_,id)
 modAdds=modAdds+1;assert(id=='modifier_enfos_bb_native_scaling');modifiers[id]=scaler;return scaler
end
hero.AddAbility=function(_,id)
 adds=adds+1
 local a={level=0,IsNull=function()return false end,GetAbilityName=function()return id end,
 GetLevel=function(self)return self.level end,SetLevel=function(self,n)self.level=n end,
 SetHidden=function(self,n)self.hidden=n end,SetActivated=function(self,n)self.active=n end,
 GetIntrinsicModifierName=function()return ''end,
 OnSpellStart=function(self)casts=casts+1;self.target=hero.target;self.point=hero.point end,
 StartCooldown=function(self,n)self.cd=n end,GetCooldownTimeRemaining=function(self)return self.cd or 3 end,
 GetAutoCastState=function(self)return self.auto or false end,ToggleAutoCast=function(self)self.auto=not self.auto end}
 abilities[id]=a;return a
end
${body}`});
 assert.equal(result.status,0,result.stderr);assert.equal(result.stderr,'');
}

test('linked providers remain bounded across ranks and restore; native E stays untrained at paid rank zero',()=>lua(`
ranks.enfos_bb_bristleback=0;assert(Integration.Restore(hero));assert(adds==4 and modAdds==1)
assert(abilities.bristleback_bristleback.level==0)
for id in pairs(values)do ranks[id]=10 end
assert(Integration.Restore(hero));assert(Integration.Restore(hero));assert(adds==4 and modAdds==1)
for _,id in ipairs({'bristleback_viscous_nasal_goo','bristleback_quill_spray','bristleback_bristleback','enfos_bb_native_hairball'})do
 assert(abilities[id].level==1 and abilities[id].hidden,id)
end
assert(abilities.bristleback_quill_spray.active and abilities.bristleback_bristleback.active)
assert(not abilities.enfos_bb_native_hairball.active)
server=false;assert(not Integration.Restore(hero));server=true;illusion=true;assert(not Integration.Restore(hero))
illusion=false;hero.GetUnitName=function()return 'npc_dota_hero_luna'end;assert(not Integration.Restore(hero))
`));

test('paid rank queries preserve Goo armor, STR scaling and R stacks without reproducing engine damage',()=>lua(`
assert(Integration.Restore(hero))
local function query(id,key)
 local p={ability=abilities[id],ability_special_value=key};assert(scaler:GetModifierOverrideAbilitySpecial(p)==1)
 return scaler:GetModifierOverrideAbilitySpecialValue(p)
end
assert(query('bristleback_viscous_nasal_goo','base_armor')==0)
assert(query('bristleback_viscous_nasal_goo','armor_per_stack')==2)
assert(query('bristleback_quill_spray','quill_base_damage')==80)
assert(query('bristleback_quill_spray','quill_stack_damage')==40)
assert(query('bristleback_quill_spray','max_damage')==500)
assert(query('enfos_bb_native_hairball','goo_stacks')==2)
for id in pairs(values)do ranks[id]=10 end
assert(query('bristleback_viscous_nasal_goo','armor_per_stack')==5)
assert(query('bristleback_quill_spray','quill_base_damage')==140)
assert(query('bristleback_quill_spray','quill_stack_damage')==70)
assert(query('enfos_bb_native_hairball','goo_stacks')==3)
assert(query('bristleback_bristleback','back_damage_reduction')==40)
server=false;hero.IsAlive=function()error('Client getter must not use server API')end
hero.FindModifierByName=function()error('Client getter must not read modifier handles')end
assert(query('bristleback_quill_spray','quill_base_damage')==140)
ranks.enfos_bb_quill_spray=0;assert(query('bristleback_quill_spray','quill_base_damage')==0)
assert(scaler:GetModifierOverrideAbilitySpecial({ability=abilities.bristleback_quill_spray,ability_special_value='projectile_speed'})==0)
`));

test('native casts receive selected entity/world cursor once, with no local damage or search',()=>lua(`
local q=abilities.enfos_bb_viscous_nasal_goo;local r=abilities.enfos_bb_hairball
local t={IsNull=function()return false end,IsAlive=function()return true end}
local point={x=123,y=456}
q.GetCursorTarget=function()return t end;r.GetCursorPosition=function()return point end
q:OnSpellStart();r:OnSpellStart();abilities.enfos_bb_quill_spray:OnSpellStart()
assert(casts==3 and refunds==0)
assert(abilities.bristleback_viscous_nasal_goo.target==t)
assert(abilities.enfos_bb_native_hairball.point==point)
alive=false;r:OnSpellStart();assert(casts==3 and refunds==1)
server=false;q:OnSpellStart();assert(casts==3)
`));

test('autocast relay rejects other issuers and mirrors native cooldown at the cast event',()=>lua(`
local paid=abilities.enfos_bb_quill_spray
EntIndexToHScript=function()return paid end
local order={order_type=20,entindex_ability=7,issuer_player_id_const=1}
Integration.AutocastOrder(order);assert(adds==0)
order.issuer_player_id_const=0;Integration.AutocastOrder(order)
local native=abilities.bristleback_quill_spray;assert(native.auto)
native.cd=2.2;scaler:OnAbilityFullyCast({unit=hero,ability=native});assert(paid.cd==2.2)
server=false;native.cd=1;scaler:OnAbilityFullyCast({unit=hero,ability=native});assert(paid.cd==2.2)
`));

test('rank refresh uses engine intrinsic names and native Scepter suppresses only BB generic bonuses',()=>lua(`
assert(Integration.Restore(hero))
local native=abilities.bristleback_bristleback
native.GetIntrinsicModifierName=function()return 'engine_supplied_intrinsic'end
local handle={IsNull=function()return false end,ForceRefresh=function()refreshes=refreshes+1 end}
modifiers.engine_supplied_intrinsic=handle
assert(Integration.Refresh(hero));assert(refreshes==1 and modifiers.engine_supplied_intrinsic==handle)
assert(adds==4 and modAdds==1)
require('heroes/aghanim_manager')
DOTA_ABILITY_TYPE_ULTIMATE=1
local r={GetAbilityType=function()return 1 end}
local s=setmetatable({GetParent=function()return hero end},modifier_enfos_scepter_upgrade)
assert(s:GetModifierSpellAmplify_Percentage({inflictor=r})==0)
assert(s:GetModifierPercentageCooldown({ability=r})==0)
local shard=setmetatable({role='Tank',GetParent=function()return hero end},modifier_enfos_shard_upgrade)
assert(shard:GetModifierHealthBonus()==350)
hero.GetUnitName=function()return 'npc_dota_hero_axe'end
assert(s:GetModifierSpellAmplify_Percentage({inflictor=r})==40)
assert(s:GetModifierPercentageCooldown({ability=r})==25)
`));

test('Hairball provider cannot be granted by Shard; E owns native Scepter while authored Tank Shard remains separate',()=>{
 const provider=all.enfos_bb_native_hairball;
 assert.equal(provider.BaseClass,'bristleback_hairball');assert.equal(provider.IsGrantedByShard,'0');assert.equal(provider.MaxLevel,'1');
 assert.equal(provider.ScriptFile,undefined);
 assert.equal(all.enfos_bb_hairball.HasScepterUpgrade,undefined);
 assert.equal(all.enfos_bb_bristleback.HasScepterUpgrade,'1');
 assert.equal(all.enfos_bb_warpath.HasShardUpgrade,'1');
 for(const id of ids)assert.equal(all[id].ScriptFile,'abilities/heroes/bristleback/controllers');
 for(const p of ['game/scripts/vscripts/addon_game_mode_client.lua','game/scripts/vscripts/abilities/pve_kits.lua'])
  assert.ok(fs.readFileSync(p,'utf8').includes("require('abilities/heroes/bristleback/modifier_links')"));
});
