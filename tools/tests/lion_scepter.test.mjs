import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync,execFileSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';

test('Lion Scepter uses its Finger upgrade instead of generic ultimate bonuses',()=>{
 const baseline=process.env.LION_SCEPTER_BASELINE?execFileSync('git',['show','HEAD:game/scripts/vscripts/heroes/aghanim_manager.lua'],{encoding:'utf8'}):null;
 const lua=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end
local server=true;function IsServer()return server end;Convars={GetBool=function()return false end};DOTA_ABILITY_TYPE_ULTIMATE=1
local manager=${baseline?`assert(load([==[${baseline}]==]))()`:`require('heroes/aghanim_manager')`}
local c={name='npc_dota_hero_lion',mods={},items={},adds=0,removes=0}
function c:IsNull()return self.removed end;function c:GetUnitName()return self.name end
function c:GetEntityIndex()return 943 end;function c:HasScepter()return self.native end
function c:HasModifier(n)return self.mods[n]end;function c:HasItemInInventory(n)return self.items[n]end
function c:AddNewModifier(_,_,n)assert(n=='modifier_enfos_scepter_upgrade');self.adds=self.adds+1 end
function c:RemoveModifierByName(n)assert(n=='modifier_enfos_scepter_upgrade');self.removes=self.removes+1 end
local m=setmetatable({GetParent=function()return c end},modifier_enfos_scepter_upgrade)
local ult={GetAbilityType=function()return 1 end};local basic={GetAbilityType=function()return 0 end}
for _,mode in ipairs({true,false})do
 server=mode;c.name='npc_dota_hero_lion'
 assert(m:GetModifierSpellAmplify_Percentage({inflictor=ult})==0,'Lion must not stack generic40% ultimate amp')
 assert(m:GetModifierPercentageCooldown({ability=ult})==0,'Lion must not stack generic25% ultimate CDR')
 assert(m:IsHidden() and not m:IsPurgable() and m:IsPermanent() and not m:RemoveOnDeath())
 for _,name in ipairs({'npc_dota_hero_jakiro','npc_dota_hero_vengefulspirit','npc_dota_hero_lich','npc_dota_hero_sven','npc_dota_hero_shadow_shaman','npc_dota_hero_tidehunter'})do
  c.name=name;assert(m:GetModifierSpellAmplify_Percentage({inflictor=ult})==0 and m:GetModifierPercentageCooldown({ability=ult})==(name=='npc_dota_hero_shadow_shaman' and 25 or 0),name)
 end
 for _,name in ipairs({'npc_dota_hero_lina','npc_dota_hero_axe','npc_dota_hero_puck','npc_dota_hero_dazzle'})do
  c.name=name;assert(m:GetModifierSpellAmplify_Percentage({inflictor=ult})==40 and m:GetModifierPercentageCooldown({ability=ult})==25,name)
  assert(m:GetModifierSpellAmplify_Percentage({inflictor=basic})==0 and m:GetModifierPercentageCooldown({ability=basic})==0 and not m:IsHidden(),name)
 end
end
server=true;c.name='npc_dota_hero_lion';c.native=true;assert(manager:HasScepter(c));c.native=false
for _,n in ipairs({'modifier_item_ultimate_scepter_consumed','modifier_item_ascended_aghanims_blessing_passive','modifier_item_ascended_aghanims_blessing_consumed','modifier_ultimate_scepter_consumed'})do
 c.mods[n]=true;assert(manager:HasScepter(c));c.mods={};assert(not manager:HasScepter(c))
end
c.items.item_ultimate_scepter=true;assert(manager:HasScepter(c))
manager:UpdateHeroAghanimState(c,'Support');for i=1,100 do manager:UpdateHeroAghanimState(c,'Support')end;assert(c.adds==1)
c.items={};manager:UpdateHeroAghanimState(c,'Support');assert(c.removes==1)
c.mods.modifier_item_ultimate_scepter_consumed=true;manager:UpdateHeroAghanimState(c,'Support');assert(c.adds==2)
c.removed=true;assert(not manager:HasScepter(c))
print('Lion Scepter core PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:lua,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.equal(r.stderr,'');assert.match(r.stdout,/Lion Scepter core PASS/);
 if(!baseline){
 const kv=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities.enfos_lion_finger_of_death;
 assert.equal(kv.AbilityValues.scepter_bonus_damage,'100');assert.equal(kv.AbilityValues.splash_radius,'325');assert.match(kv.AbilityBehavior,/AOE/);
 for(const lang of ['english','turkish','russian','schinese']){
  const t=JSON.parse(fs.readFileSync('localization/'+lang+'.json','utf8')).Tokens;
  assert.ok(t.DOTA_Tooltip_Ability_enfos_lion_finger_of_death_scepter_description.includes('100'));
  assert.ok(t.DOTA_Tooltip_Ability_enfos_lion_finger_of_death_scepter_description.includes('325'));
 }
 }
});
