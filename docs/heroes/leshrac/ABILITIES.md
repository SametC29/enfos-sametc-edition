# Leshrac: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_leshrac`; role: Mage. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_leshrac_split_earth` | 10 | DOTA_ABILITY_BEHAVIOR_POINT \| DOTA_ABILITY_BEHAVIOR_AOE | abilities/pve_kits | leshrac_split_earth |
| 2 | `enfos_leshrac_diabolic_edict` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | leshrac_diabolic_edict |
| 3 | `enfos_leshrac_lightning_storm` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/pve_kits | leshrac_lightning_storm |
| 4 | `enfos_leshrac_pulse_nova` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET \| DOTA_ABILITY_BEHAVIOR_TOGGLE | abilities/pve_kits | leshrac_pulse_nova |
| 5 | `enfos_leshrac_defilement` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | leshrac_pulse_nova |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_leshrac.txt`; status: FILE_VERIFIED; SHA256: `d28c42a4598c5a75717569cb970ade97839c4d07dc98ecee8b8d09d861df8b5f`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/leshrac/leshrac.vmdl` |
| SoundSet | `Hero_Leshrac` |
| Ability1 | `leshrac_split_earth` |
| Ability2 | `leshrac_diabolic_edict` |
| Ability3 | `leshrac_lightning_storm` |
| Ability4 | `leshrac_greater_lightning_storm` |
| Ability5 | `leshrac_defilement` |
| Ability6 | `leshrac_pulse_nova` |
| Ability10 | `special_bonus_mp_regen_150` |
| Ability11 | `special_bonus_armor_4` |
| Ability12 | `special_bonus_unique_leshrac_6` |
| Ability13 | `special_bonus_unique_leshrac_4` |
| Ability14 | `special_bonus_unique_leshrac_7` |
| Ability15 | `special_bonus_unique_leshrac_3` |
| Ability16 | `special_bonus_unique_leshrac_1` |
| Ability17 | `special_bonus_unique_leshrac_pulse_nova_lightning` |
| AttributeStrengthGain | `2.5` |
| AttributeAgilityGain | `2.5` |
| AttributeIntelligenceGain | `3.5` |

### Per-ability review leads

- `enfos_leshrac_split_earth`: world position, travel/impact timing and radius alignment.
- `enfos_leshrac_diabolic_edict`: cast/impact/modifier contract and lifetime.
- `enfos_leshrac_lightning_storm`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_leshrac_pulse_nova`: toggle state, mana drain, death/respawn cleanup; ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_leshrac_defilement`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-09-30 level-50 migration: Q/W/E/Enfos passive gates start at level 1 with interval 1; R starts at level 5 with interval 5. Static contract test added; point/HUD and gameplay acceptance remain pending for owner live test.

2026-09-30 follow-up static review: checked all five callback/KV mappings and added a Defilement regression. Confirmed its damage-event handler healed from basic attacks because it did not require an ability inflictor, and it omitted the documented illusion suppression; it now rejects events without a valid ability handle, reflected damage, Break and illusions. Updated Defilement's EN/TR/RU/zh-CN tooltip to match. Targeted mock suite passes; actual Dota damage-event fields, lifesteal attribution, passive icon/effect, audio, VConsole and boss performance remain pending owner live test. The remaining four abilities were reviewed against their own callbacks and rank values; no additional code defect was confirmed in this static pass.

## Slot 1: `enfos_leshrac_split_earth`

Classification: PVE-CONVERT
Native counterpart: `leshrac_split_earth (native Ability1)`.
Decision and PvE identity rationale: Keeps targeted ground burst and short stun; rank increases area, magic damage and stun, with boss stun reduction.
Expected behavior: Point-target cast plays ground impact, damages enemies and stuns briefly; boss control reduced.
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

Change/test record (2026-09-30): all five Leshrac skill KV blocks now provide Lua-read values through named `AbilityValues` keys; the existing ten-rank curves remain intact. Static tests cover this contract. In-game gameplay, targeting, VFX, SFX, cleanup, boss and upgrade behavior remain pending for the user’s live test.

## Slot 2: `enfos_leshrac_diabolic_edict`

Classification: PVE-CONVERT
Native counterpart: `leshrac_diabolic_edict (native Ability2)`.
Decision and PvE identity rationale: Keeps surrounding repeated pure-damage explosions; rank scales explosion count, radius and damage.
Expected behavior: Timed modifier emits one bounded random-target explosion every quarter second, then ends.
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

## Slot 3: `enfos_leshrac_lightning_storm`

Classification: PVE-CONVERT
Native counterpart: `leshrac_lightning_storm (native Ability3)`.
Decision and PvE identity rationale: Keeps chain-lightning identity; rank scales chain length, damage and slow; boss hit damage capped.
Expected behavior: Targeted chain traverses unique live enemies, creates native lightning visuals and applies a short slow.
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

## Slot 4: `enfos_leshrac_pulse_nova`

Classification: PVE-CONVERT
Native counterpart: `leshrac_pulse_nova (native Ability6)`.
Decision and PvE identity rationale: Keeps toggle aura damage identity; rank scales radius/damage while mana upkeep scales and ends toggle when depleted.
Expected behavior: Toggle creates one-second pulses with native loop sound and particle; stop on manual off, death or insufficient mana.
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

## Slot 5: `enfos_leshrac_defilement`

Classification: TUNE
Native counterpart: `leshrac_defilement (native innate Ability5); Enfos passive is its own separate slot.`.
Decision and PvE identity rationale: Preserves spell lifesteal/intellect Enfos passive; rank scales both and Break/illusion suppresses effect.
Expected behavior: Intrinsic modifier adds intellect and heals from enemy ability damage only; basic attacks, reflected damage, Break and illusions do not trigger healing.
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

2026-09-30 global Break metadata audit: Added KV `IsBreakable 1` to `enfos_leshrac_defilement` because its linked Lua passive implementation check `PassivesDisabled()`. Automated content validation now rejects this metadata mismatch. Actual Dota Break behavior remains PENDING.
