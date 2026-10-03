import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync,execFileSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';

test('Lion Drain slow is nondispellable and exposes guarded live values on both sides',()=>{
 const kv=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities.enfos_lion_mana_drain;
 const baseline=process.env.LION_SLOW_BASELINE?execFileSync('git',['show','HEAD:game/scripts/vscripts/abilities/heroes/lion/e.lua'],{encoding:'utf8'}):null;
 const lua=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end
local server=true;function IsServer()return server end;Convars={GetBool=function()return false end}
MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE=1
${baseline?`assert(load([==[${baseline}]==]))()`:`require('abilities/heroes/lion/e')`}
local function unit(team)
 local u={team=team,alive=true,maxMana=100,mana=10}
 function u:IsNull()return self.removed end;function u:IsAlive()assert(not self.removed);return self.alive end
 function u:GetTeamNumber()assert(not self.removed);return self.team end
 function u:IsMagicImmune()return self.magic end;function u:IsDebuffImmune()return self.debuff end;function u:IsBuilding()return self.building end
 function u:GetMaxMana()assert(not self.removed);return self.maxMana end
 function u:GetMana()assert(not self.removed);return self.mana end
 return u
end
local c,t=unit(2),unit(3);local a={rank=0,value=${kv.AbilityValues.slow_pct}}
function a:GetCaster()return self.foreign or c end
function a:IsNull()return self.removed end;function a:GetLevel()assert(not self.removed);return self.rank end
function a:GetSpecialValueFor(k)assert(not self.removed);if k=='slow_pct' then return self.value end;assert(k=='movespeed_bonus_when_empty_pct');return ${kv.AbilityValues.movespeed_bonus_when_empty_pct} end
local m=setmetatable({GetParent=function()return t end,GetCaster=function()return c end,GetAbility=function()return a end},modifier_enfos_lion_mana_drain_debuff)
function m:IsNull()return self.removed end
assert(m:GetModifierMoveSpeedBonus_Percentage()==0,'Rank0 cannot slow a recipient')
a.rank=1;a.foreign=unit(2);assert(m:GetModifierMoveSpeedBonus_Percentage()==0,'Borrowed ability cannot slow a recipient');a.foreign=nil;a.rank=0
m:OnCreated();assert(m:IsDebuff() and not m:IsHidden() and not m:IsPurgable() and not m:IsPurgeException() and m:GetTexture()=='lion_mana_drain')
for _,side in ipairs({true,false})do
 server=side
 for rank=1,10 do
  a.rank=rank;m:OnRefresh()
  t.maxMana=100;t.mana=10;assert(m:GetModifierMoveSpeedBonus_Percentage()==-35)
  t.mana=0;assert(m:GetModifierMoveSpeedBonus_Percentage()==-50,'Depleted mana-bearing targets gain the native extra slow')
  t.mana=1;assert(m:GetModifierMoveSpeedBonus_Percentage()==-35,'Mana recovery immediately releases the extra slow')
  t.maxMana=0;t.mana=0;assert(m:GetModifierMoveSpeedBonus_Percentage()==-35,'Mana-less conversion targets retain base slow')
  t.maxMana=100;t.mana=10
 end
 a.value=42;m:OnRefresh();assert(m:GetModifierMoveSpeedBonus_Percentage()==-42,'Reads current special, not cached constant');a.value=35
end
for _,mode in ipairs({'friendly','dead target','dead caster','removed target','removed caster','ability','modifier','magic','debuff','building'})do
 if mode=='friendly' then t.team=2 elseif mode=='dead target' then t.alive=false elseif mode=='dead caster' then c.alive=false
 elseif mode=='removed target' then t.removed=true elseif mode=='removed caster' then c.removed=true
 elseif mode=='ability' then a.removed=true elseif mode=='modifier' then m.removed=true else t[mode]=true end
 assert(m:GetModifierMoveSpeedBonus_Percentage()==0,mode)
 t.team=3;t.alive=true;c.alive=true;t.removed=false;c.removed=false;a.removed=false;m.removed=false;t.magic=false;t.debuff=false;t.building=false
end
m:OnDestroy();m:OnDestroy();assert(m:GetModifierMoveSpeedBonus_Percentage()==0)
local trace=require('lib/hero_trace');local lines={};local oldPrint=print;print=function(s)lines[#lines+1]=s end
server=true;trace:SetEnabled(false);m:OnCreated();m:OnRefresh();assert(#lines==0)
trace:SetEnabled(true);m:OnCreated();m:OnRefresh();local n=#lines
for i=1,100 do m:GetModifierMoveSpeedBonus_Percentage()end;assert(#lines==n);m:OnDestroy();m:OnDestroy();assert(#lines==n+1)
assert(table.concat(lines,'\\n'):find('[LION_TRACE][E] slow removed',1,true));trace:SetEnabled(false);print=oldPrint
print('Lion slow PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:lua,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.equal(r.stderr,'');assert.match(r.stdout,/Lion slow PASS/);
 assert.equal(kv.SpellDispellableType,'SPELL_DISPELLABLE_NO');
 for(const lang of ['english','turkish','russian','schinese']){
  const t=JSON.parse(fs.readFileSync(`localization/${lang}.json`,'utf8')).Tokens;
  assert.ok(t.DOTA_Tooltip_modifier_enfos_lion_mana_drain_debuff);
  assert.ok(t.DOTA_Tooltip_modifier_enfos_lion_mana_drain_debuff_Description.includes('MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE%'));
 }
});
