# Underlord: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_abyssal_underlord`; role: Tank. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_underlord_firestorm` | 10 | DOTA_ABILITY_BEHAVIOR_POINT \| DOTA_ABILITY_BEHAVIOR_AOE | abilities/pve_kits | abyssal_underlord_firestorm |
| 2 | `enfos_underlord_pit_of_malice` | 10 | DOTA_ABILITY_BEHAVIOR_POINT \| DOTA_ABILITY_BEHAVIOR_AOE | abilities/pve_kits | abyssal_underlord_pit_of_malice |
| 3 | `enfos_underlord_atrophy_aura` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | abyssal_underlord_atrophy_aura |
| 4 | `enfos_underlord_dark_rift` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | abyssal_underlord_dark_rift |
| 5 | `enfos_underlord_abyssal_carapace` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | abyssal_underlord_atrophy_aura |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_abyssal_underlord.txt`; status: FILE_VERIFIED; SHA256: `31060e5fdf53b01592b172f9f40a1113f9b8af09b3494750bbe881f34461a5d8`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/abyssal_underlord/abyssal_underlord_v2.vmdl` |
| SoundSet | `Hero_AbyssalUnderlord` |
| Ability1 | `abyssal_underlord_firestorm` |
| Ability2 | `abyssal_underlord_pit_of_malice` |
| Ability3 | `abyssal_underlord_atrophy_aura` |
| Ability4 | `abyssal_underlord_raid_boss` |
| Ability5 | `generic_hidden` |
| Ability6 | `abyssal_underlord_dark_portal` |
| Ability10 | `special_bonus_unique_underlord_7` |
| Ability11 | `special_bonus_unique_underlord_8` |
| Ability12 | `special_bonus_unique_underlord_6` |
| Ability13 | `special_bonus_unique_underlord_5` |
| Ability14 | `special_bonus_unique_underlord_4` |
| Ability15 | `special_bonus_unique_underlord_3` |
| Ability16 | `special_bonus_unique_underlord` |
| Ability17 | `special_bonus_unique_underlord_9` |
| AttributeStrengthGain | `3.2` |
| AttributeAgilityGain | `1.600000` |
| AttributeIntelligenceGain | `2.300000` |

### Per-ability review leads

- `enfos_underlord_firestorm`: world position, travel/impact timing and radius alignment.
- `enfos_underlord_pit_of_malice`: world position, travel/impact timing and radius alignment.
- `enfos_underlord_atrophy_aura`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `enfos_underlord_dark_rift`: ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_underlord_abyssal_carapace`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-10-02 source review: the installed hero KV declares `GameSoundsFile` as `soundevents/game_sounds_heroes/game_sounds_abyssal_underlord.vsndevts`, and the kit emits three events from that bank (`Hero_AbyssalUnderlord.Firestorm.Cast`, `.PitOfMalice`, `.DarkRift.Cast`). The bank was missing from startup sound pre-cache; added it. Native AbilityDefinitions give Firestorm, Pit and legacy Dark Rift cast animations 1, 2 and 4 respectively; the Enfos custom KV omitted all three, so these fields are now explicit. Static checks cover animations and bank registration. In-game sound and gesture presentation remain PENDING owner Dota/VConsole test.

2026-09-30 Atrophy Aura repair: death-stack rewards (normal enemy, boss) and attack damage per stack are now named KV values instead of hidden Lua constants. The regression sets non-default values and confirms nearby normal/boss deaths award the configured stack amounts, distant deaths award none, the resulting attack damage uses the configured per-stack value, and Break suppresses the passive bonus. EN/TR/RU/zh-CN descriptions now state the base bonus, per-stack bonus, reduction and normal/boss stack awards. This is static/mock evidence; in-game stacks, aura behavior, localization rendering and Break remain PENDING.

2026-09-30 static special-value repair: migrated all five abilities to named `AbilityValues`, retaining their current 10-rank arrays and scalar values. Follow-up review confirmed native Firestorm identity is repeated ground waves; the prior Lua dealt only one immediate hit despite declaring `wave_count=6`. Firestorm now applies an immediate first wave plus five waves at the configured one-second interval, with a distinct wave particle and its existing burn per hit. Mock coverage verifies six waves; no in-game test is claimed. Visual, audio, timing and engine checks remain for the user.

## Slot 1: `enfos_underlord_firestorm`

Classification: PVE-CONVERT
Native counterpart: `abyssal_underlord_firestorm` (installed native snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot mapping is authored).
Decision and PvE identity rationale: PVE-CONVERT preserves the identified Dota hero fantasy while changing PvP-only targeting/control for wave, elite and boss play.
Expected behavior: Place six ground impacts at the target point: the first is immediate and five more arrive one second apart. Each impact deals ranked magic damage in radius and refreshes the existing burn.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current/target rank: each Enfos slot has ten explicit KV levels. The match is capped at level 50; Q/W/E/R require 40 paid ranks total and passive ranks 2–10 require nine more; the fifth slot rank 1 is free, for 49 spendable points overall. Rank-up HUD/runtime acceptance remains pending.
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
| Gameplay | PASS | Mock regression verifies six total waves, one-second spacing, damage and burn application; engine timing and balance remain unverified. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Q levels 1–10 gates declared; engine HUD/point behavior remains PENDING. |
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

## Slot 2: `enfos_underlord_pit_of_malice`

Classification: PVE-CONVERT
Native counterpart: `abyssal_underlord_pit_of_malice` (installed native snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot mapping is authored).
Decision and PvE identity rationale: PVE-CONVERT preserves the identified Dota hero fantasy while changing PvP-only targeting/control for wave, elite and boss play.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current/target rank: each Enfos slot has ten explicit KV levels. The match is capped at level 50; Q/W/E/R require 40 paid ranks total and passive ranks 2–10 require nine more; the fifth slot rank 1 is free, for 49 spendable points overall. Rank-up HUD/runtime acceptance remains pending.
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
| Ranks | PENDING | W levels 1–10 gates declared; engine HUD/point behavior remains PENDING. |
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

Change/test record: all five slots have MaxLevel 10; all multirank KV values have ten explicit entries. Rank-up HUD, VFX/SFX in match, boss waves and VConsole remain pending a live Dota test.

## Slot 3: `enfos_underlord_atrophy_aura`

Classification: PVE-CONVERT
Native counterpart: `abyssal_underlord_atrophy_aura` (installed native snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot mapping is authored).
Decision and PvE identity rationale: PVE-CONVERT preserves the identified Dota hero fantasy while changing PvP-only targeting/control for wave, elite and boss play.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current/target rank: each Enfos slot has ten explicit KV levels. The match is capped at level 50; Q/W/E/R require 40 paid ranks total and passive ranks 2–10 require nine more; the fifth slot rank 1 is free, for 49 spendable points overall. Rank-up HUD/runtime acceptance remains pending.
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
| Gameplay | PENDING | Normal/boss Atrophy kill-stack rewards and bonus attack damage per stack are KV-backed and mock-tested; actual aura application, nearby death ownership/radius and rank updates remain unverified in Dota. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | E levels 1–10 gates declared; engine HUD/point behavior remains PENDING. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | EN/TR/RU/zh-CN descriptions expose base damage, damage per stack, attack damage reduction and normal/boss stack awards; rendered game text remains unverified. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: Atrophy's per-stack damage and normal/boss death stack rewards are named KV values, and EN/TR/RU/zh-CN descriptions document them. The mock suite verifies non-default configured rewards, range handling, per-stack attack damage and Break. In-game aura application, rank-up HUD, VFX/SFX, boss waves and VConsole remain pending a live Dota test.

## Slot 4: `enfos_underlord_dark_rift`

Classification: PVE-CONVERT
Native counterpart: `abyssal_underlord_dark_portal` (installed native snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot mapping is authored).
Decision and PvE identity rationale: PVE-CONVERT preserves the identified Dota hero fantasy while changing PvP-only targeting/control for wave, elite and boss play.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current/target rank: each Enfos slot has ten explicit KV levels. The match is capped at level 50; Q/W/E/R require 40 paid ranks total and passive ranks 2–10 require nine more; the fifth slot rank 1 is free, for 49 spendable points overall. Rank-up HUD/runtime acceptance remains pending.
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
| Ranks | PENDING | R levels 5–50 in five-level steps declared; ultimate HUD/point behavior remains PENDING. |
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

## Slot 5: `enfos_underlord_abyssal_carapace`

Classification: REPLACE
Native counterpart: `Project Abyssal Carapace passive; native Underlord innate kept separate` (installed native snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot mapping is authored).
Decision and PvE identity rationale: REPLACE because this Enfos-authored passive has no one-to-one native counterpart; Dota innate metadata remains a separate ability.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current/target rank: each Enfos slot has ten explicit KV levels. The match is capped at level 50; Q/W/E/R require 40 paid ranks total and passive ranks 2–10 require nine more; the fifth slot rank 1 is free, for 49 spendable points overall. Rank-up HUD/runtime acceptance remains pending.
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
| Ranks | PENDING | Separate passive rank 1 grant retained; ranks 2–10 gates declared; HUD/point behavior remains PENDING. |
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

2026-09-30 level-cap integration: all five Underlord abilities now declare KV rank gates. Q/W/E and the Enfos passive use one rank per level; passive rank 1 remains a separate Enfos grant. Dark Rift ranks 1–10 unlock on levels 5, 10, …, 50. Static KV contract passes; actual rank buttons, level-up points, ultimate badge and match-start level 6 remain PENDING for owner testing.

2026-09-30 follow-up static kit review: Pit of Malice, Atrophy Aura, Dark Rift and Abyssal Carapace Lua callbacks were checked against their named KV values, hero slot assignments, shared Aghanim manager, tooltips and current mocks. Added mock regressions for pit damage/root duration and boss reduction, Atrophy death stacks/Break/debuff, Dark Rift damage/boss cap and Carapace stats/Break. Targeted suite now reports 172 passing tests (mock engine only). `node tools/verify_particles.mjs` found all three literal Underlord particle paths in the installed Valve VPK and they are registered in the existing addon precache. This proves file presence and registration only; correct CPs, on-screen appearance, sound event validity/audibility, animation, boss balance and Dota/VConsole behavior remain pending owner live test. No further confirmed Lua defect was found in this pass. Scepter's generic ultimate damage/cooldown bonuses and Tank Shard health/reflection come from `heroes/aghanim_manager.lua`, not ability-local callbacks. The custom Carapace reuses the Atrophy icon; dedicated icon fit remains a visual review item.

2026-09-30 global Break metadata audit: Added KV `IsBreakable 1` to `enfos_underlord_atrophy_aura`, `enfos_underlord_abyssal_carapace` because its linked Lua passive implementation check `PassivesDisabled()`. Automated content validation now rejects this metadata mismatch. Actual Dota Break behavior remains PENDING.
