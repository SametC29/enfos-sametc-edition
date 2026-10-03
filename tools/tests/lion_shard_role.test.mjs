import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync,execFileSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';

test('Lion Shard replaces generic healing without changing other hero upgrades',()=>{
 const baseline=process.env.LION_SHARD_ROLE_BASELINE?execFileSync('git',['show','HEAD:game/scripts/vscripts/heroes/aghanim_manager.lua'],{encoding:'utf8'}):null;
 const lua=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end
local server=true;function IsServer()return server end;Convars={GetBool=function()return false end}
local manager=${baseline?`assert(load([==[${baseline}]==]))()`:`require('heroes/aghanim_manager')`}
local c={name='npc_dota_hero_lion',alive=true,mods={},adds=0,removes=0}
function c:IsNull()return false end;function c:IsAlive()return self.alive end;function c:GetUnitName()return self.name end
function c:GetEntityIndex()return 876 end;function c:HasModifier(n)return self.mods[n]end
function c:HasItemInInventory()return false end
function c:AddNewModifier(_,_,n,kv)assert(n=='modifier_enfos_shard_upgrade');self.adds=self.adds+1;self.mods[n]=true end
function c:RemoveModifierByName(n)assert(n=='modifier_enfos_shard_upgrade');self.removes=self.removes+1;self.mods[n]=nil end
local m=setmetatable({GetParent=function()return c end},modifier_enfos_shard_upgrade)
for _,isServer in ipairs({true,false})do
 server=isServer;c.name='npc_dota_hero_lion';m:OnCreated({role='Support'})
 assert(m:GetModifierHealAmplify_PercentageSource()==0,'Lion must not stack obsolete generic healing')
 assert(m:IsHidden(),'Lion role marker must not advertise a generic upgrade')
 assert(not m:IsPurgable() and m:IsPermanent() and not m:RemoveOnDeath())
 assert(m:GetModifierHealthBonus()==0 and m:GetModifierAttackSpeedBonus_Constant()==0 and m:GetModifierMoveSpeedBonus_Percentage()==0 and m:GetModifierSpellAmplify_Percentage()==0)
 for _,name in ipairs({'npc_dota_hero_lich','npc_dota_hero_jakiro','npc_dota_hero_vengefulspirit','npc_dota_hero_shadow_shaman'})do
  c.name=name;m:OnCreated({role='Support'});assert(m:GetModifierHealAmplify_PercentageSource()==0,name)
 end
 for _,name in ipairs({'npc_dota_hero_omniknight','npc_dota_hero_dazzle','npc_dota_hero_witch_doctor','npc_dota_hero_disruptor'})do
  c.name=name;m:OnCreated({role='Support'});assert(m:GetModifierHealAmplify_PercentageSource()==25 and not m:IsHidden(),name)
 end
 for _,row in ipairs({{'npc_dota_hero_axe','Tank',350},{'npc_dota_hero_juggernaut','Fighter',35},{'npc_dota_hero_drow_ranger','Carry',15},{'npc_dota_hero_lina','Mage',15}})do
  c.name=row[1];m:OnCreated({role=row[2]})
  local value=row[2]=='Tank' and m:GetModifierHealthBonus() or row[2]=='Fighter' and m:GetModifierAttackSpeedBonus_Constant() or row[2]=='Carry' and m:GetModifierMoveSpeedBonus_Percentage() or m:GetModifierSpellAmplify_Percentage()
  assert(value==row[3],row[1])
 end
end
server=true;c.name='npc_dota_hero_lion';m:OnCreated({role='Support'})
c.mods.modifier_item_aghanims_shard_permanent_buff=true
manager:UpdateHeroAghanimState(c,'Support');for i=1,100 do manager:UpdateHeroAghanimState(c,'Support')end
assert(c.adds==1 and manager.activeShards[876]);c.alive=false;assert(m:GetModifierHealAmplify_PercentageSource()==0 and not m:RemoveOnDeath());c.alive=true
c.mods.modifier_item_aghanims_shard_permanent_buff=nil;manager:UpdateHeroAghanimState(c,'Support');assert(c.removes==1 and not manager.activeShards[876])
c.mods.modifier_item_aghanims_shard_permanent_buff=true;manager:UpdateHeroAghanimState(c,'Support');assert(c.adds==2)
print('Lion Shard role replacement PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:lua,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.equal(r.stderr,'');assert.match(r.stdout,/Lion Shard role replacement PASS/);
 if(!baseline){
  const kv=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
  assert.equal(kv.enfos_lion_demon_soul.HasShardUpgrade,undefined);assert.equal(kv.enfos_lion_mana_drain.HasShardUpgrade,'1');
  for(const lang of ['english','turkish','russian','schinese']){
   const t=JSON.parse(fs.readFileSync(`localization/${lang}.json`,'utf8')).Tokens;
   assert.equal(t.DOTA_Tooltip_Ability_enfos_lion_demon_soul_shard_description,undefined);
   assert.ok(t.DOTA_Tooltip_Ability_enfos_lion_mana_drain_shard_description.includes('2'));
  }
 }
});
