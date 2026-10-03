import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync,execFileSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';

test('Lion Finger uses ordinary authored ten-rank damage on normal and Boss recipients',()=>{
 const kv=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities.enfos_lion_finger_of_death;
 const values=kv.AbilityValues;
 const baseline=process.env.LION_FINGER_BASELINE?execFileSync('git',['show','HEAD:game/scripts/vscripts/abilities/heroes/lion/r.lua'],{encoding:'utf8'}):null;
 const lua=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end;function IsServer()return true end
DAMAGE_TYPE_MAGICAL=2;DOTA_UNIT_TARGET_TEAM_ENEMY=1;DOTA_UNIT_TARGET_HERO=2;DOTA_UNIT_TARGET_BASIC=4;DOTA_UNIT_TARGET_FLAG_NONE=0;FIND_ANY_ORDER=0;PATTACH_ABSORIGIN_FOLLOW=7
local contexts={};local autoRun=true;local contextId=0
function DoUniqueString(seed)contextId=contextId+1;return seed..contextId end
GameRules={GetGameModeEntity=function()return {SetContextThink=function(_,name,callback,delay)assert(delay==.25);contexts[#contexts+1]={name=name,callback=callback,delay=delay};if autoRun then callback()end end}end}
local recipients,hits={},{};local queries=0;local roots,releases=0,0;local bound,destroyed={},{};local particleHook,damageHook,soundHook,absorbHook
function FindUnitsInRadius(team,p,_,radius,enemy,types,flags)queries=queries+1;assert(team==2 and radius==325 and types==6 and flags==0);return recipients end
function ApplyDamage(p)assert(p.damage_type==2);hits[#hits+1]=p;p.victim.health=p.victim.health-p.damage;if damageHook then damageHook(p.victim)end;return p.damage end
ParticleManager={CreateParticle=function(_,path,attach,c)roots=roots+1;if particleHook then particleHook('create')end;return roots end,
 SetParticleControlEnt=function(_,id,cp,u,attach,name,pos,lock)assert(attach==7 and name=='' and pos==u.pos and not lock);bound[id]=bound[id] or {};bound[id][cp]=u;if particleHook then particleHook('cp'..cp)end end,
 DestroyParticle=function(_,id)assert(not destroyed[id]);destroyed[id]=true end,
 ReleaseParticleIndex=function()releases=releases+1 end}
${baseline?`assert(load([==[${baseline}]==]))()`:`require('abilities/heroes/lion/r')`}
local function unit(boss)
 local u={health=1000000,isBoss=boss,pos={x=1,y=2,z=0},max=1000}
 function u:IsNull()return self.removed end;function u:IsAlive()return self.health>0 end;function u:GetAbsOrigin()return self.pos end
 function u:GetTeamNumber()return self.team or 3 end;function u:GetUnitName()return self.isBoss and 'enfos_boss_test' or 'enfos_creep' end
 function u:GetMaxHealth()return self.max end;function u:TriggerSpellAbsorb()if absorbHook then absorbHook()end;return self.absorb end
 function u:EmitSound(s)assert(s=='Hero_Lion.FingerOfDeath');if soundHook then soundHook()end end;function u:GetIntellect()return self.int or 100 end
 return u
end
local c=unit();c.team=2;c.scepter=true;function c:HasScepter()return self.scepter end;local normal,boss=unit(),unit(true);local counter={stacks=0}
function counter:IsNull()return self.removed end
function counter:GetStackCount()assert(not self.removed);return self.stacks end;function counter:SetStackCount(n)self.stacks=n end
function c:FindModifierByName(n)assert(n=='modifier_enfos_lion_finger_counter');return counter end
local a=setmetatable({rank=1},enfos_lion_finger_of_death);local base={${values.damage.split(/\s+/).join(',')}}
local specials={damage_delay=${values.damage_delay},int_scaling_pct=${values.int_scaling_pct},kill_stack_cap=${values.kill_stack_cap},kill_stack_damage=${values.kill_stack_damage},kill_stack_spell_amp_pct=${values.kill_stack_spell_amp_pct},scepter_bonus_damage=${values.scepter_bonus_damage},splash_radius=${values.splash_radius},boss_damage_cap_pct=12}
function a:GetSpecialValueFor(k)return k=='damage' and base[self.rank] or specials[k] or 0 end
function a:IsNull()return self.removed end;function a:GetCaster()return c end;function a:GetCursorTarget()return normal end
recipients={normal,boss}
assert(a:GetAOERadius()==325);c.scepter=false;assert(a:GetAOERadius()==0)
hits={};a:OnSpellStart();assert(#hits==1 and hits[1].victim==normal and hits[1].damage==850,'Base Finger is single-target')
c.scepter=true;recipients={boss,boss};hits={};a:OnSpellStart();assert(#hits==2 and hits[1].victim==normal and hits[2].victim==boss and hits[1].damage==950,'Scepter primary cannot be omitted or duplicated')
recipients={normal,boss}
for rank=1,10 do
 a.rank=rank
 for _,stacks in ipairs({0,3,20,25})do
  counter.stacks=stacks;hits={};normal.health=1000000;boss.health=1000000;boss.max=rank*100
  a:OnSpellStart();assert(bound[roots][0]==c and bound[roots][1]==normal,'Finite beam source/target must be separate');local expected=base[rank]+100+250+math.min(stacks,20)*40
  assert(#hits==2 and hits[1].damage==expected and hits[2].damage==expected,'Boss must receive ordinary damage at every rank')
 end
end
c.scepter=false
for rank=1,10 do
 a.rank=rank
 for _,isBoss in ipairs({false,true})do
  normal=unit(isBoss);boss=unit();recipients={normal,boss}
  for _,stacks in ipairs({0,3,20,25})do
   normal.health=1000000;counter.stacks=stacks;hits={};local q=queries
   a:OnSpellStart();assert(#hits==1 and queries==q and hits[1].victim==normal and hits[1].damage==base[rank]+250+math.min(stacks,20)*40,'All base ranks are single-target without a radius query')
  end
 end
end
c.scepter=true;counter.stacks=0;normal=unit();boss=unit();recipients={normal,boss};hits={}
soundHook=function()c.scepter=false end;a:OnSpellStart();soundHook=nil
assert(#hits==2 and hits[1].damage==base[10]+350,'Upgrade is snapshotted before callbacks');c.scepter=true
counter.stacks=19;normal.health=1;boss.health=1;a:OnSpellStart();assert(counter.stacks==20,'Ordinary lethal kills retain bounded stack ownership')
normal.health=1000000;normal.absorb=true;local n=roots;hits={};a:OnSpellStart();assert(#hits==0 and roots==n,'Spell block is unchanged');normal.absorb=false
for _,mode in ipairs({'friendly','dead','removed','magic','debuff','building'})do
 normal=unit();boss=unit(true);recipients={normal,boss};counter.stacks=0
 if mode=='friendly' then boss.team=2 elseif mode=='dead' then boss.health=0 else boss[mode]=true end
 function boss:IsMagicImmune()return self.magic end;function boss:IsDebuffImmune()return self.debuff end;function boss:IsBuilding()return self.building end
 hits={};a:OnSpellStart();assert(#hits==1 and hits[1].victim==normal and counter.stacks==0,mode)
end
for _,mode in ipairs({'friendly','dead','removed','magic','debuff','building'})do
 normal=unit();boss=unit(true);recipients={normal,boss}
 if mode=='friendly' then normal.team=2 elseif mode=='dead' then normal.health=0 else normal[mode]=true end
 function normal:IsMagicImmune()return self.magic end;function normal:IsDebuffImmune()return self.debuff end;function normal:IsBuilding()return self.building end
 local n=roots;hits={};a:OnSpellStart();assert(#hits==0 and roots==n,'Rejected main target '..mode)
end
normal=unit();boss=unit(true);recipients={normal,boss};hits={};soundHook=function()a.removed=true end;a:OnSpellStart();soundHook=nil;assert(#hits==0);a.removed=false
absorbHook=function()normal.removed=true end;a:OnSpellStart();absorbHook=nil;assert(#hits==0);normal.removed=false
for _,phase in ipairs({'create','cp0','cp1'})do
 hits={};particleHook=function(p)if p==phase then normal.removed=true end end;a:OnSpellStart();particleHook=nil
 assert(#hits==0 and destroyed[roots]);if phase~='cp1' then assert(not bound[roots] or not bound[roots][1])end;normal.removed=false
end
normal.health=1;hits={};damageHook=function(u)u.removed=true end;a:OnSpellStart();damageHook=nil;assert(#hits==2,'Removed recipients cannot throw during post-hit stack checks');normal.removed=false;boss.removed=false
normal.health=1;boss.health=1;counter.stacks=0;hits={};damageHook=function()counter.removed=true end;a:OnSpellStart();damageHook=nil;assert(counter.stacks==0);counter.removed=false
normal.health=1000000;boss.health=1000000;hits={};damageHook=function()c.removed=true end;a:OnSpellStart();damageHook=nil;assert(#hits==1);c.removed=false
local oldServer=IsServer;IsServer=function()return false end;hits={};a:OnSpellStart();assert(#hits==0);IsServer=oldServer
-- Queued engine contexts prove timing; prior smoke cases execute immediately only for compatibility.
autoRun=false;contexts={};normal=unit();boss=unit(true);recipients={normal,boss};hits={};counter.stacks=0;a.rank=1;c.scepter=false;c.int=100
local original=normal;a:OnSpellStart();assert(#hits==0 and #contexts==1 and contexts[1].delay==.25,'No immediate damage')
a.rank=10;counter.stacks=20;c.scepter=true;c.int=200;normal=unit();recipients={normal,boss};local second=normal
a:OnSpellStart();assert(#hits==0 and #contexts==2 and contexts[1].name~=contexts[2].name,'Overlapping casts need independent contexts')
assert(contexts[1].callback()==nil and #hits==1 and hits[1].victim==original and hits[1].damage==850,'First cast retains target/rank/stacks/int/upgrade snapshots')
assert(contexts[2].callback()==nil and #hits==3 and hits[2].victim==second and hits[2].damage==3200 and hits[3].damage==3200)
local n=#hits;assert(contexts[1].callback()==nil and contexts[2].callback()==nil and #hits==n,'Repeated invocation cannot duplicate impact')
for _,mode in ipairs({'target dead','target removed','target friendly','target magic','target debuff','target building','caster dead','caster removed','ability removed'})do
 contexts={};normal=unit();boss=unit();recipients={normal,boss};hits={};c.scepter=false;c.health=1000000;c.removed=false;c.int=100;counter.stacks=0;a.rank=1;a.removed=false
 a:OnSpellStart();assert(#hits==0 and #contexts==1)
 if mode=='target dead' then normal.health=0 elseif mode=='target removed' then normal.removed=true elseif mode=='target friendly' then normal.team=2
 elseif mode=='target magic' then normal.magic=true elseif mode=='target debuff' then normal.debuff=true elseif mode=='target building' then normal.building=true
 elseif mode=='caster dead' then c.health=0 elseif mode=='caster removed' then c.removed=true else a.removed=true end
 function normal:IsMagicImmune()return self.magic end;function normal:IsDebuffImmune()return self.debuff end;function normal:IsBuilding()return self.building end
 assert(contexts[1].callback()==nil and #hits==0,mode)
 assert(contexts[1].callback()==nil and #hits==0,mode..' repeated')
end
c.health=1000000;c.removed=false;a.removed=false;contexts={};normal=unit();boss=unit();recipients={normal,boss};hits={};c.scepter=true
normal.pos.x=100;a:OnSpellStart();normal.removed=true
assert(contexts[1].callback()==nil and #hits==1 and hits[1].victim==boss,'A dead/removed selected recipient does not cancel other saved area recipients')
contexts={};normal=unit();boss=unit();recipients={normal,boss};hits={};a:OnSpellStart()
GameRules.IsGamePaused=function()return true end
assert(contexts[1].callback()==.03 and #hits==0,'Paused callback must defer gameplay without consuming completion')
GameRules.IsGamePaused=function()return false end
assert(contexts[1].callback()==nil and #hits==2);n=#hits;assert(contexts[1].callback()==nil and #hits==n)
GameRules.IsGamePaused=nil;autoRun=true;normal=unit();boss=unit();recipients={normal,boss};hits={}
local trace=require('lib/hero_trace');local oldPrint=print;local lines={};print=function(x)lines[#lines+1]=x end
trace:SetEnabled(false);a:OnSpellStart();assert(#lines==0)
trace:SetEnabled(true);a:OnSpellStart();assert(#lines==3 and lines[1]:find('[LION_TRACE][R] cast',1,true));trace:SetEnabled(false);print=oldPrint
assert(roots==releases,'Existing finite effect ownership remains unchanged')
print('Lion Finger ordinary targets PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:lua,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.equal(r.stderr,'');assert.match(r.stdout,/Lion Finger ordinary targets PASS/);
 assert.ok(!('boss_damage_cap_pct' in values));assert.equal(kv.AbilityCastAnimation,'ACT_DOTA_CAST_ABILITY_4');
});
