import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';

const gameScript = 'game/panorama/scripts/custom_game/native_hud_controls.js';
const contentScript = 'content/panorama/scripts/custom_game/native_hud_controls.js';

test('native minimap controls retain only fortification, repurposed for Spellbringer', () => {
  const script = fs.readFileSync(gameScript, 'utf8');
  for (const id of ['RoshanTimerContainer', 'TormentorTimerContainer', 'RadarButton'])
    assert.match(script, new RegExp(`HidePanel\\(root, "${id}"\\)`));
  assert.match(script, /FindHudElement\(root, "glyph"\)/);
  for (const id of ['GlyphButton', 'RadiantGlyphButton', 'DireGlyphButton'])
    assert.match(script, new RegExp(`FindHudElement\\(root, "${id}"\\)`));
  assert.match(script, /button\.SetPanelEvent\("onactivate", ShowSpellbringer\)/);
  assert.match(script, /SpellbringerHud/);
  assert.equal(fs.readFileSync(contentScript, 'utf8'), script);
});

test('native HUD controller hides requested panels and toggles Spellbringer from glyph', () => {
  const panels = new Map();
  function makePanel(id) {
    const panel = {
      id, style: {}, classes: new Set(), events: {}, visible: true, enabled: true,
      hittest: true, hittestchildren: true,
      GetParent: () => null,
      GetPositionWithinWindow: () => ({ x: 10, y: 10 }),
      FindChildTraverse: name => panels.get(name) || null,
      ClearPanelEvent(name) { delete this.events[name]; },
      SetPanelEvent(name, callback) { this.events[name] = callback; },
      SetHasClass(name, on) { on ? this.classes.add(name) : this.classes.delete(name); },
    };
    Object.defineProperty(panel.style, 'visibility', {
      set(value) { assert(['visible', 'collapse'].includes(value), 'CSS value must not include a declaration semicolon'); this._visibility = value; },
      get() { return this._visibility; },
    });
    panels.set(id, panel);
    return panel;
  }
  const root = makePanel('DotaHud');
  for (const id of ['RoshanTimerContainer', 'TormentorTimerContainer', 'RadarButton',
    'StatBranch', 'LevelUpTab', 'level_stats_frame', 'StatBranchDrawer', 'StatBranchHotkey',
    'levelup', 'AbilityLevelUpButton', 'abilities', 'inventory_neutral_slot_container', 'inventory_neutral_level_up',
    'inventory_tpscroll_container', 'glyph', 'NormalRoot', 'GlyphButton', 'SpellbringerHud']) makePanel(id);
  // Simulate native Glyph cooldown: Valve may disable its button, but the
  // repurposed control must still open Spellbringer.
  panels.get('glyph').enabled = false;
  panels.get('GlyphButton').enabled = false;
  panels.get('NormalRoot').enabled = false;
  panels.get('NormalRoot').events.onactivate = () => { throw new Error('native Fortification must not fire'); };
  const $ = selector => panels.get(selector.slice(1)) || null;
  let retry;
  panels.get('LevelUpTab').events.onactivate = () => { throw new Error('talent tab must not open'); };
  Object.assign($, {
    GetContextPanel: () => root,
    Schedule: (_, callback) => { retry = callback; },
    Localize: key => key,
    DispatchEvent: () => {},
  });
  vm.runInNewContext(fs.readFileSync(gameScript, 'utf8'), {
    $, Game: { GetScreenWidth: () => 1280, GetScreenHeight: () => 720 },
  });

  for (const id of ['RoshanTimerContainer', 'TormentorTimerContainer', 'RadarButton',
    'StatBranch', 'LevelUpTab', 'level_stats_frame', 'StatBranchDrawer', 'StatBranchHotkey',
    'inventory_neutral_slot_container', 'inventory_neutral_level_up'])
    assert.equal(panels.get(id).visible, false, id);
  assert.equal(panels.get('LevelUpTab').events.onactivate, undefined);
  assert.equal(panels.get('AbilityLevelUpButton').visible, true);
  assert.equal(panels.get('levelup').visible, true);
  assert.equal(panels.get('abilities').visible, true);
  // A level-up/HUD rebuild can restore native visibility. The next refresh
  // must suppress the talent tab while leaving ordinary rank controls alone.
  panels.get('LevelUpTab').visible = true;
  panels.get('level_stats_frame').visible = true;
  panels.get('StatBranchDrawer').visible = true;
  assert.equal(panels.get('level_stats_frame').style.opacity, '0', 'parent remains transparent during native child refresh');
  // A HUD rebuild replaces the native frame, not just its visible flag.
  makePanel('level_stats_frame');
  retry();
  assert.equal(panels.get('LevelUpTab').visible, false);
  assert.equal(panels.get('AbilityLevelUpButton').visible, true);
  assert.equal(panels.get('level_stats_frame').style.opacity, '0');
  assert.equal(panels.get('StatBranchDrawer').visible, false);
  assert.equal(panels.get('levelup').visible, true);
  assert.equal(panels.get('inventory_tpscroll_container').visible, true);
  assert.equal(panels.get('glyph').enabled, true);
  assert.equal(panels.get('NormalRoot').enabled, true);
  assert.equal(panels.get('NormalRoot').hittestchildren, false);
  assert.equal(panels.get('GlyphButton').events.onactivate, undefined,'only the real root handles clicks');
  panels.get('NormalRoot').events.onactivate();
  assert(panels.get('SpellbringerHud').classes.has('Visible'));
  panels.get('NormalRoot').events.onactivate();
  assert(!panels.get('SpellbringerHud').classes.has('Visible'));
});

test('native talent and neutral item affordances are hidden while TP scroll stays intact', () => {
  const script = fs.readFileSync(gameScript, 'utf8');
  assert.match(script, /FindHudElement\(root, "StatBranch"\)/);
  assert.match(script, /HidePanel\(root, "inventory_neutral_slot_container"\)/);
  assert.match(script, /HidePanel\(root, "inventory_neutral_level_up"\)/);
  assert.doesNotMatch(script, /HidePanel\(root, "inventory_tpscroll_container"\)/);
});

test('next-wave action is absent from Spellbringer UI and client controller', () => {
  const layout = fs.readFileSync('game/panorama/layout/custom_game/spellbringer.xml', 'utf8');
  const script = fs.readFileSync('game/panorama/scripts/custom_game/spellbringer.js', 'utf8');
  const css = fs.readFileSync('game/panorama/styles/custom_game/spellbringer.css', 'utf8');
  assert.doesNotMatch(layout + script + css, /NextWave|SendNextWave|enfos_next_wave/);
});
