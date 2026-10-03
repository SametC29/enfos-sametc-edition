import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
test('Liquid Fire integrates a saved five-second burn, building rules, purge, refresh and cleanup',()=>{
 const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
function LinkLuaModifier()end
local server=true;function IsServer()return server end
DAMAGE_TYPE_MAGICAL=2;DOTA_UNIT_TARGET_TEAM_ENEMY=3;DOTA_UNIT_TARGET_HERO=1;DOTA_UNIT_TARGET_BASIC=2;DOTA_UNIT_TARGET_BUILDING=4;DOTA_UNIT_TARGET_FLAG_NONE=0;FIND_ANY_ORDER=0;PATTACH_ABSORIGIN_FOLLOW=0;PATTACH_WORLDORIGIN=1
function Vector(x,y,z)return {x=x,y=y,z=z}end
MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT=1;MODIFIER_PROPERTY_TOOLTIP=2;MODIFIER_PROPERTY_TOOLTIP2=3
Convars={GetBool=function()return false end}
ParticleManager={SetParticleControl=function()end,CreateParticle=function()return 1 end,ReleaseParticleIndex=function()end}
require('abilities/heroes/jakiro/e')
local now,hits,query=0,{},{}
local function unit(name,team,building)
 local u={name=name,team=team,building=building,alive=true,removed=false,immune=false,mods={}}
 function u:IsNull()return self.removed end
 function u:IsAlive()assert(not self.removed);return self.alive end
 function u:GetTeamNumber()assert(not self.removed);return self.team end
 function u:GetUnitName()return self.name end
 function u:GetAbsOrigin()assert(not self.removed);return {}end
 function u:GetIntellect()assert(not self.removed);return self.int or 100 end
 function u:IsMagicImmune()return self.immune end
 function u:IsBuilding()return self.building end
 function u:EmitSound()assert(not self.removed)end
 function u:AddNewModifier(c,a,name,p)
  local m=self.mods[name]
  if m and not m.closed then m.expiry=now+p.duration;m:OnRefresh(p);return m end
  m=setmetatable({created=now,expiry=now+p.duration},_G[name]);self.mods[name]=m
  function m:GetParent()return u end
  function m:GetCaster()return c end
  function m:GetAbility()return a end
  function m:GetElapsedTime()return now-self.created end
  function m:GetRemainingTime()return self.expiry-now end
  function m:SetHasCustomTransmitterData()end
  function m:SendBuffRefreshToClients()end
  function m:StartIntervalThink(t)self.interval=t end
  function m:Destroy()self:OnDestroy()end
  m:OnCreated(p);return m
 end
 return u
end
local c=unit('jakiro',2);local vals={bonus_damage=90,slow_as=60,radius=300,duration=5,tick_rate=0.5,building_dmg_pct=75}
local a=setmetatable({removed=false},enfos_jakiro_liquid_fire)
function a:IsNull()return self.removed end
function a:GetCaster()assert(not self.removed);return c end
function a:GetSpecialValueFor(k)assert(not self.removed);return vals[k] or 0 end
local normal,boss,building=unit('creep',3),unit('enfos_boss_test',3),unit('tower',3,true)
function FindUnitsInRadius(team,origin,cache,radius,targetTeam,types,flags)assert(types==7 and flags==0 and radius==300);return query end
function ApplyDamage(info)hits[#hits+1]=info;return info.damage end
local function sum(u)local s=0;for _,h in ipairs(hits)do if h.victim==u then s=s+h.damage end end;return s end
local function dot(u)return u.mods.modifier_enfos_jakiro_liquid_fire_slow end
query={normal,boss,building};a:FireAt(normal)
assert(#hits==0,'Liquid Fire must not deal an instant burst')
assert(dot(normal).interval==0.5 and dot(normal):OnTooltip()==60 and dot(normal):OnTooltip2()==24)
c.int=1000;vals.bonus_damage=180;vals.slow_as=75
for i=1,9 do now=i*0.5;for _,u in ipairs(query)do dot(u):OnIntervalThink()end end
now=5;for _,u in ipairs(query)do dot(u):OnDestroy();dot(u):OnDestroy();assert(dot(u).interval==-1)end
assert(math.abs(sum(normal)-120)<0.001 and math.abs(sum(boss)-120)<0.001,'No boss exception or live stat reread')
assert(math.abs(sum(building)-90)<0.001,'Native building damage multiplier75%')
local purge=unit('purge',3);now=10;purge:AddNewModifier(c,a,'modifier_enfos_jakiro_liquid_fire_slow',{duration=5,dps=24,slow_as=60,tick_rate=0.5})
now=10.5;dot(purge):OnIntervalThink();local before=sum(purge);now=10.75;dot(purge):OnDestroy();now=12;dot(purge):OnIntervalThink();assert(sum(purge)==before and before==12)
local refresh=unit('refresh',3);now=20;refresh:AddNewModifier(c,a,'modifier_enfos_jakiro_liquid_fire_slow',{duration=5,dps=24,slow_as=60,tick_rate=0.5})
now=20.75;refresh:AddNewModifier(c,a,'modifier_enfos_jakiro_liquid_fire_slow',{duration=5,dps=40,slow_as=75,tick_rate=0.5})
assert(sum(refresh)==18 and dot(refresh):OnTooltip2()==40)
now=21.25;dot(refresh):OnIntervalThink();assert(sum(refresh)==38)
refresh.immune=true;now=21.75;dot(refresh):OnIntervalThink();assert(sum(refresh)==38 and dot(refresh):GetModifierAttackSpeedBonus_Constant()==0)
refresh.immune=false;now=22.25;dot(refresh):OnIntervalThink();assert(sum(refresh)==58,'No immunity catch-up')
for _,mode in ipairs({'removed_ability','removed_caster','removed_target','dead_target','dead_caster','client'})do
 now=30;local u=unit(mode,3);u:AddNewModifier(c,a,'modifier_enfos_jakiro_liquid_fire_slow',{duration=5,dps=24,slow_as=60,tick_rate=0.5});now=30.5
 if mode=='removed_ability' then a.removed=true elseif mode=='removed_caster' then c.removed=true elseif mode=='removed_target' then u.removed=true elseif mode=='dead_target' then u.alive=false elseif mode=='dead_caster' then c.alive=false else server=false end
 dot(u):OnIntervalThink();assert(sum(u)==(mode=='dead_caster' and 12 or 0))
 if mode~='dead_caster' and mode~='client' then assert(dot(u).closed and dot(u).interval==-1)end
 a.removed=false;c.removed=false;c.alive=true;server=true
end
local fractional=unit('fractional',3);now=40;fractional:AddNewModifier(c,a,'modifier_enfos_jakiro_liquid_fire_slow',{duration=1.25,dps=24,slow_as=60,tick_rate=0.5})
now=40.5;dot(fractional):OnIntervalThink();now=41;dot(fractional):OnIntervalThink();now=41.25;dot(fractional):OnDestroy();assert(sum(fractional)==30,'Natural expiry final partial slice')
local reentrant=unit('reentrant',3);now=50;reentrant:AddNewModifier(c,a,'modifier_enfos_jakiro_liquid_fire_slow',{duration=5,dps=24,slow_as=60,tick_rate=0.5})
local originalDamage=ApplyDamage;local nested=false
function ApplyDamage(info)
 local result=originalDamage(info)
 if not nested then nested=true;dot(reentrant):OnIntervalThink();a.removed=true end
 return result
end
now=50.5;dot(reentrant):OnIntervalThink();assert(sum(reentrant)==12,'Recursive damage callback cannot repeat elapsed slice')
now=51;dot(reentrant):OnIntervalThink();assert(dot(reentrant).closed and sum(reentrant)==12,'Removed ability cancels later ticks')
a.removed=false;ApplyDamage=originalDamage
local client=setmetatable({GetParent=function()return normal end},modifier_enfos_jakiro_liquid_fire_slow)
server=false;client:OnCreated({dps=999});client:HandleCustomTransmitterData(dot(normal):AddCustomTransmitterData())
assert(client:OnTooltip()==60 and client:OnTooltip2()==24);server=true
assert(dot(fractional):GetEffectName()=='particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf')
print('Jakiro E burn lifecycle PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.match(r.stdout,/Jakiro E burn lifecycle PASS/,r.stderr);
});
