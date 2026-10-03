import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';
import {getAbilityValues} from '../lib/ability_values.mjs';
import {readAbilitySources} from '../lib/ability_sources.mjs';
import {isVerifiedNativeAbility} from '../lib/native_hero_abilities.mjs';

const all=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
const ids=['lucent_beam','lunar_orbit','lunar_blessing','eclipse','moon_glaives'].map(x=>'enfos_luna_'+x);
test('All Luna native aliases resolve reviewed definitions with no Lua ability replicas or Boss formula',()=>{
  const snapshot=JSON.parse(fs.readFileSync('docs/audit/LUNA_NATIVE_SOURCE_2026-10-03.json','utf8'));
  for(const id of ids){assert.ok(isVerifiedNativeAbility(id,all[id]));assert.ok(snapshot.abilities[all[id].BaseClass]);}
  const shared=fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8');
  assert.doesNotMatch(shared,/enfos_luna_\w+=class|modifier_enfos_luna_/);
  assert.equal(all.enfos_luna_eclipse.AbilityValues.boss_damage_pct,undefined);
  assert.equal(all.enfos_luna_eclipse.AbilityValues.beam_damage,undefined);
  for(const [path,source]of readAbilitySources(all))if(path.includes('/luna/')) {
    assert.doesNotMatch(source,/is_boss|isBoss|GetMaxHealth|ApplyDamage|CreateTrackingProjectile|StartIntervalThink|CreateParticle|EmitSound/);
  }
});
test('Native E drops innate/hidden gates and supplies ten paid ranks; R upgrades have explicit ten-rank arrays',()=>{
  const e=all.enfos_luna_lunar_blessing,r=all.enfos_luna_eclipse;
  assert.equal(e.Innate,'0');assert.doesNotMatch(e.AbilityBehavior,/HIDDEN|SKIP_FOR_KEYBINDS|FORCE_NO_INNATE_UI/);
  assert.equal(e.MaxLevel,'10');assert.equal(e.RequiredLevel,'1');assert.equal(e.LevelsBetweenUpgrades,'1');
  for(const key of ['bonus_damage','self_bonus_damage']){
    assert.equal(e.AbilityValues[key].hero_levelup,'+0');assert.equal(e.AbilityValues[key].value.split(' ').length,10);
  }
  assert.equal(r.MaxLevel,'10');assert.equal(r.RequiredLevel,'5');assert.equal(r.LevelsBetweenUpgrades,'5');
  for(const [key,raw]of Object.entries(r.AbilityValues))for(const [name,value]of Object.entries(typeof raw==='object'?raw:{value:raw})) {
    if(!['value','special_bonus_scepter'].includes(name))continue;
    const count=value.split(' ').length;assert.ok(count===1||count===10,`${key}.${name} incomplete native array`);
  }
  assert.equal(r.AbilityValues.beam_interval.special_bonus_scepter,'-0.3');
  assert.equal(r.AbilityValues.AbilityCastRange.special_bonus_scepter,'+2500');
});

function lua(script){
  const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
  assert.equal(r.status,0,r.stderr);assert.equal(r.stderr,'');
}
const setup=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
function LinkLuaModifier()end
function IsServer()return true end
local traces={}
print=function(line)traces[#traces+1]=line end
local q={rank=0,IsNull=function()return false end,GetLevel=function(self)return self.rank end,
 GetAbilityName=function()return 'enfos_luna_lucent_beam' end,
 GetLevelSpecialValueNoOverride=function(self,key,rank)
  if key=='beam_damage' then return ({${getAbilityValues(all.enfos_luna_lucent_beam).beam_damage.split(' ').join(',')}})[rank+1] end
  assert(key=='agility_multiplier');return 1.5
 end}
local e={rank=0,IsNull=function()return false end,GetLevel=function(self)return self.rank end,
 GetSpecialValueFor=function(self,key)
  if key=='bonus_armor' then return ({${getAbilityValues(all.enfos_luna_lunar_blessing).bonus_armor.split(' ').join(',')}})[self.rank] end
  if key=='bonus_ms_pct' then return 12 end
  assert(key=='radius');return ({${getAbilityValues(all.enfos_luna_lunar_blessing).radius.split(' ').join(',')}})[math.max(1,self.rank)]
 end}
local adds,mods=0,0
local hero={points=5,agi=100,dead=false,broken=false,abilities={enfos_luna_lucent_beam=q,enfos_luna_lunar_blessing=e},modifiers={},
 IsNull=function()return false end,IsRealHero=function()return true end,IsIllusion=function()return false end,
 GetUnitName=function()return 'npc_dota_hero_luna' end,IsAlive=function(self)return not self.dead end,
 PassivesDisabled=function(self)return self.broken end,GetAgility=function(self)return self.agi end,
 FindAbilityByName=function(self,id)return self.abilities[id] end,
 HasModifier=function(self,name)return self.modifiers[name]~=nil end,
 AddNewModifier=function(self,caster,ability,name)
  mods=mods+1
  local m=setmetatable({GetParent=function()return self end,GetCaster=function()return caster end,GetAbility=function()return ability end},_G[name])
  self.modifiers[name]=m;return m
 end,
 AddAbility=function(self,name)
  assert(name=='luna_lucent_beam');adds=adds+1
  local peer={rank=0,IsNull=function()return false end,GetAbilityName=function()return name end,
   GetLevel=function(self)return self.rank end,SetLevel=function(self,n)self.rank=n end,
   SetHidden=function(self,v)self.hidden=v end,SetActivated=function(self,v)self.activated=v end}
  self.abilities[name]=peer;return peer
 end}
local integration=require('abilities/heroes/luna/integration')
`;
test('Native Q/R provider restore is idempotent and reads live paid Q ranks without changing points',()=>lua(setup+`
assert(integration.Restore(hero));assert(integration.Restore(hero))
assert(adds==1 and mods==2 and hero.points==5 and e.rank==0)
assert(#traces==0)
local peer=hero.abilities.luna_lucent_beam
assert(peer.rank==1 and peer.hidden and not peer.activated)
local m=hero.modifiers.modifier_enfos_luna_native_scaling
local args={ability=peer,ability_special_value='beam_damage',ability_special_level=0}
assert(m:GetModifierOverrideAbilitySpecial(args)==1)
assert(m:GetModifierOverrideAbilitySpecialValue(args)==0)
for _,case in ipairs({{1,300},{4,600},{5,650},{10,900}})do
 q.rank=case[1];assert(m:GetModifierOverrideAbilitySpecialValue(args)==case[2])
 args.ability=q;assert(m:GetModifierOverrideAbilitySpecialValue(args)==case[2]);args.ability=peer
end
hero.agi=200;assert(m:GetModifierOverrideAbilitySpecialValue(args)==1050)
args.ability_special_value='stun_duration';assert(m:GetModifierOverrideAbilitySpecial(args)==0)
require('lib/hero_trace'):SetEnabled(true)
assert(integration.Restore(hero));assert(#traces==3)
assert(traces[1]:find('[LUNA_TRACE][Q]',1,true) and traces[2]:find('[LUNA_TRACE][R]',1,true) and traces[3]:find('[LUNA_TRACE][E]',1,true))
hero.modifiers={};assert(integration.Restore(hero));assert(adds==1 and mods==4 and hero.points==5)
`));
test('E extension contains only ranked armor/speed and suppresses stale aura bonuses on Break/death/untrained E',()=>lua(setup+`
assert(integration.Restore(hero))
local aura=hero.modifiers.modifier_enfos_luna_blessing_extension
assert(not aura:IsAura())
e.rank=1;assert(aura:IsAura())
local buff=setmetatable({GetCaster=function()return hero end,GetAbility=function()return e end},modifier_enfos_luna_blessing_extension_buff)
assert(buff:GetModifierPhysicalArmorBonus()==3 and buff:GetModifierMoveSpeedBonus_Percentage()==12)
e.rank=10;assert(buff:GetModifierPhysicalArmorBonus()==15)
hero.broken=true;assert(not aura:IsAura() and buff:GetModifierPhysicalArmorBonus()==0 and buff:GetModifierMoveSpeedBonus_Percentage()==0)
hero.broken=false;hero.dead=true;assert(not aura:IsAura() and buff:GetModifierPhysicalArmorBonus()==0)
hero.dead=false;e.rank=0;assert(not aura:IsAura() and buff:GetModifierMoveSpeedBonus_Percentage()==0)
assert(buff.GetModifierPreAttack_BonusDamage==nil,'Native damage must not be duplicated')
hero.IsIllusion=function()return true end
assert(not integration.Restore(hero))
`));
test('Native Eclipse replaces generic Scepter amplification/cooldown while preserving native Boss and other heroes',()=>lua(setup+`
require('heroes/aghanim_manager')
DOTA_ABILITY_TYPE_ULTIMATE=1
local r={GetAbilityType=function()return 1 end}
hero.abilities.enfos_luna_eclipse=r
local mod=setmetatable({GetParent=function()return hero end},modifier_enfos_scepter_upgrade)
local args={ability=r,inflictor=r}
assert(mod:IsHidden() and mod:GetModifierSpellAmplify_Percentage(args)==0 and mod:GetModifierPercentageCooldown(args)==0)
hero.abilities.enfos_luna_eclipse=nil
assert(not mod:IsHidden() and mod:GetModifierSpellAmplify_Percentage(args)==40 and mod:GetModifierPercentageCooldown(args)==25)
hero.GetUnitName=function()return 'npc_dota_hero_drow_ranger' end
assert(mod:GetModifierSpellAmplify_Percentage(args)==40 and mod:GetModifierPercentageCooldown(args)==25)
`));


test('Luna links all three engine-only classes to a separately loadable modifier script',()=>lua(`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
LUA_MODIFIER_MOTION_NONE=0
local links={}
function LinkLuaModifier(name,path,motion)
 assert(path=='abilities/heroes/luna/modifiers' and motion==0)
 assert(not links[name],'Duplicate registration')
 local scope=setmetatable({},{__index=_G})
 local chunk=assert(loadfile('game/scripts/vscripts/'..path..'.lua','t',scope))
 assert(chunk()==nil,'Engine script must not return an unrelated restore service')
 assert(type(rawget(scope,name))=='table','Class absent from engine file scope')
 assert(rawget(scope,'Scaling')==nil and rawget(scope,'Extension')==nil)
 links[name]=scope[name]
end
require('abilities/heroes/luna/integration')
assert(links.modifier_enfos_luna_native_scaling.GetModifierOverrideAbilitySpecialValue)
assert(links.modifier_enfos_luna_blessing_extension.IsAura)
assert(links.modifier_enfos_luna_blessing_extension_buff.GetModifierPhysicalArmorBonus)
`));

test('Failed Luna Q modifier creation reports failure while E restore still runs',()=>lua(setup+`
require('lib/hero_trace'):SetEnabled(true)
local add=hero.AddNewModifier
hero.AddNewModifier=function(self,caster,ability,name)
 if name=='modifier_enfos_luna_native_scaling' then return nil end
 return add(self,caster,ability,name)
end
assert(not integration.Restore(hero))
assert(hero.modifiers.modifier_enfos_luna_blessing_extension)
local log=table.concat(traces,'|')
assert(log:find('native_scaling_modifier_missing',1,true))
assert(not log:find('native_scaling_ready',1,true) and not log:find('native_beam_provider_ready',1,true))
assert(log:find('native_blessing_extension_ready',1,true))
`));

test('Failed Luna E modifier creation cannot emit a ready trace',()=>lua(setup+`
require('lib/hero_trace'):SetEnabled(true)
local add=hero.AddNewModifier
hero.AddNewModifier=function(self,caster,ability,name)
 if name=='modifier_enfos_luna_blessing_extension' then return {IsNull=function()return true end} end
 return add(self,caster,ability,name)
end
assert(not integration.Restore(hero))
local log=table.concat(traces,'|')
assert(log:find('native_blessing_extension_missing',1,true))
assert(not log:find('native_blessing_extension_ready',1,true))
`));
