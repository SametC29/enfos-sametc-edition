import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync,execFileSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';
test('Lion primary and Shard drain transfer actual mana and convert only mana-less enemies',()=>{
 const values=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities.enfos_lion_mana_drain.AbilityValues;
 const rates=values.mana_per_second.split(/\s+/).join(',');
 const baseline=process.env.LION_ECONOMY_BASELINE?execFileSync('git',['show','HEAD:game/scripts/vscripts/abilities/heroes/lion/e.lua'],{encoding:'utf8'}):null;
 const lua=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end
local server=true;function IsServer()return server end;Convars={GetBool=function()return false end};DAMAGE_TYPE_MAGICAL=2
${baseline?`assert(load([==[${baseline}]==]))()`:`require('abilities/heroes/lion/e')`}
local Extras=require('abilities/heroes/lion/drain_extras')
local damage,mana,reductions,hook=0,0,0,nil
function ApplyDamage(p)damage=damage+p.damage;if hook then hook('damage')end;return p.damage end
local function unit(team,maxMana,currentMana)
 local u={team=team,maxMana=maxMana,mana=currentMana,alive=true,pos={x=0,y=0,z=0}}
 function u:IsNull()return self.removed end;function u:IsAlive()return self.alive end;function u:GetTeamNumber()return self.team end
 function u:IsBuilding()return self.building end;function u:IsMagicImmune()return self.immune end;function u:IsDebuffImmune()return self.immune end
 function u:GetAbsOrigin()return self.pos end;function u:GetIntellect()return 100 end
 function u:IsInvisible()return false end;function u:CanEntityBeSeenByMyTeam()return true end
 function u:GetMaxMana()assert(not self.removed);return self.maxMana end
 function u:GetMana()assert(not self.removed);return self.mana end
 function u:Script_ReduceMana(n,a)
  assert(a:GetCaster()~=self);reductions=reductions+1;self.mana=self.mana-n*(self.lossFactor or 1)
  if hook then hook('reduce')end
  return -999 -- Test observed loss, not guessed return-value semantics.
 end
 function u:GiveMana(n)mana=mana+n;if hook then hook('gain')end end
 function u:HasModifier(n)return self.shard and n=='modifier_item_aghanims_shard_permanent_buff' end
 function u:GetUnitName()return self.team==2 and 'npc_dota_hero_lion' or 'enfos_creep' end
 return u
end
local c,t,a,m
local rates={${rates}}
local function reset(rank,maxMana,currentMana)
 damage,mana,reductions,hook=0,0,0,nil;c=unit(2,1000,100);t=unit(3,maxMana,currentMana)
 a=setmetatable({rank=rank,channel=true},enfos_lion_mana_drain)
 function a:IsNull()return self.removed end;function a:GetCaster()return c end;function a:GetLevel()return self.rank end
 function a:IsChanneling()return self.channel end;function a:EndChannel()self.channel=false end
 function a:GetSpecialValueFor(k)return k=='mana_per_second' and rates[self.rank] or k=='break_distance' and 1100 or 0 end
 m=setmetatable({revision=1,drain_target=t,extra_drains={}},modifier_enfos_lion_mana_drain_channel)
 function m:GetParent()return c end;function m:GetAbility()return a end
 function m:Destroy()self.closed=true end
 return (rates[rank]+80)*.5
end
for rank=1,10 do
 local amount=reset(rank,1000,25);m:OnIntervalThink()
 assert(t.mana==0 and mana==25 and damage==0 and reductions==1,'Mana-bearing primary must lose real mana and credit only available mana')
 m:OnIntervalThink();assert(mana==25 and damage==0 and reductions==1,'An empty mana-bearing enemy must not become a conversion source')
 amount=reset(rank,0,0);m:OnIntervalThink();assert(damage==amount and mana==amount and reductions==0,'Only zero-maximum-mana PvE enemies convert damage')
 amount=reset(rank,1000,1000);t.lossFactor=.5;m:OnIntervalThink();assert(mana==amount*.5 and damage==0,'Native partial mana loss cannot mint the requested full amount')
 for _,max in ipairs({0,1000})do
  amount=reset(rank,max,max==0 and 0 or 25);c.shard=true
  m.extra_drains={{target=t}};Extras.Tick(m,1,amount,function()return true end)
  assert(mana==(max==0 and amount or 25) and damage==(max==0 and amount or 0),'Shard uses identical recipient economy')
 end
end
for _,path in ipairs({'primary','Shard'})do for _,mode in ipairs({'remove target','remove caster','remove ability','rank zero','finish','new revision','close','ally'})do
 local amount=reset(1,1000,1000);c.shard=true
 hook=function(phase)
  if phase~='reduce' then return end
  if mode=='remove target' then t.removed=true elseif mode=='remove caster' then c.removed=true
  elseif mode=='remove ability' then a.removed=true elseif mode=='rank zero' then a.rank=0
  elseif mode=='finish' then a.channel=false elseif mode=='new revision' then m.revision=2
  elseif mode=='close' then m.closed=true else t.team=2 end
 end
 if path=='primary' then m:OnIntervalThink() else m.extra_drains={{target=t}};Extras.Tick(m,1,amount,function(x,y)return y:GetTeamNumber()~=x:GetTeamNumber()end) end
 assert(mana==0 and damage==0,'Stale transfer cannot credit mana: '..path..' '..mode)
end end
local amount=reset(10,1000,25);c.shard=true
local emptyPool=unit(3,1000,0);local noPool=unit(3,0,0)
m.extra_drains={{target=emptyPool},{target=noPool}}
m:OnIntervalThink()
assert(mana==25+amount and damage==amount and t.mana==0 and emptyPool.mana==0,'One real primary tick must execute distinct primary and Shard mana policies together')
reset(1,1000,1000);server=false;m:OnIntervalThink();assert(reductions==0 and mana==0);server=true
print('Lion economy PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:lua,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.equal(r.stderr,'');assert.match(r.stdout,/Lion economy PASS/);
});
