import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';
import {isVerifiedNativeAbility} from '../lib/native_hero_abilities.mjs';
const all=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
const q=all.enfos_am_mana_break;
const native=JSON.parse(fs.readFileSync('docs/audit/ANTIMAGE_NATIVE_SOURCE_2026-10-04.json','utf8')).abilities.antimage_mana_break;
test('Mana Void focused corrections match installed targeting and immunity without falsely declaring native ownership',()=>{
 const r=all.enfos_am_mana_void,source=JSON.parse(fs.readFileSync('docs/audit/ANTIMAGE_NATIVE_SOURCE_2026-10-04.json','utf8')).abilities.antimage_mana_void;
 for(const key of ['AbilityBehavior','SpellImmunityType','AbilityUnitTargetTeam','AbilityUnitTargetType','AbilityUnitDamageType','AbilityCastRange','AbilityCastAnimation'])assert.equal(r[key],source[key],key);
 assert.equal(r.HasScepterUpgrade,undefined);assert.equal(r.AbilityValues.boss_damage_cap_pct,undefined);
 assert.equal(r.BaseClass,'ability_lua');assert.equal(isVerifiedNativeAbility('enfos_am_mana_void',r),false,'Native flat extension construction remains unresolved');
 assert.equal(r.AbilityValues.base_damage,'100 150 200 250 300 350 420 490 560 650');assert.equal(r.AbilityValues.agility_factor,'0.4 0.5 0.6 0.7 0.8 0.9 1 1.15 1.3 1.5');
 for(const lang of ['english','turkish','russian','schinese']){const t=JSON.parse(fs.readFileSync('localization/'+lang+'.json','utf8')).Tokens,p='DOTA_Tooltip_Ability_enfos_am_mana_void';assert.doesNotMatch(t[p+'_Description'],/boss_damage_cap_pct/);assert.ok(t[p+'_Description'].includes('{{stun_duration}}'));assert.equal(t[p+'_scepter_description'],undefined);}
});
test('Counterspell delegates installed reflection, Shard, dispel, illusion and animation metadata',()=>{
 const e=all.enfos_am_counterspell,source=JSON.parse(fs.readFileSync('docs/audit/ANTIMAGE_NATIVE_SOURCE_2026-10-04.json','utf8')).abilities.antimage_counterspell;
 assert.ok(isVerifiedNativeAbility('enfos_am_counterspell',e));assert.equal(all.antimage_counterspell,undefined);
 for(const key of ['AbilityBehavior','SpellDispellableType','FightRecapLevel','IsBreakable','HasShardUpgrade','AbilityCastRange','AbilityCastAnimation','AbilityCastGestureSlot'])assert.equal(e[key],source[key],key);
 for(const key of ['duration_illusion','outgoing_damage','incoming_damage','does_reflect','reflected_spell_amp','heal_pct'])assert.deepEqual(JSON.parse(JSON.stringify(e.AbilityValues[key])),source.AbilityValues[key],key);
 for(const key of ['magic_resist','active_resist','active_duration'])assert.equal(e.AbilityValues[key],undefined);
 assert.doesNotMatch(fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8'),/enfos_am_counterspell|modifier_enfos_am_counterspell/);
 for(const name of ['antimage_counter','antimage_spellshield_reflect'])assert.ok(fs.readFileSync('game/scripts/vscripts/addon_game_mode.lua','utf8').includes(name+'.vpcf'));
 const evidence=JSON.parse(fs.readFileSync('docs/audit/ANTIMAGE_NATIVE_SOURCE_2026-10-04.json','utf8')).eResearch.resources;assert.equal(evidence.length,2);assert.ok(evidence.every(x=>x.status==='FILE_VERIFIED' && x.sha256.length===64));
});
test('Counterspell preserves authored ten-rank curves and four translated tooltips use native specials',()=>{
 const e=all.enfos_am_counterspell;assert.equal(e.MaxLevel,'10');assert.equal(e.RequiredLevel,'1');assert.equal(e.LevelsBetweenUpgrades,'1');assert.equal(e.AbilityManaCost,'40');assert.equal(e.AbilityCastPoint,'0.0');
 assert.equal(e.AbilityValues.magic_resistance.value,'20 23 26 29 32 35 38 42 46 50');assert.equal(e.AbilityValues.duration,'1.4 1.55 1.7 1.85 2 2.15 2.3 2.5 2.75 3');assert.equal(e.AbilityCooldown,'12 11.3 10.6 9.9 9.2 8.5 7.8 7.1 6.5 6');assert.equal(e.AbilityValues.AbilityCooldown.value,e.AbilityCooldown);
 const names=[];for(const lang of ['english','turkish','russian','schinese']){
 const t=JSON.parse(fs.readFileSync('localization/'+lang+'.json','utf8')).Tokens,p='DOTA_Tooltip_Ability_enfos_am_counterspell';names.push(t[p]);for(const key of ['magic_resistance','duration'])assert.ok(t[p+'_Description'].includes('{{'+key+'}}'));assert.doesNotMatch(t[p+'_Description'],/active_resist|active_duration/);assert.ok(t[p+'_shard_description'].includes('{{duration_illusion}}'));
 for(const dir of ['game/resource','game/panorama/localization','content/panorama/localization']){const text=fs.readFileSync(dir+'/addon_'+lang+'.txt','utf8');assert.doesNotMatch(text,/\{\{/);assert.ok(text.includes(e.AbilityValues.magic_resistance.value.split(' ').join(' / ')));assert.ok(text.includes('DOTA_Tooltip_ability_enfos_am_counterspell_shard_description'));}
 }assert.equal(new Set(names).size,4);
});
test('Paid Mana Break has one exact native provider, ten-rank tuning and no copied burn, damage, cleave or assets',()=>{
 assert.equal(q.BaseClass,'ability_lua');assert.equal(q.ScriptFile,'abilities/heroes/antimage/q');assert.equal(q.MaxLevel,'10');assert.equal(q.RequiredLevel,'1');assert.equal(q.LevelsBetweenUpgrades,'1');
 assert.equal(q.IsBreakable,native.IsBreakable);assert.equal(q.HasScepterUpgrade,native.HasScepterUpgrade);assert.equal(q.SpellImmunityType,native.SpellImmunityType);assert.equal(q.AbilityUnitDamageType,native.AbilityUnitDamageType);
 assert.equal(q.AbilityValues.bonus_damage,'40 50 60 70 80 90 100 115 130 150');assert.equal(q.AbilityValues.agility_factor,'0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.9');
 for(const key of ['mana_per_hit','mana_per_hit_pct']){
 const values=q.AbilityValues[key].split(' ').map(Number),base=native.AbilityValues[key].value.split(' ').map(Number);
 assert.equal(values.length,10);assert.equal(values[0],base[0]);assert.equal(values[9],base[3]);
 for(let i=0;i<10;i++)assert.ok(Math.abs(values[i]-(base[0]+(base[3]-base[0])*i/9))<.051);
 }
 assert.equal(q.AbilityValues.native_scepter_mana_pct_bonus,native.AbilityValues.mana_per_hit_pct.special_bonus_scepter.slice(1));
 for(const key of ['cleave_radius','cleave_pct','percent_damage_per_burn','illusion_percentage','empowered_max_burn_pct','empowered_mana_break_debuff_duration'])assert.equal(q.AbilityValues[key],undefined,key);
 assert.equal(all.antimage_mana_break,undefined,'No native ID shadow');
 assert.doesNotMatch(fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8'),/enfos_am_mana_break=class|modifier_enfos_am_mana_break_passive/);
 for(const file of ['q','modifiers','integration'])assert.doesNotMatch(fs.readFileSync('game/scripts/vscripts/abilities/heroes/antimage/'+file+'.lua','utf8'),/ApplyDamage|ReduceMana|FindUnits|CreateParticle|EmitSound|SetAbilityPoints|StartIntervalThink|CreateTimer|is_boss/);
});
const setup=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
local server=true;function IsServer()return server end
LUA_MODIFIER_MOTION_NONE=0;function LinkLuaModifier(n,p)assert(n=='modifier_enfos_am_native_scaling' and p=='abilities/heroes/antimage/modifiers')end
package.loaded['lib/hero_trace']={Log=function()end}
local q={rank=0,null=false,IsNull=function(self)return self.null end,GetLevel=function(self)return self.rank end,
GetLevelSpecialValueNoOverride=function(self,key,rank)
 assert(rank==math.min(10,self.rank)-1)
 local data={mana_per_hit={25,26.7,28.3,30,31.7,33.3,35,36.7,38.3,40},mana_per_hit_pct={1.8,2.1,2.4,2.7,3,3.3,3.6,3.9,4.2,4.5},native_scepter_mana_pct_bonus={1.5},
 bonus_damage={40,50,60,70,80,90,100,115,130,150},agility_factor={.4,.45,.5,.55,.6,.65,.7,.75,.8,.9}}
 local row=assert(data[key],key);return row[rank+1] or row[1]
end,GetSpecialValueFor=function()error('recursive lookup')end}
local adds,mods,sets,refreshes=0,0,0,0
local c={name='npc_dota_hero_antimage',null=false,real=true,illusion=false,broken=false,scepter=false,agi=100,points=5,
IsNull=function(self)return self.null end,IsRealHero=function(self)return self.real end,IsIllusion=function(self)return self.illusion end,
GetUnitName=function(self)return self.name end,PassivesDisabled=function(self)return self.broken end,
HasScepter=function(self)return self.scepter end,GetAgility=function(self)return self.agi end,GetTeamNumber=function()return 2 end,
SetAbilityPoints=function()error('point mutation')end,IsAlive=function()error('client server-only getter')end}
q.GetCaster=function()return c end
local n={rank=0,null=false,empowered_state=13,IsNull=function(self)return self.null end,GetLevel=function(self)return self.rank end,
GetCaster=function()return c end,GetAbilityName=function()return 'antimage_mana_break'end,
SetLevel=function(self,rank)assert(server);assert(c.mod);self.rank=rank;sets=sets+1 end,
SetHidden=function(self,v)assert(server);self.hidden=v end,SetActivated=function(self,v)assert(server);self.active=v end,
GetIntrinsicModifierName=function()return 'fixture_mana_break'end}
c.FindAbilityByName=function(self,id)if id=='enfos_am_mana_break' then return q elseif id=='antimage_mana_break' then return self.native end end
c.HasModifier=function(self,name)assert(name=='modifier_enfos_am_native_scaling');return self.mod~=nil end
c.AddNewModifier=function(self,caster,a,name)assert(server and caster==c and a==q and name=='modifier_enfos_am_native_scaling');mods=mods+1
 self.mod=setmetatable({GetParent=function()return c end,IsNull=function()return false end},{__index=modifier_enfos_am_native_scaling});return self.mod end
c.AddAbility=function(self,id)assert(server and id=='antimage_mana_break' and self.mod);adds=adds+1;self.native=n;return n end
local intrinsic={IsNull=function()return false end,ForceRefresh=function()assert(server);refreshes=refreshes+1 end}
c.FindModifierByName=function(_,name)if name=='fixture_mana_break' then return intrinsic end end
local integration=require('abilities/heroes/antimage/integration')
`;
function lua(body){const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{encoding:'utf8',input:setup+body});assert.equal(r.status,0,r.stderr);assert.equal(r.stderr,'');}
test('Native Q/Blink Scepter ownership suppresses generic ultimate amplification and cooldown only for the owned Anti-Mage kit',()=>lua(`
function LinkLuaModifier()end
package.loaded['abilities/heroes/luna/integration']={UsesNativeScepter=function()return false end}
package.loaded['abilities/heroes/nevermore/ownership']={IsEnfos=function()return false end}
require('heroes/aghanim_manager')
local w={IsNull=function()return false end};local hero={GetUnitName=function()return 'npc_dota_hero_antimage'end,FindAbilityByName=function(_,name)assert(name=='enfos_am_blink');return w end}
local owner=require('abilities/heroes/antimage/ownership');assert(owner.UsesNativeScepter(hero));server=false;assert(owner.UsesNativeScepter(hero))
assert(not owner.UsesNativeScepter(nil));assert(not owner.UsesNativeScepter({}));w.IsNull=function()return true end;assert(not owner.UsesNativeScepter(hero));w.IsNull=function()return false end
local m=setmetatable({GetParent=function()return hero end},{__index=modifier_enfos_scepter_upgrade})
assert(m:IsHidden());assert(m:GetModifierSpellAmplify_Percentage({})==0);assert(m:GetModifierPercentageCooldown({})==0)
hero.GetUnitName=function()return 'npc_dota_hero_faceless_void'end;assert(not owner.UsesNativeScepter(hero))
DOTA_ABILITY_TYPE_ULTIMATE=1;local r={GetAbilityType=function()return DOTA_ABILITY_TYPE_ULTIMATE end}
assert(m:GetModifierSpellAmplify_Percentage({inflictor=r})==40);assert(m:GetModifierPercentageCooldown({ability=r})==25)
`));
test('Native Shard ownership is client-safe and rejects missing, null and foreign kits',()=>lua(`
server=false;local ownership=require('abilities/heroes/antimage/ownership')
local e={IsNull=function()return false end}
local hero={GetUnitName=function()return 'npc_dota_hero_antimage'end,FindAbilityByName=function(_,id)assert(id=='enfos_am_counterspell');return e end}
assert(ownership.UsesNativeShard(hero));assert(not ownership.UsesNativeShard(nil));assert(not ownership.UsesNativeShard({}))
e.IsNull=function()return true end;assert(not ownership.UsesNativeShard(hero))
hero.FindAbilityByName=function()return nil end;assert(not ownership.UsesNativeShard(hero))
hero.GetUnitName=function()return 'npc_dota_hero_faceless_void'end;hero.FindAbilityByName=function()error('Foreign hero query')end;assert(not ownership.UsesNativeShard(hero))
`));
test('Native Shard suppresses Anti-Mage generic Carry speed and proc while other Carry heroes retain them',()=>lua(`
function LinkLuaModifier()end
package.loaded['abilities/heroes/luna/integration']={UsesNativeShard=function()return false end}
package.loaded['abilities/heroes/nevermore/ownership']={IsEnfos=function()return false end}
require('heroes/aghanim_manager')
local e={IsNull=function()return false end};local hero={GetUnitName=function()return 'npc_dota_hero_antimage'end,FindAbilityByName=function()return e end,GetTeamNumber=function()return 2 end}
local m=setmetatable({role='Carry',GetParent=function()return hero end},{__index=modifier_enfos_shard_upgrade})
assert(m:IsHidden());assert(m:GetModifierMoveSpeedBonus_Percentage()==0)
ApplyDamage=function()error('Native Shard cannot add generic proc')end;m:OnAttackLanded({attacker=hero,target={IsNull=function()error('No native attack processing')end}})
hero.GetUnitName=function()return 'npc_dota_hero_faceless_void'end;assert(m:GetModifierMoveSpeedBonus_Percentage()==15)
local dealt;ApplyDamage=function(args)dealt=args.damage end
local target={IsNull=function()return false end,IsAlive=function()return true end,GetTeamNumber=function()return 3 end}
DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION=0;DAMAGE_TYPE_PURE=4;m:OnAttackLanded({attacker=hero,target=target,damage=100});assert(dealt==12)
server=false;ApplyDamage=function()error('Client damage')end;m:OnAttackLanded({attacker=hero,target=target,damage=100})
`));
test('Provider is installed after tuning, rank0 until trained, idempotent through restore and rank-up with no points or target state writes',()=>lua(`
assert(integration.Restore(c));assert(adds==1 and mods==1 and sets==0 and n.rank==0 and n.hidden and not n.active)
assert(integration.Restore(c));assert(adds==1 and mods==1 and sets==0)
q.rank=1;assert(integration.RefreshManaBreak(c));assert(n.rank==1 and n.active and sets==1 and refreshes==1)
for rank=2,10 do q.rank=rank;assert(integration.RefreshManaBreak(c))end
assert(adds==1 and mods==1 and sets==1 and refreshes==10 and c.points==5 and n.empowered_state==13)
assert(integration.Restore(c));assert(refreshes==10 and sets==1)
intrinsic=nil;assert(not integration.RefreshManaBreak(c));assert(n.empowered_state==13)
c.native=nil;c.AddAbility=function()return nil end;assert(not integration.Restore(c))
server=false;assert(not integration.Restore(c));server=true
c.illusion=true;assert(not integration.Restore(c));c.illusion=false
c.real=false;assert(not integration.Restore(c));c.real=true
c.name='npc_dota_hero_axe';assert(not integration.Restore(c));c.name='npc_dota_hero_antimage'
c.null=true;assert(not integration.Restore(c))
`));
test('Native bridge covers all ranks/client/server and exactly one Scepter bonus; native burn ratio, illusion and empowered fields remain untouched',()=>lua(`
assert(integration.Restore(c));local m=c.mod;local p={ability=n,ability_special_value='mana_per_hit_pct'}
assert(m:GetModifierOverrideAbilitySpecial(p)==1 and m:GetModifierOverrideAbilitySpecialValue(p)==0)
for _,scope in ipairs({true,false})do server=scope
 for rank=1,10 do q.rank=rank
  for _,scepter in ipairs({false,true})do c.scepter=scepter
   assert(math.abs(m:GetModifierOverrideAbilitySpecialValue(p)-(1.8+.3*(rank-1)+(scepter and 1.5 or 0)))<.00001)
   p.ability_special_value='mana_per_hit';assert(m:GetModifierOverrideAbilitySpecialValue(p)==q:GetLevelSpecialValueNoOverride('mana_per_hit',rank-1))
   p.ability_special_value='mana_per_hit_pct'
  end
 end
end
for _,key in ipairs({'percent_damage_per_burn','illusion_percentage','empowered_max_burn_pct','empowered_mana_break_debuff_duration','bonus_damage','AbilityDamage'})do
 p.ability_special_value=key;assert(m:GetModifierOverrideAbilitySpecial(p)==0)
end
p.ability_special_value='mana_per_hit_pct';c.broken=true;assert(m:GetModifierOverrideAbilitySpecial(p)==1,'Break is owned by native modifier');c.broken=false
n.GetCaster=function()return {}end;assert(m:GetModifierOverrideAbilitySpecial(p)==0);n.GetCaster=function()return c end
q.null=true;assert(m:GetModifierOverrideAbilitySpecial(p)==0);q.null=false
n.null=true;assert(m:GetModifierOverrideAbilitySpecial(p)==0);n.null=false
p.ability={IsNull=function()return false end,GetCaster=function()return c end,GetAbilityName=function()return 'antimage_blink'end}
assert(m:GetModifierOverrideAbilitySpecial(p)==0)
`));
test('PvE proc stays physical/real-hero only and side-effect-free, handles killing/zero-mana/immune targets without copied burn or cleave',()=>lua(`
assert(integration.Restore(c));local m=c.mod
local t={team=3,hero=false,creep=true,creature=false,IsNull=function()return false end,GetTeamNumber=function(self)return self.team end,
IsHero=function(self)return self.hero end,IsCreep=function(self)return self.creep end,IsCreature=function(self)return self.creature end,
GetMana=function()error('No copied mana logic')end,GetMaxMana=function()error('No copied mana logic')end,
IsAlive=function()error('Do not reject killing proc')end,IsMagicImmune=function()error('Physical extension uses ordinary attack rules')end}
local p={target=t};assert(m:GetModifierProcAttack_BonusDamage_Physical(p)==0)
local base={40,50,60,70,80,90,100,115,130,150};local agi={.4,.45,.5,.55,.6,.65,.7,.75,.8,.9}
for rank=1,10 do q.rank=rank
 for _,stat in ipairs({0,100,350})do c.agi=stat
  assert(m:GetModifierProcAttack_BonusDamage_Physical(p)==base[rank]+stat*agi[rank])
  assert(m:GetModifierProcAttack_BonusDamage_Physical(p)==base[rank]+stat*agi[rank],'Getter queries cannot apply duplicate damage')
 end
end
c.broken=true;assert(m:GetModifierProcAttack_BonusDamage_Physical(p)==0);c.broken=false
c.illusion=true;assert(m:GetModifierProcAttack_BonusDamage_Physical(p)==0);c.illusion=false
c.real=false;assert(m:GetModifierProcAttack_BonusDamage_Physical(p)==0);c.real=true
t.team=2;assert(m:GetModifierProcAttack_BonusDamage_Physical(p)==0);t.team=3
t.creep=false;assert(m:GetModifierProcAttack_BonusDamage_Physical(p)==0)
server=false;m.GetParent=function()error('Client must return before server work')end;assert(m:GetModifierProcAttack_BonusDamage_Physical(p)==0)
`));
test('Q rank hook is server-only and client bootstrap does not load restoration',()=>lua(`
server=false;package.loaded['abilities/heroes/antimage/integration']=nil
package.preload['abilities/heroes/antimage/integration']=function()error('client imports server')end
require('abilities/heroes/antimage/q');enfos_am_mana_break.OnUpgrade({GetCaster=function()error('client caster restore')end})
assert(enfos_am_mana_break:GetIntrinsicModifierName()=='modifier_enfos_am_native_scaling')
`));
test('Q native values and Scepter metadata render canonically in all four languages and twelve mirrors without cleave claims',()=>{
 for(const lang of ['english','turkish','russian','schinese']){
 const tokens=JSON.parse(fs.readFileSync('localization/'+lang+'.json','utf8')).Tokens;
 const desc=tokens.DOTA_Tooltip_Ability_enfos_am_mana_break_Description,upgrade=tokens.DOTA_Tooltip_Ability_enfos_am_mana_break_scepter_description;
 for(const key of ['mana_per_hit','mana_per_hit_pct','bonus_damage','agility_factor'])assert.ok(desc.includes('{{'+key+'}}'));
 assert.doesNotMatch(desc,/cleave_radius|cleave_pct/);assert.ok(upgrade.includes('{{native_scepter_mana_pct_bonus}}'));
 for(const dir of ['game/resource','game/panorama/localization','content/panorama/localization']){
  const text=fs.readFileSync(dir+'/addon_'+lang+'.txt','utf8');assert.doesNotMatch(text,/\{\{/);
  assert.ok(text.includes(q.AbilityValues.mana_per_hit.split(' ').join(' / ')));
  const row=text.split('\n').find(x=>x.includes('DOTA_Tooltip_Ability_enfos_am_mana_break_scepter_description'));assert.ok(row.includes('1.5'));
 }
 }
});
test('Automatic Anti-Mage Health reads native provider values and intrinsic without restoration or client mutations',()=>lua(`
assert(integration.Restore(c));q.rank=1;assert(integration.RefreshManaBreak(c))
local lines={};print=function(s)lines[#lines+1]=s end
c.GetLevel=function()return 6 end;c.GetAbilityPoints=function()return 5 end;c.IsAlive=function()return true end
n.GetSpecialValueFor=function(_,key)return c.mod:GetModifierOverrideAbilitySpecialValue({ability=n,ability_special_value=key})end
c.AddAbility=function()error('health changed abilities')end;c.AddNewModifier=function()error('health changed modifiers')end
local health=require('heroes/health');assert(health.Report(c,0))
local out=table.concat(lines,'|');assert(out:find('ability=antimage_mana_break rank=1',1,true))
assert(out:find('mana_break_intrinsic=fixture_mana_break present=true',1,true))
assert(out:find('native_mana_per_hit_query=25',1,true))
local count=#lines;server=false;assert(not health.Report(c,0) and #lines==count)
`));


test('Blink delegates installed native targeting, animation, sound and Scepter metadata without unconditional empowerment',()=>{
 const w=all.enfos_am_blink, source=JSON.parse(fs.readFileSync('docs/audit/ANTIMAGE_NATIVE_SOURCE_2026-10-04.json','utf8')).abilities.antimage_blink;
 assert.equal(w.BaseClass,'antimage_blink');assert.equal(w.ScriptFile,undefined);assert.equal(all.antimage_blink,undefined);
 for(const key of ['AbilityBehavior','HasScepterUpgrade','AbilityCastAnimation','AbilitySound'])assert.equal(w[key],source[key],key);
 assert.equal(w.AbilityCastPoint,'0.4');assert.equal(w.AbilityValues.min_blink_range,source.AbilityValues.min_blink_range);
 for(const key of ['empowered_mana_break_duration','empowered_max_burn_pct_tooltip','empowered_mana_break_debuff_duration_tooltip'])assert.deepEqual(Object.entries(w.AbilityValues[key]),Object.entries(source.AbilityValues[key]),key);
 assert.equal(w.AbilityValues.blink_range,undefined);
 assert.doesNotMatch(fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8'),/enfos_am_blink[=:]|function enfos_am_blink/);
 for(const path of ['antimage_blink_start','antimage_blink_end'])assert.ok(fs.readFileSync('game/scripts/vscripts/addon_game_mode.lua','utf8').includes(path+'.vpcf'));
});
test('Native Blink preserves the independently authored ten-rank progression, ranges, cooldowns and mana cost',()=>{
 const w=all.enfos_am_blink;assert.equal(w.MaxLevel,'10');assert.equal(w.RequiredLevel,'1');assert.equal(w.LevelsBetweenUpgrades,'1');assert.equal(w.AbilityManaCost,'50');
 const ranges=[700,750,800,850,900,950,1000,1050,1100,1150],cds=[9,8.3,7.6,6.9,6.2,5.5,4.8,4.2,3.8,3.5];
 for(const[key,expected]of [['AbilityCastRange',ranges],['AbilityCooldown',cds]]){
 assert.deepEqual(w[key].split(' ').map(Number),expected);assert.deepEqual(Object.entries(w.AbilityValues[key]),[['value',w[key]]],'No disabled talent branches or inconsistent native special');
 }
 const hero=parseKV(fs.readFileSync('game/scripts/npc/npc_heroes_custom.txt','utf8')).DOTAHeroes.npc_dota_hero_antimage;assert.equal(hero.Ability2,'enfos_am_blink');
});
test('Blink upgrade descriptions and range render in four real translations and twelve mirrors',()=>{
 const names=[];for(const lang of ['english','turkish','russian','schinese']){
 const tokens=JSON.parse(fs.readFileSync('localization/'+lang+'.json','utf8')).Tokens,p='DOTA_Tooltip_Ability_enfos_am_blink';names.push(tokens[p]);
 assert.ok(tokens[p+'_Description'].includes('{{AbilityCastRange}}'));assert.ok(tokens[p+'_Description'].includes('{{min_blink_range}}'));
 const upgrade=tokens[p+'_scepter_description'];for(const number of ['5','20','6'])assert.ok(upgrade.includes(number));assert.doesNotMatch(upgrade,/\{\{/);
 for(const dir of ['game/resource','game/panorama/localization','content/panorama/localization']){
 const text=fs.readFileSync(dir+'/addon_'+lang+'.txt','utf8');assert.doesNotMatch(text,/\{\{/);
 for(const casing of ['Ability','ability'])assert.ok(text.includes('DOTA_Tooltip_'+casing+'_enfos_am_blink_scepter_description'));
 assert.ok(text.includes(all.enfos_am_blink.AbilityCastRange.split(' ').join(' / ')));
 }
 }assert.equal(new Set(names).size,4);
});
