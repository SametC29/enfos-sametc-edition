# Sniper: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_sniper`; role: Carry. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_sniper_shrapnel` | 10 | DOTA_ABILITY_BEHAVIOR_POINT \| DOTA_ABILITY_BEHAVIOR_AOE | abilities/pve_kits | sniper_shrapnel |
| 2 | `enfos_sniper_headshot` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | sniper_headshot |
| 3 | `enfos_sniper_take_aim` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | sniper_take_aim |
| 4 | `enfos_sniper_assassinate` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/pve_kits | sniper_assassinate |
| 5 | `enfos_sniper_keen_eye` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | sniper_take_aim |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_sniper.txt`; status: FILE_VERIFIED; SHA256: `ffa8d1a8132d40f3c48e4a0ff093ee3973dc5b627a9bd370e7273b53afe900db`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/sniper/sniper.vmdl` |
| SoundSet | `Hero_Sniper` |
| Ability1 | `sniper_shrapnel` |
| Ability2 | `sniper_headshot` |
| Ability3 | `sniper_take_aim` |
| Ability4 | `sniper_concussive_grenade` |
| Ability5 | `sniper_keen_scope` |
| Ability6 | `sniper_assassinate` |
| Ability10 | `special_bonus_unique_sniper_5` |
| Ability11 | `special_bonus_unique_sniper_headshot_damage` |
| Ability12 | `special_bonus_unique_sniper_6` |
| Ability13 | `special_bonus_unique_sniper_1` |
| Ability14 | `special_bonus_unique_sniper_4` |
| Ability15 | `special_bonus_unique_sniper_shrapnel_damage` |
| Ability16 | `special_bonus_unique_sniper_2` |
| Ability17 | `special_bonus_unique_sniper_3` |
| AttributeStrengthGain | `2.0000` |
| AttributeAgilityGain | `3.20000` |
| AttributeIntelligenceGain | `2.600000` |

### Per-ability review leads

- `enfos_sniper_shrapnel`: world position, travel/impact timing and radius alignment.
- `enfos_sniper_headshot`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `enfos_sniper_take_aim`: cast/impact/modifier contract and lifetime.
- `enfos_sniper_assassinate`: target flags, immunity, spell block/reflect if applicable, target loss; ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_sniper_keen_eye`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

## Slot 1: `enfos_sniper_shrapnel`

Classification: PVE-CONVERT
Native counterpart: `sniper_shrapnel`, verified in the installed hero KV above. Keeps the area denial identity as a persistent damage/slow field. Lua-read values moved to `AbilityValues` unchanged.
Decision and PvE identity rationale: Preserve the native area-control role; physical damage and current field timing await in-engine balance review.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Shrapnel Q ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: Installed hero identity is documented above from build 6941 / SourceRevision 11041083; runtime parity remains pending.
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: Shrapnel and Assassinate particles are present in the installed snapshot and precached. Assassinate now uses a tracking projectile at speed 3000, based on the linked [Sniper changelog](https://liquipedia.net/dota2/Sniper/Changelogs); local build speed, attachment and appearance remain pending.
- Sound events + declaring banks + emission target + loop termination: PENDING.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: PENDING.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated mirrors: PENDING.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Assassinate now defers damage until a valid tracking-projectile hit; mock regression checks deferred timing and configured damage. Target/radius and rank behavior need Dota verification. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Q gates levels 1–10 declared; HUD/point behavior remains PENDING engine verification. |
| VFX | PENDING | Shrapnel/Assassinate assets are present and precached; Assassinate now uses a tracking visual. Scene appearance, hit location and particle semantics remain pending. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | EN/TR/RU/zh-CN descriptions supplied for all five skills; generated mirrors pass. In-game special rendering remains pending. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 2: `enfos_sniper_headshot`

Classification: PVE-CONVERT
Native counterpart: `sniper_headshot`, verified in the installed hero KV above. Keeps the precision proc and uses custom damage/knockback for PvE. Lua-read values moved to `AbilityValues` unchanged.
Decision and PvE identity rationale: Preserve the recognizable headshot proc; proc chance and knockback behavior remain engine-review items.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Headshot W ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
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
| Gameplay | PENDING | Mock confirms configured base damage + 75% Agility, non-boss knockback, Break suppression and ally rejection. Dota attack-event ordering, illusion behavior and boss feedback remain unverified. |
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
| Localization | PENDING | EN/TR/RU/zh-CN descriptions updated to current behavior; rendered in-game values remain unverified. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): mock regression confirms the configured Headshot base damage plus 75% Agility and the configured non-boss knockback distance. Existing regression also covers Break and allied-target rejection. Dota event ordering, illusion behavior, sound/effect presentation and boss feedback remain PENDING owner testing; mock is not ENGINE_PASS.

## Slot 3: `enfos_sniper_take_aim`

Classification: PVE-CONVERT
Native counterpart: `sniper_take_aim`, verified in the installed hero KV above. Custom active supplements the native long-range identity with temporary True Strike and movement speed. Lua-read values moved to `AbilityValues` unchanged.
Decision and PvE identity rationale: Keep long-range precision while making an active PvE cooldown; tooltip/rank interaction needs live review.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Take Aim E ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
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
| Gameplay | PENDING | Take Aim movement speed now reads KV; native range and active True Strike behavior remain unverified. |
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
| Localization | PENDING | EN/TR/RU/zh-CN descriptions updated to current behavior; rendered in-game values remain unverified. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 4: `enfos_sniper_assassinate`

Classification: PVE-CONVERT
Native counterpart: `sniper_assassinate`, verified as native Ability6 in the installed hero KV above. Keeps the long-range focused finisher and a cooldown refund on kill. Lua-read values moved to `AbilityValues` unchanged.
Decision and PvE identity rationale: Preserve the finisher identity with impact-time damage from a tracking projectile. Mock tests cover deferred hit damage and spell block; projectile dodge, target loss and live timing remain runtime review items.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Assassinate R ranks 1–10 are KV-gated at levels 5, 10, …, 50; ultimate UI and point behavior remain PENDING.
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
| Gameplay | PENDING | Mocks verify projectile hit damage is deferred until impact and spell block prevents launch; dodge, target loss, kill refund and boss behavior remain unverified. |
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
| Localization | PENDING | EN/TR/RU/zh-CN descriptions updated to current behavior; rendered in-game values remain unverified. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 5: `enfos_sniper_keen_eye`

Classification: REPLACE
Native counterpart: None. Native `sniper_keen_scope` is a different innate and must not be conflated with this Enfos-only piercing passive.
Decision and PvE identity rationale: Preserve this custom fifth-slot passive, separate from Dota's innate. It reads configured damage percentage and uses a forward lane bounded by configured distance, width and maximum target count; magic-immune enemies are included in the search because the proc deals physical damage. All Lua-read values are data-driven in `AbilityValues`.
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
| Gameplay | PENDING | Mock regression verifies configured physical damage, forward-lane filtering, nearest-target cap, and illusion suppression; Dota magic-immunity interaction and boss behavior remain unverified. |
| Targeting | PENDING | Static lane is 550 units long and 300 wide, capped at 3 secondary targets; confirm actual unit-query semantics in Dota. |
| Ranks | PENDING | Separate passive rank 1 grant retained; ranks 2–10 gates declared; in-game HUD/point behavior remains PENDING. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | EN/TR/RU/zh-CN descriptions updated to current behavior; rendered in-game values remain unverified. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): all five Enfos slots declare ten ranks with interpolated damage/range/cooldown curves; Keen Eye is explicitly separate from Dota Innate. Keen Eye now uses a configurable forward lane, selects the nearest three eligible enemies, suppresses Break/illusion sources, and includes magic-immune enemies in its query; mock coverage checks lane, cap, damage, allies and illusion behavior. Headshot and Keen Eye honor Break; Take Aim's passive range honors Break while its active buff remains active and shows Valve's verified overhead effect. Knockback uses clear-space placement when available. Assassinate validates caster/target at cast and impact and adds the verified impact-sparks particle. Regression coverage checks Break and positive Headshot damage/knockback. The current suite covers 200 abilities / 223 modifiers; full static checks pass. Dota/VConsole, projectile appearance/audio, boss balance and point/unlock schedule remain PENDING.

2026-09-30 level-cap integration: all five Sniper abilities now declare KV rank gates. Q/W/E and the Enfos passive use one rank per level; passive rank 1 remains a separate Enfos grant. Assassinate ranks 1–10 unlock on levels 5, 10, …, 50. Static KV contract passes; actual rank buttons, level-up points, ultimate badge and match-start level 6 remain PENDING for owner testing.

2026-09-30 static regression follow-up: Assassinate now has direct mock coverage that spell block cancels projectile launch and impact damage. Dota spell-absorb timing, projectile dodge/loss, kill refund, VFX/SFX and boss behavior remain PENDING owner testing.

2026-09-30 global Break metadata audit: Added KV `IsBreakable 1` to `enfos_sniper_headshot` because its linked Lua passive implementation check `PassivesDisabled()`. Automated content validation now rejects this metadata mismatch. Actual Dota Break behavior remains PENDING.

2026-10-02 individual review started against installed6943. Keen Eye now retains piercing from a valid primary killed by the landed attack; existing lane/cap/Break/illusion rules remain. Regression fails before repair and passes afterward. The [individual ledger](../../audit/SNIPER_INDIVIDUAL_REVIEW_2026-10-02.md) tracks current comparisons, source repairs and pending owner engine gates; this is not whole-hero or Dota runtime acceptance.

2026-10-02 Shrapnel follow-up: continuous native field now belongs to its thinker modifier, with verified ground CP0/CP2 and configured radius CP1. Existing eight-second duration/three-entity bound retained.239behavior regressions/full checks pass; real circle appearance, child expiry, sound and VConsole PENDING owner testing.
