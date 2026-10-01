# Faceless Void: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_faceless_void`; role: Carry. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_void_time_walk` | 10 | DOTA_ABILITY_BEHAVIOR_POINT | abilities/pve_kits | faceless_void_time_walk |
| 2 | `enfos_void_time_dilation` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | faceless_void_time_dilation |
| 3 | `enfos_void_time_lock` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | faceless_void_time_lock |
| 4 | `enfos_void_chronosphere` | 10 | DOTA_ABILITY_BEHAVIOR_POINT | abilities/pve_kits | faceless_void_chronosphere |
| 5 | `enfos_void_backtrack` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | faceless_void_backtrack |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_faceless_void.txt`; status: FILE_VERIFIED; SHA256: `8813f14acfc6a229872961dba2c9997feae3fbb84644b83b1b983e9b8e1b4117`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/faceless_void/faceless_void.vmdl` |
| SoundSet | `Hero_FacelessVoid` |
| Ability1 | `faceless_void_time_walk` |
| Ability2 | `faceless_void_time_dilation` |
| Ability3 | `faceless_void_time_lock` |
| Ability4 | `faceless_void_time_walk_reverse` |
| Ability5 | `faceless_void_distortion_field` |
| Ability6 | `faceless_void_chronosphere` |
| Ability10 | `special_bonus_unique_faceless_void_6` |
| Ability11 | `special_bonus_unique_faceless_void_7` |
| Ability12 | `special_bonus_unique_faceless_void_3` |
| Ability13 | `special_bonus_unique_faceless_void_8` |
| Ability14 | `special_bonus_unique_faceless_void` |
| Ability15 | `special_bonus_unique_faceless_void_5` |
| Ability16 | `special_bonus_unique_faceless_void_4` |
| Ability17 | `special_bonus_unique_faceless_void_2` |
| AttributeStrengthGain | `2.600000` |
| AttributeAgilityGain | `3.3` |
| AttributeIntelligenceGain | `1.500000` |

### Per-ability review leads

- `enfos_void_time_walk`: world position, travel/impact timing and radius alignment.
- `enfos_void_time_dilation`: cast/impact/modifier contract and lifetime.
- `enfos_void_time_lock`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `enfos_void_chronosphere`: world position, travel/impact timing and radius alignment; ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_void_backtrack`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-09-30 level-50 migration: Q/W/E/Enfos passive gates start at level 1 with interval 1; R starts at level 5 with interval 5. Static contract test added; point/HUD and gameplay acceptance remain pending for owner live test.

2026-09-30 static special-value repair: migrated all five Faceless Void skill definitions to named `AbilityValues`, preserving their ten-rank curves and scalars, with a five-slot contract. The value-loading behavior is inferred from Sven's same-build runtime evidence; this does not certify Time Walk reposition, boss Chronosphere handling, audio or VFX. Those checks remain with the user.

2026-09-30 resource audit: `node tools/verify_particles.mjs` verified the six Faceless Void particle paths referenced by the kit against the installed Valve VPK; `addon_game_mode.lua` declares all six in Precache. This proves resource presence and declared precache only. Particle roles/control points, cold-start loading, in-game visuals, audio and behavior remain PENDING owner testing.

2026-09-30 static regression: added a Chronosphere mock test covering enemy-only application, repeated normal-creep freeze, one boss stun per sphere, and particle/thinker cleanup. The mock suite passes; Dota engine behavior and live visuals/audio remain PENDING owner testing.

## Slot 1: `enfos_void_time_walk`

Classification: PVE-CONVERT
Native counterpart: `faceless_void_time_walk` (installed native Ability1).
Decision and PvE identity rationale: preserves the signature displacement; rank-scaled range and self-heal give Time Walk wave value without inventing damage.
Expected cast/travel/impact/ongoing/cleanup behavior: native cast sound and travel path particle, reposition via `FindClearSpaceForUnit`, then rank-scaled heal; no persistent effect.
Normal creep / elite / boss, immunity / dispel / resistance rules: point-target self-movement, no target interaction.
Current versus target rank curve; free rank / point cost: ten  Q/W/E/Enfos passive gate from level 1 at one rank per level; R gate from level 5 at five-level intervals. Rank 10 is available by level 50; engine point/HUD test remains pending.
Shard / Scepter / Blessing / Evolution / Ascended interactions: no new upgrade behavior; existing Scepter and Blessing paths remain runtime-pending.

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
| Gameplay | PENDING | Mock regression verifies normal creep is frozen on repeated thinker ticks, boss receives one capped stun, and ally/outside enemy are excluded; Dota engine behavior remains unverified. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Static gates put rank 10 by level 50; owner live test must confirm engine points and ability HUD. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Mock verifies the particle is destroyed and thinker entity removed at expiry; engine cleanup remains unverified. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | Not evaluated in this dossier setup. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: 2026-09-30 — `Faceless Void Chronosphere refreshes normal freezes, limits boss control and cleans its thinker` in `tests/hero_kit_regressions.lua`; mock pass. Live Dota/VConsole, VFX, SFX and boss behavior remain PENDING.

## Slot 2: `enfos_void_time_dilation`

Classification: PVE-CONVERT
Native counterpart: `faceless_void_time_dilation` (installed native Ability2).
Decision and PvE identity rationale: preserve the area slow theme; expose rank-scaled movement/attack slow and cap boss duration.
Expected cast/travel/impact/ongoing/cleanup behavior: cast sound/caster effect, apply rank-scaled timed movement/attack-speed debuff with native debuff particle; modifier expiry owns cleanup.
Normal creep / elite / boss, immunity / dispel / resistance rules: enemies in radius only; bosses receive a shorter duration; engine status resistance and purge behavior remain runtime-pending.
Current versus target rank curve; free rank / point cost: ten  Q/W/E/Enfos passive gate from level 1 at one rank per level; R gate from level 5 at five-level intervals. Rank 10 is available by level 50; engine point/HUD test remains pending.
Shard / Scepter / Blessing / Evolution / Ascended interactions: no upgrade behavior changed; confirm current hooks in engine.

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
| Localization | PENDING | Not evaluated in this dossier setup. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 3: `enfos_void_time_lock`

Classification: PVE-CONVERT
Native counterpart: `faceless_void_time_lock` (installed native Ability3).
Decision and PvE identity rationale: keep the signature attack bash, using bounded boss stun and rank-controlled proc chance/damage.
Expected cast/travel/impact/ongoing/cleanup behavior: real enemy attack rolls KV chance, emits bash sound/particle, deals magical bonus damage and applies the registered short stun.
Normal creep / elite / boss, immunity / dispel / resistance rules: Break, illusions and allies rejected; normal stun uses status resistance; boss stun capped at0.1–0.3s.
Current versus target rank curve; free rank / point cost: ten  Q/W/E/Enfos passive gate from level 1 at one rank per level; R gate from level 5 at five-level intervals. Rank 10 is available by level 50; engine point/HUD test remains pending.
Shard / Scepter / Blessing / Evolution / Ascended interactions: unchanged; runtime upgrade audit pending.

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
| Localization | PENDING | Not evaluated in this dossier setup. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 4: `enfos_void_chronosphere`

Classification: PVE-CONVERT
Native counterpart: `faceless_void_chronosphere` (installed native Ability6).
Decision and PvE identity rationale: preserve the iconic area freeze; boss is hit once per sphere to prevent periodic refresh from locking an encounter.
Expected cast/travel/impact/ongoing/cleanup behavior: world-target cast and sound, bounded ground thinker creates radius particle, applies enemy freeze on interval, then destroys/releases particle and removes thinker.
Normal creep / elite / boss, immunity / dispel / resistance rules: enemy-only sphere; normal enemies are repeatedly held while inside; each boss receives one short capped stun per sphere.
Current versus target rank curve; free rank / point cost: ten  Q/W/E/Enfos passive gate from level 1 at one rank per level; R gate from level 5 at five-level intervals. Rank 10 is available by level 50; engine point/HUD test remains pending.
Shard / Scepter / Blessing / Evolution / Ascended interactions: Scepter flag retained; exact Scepter hook/behavior remains unverified.

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
| Localization | PENDING | Not evaluated in this dossier setup. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 5: `enfos_void_backtrack`

Classification: TUNE
Native counterpart: none; this Enfos fifth-slot passive is separate from native Ability5 `faceless_void_distortion_field` and is not Dota Innate metadata.
Decision and PvE identity rationale: retain Backtrack’s damage-avoidance identity while scaling its chance over ten Enfos ranks.
Expected cast/travel/impact/ongoing/cleanup behavior: passive avoid-damage callback rolls rank chance; successful avoidance emits native Backtrack particle; no timer.
Normal creep / elite / boss, immunity / dispel / resistance rules: any damage type can be avoided by the property; Break and illusions disable it. Dota callback semantics need engine confirmation.
Current versus target rank curve; free rank / point cost: ten  Q/W/E/Enfos passive gate from level 1 at one rank per level; R gate from level 5 at five-level intervals. Rank 10 is available by level 50; engine point/HUD test remains pending.
Shard / Scepter / Blessing / Evolution / Ascended interactions: shard flag retained; existing effect remains unverified.

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
| Localization | PENDING | Not evaluated in this dossier setup. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

2026-09-30 global Break metadata audit: Added KV `IsBreakable 1` to `enfos_void_time_lock`, `enfos_void_backtrack` because its linked Lua passive implementation check `PassivesDisabled()`. Automated content validation now rejects this metadata mismatch. Actual Dota Break behavior remains PENDING.
