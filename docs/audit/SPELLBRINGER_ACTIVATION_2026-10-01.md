# Spellbringer activation and targeting — 2026-10-01

Status: **IMPLEMENTED; NOT ENGINE-VERIFIED**.

## User-facing failure

The Fortification Glyph was repurposed as the Spellbringer window opener. A
replacement `onactivate` handler alone did not clear the native button's disabled
state. During the Glyph charge/cooldown, Panorama can keep the inner control
disabled, so the Spellbringer UI cannot receive a click even though the server
mana/cooldown system is separate.

Point-target casts also had a stale server bounds check: it rejected every world
position above `y=4500`, even though the authored lane starts reach `y=11563`.
The separate `abs(x)<3000` exclusion blocked navigable central terrain. These
checks ran before effect dispatch, so a valid selected point never reached the
spell behavior.

## Change

- The HUD controller now keeps the Glyph container and verified activation
  roots enabled, then routes activation to the Spellbringer toggle. It
  continues to retry after HUD rebuilds and does not invoke the native Glyph
  action.
- The game and content Panorama copies are byte-identical.
- Existing point targeting still waits for a world position before sending the
  cast request; right-click cancels without spending mana. The server rejects
  invalid positions and charges mana/cooldown only after an execution succeeds.
- The point-target envelope now covers the authored map range (`-12000..12000`
  on x/y), while retaining defending-side ownership, finite-coordinate, and
  server `GridNav:IsTraversable` / `GridNav:IsBlocked` checks. Valid lane-start
  targets up to the authored `y=11563` route point no longer fail the stale
  `y=4500` cutoff; the arbitrary center x dead zone is removed.
- The 8 server-side ability definitions remain registered with distinct
  mana/cooldown/radius/duration data where applicable. Summons use the cursor
  location and route from the nearest lane waypoint.

## Evidence and verification

- Source2Viewer-CLI 19.2 decompiled the current installed native
  `panorama/layout/hud/dota_hud_glyph.vxml_c` without launching Dota.
  `NormalRoot` owns `DOTAHUDActivateGlyph()`; its child is `GlyphButton`.
  Spectator counterparts are `RadiantRoot`/`RadiantGlyphButton` and
  `DireRoot`/`DireGlyphButton`. The previous inner-only binding missed the
  native parent handler. The controller now binds the verified root panels
  and disables child hit testing so a click reaches exactly one handler.
  Button/container fallback is retained for layouts without those roots.
  Engine hit testing/HUD rebuild behavior still requires owner acceptance.
- Current Panorama API metadata confirms `GameUI.GetScreenWorldPosition` returns
  `[x, y, z] | null`, matching the client indexing. Current VScript API metadata
  confirms the server GridNav traversability/block checks used after bounds
  validation. The authored Radiant/Dire route tables provide map-coordinate
  limits, including lane starts at y=11,364 and y=11,563.
- Regression test simulated a native cooldown by disabling the Glyph container
  and NormalRoot before initializing the controller. It verifies the native
  parent handler is replaced and one root activation toggles the popup once.
- Lua mock-engine audit tests verify the three point-target summon abilities
  use the cursor position, apply their lifetime/aura setup, and route Rift Surge
  units; Whole Displacement moves nearby regular hostiles to the lane start but
  leaves bosses and out-of-radius units in place; Reveal publishes FOW and
  periodically grants True Sight to nearby registered hostiles. Existing tests
  cover Arcane Barrier, Purification, Future Reinforcements, neutral-hostile
  team resolution, mana/cooldown, target validation and co-op restrictions.
- Added explicit modifier-effect checks: Arcane Barrier blocks exactly its
  remaining 300 magical damage and ignores physical damage; War Standard's aura
  filters by defending-team identity and grants its authored damage/move bonus;
  Thorn Idol reflect is bounded and carries a reflection flag to prevent loops.
  Future Reinforcements separately assert player control, wave scaling, timed
  cleanup and zero leak penalty.
- These mocks verify the server code path and arguments only. They do not prove
  Source 2 visibility, placement legality, modifier lifetime, actual damage,
  particles/sounds or multiplayer replication.
- `node tools/tests/native_hud_controls.test.mjs`: PASS, 4 tests.
- `node tools/tests/spellbringer.test.mjs`: PASS, world targeting/cancel test.
- `node_modules/.bin/fengari tests/audit_regressions.lua`: PASS, 19 tests,
  including the full server-event path for a click at y=11,364.
- Added regression coverage for a valid authored lane-start point, navigable
  center-side coordinates, and an out-of-envelope rejection.
- `npm run check`: PASS, zero failures.
- Latest Dota Workshop MCP `addon_audit`: PASS, 34 VScript and 11 Panorama files, zero
  findings.
- Per owner direction, runtime Spellbringer testing is reserved for the owner;
  Codex must not launch or interact with Dota. All eight abilities remain
  pending live acceptance despite passing static/mock checks.

## Acceptance still required

Open a fresh match and click the Spellbringer control while Fortification is
ready and while its native charge display is unavailable. In both states the
Spellbringer panel must open; no Fortification must fire. Then use each of the
eight abilities on an intended world point and confirm mana, cooldown, effect,
and selected location in the game. Until that test passes, this is not a runtime
fix certification.
