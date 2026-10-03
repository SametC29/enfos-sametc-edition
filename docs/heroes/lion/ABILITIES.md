# Lion: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_lion`; role: Support. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_lion_earth_spike` | 10 | DOTA_ABILITY_BEHAVIOR_POINT \| DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/heroes/lion/q | lion_impale |
| 2 | `enfos_lion_hex` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/heroes/lion/w | lion_voodoo |
| 3 | `enfos_lion_mana_drain` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET \| DOTA_ABILITY_BEHAVIOR_CHANNELLED | abilities/heroes/lion/e | lion_mana_drain |
| 4 | `enfos_lion_finger_of_death` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/heroes/lion/r | lion_finger_of_death |
| 5 | `enfos_lion_demon_soul` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/heroes/lion/d | lion_mana_drain |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [abilities/heroes/lion/q](../../../game/scripts/vscripts/abilities/heroes/lion/q.lua), [abilities/heroes/lion/w](../../../game/scripts/vscripts/abilities/heroes/lion/w.lua), [abilities/heroes/lion/e](../../../game/scripts/vscripts/abilities/heroes/lion/e.lua), [abilities/heroes/lion/r](../../../game/scripts/vscripts/abilities/heroes/lion/r.lua), [abilities/heroes/lion/d](../../../game/scripts/vscripts/abilities/heroes/lion/d.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_lion.txt`; status: FILE_VERIFIED; SHA256: `8734daf1360ea784a2cb81a3afcac9f4e3d3d128f5ed0dabe47897a80e01c1c6`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/lion/lion.vmdl` |
| SoundSet | `Hero_Lion` |
| Ability1 | `lion_impale` |
| Ability2 | `lion_voodoo` |
| Ability3 | `lion_mana_drain` |
| Ability4 | `lion_to_hell_and_back` |
| Ability5 | `generic_hidden` |
| Ability6 | `lion_finger_of_death` |
| Ability7 | `` |
| Ability10 | `special_bonus_unique_lion_6` |
| Ability11 | `special_bonus_movement_speed_20` |
| Ability12 | `special_bonus_unique_lion_5` |
| Ability13 | `special_bonus_unique_lion_11` |
| Ability14 | `special_bonus_unique_lion_8` |
| Ability15 | `special_bonus_unique_lion_10` |
| Ability16 | `special_bonus_unique_lion_4` |
| Ability17 | `special_bonus_unique_lion_2` |
| AttributeStrengthGain | `2.4` |
| AttributeAgilityGain | `1.7` |
| AttributeIntelligenceGain | `3.500000` |

### Per-ability review leads

- `enfos_lion_earth_spike`: target flags, immunity, spell block/reflect if applicable, target loss; world position, travel/impact timing and radius alignment.
- `enfos_lion_hex`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_lion_mana_drain`: channel tick, interrupt, looping audio and thinker expiry; target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_lion_finger_of_death`: target flags, immunity, spell block/reflect if applicable, target loss; ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_lion_demon_soul`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-09-30 level-50 migration: Q/W/E/Enfos passive gates start at level 1 with interval 1; R starts at level 5 with interval 5. Static contract test added; point/HUD and gameplay acceptance remain pending for owner live test.

Static kit review (2026-09-30): added the missing startup precache for the exact
Impale hit particle used by Lua. Mana Drain now ends the actual ability channel
when its target dies or becomes invalid. Finger kill stacks now cap at 20; each
stack's Finger bonus damage and global spell amplification are KV-backed and
clamped to that cap, preventing unbounded growth over the 60-wave run. Tooltips
in EN/TR/RU/zh-CN now describe the code's actual Earth Spike area, Hex debuffs,
Mana Drain damage/mana/slow, Finger scaling/stacks, and Demon Soul cast-range /
spell-amplification bonus. Mock tests pass; Lion gameplay, VFX/SFX, channeling,
boss scaling, particle cold-start and Scepter runtime checks remain pending the
owner's Dota test. The 20-stack cap is a provisional static balance decision
and can be adjusted from live results.

Follow-up static audit (2026-09-30): rechecked all five Lua handlers against
their ten-rank KV values, EN/TR/RU/zh-CN tooltips, roster assignment, evolution
choices, Aghanim manager and targeted mocks. The shared Scepter modifier applies
the documented ultimate damage/cooldown bonuses to Finger of Death, and the
shared Support Shard effect matches the documented healing bonus. No additional
code defect was confirmed in this pass. Actual targeting, channel behavior,
damage, cold-start VFX/SFX and upgrade presentation remain pending the owner's
in-game test.

Data-mapping repair (2026-09-30): the Lua handlers contained values that were
already described by the kit but bypassed named KV fields. Earth Spike radius,
cast-direction distance and Intelligence coefficient; Hex boss duration and
base movement speed; Mana Drain channel/debuff duration and slow; and Finger's
Intelligence coefficient and boss max-health damage cap now read named
`AbilityValues`. Existing behavior values are preserved. Added mock regressions
for Earth Spike geometry/scaling, normal/boss Hex duration, Mana Drain duration/
slow, and Finger's boss cap. These checks prove the Lua/KV path only; engine
targeting, rank HUD, VFX/SFX, channel presentation, bosses and upgrades remain
PENDING for the owner's Dota test.

## Slot 1: `enfos_lion_earth_spike`

Classification: PVE-CONVERT
Native counterpart: `lion_impale` (installed native hero snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot assignment is project-specific).
Decision and PvE identity rationale: PVE-CONVERT to retain the verified native hero identity while adapting PvP-only details for wave, elite and boss combat.
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

Change/test record (2026-09-30): Lion’s five Enfos ability values are now declared as named `AbilityValues` keys for Lua access; ten-rank curves are preserved and a per-hero static contract test was added. This mapping fix does not certify gameplay. Runtime behavior, targeting, VFX, SFX, modifier lifetimes, cleanup, boss and upgrade tests remain PENDING for the user’s live test.

## Slot 2: `enfos_lion_hex`

Classification: PVE-CONVERT
Native counterpart: `lion_voodoo` (installed native hero snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot assignment is project-specific).
Decision and PvE identity rationale: PVE-CONVERT to retain the verified native hero identity while adapting PvP-only details for wave, elite and boss combat.
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

## Slot 3: `enfos_lion_mana_drain`

Classification: PVE-CONVERT
Native counterpart: `lion_mana_drain` (installed native hero snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot assignment is project-specific).
Decision and PvE identity rationale: PVE-CONVERT to retain the verified native hero identity while adapting PvP-only details for wave, elite and boss combat.
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

## Slot 4: `enfos_lion_finger_of_death`

Classification: PVE-CONVERT
Native counterpart: `lion_finger_of_death` (installed native hero snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot assignment is project-specific).
Decision and PvE identity rationale: PVE-CONVERT to retain the verified native hero identity while adapting PvP-only details for wave, elite and boss combat.
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

## Slot 5: `enfos_lion_demon_soul`

Classification: REPLACE
Native counterpart: `Project-specific Enfos passive; native Lion ability 4 is lion_to_hell_and_back and remains distinct` (installed native hero snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot assignment is project-specific).
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

2026-09-30 global Break metadata audit: Added KV `IsBreakable 1` to `enfos_lion_demon_soul` because its linked Lua passive implementation check `PassivesDisabled()`. Automated content validation now rejects this metadata mismatch. Actual Dota Break behavior remains PENDING.

## 2026-10-03 isolated source checkpoint

Q/W/E/R/D now route to abilities/heroes/lion/{q,w,e,r,d}; six modifiers have explicit owners and a compatibility init. This unit preserves all handler bodies and all KV values except ScriptFile. Independent regression compares against immutable pre-extraction commit3044af6 and cold-loads all modules before the monolith, rejecting duplicate modifier links/class ownership. Focused and full tools/checks.mjs PASS,0 failed checks. Gameplay bugs and authored Boss exceptions identified in the individual ledger remain OPEN; no runtime/visual/audio or full hero source acceptance. Earlier generic PVE-CONVERT dossier labels are superseded by the current evidence-led slot decisions in docs/audit/LION_INDIVIDUAL_REVIEW_2026-10-03.md; native counterparts are not inferred from icons. No foreign code imported; existing shared helpers reused unchanged.
