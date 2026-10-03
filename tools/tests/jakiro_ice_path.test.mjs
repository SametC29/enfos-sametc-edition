import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';

test('Jakiro Ice Path uses one saved native-width line, ordinary stun and safe delayed callbacks',()=>{
 const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
function LinkLuaModifier()end
local server=true;function IsServer()return server end
DAMAGE_TYPE_MAGICAL=2;PATTACH_WORLDORIGIN=1
DOTA_UNIT_TARGET_TEAM_ENEMY=2;DOTA_UNIT_TARGET_HERO=1;DOTA_UNIT_TARGET_BASIC=2;DOTA_UNIT_TARGET_FLAG_NONE=0
local mt={}
function Vector(x,y,z)return setmetatable({x=x,y=y,z=z or 0},mt)end
mt.__add=function(a,b)return Vector(a.x+b.x,a.y+b.y,a.z+b.z)end
mt.__sub=function(a,b)return Vector(a.x-b.x,a.y-b.y,a.z-b.z)end
mt.__mul=function(a,b)return Vector(a.x*b,a.y*b,a.z*b)end
mt.__index={Length2D=function(a)return math.sqrt(a.x*a.x+a.y*a.y)end,
 Normalized=function(a)local n=math.sqrt(a.x*a.x+a.y*a.y+a.z*a.z);return Vector(a.x/n,a.y/n,a.z/n)end}
require('abilities/heroes/jakiro/w')
for _,mode in ipairs({'ordinary','rank10','zero','client','removed_ability','removed_caster','stun_removes_target','stun_removes_ability','stun_removes_caster'})do
 server=mode~='client'
 local callbacks,particles,hits,mods={}, {}, {}, {}
 local a,c
 local function unit(id,x,y,boss)
  local u={id=id,pos=Vector(x,y),removed=false,isBoss=boss,team=3}
  function u:IsNull()return self.removed end
  function u:IsAlive()assert(not self.removed);return true end
  function u:GetAbsOrigin()assert(not self.removed);return self.pos end
  function u:GetTeamNumber()assert(not self.removed);return self.team end
  function u:GetUnitName()return self.isBoss and 'enfos_boss_test' or 'creep' end
  function u:entindex()return self.id end
  function u:AddNewModifier(caster,ab,name,p)
   assert(not self.removed);assert(name=='modifier_stunned','No undefined Lua stun')
   assert(p.duration==(mode=='rank10' and 6 or 1.5),'No Boss-only duration reduction')
   mods[self]=true
   if mode=='stun_removes_target' then self.removed=true end
   if mode=='stun_removes_ability' then a.removed=true end
   if mode=='stun_removes_caster' then c.removed=true end
  end
  return u
 end
 local creep,boss,off=unit(2,100,0),unit(3,1100,149,true),unit(4,600,200)
 c=unit(1,0,0);c.team=2
 function c:GetIntellect()return 100 end
 function c:GetForwardVector()return Vector(1,0)end
 function c:EmitSound(name)assert(not self.removed);assert(name=='Hero_Jakiro.IcePath.Cast')end
 a=setmetatable({removed=false},enfos_jakiro_ice_path)
 function a:IsNull()return self.removed end
 function a:GetCaster()assert(not self.removed);return c end
 function a:GetCursorPosition()return mode=='zero' and Vector(0,0) or Vector(900,0,200)end
 function a:GetLevel()return mode=='rank10' and 10 or 1 end
 function a:entindex()return 41 end
 function a:GetSpecialValueFor(key)
  assert(not self.removed)
  return ({damage=200,stun_duration=mode=='rank10' and 6 or 1.5,path_delay=0.5,path_length=1200,path_radius=150})[key] or 0
 end
 ParticleManager={CreateParticle=function()local id=#particles+1;particles[id]={};return id end,
 SetParticleControl=function(_,id,cp,v)particles[id][cp]=v end,
 ReleaseParticleIndex=function(_,id)particles[id].released=true end}
 GameRules={GetGameModeEntity=function()return {SetContextThink=function(_,name,cb,delay)callbacks[#callbacks+1]={cb=cb,delay=delay,name=name}end}end}
 function FindUnitsInRadius()return {creep,boss,off}end
 function FindUnitsInLine(team,origin,last,cache,width,tf,ty,flags)
  assert(team==2 and origin.x==0 and last.x==1200 and last.y==0 and last.z==0)
  assert(width==150 and tf==2 and ty==3 and flags==0)
  return {creep,boss} -- Independently selected points: y149 in; y200 out of native radius150.
 end
 function ApplyDamage(p)assert(not p.victim.removed and not c.removed and not a.removed);hits[p.victim]=p.damage;return p.damage end
 a:OnSpellStart()
 if mode=='client' then assert(#particles==0 and #callbacks==0) else
  assert(#particles==1 and particles[1][1].x==1200 and particles[1][1].z==0,'Visual path endpoint must match actual line')
  assert(particles[1].released and #callbacks==1 and callbacks[1].delay==0.5)
  assert(next(hits)==nil,'No hit before the configured warning')
  c.pos=Vector(7000,0) -- Callback must preserve cast origin.
  if mode=='removed_ability' then a.removed=true end
  if mode=='removed_caster' then c.removed=true end
  assert(callbacks[1].cb()==nil)
  if mode:find('removed_',1,true)==1 or mode:find('stun_removes_',1,true)==1 then
   assert(next(hits)==nil,'Invalidated cast must not continue with damage')
  else
   assert(hits[creep]==260 and hits[boss]==260 and not hits[off] and not mods[off])
  end
 end
end
print('Jakiro Ice Path geometry/ordinary stun/callback PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.match(r.stdout,/Jakiro Ice Path geometry.*PASS/,r.stderr);
});
