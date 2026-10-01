import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
test('Spellbringer previews one cursor area, acknowledges casts and cleans bounded effects',()=>{
 const panels=new Map(),events={},timers=[],live=new Set(),controls=[];
 let next=0;
 const $=id=>{if(!panels.has(id))panels.set(id,{style:{},SetHasClass(){}});return panels.get(id);};
 $.Localize=x=>x;$.DispatchEvent=()=>{};$.Schedule=(delay,fn)=>timers.push({delay,fn});
 const c={$,Players:{GetLocalPlayer:()=>0,GetTeam:()=>2,GetPlayerHeroEntityIndex:()=>100},
  ParticleAttachment_t:{PATTACH_WORLDORIGIN:0},
  Particles:{CreateParticle:(name,attach,owner)=>{assert.equal(owner,100);live.add(++next);return next;},
   DestroyParticleEffect:id=>assert(live.has(id),'never destroy twice'),ReleaseParticleIndex:id=>live.delete(id),
   SetParticleControl:(...args)=>controls.push(args)},
  CustomNetTables:{GetTableValue:t=>t==='spellbringer_state'?{mana:200,regen:2.5}:t==='spellbringer_meta'?{spellbringer_reveal:{cost:30,radius:900}}:null,SubscribeNetTableListener(){}},
  GameEvents:{Subscribe:(id,fn)=>events[id]=fn,SendEventClientSide(){},SendCustomGameEventToServer(){}},
  GameUI:{SetMouseCallback(){},GetCursorPosition:()=>[0,0],GetScreenWorldPosition:()=>[7500,2000,128]}};
 vm.runInNewContext(fs.readFileSync('content/panorama/scripts/custom_game/spellbringer.js','utf8'),c);
 c.CastSpell('spellbringer_reveal');assert.equal(live.size,1);
 assert(controls.some(a=>a[1]===1&&a[2][0]===900));
 c.CancelSpellTarget();assert.equal(live.size,0);
 for(const timer of timers.splice(0))timer.fn();assert.equal(timers.length,0,'cancel stops the recurring preview');
 const cast={team:2,ability:'spellbringer_reveal',x:7500,y:2000,z:128};
 events.enfos_spellbringer_effect({...cast,team:3});assert.equal(live.size,0);
 events.enfos_spellbringer_effect(cast);assert.equal(live.size,2);
 for(const timer of timers.splice(0).sort((a,b)=>a.delay-b.delay))timer.fn();assert.equal(live.size,0);
 for(let i=0;i<30;i++)events.enfos_spellbringer_effect(cast);
 assert(live.size<=32,'max sixteen confirmed effect pairs');
 for(const timer of timers.splice(0).sort((a,b)=>a.delay-b.delay))timer.fn();assert.equal(live.size,0);
});
