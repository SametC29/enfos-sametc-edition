# Luna native-first pilot — pre-migration evidence

Scope: `npc_dota_hero_luna` only. This is the decision record before major
migration, not a delivery certificate. OWNER ENGINE ACCEPTANCE: NOT TESTED.

## Source review

The installed build is ClientVersion **6943**, SourceRevision **11069754**,
VersionDate **Oct 01 2026**. The previous dossier described build 6941.
Read-only extraction from the installed `game/dota/pak01_dir.vpk` confirmed
`scripts/npc/heroes/npc_dota_hero_luna.txt` SHA256
`96f7fb3388afcc02ac071da9beeb97f53ae5ea2ae41b95c172c16434fa60e747`.
The Luna source hash is unchanged despite the build change. The exact five
AbilityDefinitions and current build are recorded in
[LUNA_NATIVE_SOURCE_2026-10-03.json](LUNA_NATIVE_SOURCE_2026-10-03.json).
No game was launched or controlled.

Relevant existing evidence: `docs/heroes/luna/ABILITIES.md`, production Luna
definitions at `game/scripts/npc/npc_abilities_custom.txt`, Lua at
`game/scripts/vscripts/abilities/pve_kits.lua`, Luna cases in
`tests/hero_kit_regressions.lua`, and Luna content/rank contracts in
`tools/tests/content_contracts.test.mjs`. The previous impact-timing fix and
four-language tooltip work are reused as evidence, not engine acceptance.

[ModDota's author-maintained KV reference](https://moddota.com/abilities/ability-keyvalues)
documents native ability BaseClass aliases and warns that their C++ internals
cannot be changed through KV. This supports testing aliases; it does not prove
Luna's linked-ability lookup or ten-rank behavior. No external custom-game code
or assets are imported.

## Decision matrix before major migration

These are preferred implementation candidates. Final decisions require checking
the identified integration constraints; native internal behavior remains
PENDING OWNER TEST. KEEP/TUNE classification refers to the native mechanic,
not approval of the previous custom recreation.

| Slot | Current stable ID / implementation | Installed counterpart | Preferred decision / class | Evidence and migration constraint |
| --- | --- | --- | --- | --- |
| Q | `enfos_luna_lucent_beam`: custom damage, stun, three secondary hits and particles/sounds | `luna_lucent_beam` | NATIVE + MINIMAL ENFOS EXTENSION / TUNE | Native unit-target magical Beam supplies cast, targeting, stun, animation and feedback. Keep explicit ten-rank damage/cost/cooldown data; isolate any retained authored agility scaling. Native Eclipse's Beam lookup must be resolved before deleting the custom Q/R link. |
| W | `enfos_luna_lunar_orbit`: custom radial pulses, range/speed/mitigation buff | `luna_lunar_orbit` | NATIVE + MINIMAL ENFOS EXTENSION / TUNE | Native orbit has actual rotating-glaive collision, attack-derived physical damage, mitigation, movement and Shard values. The current radial pulse implementation is a different mechanic. Native scaling keys must replace pulse-only data; any retained ENFOS stats must be a small extension. |
| E | `enfos_luna_lunar_blessing`: ranked damage/armor/movement aura | `luna_lunar_blessing` | NATIVE + MINIMAL ENFOS EXTENSION candidate / TUNE | Installed Blessing is hidden, one-rank, innate, level-scaled and breakable. It provides damage and night vision, not the custom armor/movement bonuses. Native paid-rank metadata and level scaling need explicit treatment; a custom fallback must be justified if innate ownership cannot support the ENFOS paid E slot. |
| R | `enfos_luna_eclipse`: custom timed random beams and per-cast Boss HP cap | `luna_eclipse` | NATIVE + MINIMAL ENFOS EXTENSION / TUNE | Native Eclipse supplies beam scheduling, targeting, darkness, resources and Scepter integration. Installed R exposes no independent beam damage field; native Beam linkage is an engine-only question for aliases. Keep a minimal linkage/scaling integration if necessary, never a recreated beam scheduler. Remove the Luna-authored Boss cap. |
| D | `enfos_luna_moon_glaives`: custom attack hook, preselected bounce chain and tracking projectiles | `luna_moon_glaive` | NATIVE with ENFOS KV tuning candidate / TUNE | Current D is Moon Glaives, not an unrelated ENFOS-only passive. Native breakable passive exposes range, bounce count and reduction. Prefer engine-owned attack records, bounce travel and hits; retain separate free D rank and paid ranks. Do not move it to W without an owner kit decision. |

## Ten-rank and linkage evidence

- Q native damage/cooldown/mana arrays contain four ranks. All migrated
  rank-dependent values need ten explicit entries. Native stun is scalar 0.6;
  ENFOS currently authors 0.4. The old custom Q also adds `1.5 * agility` and
  three 60% secondary hits, absent from the default native Beam. Any removal
  must be recorded as native restoration, not silently called equivalent.
- W native duration, collision damage, cooldown, mana and mitigation have four
  ranks. Scalar glaive count/radii/speed remain bounded. Shard adds 10 mitigation
  and 20 movement speed through `special_bonus_shard`; preserve upgrade metadata.
  Existing W has no explicit cooldown or mana cost and pulses every 0.5 seconds;
  it is not an accurate native Orbit implementation.
- E native `MaxLevel 1`, `Innate 1`, hidden/skip-keybind/force-no-innate-UI behavior
  conflicts with a paid ten-rank E. `bonus_damage` uses `hero_levelup +1`,
  `self_bonus_damage` uses `hero_levelup +2`; vision starts at 225 and adds 25
  per hero level. A native alias must not inherit unintended free ranks or
  multiply authored rank scaling by this implicit level scaling.
- R native beams contain three ranks (6/9/12), Scepter beam additions three
  ranks (0/3/6), Scepter hit-count additions three ranks (1/7/13), and duration
  three ranks (2.4/4.2/6.0). Normal hit count is 5; interval 0.6, Scepter interval
  0.3, radius 675, Scepter cast range +2500. Every retained multirank base AND
  upgrade array needs explicit ten-rank treatment. The current custom R's own
  damage curve is not a native R special. Do not assume alias Q is automatically
  found by C++ R, or infer a lookup name from the icon alone.
- D native bounces have four ranks (3/4/5/6); reduction has four ranks
  (50/45/40/35 percent). Current custom D authors 4–16 bounces, 85% retention
  per hop and a flat starting bonus. Native restoration must document numerical
  mapping and avoid adding a second damage/bounce event chain.
- KV cannot establish internal C++ rank-index safety, modifier refresh,
  status-resistance behavior, linked lookups or rank-up HUD acceptance. Test
  ranks 1, native cap, cap+1 and 10, plus hero level 50, in owner Dota.

## Shared consumers and isolation constraints

`heroes/roster.lua`, `heroes/innates.lua`, `heroes/match_levels.lua`, native
selection and the existing player spawn path own roster/progression. D receives
one free rank separately; there are 49 ordinary match skill points. Preserve all
five stable IDs when aliases can satisfy linkage. Do not restore talents.

Native Luna is also the Rift Lord Boss (`waves/wave_definitions.lua`) and is
prepared by `bosses/native_hero_bosses.lua`. Global native Luna overrides would
change that Boss and are outside this pilot. Prefer custom BaseClass aliases or
hero-local integration; do not tune native IDs globally.

The shared source audit and all-200-ability mock runner currently assume every
authored slot has Lua callbacks. Native candidates require narrowly scoped
validator support that distinguishes native ownership from missing Lua;
do not retain empty Lua wrappers merely to satisfy those assumptions.

Trace only existing ENFOS integration events through `lib/hero_trace.lua`.
Native internals need no replicated attacks, timers, modifiers or particles for
logging. Remaining Luna custom code belongs beneath
`abilities/heroes/luna/`; shared helpers stay shared. Source/resource cleanup
must consider cross-hero and Boss consumers before removing precache entries.

## Baseline automated validation

`node --test --test-name-pattern=Luna tools/tests/content_contracts.test.mjs`:
2 passed, 0 failed. This proves current authored rank gates and named-value
contracts only. One passing case still requires `boss_damage_pct 10`, so it must
be updated when the Boss exception is removed. Existing tests are not proof of
native compatibility.

## Work remaining

Implement and validate the candidates above, resolve native Q/R linkage and
rank arrays, isolate remaining custom code, remove Luna Boss exceptions and
duplication, update localization and affected validators, review the final diff,
run broader checks once at delivery, and create isolated local implementation
commits. Add the exact final trace lines and practical owner test checklist to
this record. No push, deployment, Workshop publication, or other-hero rollout.

SOURCE_REVIEW: installed definitions verified; internal linkage unresolved.
AUTOMATED_VALIDATION: existing focused baseline passed; migration not tested.
OWNER_RUNTIME: PENDING OWNER TEST.

## D migration checkpoint — 2026-10-03

D decision: **NATIVE** with ENFOS numerical KV tuning; classification TUNE.
`enfos_luna_moon_glaives` now uses `BaseClass luna_moon_glaive`, with no
ScriptFile, empty wrapper, custom class or attack modifier. Dota owns attack
records, bounce selection/projectiles, impact damage, feedback and cleanup.
The explicit `bounces` curve remains 4/6/8/10/11/12/13/14/15/16, range 500,
reduction 15%. The separate free starting rank and paid ten-rank gates remain.
Actual native rank support and dense-wave behavior are PENDING OWNER TEST.

Removed: `enfos_luna_moon_glaives` Lua class,
`modifier_enfos_luna_moon_glaives_passive`, its shared registration,
`OnAttackLanded` chain/search/visited state, prelaunched tracking-projectile
construction and ExtraData damage callback. The old chain's additive 20–140
starting bonus is removed because it is absent from native Glaives; this is an
explicit native restoration rather than an equivalence claim. No second attack
damage or projectile chain compensates for it. First-hit damage and secondary
damage ordering are owned by the installed engine and need owner measurement.
No precache entry was removed at this checkpoint: Luna's base attack resources
are also used by her ordinary attacks and the native Boss. D's inaccurate
`HasShardUpgrade` flag was removed; installed Shard belongs to Orbit.

All four D descriptions and their generated game/content mirrors now describe
the native bounce formula. Existing shared role Shard bonuses remain unchanged
at this checkpoint; native W/Shard integration is still pending migration.

Validators explicitly allow only source-reviewed native aliases. Missing Lua
for unreviewed abilities still fails. Structural inventory uses empty callbacks
and `implementationOwner NATIVE`, not fabricated Lua entrypoints. The rank mock
runner counts native slots as pending owner tests separately from Lua passes.
The old custom bounce mock was removed; it cannot validate C++ behavior.
The reference generator filters absent ScriptFiles instead of emitting an
`undefined.lua` source link. Other hero implementations are unchanged.

Validation at this checkpoint: four `tools/tests/luna_native.test.mjs` checks
pass (ownership/no replicas, explicit rank/bounce contract, allowlist rejection,
free-rank restore/idempotence/default-off trace); the two existing Luna KV/rank
tests pass; 357 `tests/hero_kit_regressions.lua` mocks pass; all 40 reference
ledgers pass structural verification. The directly affected rank mock runner
passes at rank 1 with D excluded from Lua certification. Full final-boundary
checks have not yet run.

With tracing enabled by
`script require('lib/hero_trace'):SetEnabled(true)`, the existing free-rank
restore path prints `[LUNA_TRACE][D] passive_rank_restored level=1 owner=native`
at initial spawn. Repeated restore with D rank 10 prints the same line with
`level=10` and preserves rank/points. Disable with `SetEnabled(false)`.
No timers, modifiers, searches or attacks were added for this trace.

Owner D test: restart the game after KV changes; check initial free rank and
five ordinary points, learn D through ranks 1/4/5/10, compare first hit and
successive hits against armor-adjusted 85% retention, count bounces with enough
targets, test target death/loss, Break, illusions and dense waves, then
respawn/reconnect and check no duplicate passive/points. Confirm no VConsole
Lua/resource errors. Native internal hits deliberately produce no custom trace
spam. OWNER ENGINE ACCEPTANCE: NOT TESTED.

Q/W/E/R migration, Boss-cap removal, their trace integration, final upgrade
tooltips, full acceptance checklist and final pilot conclusion remain open.

## W migration checkpoint — 2026-10-04

W decision: **NATIVE** with ENFOS numerical KV tuning; classification TUNE.
`enfos_luna_lunar_orbit` uses `BaseClass luna_lunar_orbit`, with no ScriptFile,
Lua ability wrapper or custom modifier. Dota owns four rotating glaives,
collision selection and physical attack-derived damage, movement around Luna,
cast behavior/animation, mitigation, Shard integration and resource lifecycle.
The installed `resource/localization/abilities_english.txt` explicitly describes
collision damage as a percentage of Luna's attack damage. This source was read
from the same installed archive; the native W KV is already in the snapshot.

Retained ENFOS values: duration 8 seconds, base mitigation 25%. Bounded native
values: four glaives, orbit radius 225, collision radius 200, speed 160, expansion
speed scale 4. Collision damage uses 28/32/36/40 percent for ranks 1–4 and 40%
for ranks 5–10. Cooldown is 40/35/30/25 seconds followed by six explicit 25s
entries; mana is 65/70/75/80 followed by six explicit 80 entries. These extend
the installed numerical curves by holding the native terminal value; they do
not prove internal C++ rank-index safety. W Shard retains native `+10` mitigation
and `+20` percentage movement speed. No hypothetical rank-5–10 curve is invented.

Removed: `enfos_luna_lunar_orbit` Lua class,
`modifier_enfos_luna_lunar_orbit_buff`, its shared registration, radial 0.5s
agility-scaled pulses, custom ambient/impact particle allocation/cleanup and
custom repeated impact sounds. The old extra attack-range and constant
movement-speed bonuses are removed as part of native restoration. The orbit
now has its native cooldown/mana costs instead of unrestricted repeated custom
casts. These numerical/mechanical differences are explicit pilot changes.
No separate collision or radial damage logic compensates for native behavior.

Luna's existing generic Shard +15% speed and 12% extra pure attack damage are
disabled only when the ENFOS native Orbit slot is present. Native Boss Luna
without that slot, other heroes, and shared upgrade reconciliation are
unchanged. The empty generic Shard icon is hidden for that same ENFOS kit.
Shard tooltips move from D to W, with four-language native descriptions and
generated mirrors. No native Boss ability or global native KV is overridden.

The existing free-rank integration additionally logs
`[LUNA_TRACE][W] native_integration_ready ability=enfos_luna_lunar_orbit shard=orbit`
when tracing is enabled. This records the ENFOS integration configuration, not
a successful cast, collision or Shard effect. No timer, search or gameplay
state was added for this line.

Validation: seven native/progression/upgrade integration checks and two focused
Luna content/rank checks pass. The shared Shard regression proves no generic
extra damage/speed for ENFOS Luna, while native Boss and another Carry retain
their previous path. 356 remaining hero-kit mocks pass; the obsolete custom
Orbit pulse mock is removed because it cannot validate native collisions.
Final broad project checks remain deferred to the whole-Luna delivery boundary.

Owner W test: full restart for KV; ranks 1/4/5/10, cast while moving, check
cost/cooldown, four visible glaives, collision radius and repeated contacts,
8s lifetime, 25% mitigation, death/interrupt/recast/cleanup and dense-wave frame
cost. Acquire Shard and verify 35% mitigation and 20% movement speed only during
Orbit; confirm no separate generic pure attack proc. Distinguish native
collisions from D's attack bounces. Confirm VConsole has no resource/Lua errors.
OWNER ENGINE ACCEPTANCE: NOT TESTED.

Q/E/R migration, Luna-authored Boss-cap removal, their trace integration and
the final pilot delivery remain open.
