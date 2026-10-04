import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync,execFileSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';

test('Lion Hex transforms, transmits saved speed and closes owned effects without Boss overrides',()=>{
 const durations=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities.enfos_lion_hex.AbilityValues.duration.split(/\s+/).join(',');
 const baseline=process.env.LION_HEX_BASELINE?execFileSync('git',['show','HEAD:game/scripts/vscripts/abilities/heroes/lion/w.lua'],{encoding:'utf8'}):null;
 const lua=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end
local server=true;function IsServer()return server end
Convars={GetBool=function()return false end}
MODIFIER_STATE_HEXED=1;MODIFIER_STATE_SILENCED=2;MODIFIER_STATE_DISARMED=3;MODIFIER_STATE_MUTED=4
MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE=5;MODIFIER_PROPERTY_MODEL_CHANGE=6;PATTACH_ABSORIGIN_FOLLOW=7
local created,owned,destroyed,released=0,0,{},{};local hook,soundHook,absorbHook;local binds={}
ParticleManager={CreateParticle=function(_,path,attach,p)
 assert(path=='particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf' and attach==7)
 created=created+1;if hook then hook('create')end;return created end,
 SetParticleControlEnt=function(_,id,cp,p,attach,name,pos,lock)
 assert(cp==1 and attach==7 and name=='' and pos==p.pos and lock==false);binds[id]=p;if hook then hook('bind')end end,
 DestroyParticle=function(_,id)assert(not destroyed[id]);destroyed[id]=true end,
 ReleaseParticleIndex=function(_,id)assert(not released[id]);released[id]=true end}
${baseline?`assert(load([==[${baseline}]==]))()`:`require('abilities/heroes/lion/w')`}
local function unit(team)
 local t={team=team,health=100,pos={x=10,y=20,z=0},mods={}}
 function t:IsNull()return self.removed end;function t:IsAlive()return self.health>0 end
 function t:GetUnitName()return self.boss and 'enfos_boss_test' or 'enfos_creep' end
 function t:GetAbsOrigin()return self.pos end;function t:GetTeamNumber()return self.team end
 function t:IsMagicImmune()return self.magic end;function t:IsDebuffImmune()return self.debuff end;function t:IsBuilding()return self.building end
 function t:IsIllusion()return self.illusion end;function t:IsStrongIllusion()return self.strong end
 function t:Kill(ability,attacker)assert(ability and attacker.team==2);self.kills=(self.kills or 0)+1;self.killAbility=ability;self.health=0;if self.killHook then self.killHook()end end
 function t:TriggerSpellAbsorb()if absorbHook then absorbHook()end;return self.absorb end
 function t:EmitSound(s)assert(s=='Hero_Lion.Voodoo');if soundHook then soundHook()end end
 function t:AddNewModifier(c,a,n,p)
  assert(n=='modifier_enfos_lion_hex_debuff');local m=setmetatable({params=p},modifier_enfos_lion_hex_debuff)
  function m:GetParent()return t end;function m:GetAbility()return a end
  function m:SetHasCustomTransmitterData(enabled)assert(enabled);self.transmit=true end
  function m:SendBuffRefreshToClients()self.refreshes=(self.refreshes or 0)+1 end
  function m:AddParticle(id,immediate,status,priority,hero,overhead)
   assert(not immediate and not status and priority==-1 and not hero and not overhead);owned=owned+1;self.fx=id
  end
  function m:Destroy()self:OnDestroy();if self.fx then ParticleManager:DestroyParticle(self.fx,true);ParticleManager:ReleaseParticleIndex(self.fx);self.fx=nil end end
  t.mods[#t.mods+1]=m;m:OnCreated(p);return m
 end
 return t
end
local c=unit(2);local target=unit(3)
local a=setmetatable({values={duration=4.5,base_move_speed=140,boss_duration=.8}},enfos_lion_hex)
function a:IsNull()return self.removed end;function a:GetCaster()return c end;function a:GetCursorTarget()return target end
function a:GetSpecialValueFor(k)return self.values[k] or 0 end
a:OnSpellStart();local m=target.mods[1];assert(m and m.params.duration==4.5 and m.params.move_speed==140)
assert(m:GetModifierModelChange()=='models/props_gameplay/frog.vmdl' and m:GetModifierMoveSpeedOverride()==140)
local states=m:CheckState();for i=1,4 do assert(states[i])end;local count=0;for _ in pairs(states)do count=count+1 end;assert(count==4,'Hex cannot apply Break')
assert(m:IsDebuff() and not m:IsPurgable() and m:IsPurgeException() and m:GetTexture()=='lion_voodoo')
assert(m:DeclareFunctions()[2]==6 and owned==1 and binds[m.fx]==target)
a.values.base_move_speed=99;assert(m:GetModifierMoveSpeedOverride()==140,'Existing Hex speed is saved')
local before=created;m:OnRefresh({move_speed=155});assert(created==before and m.refreshes==1 and m:GetModifierMoveSpeedOverride()==155)
local client=setmetatable({GetParent=function()return target end},modifier_enfos_lion_hex_debuff)
server=false;client:OnCreated({});client:HandleCustomTransmitterData(m:AddCustomTransmitterData());assert(created==before and client:GetModifierMoveSpeedOverride()==155);server=true
local alive=target.IsAlive;target.IsAlive=nil;server=false
assert(client:GetModifierMoveSpeedOverride()==155 and client:GetModifierModelChange()=='models/props_gameplay/frog.vmdl')
server=true;target.IsAlive=alive
for _,flag in ipairs({'magic','debuff','removed'})do target[flag]=true;assert(next(m:CheckState())==nil and m:GetModifierModelChange()==nil and m:GetModifierMoveSpeedOverride()==nil);target[flag]=false end
a.removed=true;c.removed=true;assert(m:GetModifierModelChange() and m:GetModifierMoveSpeedOverride()==155,'Applied Hex does not dereference removed source');a.removed=false;c.removed=false
m:Destroy();m:Destroy();assert(destroyed[1] and released[1] and not m:GetModifierModelChange());client:OnDestroy();assert(not client:GetModifierMoveSpeedOverride())
target=unit(3);target.isBoss=true;a:OnSpellStart();assert(target.mods[1].params.duration==4.5,'Boss uses ordinary duration')
for _,mode in ipairs({'friendly','dead','removed','magic','debuff','building','absorb'})do
 target=unit(mode=='friendly' and 2 or 3);if mode=='dead' then target.health=0 elseif mode=='removed' then target.removed=true else target[mode]=true end
 local n=created;a:OnSpellStart();assert(created==n and #target.mods==0,mode)
end
target=unit(3);absorbHook=function()target.removed=true end;a:OnSpellStart();absorbHook=nil;assert(#target.mods==0)
target=unit(3);soundHook=function()a.removed=true end;a:OnSpellStart();soundHook=nil;assert(#target.mods==0);a.removed=false
for _,phase in ipairs({'create','bind'})do
 target=unit(3);local n=created;hook=function(which)if which==phase then target.removed=true;target.mods[1]:OnDestroy()end end
 a:OnSpellStart();hook=nil;assert(created==n+1 and destroyed[created] and released[created])
end
target=unit(3);local n=created;server=false;a:OnSpellStart();server=true;assert(created==n)
-- Native Hex destroys ordinary illusions; strong illusions retain normal control.
for _,strong in ipairs({false,true})do
 target=unit(3);target.illusion=true;target.strong=strong;local n=created;local owner=owned
 a:OnSpellStart()
 if strong then assert(target:IsAlive() and not target.kills and #target.mods==1,'Strong illusions must receive ordinary Hex')
 else assert(not target:IsAlive() and target.kills==1 and target.killAbility==a and #target.mods==0,'Ordinary illusions must be destroyed, not transformed')
  assert(created==n+1 and owned==owner and binds[created]==target and released[created] and not destroyed[created],'Finite burst must bind CP1 then release once') end
end
for _,duration in ipairs({${durations}})do for _,boss in ipairs({false,true})do
 for _,illusion in ipairs({'ordinary','strong','real'})do
  target=unit(3);target.boss=boss;target.illusion=illusion~='real';target.strong=illusion=='strong';a.values.duration=duration
  a:OnSpellStart()
  if illusion=='ordinary' then assert(target.kills==1 and #target.mods==0)
  else assert(not target.kills and #target.mods==1 and target.mods[1].params.duration==duration,'All ranks use ordinary duration, including Bosses and strong illusions');target.mods[1]:Destroy()end
 end
end end
a.values.duration=4.5
target=unit(3);target.health=1;a:OnSpellStart();assert(not target.kills and target:IsAlive(),'Low health is never an execute condition')
target=unit(3);target.illusion=true;a.values.duration=0;local n=created;a:OnSpellStart();assert(not target.kills and created==n);a.values.duration=4.5
for _,flag in ipairs({'magic','debuff','building','absorb','removed'})do
 target=unit(3);target.illusion=true;target[flag]=true;local n=created;a:OnSpellStart()
 assert(not target.kills and #target.mods==0 and created==n,'Illusion destruction respects '..flag)
end
for _,phase in ipairs({'create','bind'})do
 for _,loss in ipairs({'target removed','target allied','target immune','source removed','caster dead','becomes strong'})do
  target=unit(3);target.illusion=true;local n=created
  hook=function(p)if p==phase then
   if loss=='target removed' then target.removed=true elseif loss=='target allied' then target.team=2 elseif loss=='target immune' then target.debuff=true
   elseif loss=='source removed' then a.removed=true elseif loss=='caster dead' then c.health=0 else target.strong=true end
  end end
  a:OnSpellStart();hook=nil
  assert(created==n+1 and destroyed[created] and released[created] and not target.kills and #target.mods==0,phase..' '..loss)
  a.removed=false;c.health=100
 end
end
target=unit(3);target.illusion=true;target.killHook=function()target.removed=true;c.removed=true;a.removed=true end
a:OnSpellStart();assert(target.kills==1 and released[created]);c.removed=false;a.removed=false
target=unit(3);target.illusion=true;local n=created;server=false;a:OnSpellStart();server=true
assert(not target.kills and created==n,'Client cannot destroy illusions')
local trace=require('lib/hero_trace');local lines={};local oldPrint=print
print=function(line)lines[#lines+1]=line end;trace:SetEnabled(false)
target=unit(3);a:OnSpellStart();local off=target.mods[1];off:OnRefresh({move_speed=140});off:Destroy();assert(#lines==0)
trace:SetEnabled(true);target=unit(3);a:OnSpellStart();local on=target.mods[1];local n=created
for i=1,100 do on:GetModifierModelChange();on:GetModifierMoveSpeedOverride();on:CheckState()end
assert(created==n and #lines==2,'Getter polling must not create particles or emit traces')
on:OnRefresh({move_speed=140});on:Destroy();target=unit(3);target.illusion=true;a:OnSpellStart();trace:SetEnabled(false)
local text=table.concat(lines,'\\n');for _,event in ipairs({'cast','hex applied','hex refreshed','hex removed'})do assert(text:find('[LION_TRACE][W] '..event,1,true),event)end
assert(text:find('[LION_TRACE][W] ordinary illusion destroyed',1,true))
print=oldPrint
print('Lion Hex PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:lua,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.equal(r.stderr,'');assert.match(r.stdout,/Lion Hex PASS/);
 const kv=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities.enfos_lion_hex;
 assert.ok(!('boss_duration' in kv.AbilityValues));assert.equal(kv.SpellDispellableType,'SPELL_DISPELLABLE_YES_STRONG');
 assert.equal(kv.AbilityCastAnimation,'ACT_DOTA_CAST_ABILITY_2');assert.equal(kv.SpellImmunityType,'SPELL_IMMUNITY_ENEMIES_NO');
 assert.equal(kv.MaxLevel,'10');assert.equal(kv.AbilityValues.duration.split(' ').length,10);
 assert.match(fs.readFileSync('game/scripts/vscripts/addon_game_mode.lua','utf8'),/PrecacheResource\("model", "models\/props_gameplay\/frog.vmdl", context\)/);
});
