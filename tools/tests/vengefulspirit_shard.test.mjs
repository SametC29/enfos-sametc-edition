import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {execFileSync} from 'node:child_process';

const fixture=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
function LinkLuaModifier()end
function IsServer()return true end
DAMAGE_TYPE_MAGICAL=2;DOTA_UNIT_TARGET_TEAM_ENEMY=3;DOTA_UNIT_TARGET_HERO=1;DOTA_UNIT_TARGET_BASIC=2
DOTA_UNIT_TARGET_FLAG_NONE=0;FIND_CLOSEST=1
require('abilities/heroes/vengefulspirit/q')
local shard=true;local waves={};local searches=0;local damages=0
local c={IsNull=function()return false end,IsAlive=function()return true end,GetTeamNumber=function()return 2 end,
 GetAgility=function()return 100 end,GetUnitName=function()return 'npc_dota_hero_vengefulspirit' end,
 HasModifier=function(_,name)return shard and name=='modifier_item_aghanims_shard_permanent_buff' end,
 EmitSound=function()end}
local function unit(name,hero)
 local u={removed=false,hero=hero,name=name}
 function u:IsNull()return self.removed end
 function u:IsAlive()assert(not self.removed);return true end
 function u:GetTeamNumber()assert(not self.removed);return 3 end
 function u:GetAbsOrigin()assert(not self.removed);return {x=100,y=200,z=0} end
 function u:IsHero()return self.hero end
 function u:GetUnitName()return self.name end
 function u:TriggerSpellAbsorb()return false end
 function u:EmitSound()end
 function u:AddNewModifier()return {} end
 return u
end
local first=unit('first',false);local creep=unit('near_creep',false);local hero=unit('far_hero',true)
local a=setmetatable({GetCaster=function()return c end,GetCursorTarget=function()return first end,GetLevel=function()return 1 end,
 GetEffectiveCastRange=function()return 900 end,GetSpecialValueFor=function(_,k)return k=='damage' and 200 or k=='stun_duration' and 2 or k=='bounce_range_pct' and 75 or 1350 end},enfos_vs_magic_missile)
ProjectileManager={CreateTrackingProjectile=function(_,p)waves[#waves+1]=p;return #waves end}
function FindUnitsInRadius(_,origin,_,radius)searches=searches+1;assert(origin.x==100 and radius==675,'Bounce uses impact origin and modified range');return {first,creep,hero} end
function ApplyDamage(e)damages=damages+1;assert(e.damage==290);e.victim.removed=true;return e.damage end
a:OnSpellStart();assert(#waves==1)
assert(waves[1].ExtraData and waves[1].ExtraData.remaining==1,'Consumed native Shard must authorize one bounce')
shard=false -- Already launched missile keeps its bounded entitlement snapshot.
a:OnProjectileHit_ExtraData(first,nil,waves[1].ExtraData)
assert(damages==1 and searches==1 and #waves==2,'Lethal first impact can bounce without stale target reads')
assert(waves[2].Target==hero and waves[2].vSourceLoc.x==100,'Hero priority and projectile source must be impact point')
assert(waves[2].ExtraData.remaining==0 and waves[2].bDodgeable==true)
a:OnProjectileHit_ExtraData(hero,nil,waves[2].ExtraData)
assert(damages==2 and searches==1 and #waves==2,'Second missile cannot chain indefinitely')
first.removed=false;a:OnSpellStart();assert(waves[3].ExtraData.remaining==0)
a:OnProjectileHit_ExtraData(nil,nil,waves[3].ExtraData);assert(searches==1 and damages==2,'Disjointed missile must not bounce')
local A=require('heroes/aghanim_manager');local m=setmetatable({role='Support',GetParent=function()return c end},modifier_enfos_shard_upgrade)
assert(m:GetModifierHealAmplify_PercentageSource()==0,'Venge Shard must not retain unrelated support heal amp')
local other={GetUnitName=function()return 'npc_dota_hero_omniknight' end};m.GetParent=function()return other end
assert(m:GetModifierHealAmplify_PercentageSource()==25,'Unreviewed Support Shard behavior must be preserved')
print('Venge native Shard bounce PASS')
`;

test('Venge native consumed Shard enables one hero-prioritized bounce even on lethal first impact',()=>{
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:fixture,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.match(r.stdout,/Venge native Shard bounce PASS/,r.stderr);
});
