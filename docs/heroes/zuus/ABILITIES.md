# Zeus: ability evidence dossier

Native hero and ability identifiers were checked against the installed Dota ClientVersion 6941 / SourceRevision 11041083 snapshot. This remains a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_zuus`; role: Mage. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_zeus_arc_lightning` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/pve_kits | zuus_arc_lightning |
| 2 | `enfos_zeus_lightning_bolt` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/pve_kits | zuus_lightning_bolt |
| 3 | `enfos_zeus_heavenly_jump` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | zuus_heavenly_jump |
| 4 | `enfos_zeus_thundergods_wrath` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | zuus_thundergods_wrath |
| 5 | `enfos_zeus_static_field` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | zuus_static_field |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_zuus.txt`; status: FILE_VERIFIED; SHA256: `e1a5d9c91fa66a70c233912115244d4ec8c0e388b76770d54a81404c3733a15c`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/zeus/zeus.vmdl` |
| SoundSet | `Hero_zuus` |
| Ability1 | `zuus_arc_lightning` |
| Ability2 | `zuus_lightning_bolt` |
| Ability3 | `zuus_heavenly_jump` |
| Ability4 | `zuus_cloud` |
| Ability5 | `zuus_lightning_hands` |
| Ability6 | `zuus_thundergods_wrath` |
| Ability7 | `zuus_static_field` |
| Ability10 | `special_bonus_unique_zeus` |
| Ability11 | `special_bonus_hp_200` |
| Ability12 | `special_bonus_unique_zeus_4` |
| Ability13 | `special_bonus_unique_zeus_6` |
| Ability14 | `special_bonus_unique_zeus_2` |
| Ability15 | `special_bonus_unique_zeus_3` |
| Ability16 | `special_bonus_unique_zeus_5` |
| Ability17 | `special_bonus_unique_zeus_jump_charges` |
| AttributeStrengthGain | `2.100000` |
| AttributeAgilityGain | `1.200000` |
| AttributeIntelligenceGain | `3.300000` |

### Per-ability review leads

- `enfos_zeus_arc_lightning`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_zeus_lightning_bolt`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_zeus_heavenly_jump`: cast/impact/modifier contract and lifetime.
- `enfos_zeus_thundergods_wrath`: ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_zeus_static_field`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

## Slot 1: `enfos_zeus_arc_lightning`

Classification: PVE-CONVERT
Native counterpart: `zuus_arc_lightning` (installed hero KV Ability1; ClientVersion 6941 / SourceRevision 11041083). Chaining retains Zeus’s signature lightning clear; the base damage and jump count are configurable.
Decision and PvE identity rationale: Native counterpart: `zuus_arc_lightning` (installed hero KV Ability1; ClientVersion 6941 / SourceRevision 11041083). Chaining retains Zeus’s signature lightning clear; the base damage and jump count are configurable.
Expected cast/travel/impact/ongoing/cleanup behavior: Target one enemy, deal magical base plus Intelligence scaling, then arc to configured nearby enemies. Damage remains flat on each jump.
Creep / elite / boss, spell immunity, mitigation and status rules require live verification; boss exception: Static Field cap 500 only.
Each of the five Enfos abilities now has MaxLevel 10; Static Field starts at rank 1 free through the Enfos grant. XP/point pacing for the level-50 progression remains a separate pending decision.
Shard role bonus is Mage spell amplification/mana restoration; ultimate Scepter marker remains on Thundergod’s Wrath. Runtime upgrade behavior pending.

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
| Gameplay | PASS | MOCK_PASS: existing Arc Lightning chain regression covers initial and secondary targets; live engine behavior pending. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Q gate levels 1–10 declared; engine HUD/point behavior remains PENDING. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PASS | EN/TR/RU/zh-CN text regenerated against AbilityValues; actual Dota tooltip rendering pending. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): expanded five abilities to ten ranks; removed the false Innate marker; added spell-absorb/team guards and Break-aware Static Field; moved the boss cap to KV. Regression coverage includes chain damage, boss cap, Break and Lightning Bolt spell block. Live runtime, VFX/SFX and VConsole remain PENDING; no ENGINE_PASS claimed.

2026-09-30 Break metadata correction: Static Field checked `PassivesDisabled()` in Lua, but its KV ability lacked `IsBreakable`, so engine Break might never reach that intended branch. Added the KV flag and an all-hero content contract assertion for Zeus's fifth-slot passive. Engine Break suppression remains PENDING owner testing.

## Slot 2: `enfos_zeus_lightning_bolt`

Classification: PVE-CONVERT
Native counterpart: `zuus_lightning_bolt` (installed hero KV Ability2, same source snapshot). Preserve the targeted single-burst identity; Enfos damage scales with Intelligence.
Decision and PvE identity rationale: Native counterpart: `zuus_lightning_bolt` (installed hero KV Ability2, same source snapshot). Preserve the targeted single-burst identity; Enfos damage scales with Intelligence.
Expected cast/travel/impact/ongoing/cleanup behavior: Target one enemy, then deal magical configured base damage plus 150% Intelligence. The old tooltip claimed a stun that Lua never applied; that claim was removed.
Creep / elite / boss, spell immunity, mitigation and status rules require live verification; boss exception: Static Field cap 500 only.
Each of the five Enfos abilities now has MaxLevel 10; Static Field starts at rank 1 free through the Enfos grant. XP/point pacing for the level-50 progression remains a separate pending decision.
Shard role bonus is Mage spell amplification/mana restoration; ultimate Scepter marker remains on Thundergod’s Wrath. Runtime upgrade behavior pending.

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
| Gameplay | PASS | Static review only; game targeting, native vision, VFX and SFX remain pending. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | W gate levels 1–10 declared; engine HUD/point behavior remains PENDING. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PASS | EN/TR/RU/zh-CN text regenerated against AbilityValues; actual Dota tooltip rendering pending. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): all Zeus Enfos slots now expose ten ranks. Full suite verifies Lua/KV integrity and mock behavior; in-game targeting, VFX/SFX, boss and VConsole acceptance remain PENDING.

## Slot 3: `enfos_zeus_heavenly_jump`

Classification: PVE-CONVERT
Native counterpart: `zuus_heavenly_jump` (installed hero KV Ability3, same source snapshot). This is the E mobility skill; its custom jump, shock and slow remain an active, ranked ability. Valve documents the Shard interaction in [Mistwoods](https://www.dota2.com/mistwoods).
Decision and PvE identity rationale: Native counterpart: `zuus_heavenly_jump` (installed hero KV Ability3, same source snapshot). This is the E mobility skill; its custom jump, shock and slow remain an active, ranked ability. Valve documents the Shard interaction in [Mistwoods](https://www.dota2.com/mistwoods).
Expected cast/travel/impact/ongoing/cleanup behavior: Leap 450 units forward on every cast, including while standing still, gain configured movement speed, damage up to a configured number of nearby enemies, and slow them. Jump values are now read from AbilityValues.
Creep / elite / boss, spell immunity, mitigation and status rules require live verification; boss exception: Static Field cap 500 only.
Each of the five Enfos abilities now has MaxLevel 10; Static Field starts at rank 1 free through the Enfos grant. XP/point pacing for the level-50 progression remains a separate pending decision.
Shard role bonus is Mage spell amplification/mana restoration; ultimate Scepter marker remains on Thundergod’s Wrath. Runtime upgrade behavior pending.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: PENDING.
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: launch/landing rings `zuus_shard_jump_launch_ring.vpcf` and `zuus_shard_jump_landing_ring.vpcf` are present in installed ClientVersion 6941 VPK, attached to the caster origin and explicitly precached; exact scene appearance remains pending.
- Sound events + declaring banks + emission target + loop termination: PENDING.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: PENDING.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated mirrors: PENDING.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PASS | MOCK_PASS: regression verifies 450-unit movement and configured magical damage; in-game displacement, particle, animation and audio remain pending. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | E gate levels 1–10 declared; engine HUD/point behavior remains PENDING. |
| VFX | PENDING | Native launch/landing ring resources were found in the installed VPK and wired into the cast; owner must verify their placement, size, and visibility in Dota. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PASS | EN/TR/RU/zh-CN text regenerated against AbilityValues; actual Dota tooltip rendering pending. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): the E now always moves 450 units forward, including from a stationary cast, and emits the installed launch/landing ring resources. A regression checks stationary movement and both particle calls; VPK lookup and cold-start precache wiring are checked. Dota rendering, SFX, boss and VConsole acceptance remain PENDING.

## Slot 4: `enfos_zeus_thundergods_wrath`

Classification: PVE-CONVERT
Native counterpart: `zuus_thundergods_wrath` (installed hero KV Ability6, same source snapshot). Preserve its battlefield-wide ultimate identity; custom damage scales with Intelligence.
Decision and PvE identity rationale: Native counterpart: `zuus_thundergods_wrath` (installed hero KV Ability6, same source snapshot). Preserve its battlefield-wide ultimate identity; custom damage scales with Intelligence.
Expected cast/travel/impact/ongoing/cleanup behavior: Deal magical damage to all opposing units found across the battlefield; there is currently no boss damage cap. VFX placement and map-wide target scope require engine review.
Creep / elite / boss, spell immunity, mitigation and status rules require live verification; boss exception: Static Field cap 500 only.
Each of the five Enfos abilities now has MaxLevel 10; Static Field starts at rank 1 free through the Enfos grant. XP/point pacing for the level-50 progression remains a separate pending decision.
Shard role bonus is Mage spell amplification/mana restoration; ultimate Scepter marker remains on Thundergod’s Wrath. Runtime upgrade behavior pending.

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
| Gameplay | PASS | Static review only; boss balance and actual global target behavior remain pending. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | R gate levels 5–50 in five-level steps declared; ultimate HUD/point behavior remains PENDING. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PASS | EN/TR/RU/zh-CN text regenerated against AbilityValues; actual Dota tooltip rendering pending. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): all Zeus Enfos slots now expose ten ranks. Full suite verifies Lua/KV integrity and mock behavior; in-game targeting, VFX/SFX, boss and VConsole acceptance remain PENDING.

## Slot 5: `enfos_zeus_static_field`

Classification: PVE-CONVERT
Native counterpart: `zuus_static_field` (installed hero KV Ability7, same source snapshot). This is the Enfos fifth slot, free-ranked by `heroes/innates.lua`; it is separate from Dota Innate metadata. Keep the native spell-hit passive role; cap its escalating PvE damage against bosses.
Decision and PvE identity rationale: Keep the native spell-hit passive role; apply configured current-health damage only to enemies, suppress recursion, and limit each boss trigger to a configured cap. Break disables the Enfos passive.
Expected cast/travel/impact/ongoing/cleanup behavior: When Zeus deals spell damage, deal configured percent of that victim’s current health as separate magical damage; boss bonus is capped by `boss_damage_cap` and the passive does not recursively trigger itself.
Creep / elite / boss, spell immunity, mitigation and status rules require live verification; boss exception: Static Field cap 500 only.
Each of the five Enfos abilities now has MaxLevel 10; Static Field starts at rank 1 free through the Enfos grant. XP/point pacing for the level-50 progression remains a separate pending decision.
Shard role bonus is Mage spell amplification/mana restoration; ultimate Scepter marker remains on Thundergod’s Wrath. Runtime upgrade behavior pending.

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
| Gameplay | PASS | MOCK_PASS: regression verifies 8% current-health damage and 500 boss cap; engine event filters and damage interaction remain pending. |
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
| Localization | PASS | EN/TR/RU/zh-CN text regenerated against AbilityValues; actual Dota tooltip rendering pending. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): all Zeus Enfos slots now expose ten ranks. Full suite verifies Lua/KV integrity and mock behavior; in-game targeting, VFX/SFX, boss and VConsole acceptance remain PENDING.
2026-09-30 level-cap integration: all five Zeus abilities now declare KV rank gates. Q/W/E and the Enfos passive use one rank per level; passive rank 1 remains a separate Enfos grant. Thundergod’s Wrath ranks 1–10 unlock on levels 5, 10, …, 50. Static KV contract passes; actual rank buttons, level-up points, ultimate badge and match-start level 6 remain PENDING for owner testing.

2026-10-02 individual review started: all five current Lua/KV slots read and classified PVE-CONVERT against fresh installed6943 native AbilityDefinitions. Current evidence and remaining native differences are in [the individual ledger](../../audit/ZEUS_INDIVIDUAL_REVIEW_2026-10-02.md). Arc Lightning now captures pre-damage chain centers and avoids deleted-source particle bindings so lethal/deleted intermediate targets do not truncate the chain. Before/after regression covers two deleted targets, third hit, flat damage and source endpoints; full256behavior/0failed checks. SOURCE REVIEW still IN PROGRESS; no engine/VConsole/visual/audio acceptance claimed.
