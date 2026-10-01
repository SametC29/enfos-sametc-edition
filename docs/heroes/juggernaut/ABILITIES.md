# Juggernaut: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_juggernaut`; role: Fighter. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_juggernaut_blade_fury` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET \| DOTA_ABILITY_BEHAVIOR_IMMEDIATE \| DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL | abilities/pve_kits | juggernaut_blade_fury |
| 2 | `enfos_juggernaut_healing_ward` | 10 | DOTA_ABILITY_BEHAVIOR_POINT | abilities/pve_kits | juggernaut_healing_ward |
| 3 | `enfos_juggernaut_blade_dance` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | juggernaut_blade_dance |
| 4 | `enfos_juggernaut_omni_slash` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET \| DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK | abilities/pve_kits | juggernaut_omni_slash |
| 5 | `enfos_juggernaut_duelist` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | juggernaut_swift_slash |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_juggernaut.txt`; status: FILE_VERIFIED; SHA256: `00260da4289144a9cda71ff0fceffddde5df7d2f86c9edb063fbd5dbafc02469`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/juggernaut/juggernaut.vmdl` |
| SoundSet | `Hero_Juggernaut` |
| Ability1 | `juggernaut_blade_fury` |
| Ability2 | `juggernaut_healing_ward` |
| Ability3 | `juggernaut_blade_dance` |
| Ability4 | `juggernaut_swift_slash` |
| Ability5 | `juggernaut_bladeform` |
| Ability6 | `juggernaut_omni_slash` |
| Ability10 | `special_bonus_unique_juggernaut_5` |
| Ability11 | `special_bonus_unique_juggernaut_3` |
| Ability12 | `special_bonus_unique_juggernaut_omnislash_cooldown` |
| Ability13 | `special_bonus_unique_juggernaut_blade_fury_movespeed` |
| Ability14 | `special_bonus_unique_juggernaut_4` |
| Ability15 | `special_bonus_unique_juggernaut` |
| Ability16 | `special_bonus_unique_juggernaut_omnislash_duration` |
| Ability17 | `special_bonus_unique_juggernaut_blade_dance_lifesteal` |
| AttributeStrengthGain | `2.0000` |
| AttributeAgilityGain | `2.800000` |
| AttributeIntelligenceGain | `1.400000` |

### Per-ability review leads

- `enfos_juggernaut_blade_fury`: cast/impact/modifier contract and lifetime.
- `enfos_juggernaut_healing_ward`: world position, travel/impact timing and radius alignment.
- `enfos_juggernaut_blade_dance`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `enfos_juggernaut_omni_slash`: target flags, immunity, spell block/reflect if applicable, target loss; ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_juggernaut_duelist`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

### Pilot review and special-value / passive correction — 2026-09-29

The installed ClientVersion 6941 source snapshot identifies Juggernaut's
native Q/W/E/R as `juggernaut_blade_fury`, `juggernaut_healing_ward`,
`juggernaut_blade_dance`, and `juggernaut_omni_slash`. Their Enfos versions are
PVE-CONVERT and retain the spin, healing, critical-strike, and slash identities
with wave-focused behavior. Lua-read values are now stored in named
`AbilityValues` for all five slots; the existing numeric curves and explicit
ranks did not change. After the Lina, Wraith King, Juggernaut and Drow pilots,
the global static audit reports 157 of 200 abilities still reading legacy-only
values.

The fifth-slot tooltip already promised rank-scaled passive attack speed and
movement speed, but its intrinsic modifier only listened for kills and granted
neither stat. The modifier now declares both properties and reads the existing
rank values; both return zero while passives are disabled, and the ability is
marked breakable. Its existing short kill-streak buff is retained. The
fifth-slot native identity comparison and shard interaction still need review.
Automated checks pass; actual values, Break, kill-stack refresh, VFX/SFX, healing
ward cleanup, Omni Slash target loss and boss behavior remain engine tests.
All five slots now expose ten ranks with level-50 KV gates; point allocation and HUD behavior remain pending owner engine verification.

Follow-up review (2026-09-30): all five custom slots now expose ten KV ranks.
Q/W/E/R curves and mana are explicit; the fifth Enfos passive has ten ranks.
The Dota KV `Innate` marker has been removed from `enfos_juggernaut_duelist`;
`heroes/innates.lua` is the only path that grants its free Enfos rank. The
gameplay HUD and rank-up flow still require engine acceptance.
This establishes data rank capacity only: hero level cap, point grants, free
passive ranks, and unlock schedule still require separate progression-system
implementation and in-game acceptance. Native cast behavior flags and cast
animations were checked against the installed ClientVersion 6941 source. W's
native cast event is confirmed; Q/R sound event names were not proven from the
compiled sound bank and remain pending. These checks do not certify runtime.

Follow-up static audit (2026-09-30): removed the unused `scepter_damage_amp_pct`
AbilityValue. Juggernaut's Scepter damage amplification and ultimate cooldown
reduction come from the shared `modifier_enfos_scepter_upgrade` in
`heroes/aghanim_manager.lua`; Omni Slash does not need a duplicate local value.
The tooltip reflects the shared system. Runtime Scepter behavior remains pending.

Follow-up review (2026-09-29): Duelist kill-stack cap, duration, bonuses and
full-stack healing are now read from KV rather than Lua literals; tooltip text
now explains both its base stats and kill streak. Blade Fury movement speed is
also data-driven. Healing Ward's invisible ground thinker now carries the
verified `juggernaut_healing_ward.vpcf` particle from the installed resource
snapshot; visual placement/scale and model/audio still require in-game checks.

## Slot 1: `enfos_juggernaut_blade_fury`

Classification: PVE-CONVERT
Native counterpart: `juggernaut_blade_fury` (installed ClientVersion 6941 source snapshot).
Decision and PvE identity rationale: Preserve the spinning damage window; adapt its target coverage and control-resistance behavior for PvE waves.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Blade Fury Q ranks 1–10 are KV-gated at levels 1–10; engine rank UI/point behavior remains PENDING.
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
| Ranks | PENDING | Q gate levels 1–10 are declared; in-game HUD and point behavior remain PENDING. |
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

## Slot 2: `enfos_juggernaut_healing_ward`

Classification: PVE-CONVERT
Native counterpart: `juggernaut_healing_ward` (installed ClientVersion 6941 source snapshot).
Decision and PvE identity rationale: Preserve the healing-ward sustain role while using a bounded ground aura compatible with the team's wave lanes.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Healing Ward W ranks 1–10 are KV-gated at levels 1–10; engine rank UI/point behavior remains PENDING.
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
| Ranks | PENDING | W gate levels 1–10 are declared; in-game HUD and point behavior remain PENDING. |
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

## Slot 3: `enfos_juggernaut_blade_dance`

Classification: PVE-CONVERT
Native counterpart: `juggernaut_blade_dance` (installed ClientVersion 6941 source snapshot).
Decision and PvE identity rationale: Preserve the signature critical passive and add bounded splash so it contributes to wave clear.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Blade Dance E ranks 1–10 are KV-gated at levels 1–10; engine rank UI/point behavior remains PENDING.
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
| Ranks | PENDING | E gate levels 1–10 are declared; in-game HUD and point behavior remain PENDING. |
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

## Slot 4: `enfos_juggernaut_omni_slash`

Classification: PVE-CONVERT
Native counterpart: `juggernaut_omni_slash` (installed ClientVersion 6941 source snapshot).
Decision and PvE identity rationale: Preserve the rapid target-to-target slash sequence while defining PvE target selection and boss-safe lifetime.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Omni Slash R ranks 1–10 are KV-gated at levels 5, 10, …, 50; engine ultimate UI/point behavior remains PENDING.
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
| Ranks | PENDING | R gate levels 5–50 in five-level steps is declared; ultimate HUD and point behavior remain PENDING. |
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

## Slot 5: `enfos_juggernaut_duelist`

Classification: REPLACE
Native counterpart: The installed hero definition has `juggernaut_bladeform` as Ability5; the same source also defines the separate innate `juggernaut_duelist` (Face to Face, 55-degree front angle, 12% damage bonus) and facet `juggernaut_bladeform`. The Enfos ID is a project-specific kill-stack passive and is not an alias for either native ability.
Decision and PvE identity rationale: Keep the Enfos fifth slot explicitly separate from Dota's innate system; this slot replaces its gameplay content with an agile kill-momentum passive while preserving Juggernaut's duelist identity. No native innate mechanic is silently claimed as implemented.
Expected cast/travel/impact/ongoing/cleanup behavior: Intrinsic stats apply continuously; kills grant bounded timed stacks; stack expiry and death cleanup remain engine-pending.
Normal creep / elite / boss, immunity / dispel / resistance rules: Kill event excludes allied units and is disabled by Break; boss kill-credit behavior remains pending.
Current versus target rank curve; free rank / point cost: Enfos passive rank 1 is granted separately; ranks 2–10 are KV-gated at levels 2–10; point behavior remains PENDING engine validation.
Shard / Scepter / Blessing / Evolution / Ascended interactions: generic class upgrades apply; passive-specific interactions remain pending.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: `scripts/npc/heroes/npc_dota_hero_juggernaut.txt`, ClientVersion 6941 / SourceRevision 11041083, SHA256 `00260da4289144a9cda71ff0fceffddde5df7d2f86c9edb063fbd5dbafc02469`; native slot and innate definitions recorded above.
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
| Ranks | PENDING | The separately granted passive rank 1 is retained; ranks 2–10 gates are declared; in-game HUD and point behavior remain PENDING. |
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

2026-09-30 level-cap integration: all five Juggernaut abilities now declare KV rank gates. Q/W/E and the Enfos passive use one rank per level; passive rank 1 remains a separate Enfos grant. Omni Slash ranks 1–10 unlock on levels 5, 10, …, 50. Static KV contract passes; actual rank buttons, level-up points, ultimate badge and match-start level 6 remain PENDING for owner testing.
