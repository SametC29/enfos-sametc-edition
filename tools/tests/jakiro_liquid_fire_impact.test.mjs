import test from 'node:test';import assert from 'node:assert/strict';import {spawnSync} from 'node:child_process';
test('Liquid Fire impact uses saved AoE origin and radius for its finite native particle',()=>{
const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end
local server=true;function IsServer()return server end;Convars={GetBool=function()return false end}
PATTACH_WORLDORIGIN=0;PATTACH_ABSORIGIN_FOLLOW=1;DOTA_UNIT_TARGET_TEAM_ENEMY=2;DOTA_UNIT_TARGET_HERO=1;DOTA_UNIT_TARGET_BASIC=2;DOTA_UNIT_TARGET_BUILDING=4;DOTA_UNIT_TARGET_FLAG_NONE=0;FIND_ANY_ORDER=0
function Vector(x,y,z)return {x=x,y=y,z=z}end
require('abilities/heroes/jakiro/e')
local c={removed=false,IsNull=function(self)return self.removed end,GetTeamNumber=function()return 2 end}
local target={removed=false,pos=Vector(100,200,30),IsNull=function(self)return self.removed end,GetTeamNumber=function()return 3 end,GetAbsOrigin=function(self)assert(not self.removed);return self.pos end}
function target:EmitSound(name)assert(name=='Hero_Jakiro.LiquidFire');self.pos=Vector(900,900,900)end
local a=setmetatable({GetCaster=function()return c end,IsNull=function()return false end},enfos_jakiro_liquid_fire)
local creates,release,cp=0,0,{}
ParticleManager={CreateParticle=function(_,path,attach,owner)creates=creates+1;assert(path=='particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf');assert(attach==PATTACH_WORLDORIGIN and owner==target);return creates end,SetParticleControl=function(_,id,k,v)cp[k]=v end,ReleaseParticleIndex=function()release=release+1 end}
local queries=0
function FindUnitsInRadius(team,origin,cache,radius,tt,types)queries=queries+1;assert(origin.x==100 and origin.y==200 and origin.z==30 and radius==375 and types==7);return {}end
local snapshot={radius=375,total=120,slow=40,duration=5,tick=0.5,building_pct=75}
assert(a:FireAt(target,snapshot));assert(cp[0].x==100 and cp[0].y==200 and cp[0].z==30,'VFX must stay at impact origin when sound callback moves target')
assert(cp[1].x==375 and cp[1].y==375 and cp[1].z==375,'All native radius/speed control inputs populated');assert(creates==1 and release==1 and queries==1)
server=false;assert(not a:FireAt(target,snapshot));server=true;target.removed=true;assert(not a:FireAt(target,snapshot));target.removed=false
c.removed=true;assert(not a:FireAt(target,snapshot));c.removed=false;assert(creates==1 and release==1)
target.pos=Vector(100,200,30);ParticleManager.SetParticleControl=function(_,id,k,v)cp[k]=v;if k==0 then c.removed=true end end
assert(not a:FireAt(target,snapshot));assert(creates==2 and release==2 and queries==1,'Invalidated source still releases finite effect and cannot query victims')
print('Jakiro E impact controls PASS')
`;
const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});assert.equal(r.status,0,r.stderr);assert.match(r.stdout,/Jakiro E impact controls PASS/,r.stderr);
});
