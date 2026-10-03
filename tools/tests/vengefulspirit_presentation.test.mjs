import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {parseKV} from '../lib/kv.mjs';
import {spawnSync} from 'node:child_process';

test('Nether Swap binds finite roots to the swapped models and opposite CP1 after placement',()=>{
 const script=`
package.path='game/scripts/vscripts/?.lua;'..package.path
function class(t)t.__index=t;return t end
function LinkLuaModifier()end
function IsServer()return true end
PATTACH_ABSORIGIN_FOLLOW=7;DAMAGE_TYPE_MAGICAL=2
require('abilities/heroes/vengefulspirit/r')
local function unit(x)
 local u={pos={x=x},removed=false}
 function u:IsNull()return self.removed end
 function u:IsAlive()return true end
 function u:GetTeamNumber()return 2 end
 function u:GetAbsOrigin()assert(not self.removed);return self.pos end
 function u:SetAbsOrigin(p)self.pos=p end
 function u:Interrupt()end
 function u:EmitSound()end
 function u:AddNewModifier()return {} end
 function u:GetAgility()return 0 end
 return u
end
local c,t=unit(10),unit(90)
local a=setmetatable({GetCaster=function()return c end,GetCursorTarget=function()return t end,GetLevel=function()return 1 end,
 GetSpecialValueFor=function()return 0 end},enfos_vs_nether_swap)
local roots={};local placements=0;local bindings=0;local releases=0;local invalidate=false
function FindClearSpaceForUnit(u,p)placements=placements+1;if invalidate then t.removed=true end end
ParticleManager={CreateParticle=function(_,path,attach,owner)
 assert(placements%2==0,'Effect must use completed placement');assert(attach==7 and owner~=nil)
 local casterRoot=#roots%2==0;assert(owner==(casterRoot and c or t))
 assert(path=='particles/units/heroes/hero_vengeful/'..(casterRoot and 'vengeful_nether_swap.vpcf' or 'vengeful_nether_swap_target.vpcf'))
 roots[#roots+1]={owner=owner};return #roots end,
 SetParticleControlEnt=function(_,id,cp,unit,attach,name,offset,lock)
 local other=roots[id].owner==c and t or c
 assert(cp==1 and unit==other and attach==7 and name=='' and lock==false and offset==other.pos)
 bindings=bindings+1 end,
 ReleaseParticleIndex=function(_,id)assert(not roots[id].released);roots[id].released=true;releases=releases+1 end}
for i=1,20 do a:OnSpellStart()end
assert(#roots==40 and bindings==40 and releases==40,'Each cast owns exactly two finite released roots')
assert(c.pos.x==10 and t.pos.x==90,'Presentation must not change swap gameplay')
invalidate=true;a:OnSpellStart();assert(#roots==40,'Placement callback invalidation must not bind removed models')
print('Nether Swap model binding PASS')
`;
 const r=spawnSync(process.execPath,['node_modules/fengari-node-cli/src/lua-cli.js','-'],{input:script,encoding:'utf8'});
 assert.equal(r.status,0,r.stderr||r.stdout);assert.match(r.stdout,/Nether Swap model binding PASS/,r.stderr);
});

test('Venge active abilities declare installed native animations and preload their verified sound bank',()=>{
 const abilities=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
 const expected={enfos_vs_magic_missile:'ACT_DOTA_CAST_ABILITY_1',enfos_vs_wave_of_terror:'ACT_DOTA_CAST_ABILITY_2',enfos_vs_nether_swap:'ACT_DOTA_CAST_ABILITY_4'};
 for(const [id,animation] of Object.entries(expected))assert.equal(abilities[id].AbilityCastAnimation,animation,`${id}: missing native animation`);
 const rules={enfos_vs_magic_missile:['SPELL_IMMUNITY_ENEMIES_NO','SPELL_DISPELLABLE_YES_STRONG'],enfos_vs_wave_of_terror:['SPELL_IMMUNITY_ENEMIES_NO','SPELL_DISPELLABLE_YES'],enfos_vs_nether_swap:['SPELL_IMMUNITY_ENEMIES_YES','SPELL_DISPELLABLE_YES']};
 for(const [id,[immunity,dispel]] of Object.entries(rules)){
  assert.equal(abilities[id].SpellImmunityType,immunity,`${id}: installed native immunity metadata`);
  assert.equal(abilities[id].SpellDispellableType,dispel,`${id}: installed native dispel metadata`);
 }
 assert.equal(String(abilities.enfos_vs_magic_missile.AbilityValues.magic_missile_speed),'1350');
 const startup=fs.readFileSync('game/scripts/vscripts/addon_game_mode.lua','utf8');
 const loop=startup.match(/for _,name in ipairs\(\{([^}]+)\}\) do\s*\n\s*PrecacheResource\("soundfile","soundevents\/game_sounds_heroes\/game_sounds_"/);
 assert.ok(loop && /"vengefulspirit"/.test(loop[1]),'Venge bank missing from actual startup sound precache loop');
 const recipient='particles/units/heroes/hero_vengeful/vengeful_wave_of_terror_recipient.vpcf';
 assert.ok(startup.includes(`PrecacheResource("particle", "${recipient}", context)`),'Recipient effect missing from actual startup precache');
});
