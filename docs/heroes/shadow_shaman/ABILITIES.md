# Shadow Shaman: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_shadow_shaman`; role: Support. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_ss_ether_shock` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/pve_kits | shadow_shaman_ether_shock |
| 2 | `enfos_ss_hex` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/pve_kits | shadow_shaman_voodoo |
| 3 | `enfos_ss_shackles` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET \| DOTA_ABILITY_BEHAVIOR_CHANNELLED | abilities/pve_kits | shadow_shaman_shackles |
| 4 | `enfos_ss_mass_serpent_ward` | 10 | DOTA_ABILITY_BEHAVIOR_POINT | abilities/pve_kits | shadow_shaman_mass_serpent_ward |
| 5 | `enfos_ss_fowl_play` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | shadow_shaman_fowl_play |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_shadow_shaman.txt`; status: FILE_VERIFIED; SHA256: `762dfd6468712a21ed5c0e8bb16b23580e7da8edbbf35f5f0654313b143a4539`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/shadowshaman/shadowshaman.vmdl` |
| SoundSet | `Hero_ShadowShaman` |
| Ability1 | `shadow_shaman_ether_shock` |
| Ability2 | `shadow_shaman_voodoo` |
| Ability3 | `shadow_shaman_shackles` |
| Ability4 | `shadow_shaman_fowl_play` |
| Ability5 | `shadow_shaman_urnaconda` |
| Ability6 | `shadow_shaman_mass_serpent_ward` |
| Ability10 | `special_bonus_unique_shadow_shaman_6` |
| Ability11 | `special_bonus_mp_regen_175` |
| Ability12 | `special_bonus_unique_shadow_shaman_8` |
| Ability13 | `special_bonus_unique_shadow_shaman_7` |
| Ability14 | `special_bonus_unique_shadow_shaman_2` |
| Ability15 | `special_bonus_unique_shadow_shaman_1` |
| Ability16 | `special_bonus_unique_shadow_shaman_3` |
| Ability17 | `special_bonus_unique_shadow_shaman_4` |
| AttributeStrengthGain | `2.300000` |
| AttributeAgilityGain | `1.600000` |
| AttributeIntelligenceGain | `3.300000` |

### Per-ability review leads

- `enfos_ss_ether_shock`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_ss_hex`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_ss_shackles`: channel tick, interrupt, looping audio and thinker expiry; target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_ss_mass_serpent_ward`: world position, travel/impact timing and radius alignment; ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_ss_fowl_play`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-09-30 static special-value repair: migrated all five abilities' KV special values to named `AbilityValues`, retaining the authored rank curves. This corrects the same project-specific value-loading risk confirmed for Sven; Shadow Shaman has not been Dota-tested. Follow-up review compared Fowl Play's implementation and localized tooltip: it prevents a lethal hit and grants movement speed, with no shield behavior. The unused `shield_hp` KV field was removed rather than implying a shield that the game does not provide. The user owns live gameplay, audio and VFX checks.

Follow-up static repair (2026-09-30): Fowl Play's minimum-health property no longer starts its cooldown as a side effect of a property query. It now retains the 1 HP floor while ready and only spends the save/grants its move-speed buff after a damage event leaves the hero at 1 HP. Mock regression passes; Dota event ordering and live behavior remain pending.

Follow-up static repairs (2026-09-30): Shackles now uses the same 35% boss duration for both its stun/channel and ends its channel if the target dies or becomes invalid. Mass Serpent Ward explicitly applies the shared 40% Scepter bonus to the summoned wards' physical attack damage, which spell amplification cannot provide to ordinary unit attacks; the existing shared ultimate cooldown reduction still applies. Ether Shock and Shackles tooltips now reference current KV values and explain the implemented damage/healing behavior in EN/TR/RU/zh-CN. Targeted mock regressions pass. Runtime channel ordering, ward attacks, Scepter/Blessing state, VFX/SFX and boss interaction remain pending the owner's Dota test.

## Slot 1: `enfos_ss_ether_shock`

Classification: PVE-CONVERT
Native counterpart: `shadow_shaman_ether_shock` (installed native snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot mapping is authored).
Decision and PvE identity rationale: PVE-CONVERT preserves the identified Dota hero fantasy while changing PvP-only targeting/control for wave, elite and boss play.
Expected cast/travel/impact/ongoing/cleanup behavior: source-reviewed2026-10-02; instant magical hit, cursor target first, then bounded unique secondary enemies in its600radius. Native finite beam binds caster attack1/CP0 and recipient origin/modelCP1 before lethal damage callbacks; each one-shot index released. Source/ability deletion ends remaining hits. Dota geometry/audio and cold start PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: no Elite spawns. Hero/basic enemy KV, ENEMIES_NO immunity, primary TriggerSpellAbsorb consumes cast before effects; radius query uses FLAG_NONE. Boss raw damage capped at6%maxHP before mitigation. Actual immunity/absorb interaction and source-death callback ordering PENDING owner.
Current/target rank: each Enfos slot has ten explicit KV levels. The match is capped at level 50; Q/W/E/R require 40 paid ranks total and passive ranks 2–10 require nine more; the fifth slot rank 1 is free, for 49 spendable points overall. Rank-up HUD/runtime acceptance remains pending.
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
| Ranks | PENDING | Q levels 1–10 gates declared; HUD/point behavior remains PENDING. |
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

Change/test record: all five slots have MaxLevel 10; all multirank KV values have ten explicit entries; the full 40-hero / 200-ability mock suite passes. Rank-up HUD, VFX/SFX in match, boss waves and VConsole remain pending a live Dota test.

2026-10-02 Ether Shock acceptance update: IN PROGRESS / ENGINE PENDING. Installed6943 hero definition/model verified ACT_DOTA_CAST_ABILITY_1 and attach_attack1. Decoded root creates pathCP0→CP1; impact children use recipient modelCP1; internally derivedCP4/3 not assigned externally. Root/children are finite (child_c continuous emitter has0.5s emission duration); release owns the Lua index, native decay owns effect expiry. Verified native bank EtherShock/EtherShock.Target; explicit ability precache bank/root and cast1 animation. Native icon name matches hero ability, but cold-start texture display remains pending. Target-order regression failed before repair; targeted mock evidence and final full-check counts recorded in individual ledger. All four localization sources and three generated mirrors per language now disclose existing Boss cap. No unique Shard or Scepter behavior added by this Q repair; shared upgrades still require the hero-wide audit. No new modifier/thinker/timer/reconnect state. Native cone comparison is documented; Enfos600radius design retained.

## Slot 2: `enfos_ss_hex`

Classification: PVE-CONVERT
Native counterpart: `shadow_shaman_voodoo` (installed native snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot mapping is authored).
Decision and PvE identity rationale: PVE-CONVERT preserves the identified Dota hero fantasy while changing PvP-only targeting/control for wave, elite and boss play.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current/target rank: each Enfos slot has ten explicit KV levels. The match is capped at level 50; Q/W/E/R require 40 paid ranks total and passive ranks 2–10 require nine more; the fifth slot rank 1 is free, for 49 spendable points overall. Rank-up HUD/runtime acceptance remains pending.
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
| Ranks | PENDING | W levels 1–10 gates declared; HUD/point behavior remains PENDING. |
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

Change/test record: all five slots have MaxLevel 10; all multirank KV values have ten explicit entries; the full 40-hero / 200-ability mock suite passes. Rank-up HUD, VFX/SFX in match, boss waves and VConsole remain pending a live Dota test.

## Slot 3: `enfos_ss_shackles`

Classification: PVE-CONVERT
Native counterpart: `shadow_shaman_shackles` (installed native snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot mapping is authored).
Decision and PvE identity rationale: PVE-CONVERT preserves the identified Dota hero fantasy while changing PvP-only targeting/control for wave, elite and boss play.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current/target rank: each Enfos slot has ten explicit KV levels. The match is capped at level 50; Q/W/E/R require 40 paid ranks total and passive ranks 2–10 require nine more; the fifth slot rank 1 is free, for 49 spendable points overall. Rank-up HUD/runtime acceptance remains pending.
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
| Ranks | PENDING | E levels 1–10 gates declared; HUD/point behavior remains PENDING. |
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

Change/test record: all five slots have MaxLevel 10; all multirank KV values have ten explicit entries; the full 40-hero / 200-ability mock suite passes. Rank-up HUD, VFX/SFX in match, boss waves and VConsole remain pending a live Dota test.

## Slot 4: `enfos_ss_mass_serpent_ward`

Classification: PVE-CONVERT
Native counterpart: `shadow_shaman_mass_serpent_ward` (installed native snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot mapping is authored).
Decision and PvE identity rationale: PVE-CONVERT preserves the identified Dota hero fantasy while changing PvP-only targeting/control for wave, elite and boss play.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current/target rank: each Enfos slot has ten explicit KV levels. The match is capped at level 50; Q/W/E/R require 40 paid ranks total and passive ranks 2–10 require nine more; the fifth slot rank 1 is free, for 49 spendable points overall. Rank-up HUD/runtime acceptance remains pending.
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
| Ranks | PENDING | R levels 5–50 in five-level steps declared; ultimate HUD/point behavior remains PENDING. |
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

Change/test record: all five slots have MaxLevel 10; all multirank KV values have ten explicit entries; the full 40-hero / 200-ability mock suite passes. Rank-up HUD, VFX/SFX in match, boss waves and VConsole remain pending a live Dota test.

## Slot 5: `enfos_ss_fowl_play`

Classification: REPLACE
Native counterpart: `Project Fowl Play passive; native innate metadata kept separate` (installed native snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot mapping is authored).
Decision and PvE identity rationale: REPLACE because this Enfos-authored passive has no one-to-one native counterpart; Dota innate metadata remains a separate ability.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current/target rank: each Enfos slot has ten explicit KV levels. The match is capped at level 50; Q/W/E/R require 40 paid ranks total and passive ranks 2–10 require nine more; the fifth slot rank 1 is free, for 49 spendable points overall. Rank-up HUD/runtime acceptance remains pending.
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
| Ranks | PENDING | Separate passive rank 1 grant retained; ranks 2–10 gates declared; HUD/point behavior remains PENDING. |
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

Change/test record: all five slots have MaxLevel 10; all multirank KV values have ten explicit entries; the full 40-hero / 200-ability mock suite passes. Rank-up HUD, VFX/SFX in match, boss waves and VConsole remain pending a live Dota test.

2026-09-30 level-cap integration: all five Shadow Shaman abilities now declare KV rank gates. Q/W/E and the Enfos passive use one rank per level; passive rank 1 remains a separate Enfos grant. Mass Serpent Ward ranks 1–10 unlock on levels 5, 10, …, 50. Static KV contract passes; actual rank buttons, level-up points, ultimate badge and match-start level 6 remain PENDING for owner testing.

## 2026-10-02 individual audit started: Shackles lifetime

Current installed6943 native definitions reread directly (same SHA256 as historical snapshot). Classification PVE-CONVERT remains for each stable slot; detailed native/current comparison in [individual ledger](../../audit/SHADOW_SHAMAN_INDIVIDUAL_REVIEW_2026-10-02.md). Shackles now terminates removed/dead source/deleted ability intervals, avoids post-damage stale healing, rejects switched-allied recipient, safely ends lost-target channels, and clears its scoped recipient before teardown without deleted-caster calls. Regression failed before repair;283behavior tests/full checks pass after. No damage/rank/timing balance changed. Entire hero remains IN PROGRESS; particle ownership, audio, cast/control/model/upgrade/resource and owner-engine acceptance are not closed by this lifetime fix.

## 2026-10-02 Shackles native connection/audio ownership

PVE-CONVERT remains. Decoded6943 root game config/model verifies both hands attach_attack1/2 atCP0/5; rope endpoints useCP1/6, recipient net/body uses modelCP1. CP3/4 are produced internally by child particle operators and are not guessed external setters. Channel now retains one native root, ends it with DestroyParticle(false)/release once, and no longer creates a released root each tick. Verified Shackles.Cast and loop events start once at valid creation; bank/root precache and cast/channel3 activities explicit. Full checks284behavior regressions,zero failures. Mock ownership is not visual/audio ENGINE_PASS: wearer endpoints/body net, animation/interrupt/strong purge and cold-start owner tests remain pending. Individual hero review still IN PROGRESS.

## 2026-10-02 Shackles reciprocal removal and cast pairing

PVE-CONVERT remains. Native6943 YES_STRONG now maps to explicit basic-purge false/strong true/stun identity and matching metadata. Recipient removal ends only its caster/target/ability/cast-generation channel; per-ability serial pairs both modifiers and refresh updates serial. Normal channel teardown clears pair before removing recipient, preventing recursive cancellation; stale same-target callback cannot interrupt newer cast. Missing recipient creation aborts before channel. Cast/recipient teardown and deleted source/ability guarded. Full checks286behavior regressions,zero failures; actual engine strong dispel/death/refresh/interrupt ordering remains owner pending. Hero-wide review still IN PROGRESS.
