# Sven: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_sven`; role: Tank. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `bulwark_shield_slam` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET \| DOTA_ABILITY_BEHAVIOR_AOE | abilities/pve_kits | sven_storm_bolt |
| 2 | `bulwark_challenge` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | sven_warcry |
| 3 | `bulwark_iron_guard` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | sven_great_cleave |
| 4 | `bulwark_fortress` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | sven_gods_strength |
| 5 | `bulwark_unbreakable` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | sven_wrath_of_god |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_sven.txt`; status: FILE_VERIFIED; SHA256: `2e82f619775e4b747282ec4150126e56dfbbf898687869c012c2c93c0dac527c`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
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
- `bulwark_fortress`: ultimate unlock curve, Scepter/Blessing and boss burst.
- `bulwark_unbreakable`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

### Runtime class-registration guard — 2026-09-29

The live test reported Q/W/E casts without their expected damage/feedback. Their
KV-to-Lua identifiers and callback implementations are present, but static mocks
cannot establish that Dota loaded the shared ability script. `addon_game_mode.lua`
now explicitly loads `abilities/pve_kits` at bootstrap and asserts the Sven Q,
W and E callbacks exist; a successful startup prints
`[SVEN_ABILITY_BOOTSTRAP] Q/W/E Lua handlers registered`. Live ClientVersion
6941 testing on 2026-09-29 confirms the callbacks and values:
Q projectile speed 1000, impact damage 175 and 1.1s stun; W radius 500, 3s
duration and working ally buff/enemy taunt; E radius 400 with nonzero splash,
including two nearby cleave hits in a creep pack. Q is the direct damage spell;
W is a buff/barrier/taunt, and E is passive attack cleave. VFX appearance and
audible SFX still need player confirmation.

The owner reports that Q/W/E visuals look weak and unlike Sven's original
effects. Treat VFX acceptance as unresolved pending visual evidence. Source
inspection confirms native Sven particle paths are wired for Q, W and E, but
these paths alone do not reproduce the full engine ability presentation. E's
custom splash damage does not inherit native Great Cleave visuals, so the Lua
attack callback now emits the native Sven cleave particle on the primary target
and up to five secondary damage targets per attack (six targets total maximum).
Live visual confirmation of the new multi-target feedback is pending.

### Engine-level Sven cast sounds — 2026-09-29

Q and W now declare distinct native Sven `AbilitySound` events in ability KV;
their duplicate Lua cast-time `EmitSound` calls were removed. This follows the
installed native Sven definitions and keeps cast audio at the engine ability
layer. Q impact audio remains in its projectile callback. E is passive and has
no separate cast sound. The map now launches and both sounds are configured,
but audibility remains pending player confirmation in the live match.

### Live special-value loading finding — 2026-09-29

The first live run executed Q/W/E Lua callbacks while their `GetSpecialValueFor`
reads returned zero under the legacy numbered `AbilitySpecial` blocks. Only
the Sven Q/W/E blocks were migrated to modern `AbilityValues`, preserving their
tuned values. After a full map restart, VConsole reported Q speed 1000, impact
damage 175 and stun 1.1; W radius 500 and duration 3; and E radius 400 with
nonzero splash. This validates these three abilities on ClientVersion 6941,
not every hero; audit another representative before broader migration. VConsole
does not verify visible particles or audible sounds.

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
Migration dependency: stable project ID retained and still mapped in hero KV/roster. Current Q rank curve is implemented at 10 ranks; shared KV rank gates and level-50 progression are implemented; skill-point allocation and UI behavior remain pending owner engine testing.
Normal creep / elite / boss, immunity / dispel / resistance rules: AoE magical damage and stun on successful impact; boss stun capped at 0.6s. Magic-immune enemies remain excluded by target filtering. Spell absorb is checked on the primary target before launch. Status resistance follows engine modifier rules; runtime pending.
Current versus target rank curve; free rank / point cost: KV now exposes 10 ranks: damage 140/175/210/245/280/315/350/390/430/470; radius 250/260/270/280/290/300/310/320/330/340; stun 1.0/1.1/1.2/1.3/1.4/1.5/1.6/1.7/1.8/1.9s; boss cap 0.6s. Cooldown decreases 16 to 11s and mana rises 80 to 125. Rank gates now unlock Q ranks 1–10 at hero levels 1–10; engine point/HUD behavior remains pending.
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
| Gameplay | PASS | Live ClientVersion 6941, 2026-09-29: VConsole logged projectile speed 1000; impact affected=1, damage=175, stun=1.1. |
| Targeting | PENDING | Unit-target KV and spell absorb guard implemented; range, immunity and target-loss engine behavior pending. |
| Ranks | PENDING | Ten values and levels 1–10 rank gates are in KV; in-engine rank display and point behavior remain pending. |
| VFX | PENDING | Owner reports weak/non-native-looking visuals. Native trail/explosion paths are wired; runtime frame review and visual scale/attachment confirmation remain pending. |
| SFX | PENDING | Native cast/impact event IDs wired; audibility needs player confirmation. |
| Animation | PENDING | Native Q cast animation set in KV; engine animation pending. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Trail and explosion each explicitly precached once; cold-start test pending. |
| Cleanup | PENDING | Impact index released; projectile expiry/recast engine behavior pending. |
| Boss | PENDING | Code/mock caps stun at 0.6s; engine boss/status-resistance result pending. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | EN/TR/RU/zh-CN description and summary updated; client display pending. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PASS | `[SVEN_TRACE][Q] projectile_created ... speed=1000`; impact affected=1, damage=175, stun=1.1. |

Change/test record: 2026-09-29 live match, ClientVersion 6941: cast Q on a creep and `enfos_boss_stonebreaker`; VConsole confirmed projectile, damage and stun values. VFX/SFX review pending.

## Slot 2: `bulwark_challenge`

Classification: PVE-CONVERT
Native counterpart: `sven_warcry`, verified in the installed Sven `AbilityDefinitions`, ClientVersion 6941 / SourceRevision 11041083. Native Warcry has immediate no-target behavior, native War Cry sound, override ability 3 cast gesture, dispellable ally buff and native radius/duration/speed/armor values.
Decision and PvE identity rationale: PVE-CONVERT. Keep recognizable Warcry team armor/movement support and its barrier; add a bounded short aggro pulse so Sven can protect nearby allies from waves. Runners remain immune and boss taunt remains 25% duration.
Expected cast/travel/impact/ongoing/cleanup behavior: immediate no-target cast with native Warcry sound and override-ability-3 animation; a modifier-owned buff particle accompanies each ally buff. Applies the Sven/allied armor, movement buff and damage barrier; enemy taunt is duration-limited. Caster death removes the taunt through an event callback, and cleanup clears only the force-attack target still owned by this taunt. No repeating interval thinker.
Static repair: removed manually started ability-2 gesture that disagreed with native Warcry's `ACT_DOTA_OVERRIDE_ABILITY_3`. Removed duplicate helper-created buff particles because the buff modifier already owns the same effect. Boss-duration scaling now uses the configured 25% factor and lets the engine apply status resistance once; the previous code pre-scaled by resistance and risked a second engine reduction. Forced-target cleanup now checks ownership.
Normal creep / elite / boss, immunity / dispel / resistance rules: normal eligible creeps taunted for the buff duration; `enfos_creep_runner` excluded; boss duration is 25% before engine status resistance. Buff is dispellable as configured by existing modifier behavior; runtime and AI interaction pending.
Current versus target rank curve; free rank / point cost: W now exposes 10 ranks: armor 6–24, duration 3.0–7.5s by 0.5, movement speed 15–33% by 2, barrier 100–550 by 50; radius remains 500. Cooldown decreases 18–13.5s and mana rises 65–110. Boss taunt factor is 25%; W ranks 1–10 unlock at hero levels 1–10; engine point/HUD behavior remains pending.
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
| Gameplay | PASS | Live ClientVersion 6941, 2026-09-29: W buffed Sven and taunted nearby enemies; trace showed radius=500, duration=3, with one boss and three creeps taunted in separate casts. |
| Targeting | PENDING | No-target cast; runner/boss exclusions in Lua. Runtime selection and team behavior pending. |
| Ranks | PENDING | Ten-rank values and levels 1–10 gates are checked statically; engine UI and point behavior remain pending. |
| VFX | PENDING | Owner reports weak/non-native-looking visuals. Modifier uses native Warcry buff particle; cast/persistent appearance and scale need visual review. |
| SFX | PENDING | Native WarCry event wired; audibility needs player confirmation. |
| Animation | PENDING | Native override ability 3 animation set; engine result pending. |
| Modifiers | PENDING | Mock coverage exists; refresh/barrier/break/dispel/multi-caster engine behavior pending. |
| Precache | PENDING | Buff path explicitly precached once; cold-start pending. |
| Cleanup | PENDING | Taunt no longer uses interval scans and checks forced-target ownership; death/expiry engine test pending. |
| Boss | PENDING | Configured 25% duration; resistance/taunt immunity and AI behavior pending. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | Not evaluated in this dossier setup. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PASS | `[SVEN_TRACE][W] ... allies_buffed=1 enemies_taunted=1 radius=500 duration=3`; creep-pack cast taunted 3. |

Change/test record: 2026-09-29 live match, ClientVersion 6941: cast W with boss nearby and earlier in a creep pack; VConsole confirmed ally buff, taunt count, radius and duration. VFX/SFX review pending.

## Slot 3: `bulwark_iron_guard`

Classification: TUNE
Native counterpart: `sven_great_cleave`, verified in the installed Sven `AbilityDefinitions`, ClientVersion 6941 / SourceRevision 11041083. Native source defines a passive, breakable cleave with four ranks and a native cleave attack animation.
Decision and PvE identity rationale: TUNE. The primary Enfos ID stays stable; its defensive block/reflection package is removed because it displaced Sven's signature cleave. The passive now extends his attack damage through a widening cone so E is the kit's wave-clear role while Q controls/interrupts.
Expected cast/travel/impact/ongoing/cleanup behavior: passive triggers only on the real Sven's landed attack while passives are enabled. Nearby enemies behind the primary target within the configured widening cone receive physical splash damage; primary target is excluded from repeat damage. One Sven cleave visual is attached to the primary hit per attack (God's Strength variant while R is active), and the particle index is released. Attack's native weapon audio remains in place; no guessed extra sound event is emitted.
Static implementation: uses installed native `cleave_pct` identity and tuned widening-cone dimensions. This custom cone is a PvE implementation, not proof of byte-for-byte native engine cleave geometry. Illusions and Break are excluded. Building/ward compatibility and attacking dense groups remain engine tests.
Normal creep / elite / boss, immunity / dispel / resistance rules: enemy Hero/Basic units in cone take physical damage, so armor applies. Bosses have no bespoke damage penalty; high armor and elite scaling remain live. Primary target receives only the normal attack. No direct spell-immunity check is needed for attack cleave; runtime pending.
Current versus target rank curve; free rank / point cost: E now has 10 ranks: cleave damage 30/37/44/51/58/65/72/78/84/90% of attack damage; starting width 150; ending width 240/253/266/280/293/306/320/333/346/360; distance 400/433/467/500/533/567/600/633/667/700. E ranks 1–10 unlock at hero levels 1–10; engine point/HUD behavior remains pending.
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
| Gameplay | PASS | Live ClientVersion 6941, 2026-09-29: attacks logged nonzero splash at radius=400; a creep-pack test registered two nearby cleave hits. Boss-only attacks had no secondary targets. |
| Targeting | PENDING | Hero/Basic enemy search; real target type/building/ward behavior pending. |
| Ranks | PENDING | Ten-rank values and levels 1–10 gates are checked statically; UI/rank unlock remains pending. |
| VFX | PENDING | Owner reports weak/non-native-looking visuals. Fix emits the native Sven cleave particle on primary and up to five splash targets per attack; live visual confirmation pending. |
| SFX | PENDING | No new sound override; native cleave/weapon mix needs player confirmation. |
| Animation | PENDING | Native Sven attack animation preserved; engine test pending. |
| Modifiers | PENDING | Intrinsic and Break checks are mocked; illusion/attack-event edge cases pending. |
| Precache | PENDING | Both cleave variants explicitly precached; cold-start pending. |
| Cleanup | PENDING | Particle index released per primary attack; in-engine lifetime/performance pending. |
| Boss | PENDING | Same physical cone damage, armor applies; boss armor/dense-wave balance pending. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | Not evaluated in this dossier setup. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PASS | `[SVEN_TRACE][E] ... nearby_cleave_hits=2 ... radius=400` in a creep pack; boss-only attacks had no secondary target. |

Change/test record: 2026-09-29 live match, ClientVersion 6941: attacked a boss and a creep pack; VConsole confirmed radius=400, nonzero splash and two secondary cleave hits in the pack. Follow-up fix adds bounded native cleave particles to secondary victims (max 6 total per attack); owner visual retest pending.

## Slot 4: `bulwark_fortress`

Classification: TUNE
Native counterpart: `sven_gods_strength`, verified in the installed Sven `AbilityDefinitions`, ClientVersion 6941 / SourceRevision 11041083. Native source declares no-target ultimate, native God's Strength sound, override ability 4 cast animation, non-dispellable duration and attack-damage scaling.
Decision and PvE identity rationale: TUNE. Retain God's Strength as Sven's focused damage window and preserve the recognizable cast/transform feedback; the existing defensive package and periodic wave remain intentional Enfos additions under the tank role.
Expected cast/travel/impact/ongoing/cleanup behavior: no-target cast with native Sven cast sound, short cast particle, persistent God's Strength modifier, bounded 1.5-second pulse thinker, and modifier expiry cleanup. Each pulse damages nearby enemies and attaches impact feedback to at most six affected units. Scepter extends duration and applies status resistance plus a short ally buff.
Static repair (2026-09-30): changed R to 10 ranks with explicit per-rank cooldown, mana, duration, attack bonus, strength, reduction and pulse-damage curves. Moved interval, strength factor, movement speed and all Scepter numbers to KV; removed stale, unused HP/armor KV fields. Added a mock regression for interval, damage scaling, Scepter status resistance and ally buff values. Particle thematic fit, native animation, boss behavior, rank UI and audio remain engine-pending.
Static special-value repair (2026-09-30): moved all 15 Lua-read God’s Strength fields from numbered `AbilitySpecial` into named `AbilityValues`, retaining five ten-rank curves and ten intentional scalars. This follows the prior ClientVersion 6941 live finding that Sven Q/W/E returned zero with the legacy numbered layout and began returning configured values after migration. Added a content contract that prevents this R ability from reverting to the legacy layout. D was not retested in Dota after this change; engine rank/value acceptance remains PENDING.
Tooltip audit (2026-09-30): corrected the four-language Scepter description. The old text promised Sven +20 armor and Storm Hammer cooldown/mobility that the current R/Scepter implementation does not grant; it now describes the implemented +5s duration, Sven's +50% status resistance, and the 1.8s allied damage/armor buff applied by each pulse. Localization is code-reviewed; HUD rendering remains pending.
Normal creep / elite / boss, immunity / dispel / resistance rules: Lua pulse targets enemy heroes and basic units and applies physical damage, so armor mitigates it. There is no special boss cap in the current implementation; actual boss armor/immunity and modifier status resistance remain unverified.
Current versus target rank curve; free rank / point cost: implemented as 10 ranks (duration 15–21s, bonus damage 100–200%, strength 25–55, reduction 30–50%, pulse 100–220 plus strength, cooldown 60–40s, mana 100–150); scalar radius 450 and interval 1.5s. Innate passive begins at rank 1 under the existing match progression; R ranks 1–10 are gated at levels 5, 10, …, 50; unlock UI still requires Dota verification.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: `scripts/npc/heroes/npc_dota_hero_sven.txt`, installed `pak01_dir.vpk`, ClientVersion 6941 / SourceRevision 11041083, SHA256 `2e82f619775e4b747282ec4150126e56dfbbf898687869c012c2c93c0dac527c`; current R definition read directly from the installed archive during the 2026-09-30 audit.
- Native R values: three ranks, 110/150/190% base damage, 30-second duration, 110/105/100-second cooldown and 40% slow resistance. Enfos deliberately tunes this into ten ranks, a 15–21s damage window with 60–40s cooldown, and separately documented tank defenses/pulses. The native sound (`Hero_Sven.GodsStrength`) and override ability-4 cast animation are retained. This is a sourced behavior comparison; engine presentation remains pending.
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
| Gameplay | PENDING | MOCK_PASS: regression verifies 320 physical damage at 220 base + 100 strength and the configured 1.5s interval; normal/elite/boss engine behavior pending. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Ten-rank values and level5/5-interval gates are statically checked; in-game UI remains pending. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | MOCK_PASS: regression checks configured Scepter status resistance and ally damage/armor values; refresh, dispel and duration behavior in Dota pending. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | Not evaluated in this dossier setup. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: 2026-09-30, static repair + mock regression. Full `node tools/checks.mjs` passed; no Dota runtime retest is claimed.

### D ability and passive focused repair — 2026-09-29

Static review found that `bulwark_fortress` had no cast animation override and
played the Storm Hammer impact particle at Sven's origin after every pulse.
The pulse now attaches that existing Sven impact particle to up to six affected
enemies, while damage still applies to every target. The pulse count, visual
target count, damage, and radius are logged for live verification. The D KV now
uses the installed native God's Strength override animation. This is a focused
feedback repair; it does not certify the visual's thematic fit, impact audio,
ultimate gameplay, or current shockwave design. Live retest remains pending.

The Enfos fifth-slot passive is explicitly breakable, and its regen, max-health,
and status-resistance bonuses all return zero while passives are disabled. This
aligns its three stat channels under Break; live Break testing remains pending.
R and the Enfos passive now both expose 10 ranks. The match-level system already
targets level 50 and starts the Enfos passive separately at rank 1; engine rank
unlock/UI acceptance is still pending.

## Slot 5: `bulwark_unbreakable`

Classification: PVE-CONVERT
Native counterpart candidate: installed Sven definitions include innate `sven_vanquisher` (bonus damage versus stunned targets) and separate `sven_wrath_of_god` facet variant (strength-scaled bonus damage); neither is proven to be a direct mapping for this project-specific free passive slot. Build/revision is recorded above.
Decision and PvE identity rationale: Proposal: keep a durable tank passive but add a deliberate interaction with Sven's stun/cleave identity. Installed source contains `sven_vanquisher` (bonus against stunned enemies) and separate `sven_wrath_of_god` facet definition; do not conflate either with Enfos's fifth slot.
Expected cast/travel/impact/ongoing/cleanup behavior: Passive only; rank scaling, Break, death/respawn and free starting rank must be tested. Select either tank sustain or stun synergy as the primary passive budget before adding both.
Static repair (2026-09-30): the fifth Enfos passive remains a distinct durability package, not Dota's innate. It grants HP regeneration, maximum health and status resistance; Shard doubles only regeneration below 40% health. Converted the three implemented values to explicit 10-rank KV curves and removed unused `cleave_pct`, `gods_strength_duration` and `bonus_damage_pct` fields that were misleadingly attached to this passive. All three bonuses now honor Break. Added regression coverage for all three stats, Break and the Shard threshold. Native stun synergy is intentionally not added because it would mix a separate Dota innate/facet mechanic into this Enfos passive.
Separation correction (2026-09-30): removed the Dota KV `Innate` marker from `bulwark_unbreakable`. `heroes/innates.lua` remains the sole Enfos free-rank path and grants rank 1; a content contract now requires Sven's Enfos passive to stay separate from Dota-native innate metadata. In-game HUD and rank-point behavior still require engine verification.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve; free rank / point cost: 10 ranks: regen 15→110, max HP 100→1400, status resistance 10→25%, with explicit values in KV. Enfos passive rank 1 is granted separately; ranks 2–10 are gated at hero levels 2–10. UI/unlock validation remains pending.
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
| Gameplay | PENDING | MOCK_PASS: regression verifies regen, max-health bonus, status resistance, Shard doubling below 40%, no doubling at 40%, and all three stats disabled under Break. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Ten-rank values and levels 1–10 gates are statically checked; in-game UI remains pending. |
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

Change/test record: 2026-09-30, static repair + mock regression. Full `node tools/checks.mjs` passed; Dota Break/Shard/rank UI behavior remains unverified.

2026-09-30 level-cap integration: all five Sven abilities now declare KV rank gates. Q/W/E and the Enfos passive use one rank per level; passive rank 1 remains separately granted by the Enfos system. Gods Strength ranks 1–10 unlock on levels 5, 10, …, 50. Static KV contract passes; actual rank buttons, level-up points, ultimate badge and match-start level 6 remain PENDING for owner testing.

2026-09-30 global Break metadata audit: Added KV `IsBreakable 1` to `bulwark_iron_guard` because its linked Lua passive implementation check `PassivesDisabled()`. Automated content validation now rejects this metadata mismatch. Actual Dota Break behavior remains PENDING.

### Individual-review follow-up — 2026-10-01, ClientVersion 6942

See [the current individual review](../../audit/SVEN_INDIVIDUAL_REVIEW_2026-10-01.md) for source comparisons, before/after reproducer and unresolved issues. E now cleaves living secondary victims even when the primary attack kills its target; Break/illusion/team/null guards remain. W Shard reflection rejects friendly/dead attackers and displays each ally's barrier on that ally. R is explicitly non-dispellable, matching current native God's Strength. These are code/mock repairs, not new engine PASS evidence.

W presentation repair: current decoded native cast root's mouth child uses CP2 as head location; native Sven model declares `attach_head`. The no-target server cast now emits one native `sven_spell_warcry.vpcf` root with CP2 head binding and finite particle-index release. Explicit ability precache covers cast particle and Sven sound bank; KV keeps sole cast sound ownership. Existing persistent Warcry buff remains modifier-owned; its unresolved CP1 composition is still PENDING. No duplicate persistent particle or gesture is added.

The four-language Scepter tooltip now correctly says the ally receives +50% of its **own base attack damage**, not 50% of Sven's bonus damage. The real allied Scepter modifier now has four-language name/description and synchronized generated mirrors. Current mock behavior suite:207 passing, full project checks pass. W/R VFX, SFX, animations, purge/death/recast, multi-caster and rank UI remain owner-runtime PENDING.
