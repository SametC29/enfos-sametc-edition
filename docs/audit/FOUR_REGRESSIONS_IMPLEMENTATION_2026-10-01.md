# Four regressions — implementation delivery, 2026-10-01

Status: **IMPLEMENTED BUT NOT ENGINE-VERIFIED; goal remains active.**

This is the current delivery record and supersedes intermediate status in
`FOUR_REGRESSIONS_GOAL_2026-10-01.md`. Existing unrelated contributor changes
were preserved and were not committed wholesale.

| Owner report | Code cause / change | Evidence and limit |
|---|---|---|
| Talent `+` returns after leveling | `StatBranch` suppression missed Valve's separate `LevelUpTab`, which opens the branch. Hide/disable that tab on HUD refresh; hide all forty heroes' talent/attribute slots, remove custom talent KV and unload talent/profile startup/restore hooks. | Installed Valve layout and HUD refresh mock; forty-hero contract and match-level budget tests pass. Actual HUD/rank-up/point spend and reconnect remain pending. |
| Elite creatures still spawn | Eight authored slots still referenced Elite types/NPC IDs. Replace with normal compositions; remove Elite NPCs, framework hooks and Boon; update four-language wave/loading text. | All sixty plans at 1..5 players: 48 normal/12 Boss-only, no Elite IDs. NPC/framework/Boon contract passes. Fresh-match all-eight-slot spawn verification remains pending. |
| All Boss models are ERROR | Prior model audit covered old reward templates, while actual Bosses use native hero IDs without a matching precache dependency. Request the scheduled actual unit asynchronously and retain its batch/deadline until the callback. Preserve native preparation, reward alias, Boss Life penalty and routing. | All twelve actual native Model fields resolve in installed VPK. Async/dedup/reset/failure tests and all-twelve kit/spawn/reward/Life mocks pass. Missing loading dependency is established; its causality for the rendered ERROR report, wearables/materials and actual callback behavior remain pending. |
| Reveal does not reveal invisible creatures | Defensive point validation selected own side, but thinker searched the opponent's incoming-wave registry. Use caster defending team in cast and thinker default; retain neutral-hostile registry/radius lookup. | Both teams' cast/create/tick/default tests and shared sparse-registry regression pass. True Sight/Fog rendering, actual targetability, expiry and outside-radius behavior remain pending. |

## Validation scope

On an isolated copy of the actual staged delivery tree:

- Nine focused Node tests: PASS (HUD, talent/level budget, Elites, Reveal,
  resource gate and native Boss pipeline).
- Forty-two Lua behavior tests: PASS, after replacing obsolete removed-talent,
  persistent-profile and legacy-Boss attack/cap assertions with current contracts.
- Production economy audit: PASS, all 300 wave/player configurations, retaining
  themed reward IDs behind native Boss aliases.
- Installed-data native kit audit: PASS for all twelve heroes, four trained
  native abilities and the configured final build; toggle tests pass.
- Installed actual Boss base-model lookup: PASS for all twelve.
- Relevant staged diff whitespace check: PASS.

The full contributor worktree separately passed `npm run check` with zero
failed checks. That does not certify the unrelated committed-tree validators
or unrelated hero inventories. No engine playtest, VConsole gameplay capture,
audio check or visual acceptance was performed. Mock pass is not ENGINE_PASS.

## Source and research records

See `TALENT_TAB_REGRESSION_2026-10-01.md`,
`TALENT_RUNTIME_REMOVAL_2026-10-01.md`, `ELITE_REMOVAL_2026-10-01.md`,
`TRUE_SIGHT_2026-10-01.md`, `BOSS_RESOURCE_GATE_2026-10-01.md` and
`NATIVE_BOSS_DELIVERY_2026-10-01.md` for source/API/reference provenance,
changed files and per-issue acceptance. No external code or custom assets
were imported. The installed Valve sources and API are primary evidence;
external examples were reference only.

## Git delivery

Focused implementation and test commits are published on
`origin/codex/project-hardening` through
`38d8c07bbee1eba68222ab11db768f65ae6ea2f6`. Push exited successfully and an
independent `ls-remote` confirmed that exact SHA. No force-push or history
rewrite occurred. Principal commits: `8d9f95d` HUD; `4ed43ba` resources;
`aaf9fb7` Reveal; `19a215c` Elites; `f2b477d` talent lifecycle;
`4231743` native Boss dependencies; `38d8c07` old contract updates.

## Remaining owner gate

The repository's historical owner direction prohibits Codex launching/restarting
or interacting with Dota for this work. A clarification was requested once:
allow local Dota/VConsole testing, or retain owner-operated tests. No response
has been received; automatic goal continuation is not authorization.

Required fresh-map tests (KV/HUD changes need full reload): level-up without any
talent/attribute tab or extra points while normal ranks remain trainable; all
eight former-Elite slots; all twelve visible native Bosses in both arenas;
invisible Assassin under Reveal for both teams, in/out of radius and after
expiry, including Fog of War. Verify no new Lua/compile/resource warnings,
duplicate spawns/points or reward/Life regressions. Record actual screenshots,
VConsole output and PASS/FAIL before closing the gameplay goal.
