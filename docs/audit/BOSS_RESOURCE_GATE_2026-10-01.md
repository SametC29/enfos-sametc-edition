# Actual Boss resource loading — 2026-10-01

Status: IMPLEMENTED BUT NOT ENGINE-VERIFIED.

## Problem and source evidence

The owner reports every Boss as an ERROR model. Scheduled Bosses now spawn
native hero IDs from `WaveDefinitions.BOSS_HEROES`; the twelve old custom
`enfos_boss_*` entries serve as reward/balance templates. The entrypoint only
precaches models from `npc_units_custom.txt`, so its successful old-template
VPK audit did not cover the actual entities. WaveManager called synchronous
`CreateUnitByName` without first loading the selected native hero resources.
This is a confirmed missing resource-loading dependency. Its responsibility
for the observed rendering remains a hypothesis until a cold Dota test.

## Change and classification

TUNE of Boss resource preparation; native QWER, items, model names, scale,
wave composition, rewards and player hero abilities are preserved. On the
five-second Boss warning, the actual scheduled unit is requested through
`PrecacheUnitByNameAsync`. Direct `StartWave` also requests it for developer
wave jumps. A match-local gate deduplicates requests across both teams and
allows the batch and combat deadline only after the callback. It loads the
unit through the engine, including resources the base-model-only audit cannot
cover. Normal waves do not wait for this gate. Failure cannot authorize spawn;
requests/errors/completion and a 30-second unresolved wait are logged once.
Late callbacks mutate only their original match's state.

This avoids the previous all-hero synchronous bootstrap stall. It uses the
existing wave lifecycle rather than adding a duplicate wave manager.

## Research and provenance

- Current MCP Lua API: `PrecacheUnitByNameAsync(unitName, callback, playerId?)`,
  server-side, callback on completion.
- API cross-check: https://docs.moddota.com/lua_server/declaration
- Concept/reference only: Boss-Hunters uses the callback-before-create pattern:
  https://github.com/Yahnich/Boss-Hunters/blob/master/game/scripts/vscripts/addon_game_mode.lua
- Valve tutorial also requests native hero precache asynchronously:
  https://github.com/SteamTracking/GameTracking-Dota2/blob/master/game/dota_addons/tutorial_basics/scripts/vscripts/addon_game_mode.lua
- No external code/assets imported. Current installed Valve model sources are
  checked by `node tools/verify_boss_resources.mjs` for all twelve mapped heroes.

## Verification and pending owner gate

The resource-gate mock exercises delayed completion, shared requests, retained
Boss batch/deadline, eventual one spawn per active team, match-reset callback
isolation, normal-wave bypass and resource failure. Existing native Boss kit
and wave regressions remain required. These checks do not simulate loading,
wearables, materials or client rendering.

Owner test: full fresh-map restart; do not select the scheduled Boss heroes as
players first. Observe all twelve Boss waves (5..60), both team arenas and a
second client. Each Boss must use its intended visible native model at double
normal scale; no ERROR models or resource/compile warnings. Check
`boss_resources` request/completed logs precede each spawn, no lost/duplicate
Bosses, and ordinary combat/rewards/Life/next-wave behavior. Capture VConsole
and visuals. If the problem persists after successful callbacks, inspect the
spawned entity's actual model, mounted KV and client resource warnings rather
than adding guessed model paths. Per historical owner direction, no Dota
launch/restart or live game mutation was performed during this pass.
