# Dazzle: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_dazzle`; role: Support. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_dazzle_poison_touch` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | dazzle_poison_touch |
| 2 | `enfos_dazzle_shallow_grave` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/pve_kits | dazzle_shallow_grave |
| 3 | `enfos_dazzle_shadow_wave` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/pve_kits | dazzle_shadow_wave |
| 4 | `enfos_dazzle_bad_juju` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | dazzle_bad_juju |
| 5 | `enfos_dazzle_nothl_weave` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | dazzle_weave |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_dazzle.txt`; status: FILE_VERIFIED; SHA256: `63068fe4bb9160f4f325ed30aa675a3506f8a6c4396cb7fc2fee3a7ce595a8b0`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/dazzle/dazzle.vmdl` |
| SoundSet | `Hero_Dazzle` |
| Ability1 | `dazzle_poison_touch` |
| Ability2 | `dazzle_shallow_grave` |
| Ability3 | `dazzle_shadow_wave` |
| Ability4 | `dazzle_innate_weave` |
| Ability5 | `generic_hidden` |
| Ability6 | `dazzle_nothl_projection` |
| Ability7 | `dazzle_nothl_projection_end` |
| Ability10 | `special_bonus_unique_dazzle_poison_touch_attack_range_bonus` |
| Ability11 | `special_bonus_mp_regen_175` |
| Ability12 | `special_bonus_unique_dazzle_2` |
| Ability13 | `special_bonus_unique_dazzle_nothl_projection_duration` |
| Ability14 | `special_bonus_unique_dazzle_shallow_grave_cooldown` |
| Ability15 | `special_bonus_unique_dazzle_3` |
| Ability16 | `special_bonus_unique_dazzle_1` |
| Ability17 | `special_bonus_unique_dazzle_4` |
| AttributeStrengthGain | `2.3` |
| AttributeAgilityGain | `1.7` |
| AttributeIntelligenceGain | `3.5` |

### Per-ability review leads

- `enfos_dazzle_poison_touch`: cast/impact/modifier contract and lifetime.
- `enfos_dazzle_shallow_grave`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_dazzle_shadow_wave`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_dazzle_bad_juju`: ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_dazzle_nothl_weave`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

Static regression evidence (2026-09-30): existing mock-engine checks cover Poison Touch attack-owned slow ramp, Shadow Wave's healing/damage/Weave initialization, and Break suppression. Added checks cover Shallow Grave's 1-health floor and configured heal amplification, plus Bad Juju's configured current-health cost, ally/enemy area modifiers and cooldown reduction on a different ability. These tests establish mocked Lua wiring only; all in-game behavior, visuals, audio, rank/HUD presentation, and VConsole checks remain PENDING for the user.

## Slot 1: `enfos_dazzle_poison_touch`

Classification: PVE-CONVERT
Native counterpart: `dazzle_poison_touch`, verified in the installed hero KV above. Keeps poison damage-over-time and attack-refreshing slow, with a bounded wave-target implementation. Lua-read values moved to `AbilityValues`; duration is now read from KV.
Decision and PvE identity rationale: Preserve the poison/attack-refresh identity. The current radial target pattern differs from the native cone/projectile and remains a visual/gameplay fidelity review item.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Poison Touch Q ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
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
| Localization | PENDING | EN/TR/RU/zh-CN now read the target cap, radius, Intelligence coefficient and base slow from KV tokens; in-game rendering remains unverified. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-29, static localization follow-up 2026-09-30): fixed Poison Touch attack stacking so only Dazzle's own landed attacks refresh the debuff and raise its configured slow. Radius, target cap, damage scaling, slow, per-attack increment and cap are KV-driven. EN/TR/RU/zh-CN descriptions now use KV tokens for target cap, radius, Intelligence coefficient and slow rather than duplicated constants. Regression verifies another ally cannot trigger the ramp. Installed native snapshot confirms Poison Touch identity; its physical damage type is retained. In-engine projectile/cone/VFX/SFX, boss and dispel acceptance remain PENDING.

## Slot 2: `enfos_dazzle_shallow_grave`

Classification: PVE-CONVERT
Native counterpart: `dazzle_shallow_grave`, verified in the installed hero KV above. Retains the ally's lethal-damage prevention and healing amplification; duration moved to `AbilityValues` unchanged.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Shallow Grave W ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
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

Change/test record (2026-09-29): Shallow Grave heal amplification is configured in KV and the tooltip now includes it. Engine save behavior, healing interactions, effects/audio and boss behavior remain PENDING.

## Slot 3: `enfos_dazzle_shadow_wave`

Classification: PVE-CONVERT
Native counterpart: `dazzle_shadow_wave`, verified in the installed hero KV above. Keeps chained ally healing and nearby enemy damage. `damage_radius` is now read from KV; all values moved to `AbilityValues` unchanged.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Shadow Wave E ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
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
| Gameplay | PENDING | Regression confirms Shadow Wave's first Weave application initializes one armor stack; heal scaling, bounce cap/range and damage radius now use KV. Live chain visuals/timing remain unverified. |
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
| Localization | PENDING | Shadow Wave and Nothl Weave now have complete EN/TR/RU/zh-CN titles and descriptions; UI rendering remains unverified. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: mock coverage remains as recorded below; engine cast visuals/audio, chain behavior and boss interactions remain PENDING.

## Slot 4: `enfos_dazzle_bad_juju`

Classification: REPLACE
Native counterpart: None in the current installed kit: native ultimate is `dazzle_nothl_projection`. Enfos retains the historical Bad Juju identity as a custom PvE cooldown/buff/debuff effect.
Decision and PvE identity rationale: Keep the legacy Dazzle theme within this Enfos kit. Current custom use applies an area armor swing and cooldown reduction; engine targeting, timing and boss balance remain pending.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Bad Juju R ranks 1–10 are KV-gated at levels 5, 10, …, 50; ultimate UI and point behavior remain PENDING.
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

Change/test record (2026-09-29): moved health cost, effect duration, armor values and cooldown reduction to KV-backed behavior and updated localized tooltip. Engine cost/death edge cases, effects/audio, boss handling and cooldown verification remain PENDING.

## Slot 5: `enfos_dazzle_nothl_weave`

Classification: PVE-CONVERT
Native counterpart: `dazzle_innate_weave`, verified by the current official Dota 2 hero page and installed native hero KV. Replaced the project-wide timed aura with per-ability Weave stacks on allies affected and enemies hit, matching the native trigger identity. The configured armor change, stack cap and duration now drive the effect.
Decision and PvE identity rationale: Preserve Weave's ally-armor/enemy-armor identity and Enfos values while applying it to the actual recipients of Q/W/E/R rather than unrelated nearby units.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: The Enfos passive rank 1 is granted separately; ranks 2–10 are KV-gated at levels 2–10; engine point/UI behavior remains PENDING.
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
| Gameplay | PENDING | A new stack now initializes at one; regression verifies the first stack grants its configured armor instead of zero. Refresh cap and runtime behavior still need Dota validation. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | The separate passive rank 1 grant remains; ranks 2–10 gates are declared; in-game HUD and point behavior remain PENDING. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | Shadow Wave and Nothl Weave now have complete EN/TR/RU/zh-CN titles and descriptions; UI rendering remains unverified. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): all five Enfos slots declare ten ranks, scaling Poison Touch damage, Grave duration, Shadow Wave healing, Bad Juju cooldown reduction, and Nothl Weave armor. Enfos Nothl Weave is separate from Dota Innate and now respects Break; Bad Juju's passive cooldown trigger also respects Break. Grave and Shadow Wave validate friendly targets; Poison Touch and Shallow Grave validate their caster/targets. Weave and Bad Juju modifiers use verified friend/enemy armor particles. Five Dazzle assets were added to precache/VPK verification, and the passive tooltip calls out Break. Current mock suite now covers Poison Touch ramp, Grave's lethal floor/heal amplification, Shadow Wave bounce/heal/damage and Weave, Bad Juju health cost/cooldown reduction, and passive Break suppression. Dota/VConsole, native Poison Touch cone fidelity, boss balance, full audio/visual acceptance and point/unlock schedule remain PENDING for user testing.

2026-09-30 level-cap integration: all five Dazzle abilities now declare KV rank gates. Q/W/E and the Enfos passive use one rank per level; passive rank 1 remains a separate Enfos grant. Bad Juju ranks 1–10 unlock on levels 5, 10, …, 50. Static KV contract passes; actual rank buttons, level-up points, ultimate badge and match-start level 6 remain PENDING for owner testing.
