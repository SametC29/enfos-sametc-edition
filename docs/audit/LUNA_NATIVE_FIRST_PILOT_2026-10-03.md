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
