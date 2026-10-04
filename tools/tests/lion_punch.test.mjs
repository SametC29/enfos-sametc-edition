import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync,execFileSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';
const kv=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities.enfos_lion_finger_of_death;
function run(lua){
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:lua,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.equal(r.stderr,'');assert.match(r.stdout,/Lion punch PASS/);
}
const boot=`package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end
local server=true;function IsServer()return server end;Convars={GetBool=function()return false end}
DOTA_UNIT_TARGET_TEAM_ENEMY=1;DOTA_UNIT_TARGET_HERO=2;DOTA_UNIT_TARGET_BASIC=4;DOTA_UNIT_TARGET_FLAG_NONE=0;FIND_ANY_ORDER=0
`;
const specials=Object.entries(kv.AbilityValues).map(([k,v])=>`${k}={${v.split(/\s+/).join(',')}}`).join(',');

test('Lion Finger snapshots initial AltCast choice before callbacks and passes the cast Scepter snapshot',()=>{
 const baseline=process.env.LION_PUNCH_BASELINE?execFileSync('git',['show','HEAD:game/scripts/vscripts/abilities/heroes/lion/r.lua'],{encoding:'utf8'}):null;
 run(boot+`
local grants,modifiers={},{};local Punch=require('abilities/heroes/lion/r_punch');local realGrant=Punch.Grant
Punch.Grant=function(a,c,upgraded,alt)grants[#grants+1]={a,c,upgraded,alt};return realGrant(a,c,upgraded,alt)end
${baseline?`assert(load([==[${baseline}]==]))()`:`require('abilities/heroes/lion/r')`}
local c={scepter=false};local t={team=3};local a=setmetatable({rank=1,alt=false},enfos_lion_finger_of_death)
function c:IsNull()return false end;function c:IsAlive()return true end;function c:GetTeamNumber()return 2 end
function c:GetAbsOrigin()return {x=0,y=0,z=0}end;function c:GetIntellect()return 100 end
function c:HasScepter()return self.scepter end;function c:FindModifierByName()return nil end
function c:IsIllusion()return false end
function c:AddNewModifier(_,ability,name,kv)assert(ability==a and name=='modifier_enfos_lion_finger_punch');modifiers[#modifiers+1]=kv end
local hook;function c:EmitSound()if hook then hook()end end
function t:IsNull()return self.removed end;function t:IsAlive()return true end;function t:GetTeamNumber()return self.team end
function t:GetAbsOrigin()return {x=100,y=0,z=0}end;function t:TriggerSpellAbsorb()return self.absorb end
function a:IsNull()return false end;function a:GetCaster()return c end;function a:GetCursorTarget()return t end;function a:GetLevel()return self.rank end
local reads=0;function a:ShouldAltCast()reads=reads+1;return self.alt end
function a:GetAltCastState()error('Mutable toggle must not be used')end
local values={${specials}};function a:GetSpecialValueFor(k)local v=values[k];return v and (v[self.rank] or v[1]) or 0 end
ParticleManager={CreateParticle=function()return 1 end,SetParticleControlEnt=function()end,DestroyParticle=function()end,ReleaseParticleIndex=function()end}
GameRules={GetGameModeEntity=function()return {SetContextThink=function()end}end};function DoUniqueString()return 'impact'end
function FindUnitsInRadius()return {}end
for _,upgraded in ipairs({false,true})do
 for _,initial in ipairs({false,true})do
  c.scepter=upgraded;a.alt=initial;local n=#grants;local buffs=#modifiers
  hook=function()a.alt=not initial;c.scepter=not upgraded end
  a:OnSpellStart();assert(#grants==n+1,'R must route successful casts to punch ownership')
  assert(grants[#grants][3]==upgraded and grants[#grants][4]==initial,'Grant must retain both initial cast snapshots')
  assert(#modifiers==buffs+(initial and 0 or 1),'Actual grant must respect initial AltCast')
  if not initial then assert(modifiers[#modifiers].duration==(upgraded and 30 or 20) and modifiers[#modifiers].cleave_pct==(upgraded and 50 or 25))end
 end
end
assert(reads==4)
t.absorb=true;local n=#grants;a:OnSpellStart();assert(#grants==n,'Absorbed Finger cannot empower')
server=false;a:OnSpellStart();assert(#grants==n,'Client cannot grant')
print('Lion punch PASS')
`);
});

test('Lion punch owns reversible melee state, rank/stack damage, native geometry, client transmission and finite resources',()=>{
 assert.match(kv.AbilityBehavior,/ALT_CASTABLE/);
 assert.equal(kv.AbilityValues.punch_bonus_damage,'20 25 30 35 40 45 50 55 60 65');
 run(boot+`
local props={'ATTACK_RANGE_BASE_OVERRIDE','PREATTACK_BONUS_DAMAGE','MOVESPEED_BONUS_CONSTANT','TRANSLATE_ACTIVITY_MODIFIERS','TRANSLATE_ATTACK_SOUND','TOOLTIP','TOOLTIP2'}
for i,p in ipairs(props)do _G['MODIFIER_PROPERTY_'..p]=i end
MODIFIER_EVENT_ON_ATTACK_START=20;MODIFIER_EVENT_ON_ATTACK_LANDED=21;MODIFIER_STATE_ATTACKS_ARE_MELEE=59;PATTACH_POINT_FOLLOW=4
local Punch=require('abilities/heroes/lion/r_punch')
require('abilities/heroes/lion/r')
local c={team=2,alive=true};local a=setmetatable({rank=1},enfos_lion_finger_of_death);local m,counter,created,released,destroyed,refreshes= nil,nil,0,0,0,0
local hook;local attachments={};local sounds={};local cleaves={};local additions={}
function c:IsNull()return self.removed end;function c:IsAlive()return self.alive end;function c:IsIllusion()return self.illusion end
function c:GetTeamNumber()return self.team end;function c:GetAbsOrigin()return {x=0,y=0,z=0}end
function c:SetAttackCapability()error('No irreversible capability write')end
function c:EmitSound(s)sounds[#sounds+1]=s end
function c:FindModifierByName(name)
 assert(server,'Client must not call server-only modifier lookup')
 return name=='modifier_enfos_lion_finger_counter' and counter or name=='modifier_enfos_lion_finger_punch' and m or nil
end
function c:AddNewModifier(caster,ability,name,kv)
 assert(caster==c and ability==a and name=='modifier_enfos_lion_finger_punch')
 additions[#additions+1]=kv;return m
end
function a:IsNull()return self.removed end;function a:GetCaster()return self.foreign or c end;function a:GetLevel()return self.rank end
local values={${specials}};function a:GetSpecialValueFor(k)local v=values[k];return v and (v[self.rank] or v[1]) or 0 end
ParticleManager={CreateParticle=function(_,path,attach,owner)
 assert(path=='particles/units/heroes/hero_lion/lion_fistofdeath_buff.vpcf' and attach==4 and owner==c);created=created+1;if hook then hook('create')end;return created end,
 SetParticleControlEnt=function(_,fx,cp,unit,attach,name)
  assert(cp==0 and unit==c and attach==4 and name=='attach_palm_l');attachments[fx]=true;if hook then hook('bind')end end,
 DestroyParticle=function()destroyed=destroyed+1 end,ReleaseParticleIndex=function()released=released+1 end}
function DoCleaveAttack(attacker,target,ability,damage,startWidth,endWidth,distance,effect)
 assert(attacker==c and ability==a and startWidth==150 and endWidth==350 and distance==650)
 assert(effect=='particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf')
 cleaves[#cleaves+1]=damage
 m:OnAttackLanded({attacker=c,target=target,damage=100}) -- No recursive cleave.
end
local function make()
 local n=setmetatable({},modifier_enfos_lion_finger_punch)
 function n:IsNull()return self.removed end;function n:GetParent()return self.parent or c end;function n:GetAbility()return self.ability or a end
 function n:SetHasCustomTransmitterData(v)assert(v)end;function n:SendBuffRefreshToClients()refreshes=refreshes+1 end
 return n
end
counter=setmetatable({stacks=0},modifier_enfos_lion_finger_counter);function counter:IsNull()return self.removed end
function counter:GetParent()return self.parent or c end;function counter:GetAbility()return self.ability or a end;function counter:GetStackCount()return self.stacks end
for rank=1,10 do
 a.rank=rank
 for _,upgraded in ipairs({false,true})do
  Punch.Grant(a,c,upgraded,false);local kv=additions[#additions]
  assert(kv.duration==(upgraded and 30 or 20) and kv.cleave_pct==(upgraded and 50 or 25))
  m=make();m:OnCreated(kv)
  assert(not m:IsHidden() and not m:IsPurgable() and m:RemoveOnDeath() and m:GetTexture()=='lion_finger_of_death')
  assert(#m:DeclareFunctions()==9 and m:CheckState()[59] and m:GetModifierAttackRangeOverride()==250 and m:GetModifierMoveSpeedBonus_Constant()==30)
  assert(m:GetActivityTranslationModifiers()=='melee' and m:GetAttackSound()=='Hero_Lion.Punch.Attack')
  for _,stacks in ipairs({-1,0,3,20,25})do
   counter.stacks=stacks;counter:OnStackCountChanged()
   local expected=20+(rank-1)*5+math.min(20,math.max(0,stacks))*40
   assert(m:GetModifierPreAttack_BonusDamage()==expected and m:OnTooltip()==expected)
   local payload=m:AddCustomTransmitterData();local client=make();client:HandleCustomTransmitterData(payload)
   local alive=c.IsAlive;c.IsAlive=nil;server=false
   assert(client:GetModifierPreAttack_BonusDamage()==expected and client:OnTooltip2()==kv.cleave_pct)
   server=true;c.IsAlive=alive
  end
  c.breaking=true;assert(m:CheckState()[59],'Active empowerment is not a breakable passive');c.breaking=false
  counter.ability={};assert(m:GetModifierPreAttack_BonusDamage()==20+(rank-1)*5);counter.ability=nil
  counter:OnDestroy();assert(m.stack_bonus==0,'Counter teardown must publish zero stack damage to the client');counter.closed=false
  local before=created;m:OnRefresh({cleave_pct=25});assert(created==before and m:OnTooltip2()==25,'Refresh must reuse one hand effect')
  m:OnAttackStart({attacker=c});assert(sounds[#sounds]=='Hero_Lion.Punch.PreAttack')
  local target={team=3};function target:IsNull()return self.removed end;function target:GetTeamNumber()return self.team end;function target:IsBuilding()return self.building end
  for _,boss in ipairs({false,true})do
   target.boss=boss;local n=#cleaves;m:OnAttackLanded({attacker=c,target=target,damage=200});assert(#cleaves==n+1 and cleaves[#cleaves]==50)
  end
  local n=#cleaves
  for _,mode in ipairs({'friendly','building','removed','other','zero','client'})do
   target.team=mode=='friendly' and 2 or 3;target.building=mode=='building';target.removed=mode=='removed';server=mode~='client'
   m:OnAttackLanded({attacker=mode=='other' and {} or c,target=target,damage=mode=='zero' and 0 or 200})
   assert(#cleaves==n,mode)
  end
  server=true
  for _,mode in ipairs({'dead','illusion','rank0','foreign','closed','removed'})do
   c.alive=mode~='dead';c.illusion=mode=='illusion';a.rank=mode=='rank0' and 0 or rank;a.foreign=mode=='foreign' and {} or nil;m.closed=mode=='closed';m.removed=mode=='removed'
   assert(not m:CheckState()[59] and m:GetModifierAttackRangeOverride()==nil and m:GetModifierPreAttack_BonusDamage()==0 and m:GetAttackSound()==nil,mode)
  end
  c.alive=true;c.illusion=false;a.rank=rank;a.foreign=nil;m.closed=false;m.removed=false
  local d=destroyed;m:OnDestroy();m:OnDestroy();assert(destroyed==d+1 and not m:CheckState()[59] and m:GetModifierAttackRangeOverride()==nil)
 end
end
local count=#additions;Punch.Grant(a,c,false,true);assert(#additions==count,'AltCast cannot grant')
for _,mode in ipairs({'dead','illusion','rank0','foreign','removed_caster','removed_ability','client'})do
 c.alive=mode~='dead';c.illusion=mode=='illusion';a.rank=mode=='rank0' and 0 or 10;a.foreign=mode=='foreign' and {} or nil
 c.removed=mode=='removed_caster';a.removed=mode=='removed_ability';server=mode~='client'
 Punch.Grant(a,c,true,false);assert(#additions==count,'No unauthorized grant: '..mode)
end
c.alive=true;c.illusion=false;c.removed=false;a.rank=10;a.foreign=nil;a.removed=false;server=true
for _,phase in ipairs({'create','bind'})do
 m=make();local d=destroyed;hook=function(p)if p==phase then m:OnDestroy()end end
 m:OnCreated({cleave_pct=25});hook=nil;assert(destroyed==d+1 and m.punch_fx==nil,'Reentrant teardown owns local resource exactly once')
end
assert(created==destroyed and released==destroyed and refreshes>0)
print('Lion punch PASS')
`);
});

test('Lion punch resources and four-language player descriptions are registered',()=>{
 const precache=fs.readFileSync('game/scripts/vscripts/addon_game_mode.lua','utf8');
 for(const name of ['lion_fistofdeath_buff','lion_fistofdeath_buff_wisps_trail','lion_fistofdeath_buff_wisps_trail_rope','lion_base_attack_melee_blur','lion_base_attack_melee_backhand_blur']){
  assert.ok(precache.includes(`particles/units/heroes/hero_lion/${name}.vpcf`));
 }
 assert.ok(precache.includes('particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf'));
 for(const lang of ['english','turkish','russian','schinese']){
  const tokens=JSON.parse(fs.readFileSync(`localization/${lang}.json`,'utf8')).Tokens;
  const desc=tokens.DOTA_Tooltip_Ability_enfos_lion_finger_of_death_Description;
  for(const key of ['punch_duration','punch_attack_range','punch_bonus_movespeed','punch_bonus_damage','punch_cleave_pct','punch_cleave_distance','punch_scepter_duration_bonus','punch_scepter_cleave_bonus'])assert.ok(desc.includes(`{{${key}}}`),lang+'/'+key);
  const buff=tokens.DOTA_Tooltip_modifier_enfos_lion_finger_punch_Description;
  assert.ok(buff.includes('%dMODIFIER_PROPERTY_TOOLTIP%')&&buff.includes('%dMODIFIER_PROPERTY_TOOLTIP2%'));
  for(const folder of ['content/panorama/localization','game/panorama/localization','game/resource']){
   const mirror=fs.readFileSync(`${folder}/addon_${lang}.txt`,'utf8');assert.ok(mirror.includes('DOTA_Tooltip_modifier_enfos_lion_finger_punch'));
  }
 }
});
