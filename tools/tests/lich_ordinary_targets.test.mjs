import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';

const abilities=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
const curve=(id,key)=>String(abilities[id].AbilityValues[key]).split(/\s+/).map(Number);
const q='enfos_lich_frost_blast',r='enfos_lich_chain_frost';

test('Lich Q and R use ordinary ranked formulas on both normal and Boss recipients',()=>{
  const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t) t.__index=t;return t end
function LinkLuaModifier() end
function IsServer() return true end
DAMAGE_TYPE_MAGICAL=2;PATTACH_ABSORIGIN_FOLLOW=1
DOTA_UNIT_TARGET_TEAM_ENEMY=1;DOTA_UNIT_TARGET_HERO=1;DOTA_UNIT_TARGET_BASIC=2
DOTA_UNIT_TARGET_FLAG_NONE=0;FIND_ANY_ORDER=0
function Vector(x,y,z) return {x=x,y=y,z=z} end
local controls={}
ParticleManager={CreateParticle=function() controls={};return 1 end,
  SetParticleControl=function(_,id,cp,v) controls[cp]=v end,ReleaseParticleIndex=function() end}
local world,damageEvents,sounds={},{},{}
function FindUnitsInRadius() return world end
function ApplyDamage(e) damageEvents[#damageEvents+1]=e;return e.damage end
local function unit(boss,index)
  return {isBoss=boss,IsNull=function() return false end,IsAlive=function() return true end,
    GetUnitName=function() return boss and 'enfos_boss_test' or 'normal_test' end,
    GetTeamNumber=function() return index==1 and 2 or 3 end,
    GetAbsOrigin=function() return {x=index*100,y=0,z=0} end,
    GetIntellect=function() return 1000 end,GetMaxHealth=function() return 100 end,
    EmitSound=function(self,event) sounds[#sounds+1]={unit=self,event=event} end,
    IsHero=function() return false end,entindex=function() return index end,
    AddNewModifier=function(self,c,a,name,kv) self.slow=kv.duration;return {} end}
end
require('abilities/heroes/lich/q');require('abilities/heroes/lich/r')
do
  local c,p=unit(false,1),unit(false,1)
  p.TriggerSpellAbsorb=function() error('Friendly Q must not consume spell absorb') end
  p.EmitSound=function() error('Friendly Q must not emit cast feedback') end
  local a=setmetatable({GetCaster=function() return c end,GetCursorTarget=function() return p end},enfos_lich_frost_blast)
  damageEvents={};a:OnSpellStart();assert(#damageEvents==0,'Friendly Q must not deal damage')
end
local targetDamage,splashDamage={${curve(q,'target_damage')}},{${curve(q,'radius_damage')}}
local duration,radius={${curve(q,'duration')}},{${curve(q,'radius')}}
local chainDamage,chainDuration={${curve(r,'damage')}},{${curve(r,'slow_duration')}}
for rank=1,10 do
  for _,boss in ipairs({false,true}) do
    local c,p,s=unit(false,1),unit(boss,2),unit(boss,3)
    local values={target_damage=targetDamage[rank],radius_damage=splashDamage[rank],duration=duration[rank],radius=radius[rank]}
    local a=setmetatable({GetCaster=function() return c end,GetCursorTarget=function() return p end,
      GetLevel=function() return rank end,GetSpecialValueFor=function(_,k) return values[k] or 0 end},enfos_lich_frost_blast)
    world={p,s};damageEvents={};sounds={};a:OnSpellStart()
    assert(#damageEvents==2)
    assert(#sounds==1 and sounds[1].unit==p and sounds[1].event=='Ability.FrostNova','Q emits one target-centered nova sound')
    assert(damageEvents[1].damage==targetDamage[rank]+800,'Q primary must not have a Boss maxHP cap')
    assert(damageEvents[2].damage==splashDamage[rank]+500,'Q splash must not have a Boss maxHP cap')
    assert(p.slow==duration[rank] and s.slow==duration[rank],'Q ordinary control duration applies to both')
    assert(controls[1] and controls[1].x==radius[rank] and controls[1].y==radius[rank] and controls[1].z==radius[rank],
      'Frost Nova children must receive their radius/thickness/speed CP1 inputs')
    local b=setmetatable({GetCaster=function() return c end},enfos_lich_chain_frost)
    p.slow=nil;damageEvents={}
    b:OnProjectileHit_ExtraData(p,nil,{hits=0,limit=1,damage=chainDamage[rank]+1000,slow_duration=chainDuration[1]})
    assert(#damageEvents==1 and damageEvents[1].damage==chainDamage[rank]+1000)
    assert(p.slow==chainDuration[1],'R ordinary slow duration applies to both')
  end
end
do
  local removed=false
  local a={IsNull=function() return removed end,GetSpecialValueFor=function(_,key)
    assert(not removed,'Do not read a removed slow ability')
    return ({slow_pct=51,slow_attack=40,slow_attack_pct=50})[key] or 0
  end}
  local qSlow=setmetatable({GetAbility=function() return a end},modifier_enfos_lich_frost_blast_slow)
  local rSlow=setmetatable({GetAbility=function() return a end},modifier_enfos_lich_chain_frost_slow)
  assert(qSlow:GetModifierMoveSpeedBonus_Percentage()==-51 and qSlow:GetModifierAttackSpeedBonus_Constant()==-40)
  assert(rSlow:GetModifierMoveSpeedBonus_Percentage()==-51 and rSlow:GetModifierAttackSpeedBonus_Constant()==-50)
  removed=true
  for _,m in ipairs({qSlow,rSlow}) do
    assert(m:GetModifierMoveSpeedBonus_Percentage()==0 and m:GetModifierAttackSpeedBonus_Constant()==0,
      'Removed ability must not produce hard-coded orphan slow values')
  end
end
print('Lich ordinary targets ten-rank regression PASS')
`;
  const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
  assert.equal(result.status,0,result.stderr||result.stdout);
  assert.match(result.stdout,/Lich ordinary targets ten-rank regression PASS/,result.stderr);
});
