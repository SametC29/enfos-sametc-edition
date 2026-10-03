import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync,execFileSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';

test('Lion authored passive exposes live ten-rank values and suppresses invalid, unlearned, broken and illusion states',()=>{
 const kv=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities.enfos_lion_demon_soul;
 const baseline=process.env.LION_PASSIVE_BASELINE?execFileSync('git',['show','HEAD:game/scripts/vscripts/abilities/heroes/lion/d.lua'],{encoding:'utf8'}):null;
 const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end
local server=true;function IsServer()return server end;Convars={GetBool=function()return false end}
MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING=1;MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE=2;MODIFIER_PROPERTY_TOOLTIP=3;MODIFIER_PROPERTY_TOOLTIP2=4
${baseline?`assert(load([==[${baseline}]==]))()`:`require('abilities/heroes/lion/d')`}
local parent={dead=false,broken=false,illusion=false,removed=false}
function parent:IsNull()return self.removed end
function parent:PassivesDisabled()assert(not self.removed);return self.broken end
function parent:IsIllusion()assert(not self.removed);return self.illusion end
local ranges={${kv.AbilityValues.cast_range_bonus.split(/\s+/).join(',')}};local amps={${kv.AbilityValues.spell_amp.split(/\s+/).join(',')}}
local ability={rank=0};function ability:IsNull()return self.removed end;function ability:GetLevel()assert(not self.removed);return self.rank end
function ability:GetSpecialValueFor(k)assert(not self.removed);return (k=='cast_range_bonus' and ranges or amps)[math.max(1,self.rank)]end
local m=setmetatable({GetParent=function()return parent end,GetAbility=function()return ability end},modifier_enfos_lion_demon_soul_passive)
assert(m:GetModifierCastRangeBonusStacking()==0 and m:GetModifierSpellAmplify_Percentage()==0,'Rank0 cannot grant first-rank stats')
m:OnCreated();assert(not m:IsHidden() and not m:IsPurgable() and not m:IsPurgeException() and not m:RemoveOnDeath())
assert(m:GetTexture()=='lion_mana_drain' and #m:DeclareFunctions()==4)
for _,side in ipairs({true,false})do
 server=side
 for rank=1,10 do
  ability.rank=rank;m:OnRefresh()
  assert(m:GetModifierCastRangeBonusStacking()==ranges[rank] and m:OnTooltip()==ranges[rank])
  assert(m:GetModifierSpellAmplify_Percentage()==amps[rank] and m:OnTooltip2()==amps[rank])
 end
end
for _,flag in ipairs({'broken','illusion','removed'})do
 parent[flag]=true;assert(m:OnTooltip()==0 and m:OnTooltip2()==0);parent[flag]=false
end
ability.removed=true;assert(m:OnTooltip()==0 and m:OnTooltip2()==0);ability.removed=false
parent.dead=true;assert(m:OnTooltip()==600 and m:OnTooltip2()==20,'Numeric intrinsic persists on valid dead hero for respawn');parent.dead=false
m:OnDestroy();m:OnDestroy();assert(m:OnTooltip()==0 and m:OnTooltip2()==0)
local trace=require('lib/hero_trace');local lines={};local oldPrint=print;print=function(s)lines[#lines+1]=s end
server=true;trace:SetEnabled(false);m:OnCreated();m:OnRefresh();assert(#lines==0)
trace:SetEnabled(true);m:OnCreated();m:OnRefresh();local n=#lines
for i=1,100 do m:OnTooltip();m:OnTooltip2();m:GetModifierCastRangeBonusStacking();m:GetModifierSpellAmplify_Percentage()end
assert(#lines==n,'Passive getters cannot log or create global work');m:OnDestroy();m:OnDestroy()
local text=table.concat(lines,'\\n');for _,e in ipairs({'passive applied','passive refreshed','passive removed'})do assert(text:find('[LION_TRACE][D] '..e,1,true))end
trace:SetEnabled(false);print=oldPrint
print('Lion passive PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.equal(r.stderr,'');assert.match(r.stdout,/Lion passive PASS/);
 for(const lang of ['english','turkish','russian','schinese']){
  const t=JSON.parse(fs.readFileSync(`localization/${lang}.json`,'utf8')).Tokens;
  assert.ok(t.DOTA_Tooltip_modifier_enfos_lion_demon_soul_passive);
  const d=t.DOTA_Tooltip_modifier_enfos_lion_demon_soul_passive_Description;
  assert.ok(d.includes('MODIFIER_PROPERTY_TOOLTIP%')&&d.includes('MODIFIER_PROPERTY_TOOLTIP2%'));
 }
});
