# Lina: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_lina`; role: Mage. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_lina_dragon_slave` | 10 | DOTA_ABILITY_BEHAVIOR_POINT | abilities/pve_kits | lina_dragon_slave |
| 2 | `enfos_lina_light_strike_array` | 10 | DOTA_ABILITY_BEHAVIOR_POINT \| DOTA_ABILITY_BEHAVIOR_AOE | abilities/pve_kits | lina_light_strike_array |
| 3 | `enfos_lina_fiery_soul` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | lina_fiery_soul |
| 4 | `enfos_lina_laguna_blade` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/pve_kits | lina_laguna_blade |
| 5 | `enfos_lina_combustion` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | lina_flame_cloak |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_lina.txt`; status: FILE_VERIFIED; SHA256: `f360660bedce58d9561e0bd92422b1ecef48ba9b9a5c152793f3670b9430c504`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/lina/lina.vmdl` |
| SoundSet | `Hero_Lina` |
| Ability1 | `lina_dragon_slave` |
| Ability2 | `lina_light_strike_array` |
| Ability3 | `lina_fiery_soul` |
| Ability4 | `lina_flame_cloak` |
| Ability5 | `lina_slow_burn` |
| Ability6 | `lina_laguna_blade` |
| Ability10 | `special_bonus_attack_damage_25` |
| Ability11 | `special_bonus_unique_lina_1` |
| Ability12 | `special_bonus_unique_lina_4` |
| Ability13 | `special_bonus_unique_lina_3` |
| Ability14 | `special_bonus_unique_lina_6` |
| Ability15 | `special_bonus_unique_lina_2` |
| Ability16 | `special_bonus_unique_lina_7` |
| Ability17 | `special_bonus_unique_lina_crit_debuff` |
| AttributeStrengthGain | `2.400000` |
| AttributeAgilityGain | `2.400000` |
| AttributeIntelligenceGain | `4.000000` |

### Per-ability review leads

- `enfos_lina_dragon_slave`: world position, travel/impact timing and radius alignment.
- `enfos_lina_light_strike_array`: world position, travel/impact timing and radius alignment.
- `enfos_lina_fiery_soul`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `enfos_lina_laguna_blade`: target flags, immunity, spell block/reflect if applicable, target loss; ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_lina_combustion`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

### Lina pilot repair and rank migration — 2026-09-30

Native identity was checked against the installed ClientVersion 6941 Lina KV
snapshot above. Q/W/E/R retain Dragon Slave, Light Strike Array, Fiery Soul
and Laguna Blade roles; the Enfos fifth slot remains the project passive
`enfos_lina_combustion`. Dota Ability5 `lina_slow_burn`, Ability4
`lina_flame_cloak` and the separately defined native `lina_combustion` are not
silently substituted for that slot. The custom passive no longer has the
`Innate` marker.

All five Enfos slots now declare MaxLevel 10 with ten-value curves for their
ranked values. This is the requested content migration only: match XP,
level-to-rank unlocks, free passive rank, and point distribution still require
their own explicit level-50 progression implementation and runtime acceptance.
The curves extend the existing Enfos endpoints; this is not a full balance
certification.

The mock-backed repairs cover: Dragon Slave's zero-cursor forward fallback,
KV projectile speed, and live enemy checks; Light Strike Array's 0.5-second
impact delay and 35% boss stun; Fiery Soul stack properties turning off under
Break; safe Laguna target handling before spell-block/impact; and Combustion's
KV-driven Intelligence burn contribution plus Break handling. Combustion
`burn_int_pct` is now explicitly 30. Descriptions were corrected/translated
for the damage scalings and Light Strike Array warning delay in EN/TR/RU/zh-CN.

Native source KV confirms Q `Hero_Lina.DragonSlave`, W
`Ability.LightStrikeArray`, R `Ability.LagunaBladeImpact`, their native cast
animations and targeting metadata. The installed VPK contains the Lina
Dragon Slave, Light Strike Array, Fiery Soul and Laguna Blade particle assets;
addon precache calls exist for those effects. Asset presence and a Lua/mock
pass do not prove correct control points, attachment, visible rendering,
audibility, or effect timing in the game client. Therefore VFX, SFX, animation,
precache cold-start, cleanup, boss edge cases and VConsole are still
ENGINE_PENDING. Automated checks passed 200 ability and 212 modifier mock
smokes; they are not a Dota playtest.

### Pilot review and special-value schema repair — 2026-09-29

The installed ClientVersion 6941 source snapshot identifies Lina's native
Q/W/E/R counterparts as `lina_dragon_slave`, `lina_light_strike_array`,
`lina_fiery_soul`, and `lina_laguna_blade`. The current Enfos behavior retains
those recognizable jobs while adding the documented PvE burn/area/boss rules;
the four abilities are classified PVE-CONVERT for this pilot. `enfos_lina_combustion`
remains UNASSESSED because its fifth-slot role must be compared with the
installed `lina_slow_burn` and `lina_flame_cloak` definitions; the icon does not
establish its native counterpart.

All five Lina ability definitions stored Lua-read values in legacy numbered
`AbilitySpecial` rows. They now use named `AbilityValues`; the existing numbers,
cooldowns, mana costs, explicit MaxLevel values and Lua behavior are unchanged.
The expanded roster audit follows values read by linked modifier classes;
after the Lina, Wraith King, Juggernaut and Drow pilot migrations it reports
157 of 200 abilities still using legacy-only rows. Earlier quick-scan counts
missed modifier reads.
Static checks and mock execution pass, but Lina's values, gameplay, visuals,
audio, animation and modifier lifecycle still need live ClientVersion 6941
verification. This does not implement the separate level-50 / ten-rank
migration.

## Slot 1: `enfos_lina_dragon_slave`

Classification: PVE-CONVERT
Native counterpart: `lina_dragon_slave` (installed ClientVersion 6941 source snapshot).
Decision and PvE identity rationale: Keep the forward-traveling fire wave and its multi-target damage; the Enfos combustion passive adds a separate PvE burn interaction.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Q ranks 1–10 are KV-gated at hero levels 1–10. Point cost and actual unlock behavior remain PENDING in-engine validation.
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
| Ranks | PENDING | Q rank gates are declared for levels 1–10; HUD display and point spending remain PENDING engine verification. |
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

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 2: `enfos_lina_light_strike_array`

Classification: PVE-CONVERT
Native counterpart: `lina_light_strike_array` (installed ClientVersion 6941 source snapshot).
Decision and PvE identity rationale: Keep the point-targeted delayed AoE stun and damage; reduce boss stun duration to limit control lock.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: W ranks 1–10 are KV-gated at hero levels 1–10. Point cost and actual unlock behavior remain PENDING in-engine validation.
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
| Ranks | PENDING | W rank gates are declared for levels 1–10; HUD display and point spending remain PENDING engine verification. |
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

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 3: `enfos_lina_fiery_soul`

Classification: PVE-CONVERT
Native counterpart: `lina_fiery_soul` (installed ClientVersion 6941 source snapshot).
Decision and PvE identity rationale: Keep the stacking cast/attack tempo buff and tune it for repeated wave combat.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: E ranks 1–10 are KV-gated at hero levels 1–10. Point cost and actual unlock behavior remain PENDING in-engine validation.
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
| Ranks | PENDING | E rank gates are declared for levels 1–10; HUD display and point spending remain PENDING engine verification. |
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

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 4: `enfos_lina_laguna_blade`

Classification: PVE-CONVERT
Native counterpart: `lina_laguna_blade` (installed ClientVersion 6941 source snapshot).
Decision and PvE identity rationale: Keep the single-target ultimate strike; add surrounding damage so the finisher contributes against waves.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: R ranks 1–10 are KV-gated at levels 5, 10, …, 50. Point cost and actual unlock behavior remain PENDING in-engine validation.
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
| Ranks | PENDING | Laguna Blade ranks are declared for levels 5–50 in five-level steps; ultimate HUD display and point spending remain PENDING engine verification. |
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

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 5: `enfos_lina_combustion`

Classification: PVE-CONVERT
Native counterpart: This stable ID is an Enfos-only fifth-slot passive; native `lina_slow_burn` and `lina_flame_cloak` remain separate Dota abilities and are not silently mapped by icon. The passive adds bounded PvE burn-on-spell and death explosion effects around Lina's fire identity.
Decision and PvE identity rationale: Retain the project's custom Combustion passive as the separately granted Enfos passive. Ensure death explosions only trigger from this Lina's own burn on an enemy, and keep the burn self-recursion excluded.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: The Enfos passive rank 1 is granted separately; ranks 2–10 are KV-gated at hero levels 2–10. Point cost and actual unlock behavior remain PENDING in-engine validation.
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
| Ranks | PENDING | The Enfos passive rank 1 is granted separately; ranks 2–10 are declared for levels 2–10; HUD and point behavior remain PENDING engine verification. |
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

Change/test record (2026-09-29): made combustion burn scaling, corpse explosion base/%/cap/radius and Lina's Fiery Soul attack proc/spell-amplification values KV-driven. Q now uses the passive's configured burn duration. Corpse explosion now requires this Lina's own burn on an enemy, preventing allied deaths and other Lina's burns from triggering it. Regression covers own burn, boss cap and cross-caster ownership. Dota/VConsole interaction, visual/audio assets and runtime death edge cases remain PENDING.

2026-09-30 level-cap integration: all five Lina abilities now declare KV rank gates. Q/W/E and the Enfos passive use one rank per level; passive rank 1 remains a separate Enfos grant. Laguna Blade ranks 1–10 unlock at levels 5, 10, …, 50. Static KV contract passes; actual rank buttons, level-up points, ultimate badge and match-start level 6 remain PENDING for owner testing.

2026-09-30 follow-up audit: Fiery Soul cast procs and Combustion spell
amplification, burn application and corpse detonation now explicitly suppress
illusion owners, matching the existing attack-proc guard. Dragon Slave also
does not add its passive burn when cast by an illusion. A regression covers
Combustion illusion suppression; Dota's actual illusion/passive behavior remains
pending in-engine verification.
