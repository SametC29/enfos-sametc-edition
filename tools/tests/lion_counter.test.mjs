import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync,execFileSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';

test('Lion Finger counter gates learned source and exposes bounded live bonuses without getter side effects',()=>{
 const v=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities.enfos_lion_finger_of_death.AbilityValues;
 const baseline=process.env.LION_COUNTER_BASELINE?execFileSync('git',['show','HEAD:game/scripts/vscripts/abilities/heroes/lion/r.lua'],{encoding:'utf8'}):null;
 const lua=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end
local server=true;function IsServer()return server end;Convars={GetBool=function()return false end}
MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE=1;MODIFIER_PROPERTY_TOOLTIP=2;MODIFIER_PROPERTY_TOOLTIP2=3;MODIFIER_EVENT_ON_DEATH=220
${baseline?`assert(load([==[${baseline}]==]))()`:`require('abilities/heroes/lion/r')`}
local c={};function c:IsNull()return self.removed end
local a={rank=0};function a:IsNull()return self.removed end
function a:GetLevel()assert(not self.removed);return self.rank end
local values={kill_stack_cap=${v.kill_stack_cap},kill_stack_damage=${v.kill_stack_damage},kill_stack_spell_amp_pct=${v.kill_stack_spell_amp_pct}}
function a:GetSpecialValueFor(k)assert(not self.removed);return values[k]end
local m=setmetatable({stacks=3,GetParent=function()return c end,GetAbility=function()return a end},modifier_enfos_lion_finger_counter)
function m:GetStackCount()assert(not self.removed);return self.stacks end
function m:IsNull()return self.removed end
assert(m:GetModifierSpellAmplify_Percentage()==0,'Unlearned R cannot grant accumulated spell amplification')
m:OnCreated();assert(m:GetTexture()=='lion_finger_of_death' and not m:IsHidden())
local properties=m:DeclareFunctions();assert(#properties==4 and properties[2]==2 and properties[3]==3 and properties[4]==220)
for _,side in ipairs({true,false})do
 server=side
 for rank=1,10 do
  a.rank=rank
  for _,stacks in ipairs({-3,0,1,3,19,20,25})do
   m.stacks=stacks;m:OnRefresh();local n=math.min(20,math.max(0,stacks))
   assert(m:OnTooltip()==n*40 and m:OnTooltip2()==n*1.5 and m:GetModifierSpellAmplify_Percentage()==n*1.5)
   assert(m.stacks==stacks,'Readonly presentation cannot reset or grant stacks')
  end
 end
end
c.removed=true;assert(m:OnTooltip()==0 and m:OnTooltip2()==0);c.removed=false
a.removed=true;assert(m:OnTooltip()==0 and m:OnTooltip2()==0);a.removed=false
m.removed=true;assert(m:OnTooltip()==0 and m:OnTooltip2()==0);m.removed=false
a.rank=0;assert(m:OnTooltip()==0 and m:OnTooltip2()==0);a.rank=10
m:OnDestroy();m:OnDestroy();assert(m:OnTooltip()==0 and m:OnTooltip2()==0)
local trace=require('lib/hero_trace');local lines={};local oldPrint=print;print=function(s)lines[#lines+1]=s end
server=true;trace:SetEnabled(false);m:OnCreated();m:OnRefresh();assert(#lines==0)
trace:SetEnabled(true);m:OnCreated();m:OnRefresh();local count=#lines
for i=1,100 do m:OnTooltip();m:OnTooltip2();m:GetModifierSpellAmplify_Percentage()end
assert(#lines==count,'Getters cannot emit diagnostics');m:OnDestroy();m:OnDestroy();assert(#lines==count+1)
assert(table.concat(lines,'\\n'):find('[LION_TRACE][R] counter removed',1,true))
trace:SetEnabled(false);print=oldPrint;print('Lion counter PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:lua,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.equal(r.stderr,'');assert.match(r.stdout,/Lion counter PASS/);
 for(const lang of ['english','turkish','russian','schinese']){
  const t=JSON.parse(fs.readFileSync(`localization/${lang}.json`,'utf8')).Tokens;
  assert.ok(t.DOTA_Tooltip_modifier_enfos_lion_finger_counter);
  const d=t.DOTA_Tooltip_modifier_enfos_lion_finger_counter_Description;
  assert.ok(d.includes('MODIFIER_PROPERTY_TOOLTIP%')&&d.includes('MODIFIER_PROPERTY_TOOLTIP2%'));
 }
});
