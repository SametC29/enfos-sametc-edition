import test from 'node:test';import assert from 'node:assert/strict';import {spawnSync} from 'node:child_process';
test('Liquid Fire funds attack records at launch and never reuses misses or stale records',()=>{
const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end
local server=true;function IsServer()return server end
Convars={GetBool=function()return false end}
require('abilities/heroes/jakiro/e')
local c={alive=true,removed=false,silenced=false,broken=false,int=100}
function c:IsNull()return self.removed end;function c:IsAlive()return self.alive end;function c:GetTeamNumber()return 2 end;function c:IsIllusion()return false end;function c:IsSilenced()return self.silenced end;function c:PassivesDisabled()return self.broken end;function c:GetIntellect()return self.int end
local function target()return {IsNull=function()return false end,IsAlive=function()return true end,GetTeamNumber=function()return 3 end}end
local t,wrong=target(),target()
local a={ready=true,on=true,removed=false,rank=1,spent=0,hits=0,base=90}
function a:IsNull()return self.removed end;function a:GetLevel()return self.rank end;function a:GetAutoCastState()return self.on end;function a:IsFullyCastable()return self.ready end;function a:GetSpecialValueFor(k)return ({bonus_damage=self.base,slow_as=60,radius=300,duration=5,tick_rate=0.5,building_dmg_pct=75})[k] or 0 end
local m=setmetatable({GetParent=function()return c end,GetAbility=function()return a end},modifier_enfos_jakiro_liquid_fire_passive)
function a:UseResources(mana,health,gold,cd)assert(mana and not health and not gold and cd);self.spent=self.spent+1;self.ready=false;m:OnAttack({attacker=c,target=t,record=99})end
function a:GetCaster()return c end
function a:SnapshotImpact()return enfos_jakiro_liquid_fire.SnapshotImpact(self)end
function a:FireAt(target,snapshot)self.hits=self.hits+1;assert(target==t and snapshot.total==120);m:OnAttackLanded({attacker=c,target=t,record=1})end
m:OnCreated();m:OnAttack({attacker=c,target=t,record=1});assert(a.spent==1 and a.hits==0,'Spend on launch, not impact')
a.on=false;a.base=900;c.int=1000;c.broken=true
m:OnAttackLanded({attacker=c,target=wrong,record=1});assert(a.hits==0,'Exact launched target required')
c.alive=false;m:OnAttackLanded({attacker=c,target=t,record=1});assert(a.hits==1 and a.spent==1,'Funded orb survives toggle/rank/stat/Break/caster death changes')
m:OnAttackLanded({attacker=c,target=t,record=1});assert(a.hits==1,'Record consumed before callback')
c.alive=true;c.int=100;a.base=90;a.on=true;a.ready=true;m:OnAttack({attacker=c,target=t,record=2});m:OnAttackFail({attacker=c,target=t,record=2});m:OnAttackLanded({attacker=c,target=t,record=2});assert(a.hits==1 and a.spent==2,'Miss costs resources, no burn')
a.ready=true;m:OnAttack({attacker=c,target=t,record=3});m:OnAttackRecordDestroy({attacker=c,record=3});m:OnAttackLanded({attacker=c,target=t,record=3});assert(a.hits==1)
a.ready=true;c.silenced=true;m:OnAttack({attacker=c,target=t,record=4});assert(a.spent==3);c.silenced=false
server=false;m:OnAttack({attacker=c,target=t,record=5});assert(a.spent==3);server=true
m:OnAttack({attacker=c,target=t});assert(a.spent==3,'Missing record cannot create untracked orb')
for i=100,1099 do a.ready=true;m:OnAttack({attacker=c,target=t,record=i});m:OnAttackRecordDestroy({attacker=c,record=i});assert(next(m.records)==nil,'Terminal engine events release retained target snapshots')end
a.ready=true;m:OnAttack({attacker=c,target=t,record=6});m:OnDestroy();m:OnAttackLanded({attacker=c,target=t,record=6});assert(a.hits==1 and next(m.records)==nil,'Teardown releases all records')
print('Jakiro E attack records PASS')
`;
const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});assert.equal(r.status,0,r.stderr);assert.match(r.stdout,/Jakiro E attack records PASS/,r.stderr);
});
