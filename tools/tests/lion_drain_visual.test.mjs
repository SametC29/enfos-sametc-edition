import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync,execFileSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';

test('Lion drain owns one continuous beam, survives recast and closes reentrant resources',()=>{
 const baseline=process.env.LION_DRAIN_BASELINE?execFileSync('git',['show','HEAD:game/scripts/vscripts/abilities/heroes/lion/e.lua'],{encoding:'utf8'}):null;
 const lua=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end
local server=true;function IsServer()return server end;Convars={GetBool=function()return false end}
PATTACH_ABSORIGIN_FOLLOW=3;DAMAGE_TYPE_MAGICAL=2
local units={};function EntIndexToHScript(i)return units[i]end
local created,destroyed,released,binds=0,{},{},{};local hook;local hits,mana=0,0
ParticleManager={CreateParticle=function(_,path,attach,c)
 assert(path=='particles/units/heroes/hero_lion/lion_spell_mana_drain.vpcf' and attach==3)
 created=created+1;if hook then hook('create')end;return created end,
 SetParticleControlEnt=function(_,id,cp,u,attach,bone,pos,lock)
 assert(attach==3 and bone=='' and pos==u.pos and not lock);binds[id]=binds[id] or {};binds[id][cp]=u;if hook then hook('cp'..cp)end end,
 DestroyParticle=function(_,id)assert(not destroyed[id]);destroyed[id]=true end,
 ReleaseParticleIndex=function(_,id)assert(not released[id]);released[id]=true end}
function ApplyDamage(p)hits=hits+1;return p.damage end
${baseline?`assert(load([==[${baseline}]==]))()`:`require('abilities/heroes/lion/e')`}
local function unit()
 local u={pos={x=1,y=2,z=0},removed=false,alive=true,stopped=0,cleared=0}
 function u:IsNull()return self.removed end;function u:IsAlive()return self.alive end;function u:GetAbsOrigin()return self.pos end
 function u:GetIntellect()return 100 end;function u:GiveMana(n)mana=mana+n end
 function u:StopSound(s)assert(s=='Hero_Lion.ManaDrain');self.stopped=self.stopped+1 end
 function u:RemoveModifierByNameAndCaster(n,c)assert(n=='modifier_enfos_lion_mana_drain_debuff');self.cleared=self.cleared+1 end
 return u
end
local c,t=unit(),unit();units[1]=t
local a={GetCaster=function()return c end,GetSpecialValueFor=function(_,k)return k=='mana_per_second' and 120 or 0 end}
local function modifier()
 local m=setmetatable({intervals=0},modifier_enfos_lion_mana_drain_channel)
 function m:GetCaster()return c end;function m:GetParent()return c end;function m:GetAbility()return a end
 function m:StartIntervalThink(n)assert(n==.5);self.intervals=self.intervals+1 end
 return m
end
local m=modifier();m:OnCreated({target_idx=1});assert(created==1 and m.drain_fx==1 and m.intervals==1)
assert(binds[1][0]==c and binds[1][1]==t)
for i=1,100 do m:OnIntervalThink()end
assert(created==1 and hits==100 and mana==10000,'Ticks retain existing damage/mana, but cannot spawn more beams')
local t2=unit();units[2]=t2;m:OnRefresh({target_idx=2});assert(created==2 and destroyed[1] and released[1] and m.drain_target==t2 and t.cleared==1 and m.intervals==1)
assert(binds[2][0]==c and binds[2][1]==t2)
units[2]=unit();m:OnDestroy();m:OnDestroy();assert(destroyed[2] and released[2] and t2.cleared==1 and units[2].cleared==0 and c.stopped==1,'Teardown uses saved target, not recycled entity index')
local n=hits;m:OnIntervalThink();assert(hits==n)
for _,phase in ipairs({'create','cp0','cp1'})do
 local x=modifier();hook=function(p)if p==phase then x:OnDestroy()end end
 x:OnCreated({target_idx=1});hook=nil;assert(destroyed[created] and released[created] and x.intervals==0 and x.drain_fx==nil)
 if phase~='cp1' then assert(not binds[created] or not binds[created][1],'No target access after teardown')end
end
local x=modifier();x:OnCreated({target_idx=1});c.removed=true;t.removed=true;x:OnDestroy();assert(destroyed[created] and released[created]);c.removed=false;t.removed=false
local count=created;server=false;local client=modifier();client:OnCreated({target_idx=1});client:OnRefresh({target_idx=2});client:OnDestroy();assert(created==count);server=true
local trace=require('lib/hero_trace');local lines={};local oldPrint=print;print=function(s)lines[#lines+1]=s end
trace:SetEnabled(false);local off=modifier();off:OnCreated({target_idx=1});off:OnDestroy();assert(#lines==0)
trace:SetEnabled(true);local on=modifier();on:OnCreated({target_idx=1});on:OnRefresh({target_idx=1});on:OnDestroy();trace:SetEnabled(false);print=oldPrint
local text=table.concat(lines,'\\n');for _,event in ipairs({'beam created','beam removed','channel visual refreshed','channel visual teardown'})do assert(text:find('[LION_TRACE][E] '..event,1,true))end
print('Lion drain visual PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:lua,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.equal(r.stderr,'');assert.match(r.stdout,/Lion drain visual PASS/);
 // This repair does not silently decide the pending native/PvE mana conversion.
 const path='game/scripts/npc/npc_abilities_custom.txt';
 const old=parseKV(execFileSync('git',['show','1d6a67f:'+path],{encoding:'utf8'})).DOTAAbilities.enfos_lion_mana_drain;
 assert.deepEqual(parseKV(fs.readFileSync(path,'utf8')).DOTAAbilities.enfos_lion_mana_drain,old);
});
