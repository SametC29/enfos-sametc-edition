import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';

test('Real W repairs only owned Spire and real R bridges without escaping the ordinary hit budget',()=>{
  const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t) t.__index=t;return t end
function LinkLuaModifier() end
local server=true;function IsServer() return server end
DOTA_UNIT_TARGET_HERO=1;DOTA_UNIT_TARGET_BASIC=2;DOTA_UNIT_TARGET_TEAM_ENEMY=3;DOTA_UNIT_TARGET_TEAM_FRIENDLY=2
DOTA_UNIT_TARGET_FLAG_NONE=0;FIND_ANY_ORDER=0;DAMAGE_TYPE_MAGICAL=2
UF_SUCCESS=0;UF_FAIL_OTHER=8;UF_FAIL_DEAD=15
local vector={};vector.__index=vector
function vector:Length2D() return math.sqrt(self.x*self.x+self.y*self.y) end
function vector.__sub(a,b) return setmetatable({x=a.x-b.x,y=a.y-b.y},vector) end
local origin=setmetatable({x=0,y=0},vector)
local Spire=require('abilities/heroes/lich/spire')
require('abilities/heroes/lich/w');require('abilities/heroes/lich/r')
local caster={GetTeamNumber=function() return 2 end,GetIntellect=function() return 40 end,
 IsNull=function() return false end,IsAlive=function() return true end,GetAbsOrigin=function() return origin end,
 EmitSound=function() end,FindAbilityByName=function() return nil end}
function EmitSoundOnLocationWithCaster() end
local ward={alive=true,owner=caster,team=2,pos=origin,health=8,absorb=0}
function ward:IsNull() return false end
function ward:IsAlive() return self.alive end
function ward:GetUnitName() return Spire.unitName end
function ward:GetTeamNumber() return self.team end
function ward:GetOwnerEntity() assert(server);return self.owner end
function ward:IsOther() return true end
function ward:GetAbsOrigin() return self.pos end
function ward:entindex() return 99 end
function ward:EmitSound(event) assert(event=='Hero_Lich.ChainFrostImpact.Creep') end
function ward:SetHealth(n) self.health=n end
function ward:TriggerSpellAbsorb() self.absorb=self.absorb+1;return true end
function ward:ForceKill() assert(self.alive);self.alive=false;self.mod:OnDeath({unit=self});self.mod:OnDestroy() end
function ward:FindModifierByName() return self.mod end
local shard={IsNull=function() return false end}
ward.mod=setmetatable({remaining=8,maxHits=8,heroCost=2,GetParent=function() return ward end,
 GetCaster=function() return caster end,GetAbility=function() return shard end,IsNull=function() return false end},modifier_enfos_lich_ice_spire)
caster.enfosLichSpire=ward
local function resetWard()
 ward.alive=true;ward.team=2;ward.owner=caster;ward.health=8;ward.pos=origin
 ward.mod.terminated=false;ward.mod.remaining=8;caster.enfosLichSpire=ward
end
local w=setmetatable({GetCaster=function() return caster end,IsNull=function() return false end,
 GetSpecialValueFor=function(_,k) return k=='dps' and 30 or k=='radius' and 600 or k=='slow_duration' and 0.5 or k=='damage_reduction' and 30 or 0 end},enfos_lich_frost_shield)
local search={};function FindUnitsInRadius() return search end
local shield=setmetatable({GetCaster=function() return caster end,GetParent=function() return ward end,
 GetAbility=function() return w end,Destroy=function(self) self.destroyed=true end},modifier_enfos_lich_frost_shield)
ward.mod:SpendHits(3,'test');shield:OnIntervalThink();assert(ward.health==7 and ward.mod.remaining==7)
shield:OnIntervalThink();assert(ward.health==8,'W restores one hero-hit per actual pulse and caps repair')
ward.owner={};shield:OnIntervalThink();assert(shield.destroyed and shield:GetShieldReduction()==0,'Lost ownership cancels pulse/protection')
resetWard()
local enemy={alive=true,damage=0,slows=0}
function enemy:IsNull() return false end
function enemy:IsAlive() return self.alive end
function enemy:GetTeamNumber() return 3 end
function enemy:GetUnitName() return 'enfos_wave_01' end
function enemy:GetAbsOrigin() return origin end
function enemy:entindex() return 1 end
function enemy:IsHero() return false end
function enemy:EmitSound() end
function enemy:AddNewModifier() self.slows=self.slows+1 end
function UnitFilter(target,team,types,flags,ownTeam)
 assert(types==3 and flags==0 and ownTeam==2)
 return target:GetTeamNumber()==team and UF_SUCCESS or UF_FAIL_OTHER
end
local current=enemy;local limit=10
local r=setmetatable({GetCaster=function() return caster end,GetCursorTarget=function() return current end,
 IsNull=function() return false end,GetLevel=function() return 1 end,
 GetSpecialValueFor=function(_,k) return k=='damage' and 250 or k=='jump_count' and limit or k=='slow_duration' and 2.5 or 0 end},enfos_lich_chain_frost)
assert(w:CastFilterResultTarget(ward)==0 and r:CastFilterResultTarget(ward)==0)
ward.owner={};assert(w:CastFilterResultTarget(ward)==8 and r:CastFilterResultTarget(ward)==8)
server=false;assert(r:CastFilterResultTarget(ward)==0,'Client predicts name/team without server-only API');server=true;resetWard()
server=false;assert(shield:GetShieldReduction()==30,'Client tooltip must not invoke server-only ward ownership API');server=true
assert(w:CastFilterResultTarget(enemy)==8 and r:CastFilterResultTarget(enemy)==0)
local queue={};local launches=0
ProjectileManager={CreateTrackingProjectile=function(_,p)
 local copy={};for k,v in pairs(p.ExtraData) do assert(type(v)=='number','Bounded numeric ExtraData only');copy[k]=v end
 queue[#queue+1]={target=p.Target,data=copy};launches=launches+1
 assert(p.iMoveSpeed==(copy.hits==0 and 1050 or 850));return launches
end}
function ApplyDamage(e) assert(e.victim==enemy and e.damage==290);enemy.damage=enemy.damage+1;return 290 end
local function drain(repair)
 local count=0
 while #queue>0 do
  local p=table.remove(queue,1);r:OnProjectileHit_ExtraData(p.target,nil,p.data);count=count+1
  assert(count<=18,'No infinite bridge/repeat cycle')
  if repair and ward.alive then Spire.Repair(caster,ward) end
 end
 return count
end
search={enemy};r:OnSpellStart();assert(drain(false)==9 and enemy.damage==5 and enemy.slows==5,'Four Spire hits plus five enemy hits; lethal Spire still bridges from captured origin')
assert(not ward.alive and ward.absorb==0,'Spire never receives magical damage/slow or hostile spell block')
resetWard();enemy.damage=0;enemy.slows=0;limit=18;r:OnSpellStart()
assert(drain(true)==18 and enemy.damage==9,'Even continuously repaired bridge has fixed total hit limit')
resetWard();enemy.damage=0;current=ward;limit=10;r:OnSpellStart();assert(drain(false)==8 and enemy.damage==4,'Owned Spire is valid initial target without spell block')
resetWard();current=enemy;enemy.damage=0;ward.pos=setmetatable({x=601,y=0},vector);r:OnSpellStart()
assert(drain(false)==1 and enemy.damage==1,'Spire beyond ordinary bounce range is not searched globally')
resetWard();current=ward;enemy.damage=0;r:OnSpellStart();ward.team=3;ward.owner={}
assert(drain(false)==1 and enemy.damage==0 and ward.mod.remaining==8,'Ownership/allegiance loss in flight cannot convert an allied ward into hostile damage target')
print('Lich W/R Ice Spire integration regression PASS')
`;
  const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
  assert.equal(r.status,0,r.stderr||r.stdout);
  assert.match(r.stdout,/Lich W\/R Ice Spire integration regression PASS/,r.stderr);
});

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
