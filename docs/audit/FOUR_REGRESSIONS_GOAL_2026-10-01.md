# Four owner-reported regressions — active goal, 2026-10-01

This is a continuation record, not runtime certification.

Delivery status is now superseded by
`FOUR_REGRESSIONS_IMPLEMENTATION_2026-10-01.md`; the chronological notes below
retain earlier investigation and staging states. Do not treat their old pending
commit/push descriptions as the latest status.

## Current evidence

- Installed `game/dota_addons/enfos_sametc` is a junction to this checkout's
  `game` folder. NPC, waves, Spellbringer, entrypoint and HUD controller hashes
  match. File deployment mismatch is ruled out for these sources; loaded
  engine/KV/Panorama cache has not been checked.
- Native talent tab: implemented in commit `8d9f95d`. See
  `TALENT_TAB_REGRESSION_2026-10-01.md`. HUD mock tests pass; owner level-up
  rendering and ability point spend tests remain pending.
- Defensive Reveal: working tree now routes `CastReveal` and thinker defaults
  to the caster's defending team. The previous code selected the opponent's
  incoming-wave registry despite own-side cast validation. New both-team
  cast/thinker regression passes. See `TRUE_SIGHT_2026-10-01.md` follow-up.
  The service already had many contributor edits on entry. Required neutral
  hostile lookup and summon-registration dependencies were isolated in a
  focused commit; other spell/cast-range edits remain unstaged.
- Elites: `19a215c` isolates and commits the eight normal replacement slots,
  NPC/framework/Boon retirement, relevant four-language/loading text, tests
  and production wave economy. The isolated 300-plan/player test and production
  economy check pass. Full isolated `tests/run.lua` proceeds past Elite/Life
  tests but hits a stale existing Boss percent-health-cap assertion. Remaining
  native-Boss integration tests must resolve that before final delivery.
  Fresh-match all-eight-slot evidence is still needed; no engine acceptance.
- Bosses: the old unit-model report checks legacy `enfos_boss_*` templates,
  while scheduled Bosses spawn the twelve native heroes in `BOSS_HEROES`.
  Those are different resource paths. `4ed43ba` adds asynchronous actual-unit
  loading during the warning and a batch/deadline gate until completion.
  Delayed callback, deduplication, match reset and failure mocks pass both in
  the current candidate and an isolated staged-tree copy. All twelve real
  native hero base models resolve in the installed VPK through the new
  `tools/verify_boss_resources.mjs`. That optional verifier is still untracked
  until the native hero mapping dependencies are committed. This confirms a
  missing loading dependency, not yet the observed ERROR model's engine cause.
  See `BOSS_RESOURCE_GATE_2026-10-01.md` for owner acceptance.

## Checks and delivery

`npm run check` passes after completing the smoke mock's missing forced-target
getter/setter (commit `734139f`, test infrastructure only). New defensive Reveal
test and existing audit tests pass. Tests are mocks/static, not engine evidence.
No gameplay/VConsole acceptance has been performed. Dota is running with
VConsole connected but no buffered logs; historical owner direction in
`DECISIONS_OPEN_ITEMS.md` and Boss/True Sight reports says not to launch or
interact with Dota, so engine work remains owner-gated.

Fetch succeeded. The initial push returned a missing-upstream error; the
subsequent `push --set-upstream origin codex/project-hardening` completed
successfully (terminal 31813, exit 0). The branch now tracks its remote; that
push delivered through `8d9f95d`. Later Boss/Reveal/Elite commits still need a
new push after final isolated dependency/test validation.
Preserve the large pre-existing contributor worktree; do not stage it wholesale.
The isolated staged-tree Reveal-specific test passes for both teams. The first
broader audit run failed in the sparse Spellbringer barrier fixture (not route
AI): it omitted production unit IDs/defending-team metadata required by the
new shared registry query. The focused fixture update was staged independently
of contributor tests; all fourteen isolated audit regressions then passed.
`aaf9fb7` contains Reveal and registry dependencies. The full current worktree's
`npm run check` also passes. These results remain mock/static evidence only.

The full goal remains active: HUD, Reveal and Boss loading now have focused
code/mock evidence. Elite retirement is now committed too. Remaining scoped
delivery includes native-Boss mapping/reward/AI dependencies and talent-point /
hidden-slot removal that were already in the contributor candidate. Preserve
unrelated hero/ability edits. Dependency delivery and all four engine acceptance
gates remain open; do not promote current-worktree checks to committed-tree or
engine certification.

## Latest delivery checkpoint

Talent runtime dependencies are committed in `f2b477d`. Native Boss dependencies
have also been committed after an isolated index copy passed all nine focused
checks across HUD, forty-hero slots/level budget, Elite plans, Reveal, async
resources and native Boss spawn/reward/Life pipeline. The installed-data native
kit audit also passes for all twelve. The model verifier now accompanies its
authoritative mapping. These focused checks passed on the actual staged tree,
not just the contributor candidate.

Remaining delivery checks: old whole-repo validator/test contracts still assume
removed talent definitions/profile lifecycle and legacy Boss attacks/percent-HP
cap; update only affected expectations and any required modern AbilityValues
reader dependencies, preserving unrelated contributor hero work. Do not push
remaining commits as whole-repo green before these relevant gaps are addressed.
Then push once, verify the remote SHA, and record final owner acceptance steps.
The whole current candidate remains separately green under `npm run check`.
Real Dota/VConsole visibility/rendering acceptance is still absent, and the
historical no-live-interaction owner constraint remains unresolved.
