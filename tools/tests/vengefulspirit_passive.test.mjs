import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';

test('Venge Retribution grants only learned, valid owned passive stats and never logs getter spam',()=>{
 const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
function LinkLuaModifier()end
function IsServer()return true end
require('abilities/heroes/vengefulspirit/d')
local u={removed=false,broken=false,illusion=false}
function u:IsNull()return self.removed end
function u:PassivesDisabled()assert(not self.removed,'Stale passive source');return self.broken end
function u:IsIllusion()assert(not self.removed);return self.illusion end
local a={removed=false,rank=1}
function a:IsNull()return self.removed end
function a:GetLevel()assert(not self.removed);return self.rank end
function a:GetSpecialValueFor(k)assert(not self.removed);return k=='bonus_agi' and 20+2*(self.rank-1) or 25+3*(self.rank-1) end
local m=setmetatable({GetParent=function()return u end,GetAbility=function()return a end},modifier_enfos_vs_retribution)
assert(not m:IsHidden() and not m:IsPurgable() and not m:IsPurgeException() and not m:RemoveOnDeath(),'D passive ownership persists without exposing a dispellable skill modifier')
assert(m:GetModifierBonusStats_Agility()==20 and m:GetModifierAttackSpeedBonus_Constant()==25)
a.rank=10;assert(m:GetModifierBonusStats_Agility()==38 and m:GetModifierAttackSpeedBonus_Constant()==52)
a.rank=0;assert(m:GetModifierBonusStats_Agility()==0 and m:GetModifierAttackSpeedBonus_Constant()==0,'Unlearned passive must not grant fallback rank stats')
a.rank=1;u.broken=true;assert(m:GetModifierBonusStats_Agility()==0 and m:GetModifierAttackSpeedBonus_Constant()==0)
u.broken=false;u.illusion=true;assert(m:GetModifierBonusStats_Agility()==0 and m:GetModifierAttackSpeedBonus_Constant()==0)
u.illusion=false;u.removed=true;assert(m:GetModifierBonusStats_Agility()==0 and m:GetModifierAttackSpeedBonus_Constant()==0)
u.removed=false;a.removed=true;assert(m:GetModifierBonusStats_Agility()==0 and m:GetModifierAttackSpeedBonus_Constant()==0)
a.removed=false;u=nil;assert(m:GetModifierBonusStats_Agility()==0 and m:GetModifierAttackSpeedBonus_Constant()==0)
print('Venge Retribution valid source PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.match(r.stdout,/Venge Retribution valid source PASS/,r.stderr);
});

test('Venge E/D lifecycle tracing is default-off and does not log periodic stat queries',()=>{
 const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
function LinkLuaModifier()end
function IsServer()return true end
local enabled=false;local records={}
Convars={RegisterConvar=function(_,name,default)assert(name=='enfos_hero_trace' and default=='0')end,
 GetBool=function()return enabled end}
local realprint=print;function print(line)records[#records+1]=line end
require('abilities/heroes/vengefulspirit/d');require('abilities/heroes/vengefulspirit/e')
local u={IsNull=function()return false end,GetUnitName=function()return 'npc_dota_hero_vengefulspirit' end,
 PassivesDisabled=function()return false end,IsIllusion=function()return false end}
local a={IsNull=function()return false end,GetLevel=function()return 1 end,GetSpecialValueFor=function()return 20 end}
local classes={modifier_enfos_vs_retribution,modifier_enfos_vs_vengeance_aura,modifier_enfos_vs_vengeance_aura_buff}
local mods={}
for _,cls in ipairs(classes)do
 local m=setmetatable({GetParent=function()return u end,GetCaster=function()return u end,GetAbility=function()return a end},cls)
 mods[#mods+1]=m;m:OnCreated();m:OnRefresh();m:OnDestroy()
 assert(not m:IsPurgable() and not m:IsPurgeException(),'Passive modifiers explicitly reject both dispel classes')
end
assert(mods[2]:IsHidden() and not mods[2]:RemoveOnDeath() and not mods[2]:IsAuraActiveOnDeath(),'Retained emitter must not emit while dead or duplicate recipient icon')
assert(not mods[3]:IsHidden() and mods[3]:RemoveOnDeath(),'Recipient feedback remains visible and ends on recipient death')
assert(#records==0,'Disabled tracing must stay silent')
enabled=true
for _,m in ipairs(mods)do m:OnCreated();m:OnRefresh();m:OnDestroy() end
assert(#records==9,'One trace per lifecycle event, without synthetic gameplay events')
assert(records[1]:find('[VENGEFUL_SPIRIT_TRACE][D]',1,true))
assert(records[4]:find('[VENGEFUL_SPIRIT_TRACE][E]',1,true))
for i=1,100 do mods[1]:GetModifierBonusStats_Agility();mods[1]:GetModifierAttackSpeedBonus_Constant();mods[3]:GetModifierBaseDamageOutgoing_Percentage() end
assert(#records==9,'Getter polling must not flood traces')
realprint('Venge passive lifecycle trace PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.match(r.stdout,/Venge passive lifecycle trace PASS/,r.stderr);
});
