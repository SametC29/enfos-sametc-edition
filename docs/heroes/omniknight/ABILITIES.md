# Omniknight: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_omniknight`; role: Support. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_omni_purification` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET \| DOTA_ABILITY_BEHAVIOR_AOE | abilities/pve_kits | omniknight_purification |
| 2 | `enfos_omni_repel` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/pve_kits | omniknight_repel |
| 3 | `enfos_omni_degen_aura` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE \| DOTA_ABILITY_BEHAVIOR_AURA | abilities/pve_kits | omniknight_degen_aura |
| 4 | `enfos_omni_guardian_angel` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | omniknight_guardian_angel |
| 5 | `enfos_omni_hammer_of_purity` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | omniknight_hammer_of_purity |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_omniknight.txt`; status: FILE_VERIFIED; SHA256: `c8f030c542ace2c12940d6e7c768557f23be9962051569014db4009d4108ceab`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/omniknight/omniknight.vmdl` |
| SoundSet | `Hero_Omniknight` |
| Ability1 | `omniknight_purification` |
| Ability2 | `omniknight_martyr` |
| Ability3 | `omniknight_hammer_of_purity` |
| Ability4 | `omniknight_degen_aura` |
| Ability5 | `generic_hidden` |
| Ability6 | `omniknight_guardian_angel` |
| Ability10 | `special_bonus_unique_omniknight_2` |
| Ability11 | `special_bonus_attack_base_damage_30` |
| Ability12 | `special_bonus_unique_omniknight_3` |
| Ability13 | `special_bonus_unique_omniknight_7` |
| Ability14 | `special_bonus_unique_omniknight_degen_aura_radius` |
| Ability15 | `special_bonus_unique_omniknight_6` |
| Ability16 | `special_bonus_unique_omniknight_1` |
| Ability17 | `special_bonus_unique_omniknight_4` |
| AttributeStrengthGain | `3.10000` |
| AttributeAgilityGain | `1.7` |
| AttributeIntelligenceGain | `2.100000` |

### Per-ability review leads

- `enfos_omni_purification`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_omni_repel`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_omni_degen_aura`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `enfos_omni_guardian_angel`: ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_omni_hammer_of_purity`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

### Omniknight pilot repair and rank migration — 2026-09-30

The installed ClientVersion 6941 hero KV confirms native Purification,
Martyr, Hammer of Purity, Degen Aura, hidden fifth slot, and Guardian Angel.
Enfos keeps its custom Repel on slot 2 as an identity choice; current Valve
hero documentation describes Repel as granting debuff immunity and health
regeneration, while the official 7.00 notes explicitly say Repel's immunity
could not be dispelled. The custom buff now uses `MODIFIER_STATE_DEBUFF_IMMUNE`
and cannot be purged. It still includes this project's Strength and armor
bonuses. This is not mapped to native Martyr by slot or icon.

All five Enfos abilities now have `MaxLevel 10`, ten-rank primary value curves,
and ten-rank cooldown/mana curves where applicable. Existing endpoint values
are retained. The Enfos fifth passive is granted by the roster's separate
`heroes/innates.lua` system; its KV `Innate` marker is removed so Dota does not
misidentify it. Hero XP, rank unlock level, point cost, and free passive point
distribution remain a separate level-50 progression gate.

The gameplay repairs add target/caster/team/alive guards to Purification and
Repel, explicitly disable Repel purging, and disable Degen Aura while its
owner is Broken. The aura source and its affected debuff now use verified
Omniknight VPK particle paths. Hammer of Purity's already-used detonation
particle is now precached; the old passive handler also safely rejects missing,
dead, allied and Broken attack events. Repel's localized tooltip now says
debuff immunity rather than obsolete magic immunity (EN/TR/RU/zh-CN).

Resource evidence: the installed VPK contains
`omniknight_degen_aura.vpcf_c`, `omniknight_degen_aura_debuff.vpcf_c`,
`omniknight_hammer_of_purity_detonation.vpcf_c`, plus the Purification,
Repel-buff, and Guardian Angel particles. `node tools/verify_particles.mjs`
passes for the tracked pilot particle set. Native sound bank is present, but
event definitions, audible playback, particle CP/attachment fit and in-client
rendering are not certified by file presence. `node tools/checks.mjs`, the
84-test hero-kit mock suite and all 200 ability / 212 modifier rank smoke tests
pass. Dota/VConsole interaction, visual/audio behavior, boss damage balance,
upgrade behavior, and live rank unlocks remain ENGINE_PENDING.

References: [Valve Omniknight hero page](https://www.dota2.com/hero/omniknight),
[Valve 7.00 Repel notes](https://www.dota2.com/700/gameplay/?l=turkish).

### Pilot review and ability-value repair — 2026-09-29

The installed ClientVersion 6941 source snapshot identifies Purification,
Degen Aura, Guardian Angel, and Hammer of Purity as native counterparts for
Enfos Q/E/R/fifth passive; these are PVE-CONVERT and retain healing, team
defense, area debuff, and pure-damage identities. Native Ability2 is
`omniknight_martyr`, so the Enfos `omniknight_repel` counterpart remains
UNASSESSED until its mechanic is compared with that source; the icon does not
settle the mapping.

All five KV blocks now use named `AbilityValues`; their numeric values and
current ranks are unchanged. The fifth passive had localized slow values but
did not apply them in Lua. It now applies the configured two-second slow to its
attack target; the regression checks the actual modifier property. Static checks
pass, while live healing, aura, Break, VFX/SFX, boss and Scepter/Shard behavior
remain pending. Level-50 / ten-rank progression remains separate.

Follow-up review (2026-09-29): Purification's duplicate, unused KV damage field
was removed so its matching heal/damage amount is the single native-style value;
its Strength coefficient is now configured. Degen Aura's pure-damage tick and
Hammer of Purity's splash radius, splash percent, lifesteal and Strength factor
are data-driven, and affected descriptions now match those effects. The Degen
Aura mock verifies configured pure damage and slows. The installed ClientVersion
6941 snapshot lists Martyr in native Ability2, while Valve's live hero page
documents Repel; the Enfos slot retains its established Repel protection
behavior. Runtime immunity, healing, visual/audio, boss and tooltip checks remain
PENDING.

## Slot 1: `enfos_omni_purification`

Classification: PVE-CONVERT
Native counterpart: `omniknight_purification` (installed ClientVersion 6941 source snapshot).
Decision and PvE identity rationale: Keep the allied instant heal and damage-to-nearby-enemies tradeoff for solo wave utility.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Rank data: Q ranks 1–10 gated at levels 1–10; engine HUD and point behavior remain PENDING.
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
| Ranks | PENDING | Q ranks 1–10 gated at levels 1–10; engine HUD and point behavior remain PENDING. |
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

Change/test record (2026-09-30): source/mock changes and suite results are recorded above; Dota/VConsole acceptance remains PENDING.

## Slot 2: `enfos_omni_repel`

Classification: PVE-CONVERT
Native counterpart: `omniknight_repel`, documented on [Valve's Omniknight hero page](https://www.dota2.com/hero/omniknight). The installed ClientVersion 6941 hero-source snapshot currently lists `omniknight_martyr` at native Ability2, so the Enfos slot explicitly retains Omniknight's established Repel identity rather than inferring from slot position.
Decision and PvE identity rationale: Preserve Omniknight's ally-protection identity for the support slot. The current Lua grants magic immunity, HP regeneration, Strength and armor for the configured duration.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Rank data: W ranks 1–10 gated at levels 1–10; engine HUD and point behavior remain PENDING.
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
| Ranks | PENDING | W ranks 1–10 gated at levels 1–10; engine HUD and point behavior remain PENDING. |
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

Change/test record (2026-09-30): source/mock changes and suite results are recorded above; Dota/VConsole acceptance remains PENDING.

## Slot 3: `enfos_omni_degen_aura`

Classification: PVE-CONVERT
Native counterpart: `omniknight_degen_aura` (installed ClientVersion 6941 source snapshot).
Decision and PvE identity rationale: Preserve the enemy slow aura and tune its radius/strength for grouped PvE waves.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Rank data: E ranks 1–10 gated at levels 1–10; engine HUD and point behavior remain PENDING.
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
| Ranks | PENDING | E ranks 1–10 gated at levels 1–10; engine HUD and point behavior remain PENDING. |
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

Change/test record (2026-09-30): source/mock changes and suite results are recorded above; Dota/VConsole acceptance remains PENDING.

## Slot 4: `enfos_omni_guardian_angel`

Classification: PVE-CONVERT
Native counterpart: `omniknight_guardian_angel` (installed ClientVersion 6941 source snapshot).
Decision and PvE identity rationale: Preserve the team physical-protection ultimate and add a bounded team sustain component.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Rank data: Guardian Angel R ranks 1–10 gated at levels 5, 10, …, 50; ultimate HUD and point behavior remain PENDING.
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
| Ranks | PENDING | Guardian Angel R ranks 1–10 gated at levels 5, 10, …, 50; ultimate HUD and point behavior remain PENDING. |
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

Change/test record (2026-09-30): source/mock changes and suite results are recorded above; Dota/VConsole acceptance remains PENDING.

## Slot 5: `enfos_omni_hammer_of_purity`

Classification: PVE-CONVERT
Native counterpart: `omniknight_hammer_of_purity` (installed ClientVersion 6941 source snapshot).
Decision and PvE identity rationale: Retain bonus pure damage on attacks, with sustain, splash and slow to support wave clear.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Rank data: Enfos passive rank 1 remains separately granted; ranks 2–10 gated at levels 2–10; HUD/point behavior remains PENDING.
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
| Ranks | PENDING | Enfos passive rank 1 remains separately granted; ranks 2–10 gated at levels 2–10; HUD/point behavior remains PENDING. |
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

Change/test record (2026-09-30): see “Omniknight pilot repair and rank migration” above. All runtime acceptance rows remain PENDING until validated in the Dota client and VConsole.

2026-09-30 level-cap integration: all five Omniknight abilities now declare KV rank gates. Q/W/E and the Enfos passive use one rank per level; passive rank 1 remains a separate Enfos grant. Guardian Angel ranks 1–10 unlock on levels 5, 10, …, 50. Static KV contract passes; actual rank buttons, level-up points, ultimate badge and match-start level 6 remain PENDING for owner testing.

2026-09-30 global Break metadata audit: Added KV `IsBreakable 1` to `enfos_omni_degen_aura`, `enfos_omni_hammer_of_purity` because its linked Lua passive implementation check `PassivesDisabled()`. Automated content validation now rejects this metadata mismatch. Actual Dota Break behavior remains PENDING.

### Individual source review — 2026-10-01 / build6942

All five abilities retain PVE-CONVERT classification with per-skill native comparison, source trace, resource CP/cleanup, upgrades, localization, tests and owner acceptance checklist in [the individual review](../../audit/OMNIKNIGHT_INDIVIDUAL_REVIEW_2026-10-01.md). This current source record supersedes initial setup placeholders and historical6941 observations where later corrections are recorded. Repel grants debuff immunity (not magic immunity). Purification native piercing/target indicator, Hammer lethal splash/impact CP, Degen radius ownership, Guardian Angel recipient effects, Scepter text and visible modifier identities were repaired.226 behavior regressions and full checks pass; all gameplay/render/audio/VConsole acceptance remains ENGINE PENDING. No talents, permanent progression, native Shard recast/global Angel promise or Workshop publication was added.
