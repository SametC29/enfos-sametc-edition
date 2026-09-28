# Sven: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_sven`; role: Tank. Production target: hero level 50 / all five abilities 10 total ranks; not implemented by this dossier.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `bulwark_shield_slam` | 4 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET \| DOTA_ABILITY_BEHAVIOR_POINT \| DOTA_ABILITY_BEHAVIOR_AOE | abilities/pve_kits | sven_storm_bolt |
| 2 | `bulwark_challenge` | 4 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | sven_warcry |
| 3 | `bulwark_iron_guard` | 4 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | sven_great_cleave |
| 4 | `bulwark_fortress` | 3 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | sven_gods_strength |
| 5 | `bulwark_unbreakable` | 8 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | sven_wrath_of_god |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_sven.txt`; status: FILE_VERIFIED; SHA256: `2e82f619775e4b747282ec4150126e56dfbbf898687869c012c2c93c0dac527c`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-28T21:16:02.562Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/sven/sven.vmdl` |
| SoundSet | `Hero_Sven` |
| Ability1 | `sven_storm_bolt` |
| Ability2 | `sven_great_cleave` |
| Ability3 | `sven_warcry` |
| Ability4 | `generic_hidden` |
| Ability5 | `generic_hidden` |
| Ability6 | `sven_gods_strength` |
| Ability7 | `sven_wrath_of_god` |
| Ability10 | `special_bonus_unique_sven_5` |
| Ability11 | `special_bonus_unique_sven_gods_strength_slow_resist` |
| Ability12 | `special_bonus_unique_sven_3` |
| Ability13 | `special_bonus_unique_sven_8` |
| Ability14 | `special_bonus_unique_sven_stormhammer_cooldown` |
| Ability15 | `special_bonus_unique_sven_7` |
| Ability16 | `special_bonus_unique_sven_2` |
| Ability17 | `special_bonus_unique_sven_4` |
| AttributeStrengthGain | `3.5` |
| AttributeAgilityGain | `2.20000` |
| AttributeIntelligenceGain | `1.500000` |

### Per-ability review leads

- `bulwark_shield_slam`: target flags, immunity, spell block/reflect if applicable, target loss; world position, travel/impact timing and radius alignment; static unreferenced-special candidates: bolt_speed (not confirmed defects).
- `bulwark_challenge`: cast/impact/modifier contract and lifetime.
- `bulwark_iron_guard`: intrinsic modifier, Break/illusion behavior, live rank refresh; static unreferenced-special candidates: passive_armor, damage_reduction (not confirmed defects).
- `bulwark_fortress`: ultimate unlock curve, Scepter/Blessing and boss burst; static unreferenced-special candidates: bonus_hp, bonus_armor (not confirmed defects).
- `bulwark_unbreakable`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh; static unreferenced-special candidates: cleave_pct, gods_strength_duration (not confirmed defects).

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

## Kit decision draft — 2026-09-29

These are evidence-backed **design proposals**, not a production rewrite or runtime pass. The owner authorized full skill replacement where warranted. Confirm numbers, boss exceptions and exact VFX with in-game review before implementing a major identity change. All skills must ultimately support 10 total ranks; curve pending.

| Slot | Proposed class | Direction | PvE job |
| --- | --- | --- | --- |
| Q Storm Hammer | TUNE | Use Sven's native Storm Hammer targeting/projectile/impact foundation; tune rank curve/AoE/stun for waves. Do not retain the current fake travel value or invent travel. | Ranged engage, wave stun, boss interrupt with explicit reduced duration. |
| W Warcry | PVE-CONVERT | Retain recognizable team Warcry buff and sound/animation; add a bounded wave taunt/aggro pulse as the PvE conversion. Review current barrier/Shard reflection separately to avoid overloaded defense. | Team defense + tank threat. |
| E Great Cleave | TUNE | Restore the native Sven cleave identity and tune cleave scaling/radius for wave clear. Current armor/block/reflect package is a substantial replacement for the signature cleave. | Reliable melee wave clear. |
| R God's Strength | TUNE | Retain native transformation and attack damage as the centerpiece. Remove extra shockwave/reduction/Str/move/status components unless the level10 design demonstrates a distinct, balanced role. | Focused elite/boss attack window. |
| Enfos passive | PVE-CONVERT | Keep a durable Sven passive, but connect it to the native Sven fantasy (e.g. bonus damage against stunned targets) rather than duplicating several unrelated defenses. Existing regen/health/status resistance needs one deliberate survivability budget. | Tank sustain and synergy with Q. |

The proposed passive inspiration is the installed Sven native innate definition `sven_vanquisher` (bonus damage against stunned targets); `sven_wrath_of_god` is also present as a separate native definition/facet variant. This is not a slot mapping: confirm which native variant Enfos intends before migration. Current Enfos fifth slot uses `sven_wrath_of_god` icon and an 8-rank custom modifier.

## Slot 1: `bulwark_shield_slam`

Classification: TUNE
Native counterpart: `sven_storm_bolt` / Storm Hammer, verified from installed Sven `AbilityDefinitions` (ClientVersion 6941, SourceRevision 11041083). The icon and Enfos slot alone were not used as evidence.
Decision and PvE identity rationale: Proposal: keep/tune native Storm Hammer because the native stun/projectile/AoE already serves wave control. Existing custom code is a shield-themed immediate AoE and loses travel. Do not mark the proposal final until the user reviews the kit direction.
Expected cast/travel/impact/ongoing/cleanup behavior: Native unit-target cast, native cast animation/projectile/travel and impact. Tune native values for Enfos. Any added PvE effect must own a separate impact/cleanup path. No Enfos slow/knockback is approved by this draft.
Migration dependency: direct native assignment would replace stable project ID `bulwark_shield_slam`. Before doing so, trace hero slot/roster, localization, evolution overrides, Aghanim hooks and tooltip consumers; either keep a deliberate compatibility mapping or document the ID migration. The native skill's current four-rank definition also does not by itself establish the requested ten-rank curve.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve; free rank / point cost: PENDING.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING.

### Resource and implementation evidence

- Native definition: `scripts/npc/heroes/npc_dota_hero_sven.txt`, `AbilityDefinitions/sven_storm_bolt`; installed archive hash is recorded above; ClientVersion 6941 / SourceRevision 11041083. Native KV says unit-target + AoE, magical damage, `Hero_Sven.StormBoltImpact`, strong dispel, 600 range, 0.2 cast point, cast animation `ACT_DOTA_CAST_ABILITY_1`, projectile speed 1000, stun 1.0/1.25/1.5/1.75s and AoE 250/270/290/310. Native projectile/engine runtime itself remains untested.
- Current Enfos source: `npc_abilities_custom.txt/bulwark_shield_slam` plus `pve_kits.lua:bulwark_shield_slam:OnSpellStart`. It allows both unit and point cast, deals physical damage immediately at the cursor origin, adds STR×2 + armor×8, applies 3s slow and rank-scaled stun, pushes non-boss enemies and caps boss stun at 0.6s. It creates no projectile; KV `bolt_speed=1400` is not read in the Lua callback. The tooltip describes an immediate strike, while the ability icon/name and unused bolt value suggest expectations need to be settled in the kit design.
- Particle evidence: Enfos uses `sven_storm_bolt_projectile_explosion.vpcf`, attaches it to the caster with `PATTACH_ABSORIGIN`, sets CP3 to the selected impact origin, then releases its index. That compiled VPK asset exists and the project explicitly precaches the path in `addon_game_mode.lua`. The asset's CP3 meaning, visual placement, duration and correctness are not verified; existence/precache do not equal visible effect.
- Audio evidence: Enfos emits `Hero_Sven.StormBolt`; the native hero file points to `soundevents/game_sounds_heroes/game_sounds_sven.vsndevts`, and native Storm Hammer declares `Hero_Sven.StormBoltImpact`. The current emitted event's definition, perceptible cast/hit timing and actual sound remain unverified. Do not claim SFX PASS.
- Model/animation/gesture/icon evidence: Enfos KV does not define `AbilityCastAnimation` for this custom ability and Lua does not call `StartGesture`; runtime animation behavior is PENDING. Native ability declares the cast animation above.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner: `addon_game_mode.lua` (two declarations of this explosion path are present). Cold-start test: PENDING.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated mirrors: PENDING.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Static source confirms immediate custom physical AoE, stun, slow, knockback and Scepter relocation; not a gameplay test. |
| Targeting | PENDING | KV permits unit + point casts; source picks cursor target origin or cursor point. Invalid targets, range and immunity not tested. |
| Ranks | PENDING | Not evaluated in this dossier setup. |
| VFX | PENDING | Explosion asset path is in installed VPK and explicit precache; CP3 meaning/placement and in-game visibility not tested. No projectile is created by current callback. |
| SFX | PENDING | Native bank and native impact event declaration observed; current `Hero_Sven.StormBolt` event resolution and audible output not verified. |
| Animation | PENDING | No custom cast animation KV or explicit gesture in current source; actual engine animation pending. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Explosion path explicitly precached twice in `addon_game_mode.lua`; cold start and projectile-resource coverage pending. |
| Cleanup | PENDING | Current callback releases one impact-particle index; visual lifetime and recast behavior pending. |
| Boss | PENDING | Source caps stun at 0.6s and suppresses knockback on boss-name match; damage/slow/control outcome in engine pending. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | Not evaluated in this dossier setup. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 2: `bulwark_challenge`

Classification: PVE-CONVERT
Native counterpart: `sven_warcry`, verified in the installed Sven `AbilityDefinitions`, ClientVersion 6941 / SourceRevision 11041083. Native Warcry has immediate no-target behavior, native War Cry sound, override ability 3 cast gesture, dispellable ally buff and native radius/duration/speed/armor values.
Decision and PvE identity rationale: Proposal: retain Warcry's native allied armor/movement buff; Enfos enemy-wave taunt is a PvE conversion. Review the barrier and Shard reflection budget before keeping both.
Expected cast/travel/impact/ongoing/cleanup behavior: Immediate AoE team cast plus bounded enemy aggro modifier; test target AI, boss behavior, caster death and modifier cleanup.
Static review: current Enfos Lua plays `Hero_Sven.WarCry`, which matches the native hero ability's declared event. It manually starts `ACT_DOTA_CAST_ABILITY_2`, whereas native Warcry declares `ACT_DOTA_OVERRIDE_ABILITY_3`; verify whether this causes a bad/missing cast animation. The helper-created buff particles plus modifier `GetEffectName` may create duplicates; visual test pending. Taunt cleanup currently clears the unit's force-attack target unconditionally; check interaction with lane AI/other aggro sources.
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
| Ranks | PENDING | Not evaluated in this dossier setup. |
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

## Slot 3: `bulwark_iron_guard`

Classification: TUNE
Native counterpart: `sven_great_cleave`, verified in the installed Sven `AbilityDefinitions`, ClientVersion 6941 / SourceRevision 11041083. Native source defines a passive, breakable cleave with four ranks and a native cleave attack animation.
Decision and PvE identity rationale: Proposal: tune native Great Cleave for the core Sven wave-clear identity. The current custom replacement spends much of the slot on defense and does not preserve native cleave implementation.
Expected cast/travel/impact/ongoing/cleanup behavior: Native passive attack cleave and its native visual/combat event; verify crowded waves, buildings, illusions, attack flags and Break in the target build.
Static review: current custom E combines physical armor, constant physical block, 30% reflection based on a physical-damage event, and attack-landed radial cleave. KV also contains `passive_armor` and `damage_reduction` specials not read by this modifier; they remain unconfirmed audit candidates.
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
| Ranks | PENDING | Not evaluated in this dossier setup. |
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

## Slot 4: `bulwark_fortress`

Classification: TUNE
Native counterpart: `sven_gods_strength`, verified in the installed Sven `AbilityDefinitions`, ClientVersion 6941 / SourceRevision 11041083. Native source declares no-target ultimate, native God's Strength sound, override ability 4 cast animation, non-dispellable duration and attack-damage scaling.
Decision and PvE identity rationale: Proposal: preserve native God's Strength as Sven's focused damage window. The custom repeating shockwave and stacked defensive stats risk making it an AoE tank ultimate instead.
Expected cast/travel/impact/ongoing/cleanup behavior: Native cast/transform/attack bonus and duration; tune cooldown/damage to bosses and waves, then validate Scepter and any Enfos upgrade.
Static review: the current custom ultimate adds a shockwave every 1.5s, damage reduction, strength and movement speed; Scepter adds status resistance and ally buffs. `bonus_hp` and `bonus_armor` are present in KV but unreferenced in the contract scan. Each shockwave uses the Storm Bolt explosion particle at the caster origin with no target-position CP assignment; exact effect suitability remains unverified.
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
| Ranks | PENDING | Not evaluated in this dossier setup. |
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

## Slot 5: `bulwark_unbreakable`

Classification: PVE-CONVERT
Native counterpart candidate: installed Sven definitions include innate `sven_vanquisher` (bonus damage versus stunned targets) and separate `sven_wrath_of_god` facet variant (strength-scaled bonus damage); neither is proven to be a direct mapping for this project-specific free passive slot. Build/revision is recorded above.
Decision and PvE identity rationale: Proposal: keep a durable tank passive but add a deliberate interaction with Sven's stun/cleave identity. Installed source contains `sven_vanquisher` (bonus against stunned enemies) and separate `sven_wrath_of_god` facet definition; do not conflate either with Enfos's fifth slot.
Expected cast/travel/impact/ongoing/cleanup behavior: Passive only; rank scaling, Break, death/respawn and free starting rank must be tested. Select either tank sustain or stun synergy as the primary passive budget before adding both.
Static review: current 8-rank passive grants HP regen, max HP and status resistance; under-40%-health Shard doubles regen. This is a coherent durability package but does not currently implement the native stun synergy. KV also has `cleave_pct` and `gods_strength_duration` candidates not used by the passive.
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
| Ranks | PENDING | Not evaluated in this dossier setup. |
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
