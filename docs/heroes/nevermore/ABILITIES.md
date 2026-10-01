# Shadow Fiend: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_nevermore`; role: Mage. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_sf_shadowraze` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | nevermore_shadowraze1 |
| 2 | `enfos_sf_necromastery` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | nevermore_necromastery |
| 3 | `enfos_sf_presence_of_the_dark_lord` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | nevermore_dark_lord |
| 4 | `enfos_sf_requiem_of_souls` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | nevermore_requiem |
| 5 | `enfos_sf_feast_of_souls` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | nevermore_frenzy |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_nevermore.txt`; status: FILE_VERIFIED; SHA256: `67de2fc73b3bddf8c2b3bf7943aa1c9c10d3de5e8c9e219a6762cbe37dae3371`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/shadow_fiend/shadow_fiend.vmdl` |
| SoundSet | `Hero_Nevermore` |
| Ability1 | `nevermore_shadowraze1` |
| Ability2 | `nevermore_shadowraze2` |
| Ability3 | `nevermore_shadowraze3` |
| Ability4 | `nevermore_frenzy` |
| Ability5 | `nevermore_dark_lord` |
| Ability6 | `nevermore_requiem` |
| Ability7 | `nevermore_necromastery` |
| Ability10 | `special_bonus_unique_nevermore_7` |
| Ability11 | `special_bonus_unique_nevermore_4` |
| Ability12 | `special_bonus_unique_nevermore_3` |
| Ability13 | `special_bonus_unique_nevermore_frenzy_max_collection_count` |
| Ability14 | `special_bonus_unique_nevermore_1` |
| Ability15 | `special_bonus_unique_nevermore_6` |
| Ability16 | `special_bonus_unique_nevermore_frenzy_castspeed` |
| Ability17 | `special_bonus_unique_nevermore_raze_procsattacks` |
| AttributeStrengthGain | `2.700000` |
| AttributeAgilityGain | `3.600000` |
| AttributeIntelligenceGain | `2.200000` |

### Per-ability review leads

- `enfos_sf_shadowraze`: cast/impact/modifier contract and lifetime.
- `enfos_sf_necromastery`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `enfos_sf_presence_of_the_dark_lord`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `enfos_sf_requiem_of_souls`: ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_sf_feast_of_souls`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-09-30 static special-value repair: moved every Lua-read value for Shadowraze, Necromastery, Presence, Requiem and Feast of Souls from legacy numbered `AbilitySpecial` into named `AbilityValues`, preserving the 10-rank values and scalars. Added a contract for the five-slot schema. This follows the Sven ClientVersion 6941 runtime finding; Shadow Fiend itself has not been live-tested. User-owned Dota gameplay, VFX and audio checks remain pending.

2026-09-30 static passive repair: Necromastery's attack damage and soul gains, Presence's aura, and Feast of Souls' kill sustain now stop under Break and do not trigger from illusions. Added mock regressions for those conditions and valid Feast sustain. Runtime modifier/aura behavior remains pending a Dota test.

2026-09-30 Requiem cast contract repair: removed the channel behavior and channel time that conflicted with the Lua implementation's immediate `OnSpellStart` impact. Requiem retains its 1.67-second cast point, so the damage resolves at the end of the authored wind-up instead of applying and then forcing an empty 1.67-second channel. Added a KV contract regression. Installed snapshot confirms the native Requiem slot identity and particle path, but does not archive the native ability KV; the native cast-point comparison is supported by the [Dota ability timing reference](https://www.dotawiki.de/index.php?title=Nevermore%2C_Shadow_Fiend%2FRequiem_of_Souls) and the callback ordering documented in [ModDota's ability events](https://moddota.com/abilities/datadriven/datadriven-ability-events-modifiers). Actual animation, interruption, audio and damage timing remain PENDING in Dota.

## Slot 1: `enfos_sf_shadowraze`

Classification: PVE-CONVERT
Native counterpart: `nevermore_shadowraze1/2/3` (installed native snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot mapping is authored).
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
| Ranks | PENDING | Q levels 1–10 gate declared; in-game HUD/point behavior remains PENDING. |
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

## Slot 2: `enfos_sf_necromastery`

Classification: PVE-CONVERT
Native counterpart: `nevermore_necromastery` (installed native snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot mapping is authored).
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
| Ranks | PENDING | W levels 1–10 gate declared; in-game HUD/point behavior remains PENDING. |
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

## Slot 3: `enfos_sf_presence_of_the_dark_lord`

Classification: PVE-CONVERT
Native counterpart: `nevermore_dark_lord` (installed native snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot mapping is authored).
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
| Ranks | PENDING | E levels 1–10 gate declared; in-game HUD/point behavior remains PENDING. |
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

## Slot 4: `enfos_sf_requiem_of_souls`

Classification: PVE-CONVERT
Native counterpart: `nevermore_requiem` (installed native snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot mapping is authored).
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

## Slot 5: `enfos_sf_feast_of_souls`

Classification: PVE-CONVERT
Native counterpart: `Enfos Feast of Souls; native nevermore_frenzy identity` (installed native snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot mapping is authored).
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
| Ranks | PENDING | Separate passive rank 1 grant retained; ranks 2–10 gates declared; in-game HUD/point behavior remains PENDING. |
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

2026-09-30 level-cap integration: all five Shadow Fiend abilities now declare KV rank gates. Q/W/E and the Enfos passive use one rank per level; passive rank 1 remains a separate Enfos grant. Requiem of Souls ranks 1–10 unlock on levels 5, 10, …, 50. Static KV contract passes; actual rank buttons, level-up points, ultimate badge and match-start level 6 remain PENDING for owner testing.

2026-09-30 global Break metadata audit: Added KV `IsBreakable 1` to `enfos_sf_necromastery`, `enfos_sf_presence_of_the_dark_lord`, `enfos_sf_feast_of_souls` because its linked Lua passive implementation check `PassivesDisabled()`. Automated content validation now rejects this metadata mismatch. Actual Dota Break behavior remains PENDING.
