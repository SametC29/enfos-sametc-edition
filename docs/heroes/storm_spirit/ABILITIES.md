# Storm Spirit: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_storm_spirit`; role: Mage. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_storm_static_remnant` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | NOT_EXPLICIT | storm_spirit_static_remnant |
| 2 | `enfos_storm_electric_vortex` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | NOT_EXPLICIT | storm_spirit_electric_vortex |
| 3 | `enfos_storm_overload` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/heroes/storm_spirit/e | storm_spirit_overload |
| 4 | `enfos_storm_ball_lightning` | 10 | DOTA_ABILITY_BEHAVIOR_POINT | abilities/pve_kits | storm_spirit_ball_lightning |
| 5 | `enfos_storm_galvanic_core` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | storm_spirit_overload |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [abilities/heroes/storm_spirit/e](../../../game/scripts/vscripts/abilities/heroes/storm_spirit/e.lua), [abilities/pve_kits](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_storm_spirit.txt`; status: FILE_VERIFIED; SHA256: `02996ee5b413c86b193d109253e723ed3dabe87cbbe5002362f863b1b02c823c`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/storm_spirit/storm_spirit.vmdl` |
| SoundSet | `Hero_StormSpirit` |
| Ability1 | `storm_spirit_static_remnant` |
| Ability2 | `storm_spirit_electric_vortex` |
| Ability3 | `storm_spirit_overload` |
| Ability4 | `generic_hidden` |
| Ability5 | `generic_hidden` |
| Ability6 | `storm_spirit_ball_lightning` |
| Ability7 | `storm_spirit_galvanized` |
| Ability10 | `special_bonus_unique_storm_spirit_overload_aspd` |
| Ability11 | `special_bonus_mp_regen_150` |
| Ability12 | `special_bonus_hp_250` |
| Ability13 | `special_bonus_unique_storm_spirit_5` |
| Ability14 | `special_bonus_unique_storm_spirit` |
| Ability15 | `special_bonus_unique_storm_spirit_8` |
| Ability16 | `special_bonus_unique_storm_spirit_7` |
| Ability17 | `special_bonus_unique_storm_spirit_4` |
| AttributeStrengthGain | `2.000000` |
| AttributeAgilityGain | `2.600000` |
| AttributeIntelligenceGain | `3.7` |

### Per-ability review leads

- `enfos_storm_static_remnant`: cast/impact/modifier contract and lifetime.
- `enfos_storm_electric_vortex`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_storm_overload`: intrinsic modifier, Break/illusion behavior, live rank refresh; static unreferenced-special candidates: overload_aoe (not confirmed defects).
- `enfos_storm_ball_lightning`: world position, travel/impact timing and radius alignment; ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_storm_galvanic_core`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-10-04 native-first discovery supersedes the historical classification
as a migration target only; production is still the old five-slot Lua kit.
Fresh build6943/revision11069754 has the same native hero hash shown above.
See [pre-mutation matrix and source findings](../../audit/STORM_SPIRIT_NATIVE_FIRST_REVIEW_2026-10-04.md)
and [fresh native snapshot](../../audit/STORM_SPIRIT_NATIVE_SOURCE_2026-10-04.json).
All five slots are TUNE targets: Q/E native with only an evidenced INT bridge
if needed, W/R native aliases, D native Galvanized plus separate paid stats.
Existing W never pulls; R uses teleport/arrival-only damage; Q shares trigger
and damage radius; E copies charges and misses killing-hit discharge.
W Scepter/E Shard ownership, linked identities, Q targeting, R damage/mana
read paths and innate creep credit remain open. SOURCE_IMPLEMENTATION PENDING;
OWNER_RUNTIME PENDING. Historical mock PASS rows below are not acceptance
of this proposed native kit. No production change in this discovery unit.

2026-09-30 level-50 migration: Q/W/E/Enfos passive gates start at level 1 with interval 1; R starts at level 5 with interval 5. Static contract test added; point/HUD and gameplay acceptance remain pending for owner live test.

2026-09-30 follow-up static review: verified all five Lua callbacks against the dossier's installed native identity map, named KV values, tests, localization, and existing particle precache. Confirmed two defects: Electric Vortex's tooltip promised a pull that its code never performs, and Overload cleared its charged proc before rejecting allied/invalid targets. Overload now preserves the charge on those attacks; a regression covers ally attack then enemy proc. Turkish, English, Russian and Simplified Chinese Vortex/Overload tooltips now describe the actual AoE stun and charged AoE attack; Static Remnant's trigger radius now displays the ranked value instead of a fixed 300. These fixes correct code/tooltip alignment, not ENGINE_PASS. Existing five ability mock tests pass; all six Storm particle paths have local Valve VPK validation and are registered in addon precache. Visual display, particle CPs, sound bank/event validity and audibility, form/animation, real mana/cooldown, boss balance and VConsole remain pending the owner's Dota test. Ball Lightning's engine base mana cost plus its Lua distance cost also remains an in-game acceptance check.

## Slot 1: `enfos_storm_static_remnant`

Classification: TUNE
Native counterpart: `storm_spirit_static_remnant (native Ability1)`.
Decision and PvE identity rationale: Native remnant owns placement/walking/arming/detonation/vision/expiry; minimal raw INT damage bridge preserves ENFOS scaling without another thinker.
Expected behavior: Native chosen-point walking/self-cast remnant, .75 arming delay, trigger235 and damage radius240..330; damage100..390 + INT1.2, lifetime8..12. Actual targeting/cache/cleanup remains owner-pending.
Rank target: 10 total ranks per Enfos slot within hero level 50. Skill-point/unlock curve is a separate system acceptance item.

2026-10-04 native Q source: [implementation and evidence](../../audit/STORM_SPIRIT_NATIVE_FIRST_REVIEW_2026-10-04.md). 121 affected checks/315 hero mocks PASS. Pure native alias, no ScriptFile/wrapper; previous Lua thinker/test retired. Full structural restart required before owner testing.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Native alias/raw scaling source checked; actual targeting, rank/cache and engine effects remain owner-pending. |
| Targeting | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Ranks | PENDING | Native alias/raw scaling source checked; actual targeting, rank/cache and engine effects remain owner-pending. |
| VFX | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| SFX | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Animation | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Modifiers | PENDING | Native alias/raw scaling source checked; actual targeting, rank/cache and engine effects remain owner-pending. |
| Precache | PASS | Particle paths found in installed Valve VPK and registered in addon precache; cold-start engine test pending. |
| Cleanup | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Boss | PENDING | Native alias/raw scaling source checked; actual targeting, rank/cache and engine effects remain owner-pending. |
| Upgrades | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Localization | PASS | Turkish source mirrored to EN/TR/RU/zh-CN; consistency check passed. |
| Performance | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Reconnect | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| VConsole | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |

Change/test record (2026-09-30): ten-rank KV and Lua behavior updated; static and mock checks run. Engine playtest remains pending.

Change/test record (2026-09-30): the five Storm Spirit skill KV blocks now expose their Lua-read values through named `AbilityValues` keys instead of numeric `AbilitySpecial` rows; original ten-rank curves were preserved. `tools/tests/content_contracts.test.mjs` locks this mapping. Automated static and mock checks pass; in-game gameplay, targeting, VFX, SFX, cleanup, boss, and upgrade behavior remain pending for the user’s live test.

## Slot 2: `enfos_storm_electric_vortex`

Classification: TUNE
Native counterpart: `storm_spirit_electric_vortex (native Ability2)`.
Decision and PvE identity rationale: Pure native Electric Vortex restores pull, native target rules and Scepter AoE; authored ten-rank duration/CD/cost/range retained. Copied AoE stun and Boss-specific duration retired.
Expected behavior: Pull target toward Storm with duration0.8..2.6 and pull distance180..300; native Scepter changes targeting to radius475 around Storm. Actual pull, dispel/status resistance, block/reflect and Overload charge remain owner-pending.
Rank target: 10 total ranks per Enfos slot within hero level 50. Skill-point/unlock curve is a separate system acceptance item.

2026-10-04 native W source: [implementation and remaining gates](../../audit/STORM_SPIRIT_NATIVE_FIRST_REVIEW_2026-10-04.md). 125 affected checks/314 mocks PASS. Pure native alias has no ScriptFile or empty wrapper. Full structural restart required before owner testing.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Native alias source covered; actual pull/target/rank/lifecycle remains owner-pending. |
| Targeting | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Ranks | PENDING | Native alias source covered; actual pull/target/rank/lifecycle remains owner-pending. |
| VFX | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| SFX | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Animation | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Modifiers | PENDING | Native alias source covered; actual pull/target/rank/lifecycle remains owner-pending. |
| Precache | PASS | Particle paths found in installed Valve VPK and registered in addon precache; cold-start engine test pending. |
| Cleanup | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Boss | PENDING | Native alias source covered; actual pull/target/rank/lifecycle remains owner-pending. |
| Upgrades | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Localization | PASS | Turkish source mirrored to EN/TR/RU/zh-CN; consistency check passed. |
| Performance | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Reconnect | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| VConsole | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |

Change/test record (2026-09-30): ten-rank KV and Lua behavior updated; static and mock checks run. Engine playtest remains pending.

## Slot 3: `enfos_storm_overload`

Classification: TUNE
Native counterpart: `storm_spirit_overload (native Ability3)`.
Decision and PvE identity rationale: Exact native provider owns charging, discharge, slows and Shard; minimal raw ten-rank damage/radius/INT bridge preserves paid scaling. The old five-second charge/damage/slow copy is retired.
Expected behavior: Native spell-charged attack; damage25..190 + INT0.6 and radius220..360; native movement80%/attack90 slow for0.8 seconds; native Shard activation forwarded by paid E. Actual linked casts, cache, Break/illusion and Shard behavior are OWNER_RUNTIME PENDING.
Rank target: 10 total ranks per Enfos slot within hero level 50. Skill-point/unlock curve is a separate system acceptance item.

2026-10-04 source update: [E implementation and remaining engine gates](../../audit/STORM_SPIRIT_NATIVE_FIRST_REVIEW_2026-10-04.md).
117 affected checks/316 hero mocks PASS. SOURCE_IMPLEMENTATION implemented;
all actual gameplay/ranks/modifiers/Boss/visual/audio/cleanup/upgrades/reconnect
acceptance is PENDING. Historical PASS rows below describe earlier mocks only,
not the native provider. Exact provider rank0/1 consumes no points and does not
refresh charges during restore. Shared client bootstrap now registers19 classes.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Native E implementation and raw bridge covered by focused fixtures; actual charging/damage needs Dota. |
| Targeting | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Ranks | PENDING | Paid ten-rank KV/raw queries checked; native cache/rank-up/HUD/points need Dota. |
| VFX | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| SFX | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Animation | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Modifiers | PENDING | Shared client registration/idempotent restore covered; actual native intrinsic/charges remain unverified. |
| Precache | PASS | Particle paths found in installed Valve VPK and registered in addon precache; cold-start engine test pending. |
| Cleanup | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Boss | PENDING | Ordinary native target rules; no skill-specific Boss compensation. Actual effect needs Dota. |
| Upgrades | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Localization | PASS | Native E description/Shard metadata updated in four locales and twelve mirrors; source checks pass. |
| Performance | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| Reconnect | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |
| VConsole | PENDING | Live Dota/VConsole verification has not been performed; static and mock checks do not certify engine behavior. |

Change/test record (2026-09-30): ten-rank KV and Lua behavior updated; static and mock checks run. Engine playtest remains pending.

## Slot 4: `enfos_storm_ball_lightning`

Classification: PVE-CONVERT
Native counterpart: `storm_spirit_ball_lightning (native Ability6)`.
Decision and PvE identity rationale: Keeps point-target mobility ultimate; rank improves maximum travel and mana efficiency; damage scales with distance and bosses are capped.
Expected behavior: Clamp travel to rank range, charge distance-based mana, move to landing point, then damage nearby enemies.
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

## Slot 5: `enfos_storm_galvanic_core`

Classification: TUNE
Native counterpart: `storm_spirit_galvanized is the native innate counterpart (native Ability7); not the Enfos passive slot mapping.`.
Decision and PvE identity rationale: Uses Enfos-specific mana/intellect passive as a separate fifth slot; rank scales both stats and respects Break/illusion rules.
Expected behavior: Intrinsic mana regeneration and intellect bonus, disabled under Break and on illusions.
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

2026-09-30 global Break metadata audit: Added KV `IsBreakable 1` to `enfos_storm_overload`, `enfos_storm_galvanic_core` because its linked Lua passive implementation check `PassivesDisabled()`. Automated content validation now rejects this metadata mismatch. Actual Dota Break behavior remains PENDING.
