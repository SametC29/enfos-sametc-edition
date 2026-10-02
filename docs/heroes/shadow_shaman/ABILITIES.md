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

2026-10-02 unique Hex Shard (PVE-CONVERT): successful Hex now spreads to at most two additional enemies within 325 of its primary target. Primary spell absorption prevents the cast/spread; secondary enemy query excludes debuff-immune targets, keeps the existing strong-only dispel and 35% Boss duration. Existing verified chicken model, voodoo effect and recipient audio are reused. Shadow Shaman's generic +25% healing Shard is replaced, not stacked; other supports keep it. `HasShardUpgrade` moved from Fowl Play to Hex and all four locale sources/mirrors describe the actual mechanic. This authored Enfos evolution is not native Urnaconda parity. Target-budget, Shard on/off, primary absorb, ally exclusion, Boss duration and other-Support regression tests pass in mocks. Actual spreading VFX/audio, immunity/purge and cold-start remain owner ENGINE PENDING; Scepter remains unfinished.

2026-10-02 native short protection: current installed Fowl Play KV confirms a separate 0.1s invulnerability window. Added a finite hidden, nonpurgable/death-removing invulnerability modifier before purge, retaining the existing 1s damage guard. Four locale sources/mirrors explain both durations; mock verifies state and duration. Actual Dota expiration, targetability and lethal-save ordering remain owner PENDING. This supersedes older missing-invulnerability notes, but native confusion chickens and unique hero upgrades remain open.

2026-10-02 Fowl Play purge ordering: cooldown and short damage guard are established before strong-dispel callbacks; source/ability are revalidated afterward before chicken transformation. A pre-change nested-damage regression triggered two saves, and deleted-source cases reached unsafe calls. Mock regression covers all three cases; actual Dota callback ordering still requires owner verification.

2026-10-02 shared summon reward repair: `Summons:Own` now zeros native minimum/maximum gold bounty and death XP in addition to the addon no-reward flags. Native reward handling does not consult those custom flags. Player ownership/control and group registration remain intact; combat/rank classification is unchanged. Pre-change ward/illusion bounty regression failed; the repaired behavior is MOCK_PASS, with actual enemy kill rewards and owner control still ENGINE PENDING.

2026-10-02 Sol re-review: Fowl Play previously supplied a 1 HP floor even at rank 0 and queried cooldown on removed ability handles. Its property, damage and respawn callbacks now reject unlearned/deleted abilities. Regression reproduced the failure before repair; 292 hero-kit mock tests pass afterward. See the individual review ledger for remaining native-mechanic, upgrade and ward-economy gaps. Owner Dota lethal ordering and VConsole validation remain PENDING; this is not hero-wide completion.

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
Expected cast/travel/impact/ongoing/cleanup behavior: source-reviewed2026-10-02. Instant enemy chicken transformation through modifier-owned model property; hexed/silenced/disarmed/muted,140base move speed. Target receives finite feather impact and Hex.Target sound only after successful modifier creation. No projectile/loop/custom thinker. Model restoration on modifier removal remains engine-owned and owner testing PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: no Elite spawns. Enemy hero/basic targets, ENEMIES_NO, primary spell absorb; allied target rejected. Basic purge false, strong purge true, RemoveOnDeath true. Boss duration35%rank duration. Actual immunity/status resistance/purge and Boss model/scale restoration pending owner Dota tests.
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

Hex2026-10-02 evidence summary: native6943voodoo definition/hash reread; cast2 activity verified in installed model; chicken.vmdl and voodoo icon found in VPK. Existing decoded voodoo root/children are finite instantaneousCP0-origin feather effects; no extraCPguessing needed. Bank Hex.Target uses ambient/chicken.vsnd1.397347s. Ability explicitly precaches chicken/root/bank and declares cast2. Native speed100/duration2.0→2.9 differ from authored140/duration3→5.1; PVE-CONVERT retains those tuning curves and Boss35%. All4locales/mirrors now describe actual intended transformation/control/dispel. Initial missing-model-callback regression reproduced,291behavior/full checks pass after repair. No persistent model setters, timers or new reconnect state. Owner tests remain PENDING including multi-caster refresh/purge/death/wearables/Boss scale and cold start. This record is source/mock evidence, not runtime certification; hero review remains IN PROGRESS.

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
Expected behavior: point cast at600 range; spawns up to the KV count in a bounded ring, replacing the prior group. Stationary native ranged wards auto-acquire targets and remain player-owned/controllable; native projectile/model/sound set handle attacks. Each ward expires after the KV duration or when replaced. Static source review is recorded in the [individual ledger](../../audit/SHADOW_SHAMAN_INDIVIDUAL_REVIEW_2026-10-02.md); engine order, hit and cleanup behavior is PENDING.
Normal-creep/boss attack and damage behavior is PENDING engine validation. Unit uses native `creep_piercing`; no custom immunity/dispel modifier is applied. The installed unit definition declares20–26 native gold and31 XP; actual Dota bounty behavior and its fit for PvEvP remain PENDING.
Current/target rank: each Enfos slot has ten explicit KV levels. The match is capped at level 50; Q/W/E/R require 40 paid ranks total and passive ranks 2–10 require nine more; the fifth slot rank 1 is free, for 49 spendable points overall. Rank-up HUD/runtime acceptance remains pending.
Shard / Scepter / Blessing / Evolution / Ascended interactions: shared manager applies the role-based Support Shard and global Scepter40% ultimate-damage /25% ultimate-cooldown effects; the ward attack explicitly receives the40% Scepter damage multiplier. No ward-specific Shard evolution exists. Source behavior is STATIC_REVIEW; engine acquisition/description acceptance is PENDING.

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
| Gameplay | PENDING | Static source review: native immobile serpent-ward unit and bounded shared summon manager. Damage/health behavior on the engine-special unit requires owner match test. |
| Targeting | PENDING | Static source review: point target600; unit idle acquisition700 in shared helper. Owner order takeover and boss targetability require match test. |
| Ranks | PENDING | Static KV review: ten explicit `ward_damage` entries; R gate levels5–50 every5. HUD/point allocation still owner pending. |
| VFX | PENDING | Installed ward model and native `shadow_shaman_ward_base_attack.vpcf` projectile verified; no custom cast particle. Visual match test pending. |
| SFX | PENDING | Native `Hero_ShadowShaman.SerpentWard` event and `ShadowShaman_Ward` unit sound set verified in installed bank/KV; audible match test pending. |
| Animation | PENDING | Added native-model-verified `ACT_DOTA_CAST_ABILITY_4`; verify actual cast playback in Dota. |
| Modifiers | PENDING | Uses native `modifier_kill` lifetime; no custom ward combat modifier. Engine special-unit health behavior pending. |
| Precache | PENDING | Bootstrap calls `PrecacheUnitByNameSync` for `npc_dota_shadow_shaman_ward_1`; cold-start test pending. |
| Cleanup | PENDING | Shared manager marks ownership, expires via `modifier_kill`, and ForceKills old group on recast. Recast/expiry/ability removal in engine pending. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | EN/TR/RU/zh-CN sources use KV tokens; generated mirrors refreshed and localization check passes. Inspect tooltip rendering in Dota. |
| Performance | PENDING | Eight wards per cast under20 global helper cap; no timers or per-frame scans added. Owner performance/runtime check pending. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: all five slots have MaxLevel 10; all multirank KV values have ten explicit entries; the full 40-hero / 200-ability mock suite passes. Rank-up HUD, VFX/SFX in match, boss waves and VConsole remain pending a live Dota test.

## Slot 5: `enfos_ss_fowl_play`

Classification: PVE-CONVERT
Native counterpart: `shadow_shaman_fowl_play`, installed Dota6943 / SourceRevision11069754, `Innate=1`, `IsBreakable=1`, passive. Native AbilityValues: 3s chicken transformation, +5% movement speed per5 hero levels, one chicken per6 hero levels, one second of100% incoming-damage reduction,0.1s invulnerability and120s cooldown. Enfos maps this innate identity to stable slot5 and its own rank10/cooldown curve.
Decision and PvE identity rationale: PVE-CONVERT preserves the lethal-save fantasy for long PvE fights and the authored rank10 movement/cooldown curve; it now also uses strong dispel, the Valve chicken model, one second of full damage reduction and native respawn cooldown reset. Additional chicken units and the separate0.1s invulnerability are not implemented and remain explicit gaps.
Expected behavior: while ready and not Broken, a lethal damage event is held at1 health. The server strongly dispels debuffs, starts the rank cooldown, applies a chicken model/movement buff and a separate1-second full damage guard. Respawn resets the ability cooldown. Both effects expire safely on duration/death. No particle or Fowl Play-specific sound is present in the current native source; chicken model/icon are Valve assets. Actual lethal ordering, model restoration, status effects and cooldown presentation are ENGINE PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: self-only lethal save, so incoming unit class is not filtered. Boss damage is blocked for the same1-second guard; this is strong by design but must be checked in owner boss test. Strong dispel uses the current server API `Purge(false,true,false,true,true)`.
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
| Gameplay | PENDING | Static conversion reviewed against native lethal-save values; Dota death prevention and damage callback ordering still require owner test. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Separate passive rank 1 grant retained; ranks 2–10 gates declared; HUD/point behavior remains PENDING. |
| VFX | PENDING | Uses installed Valve chicken model `models/props_gameplay/chicken.vmdl` via modifier-owned model property and native icon `shadow_shaman_fowl_play`; appearance/restoration requires Dota test. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Intrinsic checks cooldown/Break/illusion; nonpurgable chicken buff and one-second nonpurgable damage guard are explicitly linked. Engine behavior pending. |
| Precache | PENDING | Chicken model declared in ability KV; cold-start pending. |
| Cleanup | PENDING | Both owned modifiers expire/remove on death; model restoration and repeated lethal events pending engine test. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Shared Support Shard gives role-wide healing bonus; no extra Fowl Play chicken upgrade. Global Scepter effects do not change this passive. |
| Localization | PENDING | EN/TR/RU/zh-CN source tooltips describe lethal save, strong dispel, chicken transformation, movement and damage reduction; inspect in Dota. |
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

2026-10-02 Mass Serpent Ward source audit: installed Dota6943 native identity, stationary ranged serpent-ward unit, native attack projectile/sound set, rank values, shared summon ownership, owner/recast cleanup, reward flags and current generic Aghanim effects are recorded in the individual review ledger. Added the model-verified native `ACT_DOTA_CAST_ABILITY_4` cast activity; corrected all four source locale tooltips to show KV-driven ward count, duration, health and rank damage (English/Russian/Chinese had stale hardcoded values). Focused regression and full checks passed. Actual control/order-vs-auto-acquire, boss damage, native serpent unit health/damage semantics, bounty, visual/audio and cold-start behavior remain owner ENGINE PENDING; this does not close Shadow Shaman.

2026-10-02 native innate Fowl Play repair: Dota6943 identifies Fowl Play as Shadow Shaman's breakable innate. The custom slot previously prevented death and granted speed only. It now strongly dispels debuffs, shows Valve's chicken model, gives the native one-second full damage reduction window, and gates the save on Break/cooldown/real hero; the missing modifier link and model precache are supplied. Rank-tuned Enfos cooldown/movement remain. Additional native chickens and respawn cooldown reset are still gaps. Mock acceptance passes; lethal damage/death ordering, purge, model restitution, Boss interactions and cooldown-on-respawn remain owner engine test pending.
