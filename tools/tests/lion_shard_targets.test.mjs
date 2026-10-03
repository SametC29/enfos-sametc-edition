import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync,execFileSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';

test('Lion Shard owns at most two extra recipients with finite resources and callback-safe ticks',()=>{
 const kv=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities.enfos_lion_mana_drain;
 const baseline=process.env.LION_EXTRA_BASELINE?execFileSync('git',['show','HEAD:game/scripts/vscripts/abilities/heroes/lion/e.lua'],{encoding:'utf8'}):null;
 const lua=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end
local server=true;function IsServer()return server end;Convars={GetBool=function()return false end}
PATTACH_ABSORIGIN_FOLLOW=3;DAMAGE_TYPE_MAGICAL=2;DOTA_UNIT_TARGET_TEAM_ENEMY=2;DOTA_UNIT_TARGET_HERO=1;DOTA_UNIT_TARGET_BASIC=2
DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE=128;DOTA_UNIT_TARGET_FLAG_NO_INVIS=256;FIND_CLOSEST=1
local registry,candidates={},{};local reuseSlow=false;local searches,created,hits,mana=0,0,{},0;local beam,damageHook,manaHook,particleHook,slowHook={},nil,nil,nil,nil
function EntIndexToHScript(i)return registry[i]end
ParticleManager={CreateParticle=function(_,path,attach,c)
 assert(path=='particles/units/heroes/hero_lion/lion_spell_mana_drain.vpcf' and attach==3)
 created=created+1;local id=created;beam[id]={};if particleHook then particleHook('create')end;return id end,
 SetParticleControlEnt=function(_,id,cp,u,attach,bone,pos,lock)
 assert(attach==3 and bone=='' and pos==u.pos and not lock);beam[id][cp]=u;if particleHook then particleHook('cp'..cp)end end,
 DestroyParticle=function(_,id)assert(not beam[id].destroyed,'double destroy');beam[id].destroyed=true;if particleHook then particleHook('destroy')end end,
 ReleaseParticleIndex=function(_,id)assert(not beam[id].released,'double release');beam[id].released=true end}
function ApplyDamage(p)hits[#hits+1]={target=p.victim,amount=p.damage};if damageHook then damageHook(p.victim)end;return p.damage end
function FindUnitsInRadius(team,pos,cache,radius,tf,typ,flags,order,grow)
 assert(server and team==2 and radius==1300 and tf==2 and typ==3 and flags==384 and order==1 and not grow and cache==nil)
 searches=searches+1;return candidates
end
${baseline?`assert(load([==[${baseline}]==]))()`:`require('abilities/heroes/lion/e')`}
local function unit(team,x)
 local u={team=team or 3,pos={x=x or 0,y=0,z=0},alive=true,slows={}}
 function u:IsNull()return self.removed end;function u:IsAlive()assert(not self.removed);return self.alive end
 function u:GetUnitName()return 'npc_dota_hero_lion' end;function u:HasModifier(n)return self.shard and n=='modifier_item_aghanims_shard_permanent_buff' end
 function u:GetTeamNumber()return self.team end;function u:GetAbsOrigin()assert(not self.removed);return self.pos end
 function u:IsInvisible()return self.invisible end;function u:CanEntityBeSeenByMyTeam(t)assert(server);return not t.fog end
 function u:IsBuilding()return self.building end;function u:IsMagicImmune()return self.magic end;function u:IsDebuffImmune()return self.debuff end
 function u:GetIntellect()return 100 end;function u:GiveMana(n)mana=mana+n;if manaHook then manaHook()end end
 function u:StopSound()self.playing=false end
 function u:RemoveModifierByNameAndCaster(n,c)for _,m in ipairs(self.slows)do if m.caster==c then m:Destroy()end end end
 function u:AddNewModifier(c,a,n,params)
  assert(n=='modifier_enfos_lion_mana_drain_debuff' and params.duration==4)
  if reuseSlow then for _,old in ipairs(self.slows)do if old.caster==c and not old.closed then if slowHook then slowHook()end;return old end end end
  local m={caster=c};function m:IsNull()return self.closed end;function m:Destroy()self.closed=true end
  self.slows[#self.slows+1]=m;if slowHook then slowHook()end;return m
 end
 return u
end
local c,t,a,m,extra1,extra2
local function reset(shard)
 damageHook=nil;manaHook=nil;particleHook=nil;slowHook=nil
 c,t,extra1,extra2=unit(2),unit(3,50),unit(3,100),unit(3,200);c.shard=shard
 registry[1]=t;candidates={t,extra1,extra1,extra2,unit(3,250)}
 local castSource=c
 a=setmetatable({rate=120,channeling=true},enfos_lion_mana_drain)
 function a:IsNull()return self.removed end;function a:GetCaster()return castSource end
 function a:IsChanneling()return self.channeling end;function a:EndChannel()self.channeling=false end
 function a:GetSpecialValueFor(k)return k=='mana_per_second' and self.rate or k=='break_distance' and 1100 or k=='shard_break_distance_bonus' and 200 or k=='shard_bonus_targets' and 2 or k=='channel_duration' and 4 or 0 end
 m=setmetatable({intervals=0},modifier_enfos_lion_mana_drain_channel)
 local source,ability=c,a
 function m:GetCaster()return source end;function m:GetParent()return source end;function m:GetAbility()return ability end
 function m:Destroy()self:OnDestroy()end;function m:StartIntervalThink(n)assert(n==.5);self.intervals=self.intervals+1 end
end
local function active_beams()local n=0;for _,b in pairs(beam)do if not b.destroyed then n=n+1 end end;return n end
reset(false);local q=searches;m:OnCreated({target_idx=1});assert(searches==q and active_beams()==1);m:OnDestroy();assert(active_beams()==0)
reset(true);m:OnCreated({target_idx=1});assert(#(m.extra_drains or {})==2,'Shard must select two additional distinct targets')
assert(m.extra_drains[1].target==extra1 and m.extra_drains[2].target==extra2 and active_beams()==3 and m.intervals==1)
local n=created;q=searches;local h=#hits;local gain=mana
for i=1,100 do m:OnIntervalThink()end
assert(created==n and searches==q and #hits==h+300 and mana==gain+30000,'No effect/query growth during ticks')
assert(hits[h+1].target==t and hits[h+2].target==extra1 and hits[h+3].target==extra2)
local s1=m.extra_drains[1].slow;extra1.fog=true;m:OnIntervalThink();assert(s1.closed and not m.closed and active_beams()==2)
extra1.fog=false;h=#hits;m:OnIntervalThink();assert(#hits==h+2 and searches==q,'No replacement for lost secondary')
c.shard=false;m:OnIntervalThink();assert(#m.extra_drains==0 and active_beams()==1)
c.shard=true;m:OnIntervalThink();assert(#m.extra_drains==0 and searches==q,'Reacquisition waits until next cast')
m:OnDestroy();m:OnDestroy();assert(active_beams()==0)
-- Rank math is identical for every recipient; Boss labels confer no exception.
for _,rate in ipairs({${kv.AbilityValues.mana_per_second.split(/\s+/).join(',')}})do
 reset(true);a.rate=rate;extra2.isBoss=true;m:OnCreated({target_idx=1});h=#hits;gain=mana;m:OnIntervalThink()
 for j=1,3 do assert(hits[h+j].amount==(rate+80)*.5)end
 assert(mana==gain+3*(rate+80)*.5);m:OnDestroy()
end
-- Invalid and duplicate candidates never consume a recipient slot.
reset(true);local bad={}
for _,mode in ipairs({'removed','dead','friendly','building','magic','debuff','fog','invisible','outside'})do
 local u=unit(3,100);if mode=='dead' then u.alive=false elseif mode=='friendly' then u.team=2 elseif mode=='outside' then u.pos.x=1300.01 else u[mode]=true end;bad[#bad+1]=u
end
candidates={t,table.unpack(bad)};candidates[#candidates+1]=extra1;candidates[#candidates+1]=extra2
m:OnCreated({target_idx=1});assert(#m.extra_drains==2 and m.extra_drains[1].target==extra1 and m.extra_drains[2].target==extra2);m:OnDestroy()
for _,mode in ipairs({'dead','removed','friendly','building','magic','debuff','fog','invisible','outside','lethal','damage hides','damage removes','damage closes','mana closes','damage stops'})do
 reset(true);m:OnCreated({target_idx=1});local slow=m.extra_drains[1].slow;h=#hits;gain=mana
 if mode=='dead' then extra1.alive=false elseif mode=='friendly' then extra1.team=2 elseif mode=='outside' then extra1.pos.x=1300.01
 elseif mode=='lethal' then damageHook=function(u)if u==extra1 then u.alive=false end end
 elseif mode=='damage hides' then damageHook=function(u)if u==extra1 then u.fog=true end end
 elseif mode=='damage removes' then damageHook=function(u)if u==extra1 then u.removed=true end end
 elseif mode=='damage closes' then damageHook=function(u)if u==extra1 then m:OnDestroy()end end
 elseif mode=='damage stops' then damageHook=function(u)if u==extra1 then a.channeling=false end end
 elseif mode=='mana closes' then local calls=0;manaHook=function()calls=calls+1;if calls==2 then m:OnDestroy()end end
 else extra1[mode]=true end
 m:OnIntervalThink();damageHook=nil;manaHook=nil
 if mode=='damage closes' or mode=='damage stops' then assert(#hits==h+2 and mana==gain+100,mode)
 elseif mode=='mana closes' then assert(#hits==h+2 and mana==gain+200,mode)
 elseif mode=='lethal' then assert(#hits==h+3 and mana==gain+300 and slow.closed,mode)
 elseif mode=='damage hides' or mode=='damage removes' then assert(#hits==h+3 and mana==gain+200 and slow.closed,mode)
 else assert(#hits==h+2 and mana==gain+200 and slow.closed,mode)end
 m:OnDestroy();assert(active_beams()==0)
end
-- Resource creation and modifier callbacks cannot leak when closing the owner.
for _,phase in ipairs({'slow','create','cp0','cp1'})do
 reset(true);local calls=0
 if phase=='slow' then slowHook=function()m:OnDestroy()end
 else particleHook=function(p)if p==phase then calls=calls+1;if calls==2 then m:OnDestroy()end end end end
 m:OnCreated({target_idx=1});slowHook=nil;particleHook=nil
 assert(m.closed and active_beams()==0 and m.intervals==0,phase)
 for _,u in ipairs({extra1,extra2})do for _,slow in ipairs(u.slows)do assert(slow.closed,phase)end end
end
reset(true);m:OnCreated({target_idx=1});local old=m.extra_drains;registry[2]=unit(3,300);m:OnRefresh({target_idx=2})
assert(old[1].closed and old[2].closed and active_beams()==3 and m.intervals==1);m:OnDestroy()
-- Nested recast during an extra resource or damage callback preserves new revision.
for _,phase in ipairs({'create','cp0','cp1','damage','mana'})do
 reset(true);m:OnCreated({target_idx=1});registry[2]=unit(3,300)
 local old=m.extra_drains
 if phase=='damage' then damageHook=function(u)if u==extra1 then damageHook=nil;m:OnRefresh({target_idx=2})end end
 elseif phase=='mana' then local calls=0;manaHook=function()calls=calls+1;if calls==2 then manaHook=nil;m:OnRefresh({target_idx=2})end end
 else
  local calls=0;particleHook=function(p)if p==phase then calls=calls+1;if calls==2 then particleHook=nil;m:OnRefresh({target_idx=2})end end end
  m:OnRefresh({target_idx=1})
 end
 if phase=='damage' or phase=='mana' then m:OnIntervalThink()end
 particleHook=nil;damageHook=nil;manaHook=nil
 assert(not m.closed and m.drain_target==registry[2] and #m.extra_drains==2 and active_beams()==3,phase)
 assert(old[1].closed and old[2].closed);m:OnDestroy();assert(active_beams()==0,phase)
end
-- Old extra-particle teardown can synchronously start a fresh channel's sound.
reset(true);m:OnCreated({target_idx=1});c.playing=true;reuseSlow=true
local old=m;local fresh
particleHook=function(phase)if phase=='destroy' then
 particleHook=nil;c.playing=true
 fresh=setmetatable({intervals=0},modifier_enfos_lion_mana_drain_channel)
 local source,ability=c,a
 function fresh:GetCaster()return source end;function fresh:GetParent()return source end;function fresh:GetAbility()return ability end
 function fresh:Destroy()self:OnDestroy()end;function fresh:StartIntervalThink()self.intervals=self.intervals+1 end
 fresh:OnCreated({target_idx=1})
end end
old:OnDestroy();reuseSlow=false;assert(fresh and not fresh.closed and c.playing and active_beams()==3,'Old extra teardown must preserve fresh audio/resources')
for _,entry in ipairs(fresh.extra_drains)do assert(not entry.slow.closed,'Fresh extra slows must survive old teardown')end
fresh:OnDestroy();assert(active_beams()==0)
-- Engine AddNewModifier can refresh and return the same handle on a nested recast.
reset(true);reuseSlow=true
slowHook=function()slowHook=nil;m:OnRefresh({target_idx=1})end
m:OnCreated({target_idx=1});reuseSlow=false
assert(#m.extra_drains==2 and not m.extra_drains[1].slow.closed,'Old AddNewModifier continuation must not destroy newly retained slow')
m:OnDestroy();assert(active_beams()==0)
-- Two sources own independent slows even when recipients overlap.
reset(true);m:OnCreated({target_idx=1});local first=m;local firstSlow=m.extra_drains[1].slow;local overlap=extra1
reset(true);candidates={t,overlap,extra2};m:OnCreated({target_idx=1});local secondSlow=m.extra_drains[1].slow
assert(firstSlow~=secondSlow and active_beams()==6)
first:OnDestroy();assert(firstSlow.closed and not secondSlow.closed and active_beams()==3)
m:OnDestroy();assert(secondSlow.closed and active_beams()==0)
reset(true);registry[1]=nil;m:OnCreated({target_idx=1});assert(#(m.extra_drains or {})==0);m:OnDestroy();assert(active_beams()==0)
reset(true);server=false;q=searches;m:OnCreated({target_idx=1});assert(searches==q and active_beams()==0);server=true
print('Lion Shard recipients PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:lua,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.equal(r.stderr,'');assert.match(r.stdout,/Lion Shard recipients PASS/);
 assert.equal(kv.AbilityValues.shard_bonus_targets,'2');
 for(const lang of ['english','turkish','russian','schinese']){
  const text=JSON.parse(fs.readFileSync(`localization/${lang}.json`,'utf8')).Tokens.DOTA_Tooltip_Ability_enfos_lion_mana_drain_shard_description;
  assert.ok(text.includes('2'));
 }
});
