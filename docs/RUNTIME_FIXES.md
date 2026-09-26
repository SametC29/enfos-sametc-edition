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
