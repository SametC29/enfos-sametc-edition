# IMPLEMENTATION ROADMAP

Sequence by risk. Never implement 40 heroes before the reusable systems are proven.

## Phase 0 — Repository/tooling foundation
- inspect existing addon/repo structure,
- confirm current Dota Workshop Tools build/run workflow,
- configure Git remote workflow,
- add build/config version,
- establish lint/static/data validators,
- logging utility,
- test RNG,
- one top-level checks command,
- document DEV/BETA vs LIVE release process.

Gate:
- minimal addon builds/starts,
- checks repeatable,
- one clean validated commit/push cycle.

## Phase 1 — High-risk technical POCs
Prove:
1. native Dota hero-selection experience with custom heroes.
2. flying courier + 6-slot/minimal delivery-buffer behavior.
3. normal Dota Shop coexisting with Ascended Shop UI.
4. two-team isolation + opponent camera visibility.
5. server-authoritative custom events.
6. persistence adapter can be unavailable without match failure.

Gate:
- no major architectural assumption remains speculative.

## Phase 2 — Map vertical slice
Build functional not final art:
- two mirrored team arenas,
- 2 normal lanes/team,
- central Boss lane,
- merge/split points,
- Life Core,
- boundaries,
- waypoints,
- TP anchors.

Add CreepAI:
- route,
- aggro/leash,
- Skyraker and Silencer control variants,
- stuck recovery.

Gate:
- no arena crossing,
- consistent Core routing,
- leak exactly once.

## Phase 3 — Wave/Life/cap
Implement:
- threat budgets,
- batching,
- uncapped scheduled hostile spawning,
- no population-based Life loss,
- Normal/Boss scheduler; Elite content is removed by owner direction,
- Boss transition with prior-wave hostiles retained,
- Endless skeleton.

Tests:
- cap 1–5 players,
- crowded-lane spawn delivery,
- summons no Life,
- Boss exemption,
- disconnect cap recalculation,
- no automatic cleanup or Life charge on wave/Boss deadlines.

Gate:
- accelerated 30+ wave cycles without unbounded entity growth.

## Phase 4 — Five reference heroes
Implement one role each:
Tank/Fighter/Carry/Mage/Support.

For each:
- Q/W/E/R,
- provisional Innate/skill plan,
- solo-clear path,
- Shard,
- Scepter,
- six in-match choice milestones using temporary unified-choice framework.

Gate:
- all five can solo representative baseline content,
- roles distinct,
- framework is generic.

## Phase 5 — Spellbringer
Implement separate mana and 8 abilities.

Test:
- enemy PvE targeting,
- no direct enemy-hero grief,
- Co-op offensive disabled,
- cap behavior,
- reconnect,
- abandon normalization,
- Future Reinforcements safe pool,
- no reward exploit.

## Phase 6 — Boss framework
Implemented candidate for all twelve Boss waves:
- one distinct release-roster hero per Boss wave, preserving the themed reward
  template,
- native Valve QWER and bot skill build, team-level scaling, and six core-item
  milestones at wave 60,
- no custom phase state, phase invulnerability or signature attack kit,
- bounded server AI, Boss-only scheduling and player-count health scaling.

Acceptance gate remains open until a live Tools match proves hero/model spawn,
native ability casts, target selection, item use, movement, rewards, Boon cadence,
and wave-60 level/item milestones without new VConsole errors.

## Phase 7 — Economy/courier
Implement:
- shared Gold,
- killer bonus,
- XP share,
- Lumber,
- conversion,
- transfers,
- Tomes,
- flying courier delivery.

Build economy simulator.

Gate:
- no duplication exploit,
- totals reconcile,
- simulator outputs income by player count/difficulty.

## Phase 8 — Ascended Shop
Implement framework + representative six items, then scale to 30.

Prove:
- base item consumed,
- Lumber,
- sellback,
- copy restriction,
- stacking caps,
- Boss caps.

Gate:
- simulated/playtested economy targets plausible.

## Phase 9 — Boons/Pacts
Implement:
- 2-card vote,
- candidate generation,
- recent weighting,
- stack/Unique,
- Pacts,
- opponent-visible history.

Gate:
- reconnect-safe, no repeat vote/invalid stack.

## Phase 10 — Persistent progression removed
Account XP, Legacy, Hero Mastery, permanent passive trees, account unlocks and post-match progression rewards are out of scope by owner decision (2026-09-30). Match-local hero levels, skills, economy and choices remain. Add a regression gate that no profile service or talent UI is loaded.

## Phase 11 — Localization foundation
Before content explosion:
- EN source,
- TR/RU/zh-CN,
- coverage validator,
- placeholder validator,
- opening/support panel data,
- diagnostics copy.

Gate:
- new systems contain no hard-coded player-visible strings.

## Phase 12 — Reference-analysis checkpoint

User inputs required:
1. Watcher of Samsara Workshop folder ZIP.
2. Enfo reference map file.

When supplied:
- analyze only,
- write reference reports,
- inspect concepts for talent/passive/Shard/Scepter/courier,
- inspect Enfo pathing/wave/Spellbringer concepts,
- finalize unified in-match choice system,
- finalize persistent Hero Passive pattern,
- revise reference heroes if beneficial.

Never copy their code/assets.

## Phase 13 — Full 60-wave content
Implement:
- 48 Normal,
- 12 Boss,
- five difficulties,
- transitions and Endless escalation.

Gate:
- target runtime ~30 min,
- no wave creates performance failure,
- difficulty is readable.

## Phase 14 — Scale roster to release 40
Internally expand:
5 → 10 → 20 → 40.

Every hero checklist:
- stable ID,
- role,
- solo-clear path,
- QWER + final Innate/skill model,
- unified in-match choices,
- Shard/Scepter,
- - EN/TR/RU/ZH-CN,
- Ascended interaction tests,
- Boss tests,
- performance benchmark.

Release gate:
- 8 heroes per role.

## Phase 15 — HUD/UX production
Polish:
- native hero selection if POC succeeded,
- Life/wave/difficulty,
- Boss UI,
- wave threat warnings,
- Spellbringer,
- Boon vote/history,
- build-choice queue,
- Gold/Lumber,
- Ascended Shop,
- results/progression,
- opening panel,
- accessibility/readability.

Gate:
- four-language smoke test,
- reconnect UI rebuild,
- no critical signal is color-only.

## Phase 16 — Public beta/live ops
Maintain separate DEV/BETA and LIVE Workshop addons.

Before LIVE:
- smoke,
- compatibility audit,
- economy simulation,
- localization validation,
- performance profiling,
- persistence migration,
- rollback plan.

Use telemetry after release.

## Long-term — 40 to 100 heroes
Expand in balanced 10-hero content waves:
40→50→60→70→80→90→100,
approximately +2 per role each wave.

Do not reduce quality to hit roster count.
