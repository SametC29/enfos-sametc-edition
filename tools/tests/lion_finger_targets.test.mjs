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
local recipients,hits={},{};local roots,releases=0,0;local bound,destroyed={},{};local particleHook,damageHook,soundHook,absorbHook
function FindUnitsInRadius(team,p,_,radius,enemy,types,flags)assert(team==2 and radius==325 and types==6 and flags==0);return recipients end
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
local c=unit();c.team=2;local normal,boss=unit(),unit(true);local counter={stacks=0}
function counter:IsNull()return self.removed end
function counter:GetStackCount()assert(not self.removed);return self.stacks end;function counter:SetStackCount(n)self.stacks=n end
function c:FindModifierByName(n)assert(n=='modifier_enfos_lion_finger_counter');return counter end
local a=setmetatable({rank=1},enfos_lion_finger_of_death);local base={${values.damage.split(/\s+/).join(',')}}
local specials={int_scaling_pct=${values.int_scaling_pct},kill_stack_cap=${values.kill_stack_cap},kill_stack_damage=${values.kill_stack_damage},kill_stack_spell_amp_pct=${values.kill_stack_spell_amp_pct},splash_radius=${values.splash_radius},boss_damage_cap_pct=12}
function a:GetSpecialValueFor(k)return k=='damage' and base[self.rank] or specials[k] or 0 end
function a:IsNull()return self.removed end;function a:GetCaster()return c end;function a:GetCursorTarget()return normal end
recipients={normal,boss}
for rank=1,10 do
 a.rank=rank
 for _,stacks in ipairs({0,3,20,25})do
  counter.stacks=stacks;hits={};normal.health=1000000;boss.health=1000000;boss.max=rank*100
  a:OnSpellStart();assert(bound[roots][0]==c and bound[roots][1]==normal,'Finite beam source/target must be separate');local expected=base[rank]+250+math.min(stacks,20)*40
  assert(#hits==2 and hits[1].damage==expected and hits[2].damage==expected,'Boss must receive ordinary damage at every rank')
 end
end
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
