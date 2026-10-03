import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync,execFileSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';
test('Frost baseline linked rank and native first four values',()=>{
 const source=process.env.JAKIRO_FROST_BASELINE ? execFileSync('git',['show','HEAD:game/scripts/npc/npc_abilities_custom.txt'],{encoding:'utf8'}) : fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8');
 const kv=parseKV(source).DOTAAbilities;
 const a=kv.enfos_jakiro_liquid_frost;assert.ok(a);assert.equal(a.MaxLevel,'10');assert.match(a.AbilityBehavior,/NOT_LEARNABLE/);assert.doesNotMatch(a.AbilityUnitTargetType,/BUILDING/);
 const v=a.AbilityValues;for(const k of ['impact_damage','bonus_damage']){assert.deepEqual(v[k].split(' ').slice(0,4),['8','16','24','32']);assert.equal(v[k].split(' ').length,10);}
 assert.deepEqual(v.movement_slow.split(' ').slice(0,4),['15','20','25','30']);assert.equal(v.duration,'5');
 const heroes=parseKV(fs.readFileSync('game/scripts/npc/npc_heroes_custom.txt','utf8')).DOTAHeroes;assert.equal(heroes.npc_dota_hero_jakiro.Ability6,'enfos_jakiro_liquid_frost');assert.equal(heroes.npc_dota_hero_jakiro.Ability5,'enfos_jakiro_double_trouble');
});
test('Paired Frost ranks, resources, per-instance damage and lifecycle',()=>{
 const script=String.raw`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end;function LinkLuaModifier()end
local server=true;function IsServer()return server end;Convars={GetBool=function()return false end}
DAMAGE_TYPE_MAGICAL=2;DOTA_DAMAGE_FLAG_REFLECTION=16;PATTACH_WORLDORIGIN=1;bit={band=function(a,b)return a & b end}
require('abilities/heroes/jakiro/e_frost');local pair=require('abilities/heroes/jakiro/e_pair')
local c={mods={},abilities={},alive=true};function c:IsNull()return self.removed end;function c:GetUnitName()return 'npc_dota_hero_jakiro' end;function c:IsAlive()return self.alive end;function c:IsIllusion()return false end;function c:GetTeamNumber()return 2 end
function c:HasModifier(n)return self.mods[n]end;function c:FindAbilityByName(n)return self.abilities[n]end
local function ability(id,prototype)
 local a=setmetatable({id=id,rank=0,cd=0,hidden=false,activated=true,spent=0},prototype)
 function a:IsNull()return self.removed end;function a:GetCaster()return c end;function a:GetAbilityName()return self.id end;function a:GetLevel()return self.rank end;function a:SetLevel(n)self.rank=n end
 function a:IsHidden()return self.hidden end;function a:SetHidden(b)self.hidden=b end;function a:IsActivated()return self.activated end;function a:SetActivated(b)self.activated=b end
 function a:GetCooldownTimeRemaining()return self.cd end;function a:StartCooldown(n)self.cd=n end
 function a:GetAutoCastState()return self.auto end;function a:IsFullyCastable()return self.rank>0 and self.cd==0 end
 function a:UseResources(m,h,g,cd)assert(m and not h and not g and cd);self.spent=self.spent+1;self.cd=12 end
 function a:GetSpecialValueFor(n)return ({impact_damage=8,bonus_damage=8,movement_slow=15,duration=5})[n]end
 return a
end
local fire=ability('enfos_jakiro_liquid_fire',enfos_jakiro_liquid_fire);c.abilities[fire.id]=fire
local added=0;function c:AddAbility(id)assert(id==pair.frost);added=added+1;local a=ability(id,enfos_jakiro_liquid_frost);self.abilities[id]=a;return a end
assert(pair.Reconcile(c));local frost=c.abilities[pair.frost];assert(added==1 and frost.rank==0 and frost.hidden and not frost.activated)
for rank=1,10 do fire.rank=rank;assert(pair.Reconcile(c));assert(frost.rank==rank and not frost.hidden and frost.activated)end
for i=1,100 do pair.Reconcile(c)end;assert(added==1)
frost.hidden=true;frost.activated=false;pair.Reconcile(c);assert(not frost.hidden and frost.activated)
fire.rank=0;pair.Reconcile(c);assert(frost.rank==0 and frost.hidden and not frost.activated);fire.rank=10;pair.Reconcile(c)
fire.cd=0;frost.cd=7;pair.Reconcile(c);assert(fire.cd==7 and frost.cd==7)
local ordinaryStart=fire.StartCooldown;fire.cd=0
function fire:StartCooldown(n)ordinaryStart(self,n);frost.removed=true end
assert(not pair.Reconcile(c),'Cooldown callback invalidation cannot dereference a removed peer or claim restore')
fire.StartCooldown=ordinaryStart;frost.removed=false
c.mods.modifier_item_aghanims_shard_permanent_buff=true;fire.cd=2;frost.cd=9;pair.Reconcile(c);assert(fire.cd==2 and frost.cd==9)
fire.cd=12;pair.MirrorCooldown(fire);assert(frost.cd==9);frost.cd=4;pair.MirrorCooldown(frost);assert(fire.cd==12)
c.mods={};pair.Reconcile(c);assert(fire.cd==12 and frost.cd==12)
local t={alive=true,team=3,origin={x=55,y=6,z=0}};function t:IsNull()return self.removed end;function t:IsAlive()return self.alive end;function t:GetTeamNumber()return self.team end;function t:IsBuilding()return self.building end;function t:IsDebuffImmune()return self.immune end;function t:GetAbsOrigin()return self.origin end;function t:EmitSound(n)assert(n=='Hero_Jakiro.LiquidFire')end
local fm=setmetatable({GetParent=function()return c end,GetAbility=function()return fire end},modifier_enfos_jakiro_liquid_fire_passive);fm:OnCreated()
local im=setmetatable({GetParent=function()return c end,GetAbility=function()return frost end},modifier_enfos_jakiro_liquid_frost_orb);im:OnCreated()
function fire:SnapshotImpact()return {}end
fire.cd=0;frost.cd=0;fire.auto=true;frost.auto=true
fm:OnAttack({attacker=c,target=t,record=11});im:OnAttack({attacker=c,target=t,record=11});assert(fire.spent==1 and frost.spent==0 and fm.records[11] and not im.records[11]);fm:OnAttackFail({attacker=c,record=11})
c.mods.modifier_item_aghanims_shard_permanent_buff=true;fire.cd=0;frost.cd=0
fm:OnAttack({attacker=c,target=t,record=12});im:OnAttack({attacker=c,target=t,record=12});assert(fire.spent==2 and frost.spent==1 and fm.records[12] and im.records[12])
local particles=0;local releases=0;local controls={};ParticleManager={CreateParticle=function(_,path,attach,target)assert(path=='particles/units/heroes/hero_jakiro/jakiro_base_attack_frost_explosion.vpcf' and attach==1 and target==t);particles=particles+1;return particles end,SetParticleControl=function(_,p,cp,pos)assert((cp==0 or cp==1 or cp==3) and pos==t.origin);controls[cp]=true end,ReleaseParticleIndex=function()releases=releases+1 end}
local total=0;local mod;function ApplyDamage(info)assert(info.damage_type==2 and info.attacker==c and info.ability==frost);total=total+info.damage;if mod then mod:OnTakeDamage({unit=t,attacker=c,inflictor=frost,damage=info.damage})end;return info.damage end
function t:AddNewModifier(caster,ability,name,p)assert(caster==c and ability==frost and name=='modifier_enfos_jakiro_liquid_frost_debuff' and p.duration==5);self.params=p end
im:OnAttackLanded({attacker=c,target=t,record=12});im:OnAttackLanded({attacker=c,target=t,record=12});assert(total==8 and particles==1 and releases==1 and t.params.bonus==8 and controls[0] and controls[1] and controls[3])
mod=setmetatable({GetParent=function()return t end,GetCaster=function()return c end,GetAbility=function()return frost end,SetHasCustomTransmitterData=function()end,SendBuffRefreshToClients=function()end},modifier_enfos_jakiro_liquid_frost_debuff);mod:OnCreated(t.params)
assert(mod:GetModifierMoveSpeedBonus_Percentage()==-15 and mod:OnTooltip()==8 and mod:IsPurgable())
mod:OnTakeDamage({unit=t,attacker=c,damage=50});assert(total==16)
mod:OnTakeDamage({unit=t,attacker=c,inflictor={},damage=11});assert(total==24)
for _,keys in ipairs({{unit=t,attacker=c,inflictor=frost,damage=8},{unit=t,attacker={},damage=8},{unit=t,attacker=c,damage=0},{unit=t,attacker=c,damage=3,damage_flags=16},{unit={},attacker=c,damage=8}})do mod:OnTakeDamage(keys)end;assert(total==24)
t.isBoss=true;mod:OnTakeDamage({unit=t,attacker=c,damage=11});assert(total==32,'Boss formula is unchanged')
t.immune=true;mod:OnTakeDamage({unit=t,attacker=c,damage=50});assert(total==32 and mod:GetModifierMoveSpeedBonus_Percentage()==0);t.immune=false
mod:OnRefresh({slow=60,bonus=80});mod:OnTakeDamage({unit=t,attacker=c,damage=1});assert(total==112 and mod:OnTooltip()==80)
frost.removed=true;mod:OnTakeDamage({unit=t,attacker=c,damage=1});assert(total==112 and mod:GetModifierMoveSpeedBonus_Percentage()==0);frost.removed=false
c.removed=true;mod:OnTakeDamage({unit=t,attacker=c,damage=1});assert(total==112 and mod:GetModifierMoveSpeedBonus_Percentage()==0);c.removed=false
server=false;mod:HandleCustomTransmitterData({slow=55,bonus=72});assert(mod:GetModifierMoveSpeedBonus_Percentage()==-55 and mod:OnTooltip()==72);mod:OnTakeDamage({unit=t,attacker=c,damage=1});assert(total==112);server=true
mod:OnDestroy();mod:OnTakeDamage({unit=t,attacker=c,damage=1});assert(total==112 and not mod.OnIntervalThink)
t.building=true;assert(not frost:FireAt(t));im:OnAttack({attacker=c,target=t,record=20});assert(not im.records[20]);t.building=false
for _,mode in ipairs({'immune','dead','removed','friendly'})do if mode=='immune'then t.immune=true elseif mode=='dead'then t.alive=false elseif mode=='removed'then t.removed=true else t.team=2 end;assert(not frost:FireAt(t));t.immune=false;t.alive=true;t.removed=false;t.team=3 end
-- The engine already funded a manual Frost cast. Shared cooldown blocks Fire before callbacks.
function frost:GetCursorTarget()return t end
c.mods={};fire.cd=0;frost.cd=6;frost.auto=false
function c:PerformAttack(target,a,b,d,e,f,g,h)assert(target==t and a and b and not d and not e and f and not g and not h);im:OnAttack({attacker=c,target=t,record=13});fm:OnAttack({attacker=c,target=t,record=13})end
frost:OnSpellStart();assert(im.records[13] and not fm.records[13] and fire.cd==6 and frost.spent==1 and not frost.manual_target);im:OnAttackRecordDestroy({attacker=c,record=13});assert(not im.records[13])
server=false;assert(not pair.Reconcile(c));pair.MirrorCooldown(fire);assert(not frost:FireAt(t));server=true
local upgrade=setmetatable({GetParent=function()return c end,role='Support'},modifier_enfos_shard_upgrade);assert(upgrade:GetModifierHealAmplify_PercentageSource()==0 and upgrade:IsHidden())
function c:GetUnitName()return 'npc_dota_hero_omniknight' end;assert(upgrade:GetModifierHealAmplify_PercentageSource()==25)
print('Jakiro paired Frost PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});assert.equal(r.status,0,r.stderr);assert.match(r.stdout,/Jakiro paired Frost PASS/,r.stderr);
});
