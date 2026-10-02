# Active individual hero audit goal — owner revision, 2026-10-03

This owner-supplied revision extends the active thread goal; it does not close or
restart that goal. The owner's latest priority is reverse roster order, starting
with Lich; the reopened Sven review remains pending. Earlier
reviews must satisfy the added instrumentation and evidence requirements before
source completion is carried forward. No owner engine acceptance is implied by
this document. Local commits only; no remote push or Workshop publication.

Audit, repair, instrument, and validate all 40 release heroes individually in ENFOS Team Survival SametC Edition, covering Desktop update items 14–16 without dropping pending items 1–8.

Owner order correction, 2026-10-03: work through the release roster one hero at a
time in reverse roster order, starting with the last hero. Earlier unfinished
reviews, including Sven, remain explicitly pending and must not be dropped.
Do not substitute global scans, bulk assumptions, automated mocks, or
shared-framework inspection for a detailed individual hero review.

For every hero:

1. Read that hero's `AGENTS.md` and `ABILITIES.md`, together with the required repository research/runtime protocol and any applicable individual audit/runtime checklist.

2. Inspect every gameplay-relevant aspect of all five hero slots:
   - Q
   - W
   - E
   - R
   - fifth Enfos ability/passive

3. For every ability/passive, inspect and validate as applicable:
   - rank progression and 10-rank/level-50 compatibility
   - targeting rules
   - normal creep interaction
   - Boss interaction
   - damage
   - healing
   - attack records
   - critical strikes
   - cleave/splash
   - lethal-hit branches
   - modifiers
   - stack ownership
   - aura ownership and recipients
   - stun/root/silence/slow/control effects
   - status resistance
   - magic immunity behavior
   - Break behavior
   - basic/strong dispel behavior
   - death behavior
   - refresh/recast behavior
   - summons
   - projectile creation, travel, impact, dodge/disjoint behavior
   - channel start/end/interruption
   - Shard behavior
   - Scepter behavior
   - localization
   - ability and modifier tooltips
   - icons
   - particles
   - particle attachment and control points
   - particle lifecycle and cleanup
   - sound event banks
   - cast sounds
   - impact sounds
   - looping sound cleanup
   - cast/channel animations
   - precache/resource availability
   - modifier cleanup
   - particle cleanup
   - sound cleanup
   - death cleanup
   - reconnect-sensitive state
   - any hero-specific edge case documented in AGENTS.md, ABILITIES.md, audit notes, or current implementation

Validate the implementation against the current installed Dota build rather than relying only on stale historical behavior or assumptions.

For every ability, record an evidence-backed design disposition:

- KEEP
- TUNE
- PVE-CONVERT
- REPLACE

Do not change an ability merely because a different implementation appears cleaner. Preserve hero identity, contributor work, stable IDs, existing intended PvE behavior, and already-correct functionality unless there is concrete evidence supporting a change.

Diagnose proven defects and repair them with focused changes. Avoid broad speculative rewrites.

Run meaningful regression checks after each repair. Preserve unrelated contributor work and make isolated local commits for logically separate fixes.

## Mandatory hero ability isolation — owner addition, 2026-10-03

Ability isolation is part of this same individual audit goal, not a separate
optional cleanup. Apply it one reviewed hero at a time in the current owner
review order. Do not migrate all 40 kits in a bulk rewrite or postpone the
five-slot inspection in favor of a global refactor.

For each release hero, move its custom Q/W/E/R/D ability classes and exclusively
owned modifiers/helpers out of `game/scripts/vscripts/abilities/pve_kits.lua`
into `game/scripts/vscripts/abilities/heroes/<native_hero_slug>/`. Prefer a
separate Lua file per slot or coherent ability/modifier unit, with explicit
dependencies. New custom heroes must use this isolated structure from the start.
Keep verified native KEEP/TUNE abilities native; do not replace engine behavior
with custom Lua solely to satisfy a directory convention.

Before extraction, identify each class, modifier, local helper, shared state,
callback, precache dependency and cross-hero caller. Preserve stable hero/ability
and modifier IDs, global class registration, callback signatures, server/client
behavior, state ownership and intended correct PvE behavior. Moving files alone
does not justify numerical, design or lifecycle changes. Keep proven gameplay
repairs logically separate from behavior-preserving extraction where practical.

Keep truly shared gameplay/resource helpers in explicit shared modules and use
the existing common runtime trace helper and single debug flag. Do not copy a
private version into every hero, depend on another hero's local scope, or create
circular imports. Do not add timers, events, modifiers, searches or state changes
to make isolation or tracing easier.

Update the affected KV `ScriptFile`, `LinkLuaModifier` paths and explicit startup
loading where required. Preserve startup assertions, precache ownership and
class availability at cold start; ensure there is exactly one authoritative
definition of each extracted class. `pve_kits.lua` may remain a backward-compatible
loader/shared entry point while migration proceeds, but completed custom hero
implementations must live in their isolated modules.

Adapt existing structural audits, ability/mock tests, localization modifier
discovery and generated dossier inventories to follow actual KV/module ownership
rather than assuming all implementations are in `pve_kits.lua`. Keep production
KV authoritative and retain release-roster checks and hero-selection behavior.
Regenerate only affected derived inventories/mirrors and preserve handwritten
decisions and owner evidence. Do not create a competing content source.

For each extraction, verify Lua syntax, KV/class/modifier resolution, imports and
duplicate-definition absence; run the hero's meaningful behavior/trace regressions
and required shared/full checks. Compare before/after behavior for material
branches, including shared consumers and relevant death/refresh/recast/attack-record
paths. Record exact moved files, dependency decisions and test results. Owner
cold-start/full-restart tests must separately verify new script registrations,
modifier loading, resources and standardized traces; static checks and mocks do
not establish engine acceptance.

Record `ABILITY ISOLATION: COMPLETE / PARTIAL / PENDING` per hero, with a Q/W/E/R/D
module/ownership map, any justified native/shared exceptions and explicit remaining
work. `COMPLETE` means the custom kit is isolated and source/regression requirements
passed; owner runtime acceptance retains its separate status. Do not carry historical
source closure forward without reviewing the extracted implementation. Finish
material isolation and trace coverage before marking that hero's source review
complete.

## Mandatory standardized runtime trace instrumentation

As each hero is reviewed, add or verify a lightweight standardized VConsole runtime trace layer that allows owner-driven live tests to produce useful diagnostic evidence.

Use a consistent prefix based on the hero name:

`[HERO_NAME_TRACE][Q]`
`[HERO_NAME_TRACE][W]`
`[HERO_NAME_TRACE][E]`
`[HERO_NAME_TRACE][R]`
`[HERO_NAME_TRACE][D]`

`D` represents the fifth Enfos ability/passive slot.

Examples:

`[SVEN_TRACE][Q] cast caster=npc_dota_hero_sven target=enfos_wave_02 level=1`

`[SVEN_TRACE][Q] projectile_created handle=1073741938 speed=1000`

`[SVEN_TRACE][Q] impact target=enfos_wave_02 affected=6 damage=140 stun=1`

`[JUGGERNAUT_TRACE][E] attack_record_created record=123 target=enfos_wave_04`

`[JUGGERNAUT_TRACE][E] crit record=123 damage=425`

`[JUGGERNAUT_TRACE][E] attack_record_cleanup record=123`

`[JUGGERNAUT_TRACE][R] slash index=4 target=enfos_wave_05 total_slashes=7`

Trace events should capture meaningful runtime transitions and actual values when applicable, including:

- cast/start
- caster
- target
- target position
- ability level/rank
- projectile creation
- projectile impact
- affected target count
- damage
- healing
- control-effect duration
- modifier apply
- modifier refresh
- modifier removal
- stack gain/loss/count
- aura recipients
- summon creation/removal
- channel start
- channel finish
- channel interruption and reason
- attack-record creation
- attack-record consumption
- attack-record cleanup
- critical strike proc
- cleave/splash secondary target count
- lethal-hit branch
- Boss-specific behavior
- Boss caps
- status-resistance-adjusted effects
- Shard branch
- Scepter branch
- Break branch
- dispel branch
- death cleanup
- refresh/recast behavior
- particle creation/cleanup when custom particle ownership matters
- other important hero-specific runtime branches

Prefer structured runtime evidence over generic logging.

Good:

`[AXE_TRACE][R] execute target=enfos_wave_24 hp=310 threshold=450 result=executed`

Bad:

`Axe ult works`

## Trace safety requirements

Trace instrumentation is diagnostic only.

It must not alter gameplay behavior.

Do not introduce gameplay timers, modifiers, damage events, projectiles, particles, state, target searches, or cleanup operations solely to generate trace output.

Do not duplicate modifier cleanup, particle destruction, attack-record destruction, or state transitions merely for logging.

Trace code must tolerate dead, deleted, invalid, and null entities safely.

Avoid unbounded per-frame logging.

Periodic abilities may emit bounded diagnostic pulse summaries where useful, but VConsole must not be flooded.

Prefer one centralized/common trace helper or a consistent implementation pattern rather than 40 incompatible logging styles.

Trace output should be controlled by a single runtime debug flag or equivalent mechanism so detailed hero tracing can be disabled for production/Workshop delivery without removing the instrumentation.

Trace logging itself must not become a performance problem during dense waves.

## Runtime evidence rules

Owner alone launches and controls Dota and performs live tests.

The agent must never launch or control Dota on the owner's behalf unless separately authorized and technically available under the repository protocol.

When owner-supplied VConsole evidence is available, inspect it against:

- the hero's `AGENTS.md`
- the hero's `ABILITIES.md`
- current implementation
- individual audit findings
- expected ability behavior
- current Dota engine behavior

Use runtime trace evidence to determine whether intended runtime branches actually executed.

However, do not equate trace presence with complete engine acceptance.

VConsole can provide strong evidence for:

- casts
- projectiles
- impacts
- targets
- modifiers
- stack changes
- damage/healing
- channel lifecycle
- attack records
- cleanup paths
- Boss branches
- runtime errors
- missing resources

VConsole alone cannot prove that the following are visually or audibly correct:

- particle appearance
- particle positioning
- particle control points as seen by the player
- projectile appearance
- animation quality/correctness
- audible sound playback
- sound timing
- cosmetic appearance
- visual readability

Those require owner visual/audio confirmation.

## Per-hero findings ledger

Maintain a separate detailed findings ledger for every hero.

Do not collapse all 40 heroes into a single generic status.

For each hero record at minimum:

`SOURCE REVIEW: PASS / FAIL / PENDING`

`DESIGN DECISION: KEEP / TUNE / PVE-CONVERT / REPLACE` for every Q/W/E/R/D slot

`PROVEN DEFECTS: repaired / unresolved / none found`

`MOCK/REGRESSION VALIDATION: PASS / FAIL / PENDING`

`RUNTIME TRACE COVERAGE: COMPLETE / PARTIAL / MISSING`

`ABILITY ISOLATION: COMPLETE / PARTIAL / PENDING` with per-slot module/ownership paths and justified native/shared exceptions

`OWNER RUNTIME TRACE EVIDENCE: PASS / PARTIAL / FAIL / NOT TESTED`

`OWNER VISUAL/AUDIO VERIFICATION: PASS / PARTIAL / FAIL / NOT TESTED`

`OWNER ENGINE ACCEPTANCE: PASS / FAIL / NOT TESTED`

`REMAINING ENGINE-ONLY TESTS: explicit list`

If owner evidence exposes a failure, record the exact evidence and diagnose it before changing unrelated code.

If no owner test has occurred, explicitly record `NOT TESTED` or `PENDING OWNER TEST`.

Never convert missing evidence into PASS.

## Runtime acceptance discipline

Keep these three categories separate throughout the project:

1. CODE REVIEW
2. MOCK/REGRESSION VALIDATION
3. OWNER RUNTIME/ENGINE VERIFICATION

A hero is not engine-accepted merely because:

- source inspection passed
- `npm run check` passed
- mocks passed
- global scans found no issue
- trace instrumentation exists
- no Lua traceback appeared

A hero may only receive `OWNER ENGINE ACCEPTANCE: PASS` when sufficient owner live-test evidence has actually been supplied.

When owner runtime evidence confirms Q/W/E/R/D behavior but advanced edge cases such as Break, dispel, death, reconnect, Shard, Scepter, or Boss interactions remain untested, record the basic runtime pass separately and leave those specific advanced cases pending rather than treating the hero as fully accepted.

## Runtime trace completion requirement

Before source review for a hero is considered complete, ensure Q/W/E/R/D have sufficient trace coverage for important gameplay branches that cannot otherwise be reliably established from VConsole.

Do not instrument trivial getter functions or produce noise merely to increase trace coverage.

Trace the events that materially help diagnose whether the PvE implementation behaves correctly.

## Scope restrictions

Do not:

- investigate NVIDIA
- restore talents
- restore persistent progression
- restore removed mastery/permanent progression systems
- push remotely
- publish to Workshop
- treat Workshop publication as part of this goal
- silently redesign unrelated game systems
- overwrite unrelated contributor work
- change stable IDs without proven necessity
- claim engine acceptance from static analysis or mocks

## Working method

Proceed one hero at a time.

For each hero:

read documentation
→ inspect all five ability slots
→ compare against current Dota behavior
→ record KEEP/TUNE/PVE-CONVERT/REPLACE
→ identify proven defects
→ make focused repairs
→ isolate that hero's custom ability/modifier modules and update their explicit dependencies/KV paths
→ add/verify standardized runtime tracing
→ run focused regression checks
→ record findings
→ make isolated local commit
→ record owner-runtime requirements
→ continue to the next hero

Do not postpone individual review by replacing it with a global hero scan.

Global scans may be used as supporting evidence but never as substitutes for individual review.

## Completion criteria

The goal is complete only when all 40 release heroes have:

- an individual detailed review
- Q/W/E/R/D inspected individually
- an evidence-backed KEEP/TUNE/PVE-CONVERT/REPLACE decision for every slot
- proven defects repaired where feasible
- meaningful regression validation recorded
- standardized runtime trace coverage added or verified
- custom Q/W/E/R/D implementations isolated into hero modules, with justified native/shared exceptions and an individual isolation/dependency record
- a separate per-hero findings ledger
- code review status recorded
- mock/regression status recorded
- owner runtime status recorded separately
- remaining engine-only verification explicitly listed

Runtime acceptance may remain pending where owner testing has not yet occurred, but it must be explicitly recorded as pending rather than silently treated as complete.

Do not declare the overall goal complete merely because all automated checks pass.

Do not declare all 40 heroes engine-accepted unless owner live-test evidence actually supports that conclusion.
