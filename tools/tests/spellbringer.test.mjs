import test from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import fs from 'node:fs';

test('Spellbringer waits for world point, permits normal orders and cancels without casting', () => {
  const panels = new Map(), sent = [];
  const $ = id => { if (!panels.has(id)) panels.set(id, {style:{},SetHasClass(){}}); return panels.get(id); };
  $.Localize = x => x; $.DispatchEvent = () => {};
  let mouse;
  const c = {$, Players:{GetLocalPlayer:()=>0},
    CustomNetTables:{GetTableValue:(t)=>t==='spellbringer_state'?{mana:200,regen:2.5}:null,SubscribeNetTableListener(){}},
    GameEvents:{Subscribe(){},SendEventClientSide(){},SendCustomGameEventToServer:(name,data)=>sent.push({name,data})},
    GameUI:{SetMouseCallback:fn=>mouse=fn,GetCursorPosition:()=>[3,4],GetScreenWorldPosition:()=>[7500,-2000,500]}};
  vm.runInNewContext(fs.readFileSync('content/panorama/scripts/custom_game/spellbringer.js','utf8'),c);
  assert.equal(mouse('pressed',0),false);
  c.CastSpell('spellbringer_future_reinforcements');
  assert.equal(sent.length,0);
  c.ShowTooltip('spellbringer_reveal');
  assert.equal(mouse('pressed',0),false,'UI clicks must not cast through buttons');
  c.HideTooltip();
  assert.equal(mouse('pressed',0),true);
  assert.equal(sent[0].data.target_z,500);
  assert.equal(sent[0].data.target_x,7500);
  assert.equal(mouse('pressed',1),false,'normal movement remains available');
  c.CastSpell('spellbringer_reveal'); mouse('pressed',1);
  assert.equal(sent.length,1,'cancel must not send a cast');
});
