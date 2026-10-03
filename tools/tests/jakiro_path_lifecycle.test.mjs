import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';

test('Persistent Ice Path catches later entrants once, expires and bounds recast owners',()=>{
 const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
function LinkLuaModifier()end
function IsServer()return true end
DAMAGE_TYPE_MAGICAL=2;PATTACH_WORLDORIGIN=1
DOTA_UNIT_TARGET_TEAM_ENEMY=2;DOTA_UNIT_TARGET_HERO=1;DOTA_UNIT_TARGET_BASIC=2;DOTA_UNIT_TARGET_FLAG_NONE=0
local mt={};function Vector(x,y,z)return setmetatable({x=x,y=y,z=z or 0},mt)end
mt.__add=function(a,b)return Vector(a.x+b.x,a.y+b.y,a.z+b.z)end
mt.__sub=function(a,b)return Vector(a.x-b.x,a.y-b.y,a.z-b.z)end
mt.__mul=function(a,b)return Vector(a.x*b,a.y*b,a.z*b)end
mt.__index={Length2D=function(a)return math.sqrt(a.x*a.x+a.y*a.y)end,
 Normalized=function(a)local n=math.sqrt(a.x*a.x+a.y*a.y+a.z*a.z);return Vector(a.x/n,a.y/n,a.z/n)end}
local now,created,destroyed,released=0,0,0,0
local function unit(team)
 local u={team=team,pos=Vector(0,0),removed=false,hits=0,damage=0,stuns={}}
 function u:IsNull()return self.removed end;function u:IsAlive()assert(not self.removed);return true end
 function u:GetTeamNumber()assert(not self.removed);return self.team end
 function u:GetAbsOrigin()assert(not self.removed);return self.pos end
 function u:GetForwardVector()return Vector(1,0)end;function u:GetIntellect()return 100 end
 function u:EmitSound(name)assert(not self.removed);self.sound=name end
 function u:StopSound(name)assert(not self.removed);self.stopped=name end
 function u:AddNewModifier(c,a,name,p)assert(name=='modifier_stunned');self.stuns[#self.stuns+1]=p.duration end
 return u
end
ParticleManager={CreateParticle=function()created=created+1;return created end,SetParticleControl=function()end,
 DestroyParticle=function()destroyed=destroyed+1 end,ReleaseParticleIndex=function()released=released+1 end}
function UTIL_Remove(p)
 if p.removed then return end;p.removed=true
 if p.zone then p.zone:OnDestroy()end
end
local caster=unit(2)
require('abilities/heroes/jakiro/w')
local a=setmetatable({removed=false},enfos_jakiro_ice_path)
function a:IsNull()return self.removed end;function a:GetCaster()return caster end
function a:GetCursorPosition()return Vector(1200,0)end
function a:GetSpecialValueFor(k)return ({damage=200,stun_duration=2,path_delay=0.5,path_duration=3,path_length=1200,path_radius=150})[k] or 0 end
local owners={}
function CreateModifierThinker(c,ab,name,params,origin,team)
 assert(name=='modifier_enfos_jakiro_ice_path_zone')
 local p=unit(team);p.pos=origin;local birth=now
 local z=setmetatable({GetCaster=function()return c end,GetAbility=function()return ab end,
  GetParent=function()return p end,GetElapsedTime=function()return now-birth end},modifier_enfos_jakiro_ice_path_zone)
 function z:StartIntervalThink(t)self.interval=t end;function z:Destroy()self:OnDestroy()end
 p.zone=z;owners[#owners+1]=p;z:OnCreated(params);return p
end
local first,late,last=unit(3),unit(3),unit(3);late.isBoss=true
local targets={first}
function FindUnitsInLine()return targets end
function ApplyDamage(p)p.victim.hits=p.victim.hits+1;p.victim.damage=p.victim.damage+p.damage;return p.damage end
a:OnSpellStart();local p=owners[1];local z=p.zone
assert(z.interval==0.5 and created==1 and released==0)
z:OnIntervalThink();assert(first.hits==0)
now=0.5;z:OnIntervalThink();assert(first.hits==1 and first.damage==260 and first.stuns[1]==2 and z.interval==0.1)
now=1;targets={first,late};z:OnIntervalThink();assert(first.hits==1 and late.hits==1 and late.stuns[1]==2)
for i=1,20 do z:OnIntervalThink()end
assert(first.hits==1 and late.hits==1,'Each cast owns a once-per-unit hit set')
now=3;targets={last};z:OnIntervalThink();assert(last.hits==1 and last.stuns[1]==0.5,'Late stun ends at ordinary path expiry')
now=3.5;z:OnIntervalThink();assert(z.closed and z.seen==nil and p.removed and released==1 and destroyed==1)
z:OnIntervalThink();z:OnDestroy();assert(released==1 and destroyed==1,'Teardown idempotence')
now=4;targets={};a.enfosGroundEffects={}
for i=1,20 do a:OnSpellStart()end
assert(#a.enfosGroundEffects==3 and created==21 and released==18 and destroyed==18,'Max three retained cast owners')
for _,parent in ipairs(a.enfosGroundEffects)do parent.zone:Destroy()end
assert(released==21 and destroyed==21)
-- Source invalidation mid-path cancels and cleans resources without target callbacks.
a.enfosGroundEffects={};a:OnSpellStart();local bad=owners[#owners];a.removed=true
bad.zone:OnIntervalThink();assert(bad.zone.closed and bad.removed and released==22)
print('Persistent Jakiro Ice Path lifecycle PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.match(r.stdout,/Persistent Jakiro Ice Path lifecycle PASS/,r.stderr);
});
