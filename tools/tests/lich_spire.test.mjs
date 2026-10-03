import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';

test('Ice Spire foundation keeps native ward identity and four-language presentation',()=>{
  const u=parseKV(fs.readFileSync('game/scripts/npc/npc_units_custom.txt','utf8')).DOTAUnits.enfos_lich_ice_spire_unit;
  assert.equal(u.Model,'models/heroes/lich/ice_spire.vmdl');
  assert.equal(u.IsOther,'1');assert.equal(u.IsSummoned,'1');
  assert.equal(u.Ability1,'neutral_spell_immunity','Installed native ward uses this ability');
  assert.equal(u.MovementCapabilities,'DOTA_UNIT_CAP_MOVE_NONE');
  assert.equal(u.AttackCapabilities,'DOTA_UNIT_CAP_NO_ATTACK');
  assert.equal(u.BountyXP,'0');assert.equal(u.BountyGoldMin,'0');assert.equal(u.BountyGoldMax,'0');
  for(const lang of ['english','turkish','russian','schinese']){
    const t=JSON.parse(fs.readFileSync(`localization/${lang}.json`,'utf8')).Tokens;
    for(const key of ['enfos_lich_ice_spire_unit','DOTA_Tooltip_modifier_enfos_lich_ice_spire',
      'DOTA_Tooltip_modifier_enfos_lich_ice_spire_Description',
      'DOTA_Tooltip_modifier_enfos_lich_ice_spire_slow',
      'DOTA_Tooltip_modifier_enfos_lich_ice_spire_slow_Description'])assert.ok(t[key],`${lang}:${key}`);
  }
});

test('Real Ice Spire controller bounds lifetime, attack durability, repair and destruction ownership',()=>{
  const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t) t.__index=t;return t end
function LinkLuaModifier() end
local server=true;function IsServer() return server end
local Spire=require('abilities/heroes/lich/spire')
local caster={removed=false,alive=true};local sounds,blasts,kills,spawned=0,0,0,{}
local q={GetLevel=function() return 1 end,IsNull=function() return false end}
function q:BlastAtPoint(origin) assert(origin);blasts=blasts+1 end
function caster:IsNull() return self.removed end
function caster:IsAlive() return self.alive end
function caster:GetTeamNumber() return 2 end
function caster:FindAbilityByName(id) assert(id=='enfos_lich_frost_blast');return q end
local removed=false
local values={duration=15,max_hero_attacks=4,max_creep_attacks=8,aura_radius=550,slow_duration=0.5,bonus_movespeed=-25}
local ability=setmetatable({GetCaster=function() return caster end,IsNull=function() return removed end,
 GetCursorPosition=function() return {x=400,y=700,z=0} end,
 GetSpecialValueFor=function(_,key) return values[key] or 0 end},enfos_lich_ice_spire)
function EmitSoundOnLocationWithCaster(origin,event,owner)
 assert(origin and owner==caster);assert(event=='Ability.FrostNova' or event=='Hero_Lich.IceSpire.Destroy');sounds=sounds+1
end
local failSpawn,failController=false,false
local function unit()
 local u={alive=true,removed=false,owner=caster,team=2,health=8}
 function u:IsNull() return self.removed end
 function u:IsAlive() return self.alive end
 function u:GetUnitName() return Spire.unitName end
 function u:GetTeamNumber() return self.team end
 function u:GetOwnerEntity() assert(server,'Server-only owner API');return self.owner end
 function u:GetAbsOrigin() return {x=400,y=700,z=0} end
 function u:SetBaseMaxHealth(n) assert(n==8) end
 function u:SetMaxHealth(n) assert(n==8) end
 function u:SetHealth(n) assert(n>=1 and n<=8);self.health=n end
 function u:FindModifierByName(name) assert(name=='modifier_enfos_lich_ice_spire');return self.mod end
 function u:AddNewModifier(c,ab,name,kv)
   assert(c==caster and ab==ability and name=='modifier_enfos_lich_ice_spire' and kv.duration==15)
   if failController then return nil end
   local m=setmetatable({GetParent=function() return self end,GetCaster=function() return caster end,
     GetAbility=function() return ability end,IsNull=function() return false end,
     StartIntervalThink=function(_,n) assert(n==0.5) end},modifier_enfos_lich_ice_spire)
   self.mod=m;m:OnCreated();return m
 end
 function u:ForceKill(reincarnate)
   assert(not reincarnate);assert(self.alive,'No repeated kill');self.alive=false;kills=kills+1
   if self.mod then self.mod:OnDeath({unit=self});self.mod:OnDestroy() end
 end
 return u
end
function CreateUnitByName(name,pos,clear,npcOwner,entityOwner,team)
 assert(name==Spire.unitName and pos.y==700 and clear and npcOwner==caster and entityOwner==caster and team==2)
 if failSpawn then return nil end
 local u=unit();spawned[#spawned+1]=u;return u
end
local function attack(hero,team)
 return {IsNull=function() return false end,IsAlive=function() return true end,
 GetTeamNumber=function() return team or 3 end,IsHero=function() return hero end}
end
ability:OnSpellStart();local first=Spire.Get(caster);assert(first and first.health==8 and sounds==1)
assert(first.mod:IsAura() and first.mod:GetAuraRadius()==550 and first.mod:GetAuraDuration()==0.5)
assert(first.mod:GetAbsoluteNoDamagePhysical()==1 and first.mod:GetAbsoluteNoDamageMagical()==1 and first.mod:GetAbsoluteNoDamagePure()==1)
first.mod:OnAttackLanded({target=first,attacker=attack(true,2)});assert(first.health==8,'Friendly attack does not count')
first.mod:OnAttackLanded({target={},attacker=attack(true)});assert(first.health==8,'Other unit attack does not count')
first.mod:OnAttackLanded({target=first,attacker=attack(true)});assert(first.health==6,'Hero attack is two of eight durability')
assert(Spire.Repair(caster,first)==2 and first.health==8);assert(Spire.Repair(caster,first)==0,'Repair capped at original health')
first.mod:OnAttackLanded({target=first,attacker=attack(false)});assert(first.health==7)
assert(Spire.Repair(caster,first)==1 and first.health==8,'Partial repair cannot over-heal')
for i=1,3 do first.mod:OnAttackLanded({target=first,attacker=attack(true)}) end
assert(first.health==2 and blasts==0)
assert(Spire.HeroHit(caster,first));assert(not first.alive and blasts==1 and caster.enfosLichSpire==nil and kills==1)
first.mod:OnDestroy();first.mod:OnDeath({unit=first});assert(blasts==1 and kills==1,'Reentrant death/expiry only one Nova and kill')
ability:OnSpellStart();local second=Spire.Get(caster)
for i=1,8 do second.mod:OnAttackLanded({target=second,attacker=attack(false)}) end
assert(blasts==2 and not second.alive,'Eight creep attacks exhaust Spire regardless of attack damage')
ability:OnSpellStart();local third=Spire.Get(caster);caster.alive=false
third.mod:OnIntervalThink();assert(third.mod:IsAura(),'Caster death does not remove existing owned totem')
third.mod:OnDestroy();assert(blasts==3 and not third.alive,'Finite expiry detonates once with valid dead owner')
caster.alive=true;ability:OnSpellStart();local old=Spire.Get(caster)
ability:OnSpellStart();local replacement=Spire.Get(caster)
assert(old~=replacement and not old.alive and blasts==3,'Recast retires old Spire without death Nova')
old.mod:OnDestroy();assert(caster.enfosLichSpire==replacement,'Old callbacks cannot clear replacement')
failSpawn=true;ability:OnSpellStart();assert(Spire.Get(caster)==replacement);failSpawn=false
values.duration=0;local spawnCount=#spawned;ability:OnSpellStart()
assert(#spawned==spawnCount and Spire.Get(caster)==replacement,'Invalid lifetime cannot create permanent unit');values.duration=15
failController=true;ability:OnSpellStart();assert(Spire.Get(caster)==replacement and not spawned[#spawned].alive);failController=false
Spire.Retire(caster,'shard_lost');assert(not replacement.alive and blasts==3 and caster.enfosLichSpire==nil)
ability:OnSpellStart();local orphan=Spire.Get(caster);removed=true
orphan.mod:OnIntervalThink();assert(not orphan.alive and blasts==3);removed=false
ability:OnSpellStart();orphan=Spire.Get(caster);orphan.owner={}
orphan.mod:OnIntervalThink();assert(not orphan.alive and blasts==3,'Foreign owner cannot trigger Nova')
ability:OnSpellStart();orphan=Spire.Get(caster);orphan.team=3
orphan.mod:OnIntervalThink();assert(not orphan.alive and blasts==3,'Allegiance change terminates without Nova')
ability:OnSpellStart();orphan=Spire.Get(caster);caster.removed=true
orphan.mod:OnIntervalThink();assert(not orphan.alive and blasts==3);caster.removed=false
-- Client evaluation must never use server-only entity-owner/health APIs.
ability:OnSpellStart();local client=Spire.Get(caster);server=false
assert(not client.mod:IsAura() and not Spire.Get(caster));assert(client.mod:RepairHeroHit()==0)
client.mod:OnAttackLanded({target=client,attacker=attack(true)});assert(client.health==8)
client.mod:OnDestroy();assert(client.alive);server=true
Spire.Retire(caster,'test_cleanup')
local slow=setmetatable({GetAbility=function() return ability end},modifier_enfos_lich_ice_spire_slow)
assert(slow:IsDebuff() and not slow:IsPurgable() and slow:GetTexture()=='lich_ice_spire')
assert(slow:GetModifierMoveSpeedBonus_Percentage()==-25);removed=true
assert(slow:GetModifierMoveSpeedBonus_Percentage()==0)
print('Lich Ice Spire controller regression PASS')
`;
  const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
  assert.equal(r.status,0,r.stderr||r.stdout);
  assert.match(r.stdout,/Lich Ice Spire controller regression PASS/,r.stderr);
});
