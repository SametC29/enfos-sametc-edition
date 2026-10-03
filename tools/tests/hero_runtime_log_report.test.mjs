import test from 'node:test';
import assert from 'node:assert/strict';
import {analyzeHeroLog}from'../hero_runtime_log_report.mjs';
test('extracts multiple selected heroes and preserves missing providers without certifying acceptance',()=>{
const r=analyzeHeroLog(`[VScript]: [HERO_HEALTH] player=2 hero=npc_dota_hero_luna level=6 points=5 alive=true
[VScript]: [HERO_HEALTH] ability=enfos_luna_lucent_beam rank=0
[VScript]: [SF_HEALTH] player=0 level=9 points=0 alive=true
[VScript]: [SF_HEALTH] ability=nevermore_requiem rank=missing
[VScript]: [SF_HEALTH] modifier=modifier_nevermore_necromastery present=true stacks=38
[VScript]: [SF_HEALTH] native_requiem_damage_query=194.88 ability_damage_getter=80`);
assert.equal(r.snapshots.length,2);assert.equal(r.snapshots[0].hero,'npc_dota_hero_luna');
assert.equal(r.snapshots[1].abilities[0].rank,null);assert.equal(r.snapshots[1].modifiers[0].stacks,38);
assert.equal(r.snapshots[1].queries.requiemSurfacesDiffer,true);assert.equal(r.engineAcceptance,'NOT_ESTABLISHED_BY_LOG');
});
test('counts runtime errors and rejected orders separately and omits unrelated account/chat records',()=>{
const r=analyzeHeroLog(`GC chat [U:1:123456] private player name
Script Runtime Error: C:\\Users\\someone\\ability.lua:47 nil method
Script Runtime Error: C:\\Users\\someone\\ability.lua:47 nil method
Game code (account 123456) tried to execute invalid order (26).
Game code (account 123456) tried to execute invalid order (15).`);
assert.equal(r.runtimeErrors[0].count,2);assert.deepEqual(r.invalidOrderCounts,{'15':1,'26':1});
assert.ok(!JSON.stringify(r).includes('123456'));assert.ok(!JSON.stringify(r).includes('someone'));
assert.equal(r.snapshots.length,0);assert.equal(r.engineAcceptance,'NOT_ESTABLISHED_BY_LOG');
});
