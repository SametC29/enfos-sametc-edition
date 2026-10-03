import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync,execFileSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';
test('Lion spike launches vertically and settles each saved hit once without stealing competing motion',()=>{
 const kv=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities.enfos_lion_earth_spike;
 const baseline=process.env.LION_MOTION_BASELINE?execFileSync('git',['show','HEAD:game/scripts/vscripts/abilities/heroes/lion/q.lua'],{encoding:'utf8'}):null;
 const lua=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
LUA_MODIFIER_MOTION_VERTICAL=2;LUA_MODIFIER_MOTION_NONE=0;MODIFIER_PRIORITY_NORMAL=1;MODIFIER_STATE_STUNNED=9;DAMAGE_TYPE_MAGICAL=2;PATTACH_WORLDORIGIN=7
function LinkLuaModifier(n,p,kind)assert(kind==2,'Spike must register as a vertical controller')end
function Vector(x,y,z)return {x=x,y=y,z=z}end
local server=true;function IsServer()return server end;Convars={GetBool=function()return false end}
local ground=9;function GetGroundHeight()return ground end
ParticleManager={CreateParticle=function()return 1 end,SetParticleControl=function()end,ReleaseParticleIndex=function()end}
${baseline?`assert(load([==[${baseline}]==]))()`:`require('abilities/heroes/lion/q')`}
local c,t,a,m;local damage,removes,moves,lands=0,0,0,0;local hook
function ApplyDamage(p)damage=damage+p.damage;if hook then hook('damage')end;return p.damage end
local function unit(team)
 local u={team=team,alive=true,pos=Vector(0,0,ground)}
 function u:IsNull()return self.removed end;function u:IsAlive()return self.alive end;function u:GetTeamNumber()return self.team end
 function u:IsBuilding()return self.building end;function u:IsMagicImmune()return self.immune end;function u:IsDebuffImmune()return self.immune end
 function u:GetAbsOrigin()return self.pos end;function u:GetUnitName()return 'enfos_creep'end
 function u:EmitSound(n)if n=='Hero_Lion.ImpaleTargetLand' then lands=lands+1 end;if hook then hook('sound')end end
 function u:SetAbsOrigin(p)moves=moves+1;self.pos=p;if hook then hook('position')end end
 function u:IsCurrentlyVerticalMotionControlled()return self.controller~=nil end
 function u:RemoveVerticalMotionController(x)assert(self.controller==x,'Only the owned controller may be removed');self.controller=nil;removes=removes+1;if hook then hook('remove')end end
 function u:AddNewModifier(caster,ability,name,p)
  assert(name=='modifier_enfos_lion_earth_spike_stun')
  m=setmetatable({params=p},modifier_enfos_lion_earth_spike_stun)
  function m:GetCaster()return caster end;function m:GetParent()return u end;function m:GetAbility()return ability end
  function m:GetDuration()return p.duration*(u.durationFactor or 1)end
  function m:Destroy()self:OnDestroy()end
  function m:ApplyVerticalMotionController()
   if u.controller then return false end
   u.controller=self;if hook then hook('acquire')end;return true
  end
  m:OnCreated(p);return m
 end
 return u
end
local function reset()
 damage,removes,moves,lands,hook=0,0,0,0,nil;ground=9;c=unit(2);t=unit(3)
 a=setmetatable({},enfos_lion_earth_spike)
 function a:IsNull()return self.removed end;function a:GetCaster()return self.foreign or c end
end
local function hit(damage,stun)
 local data={damage=damage,stun_duration=stun,launch_height=${kv.AbilityValues.launch_height},launch_duration=${kv.AbilityValues.launch_duration}}
 assert(a:OnProjectileHit_ExtraData(t,nil,data)==false);return data
end
local damages={${kv.AbilityValues.damage.split(/\s+/).join(',')}};local stuns={${kv.AbilityValues.stun_duration.split(/\s+/).join(',')}}
for rank=1,10 do for _,boss in ipairs({false,true})do
 reset();t.isBoss=boss;hit(damages[rank]+110,stuns[rank]);assert(damage==0 and t.controller==m,'Damage must wait for landing')
 assert(m:CheckState()[9] and m:GetMotionPriority()==1)
 m:UpdateVerticalMotion(t,.1);assert(math.abs(t.pos.z-159)<1e-7 and damage==0)
 t.pos.x=50;t.pos.y=70;ground=20;m:UpdateVerticalMotion(t,.1)
 assert(t.pos.x==50 and t.pos.y==70 and math.abs(t.pos.z-220)<1e-7,'Vertical motion preserves horizontal position and follows terrain')
 m:UpdateVerticalMotion(t,.2);assert(t.pos.z==20 and damage==damages[rank]+110 and lands==1 and removes==1 and not t.controller)
 m:UpdateVerticalMotion(t,10);m:OnDestroy();m:OnDestroy();assert(damage==damages[rank]+110 and removes==1,'Landing/expiry cannot duplicate settlement')
end end
reset();t.durationFactor=.1;hit(100,1);assert(m.flight.duration==.1,'Flight must fit actual engine-adjusted control duration')
m:UpdateVerticalMotion(t,.1);assert(damage==100 and t.pos.z==ground)
reset();local competing={};t.controller=competing;hit(100,1)
assert(damage==100 and removes==0 and moves==0 and t.controller==competing,'Failed acquisition leaves another controller intact')
reset();hit(100,1);m:UpdateVerticalMotion(t,.1);t.controller=competing;local writes=moves
m:OnVerticalMotionInterrupted();assert(damage==100 and removes==0 and moves==writes and t.controller==competing,'Revoked motion cannot move or remove its replacement')
m:OnDestroy();assert(damage==100 and t.controller==competing)
reset();hit(100,1);m:UpdateVerticalMotion(t,.1);m:OnDestroy();assert(damage==100 and t.pos.z==ground and removes==1,'Strong purge settles the hit and releases its owned altitude')
reset();hit(100,1);m:UpdateVerticalMotion(t,.1);t.controller=nil;m:OnVerticalMotionInterrupted()
assert(damage==100 and t.pos.z==ground and removes==0,'Revoked motion without a replacement returns to terrain without removing an unowned controller')
m:OnDestroy();assert(damage==100)
reset();hook=function(phase)if phase=='acquire' then m:OnDestroy()end end;hit(100,1)
assert(damage==100 and removes==1 and not t.controller,'Teardown during acquisition releases the acquired handle exactly once')
reset();local old=hit(100,1);m:UpdateVerticalMotion(t,.1)
local oldFlight=m.flight;m:OnRefresh({damage=300,launch_height=200,launch_duration=.4})
assert(damage==100 and m.flight~=oldFlight and not m.closed and removes==1)
require('abilities/heroes/lion/spike_motion').Finish(m,oldFlight);assert(damage==100)
m:UpdateVerticalMotion(t,.4);assert(damage==400 and removes==2 and lands==2,'Refresh preserves separate immutable damage receipts')
for _,mode in ipairs({'dead target','removed target','ally','immune','building','removed caster','removed ability','foreign source'})do
 reset();hit(100,1)
 if mode=='dead target' then t.alive=false elseif mode=='removed target' then t.removed=true elseif mode=='ally' then t.team=2
 elseif mode=='immune' then t.immune=true elseif mode=='building' then t.building=true elseif mode=='removed caster' then c.removed=true
 elseif mode=='removed ability' then a.removed=true else a.foreign=unit(2)end
 m:UpdateVerticalMotion(t,.4);assert(damage==0,mode)
end
reset();hit(100,1);c.alive=false;m:UpdateVerticalMotion(t,.4);assert(damage==100,'Caster death preserves a launched valid hit')
reset();hit(100,1);hook=function(phase)if phase=='damage' then m:OnDestroy()end end;m:UpdateVerticalMotion(t,.4);assert(damage==100 and removes==1,'Damage callback teardown must not settle twice')
reset();hit(100,1);hook=function(phase)if phase=='sound' then t.team=2 end end;m:UpdateVerticalMotion(t,.4);assert(damage==0,'Landing audio callback invalidation gates damage')
reset();server=false;a:OnProjectileHit_ExtraData(t,nil,{damage=100,stun_duration=1});assert(damage==0 and moves==0);server=true
print('Lion motion PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:lua,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.equal(r.stderr,'');assert.match(r.stdout,/Lion motion PASS/);
});
