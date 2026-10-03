# Jakiro: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_jakiro`; role: Support. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_jakiro_dual_breath` | 10 | DOTA_ABILITY_BEHAVIOR_POINT | abilities/heroes/jakiro/q | jakiro_dual_breath |
| 2 | `enfos_jakiro_ice_path` | 10 | DOTA_ABILITY_BEHAVIOR_POINT | abilities/heroes/jakiro/w | jakiro_ice_path |
| 3 | `enfos_jakiro_liquid_fire` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET \| DOTA_ABILITY_BEHAVIOR_AUTOCAST | abilities/heroes/jakiro/e | jakiro_liquid_fire |
| 4 | `enfos_jakiro_macropyre` | 10 | DOTA_ABILITY_BEHAVIOR_POINT | abilities/heroes/jakiro/r | jakiro_macropyre |
| 5 | `enfos_jakiro_double_trouble` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/heroes/jakiro/d | jakiro_liquid_fire |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [abilities/heroes/jakiro/q](../../../game/scripts/vscripts/abilities/heroes/jakiro/q.lua), [abilities/heroes/jakiro/w](../../../game/scripts/vscripts/abilities/heroes/jakiro/w.lua), [abilities/heroes/jakiro/e](../../../game/scripts/vscripts/abilities/heroes/jakiro/e.lua), [abilities/heroes/jakiro/r](../../../game/scripts/vscripts/abilities/heroes/jakiro/r.lua), [abilities/heroes/jakiro/d](../../../game/scripts/vscripts/abilities/heroes/jakiro/d.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_jakiro.txt`; status: FILE_VERIFIED; SHA256: `da0a519bfad3795e143cd0f8e595d83ed20ea1354a8391beed27400aadcc0f34`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/jakiro/jakiro.vmdl` |
| SoundSet | `Hero_Jakiro` |
| Ability1 | `jakiro_dual_breath` |
| Ability2 | `jakiro_ice_path` |
| Ability3 | `jakiro_liquid_fire` |
| Ability4 | `jakiro_liquid_ice` |
| Ability5 | `jakiro_double_trouble` |
| Ability6 | `jakiro_macropyre` |
| Ability10 | `special_bonus_unique_jakiro_4` |
| Ability11 | `special_bonus_unique_jakiro_6` |
| Ability12 | `special_bonus_attack_range_175` |
| Ability13 | `special_bonus_unique_jakiro_dualbreath_cooldown` |
| Ability14 | `special_bonus_unique_jakiro` |
| Ability15 | `special_bonus_unique_jakiro_7` |
| Ability16 | `special_bonus_unique_jakiro_2` |
| Ability17 | `special_bonus_unique_jakiro_3` |
| AttributeStrengthGain | `2.6` |
| AttributeAgilityGain | `1.200000` |
| AttributeIntelligenceGain | `3.300000` |

### Per-ability review leads

- `enfos_jakiro_dual_breath`: world position, travel/impact timing and radius alignment.
- `enfos_jakiro_ice_path`: world position, travel/impact timing and radius alignment.
- `enfos_jakiro_liquid_fire`: manual/autocast parity, attack proc and duplicate events; target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_jakiro_macropyre`: world position, travel/impact timing and radius alignment; ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_jakiro_double_trouble`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-09-30 level-50 migration: Q/W/E/Enfos passive gates start at level 1 with interval 1; R starts at level 5 with interval 5. Static contract test added; point/HUD and gameplay acceptance remain pending for owner live test.

2026-09-30 Double Trouble passive repair: the fifth-slot Intelligence and attack-speed bonuses now honor Break and are not inherited by illusions. KV marks the custom passive breakable; a mock regression covers both stats under normal, Broken and illusion states. Modifier lifecycle and live Dota behavior remain PENDING.

## Slot 1: `enfos_jakiro_dual_breath`

Classification: TUNE
Native counterpart: `jakiro_dual_breath` (installed native hero snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot assignment is project-specific).
Decision and PvE identity rationale: TUNE — the native mechanic already fits creeps; ten authored ranks/INT scaling require compatibility review. See the 2026-10-03 individual ledger for identified source defects and pending repair; no blanket PvP conversion is justified.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve; free rank / point cost: PENDING.
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

Change/test record: all five abilities now expose ten KV ranks; the complete 200-ability Lua mock suite passes. This confirms static/mock behavior only; in-match Dota VFX, SFX, rank-up HUD, boss and VConsole acceptance remain PENDING.

Change/test record (2026-09-30): all five Jakiro skill value blocks now use named `AbilityValues` keys consumed by Lua; ten-rank curves are unchanged. A five-slot static contract test was added. In-game damage/timing, auto-cast, VFX, SFX, modifier cleanup, boss and upgrade checks remain PENDING for the user.

Follow-up review (2026-09-30): Ice Path's configured 0.5-second `path_delay` was not read, so damage and stun occurred before the warning completed. The implementation now snapshots the cast origin/direction and applies its ranked hit and shortened boss stun after that delay. Mock regression passes; VFX/SFX, actual timing and cleanup remain pending for the user’s Dota test.

Follow-up static audit (2026-09-30): rechecked Dual Breath, Liquid Fire,
Macropyre and Double Trouble against their ten-rank KV values, EN/TR/RU/zh-CN
tooltips, evolution choices, shared Aghanim handling and targeted mocks. Liquid
Fire's manual and autocast paths both route through the same effect implementation;
Macropyre's line filtering and per-cast boss cap have regression coverage. No
additional code defect was confirmed in this pass. In-game cast/attack behavior,
rank scaling, particle controls, audio, channel/effect cleanup and upgrades remain
pending the owner's live Dota test.

## Slot 2: `enfos_jakiro_ice_path`

Classification: PVE-CONVERT
Native counterpart: `jakiro_ice_path` (installed native hero snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot assignment is project-specific).
Decision and PvE identity rationale: TUNE — the native mechanic already fits creeps; ten authored ranks/INT scaling require compatibility review. See the 2026-10-03 individual ledger for identified source defects and pending repair; no blanket PvP conversion is justified.
Expected behavior: Snapshot a planar path at cast origin, show matching endpoint warning, then use engine line targeting after 0.5 seconds with ordinary ranked engine stun for all valid enemies. A finite modifier now catches later entrants once per cast, snapshots each path, bounds late stuns by remaining lifetime and owns effect cleanup. Actual engine/particle timing and parity remain pending under the current individual ledger.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve; free rank / point cost: PENDING.
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
| Gameplay | PENDING | Historical mock protected a circular hit and Boss-only stun reduction; reopened under the 2026-10-03 individual audit. Engine timing and native path geometry remain unverified. |
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

Change/test record: all five abilities now expose ten KV ranks; the complete 200-ability Lua mock suite passes. This confirms static/mock behavior only; in-match Dota VFX, SFX, rank-up HUD, boss and VConsole acceptance remain PENDING.

## Slot 3: `enfos_jakiro_liquid_fire`

Classification: PVE-CONVERT
Native counterpart: `jakiro_liquid_fire` (installed native hero snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot assignment is project-specific).
Decision and PvE identity rationale: TUNE — the native mechanic already fits creeps; ten authored ranks/INT scaling require compatibility review. See the 2026-10-03 individual ledger for identified source defects and pending repair; no blanket PvP conversion is justified.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve; free rank / point cost: PENDING.
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

Change/test record: all five abilities now expose ten KV ranks; the complete 200-ability Lua mock suite passes. This confirms static/mock behavior only; in-match Dota VFX, SFX, rank-up HUD, boss and VConsole acceptance remain PENDING.

## Slot 4: `enfos_jakiro_macropyre`

Classification: PVE-CONVERT
Native counterpart: `jakiro_macropyre` (installed native hero snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot assignment is project-specific).
Decision and PvE identity rationale: TUNE — the native mechanic already fits creeps; ten authored ranks/INT scaling require compatibility review. See the 2026-10-03 individual ledger for identified source defects and pending repair; no blanket PvP conversion is justified.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve; free rank / point cost: PENDING.
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

Change/test record: all five abilities now expose ten KV ranks; the complete 200-ability Lua mock suite passes. This confirms static/mock behavior only; in-match Dota VFX, SFX, rank-up HUD, boss and VConsole acceptance remain PENDING.

## Slot 5: `enfos_jakiro_double_trouble`

Classification: REPLACE
Native counterpart: `Project-specific Enfos passive; native Jakiro innate remains distinct` (installed native hero snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot assignment is project-specific).
Decision and PvE identity rationale: REPLACE because this fifth ability is an Enfos-authored passive with no direct native counterpart; its hero identity comes from the adjacent Dota kit.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve; free rank / point cost: PENDING.
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
| Ranks | PENDING | Static gates put rank 10 by level 50; owner live test must confirm engine points and ability HUD. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | MOCK_PASS: Double Trouble's two bonuses are checked for Break/illusion suppression; engine modifier and Break presentation remain unverified. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | Not evaluated in this dossier setup. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: all five abilities now expose ten KV ranks; the complete 200-ability Lua mock suite passes. This confirms static/mock behavior only; in-match Dota VFX, SFX, rank-up HUD, boss and VConsole acceptance remain PENDING.

## Active individual audit — 2026-10-03

[Individual review](../../audit/JAKIRO_INDIVIDUAL_REVIEW_2026-10-03.md) supersedes historical source closures. All five handlers reviewed against installed build 6943 / revision 11069754; native-first Q/W/E/R TUNE, D REPLACE. Isolation preserves existing mechanics and known defects. Source repair, traces and every engine/visual/audio gate remain pending. Ice Path Boss reduction and Macropyre cap are defects to remove under the owner contract, not accepted behavior.

2026-10-03 R focused repair: removed the cumulative Boss-only 10% maxHP cap/table. Independent fixture reproduced truncation before the change and passes for ordinary/flagged/named Boss targets afterward; ordinary magical flags and existing line rejection remain unchanged. Native path/Scepter/VFX/SFX/engine acceptance remains PENDING.

2026-10-03 W focused repair: matching saved visual/hit endpoints, native-radius150 line query, zero-aim facing fallback, built-in stun without Boss multiplier, server/removal/reentrant callback protections, startup native bank and four-locale formula/immunity/dispel text. Independent fixture reproduced endpoint mismatch before repair and covers rank1/10/invalid callbacks afterward. Persistent native path behavior and engine/VFX/SFX/width verification remain PENDING.

2026-10-03 W persistent follow-up: independent path_duration3–7.5s, warning0.5s, one W-owned modifier per cast, existing max-three ground entities, 0.1s local engine line checks and once-per-target hits; modifier owns particle/sound destruction. Source/lifecycle tests pass, engine/VFX/SFX/performance remain PENDING.

2026-10-03 D focused repair: learned-rank and removed-handle gates, explicit nonpurge/death-retained intrinsic, visible verified Liquid Fire icon, dynamic INT/AS modifier tooltip and bounded lifecycle traces. Rank-zero defect reproduced before repair; independent ranks0–10/Break/illusion/removed-owner/tooltip/logging fixture. All engine/respawn/reconnect/tooltip presentation gates remain PENDING. No native second attack claimed.
