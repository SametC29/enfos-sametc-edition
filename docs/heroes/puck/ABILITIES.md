# Puck: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_puck`; role: Mage. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_puck_illusory_orb` | 10 | DOTA_ABILITY_BEHAVIOR_POINT | abilities/pve_kits | puck_illusory_orb |
| 2 | `enfos_puck_waning_rift` | 10 | DOTA_ABILITY_BEHAVIOR_POINT \| DOTA_ABILITY_BEHAVIOR_AOE | abilities/pve_kits | puck_waning_rift |
| 3 | `enfos_puck_phase_shift` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | puck_phase_shift |
| 4 | `enfos_puck_dream_coil` | 10 | DOTA_ABILITY_BEHAVIOR_POINT \| DOTA_ABILITY_BEHAVIOR_AOE | abilities/pve_kits | puck_dream_coil |
| 5 | `enfos_puck_faerie_magic` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | puck_phase_shift |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_puck.txt`; status: FILE_VERIFIED; SHA256: `f46e4f17fb0fab23f7d39ff60ea11a7e0dc61cfda5c6b60e30bc20313a4f3b62`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/puck/puck.vmdl` |
| SoundSet | `Hero_Puck` |
| Ability1 | `puck_illusory_orb` |
| Ability2 | `puck_waning_rift` |
| Ability3 | `puck_phase_shift` |
| Ability4 | `puck_ethereal_jaunt` |
| Ability5 | `puck_puckish` |
| Ability6 | `puck_dream_coil` |
| Ability10 | `special_bonus_unique_puck_orb_damage` |
| Ability11 | `special_bonus_unique_puck_7` |
| Ability12 | `special_bonus_unique_puck_5` |
| Ability13 | `special_bonus_unique_puck_6` |
| Ability14 | `special_bonus_unique_puck_2` |
| Ability15 | `special_bonus_unique_puck_coil_damage` |
| Ability16 | `special_bonus_unique_puck` |
| Ability17 | `special_bonus_unique_puck_rift_radius` |
| AttributeStrengthGain | `2.400000` |
| AttributeAgilityGain | `2.1` |
| AttributeIntelligenceGain | `3.800000` |

### Per-ability review leads

- `enfos_puck_illusory_orb`: world position, travel/impact timing and radius alignment.
- `enfos_puck_waning_rift`: world position, travel/impact timing and radius alignment.
- `enfos_puck_phase_shift`: cast/impact/modifier contract and lifetime.
- `enfos_puck_dream_coil`: world position, travel/impact timing and radius alignment; ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_puck_faerie_magic`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-09-30 level-50 migration: Q/W/E/Enfos passive gates start at level 1 with interval 1; R starts at level 5 with interval 5. Static contract test added; point/HUD and gameplay acceptance remain pending for owner live test.

2026-09-30 follow-up static review: reviewed all five callbacks against the current rank values and added a Phase Shift regression confirming its ranked duration plus `INVULNERABLE` and `OUT_OF_GAME` states. No additional gameplay defect was confirmed. Waning Rift currently passes a fixed Vector(400,400,400) to particle CP1 while its gameplay radius scales from 300 to 480; the local compiled particle does not establish CP1 semantics, so this remains a visual alignment candidate rather than a proven defect. Dota display, CP meaning, all sound events/audibility, particle cleanup, boss feel and VConsole remain pending the owner's live test.

2026-09-30 static repair: Illusory Orb now flattens its aim vector and falls back to Puck's facing when the cursor overlaps the caster, preventing a zero-velocity linear projectile. A regression aims at Puck's own position and asserts the projectile travels along the configured facing direction. This mock does not certify engine projectile visuals, collision or sound; those remain pending owner testing.

## Slot 1: `enfos_puck_illusory_orb`

Classification: PVE-CONVERT
Native counterpart: `puck_illusory_orb (native Ability1)`.
Decision and PvE identity rationale: Keeps the moving orb and pierce identity; now uses a real linear projectile impact callback with rank speed/radius/damage and a boss cap.
Expected behavior: Cast launches native orb visual down a bounded lane; each enemy collision gets one magic hit.
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

Change/test record (2026-09-30): Puck’s five Enfos abilities now declare Lua-read values under named `AbilityValues` keys, preserving all ten-rank curves. A static contract test covers all five slots. Live gameplay, targeting, VFX, SFX, animation, cleanup, boss behavior and upgrades remain pending for the user’s in-game test.

## Slot 2: `enfos_puck_waning_rift`

Classification: PVE-CONVERT
Native counterpart: `puck_waning_rift (native Ability2)`.
Decision and PvE identity rationale: Keeps the targeted silence/damage burst; removes an incorrect caster teleport from the prior implementation.
Expected behavior: Point-target area cast stays at the target location, damages and silences enemies with boss duration/damage limits.
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

## Slot 3: `enfos_puck_phase_shift`

Classification: PVE-CONVERT
Native counterpart: `puck_phase_shift (native Ability3)`.
Decision and PvE identity rationale: Keeps brief invulnerability refuge; uses a timed cast modifier and avoids channel-interrupt desync.
Expected behavior: No-target cast grants timed invulnerability and phase shift particle.
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

## Slot 4: `enfos_puck_dream_coil`

Classification: PVE-CONVERT
Native counterpart: `puck_dream_coil (native Ability6)`.
Decision and PvE identity rationale: Keeps focused coil control; PvE version uses a short burst AoE stun/damage with boss caps.
Expected behavior: Place coil particle, stun area briefly, deal magical damage; boss duration shortened and damage capped.
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

## Slot 5: `enfos_puck_faerie_magic`

Classification: TUNE
Native counterpart: `puck_puckish (native Ability5 innate); separate Enfos passive slot.`.
Decision and PvE identity rationale: Enfos passive grants ranked mobility/spell amplification independently of Dota Innate metadata; respects Break and illusion rules.
Expected behavior: Intrinsic movement speed and spell amplification values scale by rank, disabled under Break and on illusions.
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

2026-09-30 global Break metadata audit: Added KV `IsBreakable 1` to `enfos_puck_faerie_magic` because its linked Lua passive implementation check `PassivesDisabled()`. Automated content validation now rejects this metadata mismatch. Actual Dota Break behavior remains PENDING.
