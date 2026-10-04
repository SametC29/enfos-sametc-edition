import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import {parseKV} from '../lib/kv.mjs';
import {isVerifiedNativeAbility} from '../lib/native_hero_abilities.mjs';
const all=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
const r=all.enfos_ursa_enrage;
const snapshot=JSON.parse(fs.readFileSync('docs/audit/URSA_NATIVE_SOURCE_2026-10-04.json','utf8'));

test('Enrage uses installed native cast, dispel, immunity and effects with no Lua replica',()=>{
 const native=snapshot.abilities.ursa_enrage;
 assert.ok(isVerifiedNativeAbility('enfos_ursa_enrage',r));assert.equal(r.ScriptFile,undefined);
 for(const k of ['AbilityBehavior','SpellImmunityType','SpellDispellableType','FightRecapLevel','HasScepterUpgrade','AbilitySound','AbilityCastAnimation','AbilityCastGestureSlot','AbilityCastRange'])assert.equal(r[k],native[k],k);
 assert.equal(r.AbilityType,'DOTA_ABILITY_TYPE_ULTIMATE');
 assert.equal(r.MaxLevel,'10');assert.equal(r.RequiredLevel,'5');assert.equal(r.LevelsBetweenUpgrades,'5');
 const source=fs.readFileSync('game/scripts/vscripts/abilities/pve_kits.lua','utf8');
 assert.doesNotMatch(source,/enfos_ursa_enrage=class|modifier_enfos_ursa_enrage_buff/);
 assert.equal(all.ursa_enrage,undefined,'No shadowing the native ID');
 const heroes=parseKV(fs.readFileSync('game/scripts/npc/npc_heroes_custom.txt','utf8')).DOTAHeroes;
 assert.equal(heroes.npc_dota_hero_ursa.Ability4,'enfos_ursa_enrage');
});

test('Enrage exposes full ten-rank tuning and explicit Scepter cooldown without deprecated facet grants',()=>{
 assert.equal(r.AbilityValues.AbilityCooldown.value,r.AbilityCooldown);
 const enhanced=r.AbilityValues.AbilityCooldown.special_bonus_scepter.split(' ').map(x=>Number(x.slice(1)));
 const native=snapshot.abilities.ursa_enrage.AbilityValues.AbilityCooldown.special_bonus_scepter.split(' ').map(x=>Number(x.slice(1)));
 assert.equal(enhanced.length,10);assert.equal(enhanced[0],native[0]);assert.equal(enhanced[9],native[2]);
 for(let i=1;i<10;i++){assert.ok(enhanced[i]<=enhanced[i-1]);assert.ok(Math.abs(enhanced[i]-(30-12*i/9))<0.051);}
 assert.equal(r.AbilityValues.duration,'4.5 4.8 5.1 5.4 5.7 6 6.4 6.8 7.4 8');
 assert.equal(r.AbilityValues.damage_reduction,'60 63 66 69 72 75 78 82 86 90');
 assert.equal(r.AbilityValues.status_resistance,'20 24 28 32 36 40 44 48 54 60');
 assert.equal(r.AbilityValues.damage_increase,'0');assert.equal(r.AbilityValues.damage_increase_duration,'0');
 assert.equal(r.AbilityValues.aoe_radius.value,'0');assert.equal(r.AbilityManaCost,'0');
 assert.doesNotMatch(JSON.stringify(r),/special_bonus_facet|special_bonus_unique|DependentOnAbility/);
});

test('Native Enrage ownership is client-safe, scoped and suppresses only generic Enfos ultimate bonuses',()=>{
 const result=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{encoding:'utf8',input:`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
function LinkLuaModifier()end
function IsServer()return false end
DOTA_ABILITY_TYPE_ULTIMATE=1
local Ownership=require('abilities/heroes/ursa/ownership')
local ability={null=false,IsNull=function(self)return self.null end,GetAbilityType=function()return 1 end}
local hero={name='npc_dota_hero_ursa',has=true,null=false,
 IsNull=function(self)return self.null end,GetUnitName=function(self)return self.name end,
 FindAbilityByName=function(self,id)assert(id=='enfos_ursa_enrage');if self.has then return ability end end,
 IsAlive=function()error('Server-only getter')end,AddNewModifier=function()error('Read-only ownership')end,
 AddAbility=function()error('Read-only ownership')end}
assert(Ownership.UsesNativeScepter(hero));assert(not Ownership.UsesNativeScepter(nil));assert(not Ownership.UsesNativeScepter({}))
hero.null=true;assert(not Ownership.UsesNativeScepter(hero));hero.null=false
ability.null=true;assert(not Ownership.UsesNativeScepter(hero));ability.null=false
hero.has=false;assert(not Ownership.UsesNativeScepter(hero));hero.has=true
hero.name='npc_dota_hero_axe';assert(not Ownership.UsesNativeScepter(hero));hero.name='npc_dota_hero_ursa'
require('heroes/aghanim_manager')
local m=setmetatable({GetParent=function()return hero end},modifier_enfos_scepter_upgrade)
assert(m:IsHidden());assert(m:GetModifierSpellAmplify_Percentage({inflictor=ability})==0)
assert(m:GetModifierPercentageCooldown({ability=ability})==0)
hero.has=false;assert(not m:IsHidden());assert(m:GetModifierSpellAmplify_Percentage({inflictor=ability})==40)
assert(m:GetModifierPercentageCooldown({ability=ability})==25)
hero.name='npc_dota_hero_axe';assert(m:GetModifierSpellAmplify_Percentage({inflictor=ability})==40)
assert(m:GetModifierPercentageCooldown({ability=ability})==25)
assert(not package.loaded['abilities/heroes/ursa/integration'],'No server integration loaded by client ownership')
`});assert.equal(result.status,0,result.stderr);assert.equal(result.stderr,'');
});

test('All locales describe native strong dispel and disabled-cast Scepter without the obsolete generic bonuses',()=>{
 for(const lang of ['english','turkish','russian','schinese']){
 const tokens=JSON.parse(fs.readFileSync('localization/'+lang+'.json','utf8')).Tokens;
 const upgrade=tokens.DOTA_Tooltip_Ability_enfos_ursa_enrage_scepter_description;
 assert.match(upgrade,/30–18/);assert.doesNotMatch(upgrade,/40|25/);
 assert.ok(tokens.DOTA_Tooltip_Ability_enfos_ursa_enrage_Description.includes('{{status_resistance}}'));
 for(const prefix of ['game/resource','game/panorama/localization','content/panorama/localization']){
 const t=parseKV(fs.readFileSync(prefix+'/addon_'+lang+'.txt','utf8')).lang.Tokens;
 assert.equal(t.DOTA_Tooltip_Ability_enfos_ursa_enrage_scepter_description,upgrade);
 }
 }
 assert.ok(snapshot.resources.some(x=>x.path.endsWith('ursa_enrage_buff.vpcf_c')&&x.status==='FILE_VERIFIED'));
 assert.ok(fs.readFileSync('game/scripts/vscripts/addon_game_mode.lua','utf8').includes('hero_ursa/ursa_enrage_buff.vpcf'));
});
