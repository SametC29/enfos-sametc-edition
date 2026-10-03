import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync,execFileSync} from 'node:child_process';

test('Lion consumed native Shard is detected and existing upgrade reconciliation stays idempotent',()=>{
 const baseline=process.env.LION_SHARD_BASELINE?execFileSync('git',['show','HEAD:game/scripts/vscripts/heroes/aghanim_manager.lua'],{encoding:'utf8'}):null;
 const lua=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end
function IsServer()return true end;Convars={GetBool=function()return false end}
local manager=${baseline?`assert(load([==[${baseline}]==]))()`:`require('heroes/aghanim_manager')`}
local c={name='npc_dota_hero_lion',mods={},items={},adds=0,removes=0}
function c:IsNull()return self.removed end;function c:GetUnitName()return self.name end
function c:GetEntityIndex()return 456 end
function c:HasModifier(n)assert(not self.removed);return self.mods[n]==true end
function c:HasItemInInventory(n)assert(not self.removed);return self.items[n]==true end
function c:AddNewModifier(_,_,name,params)assert(name=='modifier_enfos_shard_upgrade' and params.role=='Support');self.adds=self.adds+1 end
function c:RemoveModifierByName(name)assert(name=='modifier_enfos_shard_upgrade');self.removes=self.removes+1 end
c.mods.modifier_item_aghanims_shard_permanent_buff=true
assert(manager:HasShard(c),'Consumed native Lion Shard must remain detectable without inventory item')
manager:UpdateHeroAghanimState(c,'Support');assert(c.adds==1 and manager.activeShards[456])
for i=1,100 do manager:UpdateHeroAghanimState(c,'Support')end;assert(c.adds==1 and c.removes==0,'Polling cannot duplicate acquisition')
c.mods={};manager:UpdateHeroAghanimState(c,'Support');assert(c.removes==1 and not manager.activeShards[456])
for i=1,100 do manager:UpdateHeroAghanimState(c,'Support')end;assert(c.removes==1)
for _,id in ipairs({'modifier_item_aghanims_shard_permanent_buff','modifier_item_aghanims_shard_consumed','modifier_aghanims_shard_consumed'})do
 c.mods[id]=true;assert(manager:HasShard(c));c.mods={};assert(not manager:HasShard(c))
end
c.items.item_aghanims_shard=true;assert(manager:HasShard(c));c.items={};assert(not manager:HasShard(c))
c.mods.modifier_item_aghanims_shard_permanent_buff=true;c.removed=true;assert(not manager:HasShard(c));c.removed=false
for _,name in ipairs({'npc_dota_hero_lich','npc_dota_hero_vengefulspirit','npc_dota_hero_jakiro'})do c.name=name;assert(manager:HasShard(c),'Preserve reviewed native recognition')end
for _,name in ipairs({'npc_dota_hero_lina','npc_dota_hero_sven','npc_dota_hero_puck'})do c.name=name;assert(not manager:HasShard(c),'Unreviewed permanent-buff policy unchanged')end
c.name='npc_dota_hero_lion';manager:UpdateHeroAghanimState(c,'Support');assert(c.adds==2,'Reacquisition restores existing upgrade once')
print('Lion Shard detection PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:lua,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.equal(r.stderr,'');assert.match(r.stdout,/Lion Shard detection PASS/);
});
