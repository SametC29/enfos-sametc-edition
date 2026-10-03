import test from 'node:test';import assert from 'node:assert/strict';import {spawnSync} from 'node:child_process';
test('Jakiro Shard mana uses authoritative acquisition and live engine base cost',()=>{
const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end
function IsServer()return true end;Convars={GetBool=function()return false end}
local manager=require('heroes/aghanim_manager');require('abilities/heroes/jakiro/e')
local c={name='npc_dota_hero_jakiro',removed=false,mods={},items={}}
function c:IsNull()return self.removed end;function c:GetUnitName()return self.name end;function c:HasModifier(n)return self.mods[n]==true end;function c:HasItemInInventory(n)return self.items[n]==true end
local calls=0;local a=setmetatable({GetCaster=function()return c end,BaseClass={GetManaCost=function(_,level)calls=calls+1;return level==9 and 33 or 20 end}},enfos_jakiro_liquid_fire)
assert(a.GetManaCost,'Native Shard mana callback missing')
for rank=0,9 do assert(a:GetManaCost(rank)==(rank==9 and 33 or 20))end
local before=calls
c.mods.modifier_item_aghanims_shard_permanent_buff=true;assert(manager:HasShard(c));assert(a:GetManaCost(-1)==0 and a:GetManaCost(9)==0 and calls==before)
function IsServer()return false end;assert(a:GetManaCost(0)==0,'Client must show same live Shard mana');function IsServer()return true end
c.mods={};assert(a:GetManaCost(-1)==20,'Loss restores native base cost without stale cache')
for _,id in ipairs({'modifier_item_aghanims_shard_consumed','modifier_aghanims_shard_consumed'})do c.mods[id]=true;assert(a:GetManaCost(0)==0);c.mods={}end
c.items.item_aghanims_shard=true;assert(a:GetManaCost(0)==0);c.items={}
c.removed=true;assert(not manager:HasShard(c));assert(a:GetManaCost(0)==20);c.removed=false
c.name='npc_dota_hero_lina';c.mods.modifier_item_aghanims_shard_permanent_buff=true;assert(not manager:HasShard(c),'Do not migrate unreviewed hero permanent-buff policy')
c.name='npc_dota_hero_jakiro';c.mods.modifier_item_aghanims_shard_permanent_buff=true;c.mana=0
function c:GetTeamNumber()return 2 end;function c:IsAlive()return true end;function c:IsIllusion()return false end
function a:GetLevel()return 1 end;function a:GetAutoCastState()return true end
function a:IsNull()return false end;function a:IsFullyCastable()return not self.cd and c.mana>=self:GetManaCost(-1)end
function a:SnapshotImpact()return {}end
local funded=0;function a:UseResources(mana,health,gold,cd)assert(mana and not health and not gold and cd);funded=funded+1;c.mana=c.mana-self:GetManaCost(-1);self.cd=true end
local orb=setmetatable({GetParent=function()return c end,GetAbility=function()return a end},modifier_enfos_jakiro_liquid_fire_passive);orb:OnCreated()
local target={IsNull=function()return false end,IsAlive=function()return true end,GetTeamNumber=function()return 3 end}
orb:OnAttack({attacker=c,target=target,record=1});assert(c.mana==0 and funded==1 and a.cd and orb.records[1],'Shard zero mana still funds one real cooldown launch')
orb:OnAttack({attacker=c,target=target,record=2});assert(funded==1 and not orb.records[2],'Shard never bypasses ordinary cooldown');orb:OnAttackFail({attacker=c,record=1});assert(not orb.records[1])
print('Jakiro E shard mana PASS')
`;
const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});assert.equal(r.status,0,r.stderr);assert.match(r.stdout,/Jakiro E shard mana PASS/,r.stderr);
});
