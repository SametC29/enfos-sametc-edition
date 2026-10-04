import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';
import {isVerifiedNativeAbility} from '../lib/native_hero_abilities.mjs';
const all=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
const source=JSON.parse(fs.readFileSync('docs/audit/DRAGON_KNIGHT_NATIVE_SOURCE_2026-10-04.json','utf8'));
const setup=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
local server=true;function IsServer()return server end
LUA_MODIFIER_MOTION_NONE=0;function LinkLuaModifier(n,p)assert((n=='modifier_enfos_dk_native_scaling' or n=='modifier_enfos_dk_wyrm_vigor_passive') and p=='abilities/heroes/dragon_knight/modifiers')end
package.loaded['lib/hero_trace']={Log=function()end}
local hero={null=false,real=true,illusion=false,name='npc_dota_hero_dragon_knight',str=80,
IsNull=function(self)return self.null end,IsRealHero=function(self)return self.real end,IsIllusion=function(self)return self.illusion end,
GetUnitName=function(self)return self.name end,GetStrength=function(self,...)assert(select('#',...)==0);return self.str end,
IsAlive=function()error('server-only getter')end,AddAbility=function()error('unneeded provider')end,
SetAbilityPoints=function()error('points mutation')end}
local q={rank=0,null=false,IsNull=function(self)return self.null end,GetCaster=function()return hero end,
GetAbilityName=function()return 'enfos_dk_breathe_fire'end,GetLevel=function(self)return self.rank end,
GetSpecialValueFor=function()error('recursive raw query')end,
GetLevelSpecialValueNoOverride=function(self,key,rank)assert(rank==math.min(10,self.rank)-1);if key=='strength_factor' then return 1.2 end;assert(key=='damage');return 120+rank*60 end}
local mods=0;hero.FindAbilityByName=function(_,id)if id=='enfos_dk_breathe_fire' then return q end end
hero.HasModifier=function(self,id)assert(id=='modifier_enfos_dk_native_scaling');return self.mod~=nil end
hero.AddNewModifier=function(self,c,a,id)assert(server and c==hero and a==q and id=='modifier_enfos_dk_native_scaling');mods=mods+1
 self.mod=setmetatable({IsNull=function()return false end,GetParent=function()return hero end},{__index=modifier_enfos_dk_native_scaling});return self.mod end
local integration=require('abilities/heroes/dragon_knight/integration')
`;
function lua(body){const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:setup+body,encoding:'utf8'});assert.equal(r.status,0,r.stderr);assert.equal(r.stderr,'');}

const formSetup=`
require('abilities/heroes/dragon_knight/r')
local r=setmetatable({rank=0,null=false,refunds=0,ends=0,
IsNull=function(self)return self.null end,GetCaster=function()return hero end,
GetAbilityName=function()return 'enfos_dk_elder_dragon_form'end,GetLevel=function(self)return self.rank end,
GetLevelSpecialValueNoOverride=function(self,key,rank)assert(rank==self.rank-1);return assert(({duration={30,33,36,40,43,46,50,53,56,60},bonus_attack_damage={30,40,50,60,70,80,90,100,110,120}})[key])[rank+1]end,
GetCooldownTimeRemaining=function()return 42 end,EndCooldown=function(self)self.ends=self.ends+1 end,
RefundManaCost=function(self)self.refunds=self.refunds+1 end},{__index=enfos_dk_elder_dragon_form})
local form,fireball;local grants,writes,casts,cooldowns=0,0,0,0
local find=hero.FindAbilityByName
hero.FindAbilityByName=function(_,id)if id=='enfos_dk_elder_dragon_form'then return r elseif id=='dragon_knight_elder_dragon_form'then return form elseif id=='dragon_knight_fireball'then return fireball else return find(hero,id)end end
hero.IsAlive=function()assert(server);return not hero.dead end
hero.AddAbility=function(_,id)assert(server);grants=grants+1
local a={rank=0,null=false,IsNull=function(self)return self.null end,GetCaster=function()return hero end,
GetAbilityName=function()return id end,GetLevel=function(self)return self.rank end,
SetLevel=function(self,rank)assert(rank>=0 and rank<=(id=='dragon_knight_fireball'and 1 or 3));writes=writes+1;self.rank=rank end,
SetHidden=function(self,v)self.hidden=v end,SetActivated=function(self,v)self.active=v end,
OnSpellStart=function(self)assert(server);casts=casts+1;if self.invalidate then self.null=true end end,
StartCooldown=function(self,v)assert(v==42);cooldowns=cooldowns+1 end,
UseResources=function()error('second resource charge')end}
if id=='dragon_knight_elder_dragon_form'then form=a elseif id=='dragon_knight_fireball'then fireball=a else error(id)end;return a end
`;

test('R uses a capped native form provider, preserves ten paid ranks and delegates exactly one server cast without double costs',()=>lua(formSetup+`
assert(integration.Restore(hero));assert(form.rank==0 and form.hidden and not form.active and grants==1)
for rank=1,10 do r.rank=rank;assert(integration.Restore(hero));assert(form.rank==math.min(3,rank) and r.rank==rank)end
local count=writes;assert(integration.Restore(hero));assert(writes==count and grants==1 and casts==0 and cooldowns==0)
r:OnSpellStart();assert(casts==1 and cooldowns==1 and r.refunds==0)
server=false;r:OnSpellStart();r:OnUpgrade();assert(casts==1 and cooldowns==1);server=true
hero.dead=true;r:OnSpellStart();assert(casts==1 and r.refunds==1 and r.ends==1);hero.dead=false
form.invalidate=true;r:OnSpellStart();assert(casts==2 and cooldowns==1)
`));

test('R raw tuning covers ten ranks on both contexts without overriding native tier/Scepter fields or suppressing active casts under Break',()=>lua(formSetup+`
assert(integration.Restore(hero));local m=hero.mod;local p={ability=form,ability_special_value='duration'}
assert(m:GetModifierOverrideAbilitySpecial(p)==1 and m:GetModifierOverrideAbilitySpecialValue(p)==0)
for _,context in ipairs({true,false})do server=context;for rank=1,10 do r.rank=rank;assert(m:GetModifierOverrideAbilitySpecialValue(p)==r:GetLevelSpecialValueNoOverride('duration',rank-1));p.ability_special_value='bonus_attack_damage';assert(m:GetModifierOverrideAbilitySpecialValue(p)==30+(rank-1)*10);p.ability_special_value='duration'end end
hero.broken=true;assert(m:GetModifierOverrideAbilitySpecialValue(p)==60)
for _,key in ipairs({'scepter_bonus_levels','frost_duration','magic_resistance','bonus_ability_cast_range'})do p.ability_special_value=key;assert(m:GetModifierOverrideAbilitySpecial(p)==0)end
p.ability_special_value='duration';r.null=true;assert(m:GetModifierOverrideAbilitySpecialValue(p)==0);r.null=false
r.GetCaster=function()return {}end;assert(m:GetModifierOverrideAbilitySpecialValue(p)==0);r.GetCaster=function()return hero end
form.GetCaster=function()return {}end;assert(m:GetModifierOverrideAbilitySpecial(p)==0)
`));

test('Shard Fireball reconciles grant/loss/reconnect without a duplicate provider, rank write or cooldown reset and respects owned/server guards',()=>lua(formSetup+`
assert(integration.ReconcileFireball(hero,false) and grants==0)
assert(integration.ReconcileFireball(hero,true));assert(grants==1 and fireball.rank==1 and not fireball.hidden and fireball.active)
for i=1,3 do assert(integration.ReconcileFireball(hero,true))end;assert(grants==1 and writes==1 and cooldowns==0)
assert(integration.ReconcileFireball(hero,false));assert(fireball.hidden and not fireball.active and fireball.rank==1)
assert(integration.ReconcileFireball(hero,true));assert(grants==1 and writes==1 and cooldowns==0)
server=false;assert(not integration.ReconcileFireball(hero,true));server=true
hero.illusion=true;assert(not integration.ReconcileFireball(hero,true));hero.illusion=false
hero.name='npc_dota_hero_axe';assert(not integration.ReconcileFireball(hero,true));hero.name='npc_dota_hero_dragon_knight'
r.GetCaster=function()return {}end;assert(not integration.ReconcileFireball(hero,true));r.GetCaster=function()return hero end
fireball.GetCaster=function()return {}end;assert(not integration.ReconcileFireball(hero,true))
`));

test('R source retains native tier data and has no copied form/proc/cleanup or misleading generic upgrade tooltips',()=>{
 const r=all.enfos_dk_elder_dragon_form,n=source.abilities.dragon_knight_elder_dragon_form;
 assert.equal(r.MaxLevel,'10');assert.equal(r.RequiredLevel,'5');assert.equal(r.LevelsBetweenUpgrades,'5');assert.equal(r.ScriptFile,'abilities/heroes/dragon_knight/r');
 assert.equal(n.MaxLevel,'3');assert.equal(n.AbilityValues.scepter_bonus_levels,'1');
 assert.deepEqual(Object.keys(r.AbilityValues).sort(),['bonus_attack_damage','duration']);
 assert.equal(all.dragon_knight_elder_dragon_form,undefined);assert.equal(all.dragon_knight_fireball,undefined);
 const kits=fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8');assert.doesNotMatch(kits,/modifier_enfos_dk_(elder_dragon_form_buff|frost)|enfos_dk_elder_dragon_form=class/);
 for(const lang of ['english','turkish','russian','schinese']){const t=JSON.parse(fs.readFileSync('localization/'+lang+'.json','utf8')).Tokens;
 for(const suffix of ['Description','SummaryDescription'])for(const key of ['duration','bonus_attack_damage'])assert.ok(t['DOTA_Tooltip_Ability_enfos_dk_elder_dragon_form_'+suffix].includes('{{'+key+'}}'));
 assert.ok(t.DOTA_Tooltip_Ability_enfos_dk_elder_dragon_form_shard_description);assert.equal(t.DOTA_Tooltip_Ability_enfos_dk_wyrm_vigor_shard_description,undefined);
 }
});

test('Existing Aghanim reconciliation detects native DK Shard, restores Fireball and suppresses only owned DK generic bonuses',()=>lua(formSetup+`
LinkLuaModifier=function()end;package.loaded['lib/log']={Info=function()end}
local manager=require('heroes/aghanim_manager');local has=false
hero.HasModifier=function()return has end;hero.HasScepter=function()return false end
manager.OnShardAcquired=function()end;manager.OnShardLost=function()end
assert(not manager:HasShard(hero));has=true;assert(manager:HasShard(hero))
manager:UpdateHeroAghanimState(hero,'Tank');assert(fireball and fireball.active and grants==1)
manager:UpdateHeroAghanimState(hero,'Tank');assert(grants==1 and writes==1)
has=false;manager:UpdateHeroAghanimState(hero,'Tank');assert(fireball.hidden and not fireball.active)
local s=setmetatable({GetParent=function()return hero end},{__index=modifier_enfos_scepter_upgrade})
local shard=setmetatable({role='Tank',GetParent=function()return hero end},{__index=modifier_enfos_shard_upgrade})
assert(s:IsHidden() and s:GetModifierSpellAmplify_Percentage({})==0 and s:GetModifierPercentageCooldown({})==0)
assert(shard:IsHidden() and shard:GetModifierHealthBonus()==0);shard:OnTakeDamage({})
hero.name='npc_dota_hero_axe';hero.FindAbilityByName=function()return nil end
DOTA_ABILITY_TYPE_ULTIMATE=1;local ult={GetAbilityType=function()return 1 end}
assert(s:GetModifierSpellAmplify_Percentage({inflictor=ult})==40 and s:GetModifierPercentageCooldown({ability=ult})==25)
assert(shard:GetModifierHealthBonus()==350)
`));

test('R automatic Health reports native form/Fireball queries without a cast, provider restore or cooldown change',()=>lua(formSetup+`
r.rank=10;assert(integration.Restore(hero));assert(integration.ReconcileFireball(hero,true))
hero.GetLevel=function()return 50 end;hero.GetAbilityPoints=function()return 0 end
q.GetSpecialValueFor=function()return 0 end
form.GetSpecialValueFor=function(_,key)return assert(({duration=60,bonus_attack_damage=120,scepter_bonus_levels=1})[key])end
hero.AddAbility=function()error('Health grant')end;local out={};print=function(s)out[#out+1]=s end
assert(require('heroes/health').Report(hero,0));local joined=table.concat(out,'|')
assert(joined:find('ability=dragon_knight_elder_dragon_form rank=3',1,true))
assert(joined:find('native_form_duration_query=60 native_form_bonus_damage_query=120 native_form_scepter_levels_query=1',1,true))
assert(joined:find('ability=dragon_knight_fireball rank=1',1,true));assert(casts==0 and cooldowns==0)
`));

const bloodSetup=`
local armor={6,8,10,12,14,16,18,20,22,24};local regen={10,13,17,20,23,27,30,33,37,40}
local e={rank=0,null=false,IsNull=function(self)return self.null end,GetCaster=function()return hero end,
GetLevel=function(self)return self.rank end,GetSpecialValueFor=function()error('recursive E read')end,
GetLevelSpecialValueNoOverride=function(self,key,rank)assert(rank==math.min(10,self.rank)-1);if key=='strength_regen_factor' then return .05 end;return assert(({armor=armor,health_regen=regen})[key])[rank+1]end}
local native,adds,rankWrites,refreshes=nil,0,0,0
local intrinsic={IsNull=function()return false end,ForceRefresh=function()assert(server);refreshes=refreshes+1 end}
hero.PassivesDisabled=function(self)return self.broken or false end
hero.FindAbilityByName=function(_,id)if id=='enfos_dk_breathe_fire'then return q elseif id=='enfos_dk_dragon_blood'then return e elseif id=='dragon_knight_dragon_blood'then return native end end
hero.FindModifierByName=function(_,name)assert(name=='fixture_native_blood');return intrinsic end
hero.AddAbility=function(_,id)assert(server and id=='dragon_knight_dragon_blood');adds=adds+1
native={rank=0,IsNull=function()return false end,GetCaster=function()return hero end,GetAbilityName=function()return 'dragon_knight_dragon_blood'end,
GetLevel=function(self)return self.rank end,SetLevel=function(self,rank)assert(rank==1);rankWrites=rankWrites+1;self.rank=rank end,
SetHidden=function(self,v)assert(v);self.hidden=v end,SetActivated=function(self,v)self.active=v end,
GetIntrinsicModifierName=function()return 'fixture_native_blood'end};return native end
`;
const wrathSetup=bloodSetup+`
local magic={10,13,17,20,23,27,30,33,37,40};local mr={10,12,13,15,17,18,20,22,23,25}
local d={rank=0,null=false,IsNull=function(self)return self.null end,GetCaster=function()return hero end,
GetAbilityName=function()return 'enfos_dk_wyrm_vigor'end,GetLevel=function(self)return self.rank end,
GetSpecialValueFor=function()error('recursive D read')end,
GetLevelSpecialValueNoOverride=function(self,key,rank)assert(rank==math.min(10,self.rank)-1)
 if key=='magic_damage'then return magic[rank+1] elseif key=='bonus_aoe'then return 30+10*rank elseif key=='magic_resist'then return mr[rank+1] elseif key=='bonus_strength'then return 10+5*rank end;error(key)end}
local wrath,dAdds,dRankWrites,dRefreshes=nil,0,0,0
local di={IsNull=function()return false end,ForceRefresh=function()assert(server);dRefreshes=dRefreshes+1 end}
local find,add,findmod=hero.FindAbilityByName,hero.AddAbility,hero.FindModifierByName
hero.FindAbilityByName=function(_,id)if id=='enfos_dk_wyrm_vigor'then return d elseif id=='dragon_knight_wyrms_wrath'then return wrath else return find(hero,id)end end
hero.FindModifierByName=function(_,name)if name=='fixture_native_wrath'then return di else return findmod(hero,name)end end
hero.AddAbility=function(_,id)if id~='dragon_knight_wyrms_wrath'then return add(hero,id)end;assert(server);dAdds=dAdds+1
 wrath={rank=0,IsNull=function()return false end,GetCaster=function()return hero end,GetAbilityName=function()return 'dragon_knight_wyrms_wrath'end,
GetLevel=function(self)return self.rank end,SetLevel=function(self,rank)assert(rank==0 or rank==1);dRankWrites=dRankWrites+1;self.rank=rank end,
SetHidden=function(self,v)assert(v);self.hidden=v end,SetActivated=function(self,v)self.active=v end,
GetIntrinsicModifierName=function()return 'fixture_native_wrath'end};return wrath end
`;

test('Wyrm Vigor preserves free paid D gates/defense and forwards exact native attack/AoE keys without a copied proc',()=>{
 const d=all.enfos_dk_wyrm_vigor,n=source.abilities.dragon_knight_wyrms_wrath;
 assert.equal(d.AbilityUnitDamageType,n.AbilityUnitDamageType);
 assert.equal(d.BaseClass,'ability_lua');assert.equal(d.ScriptFile,'abilities/heroes/dragon_knight/d');assert.equal(d.Innate,undefined);assert.equal(d.RequiredLevel,'1');assert.equal(d.LevelsBetweenUpgrades,'1');assert.equal(d.MaxLevel,'10');assert.equal(d.IsBreakable,n.IsBreakable);assert.equal(all.dragon_knight_wyrms_wrath,undefined);assert.equal(n.MaxLevel,'4');
 assert.equal(d.AbilityValues.magic_resist,'10 12 13 15 17 18 20 22 23 25');assert.equal(d.AbilityValues.bonus_strength,'10 15 20 25 30 35 40 45 50 55');
 for(const key of ['magic_damage','bonus_aoe']){const paid=d.AbilityValues[key].split(' ').map(Number),base=n.AbilityValues[key].value.split(' ').map(Number);assert.equal(paid.length,10);assert.equal(paid[0],base[0]);assert.equal(paid[9],base[3]);assert.ok(paid.every((v,i)=>i===0||v>paid[i-1]));}
 for(const name of ['modifiers','d','integration'])assert.doesNotMatch(fs.readFileSync('game/scripts/vscripts/abilities/heroes/dragon_knight/'+name+'.lua','utf8'),/OnAttackLanded|ApplyDamage|StartIntervalThink|MODIFIER_PROPERTY_AOE_BONUS/);
 const kits=fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8');assert.doesNotMatch(kits,/dk_passive_sources|enfos_dk_wyrm_vigor=class|modifier_enfos_dk_wyrm_vigor_passive/);
});

test('D native value overrides cover all paid ranks/both contexts and reject unsupported/foreign/untrained/Break/illusion sources',()=>lua(wrathSetup+`
assert(integration.Restore(hero));local m=hero.mod;local p={ability=wrath,ability_special_value='magic_damage'}
assert(wrath.rank==0 and not wrath.active and m:GetModifierOverrideAbilitySpecial(p)==1 and m:GetModifierOverrideAbilitySpecialValue(p)==0)
for _,context in ipairs({true,false})do server=context;for rank=1,10 do d.rank=rank
assert(m:GetModifierOverrideAbilitySpecialValue(p)==magic[rank]);p.ability_special_value='bonus_aoe';assert(m:GetModifierOverrideAbilitySpecialValue(p)==30+(rank-1)*10);p.ability_special_value='magic_damage'
end end
for _,flag in ipairs({'broken','illusion'})do hero[flag]=true;assert(m:GetModifierOverrideAbilitySpecialValue(p)==0);hero[flag]=false end
d.null=true;assert(m:GetModifierOverrideAbilitySpecialValue(p)==0);d.null=false
local old=d.GetCaster;d.GetCaster=function()return {}end;assert(m:GetModifierOverrideAbilitySpecialValue(p)==0);d.GetCaster=old
p.ability_special_value='damage';assert(m:GetModifierOverrideAbilitySpecial(p)==0);p.ability_special_value='bonus_aoe'
wrath.GetCaster=function()return {}end;assert(m:GetModifierOverrideAbilitySpecial(p)==0);wrath.GetCaster=function()return hero end
local find=hero.FindAbilityByName;hero.FindAbilityByName=function(_,id)if id~='enfos_dk_wyrm_vigor'then return find(hero,id)end end;assert(m:GetModifierOverrideAbilitySpecial(p)==1 and m:GetModifierOverrideAbilitySpecialValue(p)==0)
`));

test('D defensive stats use live raw ranks on both contexts and never duplicate on Break/illusions/invalid ownership',()=>lua(wrathSetup+`
local a=d;local m=setmetatable({GetParent=function()return hero end,GetAbility=function()return a end},{__index=modifier_enfos_dk_wyrm_vigor_passive})
assert(m:GetModifierMagicalResistanceBonus()==0 and m:GetModifierBonusStats_Strength()==0)
assert(not m:IsHidden() and not m:IsPurgable() and not m:RemoveOnDeath() and m:GetTexture()=='dragon_knight_wyrms_wrath')
for _,context in ipairs({true,false})do server=context;for rank=1,10 do d.rank=rank;assert(m:GetModifierMagicalResistanceBonus()==mr[rank] and m:GetModifierBonusStats_Strength()==10+5*(rank-1))end end
local function zero()assert(m:GetModifierMagicalResistanceBonus()==0 and m:GetModifierBonusStats_Strength()==0)end
for _,flag in ipairs({'broken','illusion','null'})do hero[flag]=true;zero();hero[flag]=false end
d.null=true;zero();d.null=false;a=nil;zero();a=d
d.GetCaster=function()return {}end;zero();d.GetCaster=function()return hero end
d.GetAbilityName=function()return 'enfos_dk_dragon_blood'end;zero()
`));

test('D restore caps native rank, preserves free/paid ranks and refreshes only its intrinsic on server paid upgrade',()=>lua(wrathSetup+`
assert(integration.Restore(hero));d.rank=1;assert(integration.Restore(hero));assert(wrath.rank==1 and wrath.hidden and wrath.active)
for i=1,3 do assert(integration.Restore(hero))end;assert(adds==1 and dAdds==1 and mods==1 and dRankWrites==1 and dRefreshes==0 and refreshes==0)
d.rank=10;assert(integration.Restore(hero));assert(d.rank==10 and wrath.rank==1 and dRankWrites==1)
require('abilities/heroes/dragon_knight/d');local paid=setmetatable({GetCaster=function()return hero end},{__index=enfos_dk_wyrm_vigor})
assert(paid:GetIntrinsicModifierName()=='modifier_enfos_dk_wyrm_vigor_passive');paid:OnUpgrade();assert(dRefreshes==1 and refreshes==0)
server=false;paid:OnUpgrade();assert(not integration.RefreshWyrmsWrath(hero) and dRefreshes==1);server=true
di=nil;assert(not integration.RefreshWyrmsWrath(hero) and dRefreshes==1)
wrath.GetCaster=function()return {}end;assert(not integration.Restore(hero));assert(d.rank==10 and mods==1)
`));

test('D Health reports exact provider values read-only; locales/mirrors include attack/AoE and retained defensive curves',()=>{
 lua(wrathSetup+`
assert(integration.Restore(hero));hero.GetLevel=function()return 6 end;hero.GetAbilityPoints=function()return 5 end;hero.IsAlive=function()return true end
native.GetSpecialValueFor=function()return 0 end;wrath.GetSpecialValueFor=function(_,key)return assert(({magic_damage=10,bonus_aoe=30})[key])end
q.GetIntrinsicModifierName=function()return ''end;q.GetSpecialValueFor=function()return 0 end
local out={};print=function(s)out[#out+1]=s end;hero.AddAbility=function()error('Health grant')end;di.ForceRefresh=function()error('Health refresh')end
assert(require('heroes/health').Report(hero,0));local joined=table.concat(out,'|');assert(joined:find('wyrms_wrath_intrinsic=fixture_native_wrath present=true',1,true));assert(joined:find('native_wrath_magic_damage_query=10 native_wrath_bonus_aoe_query=30',1,true));assert(dRefreshes==0)
`);
 for(const lang of ['english','turkish','russian','schinese']){const t=JSON.parse(fs.readFileSync('localization/'+lang+'.json','utf8')).Tokens;for(const suffix of ['Description','SummaryDescription'])for(const key of ['magic_damage','bonus_aoe','magic_resist','bonus_strength'])assert.ok(t['DOTA_Tooltip_Ability_enfos_dk_wyrm_vigor_'+suffix].includes('{{'+key+'}}'));for(const dir of ['game/resource','game/panorama/localization','content/panorama/localization'])assert.ok(fs.readFileSync(dir+'/addon_'+lang+'.txt','utf8').includes('30 / 40 / 50 / 60 / 70 / 80 / 90 / 100 / 110 / 120'));}
});

test('Dragon Blood is a paid ten-rank controller with the native stat keys and no second armor/regen implementation',()=>{
 const e=all.enfos_dk_dragon_blood,n=source.abilities.dragon_knight_dragon_blood;
 assert.equal(e.ScriptFile,'abilities/heroes/dragon_knight/e');assert.equal(e.BaseClass,'ability_lua');assert.equal(e.Innate,'0');assert.equal(e.IsBreakable,n.IsBreakable);assert.equal(e.MaxLevel,'10');assert.equal(e.RequiredLevel,'1');assert.equal(e.LevelsBetweenUpgrades,'1');assert.equal(e.AbilityBehavior,'DOTA_ABILITY_BEHAVIOR_PASSIVE');assert.equal(all.dragon_knight_dragon_blood,undefined);
 assert.equal(e.AbilityValues.armor,'6 8 10 12 14 16 18 20 22 24');assert.equal(e.AbilityValues.health_regen,'10 13 17 20 23 27 30 33 37 40');assert.equal(e.AbilityValues.strength_regen_factor,'0.05');assert.equal(e.AbilityValues.regen_and_armor_multiplier_during_dragon_form,undefined);assert.equal(n.AbilityValues.regen_and_armor_multiplier_during_dragon_form.value,'50');
 const m=fs.readFileSync('game/scripts/vscripts/abilities/heroes/dragon_knight/modifiers.lua','utf8');assert.doesNotMatch(m,/GetModifierPhysicalArmorBonus|GetModifierConstantHealthRegen|MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS|MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT|HasDragonForm|HasModifier\(/);
 assert.doesNotMatch(fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8'),/modifier_enfos_dk_dragon_blood_passive|enfos_dk_dragon_blood=class/);
});

test('E raw native queries replace defaults at every paid rank on both contexts and zero invalid/untrained/Break/illusion sources',()=>lua(bloodSetup+`
assert(integration.Restore(hero));local m=hero.mod;local p={ability=native,ability_special_value='armor'}
assert(native.rank==1 and not native.active and m:GetModifierOverrideAbilitySpecial(p)==1 and m:GetModifierOverrideAbilitySpecialValue(p)==0)
for _,context in ipairs({true,false})do server=context;for rank=1,10 do e.rank=rank
 assert(m:GetModifierOverrideAbilitySpecialValue(p)==armor[rank]);p.ability_special_value='health_regen';assert(m:GetModifierOverrideAbilitySpecialValue(p)==regen[rank]+4);p.ability_special_value='armor'
end end
hero.str=100;p.ability_special_value='health_regen';assert(m:GetModifierOverrideAbilitySpecialValue(p)==45)
for _,flag in ipairs({'broken','illusion'})do hero[flag]=true;assert(m:GetModifierOverrideAbilitySpecialValue(p)==0);hero[flag]=false end
e.null=true;assert(m:GetModifierOverrideAbilitySpecialValue(p)==0);e.null=false
local old=e.GetCaster;e.GetCaster=function()return {}end;assert(m:GetModifierOverrideAbilitySpecialValue(p)==0);e.GetCaster=old
p.ability_special_value='regen_and_armor_multiplier_during_dragon_form';assert(m:GetModifierOverrideAbilitySpecial(p)==0)
p.ability_special_value='health_regen';native.GetCaster=function()return {}end;assert(m:GetModifierOverrideAbilitySpecial(p)==0);native.GetCaster=function()return hero end
local find=hero.FindAbilityByName;hero.FindAbilityByName=function(_,id)if id~='enfos_dk_dragon_blood'then return find(hero,id)end end;assert(m:GetModifierOverrideAbilitySpecial(p)==1 and m:GetModifierOverrideAbilitySpecialValue(p)==0)
`));

test('E restore adds one exact hidden innate, leaves paid ranks/points unchanged and refreshes only through server paid upgrade',()=>lua(bloodSetup+`
assert(integration.Restore(hero));assert(integration.Restore(hero));assert(adds==1 and mods==1 and rankWrites==1 and refreshes==0 and e.rank==0)
e.rank=10;assert(integration.Restore(hero));assert(native.active and native.rank==1 and e.rank==10 and refreshes==0)
assert(integration.RefreshDragonBlood(hero));assert(refreshes==1 and adds==1 and rankWrites==1)
require('abilities/heroes/dragon_knight/e');local paid=setmetatable({GetCaster=function()return hero end},{__index=enfos_dk_dragon_blood})
assert(paid:GetIntrinsicModifierName()=='modifier_enfos_dk_native_scaling');paid:OnUpgrade();assert(refreshes==2)
server=false;paid:OnUpgrade();assert(not integration.RefreshDragonBlood(hero) and refreshes==2);server=true
hero.illusion=true;assert(not integration.Restore(hero));hero.illusion=false
hero.FindModifierByName=function()return nil end;assert(not integration.RefreshDragonBlood(hero) and refreshes==2)
native=nil;hero.AddAbility=function()return nil end;assert(not integration.Restore(hero) and e.rank==10)
`));

test('E Health reads native identity/intrinsic/stats and four locales describe native form amplification without retired modifier aliases',()=>{
 lua(bloodSetup+`
assert(integration.Restore(hero));hero.GetLevel=function()return 6 end;hero.GetAbilityPoints=function()return 5 end;hero.IsAlive=function()return true end
native.GetSpecialValueFor=function(_,key)return assert(({armor=6,health_regen=14,regen_and_armor_multiplier_during_dragon_form=50})[key])end
q.GetIntrinsicModifierName=function()return ''end;q.GetSpecialValueFor=function()return 0 end
local out={};print=function(s)out[#out+1]=s end;hero.AddAbility=function()error('Health grant')end;intrinsic.ForceRefresh=function()error('Health refresh')end
assert(require('heroes/health').Report(hero,0));local joined=table.concat(out,'|');assert(joined:find('dragon_blood_intrinsic=fixture_native_blood present=true',1,true));assert(joined:find('native_blood_armor_query=6 native_blood_regen_query=14 native_blood_form_multiplier_query=50',1,true));assert(refreshes==0)
`);
 for(const lang of ['english','turkish','russian','schinese']){const t=JSON.parse(fs.readFileSync('localization/'+lang+'.json','utf8')).Tokens;
 for(const suffix of ['Description','SummaryDescription']){const d=t['DOTA_Tooltip_Ability_enfos_dk_dragon_blood_'+suffix];assert.ok(d.includes('{{armor}}')&&d.includes('{{health_regen}}')&&d.includes('50'));assert.doesNotMatch(d,/bonus_armor|bonus_hp_regen/);}
 assert.equal(t.DOTA_Tooltip_modifier_enfos_dk_dragon_blood_passive,undefined);
 for(const dir of ['game/resource','game/panorama/localization','content/panorama/localization']){const mirror=fs.readFileSync(dir+'/addon_'+lang+'.txt','utf8');assert.doesNotMatch(mirror,/modifier_enfos_dk_dragon_blood|\{\{/);assert.ok(mirror.includes('6 / 8 / 10 / 12 / 14 / 16 / 18 / 20 / 22 / 24'));}
 }
});

test('Breathe Fire is a pure native cone alias with exact targeting/dispel/travel fields and consistent ten-rank tuning',()=>{
 const q=all.enfos_dk_breathe_fire,n=source.abilities.dragon_knight_breathe_fire;
 assert.ok(isVerifiedNativeAbility('enfos_dk_breathe_fire',q));assert.equal(q.ScriptFile,undefined);assert.equal(q.MaxLevel,'10');assert.equal(q.RequiredLevel,'1');assert.equal(q.LevelsBetweenUpgrades,'1');assert.equal(all.dragon_knight_breathe_fire,undefined);
 for(const key of ['AbilityBehavior','AbilityUnitTargetTeam','AbilityUnitTargetType','SpellImmunityType','SpellDispellableType','AbilityUnitDamageType','AbilitySound','AbilityCastPoint','AbilityCastAnimation'])assert.equal(q[key],n[key],key);
 for(const key of ['range','speed','AbilityCastRange'])assert.equal(q.AbilityValues[key],n.AbilityValues[key],key);assert.equal(q.AbilityCastRange,q.AbilityValues.AbilityCastRange);assert.equal(q.AbilityCooldown,q.AbilityValues.AbilityCooldown.value);
 for(const [key,value]of [['start_radius','150'],['end_radius','250']]){assert.equal(q.AbilityValues[key].value,value);assert.equal(q.AbilityValues[key].affected_by_aoe_increase,n.AbilityValues[key].affected_by_aoe_increase);}
 assert.equal(q.AbilityValues.damage.value,'120 180 240 300 360 420 480 540 600 660');assert.equal(q.AbilityValues.strength_factor,'1.2');assert.equal(q.AbilityValues.reduction.value,'35 38 41 44 47 50 53 56 59 62');assert.equal(q.AbilityValues.duration,'6 6.3 6.7 7 7.3 7.7 8 8.3 8.7 9');assert.equal(q.AbilityManaCost,'90 99 108 117 126 135 144 153 162 170');assert.equal(q.AbilityValues.width,undefined);assert.equal(q.AbilityValues.reduction_pct,undefined);
 const kits=fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8');assert.doesNotMatch(kits,/enfos_dk_breathe_fire=class|modifier_enfos_dk_breathe_fire_debuff/);
 for(const name of ['modifiers','integration'])assert.doesNotMatch(fs.readFileSync('game/scripts/vscripts/abilities/heroes/dragon_knight/'+name+'.lua','utf8'),/ApplyDamage|OnSpellStart|CreateParticle|EmitSound|FindUnits|CreateLinearProjectile|StartIntervalThink|SetAbilityPoints/);
 assert.doesNotMatch(fs.readFileSync('game/scripts/vscripts/abilities/heroes/dragon_knight/integration.lua','utf8').split('function Integration.RefreshDragonBlood')[0],/ForceRefresh/);
});

test('Q live raw STR damage covers all ranks on both contexts and rejects wrong keys/owner/ability without suppressing active casts under Break',()=>lua(`
assert(integration.Restore(hero));local m,p=hero.mod,{ability=q,ability_special_value='damage'}
assert(m:GetModifierOverrideAbilitySpecial(p)==1 and m:GetModifierOverrideAbilitySpecialValue(p)==0)
hero.PassivesDisabled=function()return true end
for _,context in ipairs({true,false})do server=context;for rank=1,10 do q.rank=rank;assert(m:GetModifierOverrideAbilitySpecialValue(p)==120+60*(rank-1)+96)end end
hero.str=100;assert(m:GetModifierOverrideAbilitySpecialValue(p)==780)
p.ability_special_value='reduction';assert(m:GetModifierOverrideAbilitySpecial(p)==0);p.ability_special_value='damage'
q.GetCaster=function()return {}end;assert(m:GetModifierOverrideAbilitySpecial(p)==0);q.GetCaster=function()return hero end
q.GetAbilityName=function()return 'enfos_dk_elder_dragon_form'end;assert(m:GetModifierOverrideAbilitySpecial(p)==0);q.GetAbilityName=function()return 'enfos_dk_breathe_fire'end
hero.null=true;assert(m:GetModifierOverrideAbilitySpecialValue(p)==0);hero.null=false;q.null=true;assert(m:GetModifierOverrideAbilitySpecialValue(p)==0);q.null=false
assert(m:GetModifierOverrideAbilitySpecial(nil)==0);assert(mods==1)
`));

test('Q integration restore is idempotent and respects real-owned server guards without native grants/ranks/points writes',()=>lua(`
assert(integration.Restore(hero));assert(integration.Restore(hero));assert(mods==1)
assert(hero.mod:IsHidden() and not hero.mod:IsPurgable() and not hero.mod:RemoveOnDeath())
q.rank=10;assert(integration.Restore(hero));assert(mods==1 and q.rank==10)
server=false;assert(not integration.Restore(hero));server=true
hero.illusion=true;assert(not integration.Restore(hero));hero.illusion=false;hero.real=false;assert(not integration.Restore(hero));hero.real=true
q.GetCaster=function()return {}end;assert(not integration.Restore(hero));q.GetCaster=function()return hero end
hero.mod=nil;hero.AddNewModifier=function()return nil end;assert(not integration.Restore(hero))
`));

test('Q Health reads native damage/cone/speed without invoking gameplay; client does not report',()=>lua(`
hero.GetLevel=function()return 6 end;hero.GetAbilityPoints=function()return 5 end;hero.IsAlive=function()return true end
q.GetIntrinsicModifierName=function()return ''end;q.GetSpecialValueFor=function(_,key)return assert(({damage=216,start_radius=150,end_radius=250,speed=1050})[key])end
hero.AddNewModifier=function()error('Health restores')end
local out={};print=function(s)out[#out+1]=s end;assert(require('heroes/health').Report(hero,0));assert(table.concat(out,'|'):find('native_breathe_damage_query=216 native_breathe_start_radius_query=150 native_breathe_end_radius_query=250 native_breathe_speed_query=1050',1,true))
server=false;local count=#out;assert(not require('heroes/health').Report(hero,0) and #out==count)
`));

test('Four Q locale descriptions/mirrors use native cone and reduction keys; verified native particle precache stays available',()=>{
 for(const lang of ['english','turkish','russian','schinese']){const t=JSON.parse(fs.readFileSync('localization/'+lang+'.json','utf8')).Tokens;for(const suffix of ['Description','SummaryDescription']){const desc=t['DOTA_Tooltip_Ability_enfos_dk_breathe_fire_'+suffix];for(const key of ['damage','strength_factor','reduction','duration','range','speed','start_radius','end_radius'])assert.ok(desc.includes('{{'+key+'}}'),key);assert.doesNotMatch(desc,/225|reduction_pct/);}for(const dir of ['game/resource','game/panorama/localization','content/panorama/localization']){const text=fs.readFileSync(dir+'/addon_'+lang+'.txt','utf8');assert.doesNotMatch(text,/\{\{/);assert.ok(text.includes('120 / 180 / 240 / 300 / 360 / 420 / 480 / 540 / 600 / 660'));}}
 const precache=fs.readFileSync('game/scripts/vscripts/addon_game_mode.lua','utf8');for(const end of ['breathe_fire','breathe_fire_explosion']){const path='particles/units/heroes/hero_dragon_knight/dragon_knight_'+end+'.vpcf';assert.ok(precache.includes(path)&&source.assets.find(x=>x.path===path));}
});

const tailSetup=`
local w={rank=0,null=false,IsNull=function(self)return self.null end,GetCaster=function()return hero end,
GetAbilityName=function()return 'enfos_dk_dragon_tail'end,GetLevel=function(self)return self.rank end,
GetSpecialValueFor=function()error('recursive W read')end,
GetLevelSpecialValueNoOverride=function(self,key,rank)assert(rank==math.min(10,self.rank)-1);if key=='strength_factor'then return 1 end;assert(key=='damage');return 150+50*rank end}
local find=hero.FindAbilityByName;hero.FindAbilityByName=function(_,id)if id=='enfos_dk_dragon_tail'then return w else return find(hero,id)end end
`;
test('Dragon Tail uses exact native targeting/immunity/dispel/animation/projectile/AoE fields with authored ten-rank costs and no Boss cap',()=>{
 const w=all.enfos_dk_dragon_tail,n=source.abilities.dragon_knight_dragon_tail;
 assert.ok(isVerifiedNativeAbility('enfos_dk_dragon_tail',w));assert.equal(w.ScriptFile,undefined);assert.equal(all.dragon_knight_dragon_tail,undefined);assert.equal(w.MaxLevel,'10');assert.equal(w.RequiredLevel,'1');assert.equal(w.LevelsBetweenUpgrades,'1');
 for(const key of ['AbilityBehavior','AbilityUnitTargetTeam','AbilityUnitTargetType','AbilityUnitDamageType','SpellImmunityType','SpellDispellableType','AbilitySound','AbilityCastAnimation','AbilityCastPoint','AbilityCastRange','FightRecapLevel'])assert.equal(w[key],n[key],key);
 for(const key of ['damage_pct','dragon_cast_range','projectile_speed'])assert.equal(w.AbilityValues[key],n.AbilityValues[key],key);
 assert.deepEqual(Object.entries(w.AbilityValues.aoe),Object.entries(n.AbilityValues.aoe));
 assert.equal(w.AbilityValues.damage,'150 200 250 300 350 400 450 500 550 600');assert.equal(w.AbilityValues.strength_factor,'1.0');assert.equal(w.AbilityValues.stun_duration.value,'2.5 2.7 2.9 3.1 3.3 3.5 3.7 3.9 4.1 4.3');assert.equal(w.AbilityValues.stun_duration.special_bonus_unique_dragon_knight_2,n.AbilityValues.stun_duration.special_bonus_unique_dragon_knight_2);assert.equal(w.AbilityValues.boss_stun_duration,undefined);assert.equal(w.AbilityManaCost,'70 77 83 90 97 103 110 117 123 130');assert.equal(w.AbilityCooldown,'12 11.3 10.7 10 9.3 8.7 8 7.3 6.7 6');
 assert.doesNotMatch(fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8'),/enfos_dk_dragon_tail=class|modifier_enfos_dk_dragon_tail_stun/);
});
test('W raw damage/STR is live at all ranks on both contexts; active spell survives Break and rejects foreign/key/null/untrained inputs',()=>lua(tailSetup+`
assert(integration.Restore(hero));local m=hero.mod;local p={ability=w,ability_special_value='damage',ability_special_level=99}
assert(m:GetModifierOverrideAbilitySpecial(p)==1 and m:GetModifierOverrideAbilitySpecialValue(p)==0)
hero.PassivesDisabled=function()return true end
for _,context in ipairs({true,false})do server=context;for rank=1,10 do w.rank=rank;assert(m:GetModifierOverrideAbilitySpecialValue(p)==150+50*(rank-1)+80)end end
hero.str=100;assert(m:GetModifierOverrideAbilitySpecialValue(p)==700)
p.ability_special_value='stun_duration';assert(m:GetModifierOverrideAbilitySpecial(p)==0);p.ability_special_value='damage'
w.null=true;assert(m:GetModifierOverrideAbilitySpecialValue(p)==0);w.null=false
w.GetCaster=function()return {}end;assert(m:GetModifierOverrideAbilitySpecial(p)==0);w.GetCaster=function()return hero end
hero.name='npc_dota_hero_luna';assert(m:GetModifierOverrideAbilitySpecial(p)==0);hero.name='npc_dota_hero_dragon_knight'
assert(mods==1 and w.rank==10)
`));
test('W automatic Health reports query values without a native cast, and locales/native particles follow installed ownership',()=>{
 lua(tailSetup+`
hero.GetLevel=function()return 6 end;hero.GetAbilityPoints=function()return 5 end;hero.IsAlive=function()return true end
w.GetIntrinsicModifierName=function()return ''end;w.GetSpecialValueFor=function(_,key)return assert(({damage=230,stun_duration=2.5,aoe=50,dragon_cast_range=150,projectile_speed=1600})[key])end
q.GetIntrinsicModifierName=function()return ''end;q.GetSpecialValueFor=function()return 0 end
local out={};print=function(s)out[#out+1]=s end;w.OnSpellStart=function()error('Health casts W')end
assert(require('heroes/health').Report(hero,0));assert(table.concat(out,'|'):find('native_tail_damage_query=230 native_tail_stun_query=2.5 native_tail_aoe_query=50 native_tail_dragon_range_query=150 native_tail_projectile_speed_query=1600',1,true))
`);
 for(const lang of ['english','turkish','russian','schinese']){const t=JSON.parse(fs.readFileSync('localization/'+lang+'.json','utf8')).Tokens;for(const suffix of ['Description','SummaryDescription']){const d=t['DOTA_Tooltip_Ability_enfos_dk_dragon_tail_'+suffix];for(const key of ['damage','strength_factor','stun_duration','aoe','projectile_speed'])assert.ok(d.includes('{{'+key+'}}'));assert.doesNotMatch(d,/boss_stun_duration|physical damage|fiziksel/);}}
 const mode=fs.readFileSync('game/scripts/vscripts/addon_game_mode.lua','utf8');const path='particles/units/heroes/hero_dragon_knight/dragon_knight_dragon_tail_impact.vpcf';assert.ok(mode.includes(path)&&source.assets.some(x=>x.path===path));
});
