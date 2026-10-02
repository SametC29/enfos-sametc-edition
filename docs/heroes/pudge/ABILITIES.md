# Pudge: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_pudge`; role: Tank. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_pudge_meat_hook` | 10 | DOTA_ABILITY_BEHAVIOR_POINT \| DOTA_ABILITY_BEHAVIOR_DIRECTIONAL | abilities/pve_kits | pudge_meat_hook |
| 2 | `enfos_pudge_rot` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET \| DOTA_ABILITY_BEHAVIOR_TOGGLE | abilities/pve_kits | pudge_rot |
| 3 | `enfos_pudge_flesh_heap` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | pudge_flesh_heap |
| 4 | `enfos_pudge_dismember` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET \| DOTA_ABILITY_BEHAVIOR_CHANNELLED | abilities/pve_kits | pudge_dismember |
| 5 | `enfos_pudge_meat_shield` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | pudge_eject |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_pudge.txt`; status: FILE_VERIFIED; SHA256: `01ac9e175c2127bb00839ef8356fdb09b89fbff81e16d80fded83664adc975fa`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/pudge/pudge.vmdl` |
| SoundSet | `Hero_Pudge` |
| Ability1 | `pudge_meat_hook` |
| Ability2 | `pudge_rot` |
| Ability3 | `pudge_flesh_heap` |
| Ability4 | `generic_hidden` |
| Ability5 | `pudge_innate_graft_flesh` |
| Ability6 | `pudge_dismember` |
| Ability10 | `special_bonus_armor_5` |
| Ability11 | `special_bonus_unique_pudge_4` |
| Ability12 | `special_bonus_spell_lifesteal_8` |
| Ability13 | `special_bonus_unique_pudge_7` |
| Ability14 | `special_bonus_unique_pudge_6` |
| Ability15 | `special_bonus_unique_pudge_5` |
| Ability16 | `special_bonus_unique_pudge_3` |
| Ability17 | `special_bonus_unique_pudge_1` |
| AttributeStrengthGain | `3.0` |
| AttributeAgilityGain | `1.400000` |
| AttributeIntelligenceGain | `1.800000` |

### Per-ability review leads

- `enfos_pudge_meat_hook`: world position, travel/impact timing and radius alignment.
- `enfos_pudge_rot`: toggle state, mana drain, death/respawn cleanup.
- `enfos_pudge_flesh_heap`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `enfos_pudge_dismember`: channel tick, interrupt, looping audio and thinker expiry; target flags, immunity, spell block/reflect if applicable, target loss; ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_pudge_meat_shield`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

2026-10-02 source review: refreshed installed hero KV confirms `GameSoundsFile` is `soundevents/game_sounds_heroes/game_sounds_pudge.vsndevts`; this bank was absent from the addon's startup hero-sound precache list even though the Pudge kit emits `Hero_Pudge.MeatHook`, `Hero_Pudge.Rot` and `Hero_Pudge.Dismember`. Added Pudge to that shared list. The same installed native ability definitions specify `ACT_DOTA_CAST_ABILITY_1` for Meat Hook, `ACT_DOTA_CAST_ABILITY_2` for Rot, and both `ACT_DOTA_CAST_ABILITY_4` and `ACT_DOTA_CHANNEL_ABILITY_4` for Dismember; the Enfos KV now carries those animation fields. Dismember's native magic-immune target flag is also now explicit and matches its immunity setting. Static regression checks cover these contracts and the bank list. Cold-client sound playback and in-game gestures remain PENDING owner Dota/VConsole verification.

## Human decisions and runtime evidence (preserve on refresh)

2026-09-30 implementation record: all five Enfos slots now expose ten KV ranks; custom Meat Shield is no longer mislabeled as Dota `Innate`. Verified source mapping: Meat Hook=`pudge_meat_hook` (Ability1), Rot=`pudge_rot` (Ability2), Flesh Heap=`pudge_flesh_heap` (Ability3), Dismember=`pudge_dismember` (Ability6), Meat Shield is a conversion of native innate `pudge_innate_graft_flesh` (Ability5). Hook now launches the VPK-verified linear hook particle, deals impact damage only on collision, and pulls non-boss targets. Rot reads its radius/tick/mana/self-cost/slow values from KV and stops its loop on modifier cleanup. Flesh Heap and Meat Shield honor Break; kill stacks are capped. Dismember rejects allies/spell block, caps boss stun, owns one persistent tether effect, and no longer emits its loop audio on every damage tick; actual dealt damage drives healing when available. Mock coverage includes hook travel/pull and Dismember cleanup. VPK check confirms the four used Pudge particles. Live engine hook collision/animation/audio, Rot radius visual and boss interactions remain PENDING.

2026-09-30 static special-value repair: migrated all five Pudge abilities to named `AbilityValues`, preserving their current rank curves and scalar fields. Improved the deep audit's static key reference detection to recognize conditional Lua keys (`boss_key or normal_key`); this confirms Flesh Heap's kill-stack values are referenced instead of leaving them falsely flagged. Added regressions for the schema and conditional-key audit. No Dota test is claimed; the user owns live gameplay, audio and VFX verification.

2026-09-30 channel lifecycle repair: Dismember's interval handler now calls the
ability's `EndChannel(true)` when Pudge or the target dies/becomes invalid;
destroying only the Lua modifier did not explicitly terminate the engine
channel. Added mock regressions for both dead-target and dead-caster paths.
Interruption timing, channel animation/audio cleanup, and boss runtime behavior
remain PENDING for the owner's Dota test.

2026-09-30 mock regression evidence: the current suite verifies Meat Hook projectile travel/impact/pull; Rot rank-value radius, mana drain, self-cost and damage tick; Flesh Heap kill stacks, cap and Break; and Dismember spell block, boss control cap, tether cleanup and explicit channel interruption for dead caster/target. Added Meat Shield coverage for damage accumulation to its KV threshold, max-health-scaled physical burst and radius, three-burst-per-event cap, and Break suppression of both accumulation and defensive bonuses. These tests exercise mocked Lua wiring only; Dota gameplay, effects, audio, channel/interrupt timing, boss behavior and rank/HUD presentation remain PENDING for the user.

## Slot 1: `enfos_pudge_meat_hook`

Classification: PVE-CONVERT
Native counterpart: `pudge_meat_hook` (installed Ability1).
Decision and PvE identity rationale: preserve the hook projectile and pull identity, with PvE-safe boss pull exclusion and pure impact damage.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Meat Hook Q ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
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
| Ranks | PENDING | Q gates levels 1–10 declared; HUD/point behavior remains PENDING engine verification. |
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

## Slot 2: `enfos_pudge_rot`

Classification: PVE-CONVERT
Native counterpart: `pudge_rot` (installed Ability2).
Decision and PvE identity rationale: retain the toggle damage aura and self-cost while making radius, mana drain, tick and slow data-driven.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Rot W ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
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
| Ranks | PENDING | W gates levels 1–10 declared; HUD/point behavior remains PENDING engine verification. |
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

## Slot 3: `enfos_pudge_flesh_heap`

Classification: PVE-CONVERT
Native counterpart: `pudge_flesh_heap` (installed Ability3).
Decision and PvE identity rationale: preserve kill-based permanent Strength with a bounded stack ceiling and Break-aware defenses.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Flesh Heap E ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
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
| Ranks | PENDING | E gates levels 1–10 declared; HUD/point behavior remains PENDING engine verification. |
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

## Slot 4: `enfos_pudge_dismember`

Classification: PVE-CONVERT
Native counterpart: `pudge_dismember` (installed Ability6).
Decision and PvE identity rationale: keep the channel, damage and sustain identity while preventing boss stun from exceeding its configured cap.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Dismember R ranks 1–10 are KV-gated at levels 5, 10, …, 50; ultimate UI and point behavior remain PENDING.
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
| Ranks | PENDING | R gates levels 5–50 in five-level steps declared; ultimate HUD/point behavior remains PENDING. |
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

## Slot 5: `enfos_pudge_meat_shield`

Classification: PVE-CONVERT
Native counterpart: `pudge_innate_graft_flesh` (installed Ability5).
Decision and PvE identity rationale: adapt Pudge's flesh-based innate identity into Enfos toughness and a bounded damage-triggered pulse; Enfos slot remains distinct from Dota innate metadata.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve; free rank / point cost: ten ranks are defined; the Enfos passive rank 1 grant is separate from Dota innate metadata, ranks 2–10 are KV-gated at levels 2–10; in-engine point behavior remains pending.
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
| Ranks | PENDING | Separate passive rank 1 grant retained; ranks 2–10 gates declared; in-game HUD/point behavior remains PENDING. |
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

2026-09-30 level-cap integration: all five Pudge abilities now declare KV rank gates. Q/W/E and the Enfos passive use one rank per level; passive rank 1 remains a separate Enfos grant. Dismember ranks 1–10 unlock on levels 5, 10, …, 50. Static KV contract passes; actual rank buttons, level-up points, ultimate badge and match-start level 6 remain PENDING for owner testing.

2026-09-30 follow-up audit: Flesh Heap's strength/block and kill-stack callbacks
and Meat Shield's resistance/health/burst callbacks now suppress illusion owners.
Their KV entries declare `IsBreakable 1`, matching existing `PassivesDisabled`
checks. Meat Shield's physical burst search now includes magic-immune enemies.
Mock tests cover illusion suppression and the physical target flag; the real
engine's passive/Break, damage and immunity behavior remains pending.
