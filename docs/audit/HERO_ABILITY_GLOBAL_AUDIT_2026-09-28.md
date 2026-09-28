# Hero and ability global audit — 2026-09-28

## Scope and evidence

This is a repository-level discovery and triage report. It uses the checked-in NPC KV, shared ability implementation, test fixtures, structural contract inventory and prior review notes. Structural checks and mocked Lua execution do not prove Dota runtime behavior or validate Valve resource names. This pass did not inspect the installed Dota VPK, launch a game, or inspect VConsole.

## Architecture found

- The release roster is assigned through `game/scripts/npc/npc_heroes_custom.txt`; the current checked-in structural inventory identifies 40 heroes and 200 assigned ability slots.
- All 200 slots point at project-named abilities in `npc_abilities_custom.txt`, configured as `ability_lua` with a shared `abilities/pve_kits` script. Implementations and their modifier classes live together in `game/scripts/vscripts/abilities/pve_kits.lua`.
- `game/scripts/vscripts/addon_game_mode.lua` is the engine entrypoint. Its `Precache(context)` currently has a long, literal list of ability particles, five explicitly named hero sound banks, unit and hero precache calls, and other resources. This is a shared systemic audit surface; references and resource availability need to be reconciled against installed Valve data before changing paths.
- `game/scripts/vscripts/enfos_sametc.lua` initializes the game mode and delegates to existing wave, economy, scoreboard and other services. These integrations must remain intact during hero changes.
- Automated coverage includes KV/Lua syntax and contracts, a 40-hero structural inventory, mock-engine regressions and a rank sweep. These provide useful behavioral evidence but do not establish rendered VFX, played SFX, engine targeting or VConsole cleanliness.

## Global findings

1. The present roster is a full custom-Lua replacement surface: native hero kit slots have been replaced with custom IDs. The data reviewed here does not establish which individual replacements are necessary. Do not classify all 200 as D without comparing each original native ability and its current Valve data. An ability-by-ability KEEP/TUNE/PVE-CONVERT/REPLACE matrix with reasons remains necessary before new rewrites.
2. The structural scan passes 40 heroes / 200 entrypoints. It currently reports 64 abilities with unreferenced-special-field candidates. These are review candidates, not confirmed defects; historical review notes identify real semantic mismatches alongside legacy aliases.
3. The 2026-09-27 review documents previous functional repairs and passing mocked scenarios, while explicitly leaving runtime playtests pending. It specifically calls out delayed/persistent behavior (Underlord Firestorm, Jakiro Macropyre, Invoker Sun Strike/EMP), old radius/stat aliases and tooltip agreement for semantic review.
4. Particle and sound coverage scripts use source-text heuristics. For example, a helper-wrapped effect or an ability whose effect is inherited through a modifier may be reported as missing. Treat their alerts as leads, not failure proof. Verify literal native resources and sound events against installed game data before edits.
5. Precache code mixes shared setup and a large list of literal resources in the game-mode entrypoint. Audit whether every used resource is available and whether unrelated hero resources are loaded; do not mass-expand precache or invent replacements based on these static lists.
6. The initial `npm run check` failed two mocked behavior cases: Sven's `bulwark_challenge` calls `StartGesture`, but each of two independent mock-unit fixtures lacked that engine method. The production call may be valid; this was a test-fixture gap. Both mock environments now supply it so the regressions represent the engine API.

## Pilot sequence

Use three focused pilots to cover the outstanding risk patterns, retaining their existing stable IDs and designs pending native comparison:

| Pilot | Coverage and reason | Acceptance emphasis |
| --- | --- | --- |
| Jakiro | Existing review already covers manual/autocast Liquid Fire; Macropyre remains a delayed/persistent-effect semantic candidate. | Actual particle placement, repeated interval damage, timer/effect cleanup, sound and tooltip agreement. |
| Invoker | Ranged caster with delayed Sun Strike and persistent EMP behavior called out for follow-up. | Cast/travel/impact timing, target death, boss/elite behavior, resource visibility and cleanup. |
| Juggernaut | Melee channel/area effects and thinker cleanup; prior review states live area count is capped. | Repeated casts, channel interruption, area cap/expiry, particle/sound lifecycle and dense-creep performance. |

The classifications for individual abilities remain OPEN until the native counterpart and current installed data are compared. Do not treat pilot inclusion as a design approval or claim runtime completion before local Dota testing.

## Next work and status

- `npm run check` passes with zero failures after the mock fixture correction. It reports all 200 ability entrypoints and 210 modifiers exercised by mock runtime checks; these remain mock-engine results, not an in-game acceptance claim.
- Compare pilot assignments against current native Dota ability definitions and assets, recording source/build provenance. Then classify each pilot ability individually.
- Review the 64 unreferenced-special candidates semantically and align actual behavior, boss rules and EN/TR/RU/zh-CN tooltips.
- Build a small auditable resource/precache report tied to literal uses, with uncertainty labels for dynamic/helper-mediated references.
- Run pilot abilities in Dota and inspect visuals, audio and VConsole. Until this is done, runtime acceptance remains pending.

No hero ability implementation was changed by this audit. The only code adjustment is to the mock unit fixture so an engine method used by the existing ability is modeled in the regression environment.
