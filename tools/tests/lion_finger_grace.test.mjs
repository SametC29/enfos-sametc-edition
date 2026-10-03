import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync,execFileSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';

test('Lion Finger credits one affected enemy death within a pause-safe bounded grace window',()=>{
 const v=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities.enfos_lion_finger_of_death.AbilityValues;
 const baseline=process.env.LION_GRACE_BASELINE?execFileSync('git',['show','HEAD:game/scripts/vscripts/abilities/heroes/lion/r.lua'],{encoding:'utf8'}):null;
 const lua=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end
local server=true;function IsServer()return server end
Convars={GetBool=function()return false end}
DAMAGE_TYPE_MAGICAL=2;DOTA_UNIT_TARGET_TEAM_ENEMY=1;DOTA_UNIT_TARGET_HERO=2;DOTA_UNIT_TARGET_BASIC=4;DOTA_UNIT_TARGET_FLAG_NONE=0;FIND_ANY_ORDER=0;PATTACH_ABSORIGIN_FOLLOW=7
MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE=1;MODIFIER_PROPERTY_TOOLTIP=2;MODIFIER_PROPERTY_TOOLTIP2=3;MODIFIER_EVENT_ON_DEATH=220
local time=10;local serial=0;local contexts={};local hits={};local targets={};local damageHook
function DoUniqueString(seed)serial=serial+1;return seed..serial end
GameRules={GetGameTime=function()return time end,GetGameModeEntity=function()return {
 SetContextThink=function(_,name,callback,delay)contexts[#contexts+1]={name=name,callback=callback,delay=delay}end
}end}
ParticleManager={CreateParticle=function()return 1 end,SetParticleControlEnt=function()end,ReleaseParticleIndex=function()end,DestroyParticle=function()end}
function FindUnitsInRadius()return targets end
function ApplyDamage(p)hits[#hits+1]=p;p.victim.health=p.victim.health-p.damage;if damageHook then damageHook(p.victim)end;return p.damage end
${baseline?`assert(load([==[${baseline}]==]))()`:`require('abilities/heroes/lion/r')`}
local function unit(boss)
 local u={health=100000,team=3,boss=boss,pos={x=0,y=0,z=0}}
 function u:IsNull()return self.removed end;function u:IsAlive()return self.health>0 end
 function u:GetTeamNumber()return self.team end;function u:GetAbsOrigin()return self.pos end
 function u:GetIntellect()return 100 end;function u:HasScepter()return self.scepter end
 function u:TriggerSpellAbsorb()return self.absorb end;function u:EmitSound()end
 function u:IsBuilding()return self.building end;function u:IsMagicImmune()return self.magic end;function u:IsDebuffImmune()return self.debuff end
 function u:GetUnitName()return self.boss and 'enfos_boss_test' or 'enfos_creep' end
 return u
end
local c=unit();c.team=2
local chosen;local a=setmetatable({rank=1},enfos_lion_finger_of_death)
function a:IsNull()return self.removed end;function a:GetCaster()return c end;function a:GetCursorTarget()return chosen end;function a:GetLevel()return self.rank end;function a:ShouldAltCast()return true end
local values={damage_delay=.25,grace_period=3,splash_radius=325,scepter_bonus_damage=100,int_scaling_pct=250,kill_stack_cap=20,kill_stack_damage=40,kill_stack_spell_amp_pct=1.5}
local damages={${v.damage.split(/\s+/).join(',')}}
function a:GetSpecialValueFor(k)return k=='damage' and damages[self.rank] or values[k] or 0 end
local m
local function counter()
 local n=setmetatable({stacks=0},modifier_enfos_lion_finger_counter)
 function n:IsNull()return self.removed end;function n:GetParent()return c end;function n:GetAbility()return self.otherAbility or a end
 function n:GetStackCount()return self.stacks end;function n:SetStackCount(k)self.stacks=k end
 n:OnCreated();return n
end
m=counter();function c:FindModifierByName()return m end
local function latest(prefix)
 for i=#contexts,1,-1 do if contexts[i].name:find(prefix,1,true)then return contexts[i]end end
 error('Missing context '..prefix)
end
local function hit(u)
 chosen=u;a:OnSpellStart();local impact=latest('EnfosLionFingerImpact');assert(impact.delay==.25)
 assert(impact.callback()==nil);return impact
end
local function die(u)u.health=0;m:OnDeath({unit=u,attacker=unit()})end
-- This is the independently observed defect: surviving R then dying to an ally gave no stack.
chosen=unit();hit(chosen);assert(chosen:IsAlive() and m.stacks==0)
assert(type(m.OnDeath)=='function','Affected deaths after impact must be observed')
time=12.999;die(chosen);assert(m.stacks==1,'An ally finishing a hit enemy within three seconds credits Lion')
die(chosen);assert(m.stacks==1,'Duplicate death events cannot credit twice')
assert(m:RemoveOnDeath()==false and m:IsPurgable()==false,'Match-only kill counter survives death and dispel')
-- Exact boundary and ordinary Boss behavior are the same at all ten ranks.
for rank=1,10 do for _,boss in ipairs({false,true})do
 for _,elapsed in ipairs({0,2.999,3,3.0001})do
  m=counter();a.rank=rank;time=20;local u=unit(boss);hit(u);time=20+elapsed;die(u)
  assert(m.stacks==(elapsed<=3 and 1 or 0),'Grace boundary must use game time, not damage or Boss type')
 end
end end
a.rank=1;m=counter();time=30;local instant=unit();instant.health=1
damageHook=function(u)m:OnDeath({unit=u})end
hit(instant);damageHook=nil;assert(m.stacks==1,'Synchronous death and post-damage fallback share one consumed receipt')
die(instant);assert(m.stacks==1)
m=counter();time=40;local u=unit();hit(u);local cleanup=latest('EnfosLionFingerGrace')
assert(cleanup.delay==3);local count=#contexts
time=42;hit(u);assert(#contexts==count+1,'Repeated impacts share one counter expiry context')
time=43.001;assert(cleanup.callback()>0,'Old deadline cannot erase refreshed target receipt')
time=45;die(u);assert(m.stacks==1,'Latest hit refreshes one reward window')
time=45.1;assert(cleanup.callback()==nil and next(m.pendingFingerHits)==nil,'Empty attribution ledger terminates')
-- Pause clock does not advance: expiry cannot remove valid marks merely due to wall time.
m=counter();time=50;u=unit();hit(u);cleanup=latest('EnfosLionFingerGrace')
for i=1,5 do assert(cleanup.callback()==3 and m.pendingFingerHits[u])end
time=53;assert(cleanup.callback()>0);die(u);assert(m.stacks==1)
time=53.01;assert(cleanup.callback()==nil)
-- Idle expiry clears references, stops, then a new hit arms exactly one new context.
m=counter();time=60;u=unit();hit(u);cleanup=latest('EnfosLionFingerGrace');time=63.01
assert(cleanup.callback()==nil and next(m.pendingFingerHits)==nil and not m.fingerCleanupArmed)
count=#contexts;local later=unit();hit(later);assert(#contexts==count+2)
local laterToken=m.fingerCleanupToken
assert(cleanup.callback()==nil and m.pendingFingerHits[later] and m.fingerCleanupToken==laterToken and m.fingerCleanupArmed,'Terminated cleanup cannot steal a new context')
-- Recreated modifier state must not be changed by an old queued cleanup.
m=counter();time=70;u=unit();hit(u);cleanup=latest('EnfosLionFingerGrace');m:OnDestroy();m:OnCreated()
time=71;local fresh=unit();hit(fresh);local newMap=m.pendingFingerHits
time=74;assert(cleanup.callback()==nil and m.pendingFingerHits==newMap and newMap[fresh])
die(fresh);assert(m.stacks==1)
for _,mode in ipairs({'caster removed','ability removed','rank zero','counter removed','counter closed','ability replaced','target removed','target allied','caster changed team','target building'})do
 m=counter();time=80;u=unit();hit(u)
 if mode=='caster removed' then c.removed=true elseif mode=='ability removed' then a.removed=true elseif mode=='rank zero' then a.rank=0
 elseif mode=='counter removed' then m.removed=true elseif mode=='counter closed' then m:OnDestroy() elseif mode=='ability replaced' then m.otherAbility={GetLevel=function()return 1 end,GetCaster=function()return c end}
 elseif mode=='target removed' then u.removed=true elseif mode=='target allied' then u.team=2 elseif mode=='caster changed team' then c.team=3 else u.building=true end
 die(u);assert(m.stacks==0,mode);c.removed=false;c.team=2;a.removed=false;a.rank=1
end
m=counter();time=90;u=unit();hit(u);c.health=0;die(u);assert(m.stacks==1,'An already affected enemy may credit a dead but valid Lion');c.health=100000
m=counter();time=100;u=unit();hit(u);server=false;die(u);assert(m.stacks==0,'Client events cannot grant stacks');server=true
die(u);assert(m.stacks==1)
m=counter();time=105;u=unit();hit(u)
local setStack=m.SetStackCount;m.SetStackCount=function(self,n)setStack(self,n);self:OnDeath({unit=u})end
die(u);assert(m.stacks==1,'Stack callback reentrancy cannot consume a claim twice')
m=counter();m.stacks=20;time=110;u=unit();hit(u);die(u);assert(m.stacks==20)
-- Two counters have distinct original-handle ledgers; no cross-Lion consumption.
m=counter();time=120;u=unit();hit(u);local first=m;m=counter();hit(u);die(u);first:OnDeath({unit=u});assert(m.stacks==1 and first.stacks==1)
m=counter();time=130;u=unit();u.absorb=true;chosen=u;count=#contexts;a:OnSpellStart();assert(#contexts==count);die(u);assert(m.stacks==0)
local untouched=unit();die(untouched);assert(m.stacks==0,'Non-hit deaths do not credit')
-- Distinct Scepter victims may each credit exactly once, with identical normal/Boss policy.
m=counter();time=140;c.scepter=true;u=unit();local boss=unit(true);targets={u,boss,boss};hit(u)
die(u);die(boss);die(boss);assert(m.stacks==2);c.scepter=false
print('Lion grace PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:lua,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.equal(r.stderr,'');assert.match(r.stdout,/Lion grace PASS/);
 assert.equal(v.grace_period,'3','Native verified grace window is data-driven');
});
