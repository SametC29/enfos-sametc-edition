import test from 'node:test';import assert from 'node:assert/strict';import fs from 'node:fs';
import {spawnSync,execFileSync} from 'node:child_process';import {parseKV} from '../lib/kv.mjs';
test('Lion travelling Earth Spike snapshots damage, preserves ordinary control and closes finite resources',()=>{
 const baseline=process.env.LION_SPIKE_BASELINE?execFileSync('git',['show','HEAD:game/scripts/vscripts/abilities/heroes/lion/q.lua'],{encoding:'utf8'}):null;
 const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end
local server=true;function IsServer()return server end
local V={};V.__index=V;function Vector(x,y,z)return setmetatable({x=x,y=y,z=z or 0},V)end
function V.__sub(a,b)return Vector(a.x-b.x,a.y-b.y,a.z-b.z)end
function V.__mul(a,b)return Vector(a.x*b,a.y*b,a.z*b)end
function V:Length2D()return math.sqrt(self.x*self.x+self.y*self.y)end
function V:Normalized()local n=self:Length2D();return n>0 and Vector(self.x/n,self.y/n,0) or Vector(0,0,0)end
DOTA_UNIT_TARGET_TEAM_ENEMY=1;DOTA_UNIT_TARGET_HERO=2;DOTA_UNIT_TARGET_BASIC=4;DOTA_UNIT_TARGET_FLAG_NONE=0;DAMAGE_TYPE_MAGICAL=2;PATTACH_WORLDORIGIN=7;MODIFIER_STATE_STUNNED=9
GameRules={GetGameTime=function()return 20 end};Convars={GetBool=function()return false end}
local waves,damages,particles,releases={}, {}, {}, {};local onDamage,onParticle,onSound
function FindUnitsInRadius()error('Earth Spike cannot remain an instantaneous circle scan')end
function ApplyDamage(k)table.insert(damages,k);k.victim.health=k.victim.health-k.damage;if onDamage then onDamage()end;return k.damage end
ProjectileManager={CreateLinearProjectile=function(_,o)table.insert(waves,o);return #waves end}
ParticleManager={CreateParticle=function(_,path,attach,t)assert(attach==7);local id=#particles+1;particles[id]={path=path,t=t};if onParticle then onParticle()end;return id end,
 SetParticleControl=function(_,id,cp,pos)assert(cp==0);particles[id].pos=pos end,
 ReleaseParticleIndex=function(_,id)assert(not releases[id]);releases[id]=true end}
${baseline?`assert(load([==[${baseline}]==]))()`:`require('abilities/heroes/lion/q')`}
local function unit(team)
 local t={team=team,health=100000,int=100,pos=Vector(0,0,0),mods={}}
 function t:IsNull()return self.removed end;function t:IsAlive()return self.health>0 end;function t:GetTeamNumber()return self.team end
 function t:GetAbsOrigin()return self.pos end;function t:GetForwardVector()return Vector(0,1,0)end;function t:GetIntellect()return self.int end
 function t:IsMagicImmune()return self.magic end;function t:IsDebuffImmune()return self.debuff end
 function t:EmitSound(s)assert(s=='Hero_Lion.Impale' or s=='Hero_Lion.ImpaleHitTarget');if onSound then onSound()end end
 function t:AddNewModifier(c,a,n,p)assert(n=='modifier_enfos_lion_earth_spike_stun');self.mods[#self.mods+1]={c=c,a=a,p=p}end
 return t
end
local c=unit(2);local a=setmetatable({cursor=Vector(100,0,200),values={AbilityCastRange=900,width=140,speed=2800,length_buffer=275,damage=120,int_scaling_pct=110,stun_duration=1.2}},enfos_lion_earth_spike)
function a:IsNull()return self.removed end;function a:GetCaster()return c end;function a:GetCursorPosition()return self.cursor end;function a:GetCursorTarget()return self.target end;function a:GetSpecialValueFor(k)return self.values[k] or 0 end
function a:GetCastRange(origin,t)assert(origin==c.pos);return self.values.AbilityCastRange end
a:OnSpellStart();assert(#waves==1 and #damages==0,'Travel must precede impact')
local w=waves[1];assert(w.fDistance==1175 and w.fStartRadius==140 and w.fEndRadius==140 and w.vVelocity.x==2800 and w.vVelocity.z==0)
assert(not w.bDeleteOnHit and not w.bReplaceExisting and not w.bProvidesVision and w.iUnitTargetType==6 and w.iUnitTargetFlags==0)
assert(w.EffectName=='particles/units/heroes/hero_lion/lion_spell_impale.vpcf' and math.abs(w.fExpireTime-(20+1175/2800+0.2))<1e-8)
c.int=900;a.values.damage=480;a.values.stun_duration=2.4;a.cursor=Vector(0,100,0);a:OnSpellStart();assert(w.ExtraData.damage==230 and w.ExtraData.stun_duration==1.2 and waves[2].ExtraData.damage==1470 and waves[2].vVelocity.y==2800)
local normal,boss=unit(3),unit(3);boss.isBoss=true
assert(a:OnProjectileHit_ExtraData(normal,nil,w.ExtraData)==false);assert(a:OnProjectileHit_ExtraData(boss,nil,w.ExtraData)==false)
assert(damages[1].damage==230 and damages[2].damage==230 and normal.mods[1].p.duration==boss.mods[1].p.duration and boss.mods[1].p.duration==1.2)
assert(particles[1].pos==normal.pos and particles[2].pos==boss.pos and releases[1] and releases[2])
for _,mode in ipairs({'friendly','dead','removed','magic','debuff'})do
 local t=unit(mode=='friendly' and 2 or 3);if mode=='dead' then t.health=0 elseif mode=='removed' then t.removed=true elseif mode=='magic' then t.magic=true elseif mode=='debuff' then t.debuff=true end
 local n=#damages;assert(a:OnProjectileHit_ExtraData(t,nil,w.ExtraData)==false and #damages==n and #t.mods==0,mode)
end
local t=unit(3);t.health=1;assert(not a:OnProjectileHit_ExtraData(t,nil,w.ExtraData) and #t.mods==0,'Lethal damage cannot attach stun to corpse')
local t2=unit(3);onDamage=function()t2.removed=true end;a:OnProjectileHit_ExtraData(t2,nil,w.ExtraData);onDamage=nil;assert(#t2.mods==0)
local t3=unit(3);local n=#damages;onParticle=function()a.removed=true end;a:OnProjectileHit_ExtraData(t3,nil,w.ExtraData);onParticle=nil;assert(#damages==n and releases[#particles]);a.removed=false
c.health=0;n=#damages;a:OnProjectileHit_ExtraData(unit(3),nil,w.ExtraData);assert(#damages==n+1,'Valid caster death cannot cancel launched spell');c.health=100
c.removed=true;assert(a:OnProjectileHit_ExtraData(unit(3),nil,w.ExtraData)==true);c.removed=false
assert(a:OnProjectileHit_ExtraData(nil,nil,w.ExtraData)==true and a:OnProjectileHit_ExtraData(unit(3),nil,{})==true)
a.cursor=c.pos;a.target=nil;a:OnSpellStart();assert(waves[#waves].vVelocity.y==2800,'Same-position cast uses horizontal forward')
a.target=unit(3);a.target.pos=Vector(-100,0,1000);a:OnSpellStart();assert(waves[#waves].vVelocity.x==-2800 and waves[#waves].vVelocity.z==0)
a.values.AbilityCastRange=1200;a:OnSpellStart();assert(waves[#waves].fDistance==1475,'Geometry must read the current engine range, not a frozen mirror')
local count=#waves;server=false;a:OnSpellStart();assert(#waves==count and a:OnProjectileHit_ExtraData(unit(3),nil,w.ExtraData)==true);server=true
onSound=function()a.removed=true end;a:OnSpellStart();onSound=nil;assert(#waves==count);a.removed=false
local stun=modifier_enfos_lion_earth_spike_stun;assert(stun:IsDebuff() and not stun:IsPurgable() and stun:IsPurgeException() and stun:GetTexture()=='lion_impale' and stun:CheckState()[9])
print('Lion Spike PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});assert.equal(r.status,0,r.stderr);assert.match(r.stdout,/Lion Spike PASS/);
 const kv=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities.enfos_lion_earth_spike;
 assert.equal(kv.AbilityValues.width,'140');assert.equal(kv.AbilityValues.speed,'2800');assert.equal(kv.AbilityValues.length_buffer,'275');
 assert.ok(!('radius' in kv.AbilityValues)&&!('distance' in kv.AbilityValues));assert.equal(kv.SpellDispellableType,'SPELL_DISPELLABLE_YES_STRONG');
});
