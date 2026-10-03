import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {parseKV} from '../lib/kv.mjs';

test('Venge active abilities declare installed native animations and preload their verified sound bank',()=>{
 const abilities=parseKV(fs.readFileSync('game/scripts/npc/npc_abilities_custom.txt','utf8')).DOTAAbilities;
 const expected={enfos_vs_magic_missile:'ACT_DOTA_CAST_ABILITY_1',enfos_vs_wave_of_terror:'ACT_DOTA_CAST_ABILITY_2',enfos_vs_nether_swap:'ACT_DOTA_CAST_ABILITY_4'};
 for(const [id,animation] of Object.entries(expected))assert.equal(abilities[id].AbilityCastAnimation,animation,`${id}: missing native animation`);
 assert.equal(String(abilities.enfos_vs_magic_missile.AbilityValues.magic_missile_speed),'1350');
 const startup=fs.readFileSync('game/scripts/vscripts/addon_game_mode.lua','utf8');
 const loop=startup.match(/for _,name in ipairs\(\{([^}]+)\}\) do\s*\n\s*PrecacheResource\("soundfile","soundevents\/game_sounds_heroes\/game_sounds_"/);
 assert.ok(loop && /"vengefulspirit"/.test(loop[1]),'Venge bank missing from actual startup sound precache loop');
 const recipient='particles/units/heroes/hero_vengeful/vengeful_wave_of_terror_recipient.vpcf';
 assert.ok(startup.includes(`PrecacheResource("particle", "${recipient}", context)`),'Recipient effect missing from actual startup precache');
});
