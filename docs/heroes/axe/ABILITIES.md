# Axe: ability evidence dossier

This dossier preserves its historical PENDING setup below. The 2026-10-02 [individual Axe review](../../audit/AXE_INDIVIDUAL_REVIEW_2026-10-01.md) supersedes those setup rows for SOURCE REVIEW, using installed build6942/SourceRevision11055158. All five skills have detailed source evidence and focused regression repairs; actual Dota/VConsole acceptance remains OWNER ENGINE PENDING. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_axe`; role: Tank. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_axe_berserkers_call` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | axe_berserkers_call |
| 2 | `enfos_axe_battle_hunger` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/pve_kits | axe_battle_hunger |
| 3 | `enfos_axe_counter_helix` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | axe_counter_helix |
| 4 | `enfos_axe_culling_blade` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/pve_kits | axe_culling_blade |
| 5 | `enfos_axe_blood_armor` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | axe_foreboding |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_axe.txt`; status: FILE_VERIFIED; SHA256: `c91a8721a951d45c5c010769f68a650474d512819bae6a191306b652c71b999f`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/axe/axe.vmdl` |
| SoundSet | `Hero_Axe` |
| Ability1 | `axe_berserkers_call` |
| Ability2 | `axe_battle_hunger` |
| Ability3 | `axe_counter_helix` |
| Ability4 | `generic_hidden` |
| Ability5 | `generic_hidden` |
| Ability6 | `axe_culling_blade` |
| Ability7 | `axe_one_man_army` |
| Ability10 | `special_bonus_unique_axe_culling_blade_speed_duration` |
| Ability11 | `special_bonus_unique_axe_8` |
| Ability12 | `special_bonus_unique_axe` |
| Ability13 | `special_bonus_unique_axe_7` |
| Ability14 | `special_bonus_strength_15` |
| Ability15 | `special_bonus_unique_axe_4` |
| Ability16 | `special_bonus_unique_axe_2` |
| Ability17 | `special_bonus_unique_axe_5` |
| AttributeStrengthGain | `2.7` |
| AttributeAgilityGain | `1.7` |
| AttributeIntelligenceGain | `1.6` |

### Per-ability review leads

- `enfos_axe_berserkers_call`: cast/impact/modifier contract and lifetime.
- `enfos_axe_battle_hunger`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_axe_counter_helix`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `enfos_axe_culling_blade`: target flags, immunity, spell block/reflect if applicable, target loss; ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_axe_blood_armor`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

## Slot 1: `enfos_axe_berserkers_call`

Classification: PVE-CONVERT
Native counterpart: `axe_berserkers_call`, verified in the installed Axe hero KV above. The custom implementation retains its recognizable area taunt and armor window, with boss taunt duration reduced to 25%; this is a purposeful PvE adaptation.
Decision and PvE identity rationale: Keep the native Call identity and custom boss tuning. The ten-rank curve preserves the previous rank-one/rank-four armor and cooldown endpoints; boss taunt scaling is now data-driven.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Berserker’s Call Q ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
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
| Ranks | PENDING | Q gates levels 1–10 declared; HUD/point behavior remains PENDING engine verification. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | English, Russian and Simplified Chinese now have authored tooltip text; the generator and content contract verify aliases, mirrors and configured placeholders. In-game tooltip rendering remains PENDING owner verification. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 2: `enfos_axe_battle_hunger`

Classification: PVE-CONVERT
Native counterpart: `axe_battle_hunger`, verified in the installed Axe hero KV above. Retains the signature curse while adding caster speed and bounded on-death spread for wave combat.
Decision and PvE identity rationale: Retain the curse identity and current PvE additions. Migrated Lua-read values to `AbilityValues` unchanged. Death spread now reads radius, duration and target count from the ability KV; static regression confirms radius and target cap are honored.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Battle Hunger W ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
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
| Ranks | PENDING | W gates levels 1–10 declared; HUD/point behavior remains PENDING engine verification. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | English, Russian and Simplified Chinese now have authored tooltip text; the generator and content contract verify aliases, mirrors and configured placeholders. In-game tooltip rendering remains PENDING owner verification. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 3: `enfos_axe_counter_helix`

Classification: PVE-CONVERT
Native counterpart: `axe_counter_helix`, verified in the installed Axe hero KV above. Retains the reactive spin proc and changes its damage/rank model for PvE.
Decision and PvE identity rationale: Keep the iconic reactive AoE; retain current pure damage and boss proc throttle as custom PvE behavior. Migrated Lua-read values to `AbilityValues` unchanged.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Counter Helix E ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
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
| Ranks | PENDING | E gates levels 1–10 declared; HUD/point behavior remains PENDING engine verification. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | English, Russian and Simplified Chinese now have authored tooltip text; the generator and content contract verify aliases, mirrors and configured placeholders. In-game tooltip rendering remains PENDING owner verification. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 4: `enfos_axe_culling_blade`

Classification: PVE-CONVERT
Native counterpart: `axe_culling_blade`, verified as native Ability6 in the installed Axe hero KV above. Retains the execution identity and team speed reward; the boss execute threshold is custom-capped at 15%.
Decision and PvE identity rationale: Keep the native finisher identity. Migrated Lua-read values to `AbilityValues` unchanged and fixed the confirmed mismatch where configured `speed_duration` was ignored in favor of a hardcoded 6 seconds.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Culling Blade R ranks 1–10 are KV-gated at levels 5, 10, …, 50; ultimate UI and point behavior remain PENDING.
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
| Ranks | PENDING | R gates levels 5–50 in five-level steps declared; ultimate HUD/point behavior remains PENDING. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | English, Russian and Simplified Chinese now have authored tooltip text; the generator and content contract verify aliases, mirrors and configured placeholders. In-game tooltip rendering remains PENDING owner verification. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 5: `enfos_axe_blood_armor`

Classification: REPLACE
Native counterpart: None. This is Enfos-only; `axe_one_man_army` is the separate native innate and must not be conflated with this custom fifth-slot passive.
Decision and PvE identity rationale: Preserve this Enfos identity as its own starting passive. Migrated its Lua-read values to `AbilityValues` unchanged; stack, Break, respawn and upgrade acceptance remain pending.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: The Enfos passive rank 1 is granted separately; ranks 2–10 are KV-gated at levels 2–10; engine point/UI behavior remains PENDING.
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
| Localization | PENDING | English, Russian and Simplified Chinese now have authored tooltip text; the generator and content contract verify aliases, mirrors and configured placeholders. In-game tooltip rendering remains PENDING owner verification. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): all five Enfos slots now declare ten ranks; ranked values interpolate the existing low/high endpoints. Counter Helix now uses a configurable attack counter (7→3 attacks across ten ranks), matching Valve's attack-count design instead of the previous random roll. Enfos Blood Armor no longer carries the Dota `Innate` KV flag, uses its own verified Axe icon, keeps kill stacks through death, respects Break, and reflects only enemy physical damage. Call/Counter Helix include spell-immune enemies; Hunger and Culling Blade reject spell-blocked or invalid targets; Culling Blade has a hit-sparks effect on its non-execute hit. Five Axe particles are now in the VPK asset check, and Turkish tooltips describe the mechanics and rank values. Mock suite and full `node tools/checks.mjs` pass. Dota/VConsole gameplay, effect timing/attachment quality, sound-bank behavior, and point/unlock schedule remain PENDING. Static asset existence and mocks are not ENGINE_PASS.

2026-09-30 level-cap integration: all five Axe abilities now declare KV rank gates. Q/W/E and the Enfos passive use one rank per level; passive rank 1 remains a separate Enfos grant. Culling Blade ranks 1–10 unlock on levels 5, 10, …, 50. Static KV contract passes; actual rank buttons, level-up points, ultimate badge and match-start level 6 remain PENDING for owner testing.

2026-09-30 localization repair: the English, Russian and Simplified Chinese Axe
ability tooltips had silently inherited Turkish text from the localization
fallback. Added authored translations for all five abilities; the generator
creates their lowercase aliases, summaries, modifier tooltips and three file
mirrors. A content contract confirms each language has its own text and retains
the configured special-value placeholders. In-game tooltip display remains
PENDING owner verification.

2026-09-30 static regression follow-up: added direct coverage for Blood Armor's
physical-only reflection, reflection-flag recursion guard, and Break suppression.
Added Culling Blade boss-threshold coverage as well: a boss above its configured
15% threshold takes the normal hit, while one at the threshold is executed.
These close mock-coverage gaps only; Dota damage-event behavior, live execution,
effects, sound, and rank UI remain pending owner test.

2026-09-30 global Break metadata audit: Added KV `IsBreakable 1` to `enfos_axe_counter_helix` because its linked Lua passive implementation check `PassivesDisabled()`. Automated content validation now rejects this metadata mismatch. Actual Dota Break behavior remains PENDING.
