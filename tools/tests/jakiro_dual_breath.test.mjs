import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
test('Jakiro Q travels in two saved cones and owns finite elapsed burn, refresh and cleanup',()=>{
 const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
function LinkLuaModifier()end
local server=true;function IsServer()return server end
DAMAGE_TYPE_MAGICAL=2;DOTA_UNIT_TARGET_TEAM_ENEMY=3;DOTA_UNIT_TARGET_HERO=1;DOTA_UNIT_TARGET_BASIC=2;DOTA_UNIT_TARGET_FLAG_NONE=0
PATTACH_ABSORIGIN_FOLLOW=1;MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE=1;MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT=2;MODIFIER_PROPERTY_TOOLTIP=3;MODIFIER_PROPERTY_TOOLTIP2=4
local mt={};mt.__index=mt
function Vector(x,y,z)return setmetatable({x=x,y=y,z=z or 0},mt)end
mt.__sub=function(a,b)return Vector(a.x-b.x,a.y-b.y,a.z-b.z)end
mt.__add=function(a,b)return Vector(a.x+b.x,a.y+b.y,a.z+b.z)end
mt.__mul=function(a,n)return Vector(a.x*n,a.y*n,a.z*n)end
function mt:Length2D()return math.sqrt(self.x*self.x+self.y*self.y)end
function mt:Normalized()local n=self:Length2D();return Vector(self.x/n,self.y/n,0)end
local now,paused=0,false;local contexts,waves,hits={}, {}, {}
GameRules={GetGameTime=function()return now end,IsGamePaused=function()return paused end,
 GetGameModeEntity=function()return {SetContextThink=function(_,name,fn,delay)assert(not contexts[name]);contexts[name]={fn=fn,delay=delay}end}end}
Convars={GetBool=function()return false end}
ProjectileManager={CreateLinearProjectile=function(_,p)waves[#waves+1]=p;return #waves end}
ParticleManager={CreateParticle=function()return 1 end,SetParticleControl=function()end,ReleaseParticleIndex=function()end}
function ApplyDamage(info)hits[#hits+1]=info;return info.damage end
require('abilities/heroes/jakiro/q')
local a,c
local function unit(name,team)
 local u={name=name,team=team,removed=false,alive=true,immune=false,mods={},sounds=0,stops=0}
 function u:IsNull()return self.removed end
 function u:IsAlive()assert(not self.removed);return self.alive end
 function u:GetTeamNumber()assert(not self.removed);return self.team end
 function u:GetUnitName()return self.name end
 function u:IsMagicImmune()return self.immune end
 function u:EmitSound()assert(not self.removed);self.sounds=self.sounds+1 end
 function u:StopSound()assert(not self.removed);self.stops=self.stops+1 end
 function u:AddNewModifier(caster,ab,name,p)
  assert(not self.removed)
  local m=self.mods[name]
  if m then m.expiry=now+p.duration;m:OnRefresh(p);return m end
  m=setmetatable({created=now,expiry=now+p.duration},_G[name]);self.mods[name]=m
  function m:GetParent()return u end
  function m:GetCaster()return caster end
  function m:GetAbility()return ab end
  function m:GetElapsedTime()return now-self.created end
  function m:GetRemainingTime()return self.expiry-now end
  function m:StartIntervalThink(x)self.interval=x end
  function m:SetHasCustomTransmitterData()end
  function m:SendBuffRefreshToClients()end
  function m:Destroy()self:OnDestroy()end
  m:OnCreated(p);return m
 end
 return u
end
c=unit('jakiro',2);c.pos=Vector(100,200,30);c.int=90
function c:GetAbsOrigin()return self.pos end
function c:GetForwardVector()return Vector(1,0,0)end
function c:GetIntellect()return self.int end
local vals={damage=340,duration=5,slow_pct=45,breath_distance=850,breath_speed=1050,start_radius=150,end_radius=275,fire_delay=0.2}
a=setmetatable({removed=false},enfos_jakiro_dual_breath)
function a:IsNull()return self.removed end
function a:GetCaster()assert(not self.removed);return c end
function a:GetCursorPosition()return Vector(950,200,300)end
function a:GetSpecialValueFor(k)return vals[k] or 0 end
function a:GetLevel()return 4 end
function a:entindex()return 1 end
local normal,boss,ally,immune=unit('creep',3),unit('enfos_boss_test',3),unit('ally',2),unit('immune',3);boss.isBoss=true;immune.immune=true
function FindUnitsInRadius()return {normal,boss}end
function sums(u)local s=0;for _,d in ipairs(hits)do if d.victim==u then s=s+d.damage end end;return s end
a:OnSpellStart();assert(#hits==0,'No circle burst before traveling fire impact')
assert(#waves==1 and waves[1].ExtraData.phase==1)
assert(waves[1].vSpawnOrigin.x==100 and waves[1].vVelocity.x==1050 and waves[1].vVelocity.z==0)
assert(waves[1].fStartRadius==150 and waves[1].fEndRadius==275 and waves[1].fDistance==850)
assert(waves[1].bDeleteOnHit==false and waves[1].iUnitTargetFlags==0 and waves[1].iUnitTargetType==3)
local ctx;for _,v in pairs(contexts)do ctx=v end;assert(ctx.delay==0.2)
paused=true;assert(ctx.fn()>0 and #waves==1);paused=false
c.pos=Vector(900,900);c.int=500;vals.damage=490;vals.slow_pct=51
now=0.2;assert(ctx.fn()==nil and #waves==2);assert(waves[2].ExtraData.phase==2 and waves[2].vSpawnOrigin.x==100)
for _,u in ipairs({normal,boss})do
 assert(a:OnProjectileHit_ExtraData(u,nil,waves[1].ExtraData)==false)
 assert(u.mods.modifier_enfos_jakiro_dual_breath_slow:GetModifierMoveSpeedBonus_Percentage()==-45)
 assert(a:OnProjectileHit_ExtraData(u,nil,waves[2].ExtraData)==false)
end
assert(#hits==0,'Fire applies periodic burn, no bonus instant nuke')
assert(a:OnProjectileHit_ExtraData(ally,nil,waves[2].ExtraData)==false and next(ally.mods)==nil)
assert(a:OnProjectileHit_ExtraData(immune,nil,waves[2].ExtraData)==false and next(immune.mods)==nil)
for i=1,9 do now=0.2+i*0.5;for _,u in ipairs({normal,boss})do u.mods.modifier_enfos_jakiro_dual_breath_burn:OnIntervalThink()end end
now=5.2;for _,u in ipairs({normal,boss})do local b=u.mods.modifier_enfos_jakiro_dual_breath_burn;b:OnDestroy();b:OnDestroy();assert(b.interval==-1 and u.stops==1)end
assert(math.abs(sums(normal)-412)<0.001 and math.abs(sums(boss)-412)<0.001,'Same full duration normal/Boss formula, saved INT')
local purge=unit('purge',3);now=10;a:OnProjectileHit_ExtraData(purge,nil,waves[2].ExtraData)
local b=purge.mods.modifier_enfos_jakiro_dual_breath_burn;now=10.5;b:OnIntervalThink();local before=sums(purge);now=10.75;b:OnDestroy();now=12;b:OnIntervalThink();assert(sums(purge)==before,'Purge neither cashes remainder nor keeps ticks alive')
local refresh=unit('refresh',3);now=20;a:OnProjectileHit_ExtraData(refresh,nil,waves[2].ExtraData)
b=refresh.mods.modifier_enfos_jakiro_dual_breath_burn;now=20.75
refresh:AddNewModifier(c,a,'modifier_enfos_jakiro_dual_breath_burn',{duration=5,dps=100})
assert(math.abs(sums(refresh)-61.8)<0.001,'Settle old elapsed slice at refresh')
now=21.25;b:OnIntervalThink();assert(math.abs(sums(refresh)-111.8)<0.001)
refresh.immune=true;now=21.75;b:OnIntervalThink();assert(math.abs(sums(refresh)-111.8)<0.001)
refresh.immune=false;a.removed=true;now=22;b:OnIntervalThink();assert(b.closed and b.interval==-1)
a.removed=false
for _,mode in ipairs({'removed_caster','removed_target','dead_caster','client_tick'})do
 local victim=unit(mode,3);now=30;a:OnProjectileHit_ExtraData(victim,nil,waves[2].ExtraData)
 local dot=victim.mods.modifier_enfos_jakiro_dual_breath_burn
 now=30.5
 if mode=='removed_caster' then c.removed=true elseif mode=='removed_target' then victim.removed=true elseif mode=='dead_caster' then c.alive=false else server=false end
 dot:OnIntervalThink()
 if mode=='dead_caster' then assert(math.abs(sums(victim)-41.2)<0.001,'Already cast burn survives ordinary caster death') else assert(sums(victim)==0) end
 if mode=='removed_caster' or mode=='removed_target' then assert(dot.closed and dot.interval==-1) end
 c.removed=false;c.alive=true;server=true
end
local slow=normal.mods.modifier_enfos_jakiro_dual_breath_slow;normal.immune=true
assert(slow:GetModifierMoveSpeedBonus_Percentage()==0 and slow:GetModifierAttackSpeedBonus_Constant()==0,'Ordinary immunity suppresses control')
normal.immune=false
server=false;local n=#waves;a:OnSpellStart();assert(#waves==n);server=true
c.pos=Vector(100,200,30);function a:GetCursorPosition()return c.pos end;a:OnSpellStart();assert(waves[#waves].vVelocity.x==1050,'Zero aim falls back to facing')
a.removed=true;for _,v in pairs(contexts)do v.fn()end;assert(#waves==n+1,'Removed ability cancels pending fire')
print('Jakiro Q travel/burn/cleanup PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.match(r.stdout,/Jakiro Q travel.*PASS/,r.stderr);
});
