import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync,execFileSync} from 'node:child_process';

test('Lion Drain finish destroys only its exact source and parent, including rank loss and duplicate finish',()=>{
 const baseline=process.env.LION_DRAIN_FINISH_BASELINE?execFileSync('git',['show','HEAD:game/scripts/vscripts/abilities/heroes/lion/e.lua'],{encoding:'utf8'}):null;
 const lua=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end
local server=true;function IsServer()return server end
${baseline?`assert(load([==[${baseline}]==]))()`:`require('abilities/heroes/lion/e')`}
local c,a,m,current,destroyed,broad
local function reset()
 server=true;destroyed,broad=0,0
 c={};function c:IsNull()return self.removed end
 function c:FindModifierByName(name)assert(name=='modifier_enfos_lion_mana_drain_channel');return current end
 function c:RemoveModifierByName()broad=broad+1 end
 a=setmetatable({rank=1},enfos_lion_mana_drain)
 function a:IsNull()return self.removed end;function a:GetCaster()return c end;function a:GetLevel()return self.rank end
 function a:IsChanneling()assert(server,'Client cannot query engine channel state');return self.channeling or false end
 m={parent=c,ability=a};function m:IsNull()return self.removed end
 function m:GetParent()return self.parent end;function m:GetAbility()return self.ability end
 function m:Destroy()assert(not self.removed);destroyed=destroyed+1;self.closed=true;self.removed=true;if self.hook then self.hook()end end
 current=m
end
for _,interrupted in ipairs({false,true})do
 for _,rank in ipairs({0,1,10})do
  reset();a.rank=rank;a:OnChannelFinish(interrupted)
  assert(destroyed==1 and broad==0,'Finish must destroy the owned handle rather than remove by name')
  a:OnChannelFinish(interrupted);assert(destroyed==1,'Repeated finish must not destroy twice')
 end
end
for _,mode in ipairs({'none','foreign_ability','foreign_parent','closed','removed_modifier','removed_caster','removed_ability','client'})do
 reset()
 if mode=='none' then current=nil elseif mode=='foreign_ability' then m.ability={} elseif mode=='foreign_parent' then m.parent={}
 elseif mode=='closed' then m.closed=true elseif mode=='removed_modifier' then m.removed=true
 elseif mode=='removed_caster' then c.removed=true elseif mode=='removed_ability' then a.removed=true else server=false end
 a:OnChannelFinish(true);assert(destroyed==0 and broad==0,'Unowned/closed finish: '..mode)
end
reset();local replacement={}
m.hook=function()current=replacement end;a:OnChannelFinish(false)
assert(current==replacement and destroyed==1 and broad==0,'Destroy reentrancy must leave the replacement modifier alone')
for _,interrupted in ipairs({false,true})do
 reset();a.channeling=true
 a:OnChannelFinish(interrupted)
 assert(destroyed==0 and current==m and not m.closed,'An old finish cannot tear down the actively channeling replacement')
 a.channeling=false;a:OnChannelFinish(interrupted)
 assert(destroyed==1,'Once the engine stops channeling, normal source-owned cleanup still runs')
end
print('Lion drain finish ownership PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:lua,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.equal(r.stderr,'');assert.match(r.stdout,/Lion drain finish ownership PASS/);
});

test('Lion Drain rejects invalid ordinary targets and revalidates engine callbacks before modifier creation',()=>{
 const baseline=process.env.LION_DRAIN_CAST_BASELINE?execFileSync('git',['show','HEAD:game/scripts/vscripts/abilities/heroes/lion/e.lua'],{encoding:'utf8'}):null;
 const lua=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end
local server=true;function IsServer()return server end
${baseline?`assert(load([==[${baseline}]==]))()`:`require('abilities/heroes/lion/e')`}
local adds,sounds=0,0;local hook,c,t,a
local function unit(team)
 local u={team=team,alive=true}
 function u:IsNull()return self.removed end
 function u:IsAlive()assert(not self.removed);return self.alive end
 function u:IsInvisible()assert(not self.removed);return self.invisible end;function u:CanEntityBeSeenByMyTeam(target)assert(server and not self.removed);return not target.fog end
 function u:GetTeamNumber()assert(not self.removed);return self.team end
 function u:IsBuilding()return self.building end
 function u:IsMagicImmune()return self.magic end
 function u:IsDebuffImmune()return self.debuff end
 function u:TriggerSpellAbsorb()if hook then hook('absorb')end;return self.absorb end
 function u:EmitSound(s)assert(s=='Hero_Lion.ManaDrain');sounds=sounds+1;if hook then hook('sound')end end
 function u:entindex()assert(not self.removed);return 42 end
 function u:AddNewModifier(_,_,name,kv)
  assert(not self.removed);adds=adds+1
  assert(kv.duration==4);if name=='modifier_enfos_lion_mana_drain_channel' then assert(kv.target_idx==42)end
  if hook then hook('modifier')end
 end
 return u
end
local function reset()
 adds,sounds=0,0;hook=nil;c,t=unit(2),unit(3)
 a=setmetatable({rank=1},enfos_lion_mana_drain)
 function a:IsNull()return self.removed end;function a:GetLevel()return self.rank end
 function a:GetCaster()return c end;function a:GetCursorTarget()return t end
 function a:GetSpecialValueFor(k)assert(not self.removed and k=='channel_duration');return 4 end
end
reset();a:OnSpellStart();assert(adds==2 and sounds==1,'Ordinary enemy cast still owns two modifiers')
for _,mode in ipairs({'friendly','dead','removed','building','magic','debuff','absorbed','fog','invisible'})do
 reset()
 if mode=='friendly' then t.team=2 elseif mode=='dead' then t.alive=false elseif mode=='absorbed' then t.absorb=true else t[mode]=true end
 a:OnSpellStart();assert(adds==0 and sounds==0,mode)
end
for _,phase in ipairs({'absorb','sound','modifier'})do
 for _,who in ipairs({'caster','target','ability'})do
  reset();hook=function(p)if p==phase then (who=='caster' and c or who=='target' and t or a).removed=true end end
  a:OnSpellStart();assert(adds==(phase=='modifier' and 1 or 0),phase..' invalidates '..who)
 end
end
for _,phase in ipairs({'absorb','sound','modifier'})do
 reset();hook=function(p)if p==phase then a.rank=0 end end;a:OnSpellStart();assert(adds==(phase=='modifier' and 1 or 0),'Rank loss during '..phase..' cannot create new effects')
end
reset();a.rank=0;a:OnSpellStart();assert(adds==0 and sounds==0,'Unlearned Drain cannot cast or emit sound')
reset();server=false;a:OnSpellStart();assert(adds==0 and sounds==0)
print('Lion drain cast PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:lua,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.equal(r.stderr,'');assert.match(r.stdout,/Lion drain cast PASS/);
});
