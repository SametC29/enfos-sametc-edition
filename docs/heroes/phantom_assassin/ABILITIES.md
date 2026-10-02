# Phantom Assassin: ability evidence dossier

Native identifiers and custom slots were checked against the installed Dota 2 ClientVersion 6941 / SourceRevision 11041083 snapshot. This dossier remains a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_phantom_assassin`; role: Carry. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_pa_stifling_dagger` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/pve_kits | phantom_assassin_stifling_dagger |
| 2 | `enfos_pa_phantom_strike` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET \| DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES | abilities/pve_kits | phantom_assassin_phantom_strike |
| 3 | `enfos_pa_blur` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | phantom_assassin_blur |
| 4 | `enfos_pa_coup_de_grace` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | phantom_assassin_coup_de_grace |
| 5 | `enfos_pa_immaterial` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | phantom_assassin_immaterial |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_phantom_assassin.txt`; status: FILE_VERIFIED; SHA256: `78f9c1ae238b3ecd2e41288478fb9c545fd8ab8476f2309b6a0a4c46a70b4b88`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/phantom_assassin/phantom_assassin.vmdl` |
| SoundSet | `Hero_PhantomAssassin` |
| Ability1 | `phantom_assassin_stifling_dagger` |
| Ability2 | `phantom_assassin_phantom_strike` |
| Ability3 | `phantom_assassin_blur` |
| Ability4 | `phantom_assassin_fan_of_knives` |
| Ability5 | `phantom_assassin_immaterial` |
| Ability6 | `phantom_assassin_coup_de_grace` |
| Ability10 | `special_bonus_unique_phantom_assassin_4` |
| Ability11 | `special_bonus_unique_phantom_assassin_7` |
| Ability12 | `special_bonus_unique_phantom_assassin_3` |
| Ability13 | `special_bonus_unique_phantom_assassin_5` |
| Ability14 | `special_bonus_unique_phantom_assassin_6` |
| Ability15 | `special_bonus_unique_phantom_assassin_strike_aspd` |
| Ability16 | `special_bonus_unique_phantom_assassin_2` |
| Ability17 | `special_bonus_unique_phantom_assassin` |
| AttributeStrengthGain | `2.2` |
| AttributeAgilityGain | `3.40000` |
| AttributeIntelligenceGain | `1.700000` |

### Per-ability review leads

- `enfos_pa_stifling_dagger`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_pa_phantom_strike`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_pa_blur`: cast/impact/modifier contract and lifetime.
- `enfos_pa_coup_de_grace`: intrinsic modifier, Break/illusion behavior, live rank refresh; ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_pa_immaterial`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-09-30 modifier-link repair: `modifier_enfos_pa_immaterial_passive` was defined and returned as the slot-5 intrinsic modifier but missing from the shared `LinkLuaModifier` registry. Added the link and a registry contract covering every local Enfos modifier class. Lua/mock and static registration checks pass; engine attachment, Break and evasion behavior remain PENDING owner testing.

2026-09-30 physical-area/value repair: Stifling Dagger chain and Coup de Grace
splash were using radius searches with default flags, which omit spell-immune
enemies despite applying physical damage. Both searches now include
`DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES`. Dagger Agility coefficient, chain
radius and secondary damage percentage, plus Coup splash radius/percentage, are
named KV values. EN/TR/RU/zh-CN descriptions now state those formulas. Mocks
assert configured values and search flags; actual immunity handling and damage
remain PENDING owner testing.

2026-09-30 Break metadata repair: Blur, Coup de Grace and the Enfos fifth-slot
Immaterial passive checked `PassivesDisabled()` in Lua but lacked KV
`IsBreakable`. Added the missing metadata and a rank-contract assertion for all
three passives. In-engine Break/evasion behavior remains PENDING owner testing.

## Slot 1: `enfos_pa_stifling_dagger`

Classification: PVE-CONVERT
Native counterpart: `phantom_assassin_stifling_dagger` (installed hero KV Ability1, ClientVersion 6941 / SourceRevision 11041083). Preserve its targeted dagger projectile; Enfos adds bounded two-target chaining and PvE scaling.
Decision and PvE identity rationale: Preserve its targeted dagger projectile; Enfos adds bounded two-target chaining and PvE scaling.
Expected cast/travel/impact/ongoing/cleanup behavior: Damage is calculated at cast; tracking daggers apply physical damage and configured slow on impact. Projectiles and their visual/audio behavior need live confirmation.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current rank target is now MaxLevel 10 on each of the five Enfos slots; slot 5 still starts at rank 1 for free through the separate Enfos innate service. Level-50 KV rank gates are configured; engine point allocation and HUD behavior remain pending owner verification.
Shard role bonus remains global (+15% movement speed and +12% attack pure damage for Carry). Coup de Grace has the generic Scepter marker; these integrations need runtime verification.

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
| Ranks | PENDING | Q ranks 1–10 are KV-gated at hero levels 1–10. HUD unlock and point behavior remain PENDING engine validation. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PASS | EN/TR/RU/zh-CN generated and validated against KV special keys; engine tooltip rendering remains pending. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): extended every skill to ten KV ranks; removed the false Dota Innate marker; added spell-block/team guards, Break handling for passives, Q hit impact VFX and verified missing precache entries. Automated regression now covers Dagger projectile, spell block, Phantom Strike facing and passive Break. Live gameplay, VFX/SFX quality and VConsole remain PENDING; no ENGINE_PASS claimed.

## Slot 2: `enfos_pa_phantom_strike`

Classification: PVE-CONVERT
Native counterpart: `phantom_assassin_phantom_strike` (installed hero KV Ability2, same source snapshot). Preserve target teleport/attack identity; PvE sustain is the custom healing component.
Decision and PvE identity rationale: Preserve target teleport/attack identity; PvE sustain is the custom healing component.
Expected cast/travel/impact/ongoing/cleanup behavior: On cast, teleport behind the target using its forward vector, then grant configured attack speed and damage-based healing for the configured duration.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current rank target is now MaxLevel 10 on each of the five Enfos slots; slot 5 still starts at rank 1 for free through the separate Enfos innate service. Level-50 KV rank gates are configured; engine point allocation and HUD behavior remain pending owner verification.
Shard role bonus remains global (+15% movement speed and +12% attack pure damage for Carry). Coup de Grace has the generic Scepter marker; these integrations need runtime verification.

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
| Gameplay | PASS | `node tools/checks.mjs`: facing-aware Phantom Strike destination / Immaterial intrinsic value test passed; actual Dota behavior remains pending. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | W ranks 1–10 are KV-gated at hero levels 1–10. HUD unlock and point behavior remain PENDING engine validation. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PASS | EN/TR/RU/zh-CN generated and validated against KV special keys; engine tooltip rendering remains pending. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): extended every skill to ten KV ranks; removed the false Dota Innate marker; added spell-block/team guards, Break handling for passives, Q hit impact VFX and verified missing precache entries. Automated regression now covers Dagger projectile, spell block, Phantom Strike facing and passive Break. Live gameplay, VFX/SFX quality and VConsole remain PENDING; no ENGINE_PASS claimed.

## Slot 3: `enfos_pa_blur`

Classification: PVE-CONVERT
Native counterpart: `phantom_assassin_blur` (installed hero KV Ability3, same source snapshot). The authored active/invisibility behavior is Enfos-specific; passive evasion remains the core identity.
Decision and PvE identity rationale: The authored active/invisibility behavior is Enfos-specific; passive evasion remains the core identity.
Expected cast/travel/impact/ongoing/cleanup behavior: Intrinsic evasion plus an activated temporary invisibility modifier; duration and visual/audio fidelity still need engine verification.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current rank target is now MaxLevel 10 on each of the five Enfos slots; slot 5 still starts at rank 1 for free through the separate Enfos innate service. Level-50 KV rank gates are configured; engine point allocation and HUD behavior remain pending owner verification.
Shard role bonus remains global (+15% movement speed and +12% attack pure damage for Carry). Coup de Grace has the generic Scepter marker; these integrations need runtime verification.

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
| Ranks | PENDING | E ranks 1–10 are KV-gated at hero levels 1–10. HUD unlock and point behavior remain PENDING engine validation. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PASS | EN/TR/RU/zh-CN generated and validated against KV special keys; engine tooltip rendering remains pending. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): extended every skill to ten KV ranks; removed the false Dota Innate marker; added spell-block/team guards, Break handling for passives, Q hit impact VFX and verified missing precache entries. Automated regression now covers Dagger projectile, spell block, Phantom Strike facing and passive Break. Live gameplay, VFX/SFX quality and VConsole remain PENDING; no ENGINE_PASS claimed.

## Slot 4: `enfos_pa_coup_de_grace`

Classification: PVE-CONVERT
Native counterpart: `phantom_assassin_coup_de_grace` (installed hero KV Ability6, same source snapshot). Preserve critical-strike identity; Enfos adds a bounded nearby physical splash.
Decision and PvE identity rationale: Preserve critical-strike identity; Enfos adds a bounded nearby physical splash.
Expected cast/travel/impact/ongoing/cleanup behavior: Passive critical strike; on landed crit, damage nearby enemies at half the reported attack damage. Validate proc ownership and boss burst in Dota.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current rank target is now MaxLevel 10 on each of the five Enfos slots; slot 5 still starts at rank 1 for free through the separate Enfos innate service. Level-50 KV rank gates are configured; engine point allocation and HUD behavior remain pending owner verification.
Shard role bonus remains global (+15% movement speed and +12% attack pure damage for Carry). Coup de Grace has the generic Scepter marker; these integrations need runtime verification.

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
| Ranks | PENDING | R ranks 1–10 are KV-gated at levels 5, 10, …, 50. HUD ultimate marker and point behavior remain PENDING engine validation. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PASS | EN/TR/RU/zh-CN generated and validated against KV special keys; engine tooltip rendering remains pending. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): extended every skill to ten KV ranks; removed the false Dota Innate marker; added spell-block/team guards, Break handling for passives, Q hit impact VFX and verified missing precache entries. Automated regression now covers Dagger projectile, spell block, Phantom Strike facing and passive Break. Live gameplay, VFX/SFX quality and VConsole remain PENDING; no ENGINE_PASS claimed.

## Slot 5: `enfos_pa_immaterial`

Classification: PVE-CONVERT
Native counterpart: `phantom_assassin_immaterial` (installed hero KV Ability5, same source snapshot). This is the fifth Enfos passive and is free-ranked by `heroes/innates.lua`; native Dota innate and Enfos rank systems remain separate. Fan of Knives is an active ability in the native kit and is not used as the passive slot.
Decision and PvE identity rationale: This is the fifth Enfos passive and is free-ranked by `heroes/innates.lua`; native Dota innate and Enfos rank systems remain separate
Expected cast/travel/impact/ongoing/cleanup behavior: Always grants configured evasion through an intrinsic modifier; starts at level 1 through the Enfos innate service.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current rank target is now MaxLevel 10 on each of the five Enfos slots; slot 5 still starts at rank 1 for free through the separate Enfos innate service. Level-50 KV rank gates are configured; engine point allocation and HUD behavior remain pending owner verification.
Shard role bonus remains global (+15% movement speed and +12% attack pure damage for Carry). Coup de Grace has the generic Scepter marker; these integrations need runtime verification.

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
| Gameplay | PASS | `node tools/checks.mjs`: facing-aware Phantom Strike destination / Immaterial intrinsic value test passed; actual Dota behavior remains pending. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | The Enfos passive rank 1 is granted separately; ranks 2–10 are KV-gated at hero levels 2–10. HUD unlock and point behavior remain PENDING engine validation. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Slot-5 intrinsic modifier is now included in the shared LinkLuaModifier registry; engine attachment, evasion and Break behavior remain for owner testing. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PASS | EN/TR/RU/zh-CN generated and validated against KV special keys; engine tooltip rendering remains pending. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): extended every skill to ten KV ranks; removed the false Dota Innate marker; added spell-block/team guards, Break handling for passives, Q hit impact VFX and verified missing precache entries. Automated regression now covers Dagger projectile, spell block, Phantom Strike facing and passive Break. Live gameplay, VFX/SFX quality and VConsole remain PENDING; no ENGINE_PASS claimed.


### Migration note

The former custom `enfos_pa_fan_of_knives` active was incorrectly assigned to Enfos slot 5 and removed from the five-slot kit. Slot 5 now uses the installed passive `phantom_assassin_immaterial`, and the active native Fan of Knives remains a separate Aghanim-style upgrade candidate. The shared Aghanim manager currently grants role bonuses, so Fan of Knives upgrade wiring is not yet implemented. Source: [Valve Dota 2 Mistwoods](https://www.dota2.com/mistwoods).

2026-09-30 level-cap integration: all five Phantom Assassin abilities now have explicit KV gates. Q/W/E and the Enfos passive use one rank per level; the passive’s free rank 1 remains managed by the separate Enfos grant. Coup de Grace uses levels 5, 10, …, 50 so rank 10 fits the cap. Static KV contract passes; engine level-up buttons, rank grants, ultimate marker and point pacing remain PENDING for owner testing.
