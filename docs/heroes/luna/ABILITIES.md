# Luna: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_luna`; role: Carry. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_luna_lucent_beam` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/pve_kits | luna_lucent_beam |
| 2 | `enfos_luna_lunar_orbit` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET \| DOTA_ABILITY_BEHAVIOR_IMMEDIATE \| DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_MOVEMENT | NOT_EXPLICIT | luna_lunar_orbit |
| 3 | `enfos_luna_lunar_blessing` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE \| DOTA_ABILITY_BEHAVIOR_AURA | abilities/pve_kits | luna_lunar_blessing |
| 4 | `enfos_luna_eclipse` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | luna_eclipse |
| 5 | `enfos_luna_moon_glaives` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | NOT_EXPLICIT | luna_moon_glaive |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_luna.txt`; status: FILE_VERIFIED; SHA256: `96f7fb3388afcc02ac071da9beeb97f53ae5ea2ae41b95c172c16434fa60e747`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/luna/luna.vmdl` |
| SoundSet | `Hero_Luna` |
| Ability1 | `luna_lucent_beam` |
| Ability2 | `luna_lunar_orbit` |
| Ability3 | `luna_moon_glaive` |
| Ability4 | `luna_lunar_blessing` |
| Ability5 | `generic_hidden` |
| Ability6 | `luna_eclipse` |
| Ability7 | `generic_hidden` |
| Ability10 | `special_bonus_unique_luna_7` |
| Ability11 | `special_bonus_unique_luna_4` |
| Ability12 | `special_bonus_unique_luna_lunar_orbit_glaive_count` |
| Ability13 | `special_bonus_unique_luna_1` |
| Ability14 | `special_bonus_unique_luna_6` |
| Ability15 | `special_bonus_unique_luna_lunar_orbit_speed_damage` |
| Ability16 | `special_bonus_unique_luna_3` |
| Ability17 | `special_bonus_unique_luna_5` |
| AttributeStrengthGain | `2.200000` |
| AttributeAgilityGain | `3.400000` |
| AttributeIntelligenceGain | `1.90000` |

### Per-ability review leads

- `enfos_luna_lucent_beam`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_luna_lunar_orbit`: cast/impact/modifier contract and lifetime.
- `enfos_luna_lunar_blessing`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `enfos_luna_eclipse`: ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_luna_moon_glaives`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-10-03 native-first pilot source review: installed ClientVersion 6943 /
SourceRevision 11069754 (Oct 01 2026) was inspected read-only. The native Luna
hero source SHA256 remains identical to the earlier 6941 source. The five exact
native AbilityDefinitions, pre-migration decision matrix, ten-rank constraints
and shared consumers are recorded in
[the Luna pilot record](../../audit/LUNA_NATIVE_FIRST_PILOT_2026-10-03.md) and
[the installed-source evidence](../../audit/LUNA_NATIVE_SOURCE_2026-10-03.json).
Current production slot order is Q Beam / W Orbit / E Blessing / R Eclipse /
D Moon Glaives. Native Blessing is a one-rank, hidden, hero-level-scaled innate;
it is not equivalent to the current paid E aura. The two existing focused Luna
KV/rank contracts pass, including an obsolete Boss-cap assertion that the
migration must replace. No implementation migration or engine acceptance is
claimed by this source review. OWNER ENGINE ACCEPTANCE: NOT TESTED.

2026-09-30 static special-value repair: migrated Lua-read values for all five Luna abilities from legacy numbered `AbilitySpecial` to named `AbilityValues`, preserving existing rank arrays and scalar values. Added a content contract for the 10-rank definitions and schema. This uses the project-specific Sven ClientVersion 6941 finding as the compatibility evidence; the Luna abilities themselves have not been verified in Dota. The user owns the remaining in-game gameplay, audio, and visual checks.

## Slot 1: `enfos_luna_lucent_beam`

Classification: PVE-CONVERT
Native counterpart: `luna_lucent_beam` (installed native snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot mapping is authored).
Decision and PvE identity rationale: PVE-CONVERT preserves the identified Dota hero fantasy while changing PvP-only targeting/control for wave, elite and boss play.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current/target rank: Lucent Beam Q ranks 1–10 are gated at hero levels 1–10; engine HUD/point behavior remains PENDING.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: PENDING.
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: PENDING.
- Sound events + declaring banks + emission target + loop termination: PENDING.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: PENDING.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated mirrors: PENDING.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Not evaluated in this dossier setup. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Q gates levels 1–10 declared; in-game HUD and point behavior remain PENDING. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | Not evaluated in this dossier setup. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: all five slots have MaxLevel 10; all multirank KV values have ten explicit entries; the full 40-hero / 200-ability mock suite passes. Rank-up HUD, VFX/SFX in match, boss waves and VConsole remain pending a live Dota test.

## Slot 5: `enfos_luna_moon_glaives`

Classification: TUNE
Native counterpart: `luna_moon_glaive` (installed native snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot mapping is authored).
Decision and PvE identity rationale: native Moon Glaives now owns the attack/bounce mechanic; explicit ENFOS ten-rank numerical tuning preserves the passive D slot and separate free rank. See the D checkpoint in the pilot record.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current/target rank: Moon Glaives D ranks 1–10 are gated at hero levels 1–10; engine HUD/point behavior remains PENDING.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: PENDING.
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: PENDING.
- Sound events + declaring banks + emission target + loop termination: PENDING.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: PENDING.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated mirrors: PENDING.

2026-10-03 D checkpoint: `BaseClass luna_moon_glaive`; no Lua wrapper, attack hook or custom projectile damage remains. Native ownership and four-language descriptions are checked by `tools/tests/luna_native.test.mjs`. Installed build 6943 / source hash above; engine effects, Break, illusion rules, rank scaling and performance remain PENDING OWNER TEST. The previous 2026-09-30 custom bounce records below are historical and superseded for D. OWNER ENGINE ACCEPTANCE: NOT TESTED.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Not evaluated in this dossier setup. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | D ten-rank gates and free-rank restore pass static/mock checks; native rank-up and bounce scaling are PENDING OWNER TEST. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | Not evaluated in this dossier setup. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: all five slots have MaxLevel 10; all multirank KV values have ten explicit entries; the full 40-hero / 200-ability mock suite passes. Rank-up HUD, VFX/SFX in match, boss waves and VConsole remain pending a live Dota test.

## Slot 3: `enfos_luna_lunar_blessing`

Classification: PVE-CONVERT
Native counterpart: `luna_lunar_blessing` (installed native snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot mapping is authored).
Decision and PvE identity rationale: PVE-CONVERT preserves the identified Dota hero fantasy while changing PvP-only targeting/control for wave, elite and boss play.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current/target rank: Lunar Blessing E ranks 1–10 are gated at hero levels 1–10; engine HUD/point behavior remains PENDING.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: PENDING.
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: PENDING.
- Sound events + declaring banks + emission target + loop termination: PENDING.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: PENDING.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated mirrors: PENDING.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Not evaluated in this dossier setup. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | E gates levels 1–10 declared; in-game HUD and point behavior remain PENDING. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | Not evaluated in this dossier setup. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: all five slots have MaxLevel 10; all multirank KV values have ten explicit entries; the full 40-hero / 200-ability mock suite passes. Rank-up HUD, VFX/SFX in match, boss waves and VConsole remain pending a live Dota test.

## Slot 4: `enfos_luna_eclipse`

Classification: PVE-CONVERT
Native counterpart: `luna_eclipse` (installed native snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot mapping is authored).
Decision and PvE identity rationale: PVE-CONVERT preserves the identified Dota hero fantasy while changing PvP-only targeting/control for wave, elite and boss play.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current/target rank: Eclipse R ranks 1–10 are gated at levels 5, 10, …, 50; ultimate HUD/point behavior remains PENDING.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: PENDING.
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: PENDING.
- Sound events + declaring banks + emission target + loop termination: PENDING.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: PENDING.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated mirrors: PENDING.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Not evaluated in this dossier setup. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | R gates levels 5–50 in five-level steps declared; ultimate HUD and point behavior remain PENDING. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | Not evaluated in this dossier setup. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: all five slots have MaxLevel 10; all multirank KV values have ten explicit entries; the full 40-hero / 200-ability mock suite passes. Rank-up HUD, VFX/SFX in match, boss waves and VConsole remain pending a live Dota test.

## Slot 2: `enfos_luna_lunar_orbit`

Classification: TUNE
Native counterpart: `Enfos Lunar Orbit / native luna_lunar_orbit identity` (installed native snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot mapping is authored).
Decision and PvE identity rationale: native rotating-glaive collisions replace the custom radial pulses. ENFOS duration/mitigation and ten ranks remain explicit; native Shard upgrades W. See the W checkpoint in the pilot record.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current/target rank: Lunar Orbit is active slot 2 and ranks 1–10 are gated at hero levels 1–10. Moon Glaives is the slot-5 Enfos passive and starts at rank 1 via the separate Enfos grant. Rank buttons and point behavior remain PENDING in-engine validation.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: PENDING.
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: PENDING.
- Sound events + declaring banks + emission target + loop termination: PENDING.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: PENDING.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated mirrors: PENDING.

2026-10-04 W checkpoint: `BaseClass luna_lunar_orbit`; no Lua pulse, particle or sound replica remains. Native Shard values replace Luna's generic role Shard speed/pure-hit path, without changing other heroes or native Boss Luna. Seven native/integration checks and 356 hero-kit mocks pass. Collision feedback, mitigation, costs, ranks and performance remain PENDING OWNER TEST. OWNER ENGINE ACCEPTANCE: NOT TESTED.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Not evaluated in this dossier setup. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | W is the paid active slot 2, not the free D passive; native ten-rank numeric arrays pass static checks. Rank-up HUD and C++ scaling remain PENDING OWNER TEST. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | Not evaluated in this dossier setup. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: all five slots have MaxLevel 10; all multirank KV values have ten explicit entries; the full 40-hero / 200-ability mock suite passes. Rank-up HUD, VFX/SFX in match, boss waves and VConsole remain pending a live Dota test.

2026-09-30 level-cap integration and slot correction: all five Luna abilities declare KV rank gates. Q/W/E and the active W ability Lunar Orbit use one rank per level; Moon Glaives is the slot-5 Enfos passive and receives rank 1 through the separate Enfos grant. Eclipse ranks 1–10 unlock on levels 5, 10, …, 50. Static KV contract passes; actual rank buttons, level-up points, ultimate badge and match-start level 6 remain PENDING.

2026-09-30 static behavior follow-up: Moon Glaives now applies its physical
damage on tracking-projectile impact instead of immediately at launch, with a
guard for dead/friendly targets and illusion attackers; bounce count is bounded
to the authored 16 maximum. Eclipse previously read the Q beam rank, leaving its
own R damage curve unused; it now uses its own rank, with per-cast boss damage
percentage and per-target beam cap in KV. Thinker cleanup also occurs if Luna
dies. Lunar Orbit's pulse interval/radius/damage/scaling and damage reduction,
plus Lunar Blessing's movement speed, now use named KV values. Moon Glaives and
Lunar Blessing declare Break support, matching their passive/aura nature.
English, Turkish, Russian and Simplified Chinese descriptions now match those
values and the implemented bounce, beam and pulse behavior. New mock coverage
checks impact-timed glaive damage and Eclipse's own damage rank/boss cap. All
game-client VFX/SFX, projectile appearance, aura source behavior, Break and
boss interactions remain pending owner testing.
