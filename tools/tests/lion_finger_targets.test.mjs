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
local recipients,hits={},{};local roots,releases=0,0
function FindUnitsInRadius(team,p,_,radius,enemy,types,flags)assert(team==2 and radius==325 and types==6 and flags==0);return recipients end
function ApplyDamage(p)assert(p.damage_type==2);hits[#hits+1]=p;p.victim.health=p.victim.health-p.damage;return p.damage end
ParticleManager={CreateParticle=function()roots=roots+1;return roots end,ReleaseParticleIndex=function()releases=releases+1 end}
${baseline?`assert(load([==[${baseline}]==]))()`:`require('abilities/heroes/lion/r')`}
local function unit(boss)
 local u={health=1000000,isBoss=boss,pos={x=1,y=2,z=0},max=1000}
 function u:IsNull()return false end;function u:IsAlive()return self.health>0 end;function u:GetAbsOrigin()return self.pos end
 function u:GetTeamNumber()return 2 end;function u:GetUnitName()return self.isBoss and 'enfos_boss_test' or 'enfos_creep' end
 function u:GetMaxHealth()return self.max end;function u:TriggerSpellAbsorb()return self.absorb end
 function u:EmitSound(s)assert(s=='Hero_Lion.FingerOfDeath')end;function u:GetIntellect()return self.int or 100 end
 return u
end
local c=unit();local normal,boss=unit(),unit(true);local counter={stacks=0}
function counter:GetStackCount()return self.stacks end;function counter:SetStackCount(n)self.stacks=n end
function c:FindModifierByName(n)assert(n=='modifier_enfos_lion_finger_counter');return counter end
local a=setmetatable({rank=1},enfos_lion_finger_of_death);local base={${values.damage.split(/\s+/).join(',')}}
local specials={int_scaling_pct=${values.int_scaling_pct},kill_stack_cap=${values.kill_stack_cap},kill_stack_damage=${values.kill_stack_damage},kill_stack_spell_amp_pct=${values.kill_stack_spell_amp_pct},splash_radius=${values.splash_radius},boss_damage_cap_pct=12}
function a:GetSpecialValueFor(k)return k=='damage' and base[self.rank] or specials[k] or 0 end
function a:GetCaster()return c end;function a:GetCursorTarget()return normal end
recipients={normal,boss}
for rank=1,10 do
 a.rank=rank
 for _,stacks in ipairs({0,3,20,25})do
  counter.stacks=stacks;hits={};normal.health=1000000;boss.health=1000000;boss.max=rank*100
  a:OnSpellStart();local expected=base[rank]+250+math.min(stacks,20)*40
  assert(#hits==2 and hits[1].damage==expected and hits[2].damage==expected,'Boss must receive ordinary damage at every rank')
 end
end
counter.stacks=19;normal.health=1;boss.health=1;a:OnSpellStart();assert(counter.stacks==20,'Ordinary lethal kills retain bounded stack ownership')
normal.health=1000000;normal.absorb=true;local n=roots;hits={};a:OnSpellStart();assert(#hits==0 and roots==n,'Spell block is unchanged');normal.absorb=false
assert(roots==releases,'Existing finite effect ownership remains unchanged')
print('Lion Finger ordinary targets PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:lua,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.equal(r.stderr,'');assert.match(r.stdout,/Lion Finger ordinary targets PASS/);
 assert.ok(!('boss_damage_cap_pct' in values));
});
