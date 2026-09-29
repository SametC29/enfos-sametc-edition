# Sven: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_sven`; role: Tank. Production target: hero level 50 / all five abilities 10 total ranks; not implemented by this dossier.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `bulwark_shield_slam` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET \| DOTA_ABILITY_BEHAVIOR_AOE | abilities/pve_kits | sven_storm_bolt |
| 2 | `bulwark_challenge` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | sven_warcry |
| 3 | `bulwark_iron_guard` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | sven_great_cleave |
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

- `bulwark_shield_slam`: target flags, immunity, spell block/reflect if applicable, target loss.
- `bulwark_challenge`: cast/impact/modifier contract and lifetime.
- `bulwark_iron_guard`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `bulwark_fortress`: ultimate unlock curve, Scepter/Blessing and boss burst; static unreferenced-special candidates: bonus_hp, bonus_armor (not confirmed defects).
- `bulwark_unbreakable`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh; static unreferenced-special candidates: cleave_pct, gods_strength_duration (not confirmed defects).

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

### Runtime class-registration guard — 2026-09-29

The live test reported Q/W/E casts without their expected damage/feedback. Their
KV-to-Lua identifiers and callback implementations are present, but static mocks
cannot establish that Dota loaded the shared ability script. `addon_game_mode.lua`
now explicitly loads `abilities/pve_kits` at bootstrap and asserts the Sven Q,
W and E callbacks exist; a successful startup prints
`[SVEN_ABILITY_BOOTSTRAP] Q/W/E Lua handlers registered`. Engine verification
remains pending. Q is the direct damage spell; W is a buff/barrier/taunt, and E
is attack cleave, so W should not be expected to deal direct damage and E needs a
second enemy in the cone to show splash damage.

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
Decision and PvE identity rationale: TUNE. Keep the stable custom Enfos ID and use Sven's verified native Storm Hammer tracking/trail/impact identity. This restores the absent travel phase while retaining Enfos's radial wave-control role. Removed unrelated strength/armor physical scaling, slow, manual knockback and point-target detonation; those behaviors were unsupported by the native ability and overloaded the tank Q.
Expected cast/travel/impact/ongoing/cleanup behavior: unit-target cast with Sven Q animation from KV and cast event; visible, dodgeable, tracking Storm Hammer trail; on valid impact, impact sound/effect, magical damage and stun in configured AoE; one boss stun cap. A dodged/lost projectile does not detonate. Existing Scepter + God's Strength mobility effect happens at impact. One-shot impact particle index is released.
Migration dependency: stable project ID retained and still mapped in hero KV/roster. Current Q rank curve is implemented at 10 ranks; project-wide skill-point unlock gates, UI behavior and level-50 engine migration are separate pending work.
Normal creep / elite / boss, immunity / dispel / resistance rules: AoE magical damage and stun on successful impact; boss stun capped at 0.6s. Magic-immune enemies remain excluded by target filtering. Spell absorb is checked on the primary target before launch. Status resistance follows engine modifier rules; runtime pending.
Current versus target rank curve; free rank / point cost: KV now exposes 10 ranks: damage 140/175/210/245/280/315/350/390/430/470; radius 250/260/270/280/290/300/310/320/330/340; stun 1.0/1.1/1.2/1.3/1.4/1.5/1.6/1.7/1.8/1.9s; boss cap 0.6s. Cooldown decreases 16 to 11s and mana rises 80 to 125. Rank gates pending.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING.

### Resource and implementation evidence

- Native definition: `scripts/npc/heroes/npc_dota_hero_sven.txt`, `AbilityDefinitions/sven_storm_bolt`; installed archive hash is recorded above; ClientVersion 6941 / SourceRevision 11041083. Native KV says unit-target + AoE, magical damage, `Hero_Sven.StormBoltImpact`, strong dispel, 600 range, 0.2 cast point, cast animation `ACT_DOTA_CAST_ABILITY_1`, projectile speed 1000, stun 1.0/1.25/1.5/1.75s and AoE 250/270/290/310. Native projectile/engine runtime itself remains untested.
- Current implementation: `OnSpellStart` validates the target, attempts spell absorb, starts the native Q gesture and cast sound, then creates a tracking projectile. `OnProjectileHit` handles impact only for a live target, centers the effect and AoE at projectile location, applies magical damage/stun and respects the boss cap. Runtime callback behavior remains pending.
- Particle evidence: installed VPK contains `sven_storm_bolt_projectile_trail.vpcf` and `sven_storm_bolt_projectile_explosion.vpcf`; both are explicitly precached by `addon_game_mode.lua`. Their in-engine appearance, attachment/control-point fit, visual scale and cold-start load are pending.
- Audio evidence: uses native Sven cast event `Hero_Sven.StormBolt` and impact event `Hero_Sven.StormBoltImpact` from installed Sven sounds source (ClientVersion 6941 / SourceRevision 11041083). Event audibility and 3D emission at cast/impact are pending.
- Animation: KV declares `ACT_DOTA_CAST_ABILITY_1`, matching installed native Storm Hammer; actual engine animation pending.
- Precache owner: `addon_game_mode.lua`, one declaration per trail and explosion. Cold-start test pending.
- One-shot impact particle index is released; tracking projectile is engine-owned. Repeated-use/lifetime test pending.
- Localization: description and summary updated in EN/TR/RU/zh-CN; verify client display after restart.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Mock regression covers deferred impact AoE damage and stun; no engine test. |
| Targeting | PENDING | Unit-target KV and spell absorb guard implemented; range, immunity and target-loss engine behavior pending. |
| Ranks | PENDING | Ten values are in KV and static checks; in-engine rank display/leveling gates pending. |
| VFX | PENDING | Installed trail/explosion resources precached and wired; engine visibility/CP and impact positioning pending. |
| SFX | PENDING | Native cast/impact event IDs wired; audibility and source location pending. |
| Animation | PENDING | Native Q cast animation set in KV; engine animation pending. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Trail and explosion each explicitly precached once; cold-start test pending. |
| Cleanup | PENDING | Impact index released; projectile expiry/recast engine behavior pending. |
| Boss | PENDING | Code/mock caps stun at 0.6s; engine boss/status-resistance result pending. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | EN/TR/RU/zh-CN description and summary updated; client display pending. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 2: `bulwark_challenge`

Classification: PVE-CONVERT
Native counterpart: `sven_warcry`, verified in the installed Sven `AbilityDefinitions`, ClientVersion 6941 / SourceRevision 11041083. Native Warcry has immediate no-target behavior, native War Cry sound, override ability 3 cast gesture, dispellable ally buff and native radius/duration/speed/armor values.
Decision and PvE identity rationale: PVE-CONVERT. Keep recognizable Warcry team armor/movement support and its barrier; add a bounded short aggro pulse so Sven can protect nearby allies from waves. Runners remain immune and boss taunt remains 25% duration.
Expected cast/travel/impact/ongoing/cleanup behavior: immediate no-target cast with native Warcry sound and override-ability-3 animation; a modifier-owned buff particle accompanies each ally buff. Applies the Sven/allied armor, movement buff and damage barrier; enemy taunt is duration-limited. Caster death removes the taunt through an event callback, and cleanup clears only the force-attack target still owned by this taunt. No repeating interval thinker.
Static repair: removed manually started ability-2 gesture that disagreed with native Warcry's `ACT_DOTA_OVERRIDE_ABILITY_3`. Removed duplicate helper-created buff particles because the buff modifier already owns the same effect. Boss-duration scaling now uses the configured 25% factor and lets the engine apply status resistance once; the previous code pre-scaled by resistance and risked a second engine reduction. Forced-target cleanup now checks ownership.
Normal creep / elite / boss, immunity / dispel / resistance rules: normal eligible creeps taunted for the buff duration; `enfos_creep_runner` excluded; boss duration is 25% before engine status resistance. Buff is dispellable as configured by existing modifier behavior; runtime and AI interaction pending.
Current versus target rank curve; free rank / point cost: W now exposes 10 ranks: armor 6–24, duration 3.0–7.5s by 0.5, movement speed 15–33% by 2, barrier 100–550 by 50; radius remains 500. Cooldown decreases 18–13.5s and mana rises 65–110. Boss taunt factor is 25%; rank gates pending.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING.

### Resource and implementation evidence

- Native source: installed Sven `sven_warcry`, ClientVersion 6941 / SourceRevision 11041083; native ability declares War Cry event and `ACT_DOTA_OVERRIDE_ABILITY_3`. Engine verification pending.
- Buff particle path `particles/units/heroes/hero_sven/sven_warcry_buff.vpcf` already exists in VPK and is precached; now modifier-owned via `GetEffectName`/`GetEffectAttachType`, but actual rendering and duplicate-free behavior pending.
- Sound event: `Hero_Sven.WarCry`, emitted by Sven. Bank source is the installed Sven sound bank; audible output and cold-start resolution pending.
- Animation: `ACT_DOTA_OVERRIDE_ABILITY_3` now set in KV from installed native ability data; engine animation pending.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner: `addon_game_mode.lua` already precaches the Sven Warcry buff particle. Cold-start test pending.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated mirrors: PENDING.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Existing mock test verifies self/ally buff and normal/boss taunt duration; Dota AI/runtime not tested. |
| Targeting | PENDING | No-target cast; runner/boss exclusions in Lua. Runtime selection and team behavior pending. |
| Ranks | PENDING | Ten-rank curves are checked statically; engine UI/level gates pending. |
| VFX | PENDING | Modifier-owned VPK particle; actual attachment/appearance pending. |
| SFX | PENDING | Native WarCry event wired; audible test pending. |
| Animation | PENDING | Native override ability 3 animation set; engine result pending. |
| Modifiers | PENDING | Mock coverage exists; refresh/barrier/break/dispel/multi-caster engine behavior pending. |
| Precache | PENDING | Buff path explicitly precached once; cold-start pending. |
| Cleanup | PENDING | Taunt no longer uses interval scans and checks forced-target ownership; death/expiry engine test pending. |
| Boss | PENDING | Configured 25% duration; resistance/taunt immunity and AI behavior pending. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | Not evaluated in this dossier setup. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 3: `bulwark_iron_guard`

Classification: TUNE
Native counterpart: `sven_great_cleave`, verified in the installed Sven `AbilityDefinitions`, ClientVersion 6941 / SourceRevision 11041083. Native source defines a passive, breakable cleave with four ranks and a native cleave attack animation.
Decision and PvE identity rationale: TUNE. The primary Enfos ID stays stable; its defensive block/reflection package is removed because it displaced Sven's signature cleave. The passive now extends his attack damage through a widening cone so E is the kit's wave-clear role while Q controls/interrupts.
Expected cast/travel/impact/ongoing/cleanup behavior: passive triggers only on the real Sven's landed attack while passives are enabled. Nearby enemies behind the primary target within the configured widening cone receive physical splash damage; primary target is excluded from repeat damage. One Sven cleave visual is attached to the primary hit per attack (God's Strength variant while R is active), and the particle index is released. Attack's native weapon audio remains in place; no guessed extra sound event is emitted.
Static implementation: uses installed native `cleave_pct` identity and tuned widening-cone dimensions. This custom cone is a PvE implementation, not proof of byte-for-byte native engine cleave geometry. Illusions and Break are excluded. Building/ward compatibility and attacking dense groups remain engine tests.
Normal creep / elite / boss, immunity / dispel / resistance rules: enemy Hero/Basic units in cone take physical damage, so armor applies. Bosses have no bespoke damage penalty; high armor and elite scaling remain live. Primary target receives only the normal attack. No direct spell-immunity check is needed for attack cleave; runtime pending.
Current versus target rank curve; free rank / point cost: E now has 10 ranks: cleave damage 30/37/44/51/58/65/72/78/84/90% of attack damage; starting width 150; ending width 240/253/266/280/293/306/320/333/346/360; distance 400/433/467/500/533/567/600/633/667/700. Rank gates pending.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING.

### Resource and implementation evidence

- Native source: installed `sven_great_cleave`, ClientVersion 6941 / SourceRevision 11041083. Source uses passive/breakable identity, four ranks, attack animation `ACT_DOTA_CAST_ABILITY_2`, damage 60/70/80/90%, start width150, end width270/300/330/360 and distance400/500/600/700. Enfos target retains max native damage but spreads it over 10 ranks; runtime pending.
- Native visual resources: VPK includes `sven_spell_great_cleave.vpcf` and `sven_spell_great_cleave_gods_strength.vpcf`; Enfos precaches and attaches one per primary attack. CP/attachment fit and visible result pending.
- Sound: no extra custom cleave event is emitted; regular Sven weapon attack sound remains engine-owned. Any native cleave overlay sound is not claimed or overridden. Listening test pending.
- Animation/icon: attacks use Sven's regular attack animation; stable `sven_great_cleave` icon retained. Native ability definition also declares `ACT_DOTA_CAST_ABILITY_2`; it is not assigned as an ability-cast gesture for this passive.
- Modifier: intrinsic `modifier_bulwark_iron_guard`, attack-landed event only; honors Break, skips Sven illusions, no persistent state or stacks.
- Precache owner: `addon_game_mode.lua`, both native cleave particles. Cold-start pending.
- One-shot VFX index released immediately; no thinker/timer. Dense-wave visual budget and repeated attack cleanup pending.
- Localization keys and generated mirrors: PENDING.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Mock test checks cone inclusion/exclusion, physical splash, and primary-hit exclusion; engine combat not tested. |
| Targeting | PENDING | Hero/Basic enemy search; real target type/building/ward behavior pending. |
| Ranks | PENDING | Ten-rank curves static checked; UI/rank unlock pending. |
| VFX | PENDING | Native Sven cleave resources wired and precached; actual attachment and visibility pending. |
| SFX | PENDING | No new sound override; actual native cleave/weapon mix pending. |
| Animation | PENDING | Native Sven attack animation preserved; engine test pending. |
| Modifiers | PENDING | Intrinsic and Break checks are mocked; illusion/attack-event edge cases pending. |
| Precache | PENDING | Both cleave variants explicitly precached; cold-start pending. |
| Cleanup | PENDING | Particle index released per primary attack; in-engine lifetime/performance pending. |
| Boss | PENDING | Same physical cone damage, armor applies; boss armor/dense-wave balance pending. |
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
