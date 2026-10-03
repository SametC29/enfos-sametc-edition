import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';

const abilities=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
const curve=(id,key)=>String(abilities[id].AbilityValues[key]).split(/\s+/).map(Number);
const q='enfos_lich_frost_blast',r='enfos_lich_chain_frost';

test('Gaze basic-dispel contract and removal preserve channel ownership',()=>{
  const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t) t.__index=t;return t end
function LinkLuaModifier() end
local server=true
function IsServer() return server end
require('abilities/heroes/lich/e')
local cls=modifier_enfos_lich_sinister_gaze_debuff
assert(cls:IsPurgable() and not cls:IsStunDebuff(),'Native Gaze hypnosis allows basic dispel despite action lock')
assert(cls:IsDebuff() and cls:GetTexture()=='lich_sinister_gaze','Harmful hypnosis keeps native icon')
local target,newTarget={},{}
local ended,active,removed=0,nil,false
local caster={IsNull=function() return false end,GetCurrentActiveAbility=function() return active end}
local ability={IsNull=function() return removed end,gazeTarget=target}
function ability:EndChannel(interrupted)
  assert(interrupted and self.gazeTarget==nil,'Detach ownership before callback to prevent recursive cleanup')
  ended=ended+1
end
local m=setmetatable({GetAbility=function() return ability end,GetCaster=function() return caster end,
  GetParent=function() return target end},cls)
active=ability;m:OnDestroy()
assert(ended==1 and ability.gazeTarget==nil,'Dispel/expiry interrupts matching channel once')
m:OnDestroy();assert(ended==1,'Repeated removal cannot interrupt twice')
ability.gazeTarget=newTarget;m:OnDestroy()
assert(ended==1 and ability.gazeTarget==newTarget,'Old target cannot erase or interrupt new cast')
ability.gazeTarget=target;active={};m:OnDestroy()
assert(ended==1 and ability.gazeTarget==nil,'Other active ability must not be interrupted')
ability.gazeTarget=target;active=ability;removed=true;m:OnDestroy()
assert(ended==1 and ability.gazeTarget==target,'Removed ability is not mutated')
removed=false;server=false;m:OnDestroy()
assert(ended==1 and ability.gazeTarget==target,'Client cleanup cannot mutate server ownership')
print('Lich E dispel ownership regression PASS')
`;
  const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
  assert.equal(result.status,0,result.stderr||result.stdout);
  assert.match(result.stdout,/Lich E dispel ownership regression PASS/,result.stderr);
  for(const lang of ['english','turkish','russian','schinese']){
    const tokens=JSON.parse(fs.readFileSync(`localization/${lang}.json`,'utf8')).Tokens;
    assert.ok(tokens.DOTA_Tooltip_modifier_enfos_lich_sinister_gaze_debuff,lang+': explicit control name');
    assert.ok(tokens.DOTA_Tooltip_modifier_enfos_lich_sinister_gaze_debuff_Description,lang+': explicit control description');
  }
});

test('Lich aura has explicit four-locale ability and recipient tooltips',()=>{
  for(const lang of ['english','turkish','russian','schinese']){
    const tokens=JSON.parse(fs.readFileSync(`localization/${lang}.json`,'utf8')).Tokens;
    const key='DOTA_Tooltip_Ability_enfos_lich_ice_aura';
    assert.ok(tokens[key],`${lang}: explicit passive title`);
    for(const suffix of ['_Description','_SummaryDescription']){
      for(const value of ['radius','bonus_armor','mana_regen'])
        assert.ok(tokens[key+suffix]?.includes(`{{${value}}}`),`${lang}: authored ${value} shown without rank1 snapshots`);
    }
    const buff=tokens.DOTA_Tooltip_modifier_enfos_lich_ice_aura_buff_Description;
    for(const property of ['PHYSICAL_ARMOR_BONUS','MANA_REGEN_CONSTANT'])
      assert.ok(buff?.includes(`MODIFIER_PROPERTY_${property}`),`${lang}: live recipient ${property}`);
  }
});

test('Lich Q and R use ordinary ranked formulas on both normal and Boss recipients',()=>{
  const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t) t.__index=t;return t end
function LinkLuaModifier() end
function IsServer() return true end
DAMAGE_TYPE_MAGICAL=2;PATTACH_ABSORIGIN_FOLLOW=1
DOTA_UNIT_TARGET_TEAM_ENEMY=1;DOTA_UNIT_TARGET_HERO=1;DOTA_UNIT_TARGET_BASIC=2
DOTA_UNIT_TARGET_FLAG_NONE=0;FIND_ANY_ORDER=0
function Vector(x,y,z) return {x=x,y=y,z=z} end
local controls={}
ParticleManager={CreateParticle=function() controls={};return 1 end,
  SetParticleControl=function(_,id,cp,v) controls[cp]=v end,ReleaseParticleIndex=function() end}
local world,damageEvents,sounds={},{},{}
function FindUnitsInRadius() return world end
function ApplyDamage(e) damageEvents[#damageEvents+1]=e;return e.damage end
local function unit(boss,index)
  return {isBoss=boss,IsNull=function() return false end,IsAlive=function() return true end,
    GetUnitName=function() return boss and 'enfos_boss_test' or 'normal_test' end,
    GetTeamNumber=function() return index==1 and 2 or 3 end,
    GetAbsOrigin=function() return {x=index*100,y=0,z=0} end,
    GetIntellect=function() return 1000 end,GetMaxHealth=function() return 100 end,
    EmitSound=function(self,event) sounds[#sounds+1]={unit=self,event=event} end,
    IsHero=function() return false end,entindex=function() return index end,
    AddNewModifier=function(self,c,a,name,kv) self.slow=kv.duration;return {} end}
end
require('abilities/heroes/lich/q');require('abilities/heroes/lich/r')
do
  local c,p=unit(false,1),unit(false,1)
  p.TriggerSpellAbsorb=function() error('Friendly Q must not consume spell absorb') end
  p.EmitSound=function() error('Friendly Q must not emit cast feedback') end
  local a=setmetatable({GetCaster=function() return c end,GetCursorTarget=function() return p end},enfos_lich_frost_blast)
  damageEvents={};a:OnSpellStart();assert(#damageEvents==0,'Friendly Q must not deal damage')
end
local targetDamage,splashDamage={${curve(q,'target_damage')}},{${curve(q,'radius_damage')}}
local duration,radius={${curve(q,'duration')}},{${curve(q,'radius')}}
local chainDamage,chainDuration={${curve(r,'damage')}},{${curve(r,'slow_duration')}}
for rank=1,10 do
  for _,boss in ipairs({false,true}) do
    local c,p,s=unit(false,1),unit(boss,2),unit(boss,3)
    local values={target_damage=targetDamage[rank],radius_damage=splashDamage[rank],duration=duration[rank],radius=radius[rank]}
    local a=setmetatable({GetCaster=function() return c end,GetCursorTarget=function() return p end,
      GetLevel=function() return rank end,GetSpecialValueFor=function(_,k) return values[k] or 0 end},enfos_lich_frost_blast)
    world={p,s};damageEvents={};sounds={};a:OnSpellStart()
    assert(#damageEvents==2)
    assert(#sounds==1 and sounds[1].unit==p and sounds[1].event=='Ability.FrostNova','Q emits one target-centered nova sound')
    assert(damageEvents[1].damage==targetDamage[rank]+800,'Q primary must not have a Boss maxHP cap')
    assert(damageEvents[2].damage==splashDamage[rank]+500,'Q splash must not have a Boss maxHP cap')
    assert(p.slow==duration[rank] and s.slow==duration[rank],'Q ordinary control duration applies to both')
    assert(controls[1] and controls[1].x==radius[rank] and controls[1].y==radius[rank] and controls[1].z==radius[rank],
      'Frost Nova children must receive their radius/thickness/speed CP1 inputs')
    local b=setmetatable({GetCaster=function() return c end},enfos_lich_chain_frost)
    p.slow=nil;damageEvents={}
    b:OnProjectileHit_ExtraData(p,nil,{hits=0,limit=1,damage=chainDamage[rank]+1000,slow_duration=chainDuration[1]})
    assert(#damageEvents==1 and damageEvents[1].damage==chainDamage[rank]+1000)
    assert(p.slow==chainDuration[1],'R ordinary slow duration applies to both')
  end
end
do
  local removed=false
  local a={IsNull=function() return removed end,GetSpecialValueFor=function(_,key)
    assert(not removed,'Do not read a removed slow ability')
    return ({slow_pct=51,slow_attack=40,slow_attack_pct=50})[key] or 0
  end}
  local qSlow=setmetatable({GetAbility=function() return a end},modifier_enfos_lich_frost_blast_slow)
  local rSlow=setmetatable({GetAbility=function() return a end},modifier_enfos_lich_chain_frost_slow)
  assert(qSlow:GetModifierMoveSpeedBonus_Percentage()==-51 and qSlow:GetModifierAttackSpeedBonus_Constant()==-40)
  assert(rSlow:GetModifierMoveSpeedBonus_Percentage()==-51 and rSlow:GetModifierAttackSpeedBonus_Constant()==-50)
  removed=true
  for _,m in ipairs({qSlow,rSlow}) do
    assert(m:GetModifierMoveSpeedBonus_Percentage()==0 and m:GetModifierAttackSpeedBonus_Constant()==0,
      'Removed ability must not produce hard-coded orphan slow values')
  end
end
print('Lich ordinary targets ten-rank regression PASS')
`;
  const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
  assert.equal(result.status,0,result.stderr||result.stdout);
  assert.match(result.stdout,/Lich ordinary targets ten-rank regression PASS/,result.stderr);
});

test('Lich aura uses its actual source for Break, rank changes and removed-source ownership',()=>{
  const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t) t.__index=t;return t end
function LinkLuaModifier() end
DOTA_UNIT_TARGET_TEAM_FRIENDLY=2;DOTA_UNIT_TARGET_HERO=1;DOTA_UNIT_TARGET_BASIC=2
require('abilities/heroes/lich/d')
local rank,sourceBroken,recipientBroken,sourceRemoved,abilityRemoved,illusion=1,false,false,false,false,false
local armor={${curve('enfos_lich_ice_aura','bonus_armor')}}
local mana={${curve('enfos_lich_ice_aura','mana_regen')}}
local radius={${curve('enfos_lich_ice_aura','radius')}}
local source={IsNull=function() return sourceRemoved end,PassivesDisabled=function() return sourceBroken end}
local recipient={IsNull=function() return false end,IsIllusion=function() return illusion end,
  PassivesDisabled=function() return recipientBroken end}
local a={IsNull=function() return abilityRemoved end,GetLevel=function() return rank end,
  GetSpecialValueFor=function(_,key)
    assert(not abilityRemoved,'Never read a removed aura ability')
    if key=='bonus_armor' then return armor[rank] or armor[1] end
    if key=='mana_regen' then return mana[rank] end
    if key=='radius' then return radius[rank] end
    error('Unexpected aura value '..key)
  end}
local intrinsic=setmetatable({GetParent=function() return source end,GetAbility=function() return a end},modifier_enfos_lich_ice_aura)
local buff=setmetatable({GetParent=function() return recipient end,GetCaster=function() return source end,
  GetAbility=function() return a end},modifier_enfos_lich_ice_aura_buff)
local function bonuses(expectedArmor,expectedMana)
  assert(buff:GetModifierPhysicalArmorBonus()==expectedArmor,'Aura armor/source ownership')
  assert(math.abs(buff:GetModifierConstantManaRegen()-expectedMana)<0.000001,'Aura mana/source ownership')
end
assert(intrinsic:GetAuraSearchTeam()==DOTA_UNIT_TARGET_TEAM_FRIENDLY)
assert(intrinsic:GetAuraSearchType()==DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC)
assert(intrinsic:GetModifierAura()=='modifier_enfos_lich_ice_aura_buff')
for nextRank=1,10 do
  rank=nextRank
  assert(intrinsic:IsAura(),'Learned, unbroken source emits aura')
  -- Authored support contract: flat 8 armor, +0.6 mana regen per additional rank.
  bonuses(8,4+(rank-1)*0.6)
  assert(intrinsic:GetAuraRadius()==radius[rank])
  recipientBroken=true;bonuses(8,4+(rank-1)*0.6);recipientBroken=false
  sourceBroken=true;assert(not intrinsic:IsAura());bonuses(0,0)
  sourceBroken=false;bonuses(8,4+(rank-1)*0.6)
  illusion=true;bonuses(0,0);illusion=false
end
rank=0;assert(not intrinsic:IsAura());bonuses(0,0)
rank=10;abilityRemoved=true;assert(not intrinsic:IsAura());bonuses(0,0)
abilityRemoved=false;sourceRemoved=true;assert(not intrinsic:IsAura());bonuses(0,0)
sourceRemoved=false;bonuses(8,9.4)
print('Lich aura source/rank regression PASS')
`;
  const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
  assert.equal(result.status,0,result.stderr||result.stdout);
  assert.match(result.stdout,/Lich aura source\/rank regression PASS/,result.stderr);
});

test('Lich shield mitigation cannot outlive valid allied ownership between pulses',()=>{
  const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t) t.__index=t;return t end
function LinkLuaModifier() end
require('abilities/heroes/lich/w')
local rank,sourceRemoved,recipientRemoved,abilityRemoved,recipientAlive,sourceAlive,recipientTeam=1,false,false,false,true,true,2
local reductions={${curve('enfos_lich_frost_shield','damage_reduction')}}
local c={IsNull=function() return sourceRemoved end,IsAlive=function() return sourceAlive end,
  GetTeamNumber=function() return 2 end}
local p={IsNull=function() return recipientRemoved end,IsAlive=function() return recipientAlive end,
  GetTeamNumber=function() return recipientTeam end}
local a={IsNull=function() return abilityRemoved end,GetSpecialValueFor=function(_,key)
  assert(not abilityRemoved,'Never read a removed shield source')
  assert(key=='damage_reduction');return reductions[rank]
end}
local m=setmetatable({GetCaster=function() return c end,GetParent=function() return p end,
  GetAbility=function() return a end},modifier_enfos_lich_frost_shield)
for i=1,10 do rank=i;assert(m:GetModifierIncomingPhysicalDamage_Percentage()==-reductions[i]) end
recipientTeam=3
assert(m:GetModifierIncomingPhysicalDamage_Percentage()==0,'Enemy recipient must immediately lose friendly protection, before next pulse')
recipientTeam=2;sourceRemoved=true
assert(m:GetModifierIncomingPhysicalDamage_Percentage()==0,'Removed caster cannot own shield protection')
sourceRemoved=false;recipientRemoved=true
assert(m:GetModifierIncomingPhysicalDamage_Percentage()==0,'Removed recipient cannot retain protection')
recipientRemoved=false;recipientAlive=false
assert(m:GetModifierIncomingPhysicalDamage_Percentage()==0,'Dead recipient cannot retain protection')
recipientAlive=true;sourceAlive=false
assert(m:GetModifierIncomingPhysicalDamage_Percentage()==-reductions[rank],'Caster death does not cancel an existing finite allied shield')
abilityRemoved=true;assert(m:GetModifierIncomingPhysicalDamage_Percentage()==0)
print('Lich shield immediate ownership regression PASS')
`;
  const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
  assert.equal(result.status,0,result.stderr||result.stdout);
  assert.match(result.stdout,/Lich shield immediate ownership regression PASS/,result.stderr);
});

test('Lich Frost Blast traces measured damage and slow lifecycle without changing combat',()=>{
  const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t) t.__index=t;return t end
function LinkLuaModifier() end
local server,enabled=true,false
function IsServer() return server end
Convars={GetBool=function() return enabled end}
GameRules={GetGameTime=function() return 1 end}
DAMAGE_TYPE_MAGICAL=2;PATTACH_ABSORIGIN_FOLLOW=1
DOTA_UNIT_TARGET_TEAM_ENEMY=1;DOTA_UNIT_TARGET_HERO=1;DOTA_UNIT_TARGET_BASIC=2
DOTA_UNIT_TARGET_FLAG_NONE=0;FIND_ANY_ORDER=0
function Vector(x,y,z) return {x=x,y=y,z=z} end
ParticleManager={CreateParticle=function() return 1 end,SetParticleControl=function() end,ReleaseParticleIndex=function() end}
local events,lines={},{}
local realPrint=print
print=function(line) lines[#lines+1]=line end
function ApplyDamage(e) events[#events+1]=e.damage;return e.damage*0.5 end
local function unit(team,name)
  return {IsNull=function() return false end,IsAlive=function() return true end,
    GetTeamNumber=function() return team end,GetUnitName=function() return name end,
    GetAbsOrigin=function() return Vector(0,0,0) end,GetIntellect=function() return 100 end,
    EmitSound=function() end,AddNewModifier=function(self,c,a,name,kv) self.slow=kv.duration end}
end
local c,p,s=unit(2,'lich'),unit(3,'primary'),unit(3,'splash')
function FindUnitsInRadius() return {p,s} end
require('abilities/heroes/lich/q')
local a=setmetatable({GetCaster=function() return c end,GetCursorTarget=function() return p end,
  GetLevel=function() return 1 end,GetSpecialValueFor=function(_,k)
  return ({target_damage=100,radius_damage=50,radius=250,duration=4})[k] or 0 end},enfos_lich_frost_blast)
local trace=require('lib/hero_trace')
a:OnSpellStart();assert(#lines==0 and events[1]==180 and events[2]==100 and p.slow==4 and s.slow==4)
events={};enabled=true;a:OnSpellStart()
assert(#events==2 and events[1]==180 and events[2]==100 and p.slow==4 and s.slow==4,'Logging must preserve damage/control')
local joined=table.concat(lines,'|')
local requested,actual=joined:match('requested_damage=([%d%.]+) actual_damage=([%d%.]+)')
assert(tonumber(requested)==180 and tonumber(actual)==90,'Primary trace must report the ApplyDamage return')
assert(tonumber(joined:match('splash_actual_total=([%d%.]+)'))==50,'Splash summary must distinguish actual mitigation from requested damage')
local m=setmetatable({GetParent=function() return p end,GetCaster=function() return c end},modifier_enfos_lich_frost_blast_slow)
m:OnCreated();m:OnRefresh();m:OnDestroy()
joined=table.concat(lines,'|')
for _,event in ipairs({'slow_created','slow_refreshed','slow_removed'}) do assert(joined:find(event,1,true),'Missing Q lifecycle trace '..event) end
local before=#lines;server=false;m:OnCreated();m:OnRefresh();m:OnDestroy();assert(#lines==before,'Client callbacks stay silent')
server=true;enabled=false;m:OnCreated();m:OnRefresh();m:OnDestroy();assert(#lines==before,'Disabled tracing stays silent')
enabled=true;for i=1,150 do m:OnRefresh() end
assert(trace.count==100 and #lines==100,'Shared trace rate cap remains bounded')
GameRules.GetGameTime=function() return 2 end
lines={};ApplyDamage=function(e) events[#events+1]=e.damage end
a:OnSpellStart();joined=table.concat(lines,'|')
assert(joined:find('actual_damage=<unavailable>',1,true) and joined:find('splash_actual_total=<unavailable>',1,true),
  'Unavailable engine measurements must not be reported as zero damage')
realPrint('Lich Q measured trace regression PASS')
`;
  const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
  assert.equal(result.status,0,result.stderr||result.stdout);
  assert.match(result.stdout,/Lich Q measured trace regression PASS/,result.stderr);
});

test('Lich Q/W/R modifiers explicitly preserve native basic-dispel and icon identity',()=>{
  const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t) t.__index=t;return t end
function LinkLuaModifier() end
require('abilities/heroes/lich/q');require('abilities/heroes/lich/w');require('abilities/heroes/lich/r')
local effects={
  {modifier_enfos_lich_frost_blast_slow,'lich_frost_nova',true},
  {modifier_enfos_lich_frost_shield,'lich_frost_shield',false},
  {modifier_enfos_lich_chain_frost_slow,'lich_chain_frost',true},
}
for _,entry in ipairs(effects) do
  local m,icon,debuff=entry[1],entry[2],entry[3]
  assert(type(m.IsPurgable)=='function' and m:IsPurgable()==true,'Native Q/W/R effects allow basic dispel')
  assert(m:GetTexture()==icon,'Modifier must display its own native ability icon')
  assert(m:IsDebuff()==debuff,'Purge direction must match harmful slow vs positive allied shield')
end
print('Lich Q/W/R modifier dispel identity contract PASS')
`;
  const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
  assert.equal(result.status,0,result.stderr||result.stdout);
  assert.match(result.stdout,/Lich Q\/W\/R modifier dispel identity contract PASS/,result.stderr);
});

test('Lich Gaze uses ordinary ranked channel, control, mana and pull on Boss targets',()=>{
  const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t) t.__index=t;return t end
function LinkLuaModifier() end
function IsServer() return true end
local V={};V.__index=V
function Vector(x,y,z) return setmetatable({x=x,y=y,z=z},V) end
function V.__add(a,b) return Vector(a.x+b.x,a.y+b.y,a.z+b.z) end
function V.__sub(a,b) return Vector(a.x-b.x,a.y-b.y,a.z-b.z) end
function V.__mul(a,n) return Vector(a.x*n,a.y*n,a.z*n) end
function V:Length2D() return math.sqrt(self.x*self.x+self.y*self.y) end
function V:Normalized() local n=self:Length2D();return Vector(self.x/n,self.y/n,0) end
local cleared=0
function FindClearSpaceForUnit() cleared=cleared+1 end
require('abilities/heroes/lich/e')
local durations={${curve('enfos_lich_sinister_gaze','duration')}}
local drains={${curve('enfos_lich_sinister_gaze','mana_drain_pct')}}
for rank=1,10 do for _,boss in ipairs({false,true}) do
  local gained=0
  local c={IsNull=function() return false end,IsAlive=function() return true end,
    GetTeamNumber=function() return 2 end,GetAbsOrigin=function() return Vector(0,0,0) end,
    EmitSound=function() end,GiveMana=function(_,n) gained=gained+n end}
  local p={isBoss=boss,position=Vector(400,0,0),mana=1000,
    IsNull=function() return false end,IsAlive=function() return true end,GetTeamNumber=function() return 3 end,
    GetUnitName=function() return boss and 'enfos_boss_gaze' or 'normal_gaze' end,
    GetAbsOrigin=function(self) return self.position end,SetAbsOrigin=function(self,v) self.position=v end,
    GetMana=function(self) return self.mana end,GetMaxMana=function() return 1000 end,
    SetMana=function(self,n) self.mana=n end,
    AddNewModifier=function(self,c,a,name,kv) self.duration=kv.duration;return {} end}
  local a=setmetatable({GetCaster=function() return c end,GetCursorTarget=function() return p end,
    GetLevel=function() return rank end,GetSpecialValueFor=function(_,k)
    return k=='duration' and durations[rank] or k=='mana_drain_pct' and drains[rank] or 0 end},enfos_lich_sinister_gaze)
  assert(a:GetChannelTime()==durations[rank],'Boss flag cannot shorten ranked engine channel')
  a:OnSpellStart();assert(p.duration==durations[rank],'Boss flag cannot shorten control')
  local m=setmetatable({GetParent=function() return p end,GetCaster=function() return c end,
    GetAbility=function() return a end,Destroy=function() error('Valid ordinary Gaze must not cancel') end},modifier_enfos_lich_sinister_gaze_debuff)
  cleared=0;m:OnIntervalThink()
  assert(p.position.x==360 and cleared==1,'Boss gets the same ordinary40-unit pull/clear-space handling')
  local expected=1000*drains[rank]*0.01*0.5
  assert(math.abs(p.mana-(1000-expected))<0.000001 and math.abs(gained-expected)<0.000001,'Ordinary mana transfer preserved')
end end
print('Lich E ordinary ten-rank targets regression PASS')
`;
  const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
  assert.equal(result.status,0,result.stderr||result.stdout);
  assert.match(result.stdout,/Lich E ordinary ten-rank targets regression PASS/,result.stderr);
});
