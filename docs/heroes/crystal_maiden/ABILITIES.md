# Crystal Maiden: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_crystal_maiden`; role: Mage. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_cm_crystal_nova` | 10 | DOTA_ABILITY_BEHAVIOR_POINT \| DOTA_ABILITY_BEHAVIOR_AOE | abilities/pve_kits | crystal_maiden_crystal_nova |
| 2 | `enfos_cm_frostbite` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/pve_kits | crystal_maiden_frostbite |
| 3 | `enfos_cm_arcane_aura` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | crystal_maiden_brilliance_aura |
| 4 | `enfos_cm_freezing_field` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET \| DOTA_ABILITY_BEHAVIOR_CHANNELLED | abilities/pve_kits | crystal_maiden_freezing_field |
| 5 | `enfos_cm_glacial_mastery` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | crystal_maiden_freezing_field |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_crystal_maiden.txt`; status: FILE_VERIFIED; SHA256: `b4b1bddb3448471cbeecc2e625264954ac7705b1e110b9d17e1514a5183f9151`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/crystal_maiden/crystal_maiden.vmdl` |
| SoundSet | `hero_Crystal` |
| Ability1 | `crystal_maiden_crystal_nova` |
| Ability2 | `crystal_maiden_frostbite` |
| Ability3 | `crystal_maiden_brilliance_aura` |
| Ability4 | `crystal_maiden_crystal_clone` |
| Ability5 | `crystal_maiden_glacial_guard` |
| Ability6 | `crystal_maiden_freezing_field` |
| Ability7 | `crystal_maiden_freezing_field_stop` |
| Ability10 | `special_bonus_hp_200` |
| Ability11 | `special_bonus_intelligence_12` |
| Ability12 | `special_bonus_unique_crystal_maiden_frostbite_castrange` |
| Ability13 | `special_bonus_unique_crystal_maiden_5` |
| Ability14 | `special_bonus_unique_crystal_maiden_glacial_guard_mana_multiplier` |
| Ability15 | `special_bonus_unique_crystal_maiden_3` |
| Ability16 | `special_bonus_unique_crystal_maiden_1` |
| Ability17 | `special_bonus_unique_crystal_maiden_2` |
| AttributeStrengthGain | `2.200000` |
| AttributeAgilityGain | `1.800000` |
| AttributeIntelligenceGain | `3.300000` |

### Per-ability review leads

- `enfos_cm_crystal_nova`: world position, travel/impact timing and radius alignment.
- `enfos_cm_frostbite`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_cm_arcane_aura`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `enfos_cm_freezing_field`: channel tick, interrupt, looping audio and thinker expiry; ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_cm_glacial_mastery`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

Static regression evidence (2026-09-30): added mock-engine coverage for Crystal Nova configured damage/Intelligence scaling/slow, Frostbite DPS/Intelligence scaling/creep multiplier, Arcane Aura ally values/Crystal Maiden's triple mana regeneration/Break suppression, and Freezing Field pulse values/loop-sound stop on cleanup. These tests validate the Lua wiring against mocked engine callbacks only; all in-game behavior, visuals, audio, rank/HUD presentation, and VConsole checks remain PENDING for the user.

## Slot 1: `enfos_cm_crystal_nova`

Classification: PVE-CONVERT
Native counterpart: `crystal_maiden_crystal_nova`, verified in the installed hero KV above. Keeps the ground-target burst and crowd control, with persistent frost stacks added for Enfos synergy. All Lua-read values moved to `AbilityValues`; slow strengths and duration are now read from KV.
Decision and PvE identity rationale: Preserve the area burst and slow identity. Corrected the effect attaching to Crystal Maiden instead of appearing at the selected point by using a world-position particle control point.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Crystal Nova Q ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
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
| Gameplay | PENDING | Crystal Nova base damage now reads its Intelligence coefficient from KV, and its frost stack duration uses the innate configuration; live cast/radius remains unverified. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Q gates levels 1–10 declared; HUD/point behavior remains PENDING engine verification. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | EN/TR/RU/zh-CN tooltips now describe current values and behavior; rendered in-game values remain unverified. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 2: `enfos_cm_frostbite`

Classification: PVE-CONVERT
Native counterpart: `crystal_maiden_frostbite`, verified in the installed hero KV above. Keeps the targeted root/disarm and damage-over-time; its duration is now read from KV. Remaining creep/boss duration and damage behavior require engine verification.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Frostbite W ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
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
| Gameplay | PENDING | Frostbite tick interval, Intelligence scaling and creep multiplier now read KV; actual root/DoT and boss status behavior remain unverified. |
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
| Localization | PENDING | EN/TR/RU/zh-CN tooltips now describe current values and behavior; rendered in-game values remain unverified. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 3: `enfos_cm_arcane_aura`

Classification: PVE-CONVERT
Native counterpart: `crystal_maiden_brilliance_aura`, verified in the installed hero KV above. Keeps team mana support and adds the advertised spell amplification. Mana and amplification values use KV values. The aura explicitly rejects its own source and applies Crystal Maiden's triple mana regeneration and spell amplification through the intrinsic modifier, preventing duplicate self-stacking and avoiding reliance on aura self-inclusion.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Arcane Aura E ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
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
| Gameplay | PENDING | Arcane Aura reads its range and bonus values from KV. The owner receives triple configured mana regeneration plus configured spell amplification directly; allied aura recipients get the normal values. Mock tests cover source exclusion and Break suppression; live aura reach/performance remain unverified. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | E gates levels 1–10 declared; HUD/point behavior remains PENDING engine verification. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Static/mock coverage verifies owner-versus-ally values, explicit source exclusion and source Break suppression; engine aura acquisition and modifier presentation remain unverified. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | EN/TR/RU/zh-CN tooltips now describe current values and behavior; rendered in-game values remain unverified. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

2026-09-30 static audit: fixed Arcane Aura's owner bonus path. The implementation now excludes Crystal Maiden from her own aura and gives her triple mana regeneration plus the aura spell amplification through the intrinsic modifier; allies receive the normal aura values. Regression coverage exercises owner, ally, self-exclusion and Break behavior. Runtime aura propagation, HUD icon and in-game tooltip presentation remain PENDING for the owner.

## Slot 4: `enfos_cm_freezing_field`

Classification: PVE-CONVERT
Native counterpart: `crystal_maiden_freezing_field`, verified as native Ability6 in the installed hero KV above. Keeps the channeling blizzard and adds Enfos frost-stack synergy. Its Lua radius now uses the configured KV radius.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Freezing Field R ranks 1–10 are KV-gated at levels 5, 10, …, 50; ultimate UI and point behavior remain PENDING.
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
| Gameplay | PENDING | Channel duration, tick rate, damage scaling, defenses and slow now read KV; random target distribution and interrupt cleanup remain unverified. |
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
| Localization | PENDING | EN/TR/RU/zh-CN tooltips now describe current values and behavior; rendered in-game values remain unverified. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 5: `enfos_cm_glacial_mastery`

Classification: REPLACE
Native counterpart: None. `crystal_maiden_glacial_guard` is the separate native innate; Glacial Mastery is an Enfos-only frost-stack passive.
Decision and PvE identity rationale: Keep the Enfos stack-and-shatter mechanic. Fixed the configured `shatter_damage` being ignored by Lua and updated the tooltip to describe frost stacks, freeze and boss-capped damage rather than unsupported permanent spell amplification.
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
| Gameplay | PENDING | Fixed stack refresh using an ability value before fetching the ability; regression confirms fifth stack still triggers boss-capped shatter. Live freeze/boss behavior remains unverified. |
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
| Localization | PENDING | EN/TR/RU/zh-CN tooltips now describe current values and behavior; rendered in-game values remain unverified. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-30): all five Enfos slots declare ten ranks with damage, cooldown, mana, aura and proc curves interpolated from existing endpoints. Glacial Mastery is distinct from Dota Innate and honors Break; Arcane Aura also disables under Break. Frostbite validates and rejects spell-blocked/allied targets. Freezing Field uses the verified Valve caster particle, and its loop sound stops from modifier cleanup. Bosses receive only 25% of the normal Glacial freeze duration; shatter damage remains capped from KV. Localization describes the Boss control cap. Regression coverage includes Frostbite spell block and Boss freeze duration, plus new mock-engine tests for Crystal Nova, Frostbite scaling, Arcane Aura and Freezing Field pulse/audio cleanup. These are static/mock checks, not engine certification. Dota/VConsole channel interruption, actual visuals and sound, balance, and point/unlock schedule remain PENDING for user testing.

2026-09-30 level-cap integration: all five Crystal Maiden abilities now declare KV rank gates. Q/W/E and the Enfos passive use one rank per level; passive rank 1 remains a separate Enfos grant. Freezing Field ranks 1–10 unlock on levels 5, 10, …, 50. Static KV contract passes; actual rank buttons, level-up points, ultimate badge and match-start level 6 remain PENDING for owner testing.

2026-09-30 global Break metadata audit: Added KV `IsBreakable 1` to `enfos_cm_arcane_aura` because its linked Lua passive implementation check `PassivesDisabled()`. Automated content validation now rejects this metadata mismatch. Actual Dota Break behavior remains PENDING.
