import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync,execFileSync} from 'node:child_process';

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
 a=setmetatable({},enfos_lion_mana_drain)
 function a:IsNull()return self.removed end
 function a:GetCaster()return c end;function a:GetCursorTarget()return t end
 function a:GetSpecialValueFor(k)assert(not self.removed and k=='channel_duration');return 4 end
end
reset();a:OnSpellStart();assert(adds==2 and sounds==1,'Ordinary enemy cast still owns two modifiers')
for _,mode in ipairs({'friendly','dead','removed','building','magic','debuff','absorbed'})do
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
reset();server=false;a:OnSpellStart();assert(adds==0 and sounds==0)
print('Lion drain cast PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:lua,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.equal(r.stderr,'');assert.match(r.stdout,/Lion drain cast PASS/);
});
