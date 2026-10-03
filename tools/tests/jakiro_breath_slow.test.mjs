import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
test('Jakiro Q slow snapshots each hit, transmits client values and refreshes only on a new application',()=>{
 const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
function LinkLuaModifier()end
local server=true;function IsServer()return server end
MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE=1;MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT=2;MODIFIER_PROPERTY_TOOLTIP=3;MODIFIER_PROPERTY_TOOLTIP2=4
Convars={GetBool=function()return false end}
require('abilities/heroes/jakiro/q')
local rank=1;local a={GetSpecialValueFor=function(_,k)return k=='slow_pct' and (rank==1 and 30 or 51) or 0 end}
local parent={GetUnitName=function()return 'ordinary' end}
local sends=0
local function mod()
 return setmetatable({GetAbility=function()return a end,GetParent=function()return parent end,
 SetHasCustomTransmitterData=function(_,on)assert(on)end,
 SendBuffRefreshToClients=function()sends=sends+1 end},modifier_enfos_jakiro_dual_breath_slow)
end
local m=mod();assert(m.OnCreated,'Slow needs application-time ownership')
m:OnCreated({slow_pct=30,attack_slow=40})
assert(m:GetModifierMoveSpeedBonus_Percentage()==-30 and m:GetModifierAttackSpeedBonus_Constant()==-40)
rank=10
assert(m:GetModifierMoveSpeedBonus_Percentage()==-30,'Level-up must not mutate a debuff already on another unit')
local packet=m:AddCustomTransmitterData();server=false;local client=mod();client:HandleCustomTransmitterData(packet)
assert(client:GetModifierMoveSpeedBonus_Percentage()==-30 and client:GetModifierAttackSpeedBonus_Constant()==-40)
client:OnCreated({slow_pct=999});assert(client:GetModifierMoveSpeedBonus_Percentage()==-30)
server=true;m:OnRefresh({slow_pct=51,attack_slow=40});assert(sends==1)
assert(m:GetModifierMoveSpeedBonus_Percentage()==-51)
a=nil;assert(m:GetModifierMoveSpeedBonus_Percentage()==-51,'Applied snapshot survives invalid ability without dereferencing it')
server=false;client:HandleCustomTransmitterData(m:AddCustomTransmitterData());assert(client:GetModifierMoveSpeedBonus_Percentage()==-51 and client:OnTooltip()==51 and client:OnTooltip2()==40)
assert(m:IsDebuff() and m:IsPurgable() and m:GetTexture()=='jakiro_dual_breath')
print('Jakiro Q snapshot/client/refresh PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.match(r.stdout,/Jakiro Q snapshot.*PASS/,r.stderr);
});
