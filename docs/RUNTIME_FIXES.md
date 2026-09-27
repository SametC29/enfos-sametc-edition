# Playtest corrections — 2026-09-26

The selected map is Enfos survival, Workshop 3591082091. Both local map aliases
use its layout. Work remains local; do not push these changes.

## User-reported failures

- Native ability tooltips were blank. The engine log explicitly reported
  `LOCFAIL: Ignoring unsupported encoding` for resource and Panorama translations.
  The generator now emits a Unicode BOM, lowercase ability aliases and numeric
  compact descriptions. Numeric values still come from the ability KV. Other
  language files retain the existing Turkish fallback policy.
- WaveManager registered its callback with the wrong SetThink signature. It now
  uses SetContextThink, starts after GAME_IN_PROGRESS, respects pause, and stops
  at postgame. Empty teams receive no wave units. Batch rounding conserves unit
  counts; multiplayer bosses spawn once and use the existing health scaling.
- The HUD had no manifest entry or network-table declaration. The latter must be
  KV3, matching the installed Valve hero_demo example, not ordinary KeyValues.
- Eight same-team portals now use project-owned server logic at the map's existing
  locations. Only living real heroes can use them. Illusions, enemies and disabled
  heroes cannot teleport. A three-second lock plus leaving the arrival area before
  reuse prevents return loops even when the player stands still.
- Both overview files now use the Survival bounds: (-12864, 12864), scale 25.125.
  The stock hero marker remains engine-driven; no separate position polling UI.

## Next-wave button

The top HUD shows wave/state/countdown and both Life totals. A playing team member
may skip preparation only after both arenas have cleared and all batches have
finished. The first preparation cannot be skipped. The server validates identity,
team, state and remaining units; repeat clicks cannot enqueue additional waves.
Boss warning time remains. The current shared global wave clock is unchanged.
The HUD reads a snapshot on load and subscribes to changes for reconnects.

## Validation

`node tools/checks.mjs` covers 16 existing Lua tests, six additional wave/portal
behavior tests, native tooltip aliases, encoding, overview mapping and UI mirrors.
Valve resourcecompiler successfully compiled the HUD manifest and dependencies.
Source UI files live in content/panorama; runtime mirrors live in game/panorama.
The final live startup log confirmed game-mode and WaveManager initialization,
with no localization encoding failure or unknown wave_info table. Full interactive
acceptance is still open: the automated session hit a native FindClearSpaceForUnit
assertion at origin during hero selection, and later window capture/VConsole did
not provide a reliable playable view. Do not count those attempts as a gameplay pass.

Live acceptance must cover native tooltips at level zero and after upgrades, all
eight portals, minimap alignment while walking, wave 1 spawn, an early wave 2,
Boss warning, and reconnect/multiplayer behavior. Mock tests do not establish
navigation correctness or a balanced 60-wave release. The imported map still
references unused original entity scripts/custom particles; those are not copied.
# Hero origin fallback — 2026-09-27

User supplied a FindClearSpaceForUnit assertion for Drow at (0,0,0). The live log
shows the pick accepted before this assertion during pregame. Existing map data
has generic team starts but no Radiant/Dire-specific start classes. This is a
spawn-placement failure; the exact native fallback path is not proven offline.

`map/hero_spawns.lua` now creates three native team starts per arena during
InitGameMode, before selected heroes are created. The installed `dota.fgd`
documents these classes; Dota Workshop MCP confirms the spawn/respawn APIs.
Coordinates come from the approved map's existing base starts. A bounded ground
and navigation check rejects unsafe positions instead of falling back to origin.
Real player heroes receive team respawn positions. Only heroes at the central
origin fallback are relocated; repeat events cannot teleport a hero out of lane.
The compiled map is unchanged. Initialization logs each registered start.

Six mock-engine regressions and all repository checks pass (89 behavior tests
total). Native spawn lookup and navigation timing still require a fresh match;
the user explicitly owns live testing. No game launch/control was performed.
