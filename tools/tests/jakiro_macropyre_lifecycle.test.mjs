import test from 'node:test';import assert from 'node:assert/strict';import {spawnSync} from 'node:child_process';
test('Macropyre uses saved planar endpoints and a finite particle-owning ground modifier',()=>{
const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end
local server=true;function IsServer()return server end
DAMAGE_TYPE_MAGICAL=2;DOTA_UNIT_TARGET_TEAM_ENEMY=3;DOTA_UNIT_TARGET_HERO=1;DOTA_UNIT_TARGET_BASIC=2;DOTA_UNIT_TARGET_FLAG_NONE=0;FIND_ANY_ORDER=0;PATTACH_WORLDORIGIN=0
Convars={GetBool=function()return false end}
local mt={};function Vector(x,y,z)return setmetatable({x=x,y=y,z=z or 0},mt)end
mt.__add=function(a,b)return Vector(a.x+b.x,a.y+b.y,a.z+b.z)end
mt.__sub=function(a,b)return Vector(a.x-b.x,a.y-b.y,a.z-b.z)end
mt.__mul=function(a,b)return Vector(a.x*b,a.y*b,a.z*b)end
mt.__index={Length2D=function(v)return math.sqrt(v.x*v.x+v.y*v.y)end,Normalized=function(v)local n=math.sqrt(v.x*v.x+v.y*v.y+v.z*v.z);return Vector(v.x/n,v.y/n,v.z/n)end}
local now,created,destroyed,released=0,0,{},{}
local controls={};ParticleManager={CreateParticle=function()created=created+1;controls[created]={};return created end,SetParticleControl=function(_,id,cp,v)controls[id][cp]=v end,DestroyParticle=function(_,id)destroyed[id]=(destroyed[id] or 0)+1 end,ReleaseParticleIndex=function(_,id)released[id]=(released[id] or 0)+1 end}
local function unit(team,pos)local u={team=team,pos=pos,alive=true,removed=false,total=0};function u:IsNull()return self.removed end;function u:IsAlive()assert(not self.removed);return self.alive end;function u:GetTeamNumber()assert(not self.removed);return self.team end;function u:GetAbsOrigin()assert(not self.removed);return self.pos end;function u:GetForwardVector()return Vector(1,0,0)end;function u:EmitSound()end;function u:GetIntellect()return self.int or 100 end;return u end
local c=unit(2,Vector(100,200,30));local enemy=unit(3,Vector(600,200,30));local boss=unit(3,Vector(600,200,30));boss.isBoss=true
local holders={}
function CreateModifierThinker(caster,a,name,p,pos)
 local holder=unit(2,pos);holders[#holders+1]=holder
 local m=setmetatable({created=now},_G[name]);holder.mod=m
 function m:GetParent()return holder end;function m:GetCaster()return caster end;function m:GetAbility()return a end;function m:GetElapsedTime()return now-self.created end;function m:StartIntervalThink(t)self.interval=t end;function m:Destroy()self:OnDestroy()end
 m:OnCreated(p);return holder
end
function UTIL_Remove(u)if u.removed then return end;u.removed=true;u.mod:OnDestroy()end
function FindUnitsInLine(team,start,last,cache,radius,targetTeam,types,flags)assert(start.x==100 and start.y==200 and start.z==30 and last.x==1500 and last.y==200 and last.z==30);assert(radius==250 and types==3 and flags==0);return {enemy,boss}end
function FindUnitsInRadius()return {enemy,boss}end
function ApplyDamage(info)info.victim.total=info.victim.total+info.damage;return info.damage end
require('abilities/heroes/jakiro/r')
local vals={length=1400,duration=10,damage_per_sec=200,path_radius=250,burn_interval=0.5}
local a=setmetatable({removed=false,rank=1},enfos_jakiro_macropyre)
function a:IsNull()return self.removed end;function a:GetCaster()return c end;function a:GetLevel()return self.rank end;function a:GetCursorPosition()return Vector(1500,200,600)end;function a:GetSpecialValueFor(k)return vals[k] or 0 end
server=false;a:OnSpellStart();assert(#holders==0 and created==0,'Client must not create field or particle');server=true
a.rank=0;a:OnSpellStart();assert(#holders==0,'Unlearned cast rejected');a.rank=1
a:OnSpellStart();local zone=holders[1].mod;assert(created==1 and next(released)==nil,'Persistent particle remains owned')
assert(controls[1][1].x==1500 and controls[1][1].z==30 and controls[1][2].x==10 and controls[1][4].x==250)
c.pos=Vector(900,900,900);c.int=1000;vals.damage_per_sec=1000;c.alive=false
now=0.5;zone:OnIntervalThink();assert(enemy.total==135 and boss.total==135,'Cast snapshot survives valid caster death')
now=10;zone:OnIntervalThink();zone:OnDestroy();assert(enemy.total==2700 and boss.total==2700,'Complete saved damage budget at expiry');assert(zone.closed and destroyed[1]==1 and released[1]==1 and holders[1].removed,'Expiry cleanup exactly once')
c.alive=true;c.pos=Vector(100,200,30);c.int=100;vals.damage_per_sec=200
function a:GetCursorPosition()return c.pos end
for i=1,10 do a:OnSpellStart()end
assert(#a.enfosGroundEffects==3,'Existing bounded three fields preserved')
assert(controls[created][1].x==1500,'Zero aim uses facing')
local live=a.enfosGroundEffects[3].mod;a.removed=true;live:OnIntervalThink();assert(live.closed and destroyed[created]==1 and released[created]==1)
a.removed=false;now=20;vals.duration=1.25;a:OnSpellStart();local fractional=a.enfosGroundEffects[3].mod;local before=enemy.total
now=20.5;fractional:OnIntervalThink();now=21;fractional:OnIntervalThink();now=21.25;fractional:OnDestroy()
assert(enemy.total-before==337.5 and released[created]==1,'Engine expiry settles final partial interval without duplication')
local previous=#holders;c.removed=true;a:OnSpellStart();assert(#holders==previous);c.removed=false

print('Jakiro R owner lifecycle PASS')
`;
const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});assert.equal(r.status,0,r.stderr);assert.match(r.stdout,/Jakiro R owner lifecycle PASS/,r.stderr);
});
