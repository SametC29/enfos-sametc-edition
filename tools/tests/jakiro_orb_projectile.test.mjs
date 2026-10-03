import test from 'node:test';import assert from 'node:assert/strict';import {spawnSync} from 'node:child_process';
test('Liquid Fire selects native fire projectile without state mutation or client server-only calls',()=>{
const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end
local server=true;function IsServer()return server end;Convars={GetBool=function()return false end};MODIFIER_PROPERTY_PROJECTILE_NAME=50
require('abilities/heroes/jakiro/e')
local c={removed=false,alive=true,illusion=false,silenced=false,disarmed=false,broken=false}
function c:IsNull()return self.removed end;function c:IsAlive()return self.alive end;function c:IsIllusion()return self.illusion end;function c:IsSilenced()return self.silenced end;function c:IsDisarmed()return self.disarmed end;function c:GetTeamNumber()return 2 end
local t={removed=false,alive=true,team=3,IsNull=function(self)return self.removed end,IsAlive=function(self)return self.alive end,GetTeamNumber=function(self)return self.team end}
local aggro=t;function c:GetAggroTarget()assert(server,'Server-only API called on client');return aggro end
local a={removed=false,rank=1,auto=true,ready=true,IsNull=function(self)return self.removed end,GetLevel=function(self)return self.rank end,GetAutoCastState=function(self)return self.auto end,IsFullyCastable=function(self)assert(server);return self.ready end}
local m=setmetatable({GetParent=function()return c end,GetAbility=function()return a end},modifier_enfos_jakiro_liquid_fire_passive);m:OnCreated()
assert(m.GetModifierProjectileName,'Native fire selector missing')
assert(m:DeclareFunctions()[1]==MODIFIER_PROPERTY_PROJECTILE_NAME,'Engine property must be declared')
local path='particles/units/heroes/hero_jakiro/jakiro_base_attack_fire.vpcf'
for i=1,100 do assert(m:GetModifierProjectileName()==path)end;assert(next(m.records)==nil and a.ready,'Visual query never launches, funds or records an attack')
for _,mode in ipairs({'cooldown','off','rank0','friendly','dead_target','removed_target','removed_caster','dead_caster','illusion','silenced','disarmed','removed_ability','no_aggro','client'})do
 if mode=='cooldown'then a.ready=false elseif mode=='off'then a.auto=false elseif mode=='rank0'then a.rank=0 elseif mode=='friendly'then t.team=2 elseif mode=='dead_target'then t.alive=false elseif mode=='removed_target'then t.removed=true elseif mode=='removed_caster'then c.removed=true elseif mode=='dead_caster'then c.alive=false elseif mode=='illusion'then c.illusion=true elseif mode=='silenced'then c.silenced=true elseif mode=='disarmed'then c.disarmed=true elseif mode=='removed_ability'then a.removed=true elseif mode=='no_aggro'then aggro=nil else server=false end
 assert(m:GetModifierProjectileName()==nil,'Rejected visual eligibility: '..mode)
 a.ready=true;a.auto=true;a.rank=1;t.team=3;t.alive=true;t.removed=false;c.removed=false;c.alive=true;c.illusion=false;c.silenced=false;c.disarmed=false;a.removed=false;aggro=t;server=true
end
c.broken=true;assert(m:GetModifierProjectileName()==path,'Active orb is not disabled by Break')
a.auto=false;a.ready=false;a.manual_target=t;assert(m:GetModifierProjectileName()==path,'Engine-funded manual launch does not require a second mana/cooldown check');a.manual_target=nil;assert(not m:GetModifierProjectileName(),'Manual token cannot leave stale fire selector')
m:OnDestroy();assert(not m:GetModifierProjectileName(),'Teardown keeps ordinary projectile')
print('Jakiro E projectile selector PASS')
`;
const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});assert.equal(r.status,0,r.stderr);assert.match(r.stdout,/Jakiro E projectile selector PASS/,r.stderr);
});
