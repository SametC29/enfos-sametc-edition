# Bristleback: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_bristleback`; role: Tank. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_bb_viscous_nasal_goo` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/heroes/bristleback/controllers | bristleback_viscous_nasal_goo |
| 2 | `enfos_bb_quill_spray` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET \| DOTA_ABILITY_BEHAVIOR_IMMEDIATE \| DOTA_ABILITY_BEHAVIOR_AUTOCAST | abilities/heroes/bristleback/controllers | bristleback_quill_spray |
| 3 | `enfos_bb_bristleback` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/heroes/bristleback/controllers | bristleback_bristleback |
| 4 | `enfos_bb_hairball` | 10 | DOTA_ABILITY_BEHAVIOR_POINT \| DOTA_ABILITY_BEHAVIOR_AOE | abilities/heroes/bristleback/controllers | bristleback_hairball |
| 5 | `enfos_bb_warpath` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | NOT_EXPLICIT | bristleback_warpath |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/heroes/bristleback/controllers.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_bristleback.txt`; status: FILE_VERIFIED; SHA256: `2d8ca6edbae9a580a2faa49f798848d7beef87109dbac8c00e59f34bd68f7a34`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/bristleback/bristleback.vmdl` |
| SoundSet | `Hero_Bristleback` |
| Ability1 | `bristleback_viscous_nasal_goo` |
| Ability2 | `bristleback_quill_spray` |
| Ability3 | `bristleback_bristleback` |
| Ability4 | `bristleback_hairball` |
| Ability5 | `generic_hidden` |
| Ability6 | `bristleback_warpath` |
| Ability7 | `bristleback_prickly` |
| Ability10 | `special_bonus_attack_speed_25` |
| Ability11 | `special_bonus_mp_regen_150` |
| Ability12 | `special_bonus_unique_bristleback_5` |
| Ability13 | `special_bonus_unique_bristleback_6` |
| Ability14 | `special_bonus_hp_regen_25` |
| Ability15 | `special_bonus_unique_bristleback_2` |
| Ability16 | `special_bonus_unique_bristleback` |
| Ability17 | `special_bonus_unique_bristleback_3` |
| AttributeStrengthGain | `2.800000` |
| AttributeAgilityGain | `1.800000` |
| AttributeIntelligenceGain | `2.800000` |

### Per-ability review leads

- `enfos_bb_viscous_nasal_goo`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_bb_quill_spray`: manual/autocast parity, attack proc and duplicate events.
- `enfos_bb_bristleback`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `enfos_bb_hairball`: world position, travel/impact timing and radius alignment; ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_bb_warpath`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-10-04 native-first reopening: the following 2026-09-30 records are historical
custom-implementation evidence. Current per-slot classifications are TUNE, with
native/minimal-extension choices and linked Q/W/E/R boundaries recorded in
[the current source review](../../audit/BRISTLEBACK_NATIVE_FIRST_REVIEW_2026-10-04.md).
[Installed build 6943 definitions](../../audit/BRISTLEBACK_NATIVE_SOURCE_2026-10-04.json)
confirm the same hero-file SHA256 as the older snapshot. No new ENGINE_PASS,
visual/audio acceptance or owner test is implied. The review tracks independent
native Warpath first, then the linked kit and upgrades; whole-hero source closure
remains open.

Warpath source update2026-10-04: D now delegates to native
`bristleback_warpath`; custom cast listener and both custom modifiers are removed.
The same ten-rank damage/movement values use native `move_speed_per_stack`;
aspd_per_stack is explicitly zero. D remains BASIC with separate free rank,
and Hairball remains the R ultimate. Existing generic Shard is temporarily
preserved until the linked native upgrade unit. Two native-source contracts and
351 mock hero-kit regressions pass; native ten-rank indexing, stacks/expiry,
Break, lifecycle, VFX/SFX, upgrades and cold-start remain PENDING OWNER TEST.
Historical Warpath custom-modifier evidence below does not certify this native
replacement.

Linked Q/W/E/R source update2026-10-04: custom Goo/Quill/debuff/directional
retaliation/Hairball replicas are removed. Native providers perform gameplay,
VFX/SFX and cleanup; minimal controllers retain the four stable paid slots and
a single shared special-value modifier reads their ten ranks. Hairball has a
hidden rank-one native alias that cannot be granted by Shard, plus a paid-radius
cursor reticle. Native E owns Scepter activation; generic Hairball Scepter bonuses
are removed. Tank Shard remains an explicit Enfos extension because Hairball is
already paid R. Native max_damage=500 replaces the custom Quill stack cap. Four
languages reflect projectile impact, the damage cap and ranked Hairball stacks.
All historical custom-modifier acceptance rows below are superseded by the
[current linked-kit review](../../audit/BRISTLEBACK_NATIVE_FIRST_REVIEW_2026-10-04.md).
Every native engine, visual/audio and lifecycle area remains PENDING OWNER TEST.

## Slot 1: `enfos_bb_viscous_nasal_goo`

Classification: PVE-CONVERT
Native counterpart: `bristleback_viscous_nasal_goo`, verified in installed native hero KV above. Retain target debuff, armor reduction and stacking slow; repair impact feedback and move its existing values into explicit KV.
Decision and PvE identity rationale: Preserve the recognizable armor-breaking goo and stack pressure while avoiding assumptions that a cast icon creates a projectile or impact effect.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Q/W/E ranks 1–10 are KV-gated at levels 1–10; in-engine point/HUD behavior remains PENDING.
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
| Gameplay | PENDING | Goo duration, stack cap, armor reduction and slow formula are KV-driven; mock coverage confirms capped stack values. Target immunity/refresh behavior needs Dota verification. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Q ranks 1–10 are gated at hero levels 1–10; in-engine point/HUD behavior remains PENDING. |
| VFX | PENDING | Goo impact particle is present in installed source snapshot and already precached; attachment and live appearance remain unverified. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | EN/TR/RU/zh-CN descriptions now match configured formulas; engine rendering still needs review. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): classified all five abilities against installed native IDs. Goo now applies its precached impact particle and all stack/slow values are KV-backed; Quill Spray radius, formula and stack lifetime are KV-backed; Bristleback now distinguishes frontal/side/rear damage and triggers a rear-threshold spray; Warpath gains bounded stacks on ability casts; Hairball applies Goo stacks and Quill damage at the same cursor location. Added regressions for Goo values, directional reduction/retaliation, cast-driven Warpath, Quill damage and Hairball point alignment. Updated all five descriptions in EN/TR/RU/zh-CN. `node tools/checks.mjs` passes. Runtime Dota/VConsole, particle/audio presentation, target immunity, boss interactions and migration to level 50/10 ranks remain PENDING. A mock pass is not ENGINE_PASS.

2026-09-30 Warpath visual repair: the timed stack buff now exposes the installed `particles/units/heroes/hero_bristleback/bristleback_warpath.vpcf` as its attached effect, following Bristleback for exactly the modifier lifetime. Added addon precache, VPK presence verification, and checks for the effect path and follow attachment. Particle appearance and live visibility remain pending Dota capture.

## Slot 2: `enfos_bb_quill_spray`

Classification: PVE-CONVERT
Native counterpart: `bristleback_quill_spray`, verified in installed native hero KV above. Retain close-range physical area damage and escalating quill stacks, with explicit configured radius, cap and timing.
Decision and PvE identity rationale: Preserve the close-range wave-clear role and link its effect values to KV.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Q/W/E ranks 1–10 are KV-gated at levels 1–10; in-engine point/HUD behavior remains PENDING.
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
| Gameplay | PENDING | Damage formula, radius, stack cap and duration are KV-driven; regression covers strength scaling and stack damage. Engine damage/immune-target behavior remains pending. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | W ranks 1–10 are gated at hero levels 1–10; in-engine point/HUD behavior remains PENDING. |
| VFX | PENDING | Quill Spray particle is present and precached; used on Bristleback for Q and at the world point for Hairball. In-game CP/size still need capture. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | EN/TR/RU/zh-CN descriptions now match configured formulas; engine rendering still needs review. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): all five Enfos slots now declare ten ranks, scaling Goo armor reduction, Quill damage, rear/side reduction, Warpath bonuses and Hairball radius/cooldown. Hairball is not marked as Dota Innate; it remains the Enfos fifth-slot active. Goo now validates enemies and respects spell block. Quill Spray includes spell-immune enemies as its KV already promised. Warpath stacks and bonuses honor Break; Bristleback rejects allied damage from its rear-damage counter. Two regressions cover Goo spell block and Warpath Break. Goo/Quill particles were already precached and are now part of the VPK existence audit. Dossier/tooltips describe Break. Mock/static and VPK checks are pending final rerun; Dota/VConsole audio/visual tests, boss balance and level-point schedule remain PENDING.

## Slot 3: `enfos_bb_bristleback`

Classification: PVE-CONVERT
Native counterpart: `bristleback_bristleback`, verified in installed native hero KV above. Preserve front/side/rear distinction and rear-triggered Quill Spray; remove the current all-angle reduction behavior.
Decision and PvE identity rationale: Directional defense and rear retaliation define the passive, so the flat reduction is a confirmed identity loss.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Q/W/E ranks 1–10 are KV-gated at levels 1–10; in-engine point/HUD behavior remains PENDING.
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
| Gameplay | PENDING | Regression covers front/side/rear reductions and rear threshold retaliation. 70° rear / 110° side angles are referenced from [Liquipedia](https://liquipedia.net/dota2/Bristleback); local-build/runtime semantics remain to verify. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | E ranks 1–10 are gated at hero levels 1–10; in-engine point/HUD behavior remains PENDING. |
| VFX | PENDING | Rear proc now emits the existing Quill Spray particle; directional passive feedback and live attachment remain pending. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | EN/TR/RU/zh-CN descriptions now match configured formulas; engine rendering still needs review. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 5: `enfos_bb_warpath`

Classification: PVE-CONVERT
Native counterpart: `bristleback_warpath`, verified in installed native hero KV above. Build bounded damage/speed stacks on non-item ability casts, including Goo and Hairball.
Decision and PvE identity rationale: Preserve the cast-driven ramp-up identity, rather than granting stacks only from Quill Spray.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Warpath is the slot-5 Enfos passive; rank 1 is granted separately and ranks 2–10 are gated at hero levels 2–10. Point behavior remains PENDING in-engine validation.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: PENDING.
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: timed Warpath buff attaches `particles/units/heroes/hero_bristleback/bristleback_warpath.vpcf` to the hero with `PATTACH_ABSORIGIN_FOLLOW`; path verified in installed VPK and precached. Exact particle appearance and any additional control-point needs remain pending live inspection.
- Sound events + declaring banks + emission target + loop termination: PENDING.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: PENDING.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated mirrors: PENDING.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Warpath now gains one capped, timed stack per non-item ability cast; mock verifies bonus values and item exclusion. Live event ordering and Scepter behavior remain pending. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Warpath is the slot-5 Enfos passive: rank 1 is granted separately, and ranks 2–10 use the level 2–10 regular skill-point ladder. Hairball is the slot-4 ultimate with levels 5–50 gates. In-game HUD/point behavior remains PENDING. |
| VFX | PENDING | Native Warpath buff particle is attached and precached; VPK/static checks pass, in-game appearance/attachment still needs capture. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | EN/TR/RU/zh-CN descriptions now match configured formulas; engine rendering still needs review. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 4: `enfos_bb_hairball`

Classification: PVE-CONVERT
Native counterpart: `bristleback_hairball`, verified as native Ability4 in installed hero KV above. Apply Goo stacks and Quill Spray damage at the selected impact point.
Decision and PvE identity rationale: Keep the point-target hybrid; correct the current mismatch where Goo uses the cursor area but Quill Spray incorrectly fires around the caster.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Hairball is the active slot-4 ultimate, with ranks 1–10 gated at levels 5, 10, …, 50. Its Quill Spray impact shares Quill Spray values/stacks but records Hairball as the damage inflictor so the Enfos Scepter manager's ultimate spell amplification can recognize it. Engine amplification behavior remains pending.
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
| Gameplay | PENDING | Regression confirms Goo applications and Quill Spray damage both use the selected point instead of splitting between cursor and caster; the physical damage event retains Hairball as inflictor for ultimate Scepter amplification. Projectile timing/immunity/boss and live Scepter behavior remain pending. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Hairball ultimate ranks 1–10 are gated at levels 5–50 in five-level steps; engine HUD and point behavior need verification. |
| VFX | PENDING | Uses the verified Quill Spray particle at the world impact point; Hairball-specific travel/impact presentation remains pending. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | EN/TR/RU/zh-CN descriptions now match configured formulas; engine rendering still needs review. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

2026-09-30 level-cap integration and slot correction: Hairball is the active slot-4 ultimate, gated at levels 5, 10, …, 50; Warpath is the slot-5 Enfos passive and receives rank 1 through the separate Enfos grant. Static gates pass, while engine rank UI/point behavior remains PENDING. Hairball's Scepter damage amplification path remains under review because its damage is delegated to the Quill Spray handler.

2026-09-30 static evidence correction: fixed the Warpath acceptance ledger, which incorrectly described the slot-5 Enfos passive as an ultimate with level 5–50 gates. Its actual KV uses the regular level 1–10 ladder with a separate free rank 1; Hairball is the slot-4 ultimate on the 5–50 ladder. Runtime rank buttons and point behavior remain PENDING owner testing.

2026-09-30 static Scepter correction: Hairball reused Quill Spray's damage helper, which also used Quill Spray as ApplyDamage's inflictor. The Enfos Scepter modifier only amplifies damage whose inflictor is an ultimate, so Hairball's shared impact damage bypassed that upgrade. The helper now keeps Quill Spray's configured values/stacks while reporting Hairball as the damage inflictor; the mock regression verifies this routing. Actual Scepter damage amplification remains PENDING in Dota.

2026-09-30 global Break metadata audit: Added KV `IsBreakable 1` to `enfos_bb_bristleback`, `enfos_bb_warpath` because its linked Lua passive implementation check `PassivesDisabled()`. Automated content validation now rejects this metadata mismatch. Actual Dota Break behavior remains PENDING.
