import test from 'node:test';import assert from 'node:assert/strict';import {spawnSync} from 'node:child_process';import fs from 'node:fs';
test('Macropyre snapshots Scepter duration, ordinary pure damage and immunity targeting',()=>{
const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end;function IsServer()return true end
Convars={GetBool=function()return false end};DAMAGE_TYPE_MAGICAL=2;DAMAGE_TYPE_PURE=4;PATTACH_WORLDORIGIN=0;DOTA_UNIT_TARGET_TEAM_ENEMY=2;DOTA_UNIT_TARGET_HERO=1;DOTA_UNIT_TARGET_BASIC=2;DOTA_UNIT_TARGET_FLAG_NONE=0;DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES=16
local mt={};function Vector(x,y,z)return setmetatable({x=x,y=y,z=z or 0},mt)end
mt.__sub=function(a,b)return Vector(a.x-b.x,a.y-b.y,a.z-b.z)end;mt.__add=function(a,b)return Vector(a.x+b.x,a.y+b.y,a.z+b.z)end;mt.__mul=function(a,b)return Vector(a.x*b,a.y*b,a.z*b)end
mt.__index={Length2D=function(v)return math.sqrt(v.x*v.x+v.y*v.y)end,Normalized=function(v)local n=math.sqrt(v.x*v.x+v.y*v.y);return Vector(v.x/n,v.y/n,0)end}
local manager=require('heroes/aghanim_manager');require('abilities/heroes/jakiro/r')
local c={item=true,blessing=false,IsNull=function()return false end,IsAlive=function()return true end,GetTeamNumber=function()return 2 end,GetIntellect=function()return 100 end,GetAbsOrigin=function()return Vector(0,0)end,EmitSound=function()end}
function c:HasItemInInventory(id)return self.item and id=='item_ultimate_scepter'end
function c:HasModifier(id)return self.blessing and id=='modifier_item_ascended_aghanims_blessing_consumed'end
local a=setmetatable({GetCaster=function()return c end,GetLevel=function()return 1 end,IsNull=function()return false end,GetCursorPosition=function()return Vector(1400,0)end,GetSpecialValueFor=function(_,k)return ({duration=10,damage_per_sec=200})[k]or 0 end},enfos_jakiro_macropyre)
local now=0;local target={immune=true,total=0,IsNull=function()return false end,IsAlive=function()return true end,GetTeamNumber=function()return 3 end,IsDebuffImmune=function(self)return self.immune end}
local damageTypes={};function ApplyDamage(info)target.total=target.total+info.damage;damageTypes[#damageTypes+1]=info.damage_type;return info.damage end
local function burn(params)local m=setmetatable({created=now,expiry=now+params.duration},modifier_enfos_jakiro_macropyre_burn)
function m:GetParent()return target end;function m:GetCaster()return c end;function m:GetAbility()return a end;function m:GetElapsedTime()return now-self.created end;function m:GetRemainingTime()return self.expiry-now end;function m:StartIntervalThink()end;function m:SetHasCustomTransmitterData()end;function m:SendBuffRefreshToClients()end
m:OnCreated(params);return m end
function target:AddNewModifier(caster,ability,name,params)self.application=params;self.burn=burn(params)end
local flags;function FindUnitsInLine(team,start,last,cache,radius,tt,types,f)if radius==50 then return {}end;flags=f;return {target}end
ParticleManager={CreateParticle=function()return 1 end,SetParticleControl=function()end}
local params;function CreateModifierThinker(caster,ability,name,p,pos)params=p;return {IsNull=function()return false end}end
local function field(p)local m=setmetatable({GetCaster=function()return c end,GetAbility=function()return a end,GetParent=function()return {IsNull=function()return false end,GetAbsOrigin=function()return Vector(0,0)end}end,GetElapsedTime=function()return now end,StartIntervalThink=function()end},modifier_enfos_jakiro_macropyre_zone);m:OnCreated(p);return m end
a:OnSpellStart();assert(params.duration==15 and params.damage_type==4 and params.pierce==1,'Native Scepter core snapshot missing')
local zone=field(params);assert(flags==16 and target.burn.damage_type==4 and target.burn.pierce)
c.item=false;now=0.5;target.burn:OnIntervalThink();assert(target.total==135 and damageTypes[1]==4,'Losing Scepter cannot rewrite existing pure piercing fire')
local old=target.burn;target.immune=false;now=0.75;old.expiry=1.75;old:OnRefresh({dps=270,damage_type=2,pierce=0,duration=1});assert(target.total==202.5 and damageTypes[2]==4,'Type transition settles old pure slice before switching')
now=1;old:OnIntervalThink();assert(target.total==270 and damageTypes[3]==2)
now=0;a:OnSpellStart();assert(params.duration==10 and params.damage_type==2 and params.pierce==0);target.application=nil;target.immune=true;field(params);assert(flags==0 and not target.application,'Ordinary fire never pierces immunity')
c.blessing=true;a:OnSpellStart();assert(params.duration==15 and params.damage_type==4,'Consumed Blessing retains native upgrade')
local parent={GetUnitName=function()return 'npc_dota_hero_jakiro'end};local generic=setmetatable({GetParent=function()return parent end},modifier_enfos_scepter_upgrade)
local ult={GetAbilityType=function()return DOTA_ABILITY_TYPE_ULTIMATE end};DOTA_ABILITY_TYPE_ULTIMATE=1
assert(generic:IsHidden() and generic:GetModifierSpellAmplify_Percentage({inflictor=ult})==0 and generic:GetModifierPercentageCooldown({ability=ult})==0,'Do not stack obsolete generic Scepter amp/CDR')
parent.GetUnitName=function()return 'npc_dota_hero_lina'end;assert(generic:GetModifierSpellAmplify_Percentage({inflictor=ult})==40 and generic:GetModifierPercentageCooldown({ability=ult})==25,'Unreviewed heroes retain their existing policy')
print('Jakiro R Scepter core PASS')
`;
const input=process.env.JAKIRO_R_SOURCE?script.replace("require('abilities/heroes/jakiro/r')",'assert(load([====['+fs.readFileSync(process.env.JAKIRO_R_SOURCE,'utf8')+']====]))()'):script;
const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input,encoding:'utf8'});assert.equal(r.status,0,r.stderr);assert.match(r.stdout,/Jakiro R Scepter core PASS/,r.stderr);
});
