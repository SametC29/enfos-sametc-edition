# Local hero test arena — 2026-10-04

Owner request: a separate, small square `enfos_test` map. Hero level 10,
ordinary ability progression rules, native Scepter and Shard, ten ordinary
creatures and one Boss around the selected hero. Live engine validation deferred
to the owner; no remote player log collection or publication authorized.

## Implementation

- Local addon registration includes `enfos_test` for one player; default remains
  `enfos`. The release packager removes the test map and its registration.
- Source: `content/maps/enfos_test.vmap`, derived from the installed Valve
  `addon_template/maps/template_map.vmap`. Reproduce offline with
  `node tools/build_test_map.mjs`, then compile `enfos_test` with the Workshop
  resource compiler. The builder never touches canonical Enfos.
- 12 × 12 tiles: 3072 × 3072 world units, centered at the origin. Flat combat
  floor, raised perimeter, four template-native tree placements at corners.
  All cell, vertex, edge and object arrays resized together.
- Existing hero-selection screen. Tools + exact test map automatically enables
  the server mode; regular Enfos cannot enable it. Existing native spawn markers
  use small test coordinates and Enfos portal polling is omitted on this map.
- Existing match XP curve advances level 6 to 10 through AddExperience. No
  writes to ability ranks or point totals. Nine ordinary points plus the
  separately granted Enfos passive rank; existing rank gates remain in force.
- Native Scepter item and native Shard consumption; upgrade state reconciles
  through the existing manager. Preparation fails if either upgrade is absent.
- Existing wave-one creep definition and wave-five Sven Boss definition,
  resource gate and Boss framework. Eleven bounded target placements; zero
  target XP/gold. No scheduled waves or Life leaks in the test mode.
- Localized HUD actions: reset targets, refresh health/mana/cooldowns, print
  read-only hero Health. Server validates ownership and throttles requests.
  Reset clears previous tracked targets and Boss registrations; no XP/item
  grants repeat. Partial spawn failures clean up and require explicit retry.
- The owner-test log proved that the original return button's `SendToConsole`
  command was rejected by the engine's required FCVAR flag. The repair opens
  the existing roster during gameplay and sends a separate validated pick to
  the server. `PrecacheUnitByNameAsync` completes before native
  `PlayerResource:ReplaceHeroWith`; the new hero's normal spawn path then
  receives starting points and test preparation. Target cleanup occurs before
  selection; the server checks the mode, owned hero, roster entry and pending
  switch. The engine swap and any old-hero summons still need live verification.
- The log also showed `GetAbilityByIndex` warnings for indices 23–31. The
  refresh scan now stops at 22, the observed highest safe index in this build.

## Evidence and pending acceptance

Resource compiler succeeded: 20 compiled, 0 failed; playable test VPK 421798
bytes. Offline terrain preview confirms the small square and 48 raised perimeter
vertices. Focused tests cover mode isolation, automatic startup, resource waits,
ordinary leveling, reset cleanup, failure recovery and invalid client actions.
Focused tests cover selection authorization, resource wait and native swap
sequencing. Full checks remain a required gate after the repair.
The native Panorama compiler also accepted the test layout, CSS, JavaScript and
HUD manifest. It caught a prohibited root panel ID during authoring; the final
layout uses a root wrapper and an identified child panel.

The terrain workflow was checked against Valve's
[Dota map authoring documentation](https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Level_Design/Creating_A_Dota-Style_Map)
and the installed template's current DMX arrays, rather than the retired Enfos
placeholder generator.

**Engine acceptance pending.** Owner must load `enfos_test` in Workshop Tools
after restarting the addon, select a hero, and check level/points, native upgrades,
10 creatures + Boss, reset/refresh/Health, death/respawn, tree usability,
navigation and VConsole errors. Source compilation and mocks do not prove these
runtime behaviors. No game was launched for this work.
