import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';

test('Wave of Terror travels before damage, snapshots each cast and safely resolves impacts',()=>{
 const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
function LinkLuaModifier()end
local server=true;function IsServer()return server end
local vec={};vec.__index=vec
function Vector(x,y,z)return setmetatable({x=x,y=y,z=z},vec)end
vec.__sub=function(a,b)return Vector(a.x-b.x,a.y-b.y,a.z-b.z)end
vec.__mul=function(a,n)return Vector(a.x*n,a.y*n,a.z*n)end
function vec:Length2D()return math.sqrt(self.x*self.x+self.y*self.y)end
function vec:Normalized()local n=self:Length2D();return Vector(self.x/n,self.y/n,0)end
DAMAGE_TYPE_MAGICAL=2;DOTA_UNIT_TARGET_TEAM_ENEMY=3
DOTA_UNIT_TARGET_HERO=1;DOTA_UNIT_TARGET_BASIC=2;DOTA_UNIT_TARGET_FLAG_NONE=0
GameRules={GetGameTime=function()return 50 end}
require('abilities/heroes/vengefulspirit/w')
local calls={damage=0,mods=0};local waves={}
local c={removed=false,agi=100}
function c:IsNull()return self.removed end
function c:IsAlive()return true end
function c:GetAbsOrigin()return Vector(120,300,40)end
function c:GetForwardVector()return Vector(1,0,0)end
function c:GetTeamNumber()return 2 end
function c:GetAgility()return self.agi end
function c:EmitSound()end
local specials={damage=100,duration=8,armor_reduction=4,attack_reduction=15,wave_distance=1400,wave_speed=2000,wave_width=325,vision_aoe=350,vision_duration=4}
local a=setmetatable({GetCaster=function()return c end,GetCursorPosition=function()return c:GetAbsOrigin()end,
 GetSpecialValueFor=function(_,k)return specials[k] or 0 end,GetLevel=function()return 1 end},enfos_vs_wave_of_terror)
ProjectileManager={CreateLinearProjectile=function(_,p)waves[#waves+1]=p;return #waves end}
ParticleManager={CreateParticle=function()error('Projectile owns effect; no separate fake wave')end}
function FindUnitsInRadius()error('No instantaneous radius scan')end
function ApplyDamage(e)calls.damage=calls.damage+1;assert(e.damage==160,'Cast snapshot lost');if calls.lethal then e.victim.dead=true end;return e.damage end
a:OnSpellStart()
assert(calls.damage==0 and #waves==1,'Damage must wait for traveling wave impact')
local p=waves[1]
assert(p.vVelocity.x==2000 and p.vVelocity.y==0 and p.vVelocity.z==0,'Zero aim must preserve horizontal facing')
assert(p.fDistance==1400 and p.fStartRadius==325 and p.fEndRadius==325)
assert(p.bDeleteOnHit==false and p.bReplaceExisting==false)
assert(p.ExtraData.attack_reduction==15,'Native W attack reduction must be captured at cast')
assert(p.bProvidesVision==true and p.iVisionRadius==350 and p.iVisionTeamNumber==2,'Wave must grant caster-team vision')
local viewers={}
function AddFOWViewer(team,location,radius,duration,blocked)
 viewers[#viewers+1]={team=team,location=location,radius=radius,duration=duration,blocked=blocked}
end
a:OnProjectileThink_ExtraData(Vector(300,300,40),p.ExtraData)
assert(#viewers==1 and viewers[1].team==2 and viewers[1].radius==350 and viewers[1].duration==4 and viewers[1].blocked==false)
specials.vision_aoe=900;specials.vision_duration=20
a:OnProjectileThink_ExtraData(Vector(500,300,40),p.ExtraData)
assert(viewers[2].radius==350 and viewers[2].duration==4,'In-flight vision keeps its cast snapshot')
server=false;a:OnProjectileThink_ExtraData(Vector(600,300,40),p.ExtraData);assert(#viewers==2,'Client must not create vision')
server=true;a:OnProjectileThink_ExtraData(nil,p.ExtraData);a:OnProjectileThink_ExtraData(Vector(600,300,40),{});assert(#viewers==2)
assert(p.EffectName=='particles/units/heroes/hero_vengeful/vengeful_wave_of_terror.vpcf')
local t={team=3,removed=false,dead=false,isBoss=true}
function t:IsNull()return self.removed end
function t:IsAlive()assert(not self.removed);return not self.dead end
function t:GetTeamNumber()assert(not self.removed);return self.team end
function t:AddNewModifier(_,_,name,data)assert(not self.removed and not self.dead);assert(name=='modifier_enfos_vs_wave_debuff');assert(data.duration==8 and data.armor_reduction==4 and data.attack_reduction==15);calls.mods=calls.mods+1 end
c.agi=900;specials.damage=900;specials.armor_reduction=12;specials.attack_reduction=25;a:OnSpellStart()
assert(#waves==2 and waves[2].ExtraData.damage~=p.ExtraData.damage,'Recast requires independent snapshot')
assert(a:OnProjectileHit_ExtraData(t,nil,p.ExtraData)==false)
assert(calls.damage==1 and calls.mods==1,'Ordinary Boss impact must continue through target')
calls.lethal=true;a:OnProjectileHit_ExtraData(t,nil,p.ExtraData);assert(calls.damage==2 and calls.mods==1,'No debuff after lethal impact')
t.dead=false;t.team=2;a:OnProjectileHit_ExtraData(t,nil,p.ExtraData);assert(calls.damage==2)
t.team=3;t.removed=true;a:OnProjectileHit_ExtraData(t,nil,p.ExtraData);assert(calls.damage==2)
assert(a:OnProjectileHit_ExtraData(nil,nil,p.ExtraData)==true,'Destination closes projectile')
c.removed=true;a:OnProjectileHit_ExtraData(t,nil,p.ExtraData);assert(calls.damage==2)
server=false;c.removed=false;a:OnSpellStart();assert(#waves==2)
local armor=setmetatable({count=0,GetAbility=function()return a end,
 GetParent=function()return t end,SetStackCount=function(self,n)self.count=n end,
 SetHasCustomTransmitterData=function(_,enabled)assert(enabled)end,
 SendBuffRefreshToClients=function()calls.sends=(calls.sends or 0)+1 end,
 GetStackCount=function(self)return self.count end},modifier_enfos_vs_wave_debuff)
server=true;armor:OnCreated({armor_reduction=4,attack_reduction=15})
local client=setmetatable({},modifier_enfos_vs_wave_debuff)
client:HandleCustomTransmitterData(armor:AddCustomTransmitterData())
server=false;assert(armor:GetModifierPhysicalArmorBonus()==-4,'Client reads replicated armor snapshot, not later rank')
assert(client:GetModifierDamageOutgoing_Percentage()==-15,'Client receives cast snapshot, not current rank')
server=true;armor:OnRefresh({armor_reduction=12,attack_reduction=25})
client:HandleCustomTransmitterData(armor:AddCustomTransmitterData())
server=false;assert(armor:GetModifierPhysicalArmorBonus()==-12,'Refresh replaces replicated armor value')
assert(client:GetModifierDamageOutgoing_Percentage()==-25 and calls.sends==1,'Refresh transmits the new attack reduction')
armor:OnRefresh({armor_reduction=99,attack_reduction=99});assert(calls.sends==1,'Client cannot refresh authoritative stats')
assert(armor:IsDebuff() and armor:IsPurgable())
PATTACH_ABSORIGIN_FOLLOW=1
assert(armor:GetEffectName()=='particles/units/heroes/hero_vengeful/vengeful_wave_of_terror_recipient.vpcf')
assert(armor:GetEffectAttachType()==PATTACH_ABSORIGIN_FOLLOW,'Modifier-owned native root follows target origin')
print('Vengeful Spirit traveling wave PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.match(r.stdout,/Vengeful Spirit traveling wave PASS/,r.stderr);
});
