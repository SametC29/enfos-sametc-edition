import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';

test('Jakiro fifth passive only grants learned valid stats and reports lifecycle without getter spam',()=>{
 const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
function LinkLuaModifier()end
local server=true;function IsServer()return server end
MODIFIER_PROPERTY_STATS_INTELLECT_BONUS=1;MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT=2
MODIFIER_PROPERTY_TOOLTIP=3;MODIFIER_PROPERTY_TOOLTIP2=4
local enabled=false;local lines={};local realprint=print
Convars={GetBool=function()return enabled end}
GameRules={GetGameTime=function()return 9 end}
function print(s)lines[#lines+1]=s end
require('abilities/heroes/jakiro/d')
local c={removed=false,broken=false,illusion=false,alive=true}
function c:IsNull()return self.removed end
function c:PassivesDisabled()assert(not self.removed,'Stale stat source');return self.broken end
function c:IsIllusion()assert(not self.removed);return self.illusion end
function c:GetUnitName()assert(not self.removed);return 'npc_dota_hero_jakiro' end
local a={removed=false,rank=0}
function a:IsNull()return self.removed end
function a:GetLevel()assert(not self.removed);return self.rank end
function a:GetSpecialValueFor(k)
 assert(not self.removed)
 return k=='bonus_int' and 20+2*math.max(0,self.rank-1) or 30+3*math.max(0,self.rank-1)
end
local m=setmetatable({GetParent=function()return c end,GetAbility=function()return a end},modifier_enfos_jakiro_double_trouble)
assert(m:GetModifierBonusStats_Intellect()==0 and m:GetModifierAttackSpeedBonus_Constant()==0,'Unlearned D must not receive fallback rank-one stats')
assert(not m:IsHidden() and not m:IsPurgable() and not m:IsPurgeException() and not m:RemoveOnDeath())
assert(m:GetTexture()=='jakiro_liquid_fire')
assert(#m:DeclareFunctions()==4)
for rank=1,10 do
 a.rank=rank
 assert(m:GetModifierBonusStats_Intellect()==20+2*(rank-1))
 assert(m:GetModifierAttackSpeedBonus_Constant()==30+3*(rank-1))
 assert(m:OnTooltip()==20+2*(rank-1) and m:OnTooltip2()==30+3*(rank-1))
end
c.broken=true;assert(m:OnTooltip()==0 and m:OnTooltip2()==0)
c.broken=false;c.illusion=true;assert(m:OnTooltip()==0 and m:OnTooltip2()==0)
c.illusion=false;c.alive=false;assert(m:OnTooltip()==38 and m:OnTooltip2()==57,'Ordinary death does not discard intrinsic ownership')
c.removed=true;assert(m:OnTooltip()==0 and m:OnTooltip2()==0)
c.removed=false;a.removed=true;assert(m:OnTooltip()==0 and m:OnTooltip2()==0)
a.removed=false;a.rank=1
m:OnCreated();m:OnRefresh();m:OnDestroy();assert(#lines==0,'Default-off lifecycle logging')
enabled=true;m:OnCreated();m:OnRefresh();m:OnDestroy();assert(#lines==3)
for i=1,200 do m:GetModifierBonusStats_Intellect();m:OnTooltip2()end
assert(#lines==3,'No logging from periodic stat/HUD queries')
server=false;m:OnCreated();assert(#lines==3,'No client lifecycle log')
realprint('Jakiro D learned stats/lifecycle/tooltip PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.match(r.stdout,/Jakiro D learned stats.*PASS/,r.stderr);
});
