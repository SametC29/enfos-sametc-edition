# Medusa: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_medusa`; role: Carry. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_medusa_split_shot` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET \| DOTA_ABILITY_BEHAVIOR_TOGGLE | abilities/pve_kits | medusa_split_shot |
| 2 | `enfos_medusa_mystic_snake` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/pve_kits | medusa_mystic_snake |
| 3 | `enfos_medusa_mana_shield` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | medusa_mana_shield |
| 4 | `enfos_medusa_stone_gaze` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | medusa_stone_gaze |
| 5 | `enfos_medusa_gorgon_gaze` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | medusa_cold_blooded |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_medusa.txt`; status: FILE_VERIFIED; SHA256: `2e0ca286f7164f1160c2295eaa10dabffe7101f628c06c16b84a044ea63c6f53`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/medusa/medusa.vmdl` |
| SoundSet | `Hero_Medusa` |
| Ability1 | `medusa_split_shot` |
| Ability2 | `medusa_mystic_snake` |
| Ability3 | `medusa_gorgon_grasp` |
| Ability4 | `medusa_cold_blooded` |
| Ability5 | `medusa_mana_shield` |
| Ability6 | `medusa_stone_gaze` |
| Ability10 | `special_bonus_unique_medusa_gorgons_grasp_radius` |
| Ability11 | `special_bonus_unique_medusa_8` |
| Ability12 | `special_bonus_unique_medusa_gorgons_grasp_volleys` |
| Ability13 | `special_bonus_unique_medusa_5` |
| Ability14 | `special_bonus_unique_medusa_snake_damage` |
| Ability15 | `special_bonus_unique_medusa_2` |
| Ability16 | `special_bonus_unique_medusa` |
| Ability17 | `special_bonus_intelligence_40` |
| AttributeStrengthGain | `0` |
| AttributeAgilityGain | `3.6` |
| AttributeIntelligenceGain | `3.6` |

### Per-ability review leads

- `enfos_medusa_split_shot`: toggle state, mana drain, death/respawn cleanup.
- `enfos_medusa_mystic_snake`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_medusa_mana_shield`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `enfos_medusa_stone_gaze`: ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_medusa_gorgon_gaze`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-09-30 level-50 migration: Q/W/E/Enfos passive gates start at level 1 with interval 1; R starts at level 5 with interval 5. Static contract test added; point/HUD and gameplay acceptance remain pending for owner live test.

2026-09-30 static special-value repair: migrated all five Medusa ability definitions to named `AbilityValues`, preserving ten-rank arrays and scalar values, and added a content contract. The Medusa native identity/source mapping remains documented separately from Enfos fifth-slot passive. This does not establish that split-shot projectiles, mana shield absorption, Gaze control, sound or particles behave correctly in Dota; the user will test those in-game.

2026-09-30 resource audit: `node tools/verify_particles.mjs` verified the six Medusa particle paths against the installed Valve VPK, and all six are declared in `addon_game_mode.lua` precache. This confirms file presence and declared precache only; projectile/impact roles, control points, cold-start behavior, audio and in-game rendering remain PENDING owner testing. The 169 hero-kit mock regressions pass, including all five Medusa kits; these do not certify Mana Shield damage semantics or any runtime visuals/audio.

## Slot 1: `enfos_medusa_split_shot`

Classification: PVE-CONVERT
Native counterpart: `medusa_split_shot` (installed native Ability1).
Decision and PvE identity rationale: preserve toggle and multi-arrow carry identity; rank scaling bounds additional arrow count and damage.
Expected cast/travel/impact/ongoing/cleanup behavior: on successful real attack, launch up to rank-count tracking projectiles; physical side-shot damage occurs only on projectile impact. Toggle state owns no timer.
Normal creep / elite / boss, immunity / dispel / resistance rules: side targets are living enemies within rank radius; Break and illusions disable. Projectiles are dodgeable; primary attack is untouched.
Current versus target rank curve; free rank / point cost: ten ranks; one to six additional arrows, rank-based damage/range/speed. Level-50 KV gates are configured; engine point/HUD behavior remains pending owner verification.
Shard / Scepter / Blessing / Evolution / Ascended interactions: unchanged; current upgrade hooks remain runtime-pending.

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
| Ranks | PENDING | Static gates put rank 10 by level 50; owner live test must confirm engine points and ability HUD. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PASS | Turkish source generated into EN/TR/RU/zh-CN; token validation passed. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): 140 hero-kit behavior mocks, all-200 ability/modifier smoke, and installed-VPK particle checks passed. Dota/VConsole gameplay, live visual/audio, shield engine semantics and upgrade acceptance remain PENDING.

## Slot 2: `enfos_medusa_mystic_snake`

Classification: PVE-CONVERT
Native counterpart: `medusa_mystic_snake` (installed native Ability2).
Decision and PvE identity rationale: restore the visible travelling snake and enemy bounce sequence; convert PvP mana pressure to caster mana return and cap per-boss hit.
Expected cast/travel/impact/ongoing/cleanup behavior: blockable enemy target starts a tracking projectile; each impact deals magical damage, plays impact VFX/SFX, restores rank mana, then launches the next projectile to an unvisited nearby enemy. Chain state is discarded on invalid/dodged target or exhaustion.
Normal creep / elite / boss, immunity / dispel / resistance rules: enemy hero/basic only; initial spell block is honored, projectiles are dodgeable, boss damage is capped per impact by max health. Status immunity remains engine-pending.
Current versus target rank curve; free rank / point cost: ten ranks; up to seven target hits, rank mana return, Agility scaling and bounce damage.
Shard / Scepter / Blessing / Evolution / Ascended interactions: unchanged; upgrade acceptance pending.

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
| Ranks | PENDING | Static gates put rank 10 by level 50; owner live test must confirm engine points and ability HUD. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PASS | Turkish source generated into EN/TR/RU/zh-CN; token validation passed. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): 140 hero-kit behavior mocks, all-200 ability/modifier smoke, and installed-VPK particle checks passed. Dota/VConsole gameplay, live visual/audio, shield engine semantics and upgrade acceptance remain PENDING.

## Slot 3: `enfos_medusa_mana_shield`

Classification: PVE-CONVERT
Native counterpart: `medusa_mana_shield` (installed native Ability5).
Decision and PvE identity rationale: maintain Medusa’s defining mana-powered defense and increase mana/absorption with ranks.
Expected cast/travel/impact/ongoing/cleanup behavior: intrinsic modifier adds mana and spends mana to offset a rank percentage of incoming damage, capped by remaining mana efficiency; no persistent VFX/audio.
Normal creep / elite / boss, immunity / dispel / resistance rules: self-only and applies to incoming damage; Break and illusions disable mana bonus and absorption.
Current versus target rank curve; free rank / point cost: ten ranks; mana100–1000, absorption30–80%, efficiency1.5–3.6 damage per mana.
Shard / Scepter / Blessing / Evolution / Ascended interactions: unchanged; engine damage-property and shard acceptance pending.

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
| Ranks | PENDING | Static gates put rank 10 by level 50; owner live test must confirm engine points and ability HUD. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PASS | Turkish source generated into EN/TR/RU/zh-CN; token validation passed. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): 140 hero-kit behavior mocks, all-200 ability/modifier smoke, and installed-VPK particle checks passed. Dota/VConsole gameplay, live visual/audio, shield engine semantics and upgrade acceptance remain PENDING.

## Slot 4: `enfos_medusa_stone_gaze`

Classification: PVE-CONVERT
Native counterpart: `medusa_stone_gaze` (installed native Ability6).
Decision and PvE identity rationale: preserve the iconic area petrification and physical damage setup; cap boss control sharply.
Expected cast/travel/impact/ongoing/cleanup behavior: cast sound and caster effect; enemies in radius receive timed petrification, attached debuff particle and rank-scaled incoming physical damage amplification.
Normal creep / elite / boss, immunity / dispel / resistance rules: enemy-only; regular petrify lasts rank duration; boss stun/freeze duration is capped to 0.3–1 second. Engine resistance/immunity remains pending.
Current versus target rank curve; free rank / point cost: ten ranks; radius700–900, petrify1–3.5s, boss0.3–1s, physical amp15–55%.
Shard / Scepter / Blessing / Evolution / Ascended interactions: HasScepterUpgrade retained; live Scepter behavior remains unverified.

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
| Ranks | PENDING | Static gates put rank 10 by level 50; owner live test must confirm engine points and ability HUD. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PASS | Turkish source generated into EN/TR/RU/zh-CN; token validation passed. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): 140 hero-kit behavior mocks, all-200 ability/modifier smoke, and installed-VPK particle checks passed. Dota/VConsole gameplay, live visual/audio, shield engine semantics and upgrade acceptance remain PENDING.

## Slot 5: `enfos_medusa_gorgon_gaze`

Classification: TUNE
Native counterpart: none; Enfos fifth slot is a project passive, separate from native `medusa_cold_blooded` Ability4 and native Mana Shield Ability5. It is not Dota Innate metadata.
Decision and PvE identity rationale: a rank-scaling damage/range passive complements Medusa’s Carry role and starts separately through the Enfos passive grant.
Expected cast/travel/impact/ongoing/cleanup behavior: intrinsic modifier adds bonus damage and attack range; no cast or particle.
Normal creep / elite / boss, immunity / dispel / resistance rules: self-only; Break and illusions disable both bonuses.
Current versus target rank curve; free rank / point cost: ten ranks, bonus damage15–180 and range20–120; free rank/points are managed separately from the passive curve.
Shard / Scepter / Blessing / Evolution / Ascended interactions: HasShardUpgrade retained; exact hook not changed or runtime verified.

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
| Ranks | PENDING | Static gates put rank 10 by level 50; owner live test must confirm engine points and ability HUD. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PASS | Turkish source generated into EN/TR/RU/zh-CN; token validation passed. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): 140 hero-kit behavior mocks, all-200 ability/modifier smoke, and installed-VPK particle checks passed. Dota/VConsole gameplay, live visual/audio, shield engine semantics and upgrade acceptance remain PENDING.

2026-09-30 global Break metadata audit: Added KV `IsBreakable 1` to `enfos_medusa_mana_shield`, `enfos_medusa_gorgon_gaze` because its linked Lua passive implementation check `PassivesDisabled()`. Automated content validation now rejects this metadata mismatch. Actual Dota Break behavior remains PENDING.
