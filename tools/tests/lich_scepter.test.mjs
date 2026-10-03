import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import fs from 'node:fs';
import {parseKV} from '../lib/kv.mjs';

test('Lich unique Scepter flags and four-language tooltips follow the upgraded slot',()=>{
  const kv=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
  assert.equal(kv.enfos_lich_sinister_gaze.HasScepterUpgrade,'1');
  assert.equal(Number(kv.enfos_lich_sinister_gaze.AbilityValues.aoe_scepter.value),400);
  assert.equal(kv.enfos_lich_sinister_gaze.AbilityValues.aoe_scepter.affected_by_aoe_increase,'1','Preserve native area-increase metadata');
  assert.equal(kv.enfos_lich_chain_frost.HasScepterUpgrade,undefined);
  for(const lang of ['english','turkish','russian','schinese']){
    const t=JSON.parse(fs.readFileSync(`localization/${lang}.json`,'utf8')).Tokens;
    assert.ok(t.DOTA_Tooltip_Ability_enfos_lich_sinister_gaze_scepter_description?.includes('%aoe_scepter%'),lang+': engine-native live upgrade radius');
    assert.equal(t.DOTA_Tooltip_Ability_enfos_lich_chain_frost_scepter_description,undefined,lang+': no stale generic R upgrade');
  }
});

test('Lich Scepter area control owns all recipients and leaves ordinary casts intact',()=>{
  const durations=String(parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities.enfos_lich_sinister_gaze.AbilityValues.duration).split(/\s+/).map(Number);
  const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t) t.__index=t;return t end
function LinkLuaModifier() end
function IsServer() return true end
DOTA_ABILITY_BEHAVIOR_UNIT_TARGET=8;DOTA_ABILITY_BEHAVIOR_POINT=16
DOTA_ABILITY_BEHAVIOR_AOE=32;DOTA_ABILITY_BEHAVIOR_CHANNELLED=128
DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL=4194304
DOTA_UNIT_TARGET_TEAM_ENEMY=3;DOTA_UNIT_TARGET_HERO=1;DOTA_UNIT_TARGET_BASIC=2
DOTA_UNIT_TARGET_FLAG_NONE=0;FIND_ANY_ORDER=0;DOTA_ABILITY_TYPE_ULTIMATE=1
require('abilities/heroes/lich/init')
local scepter,alive,blessing,ended=false,true,false,0
local rankedDuration=3.8
local caster={IsNull=function() return false end,IsAlive=function() return alive end,
  HasScepter=function() return scepter end,HasModifier=function(_,id)
    return blessing and id=='modifier_item_ascended_aghanims_blessing_consumed' end,
  GetTeamNumber=function() return 2 end,EmitSound=function(self) self.sounds=(self.sounds or 0)+1 end,
  GetUnitName=function() return 'npc_dota_hero_lich' end}
local a=setmetatable({GetCaster=function() return caster end,IsNull=function() return false end,
  GetCursorPosition=function() return {x=400,y=100,z=0} end,
  GetSpecialValueFor=function(_,key) return key=='duration' and rankedDuration or key=='aoe_scepter' and 400 or 0 end},enfos_lich_sinister_gaze)
caster.GetCurrentActiveAbility=function() return a end
caster.FindAbilityByName=function(_,id) return id=='enfos_lich_sinister_gaze' and a end
function a:EndChannel(interrupted) assert(interrupted);ended=ended+1;self:OnChannelFinish(interrupted) end
local function unit(team,boss,live,fail)
 local u={controls={},isBoss=boss,GetTeamNumber=function() return team end,
   IsNull=function() return false end,IsAlive=function() return live end}
 function u:AddNewModifier(c,ab,id,kv)
   assert(c==caster and ab==a and id=='modifier_enfos_lich_sinister_gaze_debuff')
   assert(kv.duration==rankedDuration,'Boss and normal area targets get the same ordinary ranked duration')
   if fail then return nil end
   local m=setmetatable({GetCaster=function() return c end,GetAbility=function() return ab end,
     GetParent=function() return self end,StartIntervalThink=function(self,n) self.interval=n end,
     Destroy=function(self) self:OnDestroy() end},modifier_enfos_lich_sinister_gaze_debuff)
   self.controls[#self.controls+1]=m;m:OnCreated(kv);assert(m.interval==0.5)
   return m
 end
 function u:RemoveModifierByNameAndCaster(id,c)
   assert(c==caster and id=='modifier_enfos_lich_sinister_gaze_debuff')
   self.removals=(self.removals or 0)+1
   for _,m in ipairs(self.controls) do m:OnDestroy() end
   self.controls={}
 end
 return u
end
local normal,boss,ally,dead=unit(3,false,true),unit(3,true,true),unit(2,false,true),unit(3,false,false)
local units={normal,boss,ally,dead,boss};local searches=0
function FindUnitsInRadius(team,pos,_,radius)
 searches=searches+1;assert(team==2 and pos.x==400 and radius==400);return units
end
local casts={}
for _,cls in ipairs({enfos_lich_frost_blast,enfos_lich_frost_shield,enfos_lich_chain_frost}) do
 casts[#casts+1]=setmetatable({GetCaster=function() return caster end},cls)
end
assert(a:GetBehavior()==136 and a:GetAOERadius()==0)
for _,spell in ipairs(casts) do assert(spell:GetBehavior()==8) end
scepter=true;assert(a:GetBehavior()==176 and a:GetAOERadius()==400)
a:OnSpellStart();assert(searches==1 and caster.sounds==1)
assert(#normal.controls==1 and #boss.controls==1 and #ally.controls==0 and #dead.controls==0,'One control per distinct eligible enemy')
for _,spell in ipairs(casts) do assert(spell:GetBehavior()==8+4194304,'Own spells can be ordered during area Gaze') end
normal.controls[1]:OnDestroy()
assert(ended==0 and not a.gazeTargets[normal] and a.gazeTargets[boss],'One dispel cannot cancel other area targets')
boss.controls[1]:OnDestroy()
assert(ended==1 and a.gazeTargets==nil,'Last control removal interrupts only matching channel')
normal.controls={};boss.controls={};a:OnSpellStart();a:OnChannelFinish(false)
assert(a.gazeTargets==nil and normal.removals==1 and boss.removals==1 and ended==1,'Normal channel finish detaches before removal callbacks')
for _,spell in ipairs(casts) do assert(spell:GetBehavior()==8,'No free-cast flag leaks past channel finish') end
units={};a:OnSpellStart();assert(ended==2 and a.gazeTargets==nil,'Empty area ends channel and stores no stale targets')
units={unit(3,false,true,true)};a:OnSpellStart();assert(ended==3 and a.gazeTargets==nil,'All failed modifier applications end channel')
for _,duration in ipairs({${durations.join(',')}}) do
 rankedDuration=duration;units={unit(3,false,true),unit(3,true,true)}
 a:OnSpellStart();assert(a:GetChannelTime()==duration)
 a:OnChannelFinish(false);assert(a.gazeTargets==nil)
end
local disappearing=unit(3,false,true)
local originalAdd=disappearing.AddNewModifier
function disappearing:AddNewModifier(...)
 local control=originalAdd(self,...)
 a.IsNull=function() return true end
 a.GetCaster=function() error('Removed ability must not query its caster after application callback') end
 return control
end
units={disappearing};a:OnSpellStart()
assert(a.gazeTargets==nil,'Removed source does not retain area ownership')
disappearing.controls[1]:OnIntervalThink()
a.IsNull=function() return false end;a.GetCaster=function() return caster end
scepter=false;blessing=true;assert(a:GetBehavior()==176,'Consumed Blessing uses existing acquisition detection')
blessing=false;assert(a:GetBehavior()==136 and a:GetAOERadius()==0)
local role=setmetatable({GetParent=function() return caster end},modifier_enfos_scepter_upgrade)
local ult={GetAbilityType=function() return DOTA_ABILITY_TYPE_ULTIMATE end}
assert(role:GetModifierSpellAmplify_Percentage({inflictor=ult})==0 and role:GetModifierPercentageCooldown({ability=ult})==0,'Unique Lich upgrade replaces generic ultimate stack')
caster.GetUnitName=function() return 'npc_dota_hero_axe' end
assert(role:GetModifierSpellAmplify_Percentage({inflictor=ult})==40 and role:GetModifierPercentageCooldown({ability=ult})==25,'Unreviewed heroes retain their existing upgrade')
print('Lich Scepter area ownership regression PASS')
`;
  const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
  assert.equal(r.status,0,r.stderr||r.stdout);
  assert.match(r.stdout,/Lich Scepter area ownership regression PASS/,r.stderr);
});
