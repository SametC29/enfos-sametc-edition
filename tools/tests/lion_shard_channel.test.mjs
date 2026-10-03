import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync,execFileSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';

test('Lion Shard grants live channel-only defense and increased break distance without full magic immunity',()=>{
 const kv=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities.enfos_lion_mana_drain;
 const baseline=process.env.LION_SHARD_CHANNEL_BASELINE?execFileSync('git',['show','HEAD:game/scripts/vscripts/abilities/heroes/lion/e.lua'],{encoding:'utf8'}):null;
 const lua=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end
local server=true;function IsServer()return server end;Convars={GetBool=function()return false end}
MODIFIER_STATE_DEBUFF_IMMUNE=56;MODIFIER_STATE_MAGIC_IMMUNE=9000 -- mock-only unrelated state identifier
MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS=84
${baseline?`assert(load([==[${baseline}]==]))()`:`require('abilities/heroes/lion/e')`}
local c={alive=true,shard=false}
function c:IsNull()return self.removed end;function c:IsAlive()return self.alive end;function c:GetUnitName()return 'npc_dota_hero_lion' end
function c:HasModifier(n)return self.shard and n=='modifier_item_aghanims_shard_permanent_buff' end
function c:HasItemInInventory()return false end
local a=setmetatable({rank=1,channeling=true},enfos_lion_mana_drain)
function a:IsNull()return self.removed end;function a:GetCaster()return self.foreign or c end;function a:GetLevel()return self.rank end
function a:IsChanneling()assert(server,'Server-only query called from client');return self.channeling end
function a:GetSpecialValueFor(k)return ({break_distance=1100,shard_break_distance_bonus=200,shard_magic_resistance=60})[k] or 0 end
local m=setmetatable({GetParent=function()return c end,GetAbility=function()return a end},modifier_enfos_lion_mana_drain_channel)
function m:IsNull()return self.removed end
assert(m.CheckState and m.GetModifierMagicalResistanceBonus and a.GetDrainBreakDistance,'Shard channel callbacks absent')
for _,side in ipairs({true,false})do
 server=side
 for rank=1,10 do
  a.rank=rank;c.shard=false;assert(m:GetModifierMagicalResistanceBonus()==0 and not m:CheckState()[56] and a:GetDrainBreakDistance()==1100)
  c.shard=true;assert(m:GetModifierMagicalResistanceBonus()==60 and m:CheckState()[56] and a:GetDrainBreakDistance()==1300)
  for state in pairs(m:CheckState())do assert(state==56,'Debuff immunity must not become full magic immunity')end
 end
end
server=true;a.rank=0;assert(m:GetModifierMagicalResistanceBonus()==0 and not m:CheckState()[56]);a.rank=10
for _,side in ipairs({true,false})do server=side;a.foreign={};assert(m:GetModifierMagicalResistanceBonus()==0 and not m:CheckState()[56],'Borrowed source cannot grant Shard defense');a.foreign=nil end
server=true
for _,mode in ipairs({'closed','removed modifier','removed ability','removed caster','dead caster','stopped channel'})do
 if mode=='closed' then m.closed=true elseif mode=='removed modifier' then m.removed=true elseif mode=='removed ability' then a.removed=true
 elseif mode=='removed caster' then c.removed=true elseif mode=='dead caster' then c.alive=false else a.channeling=false end
 assert(m:GetModifierMagicalResistanceBonus()==0 and not m:CheckState()[56],mode)
 m.closed=false;m.removed=false;a.removed=false;c.removed=false;c.alive=true;a.channeling=true
end
assert(m:GetTexture()=='lion_mana_drain' and not m:IsHidden() and not m:IsPurgable() and not m:IsPurgeException())
local funcs=m:DeclareFunctions();assert(#funcs==1 and funcs[1]==84)
print('Lion Shard channel PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:lua,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.equal(r.stderr,'');assert.match(r.stdout,/Lion Shard channel PASS/);
 assert.equal(kv.HasShardUpgrade,'1');assert.equal(kv.AbilityValues.shard_break_distance_bonus,'200');assert.equal(kv.AbilityValues.shard_magic_resistance,'60');
 for(const lang of ['english','turkish','russian','schinese']){
  const t=JSON.parse(fs.readFileSync(`localization/${lang}.json`,'utf8')).Tokens;
  assert.ok(t.DOTA_Tooltip_Ability_enfos_lion_mana_drain_shard_description);
  assert.ok(t.DOTA_Tooltip_modifier_enfos_lion_mana_drain_channel_Description.includes('MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS%'));
 }
});
