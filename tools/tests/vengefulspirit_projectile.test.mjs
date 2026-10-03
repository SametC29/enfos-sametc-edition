import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';

test('Magic Missile checks spell block on each impact, never launch, and respects callback invalidation',()=>{
 const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
function LinkLuaModifier()end
function IsServer()return true end
DAMAGE_TYPE_MAGICAL=2;DOTA_PROJECTILE_ATTACHMENT_ATTACK_2=2
DOTA_UNIT_TARGET_HERO=1;DOTA_UNIT_TARGET_BASIC=2;DOTA_UNIT_TARGET_TEAM_ENEMY=3;DOTA_UNIT_TARGET_FLAG_NONE=0;FIND_CLOSEST=1
require('abilities/heroes/vengefulspirit/q')
for _,mode in ipairs({'normal','late_block','expired_block','secondary_block','disjoint','removed_source','removed_target','removed_ability','team_changed','source_dead'})do
 local calls={absorb=0,damage=0,mods=0,sounds=0,searches=0};local shots={};local launched=false
 local c={removed=false,dead=false}
 function c:IsNull()return self.removed end
 function c:IsAlive()assert(not self.removed);return not self.dead end
 function c:GetTeamNumber()assert(not self.removed);return 2 end
 function c:GetAgility()return 100 end
 function c:EmitSound()calls.sounds=calls.sounds+1 end
 function c:HasModifier(name)return name=='modifier_item_aghanims_shard_permanent_buff' end
 function c:GetUnitName()return 'npc_dota_hero_vengefulspirit' end
 local a
 local function unit()
  local t={removed=false,team=3,blocked=mode=='expired_block'}
  function t:IsNull()return self.removed end
  function t:IsAlive()assert(not self.removed);return true end
  function t:GetTeamNumber()assert(not self.removed);return self.team end
  function t:GetAbsOrigin()assert(not self.removed);return {x=90} end
  function t:TriggerSpellAbsorb(ability)
   assert(launched and ability==a,'Block cannot be consumed before flight')
   calls.absorb=calls.absorb+1
   if mode=='removed_source' then c.removed=true elseif mode=='removed_target' then self.removed=true
   elseif mode=='removed_ability' then a.removed=true elseif mode=='team_changed' then self.team=2 end
   return self.blocked
  end
  function t:EmitSound()assert(not self.removed);calls.sounds=calls.sounds+1 end
  function t:AddNewModifier()calls.mods=calls.mods+1;return {} end
  return t
 end
 local first,second=unit(),unit()
 a=setmetatable({removed=false,GetCaster=function()return c end,GetCursorTarget=function()return first end,
 GetLevel=function()return 1 end,GetEffectiveCastRange=function()return 650 end},enfos_vs_magic_missile)
 function a:IsNull()return self.removed end
 function a:GetSpecialValueFor(k)assert(not self.removed);return ({damage=200,stun_duration=2,magic_missile_speed=1350,bounce_range_pct=75})[k] end
 ProjectileManager={CreateTrackingProjectile=function(_,p)shots[#shots+1]=p;return #shots end}
 function FindUnitsInRadius()calls.searches=calls.searches+1;return {first,second}end
 function ApplyDamage(e)calls.damage=calls.damage+1;assert(e.damage==290);return e.damage end
 a:OnSpellStart();assert(#shots==1 and calls.absorb==0 and calls.sounds==1)
 assert(shots[1].iSourceAttachment==DOTA_PROJECTILE_ATTACHMENT_ATTACK_2)
 launched=true
 first.blocked=mode=='late_block';second.blocked=mode=='secondary_block'
 if mode=='source_dead' then c.dead=true end
 local impact=first;if mode=='disjoint' then impact=nil end
 a:OnProjectileHit_ExtraData(impact,nil,shots[1].ExtraData)
 local cancelled=mode=='late_block' or mode=='disjoint' or mode=='removed_source' or mode=='removed_target'
  or mode=='removed_ability' or mode=='team_changed' or mode=='source_dead'
 if cancelled then
  assert(calls.damage==0 and calls.mods==0 and calls.sounds==1 and #shots==1 and calls.searches==0,'Rejected impact cannot stun, damage, emit impact sound or bounce')
 else
  assert(calls.damage==1 and calls.mods==1 and #shots==2 and calls.searches==1)
  a:OnProjectileHit_ExtraData(second,nil,shots[2].ExtraData)
  assert(calls.absorb==2,'Secondary impact must also check spell block')
  assert(calls.damage==(mode=='secondary_block' and 1 or 2))
  assert(#shots==2 and calls.searches==1,'Block must not cause extra bounces')
 end
end
print('Magic Missile impact boundary PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.match(r.stdout,/Magic Missile impact boundary PASS/,r.stderr);
});
