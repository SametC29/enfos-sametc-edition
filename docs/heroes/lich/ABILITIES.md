# Lich: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_lich`; role: Support. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_lich_frost_blast` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/heroes/lich/q | lich_frost_nova |
| 2 | `enfos_lich_frost_shield` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/heroes/lich/w | lich_frost_shield |
| 3 | `enfos_lich_sinister_gaze` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET \| DOTA_ABILITY_BEHAVIOR_CHANNELLED | abilities/heroes/lich/e | lich_sinister_gaze |
| 4 | `enfos_lich_chain_frost` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/heroes/lich/r | lich_chain_frost |
| 5 | `enfos_lich_ice_aura` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/heroes/lich/d | lich_frost_nova |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [abilities/heroes/lich/q](../../../game/scripts/vscripts/abilities/heroes/lich/q.lua), [abilities/heroes/lich/w](../../../game/scripts/vscripts/abilities/heroes/lich/w.lua), [abilities/heroes/lich/e](../../../game/scripts/vscripts/abilities/heroes/lich/e.lua), [abilities/heroes/lich/r](../../../game/scripts/vscripts/abilities/heroes/lich/r.lua), [abilities/heroes/lich/d](../../../game/scripts/vscripts/abilities/heroes/lich/d.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_lich.txt`; status: FILE_VERIFIED; SHA256: `b2ec9e1aa401185354c4f685e5db97994b00816a8a915bbf52f63dbe9128be75`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/lich/lich.vmdl` |
| SoundSet | `Hero_Lich` |
| Ability1 | `lich_frost_nova` |
| Ability2 | `lich_frost_shield` |
| Ability3 | `lich_sinister_gaze` |
| Ability4 | `lich_ice_spire` |
| Ability5 | `lich_death_charge` |
| Ability6 | `lich_chain_frost` |
| Ability10 | `special_bonus_unique_lich_8` |
| Ability11 | `special_bonus_unique_lich_6` |
| Ability12 | `special_bonus_unique_lich_2` |
| Ability13 | `special_bonus_unique_lich_3` |
| Ability14 | `special_bonus_unique_lich_4` |
| Ability15 | `special_bonus_unique_lich_7` |
| Ability16 | `special_bonus_unique_lich_1` |
| Ability17 | `special_bonus_unique_lich_5` |
| AttributeStrengthGain | `2.1` |
| AttributeAgilityGain | `1.7` |
| AttributeIntelligenceGain | `3.4` |

### Per-ability review leads

- `enfos_lich_frost_blast`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_lich_frost_shield`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_lich_sinister_gaze`: channel tick, interrupt, looping audio and thinker expiry; target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_lich_chain_frost`: target flags, immunity, spell block/reflect if applicable, target loss; ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_lich_ice_aura`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-09-30 modifier repair: `modifier_enfos_lich_ice_aura_buff` was returned by the slot-5 aura but missing from the shared `LinkLuaModifier` registry. Added the recipient link and a registry contract covering every local Enfos modifier class. The aura source also now shuts off while its caster is Broken. Lua/mock and static registration checks pass; in-game aura recipients, range, Break behavior and stat bonuses remain PENDING owner testing.

2026-09-30 level-50 migration: Q/W/E/Enfos passive gates start at level 1 with interval 1; R starts at level 5 with interval 5. Static contract test added; point/HUD and gameplay acceptance remain pending for owner live test.

Follow-up static audit (2026-09-30): Sinister Gaze's debuff pulled and drained
mana but did not restrict the target's actions, despite its description promising
that it leaves the target helpless. Its debuff now stuns the target and ends the
engine channel if the caster or target becomes invalid. Normal KV channel times
now match the configured effect durations; the Lua channel-time override also
shortens boss channels to the same 35% duration as the control effect (upper KV
ranks previously channeled after their effect expired). Mock regressions cover
target control, rank timing and channel interruption. Runtime behavior, rank
timing, audio, VFX and boss handling remain pending owner testing.

The same audit found Frost Blast applied its slow only in the splash loop, which
explicitly excluded the primary target. The primary target now receives the
ranked movement slow and boss-adjusted duration too; the fixed attack-speed slow
is represented by a named KV value. Added a regression for primary and splash
targets. Engine status resistance, VFX/SFX and live targeting remain pending.

## Slot 1: `enfos_lich_frost_blast`

Classification: TUNE
Native counterpart: `lich_frost_nova` (installed native hero snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot assignment is project-specific).
Decision and PvE identity rationale: native instant magical nuke, splash and slow remain useful; authored INT scaling, ten ranks and boss caps tune those mechanics. Current-build individual review supersedes the generated blanket PVE-CONVERT assumption for Q; see [2026-10-03 findings](../../audit/LICH_INDIVIDUAL_REVIEW_2026-10-03.md). Q removed-victim/source ordering is repaired with targeted regressions and partial debug-gated traces. Engine/VFX/audio acceptance remains PENDING; all other slot reviews remain open.
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

Change/test record (2026-09-30): Lich’s five Enfos ability definitions now expose their Lua-read values via named `AbilityValues` keys; all ten-rank curves are retained and checked by a per-hero static contract. Live gameplay, channel interruption, VFX, SFX, cleanup, boss and upgrade behavior remain pending for user testing.

## Slot 2: `enfos_lich_frost_shield`

2026-10-03 individual follow-up: source-lifetime guards prevent removed-recipient
access and orphan pulses; cast uses the decoded current-build IceAge sound with
explicit declaring-bank precache and native modifier icon. See
[individual findings](../../audit/LICH_INDIVIDUAL_REVIEW_2026-10-03.md). W rejects
hostile recipients and stops on allegiance change; missing abilities no longer
provide fallback protection. Installed6943 Ice Age root now uses recipient-bound
CP0/1/5 and CP2 radius600, with modifier-owned destruction/release. Refresh reuses
the particle and existing1s interval. Cast/rank/reduction, create/refresh/remove,
particle ownership and bounded pulse damage/Boss summaries are traced by the
shared flag. Four-language tooltips explicitly describe physical damage reduction,
duration and INT-scaled pulses. Actual visual/audio/control/upgrade acceptance is
still PENDING; W pulse slow and native attack-only mitigation remain open design
comparisons. Mocks do not establish engine acceptance.

Classification: PVE-CONVERT
Native counterpart: `lich_frost_shield` (installed native hero snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot assignment is project-specific).
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

## Slot 3: `enfos_lich_sinister_gaze`

Classification: PVE-CONVERT
Native counterpart: `lich_sinister_gaze` (installed native hero snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot assignment is project-specific).
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

Follow-up review (2026-09-30): Chain Frost's Lua applied the declared multi-hit count by alternating between already-hit units and never used its `slow_pct`. It now visits each unit at most once per cast and applies a configurable move/attack slow; bosses receive a shortened slow. Existing KV set the slow to 50%, and the 2.5-second duration follows the native mechanic documented in the [7.31c patch history](https://steamdb.info/patchnotes/8679596/); exact current-build native values and engine behavior remain unverified. Regression confirms two available enemies are hit once each and both receive the configured slow.

## Slot 4: `enfos_lich_chain_frost`

Classification: PVE-CONVERT
Native counterpart: `lich_chain_frost` (installed native hero snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot assignment is project-specific).
Decision and PvE identity rationale: PVE-CONVERT to retain the verified native hero identity while adapting PvP-only details for wave, elite and boss combat.
Expected behavior: Chain to up to `jump_count` distinct enemies within 600 units, hit each at most once per cast, and apply ranked damage plus a 50% move/attack slow for 2.5 seconds. Boss slow duration is reduced to 35%.
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
| Gameplay | PASS | Mock regression confirms distinct-target cap and configured move/attack slow; current-build bounce timing, engine damage and boss interaction remain unverified. |
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

## Slot 5: `enfos_lich_ice_aura`

2026-10-03 individual ownership repair: external armor/mana buffs now follow the
actual Lich caster's Break and learned/valid ability state; recipient Break does
not disable another hero's aura. Source/recipient lifecycle diagnostics are
debug-gated and bounded, with no getter logging or extra gameplay operations.
See [individual ledger](../../audit/LICH_INDIVIDUAL_REVIEW_2026-10-03.md).
Engine linger, multiple sources, rank replication, death and illusion policy
verification remain pending; no runtime acceptance is implied.

Classification: REPLACE
Native counterpart: `Project-specific Enfos passive; native Lich innates remain distinct` (installed native hero snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot assignment is project-specific).
Decision and PvE identity rationale: REPLACE because this fifth ability is an Enfos-authored passive with no direct native counterpart; its hero identity comes from the adjacent Dota kit.
Expected cast/travel/impact/ongoing/cleanup behavior: The intrinsic aura grants nearby allies configured armor and mana regeneration; its source and recipient modifiers are linked, and Break disables the source aura.
Normal creep / elite / boss, immunity / dispel / resistance rules: Friendly heroes and basics only; exact Dota aura refresh and Break removal timing remain for engine verification.
Current versus target rank curve; free rank / point cost: ten KV ranks, with Enfos passive rank 1 granted separately and later ranks gated by hero levels 2–10; engine HUD/point behavior remains pending.
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
| Modifiers | PENDING | Source and recipient are in the shared LinkLuaModifier registry; regression confirms Break disables the source aura. Owner must verify aura attachment, recipient stats and Break removal in Dota. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | Not evaluated in this dossier setup. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: all five abilities now expose ten KV ranks; the complete 200-ability Lua mock suite passes. This confirms static/mock behavior only; in-match Dota VFX, SFX, rank-up HUD, boss and VConsole acceptance remain PENDING.

2026-09-30 global Break metadata audit: Added KV `IsBreakable 1` to `enfos_lich_ice_aura` because its linked Lua passive implementation check `PassivesDisabled()`. Automated content validation now rejects this metadata mismatch. Actual Dota Break behavior remains PENDING.

2026-10-03 E individual follow-up: control removal now ends only its matching
active channel; channel finish clears target ownership before caster-specific
control removal. Invalid sources stop the existing thinker without invoking a
removed ability. Server guards, native icon and partial lifecycle traces added.
See the individual Lich review for three focused regressions and remaining
Gaze resource, timing, movement, absorb and owner engine gates. No runtime
certification or rank/balance change is implied.

2026-10-03 R individual follow-up: snapshot impact origin/control timing before
lethal damage; skip corpse control, preserve remaining spread and stop on removed
source. Current decoded sound bank supplies hero/creep impact events and explicit
bank precache. Two meaningful regressions and partial synchronous-hit tracing
are recorded in the Lich individual review. Native projectile identity, resources,
upgrades and engine acceptance remain open; this is not full R certification.

## Ice Spire integration follow-up — 2026-10-03

W remains TUNE: native Shield behavior plus own-Spire one-hero-hit pulse repair.
R remains TUNE: authored finite distinct-target orb plus native-style own-Spire
bridge; ward contacts consume the same impact budget and permit the next enemy
revisit. Stable five-slot IDs/ranks remain unchanged. Source integration and
per-case evidence are recorded in [Shard implementation ledger](../../audit/LICH_SHARD_IMPLEMENTATION_2026-10-03.md).
Extra Shard acquisition/reconciliation is locally implemented in slot6; the five
ordinary ranks remain unchanged and the old generic healing bonus is removed.
Owner runtime/visual/audio/engine
acceptance remains NOT TESTED; source/mock results are not engine certification.
