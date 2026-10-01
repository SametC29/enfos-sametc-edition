# Invoker: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_invoker`; role: Mage. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_invoker_chaos_meteor` | 10 | DOTA_ABILITY_BEHAVIOR_POINT \| DOTA_ABILITY_BEHAVIOR_AOE | abilities/pve_kits | invoker_chaos_meteor |
| 2 | `enfos_invoker_sun_strike` | 10 | DOTA_ABILITY_BEHAVIOR_POINT \| DOTA_ABILITY_BEHAVIOR_AOE | abilities/pve_kits | invoker_sun_strike |
| 3 | `enfos_invoker_deafening_blast` | 10 | DOTA_ABILITY_BEHAVIOR_POINT | abilities/pve_kits | invoker_deafening_blast |
| 4 | `enfos_invoker_emp` | 10 | DOTA_ABILITY_BEHAVIOR_POINT \| DOTA_ABILITY_BEHAVIOR_AOE | abilities/pve_kits | invoker_emp |
| 5 | `enfos_invoker_alacrity` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | invoker_alacrity |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_invoker.txt`; status: FILE_VERIFIED; SHA256: `72046fa3d6f49ce24e6c126ff93983ae859900039799b30895c95df9a8b17229`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/invoker/invoker.vmdl` |
| SoundSet | `Hero_Invoker` |
| Ability1 | `invoker_quas` |
| Ability2 | `invoker_wex` |
| Ability3 | `invoker_exort` |
| Ability4 | `invoker_empty1` |
| Ability5 | `invoker_empty2` |
| Ability6 | `invoker_invoke` |
| Ability7 | `invoker_cold_snap` |
| Ability8 | `invoker_ghost_walk` |
| Ability9 | `invoker_tornado` |
| Ability10 | `invoker_emp` |
| Ability11 | `invoker_alacrity` |
| Ability12 | `invoker_chaos_meteor` |
| Ability13 | `invoker_sun_strike` |
| Ability14 | `invoker_forge_spirit` |
| Ability15 | `invoker_ice_wall` |
| Ability16 | `invoker_deafening_blast` |
| Ability17 | `special_bonus_unique_invoker_ice_wall_dps` |
| Ability18 | `special_bonus_unique_invoker_3` |
| Ability19 | `special_bonus_unique_invoker_5` |
| Ability20 | `special_bonus_unique_invoker_9` |
| Ability21 | `special_bonus_unique_invoker_additional_chaos_meteors` |
| Ability22 | `special_bonus_unique_invoker_forged_spirit_armor_reduction` |
| Ability23 | `special_bonus_unique_invoker_2` |
| Ability24 | `special_bonus_unique_invoker_13` |
| Ability25 | `` |
| AttributeStrengthGain | `2.5` |
| AttributeAgilityGain | `2.0` |
| AttributeIntelligenceGain | `4.0` |

### Per-ability review leads

- `enfos_invoker_chaos_meteor`: world position, travel/impact timing and radius alignment.
- `enfos_invoker_sun_strike`: world position, travel/impact timing and radius alignment.
- `enfos_invoker_deafening_blast`: world position, travel/impact timing and radius alignment.
- `enfos_invoker_emp`: world position, travel/impact timing and radius alignment; ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_invoker_alacrity`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-09-30 level-50 migration: Q/W/E/Enfos passive gates start at level 1 with interval 1; R starts at level 5 with interval 5. Static contract test added; point/HUD and gameplay acceptance remain pending for owner live test.

2026-09-30 follow-up static review: Chaos Meteor previously played its cast and impact sounds together and dealt the impact hit immediately despite the falling-meteor visual. It now applies impact after an explicit 1.3-second delay, snapshots cast damage/radius, applies the 10%-max-health boss impact cap recorded by the dossier, and reads burn duration, tick interval, Intelligence factor and boss per-tick cap from KV. A new mock regression covers delayed impact and both boss caps. The 1.3-second delay is corroborated by the Valve 7.31c update record and current ability references; the installed build's split ability KV was not present in the local VPK source, so exact native-source comparison is recorded PENDING. EN/TR/RU/zh-CN tooltip now reports the warning, damage, burn cadence and caps. Live Dota timing, impact sound/VFX sync, particle CP meaning, precache cold start and balance remain for the owner test.

## Slot 1: `enfos_invoker_chaos_meteor`

Classification: PVE-CONVERT
Native counterpart: `invoker_chaos_meteor (native Ability12)`.
Decision and PvE identity rationale: Keeps meteor arrival and burn identity; rank scales impact/burn and area. Impact and periodic boss damage have explicit health caps.
Expected behavior: Cast shows the falling-meteor warning; after 1.3 seconds it applies area magic damage (boss hit capped at 10% max health) and timed burn. Burn values and per-tick boss cap are data-driven; dead targets end their burn modifier.
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

Change/test record (2026-09-30): ten-rank KV and Lua behavior updated; static and mock checks run. Engine playtest remains pending.

Change/test record (2026-09-30): Invoker’s five Enfos skill definitions now expose Lua-read values through named `AbilityValues` keys, preserving their ten-rank value curves. Static content contract added. Runtime gameplay, VFX, SFX, target/impact timing, cleanup, boss interaction and upgrade testing remain pending for the user’s live test.

### Delay behavior repair — 2026-09-30

Static review found `delay` values on Sun Strike (1.5 seconds) and EMP (2.5 seconds) with no Lua lookup; both effects applied immediately. The configured delays now schedule their impact through the game-mode context think. Sun Strike keeps its warning effect and defers impact sound/pure damage; EMP keeps its charge effect and defers discharge sound, damage, mana burn, and mana return. Damage/radius/mana values are snapshotted on cast, while eligible units are found at impact. Regression tests assert no early damage or mana drain and then verify the delayed result. Updated EN/TR/RU/zh-CN descriptions communicate the warnings. Static and mock checks pass; visual/audio timing and live engine cleanup remain PENDING.

## Slot 2: `enfos_invoker_sun_strike`

Classification: PVE-CONVERT
Native counterpart: `invoker_sun_strike (native Ability13)`.
Decision and PvE identity rationale: Keeps global precision strike identity; rank scales pure damage/area while boss burst is capped.
Expected behavior: Point-target cast plays its warning, then after the configured 1.5-second delay deals area pure damage at the stored target point. Damage is snapshotted at cast time and boss burst remains capped.
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

Change/test record (2026-09-30): ten-rank KV and Lua behavior updated; static and mock checks run. Engine playtest remains pending.

## Slot 3: `enfos_invoker_deafening_blast`

Classification: PVE-CONVERT
Native counterpart: `invoker_deafening_blast (native Ability16)`.
Decision and PvE identity rationale: Keeps directional damage/disarm identity; rank scales damage/control, with shortened boss disarm.
Expected behavior: Directional impact applies magic damage and disarm around the wave path; engine geometry needs in-game check.
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

Change/test record (2026-09-30): ten-rank KV and Lua behavior updated; static and mock checks run. Engine playtest remains pending.

## Slot 4: `enfos_invoker_emp`

Classification: PVE-CONVERT
Native counterpart: `invoker_emp (native Ability10)`.
Decision and PvE identity rationale: Keeps area EMP damage and mana denial; mana burn now drives capped mana return, boss pure damage capped.
Expected behavior: Point-target cast plays the EMP warning, then after the configured 2.5-second delay discharges for pure area damage and mana burn; returned mana is capped at one `mana_burn` amount.
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

Change/test record (2026-09-30): ten-rank KV and Lua behavior updated; static and mock checks run. Engine playtest remains pending.

## Slot 5: `enfos_invoker_alacrity`

Classification: TUNE
Native counterpart: `invoker_alacrity (native Ability11 active; custom Enfos passive remains separate from native Innate)`.
Decision and PvE identity rationale: Uses the familiar attack-speed/damage bonus identity as a five-slot passive; rank scales stats and Break/illusion rules are explicit.
Expected behavior: Intrinsic attack speed and attack-damage bonus; suppressed by Break and on illusions.
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

Change/test record (2026-09-30): ten-rank KV and Lua behavior updated; static and mock checks run. Engine playtest remains pending.

2026-09-30 global Break metadata audit: Added KV `IsBreakable 1` to `enfos_invoker_alacrity` because its linked Lua passive implementation check `PassivesDisabled()`. Automated content validation now rejects this metadata mismatch. Actual Dota Break behavior remains PENDING.
