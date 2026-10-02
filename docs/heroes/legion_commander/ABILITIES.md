# Legion Commander: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_legion_commander`; role: Fighter. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_legion_overwhelming_odds` | 10 | DOTA_ABILITY_BEHAVIOR_POINT \| DOTA_ABILITY_BEHAVIOR_AOE | abilities/pve_kits | legion_commander_overwhelming_odds |
| 2 | `enfos_legion_press_the_attack` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/pve_kits | legion_commander_press_the_attack |
| 3 | `enfos_legion_moment_of_courage` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | legion_commander_moment_of_courage |
| 4 | `enfos_legion_duel` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/pve_kits | legion_commander_duel |
| 5 | `enfos_legion_commanders_banner` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | legion_commander_press_the_attack |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_legion_commander.txt`; status: FILE_VERIFIED; SHA256: `07961ff69f2c14b83212b33e8f8013b012c9cf26245d6c01f804b0b81f66644b`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/legion_commander/legion_commander.vmdl` |
| SoundSet | `Hero_LegionCommander` |
| Ability1 | `legion_commander_overwhelming_odds` |
| Ability2 | `legion_commander_press_the_attack` |
| Ability3 | `legion_commander_moment_of_courage` |
| Ability4 | `legion_commander_outfight_them` |
| Ability5 | `generic_hidden` |
| Ability6 | `legion_commander_duel` |
| Ability10 | `special_bonus_unique_legion_commander_9` |
| Ability11 | `special_bonus_unique_legion_commander_outfight_them_armor` |
| Ability12 | `special_bonus_unique_legion_commander_6` |
| Ability13 | `special_bonus_unique_legion_commander_4` |
| Ability14 | `special_bonus_unique_legion_commander_duel_duration` |
| Ability15 | `special_bonus_unique_legion_commander_3` |
| Ability16 | `special_bonus_unique_legion_commander_7` |
| Ability17 | `special_bonus_unique_legion_commander_duel_refresh_on_victory` |
| AttributeStrengthGain | `3.000000` |
| AttributeAgilityGain | `1.700000` |
| AttributeIntelligenceGain | `2.200000` |

### Per-ability review leads

- `enfos_legion_overwhelming_odds`: world position, travel/impact timing and radius alignment.
- `enfos_legion_press_the_attack`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_legion_moment_of_courage`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `enfos_legion_duel`: target flags, immunity, spell block/reflect if applicable, target loss; ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_legion_commanders_banner`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

## Slot 1: `enfos_legion_overwhelming_odds`

Classification: PVE-CONVERT
Native counterpart: `legion_commander_overwhelming_odds`, verified in the installed hero KV above. Keeps the area strike while adapting damage and post-cast speed to wave density. All Lua-read values moved to `AbilityValues` unchanged.
Decision and PvE identity rationale: Retain the area strike identity; keep current creep/boss count scaling pending live balance verification.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Overwhelming Odds Q ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: PENDING.
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: Native `legion_commander_odds.vpcf` is present in the installed build snapshot and precached. Static review found it was parented to the caster although damage uses the cursor point; it now spawns at the cursor world position. Particle CP semantics and in-game appearance remain PENDING.
- Sound events + declaring banks + emission target + loop termination: PENDING.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: PENDING.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated mirrors: PENDING.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Mock regression confirms configured damage scaling and speed buff by enemy count; Dota target/radius and rank behavior remain unverified. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Q gate levels 1–10 declared; HUD and point behavior remain PENDING. |
| VFX | PENDING | Particle source is present and precached; cursor-point placement fixed by static review. Visual appearance still requires Dota capture. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | EN/TR/RU/zh-CN descriptions now reflect count scaling and the speed buff; generated mirrors/checks pass. In-game wrapping and special-value rendering remain unverified. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

2026-10-02 individual Q follow-up: installed build6943 compared directly. Count-based AS/MS now refresh on recast and use explicit server-to-client modifier transmission instead of client fallback constants. Independent regression reproduces the missing refresh and checks a separate client instance.233 hero behavior regressions/full checks pass. See [individual ledger](../../audit/LEGION_COMMANDER_INDIVIDUAL_REVIEW_2026-10-02.md) for native deviations and owner runtime gates. Actual networking, visuals/audio and VConsole remain PENDING; this entry updates Q source acceptance only.

## Slot 2: `enfos_legion_press_the_attack`

Classification: PVE-CONVERT
Native counterpart: `legion_commander_press_the_attack`, verified in the installed hero KV above. Keeps the friendly dispel and attack-speed/sustain buff for PvE allies. Lua-read values moved to `AbilityValues` unchanged.
Decision and PvE identity rationale: Preserve the support buff identity; target restrictions and dispel behavior need engine acceptance.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Press the Attack W ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: PENDING.
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: Cast particle is present in installed build snapshot and precached; buff attachment/appearance remains PENDING.
- Sound events + declaring banks + emission target + loop termination: PENDING.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: PENDING.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated mirrors: PENDING.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Mock regression verifies a living ally receives the requested debuff/stun purge and timed buff, while enemy targets are rejected; Dota target filtering and engine purge behavior remain unverified. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | W gate levels 1–10 declared; HUD and point behavior remain PENDING. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | EN/TR/RU/zh-CN descriptions now expose duration, attack speed, flat regen and Strength scaling; generated mirrors/checks pass. In-game display remains unverified. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 3: `enfos_legion_moment_of_courage`

Classification: PVE-CONVERT
Native counterpart: `legion_commander_moment_of_courage`, verified in the installed hero KV above. Keeps the reactive counterattack; adds healing and a boss proc interval for wave combat. Trigger chance moved to `AbilityValues` unchanged.
Decision and PvE identity rationale: Preserve the counterattack identity and current sustain adaptation; recursive proc and Break handling remain engine-review items.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Moment of Courage E ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
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
| Gameplay | PENDING | Mock covers Break and allied-attacker rejection. Counterattack lifesteal now requires attack-category damage to its tracked target; unrelated proc and spell damage are excluded. Dota event ordering, chance behavior and boss interval remain unverified. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | E gate levels 1–10 declared; HUD and point behavior remain PENDING. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | EN/TR/RU/zh-CN descriptions now state proc chance, proc heal and boss interval; generated mirrors/checks pass. In-game display remains unverified. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): added a mock regression proving only the counterattack's attack-category damage to its tracked target contributes to Moment of Courage lifesteal. Secondary proc damage and spell-category damage are excluded. In-game event order, attack result and boss behavior remain PENDING owner verification; this mock is not ENGINE_PASS.

## Slot 4: `enfos_legion_duel`

Classification: PVE-CONVERT
Native counterpart: `legion_commander_duel`, verified as native Ability6 in the installed hero KV above. Retains Duel's focused restriction window; current Enfos version supports wave targets and grants permanent Strength on a victory, with bosses currently worth more.
Decision and PvE identity rationale: Keep the recognizable Duel interaction; boss duration/control and reward need live balance verification. Duration moved to `AbilityValues` unchanged.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Duel R ranks 1–10 are KV-gated at levels 5, 10, …, 50; ultimate UI and point behavior remain PENDING.
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
| Gameplay | PENDING | Mock/static checks cover configured duel duration/reward and outside-duel damage reduction; duel target state and boss behavior remain unverified in Dota. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | R gate levels 5–50 in five-level steps declared; ultimate HUD and point behavior remain PENDING. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | EN/TR/RU/zh-CN descriptions now state duration, reduction and permanent Strength rewards; generated mirrors/checks pass. In-game display remains unverified. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 5: `enfos_legion_commanders_banner`

Classification: REPLACE
Native counterpart: None. `legion_commander_outfight_them` is the separate native innate and must not be conflated with this Enfos passive.
Decision and PvE identity rationale: Preserve the Enfos-only banner aura as the custom fifth-slot passive. The configured 20% bonus damage was previously ignored by Lua's hardcoded 20/40 values; Lua now reads the configured amount for allies and doubles it for Legion. The value moved to `AbilityValues` unchanged.
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
| Gameplay | PENDING | Regression verifies owner/ally damage values and attack-only lifesteal; live aura radius, Break, respawn and modifier refresh remain unverified. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Separate passive rank 1 grant retained; ranks 2–10 gates declared; in-game HUD and point behavior remain PENDING. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | EN/TR/RU/zh-CN descriptions now distinguish owner/ally damage and attack lifesteal; generated mirrors/checks pass. In-game display remains unverified. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-29): moved all five Legion Lua-read KV value blocks to `AbilityValues` with all current values and rank counts preserved. Fixed Commander's Banner to read its configured 20% ally bonus (Legion receives twice that value); added a regression checking both owner and ally values. Static review and automated checks pending. Dota/VConsole gameplay, VFX/SFX, modifier, boss and localization acceptance remain PENDING. A mock pass is not ENGINE_PASS.

Change/test record (2026-09-30): all five Legion Enfos slots now have ten ranks, with damage/cooldown/utility curves interpolated from existing endpoints. Commander's Banner is explicitly separate from Dota Innate, has rank scaling and Break support; Moment of Courage also honors Break and ignores ally attacks. Press the Attack validates a living friendly target, and Duel validates enemies, respects spell block, and uses a non-purgable paired state. Regressions cover spell block and Break/friendly attacks; full static and mock checks pass. Engine/VConsole tests, boss control acceptance, SFX and live tooltip presentation remain PENDING.

2026-09-30 level-cap integration: all five Legion Commander abilities now declare KV rank gates. Q/W/E and the Enfos passive use one rank per level; passive rank 1 remains a separate Enfos grant. Duel ranks 1–10 unlock on levels 5, 10, …, 50. Static KV contract passes; actual rank buttons, level-up points, ultimate badge and match-start level 6 remain PENDING for owner testing.

2026-09-30 static regression follow-up: Press the Attack now has direct mock coverage for its friendly-target purge and timed buff, and for rejecting an enemy target. The Dota purge contract, spell-immunity interactions, buff visuals/audio and live gameplay remain PENDING owner testing.

2026-09-30 global Break metadata audit: Added KV `IsBreakable 1` to `enfos_legion_moment_of_courage` because its linked Lua passive implementation check `PassivesDisabled()`. Automated content validation now rejects this metadata mismatch. Actual Dota Break behavior remains PENDING.

2026-10-02 individual Duel follow-up: forced target/orders and matching paired cleanup added; normal/running creep route AI suspends progression during Duel. Either death or expiry releases both sides. Death callbacks in either order grant one existing10normal/30Boss Strength victory only while Legion survives.234 hero behavior regressions and full static/mock checks pass. Detailed root causes/references/owner acceptance are in the [individual ledger](../../audit/LEGION_COMMANDER_INDIVIDUAL_REVIEW_2026-10-02.md). No Dota/VConsole, visual/audio or upgrade acceptance inferred.
