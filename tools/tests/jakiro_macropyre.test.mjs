import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';

test('Jakiro Macropyre never truncates ordinary magical pulses for Boss metadata',()=>{
 const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
function LinkLuaModifier()end
function IsServer()return true end
Convars={GetBool=function()return false end}
PATTACH_WORLDORIGIN=0
ParticleManager={CreateParticle=function()return 1 end,SetParticleControl=function()end,DestroyParticle=function()end,ReleaseParticleIndex=function()end}
function UTIL_Remove()end
DAMAGE_TYPE_MAGICAL=2
DOTA_UNIT_TARGET_TEAM_ENEMY=2;DOTA_UNIT_TARGET_HERO=1;DOTA_UNIT_TARGET_BASIC=2
DOTA_UNIT_TARGET_FLAG_NONE=0;FIND_ANY_ORDER=0
local mt={}
function Vector(x,y,z)return setmetatable({x=x,y=y,z=z or 0},mt)end
mt.__add=function(a,b)return Vector(a.x+b.x,a.y+b.y,a.z+b.z)end
mt.__sub=function(a,b)return Vector(a.x-b.x,a.y-b.y,a.z-b.z)end
mt.__mul=function(a,b)return Vector(a.x*b,a.y*b,a.z*b)end
mt.__index={Length2D=function(a)return math.sqrt(a.x*a.x+a.y*a.y)end,
 Normalized=function(a)local n=math.sqrt(a.x*a.x+a.y*a.y+a.z*a.z);return Vector(a.x/n,a.y/n,a.z/n)end}
local now=0
local function unit(id,name,boss,pos)
 local u={id=id,name=name,isBoss=boss,pos=pos,total=0,hits=0}
 function u:IsNull()return false end
 function u:IsAlive()return true end
 function u:GetAbsOrigin()return self.pos end
 function u:GetUnitName()return self.name end
 function u:entindex()return self.id end
 function u:GetMaxHealth()return 1000 end
 function u:GetTeamNumber()return 3 end

 function u:AddNewModifier(c,a,name,p)
  assert(name=='modifier_enfos_jakiro_macropyre_burn')
  local m=self.burn
  if m and not m.closed then m.expiry=now+p.duration;m:OnRefresh(p);return m end
  m=setmetatable({created=now,expiry=now+p.duration},_G[name]);self.burn=m
  function m:GetParent()return u end;function m:GetCaster()return c end;function m:GetAbility()return a end
  function m:GetElapsedTime()return now-self.created end;function m:GetRemainingTime()return self.expiry-now end
  function m:StartIntervalThink(t)self.interval=t end;function m:SetHasCustomTransmitterData()end;function m:SendBuffRefreshToClients()end;function m:Destroy()self:OnDestroy()end
  m:OnCreated(p);return m
 end
 return u
end
local ordinary=unit(1,'ordinary',false,Vector(500,0))
local flagged=unit(2,'ordinary_flagged',true,Vector(500,0))
local named=unit(3,'enfos_boss_named',false,Vector(500,0))
local outside=unit(4,'outside',true,Vector(500,500))
local targets={ordinary,flagged,named,outside}
function FindUnitsInLine(team,first,last,cache,radius)assert(radius==250);local result={};for _,u in ipairs(targets)do if u.pos.y<=radius then result[#result+1]=u end end;return result end
function ApplyDamage(p)
 assert(p.damage_type==DAMAGE_TYPE_MAGICAL and p.damage_flags==0)
 p.victim.total=p.victim.total+p.damage;p.victim.hits=p.victim.hits+1;return p.damage
end
local caster={IsNull=function()return false end,IsAlive=function()return true end,
 GetTeamNumber=function()return 2 end,GetIntellect=function()return 100 end}
local a={IsNull=function()return false end,GetCaster=function()return caster end,
 GetSpecialValueFor=function(_,key)return key=='damage_per_sec' and 200 or 0 end}
local parent={IsNull=function()return false end,GetAbsOrigin=function()return Vector(0,0)end}
require('abilities/heroes/jakiro/r')

local zone=setmetatable({GetCaster=function()return caster end,GetAbility=function()return a end,
 GetParent=function()return parent end,GetElapsedTime=function()return now end,StartIntervalThink=function(self,t)assert(t==0.5 or t==-1)end},modifier_enfos_jakiro_macropyre_zone)
zone:OnCreated({dir_x=1,dir_y=0,length=1400})
zone.Destroy=function(self)self:OnDestroy()end
for i=1,20 do now=i*0.5;zone:OnIntervalThink();for _,u in ipairs(targets)do if u.burn then u.burn:OnIntervalThink()end end end
-- Authored DPS 200 + 100 INT * 0.7, half-second pulses = 135 each.
-- All three geometrically identical targets must receive 2700 requested magic damage.
for _,u in ipairs({ordinary,flagged,named})do
 assert(u.hits==20 and u.total==2700,'Boss metadata truncated requested damage: '..u.name..' '..u.total)
end
assert(outside.hits==0,'ordinary line geometry must still reject off-path targets')
assert(zone.boss_damage==nil,'No per-Boss entity table retained by thinker')
print('Jakiro Macropyre ordinary Boss pulse PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.match(r.stdout,/Jakiro Macropyre ordinary Boss pulse PASS/,r.stderr);
});
