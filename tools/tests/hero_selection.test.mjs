import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import { parseKV } from '../lib/kv.mjs';

function screen(initialPicks = {}, options = {}) {
  const source = fs.readFileSync('content/panorama/scripts/custom_game/hero_selection.js', 'utf8');
  const heroes = parseKV(fs.readFileSync('game/scripts/npc/npc_heroes_custom.txt', 'utf8')).DOTAHeroes;
  const tokens = JSON.parse(fs.readFileSync('localization/english.json', 'utf8')).Tokens;
  const panels = new Map(), scheduled = [], sent = [], events = {};
  function panel(id) {
    const p = {id, classes:new Set(), children:[], handlers:{}, enabled:true,
      AddClass(c) { this.classes.add(c); },
      SetHasClass(c, on) { if (on) this.classes.add(c); else this.classes.delete(c); },
      SetImage(path) { this.image = path; },
      SetPanelEvent(name, fn) { this.handlers[name] = fn; },
      RemoveAndDeleteChildren() { this.children = []; }};
    panels.set(id, p); return p;
  }
  const root = panel('root');
  const $ = id => panels.get(id.slice(1)) || panel(id.slice(1));
  $.Localize = key => tokens[key.slice(1)] || key;
  $.GetContextPanel = () => root;
  $.Schedule = (_, fn) => scheduled.push(fn);
  $.DispatchEvent = () => {};
  $.Msg = () => {};
  $.CreatePanel = (type, parent, id) => { const p=panel(id || 'auto_'+panels.size); parent.children.push(p); return p; };
  const tables = {state:{remaining_time:90,picks:initialPicks}};
  for (const [id, hero] of Object.entries(heroes)) {
    const key='roster_'+hero.Role; tables[key] ??= {heroes:{}};
    const entries=tables[key].heroes;
    entries[Object.keys(entries).length+1] = {id,name:tokens[id],role:hero.Role,primary:hero.AttributePrimary,
      abilities:Object.fromEntries([1,2,3,4,5].map(i=>[i,hero['Ability'+i]]))};
  }
  const listeners={};
  const Game={state:4,GetState() { return this.state; }};
  const context={$, Game, DOTA_GameState:{DOTA_GAMERULES_STATE_HERO_SELECTION:4,DOTA_GAMERULES_STATE_STRATEGY_TIME:5},
    Players:{GetLocalPlayer:()=>options.localId ?? 0,GetTeam:id=>id===2?3:2},
    CustomNetTables:{GetTableValue:(_,key)=>tables[key]===undefined?null:JSON.parse(JSON.stringify(tables[key])),SubscribeNetTableListener:(table,fn)=>listeners[table]=fn},
    GameEvents:{Subscribe:(name,fn)=>events[name]=fn,SendCustomGameEventToServer:(event,data)=>{ if(options.sendError) throw new Error('transport unavailable'); sent.push({event,data}); }}};
  vm.runInNewContext(source,context);
  return {panels,root,scheduled,sent,context,Game,events,
    update(picks) { listeners.hero_selection_state('hero_selection_state','state',{remaining_time:40,picks}); },
    openTest() {tables.player_0={open:true,pending:false};listeners.hero_test_room('hero_test_room','player_0',tables.player_0);}};
}

test('Tools selection reopens the roster after lock and routes the next pick through the validated test event',()=>{
  const s=screen({'0':'npc_dota_hero_luna'});
  s.Game.state=10;s.events.game_rules_state_change();assert(s.root.classes.has('HeroSelectionHidden'));
  s.openTest();assert(!s.root.classes.has('HeroSelectionHidden'));
  const card=s.panels.get('Card_npc_dota_hero_slark');card.handlers.onactivate();
  s.context.EnfosHeroSelect.PickCurrentHero();
  assert.equal(s.sent.at(-1).event,'enfos_test_room_pick');
  assert.equal(s.sent.at(-1).data.hero_name,'npc_dota_hero_slark');
});

test('production roster shows 40 readable native names and five abilities per selection', () => {
  const s=screen();
  const cards=[...s.panels.values()].filter(p=>p.id.startsWith('Card_'));
  assert.equal(cards.length,40);
  for (const card of cards) assert.ok(card.children[1].text && !card.children[1].text.startsWith('npc_dota_'));
  s.panels.get('Card_npc_dota_hero_dazzle').handlers.onactivate();
  assert.equal(s.panels.get('ShowcaseHeroTitle').text,'Dazzle');
  assert.equal(s.panels.get('ShowcaseAbilities').children.length,5);
});
test('a missing or rejected pick response re-enables selection instead of claiming success', () => {
  const s=screen(); s.context.EnfosHeroSelect.PickCurrentHero();
  assert.equal(s.sent.length,1);
  assert.equal(s.panels.get('PickHeroBtn').enabled,false);
  assert.equal(s.panels.get('PickHeroBtn').classes.has('LockedIn'),false);
  s.scheduled.shift()(); assert.equal(s.panels.get('PickHeroBtn').enabled,true);
});
test('server acknowledgement and reconnect restore a locked hero', () => {
  const s=screen(); s.context.EnfosHeroSelect.PickCurrentHero();
  s.update({0:'npc_dota_hero_sven'}); s.scheduled.shift()();
  assert.equal(s.panels.get('PickHeroBtn').classes.has('LockedIn'),true);
  assert.equal(s.panels.get('PickHeroBtn').enabled,false);
  const reconnect=screen({0:'npc_dota_hero_luna'});
  assert.equal(reconnect.panels.get('ShowcaseHeroTitle').text,'Luna');
  assert.equal(reconnect.panels.get('PickHeroBtn').enabled,false);
});
test('a teammate pick disables that card, an opposing pick does not', () => {
  const s=screen({1:'npc_dota_hero_sven'});
  assert.equal(s.panels.get('PickHeroBtn').enabled,false);
  s.context.EnfosHeroSelect.PickCurrentHero(); assert.equal(s.sent.length,0);
  s.update({2:'npc_dota_hero_sven'}); assert.equal(s.panels.get('PickHeroBtn').enabled,true);
});
test('selection hides outside the engine selection and strategy states', () => {
  const s=screen(); assert.equal(s.root.classes.has('HeroSelectionHidden'),false);
  s.Game.state=5; s.events.game_rules_state_change(); assert.equal(s.root.classes.has('HeroSelectionHidden'),false);
  s.Game.state=10; s.events.game_rules_state_change(); assert.equal(s.root.classes.has('HeroSelectionHidden'),true);
});
test('a transport exception releases the pending button immediately', () => {
  const s=screen({}, {sendError:true});
  s.context.EnfosHeroSelect.PickCurrentHero();
  assert.equal(s.panels.get('PickHeroBtn').enabled,true);
  assert.equal(s.panels.get('PickHeroBtn').classes.has('LockedIn'),false);
  assert.equal(s.scheduled.length,1);
});
test('late local-player identity does not strand server acknowledgement', () => {
  const options={localId:-1}; const s=screen({}, options);
  options.localId=0;
  s.context.EnfosHeroSelect.PickCurrentHero();
  s.update({0:'npc_dota_hero_sven'});
  assert.equal(s.panels.get('PickHeroBtn').classes.has('LockedIn'),true);
});
