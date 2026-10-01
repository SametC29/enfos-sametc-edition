# Chaos Knight: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_chaos_knight`; role: Fighter. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_ck_chaos_bolt` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/pve_kits | chaos_knight_chaos_bolt |
| 2 | `enfos_ck_reality_rift` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/pve_kits | chaos_knight_reality_rift |
| 3 | `enfos_ck_chaos_strike` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | chaos_knight_chaos_strike |
| 4 | `enfos_ck_phantasm` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | chaos_knight_phantasm |
| 5 | `enfos_ck_entropy` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | chaos_knight_chaos_strike |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_chaos_knight.txt`; status: FILE_VERIFIED; SHA256: `d0288fc845f81f0445018401e8d35e4b615ce95656f9024078e1643f083aab47`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/chaos_knight/chaos_knight.vmdl` |
| SoundSet | `Hero_ChaosKnight` |
| Ability1 | `chaos_knight_chaos_bolt` |
| Ability2 | `chaos_knight_reality_rift` |
| Ability3 | `chaos_knight_chaos_strike` |
| Ability4 | `generic_hidden` |
| Ability5 | `chaos_knight_fundamental_forging` |
| Ability6 | `chaos_knight_phantasm` |
| Ability10 | `special_bonus_unique_chaos_knight_6` |
| Ability11 | `special_bonus_unique_chaos_knight_2` |
| Ability12 | `special_bonus_unique_chaos_knight_8` |
| Ability13 | `special_bonus_strength_10` |
| Ability14 | `special_bonus_unique_chaos_knight_3` |
| Ability15 | `special_bonus_unique_chaos_knight` |
| Ability16 | `special_bonus_unique_chaos_knight_5` |
| Ability17 | `special_bonus_unique_chaos_knight_7` |
| AttributeStrengthGain | `3.100000` |
| AttributeAgilityGain | `1.8` |
| AttributeIntelligenceGain | `1.200000` |

### Per-ability review leads

- `enfos_ck_chaos_bolt`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_ck_reality_rift`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_ck_chaos_strike`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `enfos_ck_phantasm`: ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_ck_entropy`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-09-30 level-50 migration: Q/W/E/Entropy gates are level 1 +1; Phantasm is level 5 +5. Static rank contract is covered by a focused check. Owner live verification of rank points and HUD remains pending.

2026-09-30 static special-value repair: migrated Chaos Knight's five ability value blocks to named `AbilityValues` while preserving the existing rank curves and scalars. The 10-rank and schema contract now covers every Enfos slot. This is a static fix based on the Sven-tested KV/Lua failure pattern; CK tracking projectile, illusions, damage, sound and visuals still need your Dota testing.

## Slot 1: `enfos_ck_chaos_bolt`

Classification: PVE-CONVERT
Native counterpart: `chaos_knight_chaos_bolt` (installed Dota source snapshot recorded above; native Ability1).
Decision and PvE identity rationale: preserve the signature tracking bolt; strength-scaling damage and capped boss control support the Fighter role without an unrestricted stun loop.
Expected cast/travel/impact/ongoing/cleanup behavior: cast sound, tracking projectile, impact particle/sound, magical damage and registered stun modifier; projectile engine-owned, stun expires by duration.
Normal creep / elite / boss, immunity / dispel / resistance rules: enemy hero/basic only, spell block honored, normal random stun, boss stun capped by KV; immunity policy follows the ability KV. Stun uses engine status resistance; runtime confirmation pending.
Current versus target rank curve; free rank / point cost: KV has 10 ranks; Q/W/E/Enfos passive gates start at level 1, R starts at level 5, with rank 10 at level 50. Engine point/HUD acceptance remains pending.
Shard / Scepter / Blessing / Evolution / Ascended interactions: no direct interaction implemented by this change; audit existing upgrade hooks in runtime remains pending.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: installed source snapshot, ClientVersion 6941 / SourceRevision 11041083, SHA256 `d0288fc845f81f0445018401e8d35e4b615ce95656f9024078e1643f083aab47`.
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: tracking and impact use `chaos_knight_chaos_bolt.vpcf`; VPK existence and precache statically verified; in-engine appearance pending.
- Sound events + declaring banks + emission target + loop termination: `Hero_ChaosKnight.ChaosBolt.Cast` and `.Impact`; definitions/build playback pending.
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
| Ranks | PENDING | Static KV gate contract is recorded separately; level-50 skill-point/HUD behavior awaits owner live test. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PASS | VPK path verification and game-mode precache list; cold-start Dota test pending. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PASS | Generated EN/TR/RU/zh-CN strings synchronized from Turkish source. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): static source/VPK review and Chaos Knight behavior regressions pass as part of the current 191-test hero-kit mock suite. The suite covers bolt projectile/impact/boss stun, Reality Rift spell block and boss displacement rules, Chaos Strike crit/lifesteal/cleave, Phantasm summon configuration/echo, and Entropy/Break. Project checks also pass. Dota/VConsole gameplay, sound and visual acceptance remain PENDING. A mock pass is not ENGINE_PASS.

## Slot 2: `enfos_ck_reality_rift`

Classification: PVE-CONVERT
Native counterpart: `chaos_knight_reality_rift` (installed source snapshot; native Ability2).
Decision and PvE identity rationale: movement and armor reduction preserve the native setup role; keeping bosses in place avoids breaking encounter positioning.
Expected cast/travel/impact/ongoing/cleanup behavior: blockable target cast, cast/target sounds, two-origin rift particle, midpoint reposition for caster and non-boss target, timed armor debuff with attached particle.
Normal creep / elite / boss, immunity / dispel / resistance rules: enemy hero/basic only; spell block honored; normal targets reposition, bosses do not and receive KV-capped duration; debuff is purgable according to engine default, runtime pending.
Current versus target rank curve; free rank / point cost: KV has 10 ranks; Q/W/E/Enfos passive gates start at level 1, R starts at level 5, with rank 10 at level 50. Engine point/HUD acceptance remains pending.
Shard / Scepter / Blessing / Evolution / Ascended interactions: not changed; upgrade compatibility still requires runtime audit.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: installed ClientVersion 6941 / SourceRevision 11041083; snapshot SHA256 above.
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: `chaos_knight_reality_rift.vpcf` uses CP0 caster, CP1 target, CP2 midpoint; debuff uses `chaos_knight_reality_rift_buff.vpcf`; path verified in VPK, scene pending.
- Sound events + declaring banks + emission target + loop termination: `Hero_ChaosKnight.RealityRift` and `.Target`; installed playback not engine-tested.
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
| Ranks | PENDING | Static KV gate contract is recorded separately; level-50 skill-point/HUD behavior awaits owner live test. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PASS | Both PFX paths are in game-mode precache and installed VPK; cold start pending. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PASS | Generated EN/TR/RU/zh-CN strings synchronized. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): static source/VPK review and Chaos Knight mock regression pass; Dota/VConsole gameplay, sound and visual acceptance remain PENDING.

## Slot 3: `enfos_ck_chaos_strike`

Classification: PVE-CONVERT
Native counterpart: `chaos_knight_chaos_strike` (installed source snapshot; native Ability3).
Decision and PvE identity rationale: critical attacks are the core identity; cleave and sustain let the mechanic contribute to wave combat while remaining enemy-hit driven.
Expected cast/travel/impact/ongoing/cleanup behavior: intrinsic modifier grants bonus attack damage and critical chance/multiplier; real enemy attack events trigger critical feedback, lifesteal, and bounded physical cleave. No thinker or persistent particle.
Normal creep / elite / boss, immunity / dispel / resistance rules: enemy attacks only; illusions and Break disabled; cleave excludes primary target and filters through shared enemy helper. Boss takes ordinary attack/cleave damage.
Current versus target rank curve; free rank / point cost: KV has 10 ranks; Q/W/E/Enfos passive gates start at level 1, R starts at level 5, with rank 10 at level 50. Engine point/HUD acceptance remains pending.
Shard / Scepter / Blessing / Evolution / Ascended interactions: not changed; existing upgrade-specific behavior needs runtime audit.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: installed ClientVersion 6941 / SourceRevision 11041083; snapshot SHA256 above.
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: critical feedback uses `chaos_knight_weapon_blur_critical.vpcf` on caster; VPK path verified, in-engine display pending.
- Sound events + declaring banks + emission target + loop termination: `Hero_ChaosKnight.ChaosStrike`; sound-bank playback pending.
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
| Ranks | PENDING | Static KV gate contract is recorded separately; level-50 skill-point/HUD behavior awaits owner live test. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PASS | Critical particle is in game-mode precache and installed VPK; cold-start pending. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PASS | Generated EN/TR/RU/zh-CN strings synchronized. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): regression covers attacks vs spell damage, crit, lifesteal and cleave; mock pass. Engine balance/visual/audio check remains PENDING.

## Slot 4: `enfos_ck_phantasm`

Classification: PVE-CONVERT
Native counterpart: `chaos_knight_phantasm` (installed source snapshot; native Ability6).
Decision and PvE identity rationale: copies preserve the defining ultimate; bounded count and timed replacement avoid unbounded summon growth. Rank scaling adds hero attack damage and a single-hit echo.
Expected cast/travel/impact/ongoing/cleanup behavior: cast sound and burst particle, timed self-buff, summon service creates capped copies and clears prior Enfos CK copies; buff expiry and service own summon cleanup.
Normal creep / elite / boss, immunity / dispel / resistance rules: no target filtering at summon cast; copies attack normal PvE targets through summon manager. Echo is physical, enemy-only and only from CK’s own attack. Boss damage uses normal damage scaling; runtime pending.
Current versus target rank curve; free rank / point cost: KV has 10 ranks; level-50 rank gates are configured; engine point/HUD behavior remains pending owner verification.
Shard / Scepter / Blessing / Evolution / Ascended interactions: HasScepterUpgrade flag exists; this change did not add or certify Scepter/Blessing behavior. Audit pending.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: installed ClientVersion 6941 / SourceRevision 11041083; snapshot SHA256 above.
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: `chaos_knight_phantasm.vpcf` attached to caster; VPK path verified, scene pending.
- Sound events + declaring banks + emission target + loop termination: `Hero_ChaosKnight.Phantasm`; engine playback pending.
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
| Ranks | PENDING | Static KV gate contract is recorded separately; level-50 skill-point/HUD behavior awaits owner live test. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PASS | Particle is in game-mode precache and installed VPK; cold-start pending. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PASS | Generated EN/TR/RU/zh-CN strings synchronized. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): mock verifies rank-driven summon count/outgoing damage and echo logic; summon cap is delegated to existing manager. Dota/VConsole summon visuals, voice/audio, upgrades and cleanup remain PENDING.

## Slot 5: `enfos_ck_entropy`

Classification: TUNE
Native counterpart: None; Enfos fifth-slot ID is custom and is not labeled as Dota Innate.
Decision and PvE identity rationale: rank-scaled Strength and attack speed reinforce Chaos Knight’s bruiser role and remain disabled by Break.
Expected cast/travel/impact/ongoing/cleanup behavior: intrinsic modifier supplies KV Strength and attack speed; no particle, cast, timer, or cleanup lifecycle.
Normal creep / elite / boss, immunity / dispel / resistance rules: self-only stats apply regardless of target type; Break disables both bonuses.
Current versus target rank curve; free rank / point cost: KV has 10 ranks; its Enfos passive starts at level 1 with rank 10 at level 10; free initial rank comes from the innates manager. Engine point/HUD acceptance remains pending.
Shard / Scepter / Blessing / Evolution / Ascended interactions: HasShardUpgrade flag exists; this change did not verify the shard modifier/hook. Scepter/Blessing interactions pending.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: Enfos-only; native slot distinction verified in installed snapshot (native Ability5 is `chaos_knight_fundamental_forging`), ClientVersion 6941 / SourceRevision 11041083, SHA256 above.
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
| Ranks | PENDING | Static KV gate contract is recorded separately; level-50 skill-point/HUD behavior awaits owner live test. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PASS | Generated EN/TR/RU/zh-CN strings synchronized. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): mock verifies rank values and Break. No cast/VFX/SFX is expected for passive; Dota confirmation and shard hook review remain PENDING.

2026-09-30 global Break metadata audit: Added KV `IsBreakable 1` to `enfos_ck_chaos_strike`, `enfos_ck_entropy` because its linked Lua passive implementation check `PassivesDisabled()`. Automated content validation now rejects this metadata mismatch. Actual Dota Break behavior remains PENDING.
