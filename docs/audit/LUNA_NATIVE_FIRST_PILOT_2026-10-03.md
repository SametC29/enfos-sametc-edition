# Luna native-first pilot — evidence and delivery

Scope: `npc_dota_hero_luna` only. The pre-migration matrix and intermediate
checkpoints below are historical evidence. The final delivery section records
the current implementation and explicitly pending engine gates.
OWNER ENGINE ACCEPTANCE: NOT TESTED.

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

## Final delivery — 2026-10-04

IMPLEMENTED BUT NOT ENGINE-VERIFIED. The sections above describe earlier
checkpoints, not outstanding implementation work. OWNER ENGINE ACCEPTANCE:
NOT TESTED. Installed build remains 6943 / SourceRevision 11069754.

### Final decision matrix

| Slot | ENFOS stable ID | Native counterpart | Decision | Remaining ENFOS responsibility |
| --- | --- | --- | --- | --- |
| Q | `enfos_luna_lucent_beam` | `luna_lucent_beam` | NATIVE + MINIMAL ENFOS EXTENSION | Ten-rank numeric KV and the existing 1.5 × Agility contribution through a special-value override. No replicated cast/stun/damage/feedback. |
| W | `enfos_luna_lunar_orbit` | `luna_lunar_orbit` | NATIVE | Explicit ten-rank KV, authored duration/mitigation, native Shard metadata. No Lua wrapper or pulse logic. |
| E | `enfos_luna_lunar_blessing` | `luna_lunar_blessing` | NATIVE + MINIMAL ENFOS EXTENSION | Paid ten-rank visible E metadata and local armor/movement aura. Native damage/night vision/nighttime aura remain engine-owned. |
| R | `enfos_luna_eclipse` | `luna_eclipse` | NATIVE + MINIMAL ENFOS EXTENSION | Explicit native base/upgrade arrays and a hidden original-name native Beam provider for linkage. No Lua beam scheduler or damage callback. |
| D | `enfos_luna_moon_glaives` | `luna_moon_glaive` | NATIVE | Authored ten-rank bounces, separate free starting rank and ordinary paid ranks. No attack/projectile Lua. |

All five are TUNE relative to their installed native mechanics. All five native
BaseClasses and absence of Lua ability wrappers are checked against production
KV. This establishes configuration ownership, not C++ runtime acceptance.

### Remaining custom code and rationale

- `abilities/heroes/luna/scaling.lua`: one persistent hidden, non-purgable
  special-value modifier preserves Q's authored Agility contribution. It reads
  raw `GetLevelSpecialValueNoOverride`, avoiding recursive overrides. For both
  alias Q and the original native Beam provider it uses the current paid Q rank
  and live Agility. Untrained Q returns zero. No damage events are generated.
  The restore function creates one hidden/deactivated `luna_lucent_beam` only
  on the ENFOS kit. That provider stays at native rank 1, so its internal native
  rank assumptions are not exposed to ten ranks; its damage query is redirected
  to the paid Q curve. It consumes no ordinary point and is never player-cast.
- `abilities/heroes/luna/e.lua`: one persistent extension aura and one engine
  aura recipient modifier retain only authored armor and 12% movement speed.
  They add no attack damage, particles, sounds or timers. The aura checks paid
  E rank, source life and Break; recipient getters also suppress stale lingering
  bonuses on Break/death/untrained E. Rank values are read live. This local aura
  intentionally stays within E's authored radius; native nighttime global scope
  belongs to native attack damage, not the ENFOS armor/movement extension.
- `abilities/heroes/luna/integration.lua`: existing free-rank/spawn restoration,
  native item-upgrade routing and default-off diagnostic lines. Restoration
  reuses the provider/modifiers, preserving paid ranks and ordinary points.
  Existing shared spawn and upgrade managers call it; no new manager/listener,
  periodic thinker, native attack observer or global scan is introduced.

Native ability-specific internals remain in C++. The original-name Beam
provider is an intentionally testable linkage solution, not proof of the exact
internal lookup path: owner must verify the alias R actually uses it, including
native Scepter casts. No native ID is globally overridden. Native Boss Luna
without the ENFOS kit remains outside restoration and item exclusions.

### Removed duplication and intentional native restoration

All five former Luna Lua ability classes are removed. Removed modifiers:
`modifier_enfos_luna_moon_glaives_passive`,
`modifier_enfos_luna_lunar_orbit_buff`,
`modifier_enfos_luna_lunar_blessing`,
`modifier_enfos_luna_lunar_blessing_aura`,
`modifier_enfos_luna_eclipse_thinker`, and their monolith registrations.
Native engine now owns their cast/target/attack/bounce/modifier/resource
lifecycles. Custom particle/SFX/projectile replication, pulse and Eclipse
timers, per-target custom hit counters, bounce visited tables and custom
particle cleanup are gone. The native per-target Eclipse hit limit remains
ordinary KV; the per-cast Boss max-HP cap and all Luna Boss-only branches are
removed. Boss AI/stats/skills/waves are unchanged.

Q no longer emits three custom 60% resonance hits; Q's existing damage, stun,
cooldown, mana and Agility values remain. Eclipse now follows Q, rather than the
old independent R damage curve; its native beams do not stun. R's existing
cooldown/mana, radius 750 and ordinary six-hit limit remain; cast point restores
native 0.5s. E restores native allied-hero damage scope, double self damage,
nighttime global aura and level-scaled night vision. Its ally damage/radius and
local armor/speed curves remain, with hero-level damage increments explicitly
zeroed to avoid unintended innate damage on top of paid ranks. W/D differences
are recorded in their checkpoints above. These are native mechanic restorations,
not unrelated balance redesign or claims of identical previous behavior.

Luna's generic +40% ultimate damage / -25% cooldown Scepter modifier effects are
disabled only for the ENFOS Eclipse kit; native Eclipse Scepter behavior replaces
them. The now-empty generic modifier icon is hidden. Native Boss and other-hero
paths remain unchanged in focused regressions. Shard ownership is W as recorded
above. Normal Dota item stats, consumed Scepter/Blessing state, Ascended purchase
systems and reconciliation remain intact. Four-language descriptions/mirrors
now match native mechanics and retained extensions.

Precache removals: **none**. The existing Beam/Eclipse entries still correspond
to native effects and are not obsolete merely because custom EmitSound/particle
calls vanished. Base attack resources are used by ordinary attacks and native
Boss Luna. The installed native hero sound bank
`soundevents/game_sounds_heroes/game_sounds_luna.vsndevts_c` was verified present;
Luna is added to the existing sound-bank precache loop. No new custom asset or
precache manager is introduced. Cold-start feedback/cleanup remains owner-test
work; asset existence is not a visual/audio pass.

### Ten-rank architecture and limits

The five paid slots remain rank 0–10 with the original ENFOS-facing IDs and
Q/W/E/D gates 1/1, R gates 5/5. Hero-level-50 XP, level-6 start, five initial
ordinary points, free D rank, 49 ordinary skill points, hidden talent slots,
selection/roster and match-only progression are unchanged. No account storage
or permanent progression returns. All base multirank and Scepter multirank
arrays are explicit ten entries; native terminal values are held where no new
authored curve exists. Scalars stay scalar, including bounded native counts,
radii and intervals. E is `Innate 0`, with hidden/skip-keybind behavior removed,
and no implicit damage `hero_levelup` increment; its night vision retains native
hero-level scaling. Provider Q is fixed at rank 1 and reads paid Q dynamically,
so it needs no per-upgrade timer or event mirror.

**Native ten-rank engine safety is not established.** KV/mocks cannot prove
C++ level-index assumptions, modifier refresh, hidden provider lookup,
innate-to-paid E HUD behavior, night scaling or native Shard/Scepter internals.
The smallest implemented extensions address observable data/linkage boundaries
without replacing mechanics. Owner tests must accept these before rollout.

### Validation separation

SOURCE_REVIEW: installed native Luna AbilityDefinitions verified for build 6943;
native Orbit/ Blessing/Eclipse tooltip relationships inspected read-only.
API evidence: toolkit `CDOTABaseAbility:GetLevelSpecialValueNoOverride` is
available server/client and ignores special overrides; enum modifierfunction
identifies the two override properties. No unavailable modifier upgrade event
was guessed or added. The author-maintained
[API reference](https://docs.moddota.com/lua_server/) documents the same ability
API distinction. No game launch/control or imported third-party kit occurred.

AUTOMATED_VALIDATION: 12 focused native/rank/restore/upgrade checks pass;
two Luna content/rank contracts pass; 354 remaining hero-kit mocks pass.
Structural inventory/reference generation represents five native slots with
empty Lua callbacks and pending engine status. Native slots are reported
separately from Lua passes by the rank runner, never fake-certified.
Final broad validation on 2026-10-04: `npm.cmd run check` exited 0 with
**0 failed checks**. The current working tree (including preserved contributor
changes) passed syntax, KV, localization, inventory/reference, progression and
regression checks. Rank inventory: **200/200 abilities, 195 Lua passed, 5 native
pending owner, 0 failed**, exercised at ranks 1–10 for Lua-owned mechanics.
The existing 48-normal-wave pressure checks and 12 installed native Boss-kit
preparation checks also passed their automated scope; these are not runtime
certification. The 354 hero-kit and 22 audit regressions passed in mocks.
No Dota/VConsole session was launched or controlled.

OWNER_RUNTIME: PENDING OWNER TEST. OWNER ENGINE ACCEPTANCE: NOT TESTED.

### Practical owner test and VConsole checklist

Full restart after KV and new module changes. Use a fresh Luna match, record
build/revision, then enable diagnostics with
`script require('lib/hero_trace'):SetEnabled(true)`. Respawn or invoke the existing
Luna restore point to observe initial integration. Expected restore lines:

```text
[LUNA_TRACE][D] passive_rank_restored level=1 owner=native
[LUNA_TRACE][W] native_integration_ready ability=enfos_luna_lunar_orbit shard=orbit
[LUNA_TRACE][Q] native_scaling_ready rank=0 agility_multiplier=1.5
[LUNA_TRACE][R] native_beam_provider_ready ability=luna_lucent_beam hidden=true rank=1
[LUNA_TRACE][E] native_blessing_extension_ready rank=0 damage_owner=native armor_speed_owner=enfos
```

Rank fields reflect current paid ranks on subsequent restores. Native internal
hits deliberately have no replicated trace lines. These lines prove the
integration ran, not that casts/damage/resources passed. Any
`[LUNA_TRACE][R] native_beam_provider_missing` is FAIL for linkage; inspect the
ability slots/provider availability. Disable with `SetEnabled(false)`.

| Area | Owner test / PASS criterion |
| --- | --- |
| Q | Ranks 1/4/5/10, valid/invalid/dead/friendly targets, range/mana/cooldown, spell block/immunity/status resistance. Measure armor/resistance-adjusted damage using Q's curve + 1.5×Agility; verify one native Beam and correct cast/impact animation/VFX/SFX with no duplicate resonance. Change Agility and paid Q rank; provider damage must follow live values. |
| W | Paid active slot is Orbit. Cast while moving, costs/cooldowns at 1/4/5/10, four visible glaives, collision count/damage and dense-creep performance; 8s lifetime, 25% mitigation, death/recast cleanup. Shard adds 10 mitigation and 20% speed during Orbit only. No generic pure attack proc. |
| E | E begins untrained and visible, has ten paid ranks and no second free innate rank. Measure ally damage, double Luna damage, local armor/speed and radius at 1/4/5/10. Verify night global damage/night vision, Break, death/respawn, live rank refresh and two Luna sources. Armor/speed must vanish on Break/death and not become a global nighttime extension. |
| R | R ranks 1/3/4/10, beam count/interval/ordinary hit limit/target choice against normal waves and Boss; Q untrained produces no damage, Q learned/ranked/Agility updates affect R damage. No Boss HP cap and no beam stun. Scepter item and consumed Blessing support native allied/ground targeting, beam-count and per-target upgrades, 0.3s intervals, normal death/interrupt/cleanup. No additional 40%/25% generic modifier effect. |
| D | Free starting rank and ranks 1/4/5/10; initial target, secondary targets, bounce count, falloff/projectile impact and high-density waves. Check native Break, illusion, immunity and target-loss behavior; no second Lua bounce/damage chain. |
| Match integration | Level-6 start/five ordinary points/free D, level-50 and all 49 paid points, R gates at 5/10/…/50, no visible hidden Beam provider/extra rank button/talents. Repeat respawn/reconnect: one provider and extension of each type, no duplicated ranks/points/items. Native selection, normal and Ascended shops, Scepter/Blessing and Shard remain usable. EN/TR/RU/zh-CN descriptions display correctly. |
| Performance/resources | Dense waves and repeated casts: no accumulating custom thinkers/projectiles/particles or trace spam; correct audio stop/cleanup. VConsole contains no new ERROR/FATAL/Failed/Unable/stack traceback/resource compile/modifier/null-handle errors. Record actual footage/audio and console output for acceptance. |

### Pilot conclusion

The source-reviewed implementation demonstrates a native-first architecture
with all five mechanics configured for engine ownership and small local
extensions instead of five recreated ability kits. It supports using this
architecture as the next test candidate. **It does not yet demonstrate safe
ten-rank engine behavior or justify default rollout to additional heroes.**
That conclusion remains conditional on owner acceptance of the native aliases,
Q/R provider, paid E conversion, upgrades, resources and dense-wave behavior.
No other hero rollout is begun. Local commits only; no push/deploy/Workshop
publication is authorized or performed.
