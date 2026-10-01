# Terrorblade: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_terrorblade`; role: Carry. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_tb_reflection` | 10 | DOTA_ABILITY_BEHAVIOR_POINT \| DOTA_ABILITY_BEHAVIOR_AOE | abilities/pve_kits | terrorblade_reflection |
| 2 | `enfos_tb_conjure_image` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | terrorblade_conjure_image |
| 3 | `enfos_tb_metamorphosis` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | terrorblade_metamorphosis |
| 4 | `enfos_tb_sunder` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/pve_kits | terrorblade_sunder |
| 5 | `enfos_tb_demon_zeal` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | terrorblade_terror_wave |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_terrorblade.txt`; status: FILE_VERIFIED; SHA256: `4b597ba8251d4eed9cb1a3170e21e5708faec0a5018964010b384f99732343d5`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/terrorblade/terrorblade.vmdl` |
| SoundSet | `Hero_Terrorblade` |
| Ability1 | `terrorblade_reflection` |
| Ability2 | `terrorblade_conjure_image` |
| Ability3 | `terrorblade_metamorphosis` |
| Ability4 | `terrorblade_demon_zeal` |
| Ability5 | `terrorblade_terror_wave` |
| Ability6 | `terrorblade_sunder` |
| Ability7 | `terrorblade_dark_unity` |
| Ability10 | `special_bonus_unique_terrorblade_2` |
| Ability11 | `special_bonus_unique_terrorblade_4` |
| Ability12 | `special_bonus_unique_terrorblade_metamorphosis_cooldown` |
| Ability13 | `special_bonus_unique_terrorblade_sunder_hp_threshold` |
| Ability14 | `special_bonus_all_stats_10` |
| Ability15 | `special_bonus_unique_terrorblade_5` |
| Ability16 | `special_bonus_unique_terrorblade` |
| Ability17 | `special_bonus_unique_terrorblade_3` |
| AttributeStrengthGain | `2.0` |
| AttributeAgilityGain | `4.000000` |
| AttributeIntelligenceGain | `1.60000` |

### Per-ability review leads

- `enfos_tb_reflection`: world position, travel/impact timing and radius alignment.
- `enfos_tb_conjure_image`: cast/impact/modifier contract and lifetime.
- `enfos_tb_metamorphosis`: cast/impact/modifier contract and lifetime.
- `enfos_tb_sunder`: target flags, immunity, spell block/reflect if applicable, target loss; ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_tb_demon_zeal`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-09-30 level-50 migration: Q/W/E/Enfos passive gates start at level 1 with interval 1; R starts at level 5 with interval 5. Static contract test added; point/HUD and gameplay acceptance remain pending for owner live test.

2026-09-30 static special-value repair: migrated all five Terrorblade abilities to named `AbilityValues`, preserving the existing ten-rank scalar/curve data, and added a five-slot schema contract. Native skill identities and Scepter/Shards remain as recorded; this schema fix does not validate illusion behavior, Sunder caps, VFX, audio or metamorphosis form in Dota. The user owns those live tests.

## Slot 1: `enfos_tb_reflection`

Classification: PVE-CONVERT
Native counterpart: `terrorblade_reflection (installed source Ability1)`.
Decision and PvE identity rationale: Keeps Reflection slow identity and adds ranked periodic physical damage, with boss duration, slow and per-tick damage capped.
Expected behavior: World-position area cast applies timed slow and damage, then cleans up on expiry or death.
Rank target: 10 total ranks per Enfos slot within hero level 50. Skill-point/unlock curve is a separate system acceptance item.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PASS | Mock regression coverage in tests/hero_kit_regressions.lua and ten-rank KV smoke; not ENGINE_PASS. |
| Targeting | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Ranks | PASS | Mock regression coverage in tests/hero_kit_regressions.lua and ten-rank KV smoke; not ENGINE_PASS. |
| VFX | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| SFX | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Animation | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Modifiers | PASS | Mock regression coverage in tests/hero_kit_regressions.lua and ten-rank KV smoke; not ENGINE_PASS. |
| Precache | PASS | Particle paths found in installed Valve VPK and registered in addon precache; cold-start engine test pending. |
| Cleanup | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Boss | PASS | Mock regression coverage in tests/hero_kit_regressions.lua and ten-rank KV smoke; not ENGINE_PASS. |
| Upgrades | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Localization | PASS | Turkish source mirrored to EN/TR/RU/zh-CN; consistency check passed. |
| Performance | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Reconnect | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| VConsole | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |

Change/test record (2026-09-30): rank 1-10 KV and Lua behavior updated; mock and static checks run. Engine playtest remains pending.

## Slot 2: `enfos_tb_conjure_image`

Classification: PVE-CONVERT
Native counterpart: `terrorblade_conjure_image (installed source Ability2)`.
Decision and PvE identity rationale: Keeps Conjure Image identity through bounded summon service; ranks scale count, lifetime, outgoing damage and attack echo.
Expected behavior: No-target cast creates bounded illusions and temporary attack buff; shared service owns summon cleanup.
Rank target: 10 total ranks per Enfos slot within hero level 50. Skill-point/unlock curve is a separate system acceptance item.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PASS | Mock regression coverage in tests/hero_kit_regressions.lua and ten-rank KV smoke; not ENGINE_PASS. |
| Targeting | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Ranks | PASS | Mock regression coverage in tests/hero_kit_regressions.lua and ten-rank KV smoke; not ENGINE_PASS. |
| VFX | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| SFX | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Animation | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Modifiers | PASS | Mock regression coverage in tests/hero_kit_regressions.lua and ten-rank KV smoke; not ENGINE_PASS. |
| Precache | PASS | Particle paths found in installed Valve VPK and registered in addon precache; cold-start engine test pending. |
| Cleanup | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Boss | PASS | Mock regression coverage in tests/hero_kit_regressions.lua and ten-rank KV smoke; not ENGINE_PASS. |
| Upgrades | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Localization | PASS | Turkish source mirrored to EN/TR/RU/zh-CN; consistency check passed. |
| Performance | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Reconnect | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| VConsole | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |

Change/test record (2026-09-30): rank 1-10 KV and Lua behavior updated; mock and static checks run. Engine playtest remains pending.

## Slot 3: `enfos_tb_metamorphosis`

Classification: PVE-CONVERT
Native counterpart: `terrorblade_metamorphosis (installed source Ability3)`.
Decision and PvE identity rationale: Keeps ranged transformation identity; ranks scale duration, range and damage with agility scaling.
Expected behavior: Timed transformation grants ranged capability/projectile and ranked bonuses; modifier end restores melee capability.
Rank target: 10 total ranks per Enfos slot within hero level 50. Skill-point/unlock curve is a separate system acceptance item.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PASS | Mock regression coverage in tests/hero_kit_regressions.lua and ten-rank KV smoke; not ENGINE_PASS. |
| Targeting | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Ranks | PASS | Mock regression coverage in tests/hero_kit_regressions.lua and ten-rank KV smoke; not ENGINE_PASS. |
| VFX | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| SFX | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Animation | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Modifiers | PASS | Mock regression coverage in tests/hero_kit_regressions.lua and ten-rank KV smoke; not ENGINE_PASS. |
| Precache | PASS | Particle paths found in installed Valve VPK and registered in addon precache; cold-start engine test pending. |
| Cleanup | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Boss | PASS | Mock regression coverage in tests/hero_kit_regressions.lua and ten-rank KV smoke; not ENGINE_PASS. |
| Upgrades | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Localization | PASS | Turkish source mirrored to EN/TR/RU/zh-CN; consistency check passed. |
| Performance | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Reconnect | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| VConsole | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |

Change/test record (2026-09-30): rank 1-10 KV and Lua behavior updated; mock and static checks run. Engine playtest remains pending.

## Slot 4: `enfos_tb_sunder`

Classification: PVE-CONVERT
Native counterpart: `terrorblade_sunder (installed source Ability6)`.
Decision and PvE identity rationale: Keeps Sunder as focused finisher; Enfos version heals Terrorblade and deals equal pure damage, capped by boss max health percentage.
Expected behavior: Enemy unit target respects spell block; heal uses base plus agility; boss pure damage is capped.
Rank target: 10 total ranks per Enfos slot within hero level 50. Skill-point/unlock curve is a separate system acceptance item.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PASS | Mock regression coverage in tests/hero_kit_regressions.lua and ten-rank KV smoke; not ENGINE_PASS. |
| Targeting | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Ranks | PASS | Mock regression coverage in tests/hero_kit_regressions.lua and ten-rank KV smoke; not ENGINE_PASS. |
| VFX | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| SFX | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Animation | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Modifiers | PASS | Mock regression coverage in tests/hero_kit_regressions.lua and ten-rank KV smoke; not ENGINE_PASS. |
| Precache | PASS | Particle paths found in installed Valve VPK and registered in addon precache; cold-start engine test pending. |
| Cleanup | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Boss | PASS | Mock regression coverage in tests/hero_kit_regressions.lua and ten-rank KV smoke; not ENGINE_PASS. |
| Upgrades | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Localization | PASS | Turkish source mirrored to EN/TR/RU/zh-CN; consistency check passed. |
| Performance | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Reconnect | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| VConsole | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |

Change/test record (2026-09-30): rank 1-10 KV and Lua behavior updated; mock and static checks run. Engine playtest remains pending.

## Slot 5: `enfos_tb_demon_zeal`

Classification: TUNE
Native counterpart: `terrorblade_demon_zeal (installed source Ability4)`.
Decision and PvE identity rationale: Uses native attack/mobility passive identity for fifth Enfos passive; separate from Dota Innate metadata.
Expected behavior: Ranked attack/movement speed passive; Break disables it and illusions do not receive it.
Rank target: 10 total ranks per Enfos slot within hero level 50. Skill-point/unlock curve is a separate system acceptance item.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PASS | Mock regression coverage in tests/hero_kit_regressions.lua and ten-rank KV smoke; not ENGINE_PASS. |
| Targeting | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Ranks | PASS | Mock regression coverage in tests/hero_kit_regressions.lua and ten-rank KV smoke; not ENGINE_PASS. |
| VFX | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| SFX | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Animation | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Modifiers | PASS | Mock regression coverage in tests/hero_kit_regressions.lua and ten-rank KV smoke; not ENGINE_PASS. |
| Precache | PASS | Particle paths found in installed Valve VPK and registered in addon precache; cold-start engine test pending. |
| Cleanup | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Boss | PASS | Mock regression coverage in tests/hero_kit_regressions.lua and ten-rank KV smoke; not ENGINE_PASS. |
| Upgrades | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Localization | PASS | Turkish source mirrored to EN/TR/RU/zh-CN; consistency check passed. |
| Performance | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Reconnect | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| VConsole | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |

Change/test record (2026-09-30): rank 1-10 KV and Lua behavior updated; mock and static checks run. Engine playtest remains pending.

2026-09-30 global Break metadata audit: Added KV `IsBreakable 1` to `enfos_tb_demon_zeal` because its linked Lua passive implementation check `PassivesDisabled()`. Automated content validation now rejects this metadata mismatch. Actual Dota Break behavior remains PENDING.
