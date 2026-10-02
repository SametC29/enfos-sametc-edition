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
ParticleManager={CreateParticle=function() return 1 end,SetParticleControl=function() end,ReleaseParticleIndex=function() end}
local world,damageEvents={},{}
function FindUnitsInRadius() return world end
function ApplyDamage(e) damageEvents[#damageEvents+1]=e;return e.damage end
local function unit(boss,index)
  return {isBoss=boss,IsNull=function() return false end,IsAlive=function() return true end,
    GetUnitName=function() return boss and 'enfos_boss_test' or 'normal_test' end,
    GetTeamNumber=function() return index==1 and 2 or 3 end,
    GetAbsOrigin=function() return {x=index*100,y=0,z=0} end,
    GetIntellect=function() return 1000 end,GetMaxHealth=function() return 100 end,
    EmitSound=function() end,IsHero=function() return false end,entindex=function() return index end,
    AddNewModifier=function(self,c,a,name,kv) self.slow=kv.duration;return {} end}
end
require('abilities/heroes/lich/q');require('abilities/heroes/lich/r')
local targetDamage,splashDamage={${curve(q,'target_damage')}},{${curve(q,'radius_damage')}}
local duration,radius={${curve(q,'duration')}},{${curve(q,'radius')}}
local chainDamage,chainDuration={${curve(r,'damage')}},{${curve(r,'slow_duration')}}
for rank=1,10 do
  for _,boss in ipairs({false,true}) do
    local c,p,s=unit(false,1),unit(boss,2),unit(boss,3)
    local values={target_damage=targetDamage[rank],radius_damage=splashDamage[rank],duration=duration[rank],radius=radius[rank]}
    local a=setmetatable({GetCaster=function() return c end,GetCursorTarget=function() return p end,
      GetLevel=function() return rank end,GetSpecialValueFor=function(_,k) return values[k] or 0 end},enfos_lich_frost_blast)
    world={p,s};damageEvents={};a:OnSpellStart()
    assert(#damageEvents==2)
    assert(damageEvents[1].damage==targetDamage[rank]+800,'Q primary must not have a Boss maxHP cap')
    assert(damageEvents[2].damage==splashDamage[rank]+500,'Q splash must not have a Boss maxHP cap')
    assert(p.slow==duration[rank] and s.slow==duration[rank],'Q ordinary control duration applies to both')
    local b=setmetatable({GetCaster=function() return c end},enfos_lich_chain_frost)
    p.slow=nil;damageEvents={}
    b:OnProjectileHit_ExtraData(p,nil,{hits=0,limit=1,damage=chainDamage[rank]+1000,slow_duration=chainDuration[1]})
    assert(#damageEvents==1 and damageEvents[1].damage==chainDamage[rank]+1000)
    assert(p.slow==chainDuration[1],'R ordinary slow duration applies to both')
  end
end
print('Lich ordinary targets ten-rank regression PASS')
`;
  const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
  assert.equal(result.status,0,result.stderr||result.stdout);
  assert.match(result.stdout,/Lich ordinary targets ten-rank regression PASS/,result.stderr);
});
