# Centaur Warrunner: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_centaur`; role: Tank. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_centaur_hoof_stomp` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | centaur_hoof_stomp |
| 2 | `enfos_centaur_double_edge` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/pve_kits | centaur_double_edge |
| 3 | `enfos_centaur_return` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | centaur_return |
| 4 | `enfos_centaur_stampede` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | centaur_stampede |
| 5 | `enfos_centaur_colossal_hide` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | centaur_mount |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_centaur.txt`; status: FILE_VERIFIED; SHA256: `33c8ac9381898217373bea1d5deea95c33504e9e40505d64c64f3b8f0bac6404`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/centaur/centaur.vmdl` |
| SoundSet | `Hero_Centaur` |
| Ability1 | `centaur_hoof_stomp` |
| Ability2 | `centaur_double_edge` |
| Ability3 | `centaur_return` |
| Ability4 | `centaur_work_horse` |
| Ability5 | `centaur_mount` |
| Ability6 | `centaur_stampede` |
| Ability7 | `centaur_horsepower` |
| Ability10 | `special_bonus_hp_regen_4` |
| Ability11 | `special_bonus_movement_speed_15` |
| Ability12 | `special_bonus_strength_10` |
| Ability13 | `special_bonus_unique_centaur_4` |
| Ability14 | `special_bonus_unique_centaur_3` |
| Ability15 | `special_bonus_unique_centaur_5` |
| Ability16 | `special_bonus_unique_centaur_1` |
| Ability17 | `special_bonus_unique_centaur_2` |
| AttributeStrengthGain | `4.3` |
| AttributeAgilityGain | `1.0000` |
| AttributeIntelligenceGain | `1.600000` |

### Per-ability review leads

- `enfos_centaur_hoof_stomp`: cast/impact/modifier contract and lifetime.
- `enfos_centaur_double_edge`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_centaur_return`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `enfos_centaur_stampede`: ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_centaur_colossal_hide`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

## Slot 1: `enfos_centaur_hoof_stomp`

Classification: PVE-CONVERT
Native counterpart: `centaur_hoof_stomp`, verified in the installed hero KV above. Keeps the signature area stomp and stun while adding Strength-scaled physical damage and a shorter boss stun. Its Strength factor and boss stun percentage are now KV-driven.
Decision and PvE identity rationale: Preserve the tank-control identity; boss cap and damage type are intentional Enfos PvE adaptations pending engine balance review.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve; free rank / point cost: ten total ranks, `RequiredLevel=1`, one level between ranks; unlock schedule1–10. Runtime HUD/unlock behavior PENDING.
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
| Gameplay | PENDING | Hoof Stomp damage/radius and shortened boss stun are covered by a mock; damage type, immune-target behavior and in-game stun control remain unverified. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | KV gate schedules ten ranks from hero levels1–10; custom-level HUD/point consumption remains PENDING in Dota. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | English, Russian and Simplified Chinese now have authored skill text; generator and content contract verify aliases, mirrors and configured placeholders. In-game tooltip rendering remains PENDING owner verification. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 2: `enfos_centaur_double_edge`

Classification: PVE-CONVERT
Native counterpart: `centaur_double_edge`, verified in the installed hero KV above. Keeps the self-costing close-range burst; splash radius, Strength and max-health scaling, self-cost percentage and minimum health are KV-driven.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve; free rank / point cost: ten total ranks, `RequiredLevel=1`, one level between ranks; unlock schedule1–10. Runtime HUD/unlock behavior PENDING.
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
| Gameplay | PENDING | Double Edge configured splash/self-cost and spell-block cancellation are covered by mocks; actual health-cost and pure-damage behavior remain unverified in Dota. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | KV gate schedules ten ranks from hero levels1–10; custom-level HUD/point consumption remains PENDING in Dota. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | English, Russian and Simplified Chinese now have authored skill text; generator and content contract verify aliases, mirrors and configured placeholders. In-game tooltip rendering remains PENDING owner verification. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 3: `enfos_centaur_return`

Classification: PVE-CONVERT
Native counterpart: `centaur_return`, verified in the installed hero KV above. Keeps retaliatory damage and adds a damage-threshold AoE pulse for wave combat; scaling, pulse threshold and radius are KV-driven.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve; free rank / point cost: ten total ranks, `RequiredLevel=1`, one level between ranks; unlock schedule1–10. Runtime HUD/unlock behavior PENDING.
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
| Gameplay | PENDING | Return mock covers Strength-scaled reflection, recursive-reflection flag, accumulated threshold pulse, allied-damage rejection, Break and the magic-immune target query for its physical pulse; engine event ordering and boss behavior remain pending. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | KV gate schedules ten ranks from hero levels1–10; custom-level HUD/point consumption remains PENDING in Dota. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | English, Russian and Simplified Chinese now have authored skill text; generator and content contract verify aliases, mirrors and configured placeholders. In-game tooltip rendering remains PENDING owner verification. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

2026-09-30 static target-query correction: Return's threshold pulse deals physical damage and its KV declares that it can affect magic-immune enemies, but the Lua radius query used the default flags and excluded them. The pulse query now includes `DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES`; mock coverage asserts the configured query flag. Engine immunity handling and boss behavior remain PENDING.

## Slot 4: `enfos_centaur_stampede`

Classification: PVE-CONVERT
Native counterpart: `centaur_stampede`, verified as native Ability6 in the installed hero KV above. Keeps the global team charge and adds one trampling hit per enemy for each ally during the buff. Duration, speed, mitigation and trampling parameters are KV-driven.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve; free rank / point cost: ten total ranks, `RequiredLevel=5`, five levels between ranks; unlock schedule5,10,15,20,25,30,35,40,45,50. Runtime HUD/unlock behavior PENDING.
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
| Gameplay | PENDING | Stampede mock covers Strength-scaled physical trample, slow and one-hit-per-enemy-per-ally-buff; live overlap, movement cap, boss and dense-wave performance remain pending. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | KV gate schedules ten ultimate ranks from hero levels5–50 in five-level steps; Dota honoring this override and HUD presentation remain PENDING. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | English, Russian and Simplified Chinese now have authored skill text; generator and content contract verify aliases, mirrors and configured placeholders. In-game tooltip rendering remains PENDING owner verification. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 5: `enfos_centaur_colossal_hide`

Classification: REPLACE
Native counterpart: None. `centaur_horsepower` and `centaur_mount` are separate native abilities; Colossal Hide is Enfos-only.
Decision and PvE identity rationale: Keep this custom fifth-slot tank passive; its configured flat block value is read alongside the Strength scaling.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve; free rank / point cost: rank1 is granted free at hero level1 by `heroes/innates.lua`; ten ranks total, `RequiredLevel=1`, one level between ranks. Remaining ranks are learnable on the regular level1–10 ladder; runtime point/HUD behavior PENDING.
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
| Gameplay | PENDING | Colossal Hide mock covers configured physical block, bonus maximum health and Break suppression; engine damage-block order and health-bar behavior remain pending. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Free rank1 is granted separately; KV gate schedules rank upgrades on the same level1–10 ladder. Rank1 free / 49 total points across the five skills is statically documented; Dota runtime remains PENDING. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | English, Russian and Simplified Chinese now have authored skill text; generator and content contract verify aliases, mirrors and configured placeholders. In-game tooltip rendering remains PENDING owner verification. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): all five Enfos slots now declare ten ranks, interpolating existing damage/cooldown endpoints. Enfos Colossal Hide no longer carries Dota's `Innate` marker and disables both block and bonus health under Break. Return rejects allied damage and is disabled by Break; Double Edge cancels its health cost when spell blocked and includes spell-immune enemies in its radius. Stampede emits Valve's verified cast and haste particles and applies a non-purgable global buff. Turkish descriptions now match actual Lua damage types, scaling, self-cost, thresholds and effects; generated locale mirrors are synchronized. Regressions cover spell-block and Return allied/Break handling. Hero regression suite and Valve VPK particle checks pass. Engine/VConsole play, boss control, particle attachments/timing, sound, reconnect and level-point schedule remain PENDING.

2026-09-30 Centaur mock-coverage expansion: added positive behavior tests for Return's reflection plus threshold pulse and reflection flag, Stampede's once-per-ally trample damage/slow, and Colossal Hide's Strength block, extra-health and Break handling. Full `node tools/checks.mjs` passes (200/200 ability mocks). These tests do not verify engine event order, health-bar behavior, particle/sound playback or boss interactions; those remain for live Dota/VConsole validation.

2026-09-30 level-cap integration pilot: all Centaur abilities now have explicit KV rank gates. The three regular abilities unlock ranks1–10 on hero levels1–10; Colossal Hide's free rank1 remains granted by the separate Enfos passive manager, with further ranks using that regular ladder; Stampede unlocks on levels5,10,15,20,25,30,35,40,45,50 so rank10 fits the hero cap. This supersedes the mathematically unreachable 6,11,...,51 ultimate schedule. Static KV tests pass; Dota level-up buttons, rank grants, ultimate badge, initial level6 points and real ability training remain PENDING for the owner's engine test. All 40 heroes now have the corresponding KV gates; this does not certify Dota runtime behavior.

2026-09-30 localization repair: English, Russian and Simplified Chinese ability
titles and descriptions were missing and falling back to Turkish. Added authored
translations for all five skills; the generator emits the aliases, summaries,
intrinsic modifier tooltips and mirrored files. A content contract verifies the
translations retain every configured special-value placeholder. In-game tooltip
rendering remains PENDING owner verification.

2026-09-30 global Break metadata audit: Added KV `IsBreakable 1` to `enfos_centaur_return` because its linked Lua passive implementation check `PassivesDisabled()`. Automated content validation now rejects this metadata mismatch. Actual Dota Break behavior remains PENDING.

2026-10-02 individual source review closed. See `docs/audit/CENTAUR_INDIVIDUAL_REVIEW_2026-10-02.md` for native6943 comparison, per-slot KEEP/TUNE/PVE-CONVERT/REPLACE decisions, focused repairs, exact decoded resource evidence, shared Aghanim limits and owner checklist. This supersedes historical source-not-evaluated rows above, but every actual Dota/VConsole acceptance remains pending.247behavior tests/full checks0failed; no live launch or Workshop upload. Native Work Horse/Double Edge Shard are not implemented by the shared custom upgrade policy. Source closure permits the next queued hero and does not certify gameplay balance, visuals, audio, HUD points or reconnect.
