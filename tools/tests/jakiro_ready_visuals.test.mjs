import test from 'node:test';import assert from 'node:assert/strict';import {spawnSync,execFileSync} from 'node:child_process';
test('Jakiro ready roots follow verified mouths with bounded readonly ownership',()=>{
 const baseline=process.env.JAKIRO_READY_BASELINE?execFileSync('git',['show','HEAD:game/scripts/vscripts/abilities/heroes/jakiro/e.lua'],{encoding:'utf8'}):null;
 const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end
local server=true;function IsServer()return server end;Convars={GetBool=function()return false end};PATTACH_POINT_FOLLOW=8
${baseline?`assert(load([==[${baseline}]==]))();package.loaded['abilities/heroes/jakiro/e']=true`:''}
require('abilities/heroes/jakiro/e_frost')
local created,destroyed,released,bindings=0,0,0,0;local entries={};local onCreate,onBind,onDestroy
ParticleManager={CreateParticle=function(_,path,attach,c)assert(attach==8);local id=created;created=created+1;entries[id]={path=path,c=c};if onCreate then onCreate()end;return id end,
 SetParticleControlEnt=function(_,id,cp,c,attach,name,origin,lock)assert(cp==0 and attach==8 and lock and origin==c.origin);entries[id].mouth=name;bindings=bindings+1;if onBind then onBind()end end,
 DestroyParticle=function(_,id,immediate)assert(not immediate and not entries[id].destroyed);entries[id].destroyed=true;destroyed=destroyed+1;if onDestroy then onDestroy()end end,
 ReleaseParticleIndex=function(_,id)assert(entries[id].destroyed and not entries[id].released);entries[id].released=true;released=released+1 end}
local function owner(proto,head,root)
 local c={alive=true,origin={},attachments={attach_attack1=1,attach_attack2=2}}
 function c:IsNull()return self.removed end;function c:IsAlive()return self.alive end;function c:IsIllusion()return self.illusion end;function c:IsSilenced()return self.silenced end;function c:IsDisarmed()return self.disarmed end;function c:GetAbsOrigin()return self.origin end
 function c:ScriptLookupAttachment(n)assert(server);return self.attachments[n] or 0 end
 local a={rank=1,ready=true};function a:IsNull()return self.removed end;function a:GetLevel()return self.rank end;function a:IsFullyCastable()assert(server);return self.ready end
 function a:UseResources()error('Visual query cannot spend mana/cooldown')end
 local m=setmetatable({GetParent=function()return c end,GetAbility=function()return a end,StartIntervalThink=function(self,n)self.interval=n end},proto)
 m:OnCreated();assert(m.interval==0.1 and m.ready_particle~=nil,'Native ready effect missing')
 local id=m.ready_particle;assert(entries[id].path=='particles/units/heroes/hero_jakiro/'..root..'.vpcf' and entries[id].mouth==head)
 return m,c,a
end
local fire,c,a=owner(modifier_enfos_jakiro_liquid_fire_passive,'attach_attack1','jakiro_liquid_fire_ready')
assert(fire.ready_particle==0,'Particle index0 is valid')
local ice,ic,ia=owner(modifier_enfos_jakiro_liquid_frost_orb,'attach_attack2','jakiro_liquid_ice_ready')
for i=1,100 do fire:OnIntervalThink();ice:OnIntervalThink()end;assert(created==2 and bindings==2 and destroyed==0)
c.broken=true;fire:OnIntervalThink();assert(created==2,'Break cannot suppress an active orb readiness signal')
for _,mode in ipairs({'rank0','cooldown_or_mana','dead','illusion','silenced','disarmed','no_attachment','removed_ability','removed_caster'})do
 if mode=='rank0' then a.rank=0 elseif mode=='cooldown_or_mana' then a.ready=false elseif mode=='dead' then c.alive=false elseif mode=='illusion' then c.illusion=true elseif mode=='silenced' then c.silenced=true elseif mode=='disarmed' then c.disarmed=true elseif mode=='no_attachment' then c.attachments.attach_attack1=0 elseif mode=='removed_ability' then a.removed=true else c.removed=true end
 local before=created;fire:OnIntervalThink();assert(fire.ready_particle==nil and created==before,mode)
 a.rank=1;a.ready=true;c.alive=true;c.illusion=false;c.silenced=false;c.disarmed=false;c.attachments.attach_attack1=1;a.removed=false;c.removed=false
 fire:OnIntervalThink();assert(fire.ready_particle~=nil and created==before+1)
end
local saved=fire.ready_particle;server=false;fire:OnIntervalThink();assert(fire.ready_particle==saved);server=true
onDestroy=function()fire:OnIntervalThink()end;fire:OnDestroy();onDestroy=nil
assert(fire.ready_particle==nil and fire.interval==-1);local before=created;fire:OnDestroy();fire:OnIntervalThink();assert(created==before)
ice:OnDestroy();assert(ice.ready_particle==nil and destroyed==created and released==created)
-- Particle creation/binding callbacks can remove the ability before further entity access.
local c2={origin={},IsNull=function()return false end,IsAlive=function()return true end,IsIllusion=function()return false end,ScriptLookupAttachment=function()return 1 end,GetAbsOrigin=function(self)return self.origin end}
local a2={removed=false,IsNull=function(self)return self.removed end,GetLevel=function()return 1 end,IsFullyCastable=function()return true end}
local m=setmetatable({GetParent=function()return c2 end,GetAbility=function()return a2 end,StartIntervalThink=function()end},modifier_enfos_jakiro_liquid_fire_passive)
local oldBindings=bindings;onCreate=function()a2.removed=true end;m:OnCreated();onCreate=nil;assert(m.ready_particle==nil and bindings==oldBindings and released==created)
a2.removed=false;onBind=function()m:OnDestroy()end;m:OnCreated();onBind=nil;assert(m.ready_particle==nil and released==created)
print('Jakiro ready visuals PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});assert.equal(r.status,0,r.stderr);assert.match(r.stdout,/Jakiro ready visuals PASS/,r.stderr);
});
