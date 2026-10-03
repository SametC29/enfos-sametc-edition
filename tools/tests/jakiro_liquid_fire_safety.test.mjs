import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
test('Jakiro E spends ordinary mana once, rejects invalid owners and survives reentrant callbacks',()=>{
 const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
function LinkLuaModifier()end
local server=true;function IsServer()return server end
DAMAGE_TYPE_MAGICAL=2;DOTA_UNIT_TARGET_TEAM_ENEMY=3;DOTA_UNIT_TARGET_HERO=1;DOTA_UNIT_TARGET_BASIC=2;DOTA_UNIT_TARGET_BUILDING=4;DOTA_UNIT_TARGET_FLAG_NONE=0;FIND_ANY_ORDER=0;PATTACH_ABSORIGIN_FOLLOW=0
MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT=1;MODIFIER_PROPERTY_TOOLTIP=2;MODIFIER_EVENT_ON_ATTACK_LANDED=3
Convars={GetBool=function()return false end}
require('abilities/heroes/jakiro/e')
for _,mode in ipairs({'normal','poor','cooldown','client','nil_event','removed_caster','removed_ability','removed_target','break','illusion','unlearned','autocast_off','corpse','resource_removes_ability','modifier_removes_ability','absorb_removes_caster','manual'})do
 local c,a,target,normal,boss,modifier
 local spend,hits,mods=0,{},{}
 local function unit(name,team)
  local u={name=name,team=team,removed=false,alive=true}
  function u:IsNull()return self.removed end
  function u:IsAlive()assert(not self.removed);return self.alive end
  function u:GetUnitName()return self.name end
  function u:GetTeamNumber()assert(not self.removed,'stale team');return self.team end
  function u:GetAbsOrigin()assert(not self.removed);return {x=20,y=0,z=0}end
  function u:EmitSound()assert(not self.removed)end
  function u:PassivesDisabled()assert(not self.removed);return mode=='break' end
  function u:IsIllusion()assert(not self.removed);return mode=='illusion' end
  function u:GetIntellect()assert(not self.removed);return 100 end
  function u:TriggerSpellAbsorb()if mode=='absorb_removes_caster' then c.removed=true end;return false end
  function u:AddNewModifier(caster,ability,name,p)assert(not self.removed and not caster.removed and not ability.removed);mods[#mods+1]=p;if mode=='modifier_removes_ability' then a.removed=true end end
  return u
 end
 c=unit('jakiro',2);target=unit('target',3);normal=unit('normal',3);boss=unit('enfos_boss_test',3);boss.isBoss=true
 a=setmetatable({removed=false,ready=mode~='cooldown',mana=mode=='poor' and 0 or 40},enfos_jakiro_liquid_fire)
 function a:IsNull()return self.removed end
 function a:GetCaster()assert(not self.removed);return c end
 function a:GetCursorTarget()return target end
 function a:GetLevel()assert(not self.removed);return mode=='unlearned' and 0 or 1 end
 function a:GetAutoCastState()assert(not self.removed);return mode~='autocast_off' end
 function a:IsCooldownReady()return self.ready end
 function a:IsFullyCastable()return self.ready and self.mana>=20 end
 function a:GetSpecialValueFor(k)assert(not self.removed);return ({bonus_damage=90,slow_as=60,radius=300})[k] or 0 end
 function a:UseResources(mana,health,gold,cd)
  assert(mana and not health and not gold and cd,'Autocast must spend mana and cooldown exactly once')
  spend=spend+1;self.mana=self.mana-20;self.ready=false
  modifier:OnAttackLanded({attacker=c,target=target})
  if mode=='resource_removes_ability' then self.removed=true end
 end
 modifier=setmetatable({GetParent=function()return c end,GetAbility=function()return a end},modifier_enfos_jakiro_liquid_fire_passive)
 ParticleManager={CreateParticle=function()return 1 end,ReleaseParticleIndex=function()end}
 function FindUnitsInRadius()return {normal,boss}end
 function ApplyDamage(info)hits[#hits+1]=info;return info.damage end
 server=mode~='client'
 if mode=='removed_caster' then c.removed=true elseif mode=='removed_ability' then a.removed=true elseif mode=='removed_target' then target.removed=true elseif mode=='corpse' then target.alive=false end
 if mode=='manual' or mode=='absorb_removes_caster' then a:OnSpellStart()else local event={attacker=c,target=target};if mode=='nil_event' then event=nil end;modifier:OnAttackLanded(event)end
 if mode=='normal' or mode=='corpse' then assert(spend==1 and #hits==0 and #mods==2);assert(mods[1].dps==24 and mods[2].dps==24 and mods[1].duration==5);assert(mods[1].slow_as==60)
 elseif mode=='manual' then assert(spend==0 and #hits==0 and #mods==2)
 elseif mode=='resource_removes_ability' then assert(spend==1 and #hits==0)
 elseif mode=='modifier_removes_ability' then assert(spend==1 and #hits==0 and #mods==1)
 else assert(spend==0 and #hits==0,'Rejected path spent or applied effects: '..mode)end
end
print('Jakiro E resource/callback safety PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.match(r.stdout,/Jakiro E resource.*PASS/,r.stderr);
});

test('Jakiro E slow preserves each hit snapshot and transmits it without reading a removed ability',()=>{
 const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
function LinkLuaModifier()end
local server=true;function IsServer()return server end
MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT=1;MODIFIER_PROPERTY_TOOLTIP=2
Convars={GetBool=function()return false end}
require('abilities/heroes/jakiro/e')
local removed,slow=false,30
local a={IsNull=function()return removed end,GetSpecialValueFor=function()assert(not removed);return slow end}
local parent={immune=false,IsAlive=function()return true end,GetUnitName=function()return 'target' end,IsMagicImmune=function(self)return self.immune end}
local sends=0
local function mod()return setmetatable({GetElapsedTime=function()return 0 end,StartIntervalThink=function()end,GetCaster=function()return {} end,GetParent=function()return parent end,GetAbility=function()return a end,
 SetHasCustomTransmitterData=function()end,SendBuffRefreshToClients=function()sends=sends+1 end},modifier_enfos_jakiro_liquid_fire_slow)end
local m=mod();m:OnCreated({slow_as=30});slow=75
assert(m:GetModifierAttackSpeedBonus_Constant()==-30 and m:OnTooltip()==30)
local client=mod();server=false;client:HandleCustomTransmitterData(m:AddCustomTransmitterData())
client:OnCreated({slow_as=999});assert(client:GetModifierAttackSpeedBonus_Constant()==-30)
server=true;m:OnRefresh({slow_as=75});assert(sends==1 and m:OnTooltip()==75)
removed=true;assert(m:GetModifierAttackSpeedBonus_Constant()==-75)
parent.immune=true;assert(m:GetModifierAttackSpeedBonus_Constant()==0)
assert(m:IsPurgable() and m:GetTexture()=='jakiro_liquid_fire')
print('Jakiro E slow snapshot PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.match(r.stdout,/Jakiro E slow snapshot PASS/,r.stderr);
});
