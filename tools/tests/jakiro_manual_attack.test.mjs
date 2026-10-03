import test from 'node:test';import assert from 'node:assert/strict';import {spawnSync} from 'node:child_process';
test('Manual Liquid Fire launches one ordinary funded attack and burns only on its hit',()=>{
const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end
local server=true;function IsServer()return server end
Convars={GetBool=function()return false end};require('abilities/heroes/jakiro/e')
for _,mode in ipairs({'hit','miss','no_event','removed_ability','launch_removes_ability','removed_target','client','disarmed'})do
 local a,c,t,m;local launches,burns=0,0
 c={IsNull=function()return false end,IsAlive=function()return true end,GetTeamNumber=function()return 2 end,IsIllusion=function()return false end,IsSilenced=function()return false end,IsDisarmed=function()return mode=='disarmed' end,GetIntellect=function()return 100 end}
 t={removed=false,IsNull=function(self)return self.removed end,IsAlive=function()return true end,GetTeamNumber=function()return 3 end,TriggerSpellAbsorb=function()error('Attack modifier must not invoke direct spell-block')end}
 a=setmetatable({removed=false},enfos_jakiro_liquid_fire)
 function a:IsNull()return self.removed end;function a:GetCaster()return c end;function a:GetCursorTarget()return t end;function a:GetLevel()return 1 end;function a:GetAutoCastState()return false end;function a:IsFullyCastable()return false end
 function a:GetSpecialValueFor(k)return ({bonus_damage=90,slow_as=60,radius=300,duration=5,tick_rate=0.5,building_dmg_pct=75})[k] or 0 end
 function a:UseResources()error('Manual engine funding must not be repeated')end
 function a:FireAt(target,snapshot)assert(target==t and snapshot.total==120);burns=burns+1 end
 m=setmetatable({GetParent=function()return c end,GetAbility=function()return a end},modifier_enfos_jakiro_liquid_fire_passive);server=true;m:OnCreated()
 function c:PerformAttack(target,orb,procs,skip,invis,projectile,fake,neverMiss)
  assert(target==t and orb and procs and not skip and not invis and projectile and not fake and not neverMiss)
  launches=launches+1;assert(burns==0)
  if mode~='no_event' then m:OnAttack({attacker=c,target=t,record=1})end
  if mode=='launch_removes_ability' then a.removed=true end
  assert(burns==0,'No burn before attack impact')
 end
 server=mode~='client';a:OnSpellStart();assert(a.manual_target==nil,'One-use token never survives PerformAttack')
 if mode=='removed_ability' then a.removed=true elseif mode=='removed_target' then t.removed=true end
 if mode=='miss' then m:OnAttackFail({attacker=c,target=t,record=1})end
 m:OnAttackLanded({attacker=c,target=t,record=1});m:OnAttackLanded({attacker=c,target=t,record=1})
 assert(launches==((mode=='client' or mode=='disarmed') and 0 or 1))
 assert(burns==(mode=='hit' and 1 or 0),'Unexpected impact: '..mode)
 server=true
end
print('Jakiro E manual attack bridge PASS')
`;
const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});assert.equal(r.status,0,r.stderr);assert.match(r.stdout,/Jakiro E manual attack bridge PASS/,r.stderr);
});
