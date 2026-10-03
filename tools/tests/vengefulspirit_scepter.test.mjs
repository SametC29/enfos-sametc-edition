import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';

test('Venge Scepter reconciles the native bridge without duplicate ranks or generic ultimate bonuses',()=>{
 const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
function LinkLuaModifier()end
local server=true
function IsServer()return server end
require('abilities/heroes/vengefulspirit/e')
local U=require('abilities/heroes/vengefulspirit/upgrades')
local A=require('heroes/aghanim_manager')
local aura={rank=1,removed=false}
function aura:IsNull()return self.removed end
function aura:GetLevel()return self.rank end
function aura:GetSpecialValueFor(k)return ({bonus_damage_pct=20,self_multiplier=25,scepter_self_bonus=10})[k] or 0 end
local bridge={rank=0,hidden=false,removed=false,sets=0}
function bridge:IsNull()return self.removed end
function bridge:GetLevel()return self.rank end
function bridge:SetLevel(rank)self.rank=rank;self.sets=self.sets+1;if self.callback then self.callback()end end
function bridge:IsHidden()assert(not self.removed,'stale bridge access');return self.hidden end
function bridge:SetHidden(hidden)self.hidden=hidden end
local hero={removed=false,scepter=true,consumed=false,adds=0,mods=0,broken=false,illusion=false,strong=false}
function hero:IsNull()return self.removed end
function hero:GetUnitName()return 'npc_dota_hero_vengefulspirit' end
function hero:GetEntityIndex()return 8 end
function hero:FindAbilityByName(name)if name=='enfos_vs_vengeance_aura' then return aura end;return self.bridge end
function hero:AddAbility(name)assert(name==U.bridge);self.adds=self.adds+1;if self.fail then return nil end;self.bridge=bridge;return bridge end
function hero:HasScepter()return self.scepter end
function hero:HasModifier(name)return self.consumed and name=='modifier_item_ultimate_scepter_consumed' end
function hero:AddNewModifier()self.mods=self.mods+1 end
function hero:RemoveModifierByName()end
function hero:PassivesDisabled()return self.broken end
function hero:IsIllusion()return self.illusion end
function hero:IsStrongIllusion()return self.strong end
assert(U.Reconcile(hero,true));assert(hero.adds==1 and bridge.rank==1 and bridge.hidden)
assert(U.Reconcile(hero,true));assert(hero.adds==1 and bridge.sets==1,'Repeated reconciliation must not retrain or add duplicates')
assert(U.Reconcile(hero,false) and bridge.rank==0)
aura.rank=0;assert(U.Reconcile(hero,true) and bridge.rank==0,'Unlearned E must not authorize death illusion')
aura.rank=10;assert(U.Reconcile(hero,true) and bridge.rank==1,'Native bridge never uses custom ten-rank curve')
bridge.callback=function()bridge.removed=true end
assert(U.Reconcile(hero,false)==false,'Native rank callbacks may invalidate the bridge')
bridge.callback=nil;bridge.removed=false
hero.removed=true;assert(U.Reconcile(hero,true)==false);hero.removed=false
aura.removed=true;assert(U.Reconcile(hero,true)==false);aura.removed=false
hero.bridge=nil;hero.fail=true;assert(U.Reconcile(hero,true)==false);hero.fail=false
server=false;assert(U.Reconcile(hero,true)==false);server=true
hero.bridge=bridge;hero.scepter=true
A:UpdateHeroAghanimState(hero,'Support');assert(bridge.rank==1 and hero.mods==1)
bridge.rank=0;bridge.hidden=false
A:UpdateHeroAghanimState(hero,'Support');assert(bridge.rank==1 and bridge.hidden and hero.mods==1,'Active state must repair a lost bridge without duplicate modifier')
hero.scepter=false;hero.consumed=true
assert(A:HasScepter(hero));A:UpdateHeroAghanimState(hero,'Support');assert(bridge.rank==1,'Consumed Blessing retains upgrade')
local buff=setmetatable({GetParent=function()return hero end,GetCaster=function()return hero end,GetAbility=function()return aura end},modifier_enfos_vs_vengeance_aura_buff)
assert(buff:GetModifierBaseDamageOutgoing_Percentage()==27,'Scepter adds 10% of aura bonus to native 25% self multiplier')
hero.illusion=true;assert(buff:GetModifierBaseDamageOutgoing_Percentage()==0)
hero.strong=true;assert(buff:GetModifierBaseDamageOutgoing_Percentage()==27,'Own native strong illusion can receive its copied aura')
hero.broken=true;assert(buff:GetModifierBaseDamageOutgoing_Percentage()==0);hero.broken=false
local ally={IsNull=function()return false end,IsIllusion=function()return false end}
buff.GetParent=function()return ally end;assert(buff:GetModifierBaseDamageOutgoing_Percentage()==20,'Allies never receive self/Scepter multiplier')
hero.illusion=false;hero.strong=false;hero.consumed=false
A:UpdateHeroAghanimState(hero,'Support');assert(bridge.rank==0)
buff.GetParent=function()return hero end;assert(buff:GetModifierBaseDamageOutgoing_Percentage()==25)
local e=setmetatable({GetCaster=function()return hero end},enfos_vs_vengeance_aura)
hero.scepter=true;e:OnUpgrade();assert(bridge.rank==1)
local modifier=setmetatable({GetParent=function()return hero end},modifier_enfos_scepter_upgrade)
DOTA_ABILITY_TYPE_ULTIMATE=1
local ultimate={GetAbilityType=function()return 1 end}
assert(modifier:IsHidden() and modifier:GetModifierSpellAmplify_Percentage({inflictor=ultimate})==0 and modifier:GetModifierPercentageCooldown({ability=ultimate})==0)
modifier.GetParent=function()return {GetUnitName=function()return 'npc_dota_hero_omniknight' end}end
assert(modifier:GetModifierSpellAmplify_Percentage({inflictor=ultimate})==40 and modifier:GetModifierPercentageCooldown({ability=ultimate})==25,'Other heroes retain their upgrade policy')
print('Venge Scepter reconciliation PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.match(r.stdout,/Venge Scepter reconciliation PASS/,r.stderr);
});

test('Venge native lifecycle bridge is hidden, rank one and adds no duplicate aura damage',()=>{
 const a=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
 const h=parseKV(fs.readFileSync('game/scripts/npc/npc_heroes_custom.txt','utf8')).DOTAHeroes;
 assert.equal(h.npc_dota_hero_vengefulspirit.Ability6,'enfos_vs_scepter_native');
 const b=a.enfos_vs_scepter_native;
 assert.equal(b.BaseClass,'vengefulspirit_command_aura');assert.equal(b.MaxLevel,'1');
 assert.match(b.AbilityBehavior,/HIDDEN/);assert.match(b.AbilityBehavior,/NOT_LEARNABLE/);
 assert.equal(b.AbilityValues.bonus_base_damage,'0');assert.equal(b.AbilityValues.aura_radius,'0');
 assert.equal(b.AbilityValues.scepter_illusion_damage_out_pct,'100');assert.equal(b.AbilityValues.scepter_illusion_damage_in_pct,'100');
 assert.equal(a.enfos_vs_vengeance_aura.HasScepterUpgrade,'1');assert.equal(a.enfos_vs_nether_swap.HasScepterUpgrade,undefined);
 const source=fs.readFileSync('game/scripts/vscripts/abilities/heroes/vengefulspirit/upgrades.lua','utf8');
 assert.doesNotMatch(source,/CreateIllusions|SetContextThink|StartIntervalThink/);
 // This contract intentionally cannot certify native C++ death/XP/respawn behavior.
});
