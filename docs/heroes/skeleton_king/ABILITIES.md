# Wraith King: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_skeleton_king`; role: Fighter. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_wk_wraithfire_blast` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/pve_kits | skeleton_king_hellfire_blast |
| 2 | `enfos_wk_skeleton_army` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | skeleton_king_bone_guard |
| 3 | `enfos_wk_mortal_strike` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | skeleton_king_mortal_strike |
| 4 | `enfos_wk_reincarnation` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | skeleton_king_reincarnation |
| 5 | `enfos_wk_vampiric_aura` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | skeleton_king_bone_guard |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_skeleton_king.txt`; status: FILE_VERIFIED; SHA256: `dea472e68d3c6b427b7342a5798afa66a19b3be3a8272a9ee29c74071d4d409d`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/wraith_king/wraith_king.vmdl` |
| SoundSet | `Hero_SkeletonKing` |
| Ability1 | `skeleton_king_hellfire_blast` |
| Ability2 | `skeleton_king_bone_guard` |
| Ability3 | `skeleton_king_mortal_strike` |
| Ability4 | `skeleton_king_vampiric_spirit` |
| Ability5 | `generic_hidden` |
| Ability6 | `skeleton_king_reincarnation` |
| Ability10 | `special_bonus_unique_wraith_king_2` |
| Ability11 | `special_bonus_unique_wraith_king_facet_1` |
| Ability12 | `special_bonus_unique_wraith_king_11` |
| Ability13 | `special_bonus_hp_300` |
| Ability14 | `special_bonus_attack_speed_50` |
| Ability15 | `special_bonus_unique_wraith_king_facet_3` |
| Ability16 | `special_bonus_unique_wraith_king_10` |
| Ability17 | `special_bonus_unique_wraith_king_4` |
| AttributeStrengthGain | `2.8` |
| AttributeAgilityGain | `1.7` |
| AttributeIntelligenceGain | `1.4` |

### Per-ability review leads

- `enfos_wk_wraithfire_blast`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_wk_skeleton_army`: cast/impact/modifier contract and lifetime.
- `enfos_wk_mortal_strike`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `enfos_wk_reincarnation`: intrinsic modifier, Break/illusion behavior, live rank refresh; ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_wk_vampiric_aura`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-10-02 shared summon reward repair: `Summons:Own` now zeros native minimum/maximum gold bounty and death XP in addition to the addon no-reward flags. Native reward handling does not consult those custom flags. Player ownership/control and group registration remain intact; combat/rank classification is unchanged. Pre-change ward/illusion bounty regression failed; the repaired behavior is MOCK_PASS, with actual enemy kill rewards and owner control still ENGINE PENDING.

### Pilot review and special-value schema repair — 2026-09-29

The installed ClientVersion 6941 source snapshot identifies Wraith King's
native Q/W/E/R as `skeleton_king_hellfire_blast`,
`skeleton_king_vampiric_spirit`, `skeleton_king_mortal_strike`, and
`skeleton_king_reincarnation`. The Enfos versions are PVE-CONVERT: they retain
the corresponding stun/DoT, lifesteal, critical-strike, and reincarnation
identities while adding wave/boss behavior. `enfos_wk_skeleton_army` is an
Enfos-specific fifth slot; native Ability2 is Bone Guard, separate from the
other native abilities listed above.

Lua-read values now cover projectile/impact timing, Wraithfire DoT, aura range,
Mortal Strike cleave, Reincarnation and Skeleton Army summon rules. The installed
local Dota VPK (Steam BuildID 25539253) contains the named projectile, explosion,
debuff, reincarnation and lifesteal particle resources. Presence does not prove
particle role, control points or in-game rendering. Q now launches a tracking
projectile and applies damage/control only on a valid hit; its 1200 speed follows
current public ability references, with exact native parity still pending.
The ten-rank migration now extends Q/W/E/R and the custom slot-5 summon to ten
explicit ranks; the free first slot-5 rank comes from the separate Enfos innate
grant. The shared level-50 XP and skill-point curve is implemented; engine point/HUD behavior remains pending owner verification.
Live value loading, VFX/SFX, modifiers, boss behavior and summon cleanup still
require engine verification.

2026-09-30 summon-count contract repair: rank 9/10 KV configured 11/12 skeletons,
but the shared summon helper silently capped every unit summon at 8. Added an
explicit per-call cap for Skeleton Army (bounded at 20 globally); other summon
callers retain the default cap of 8. Regression verifies twelve units, distinct
formation positions, the global bound and unchanged illusion behavior. Dota
spawn reliability, control and cleanup remain pending owner test.

## Slot 1: `enfos_wk_wraithfire_blast`

Classification: PVE-CONVERT
Native counterpart: `skeleton_king_hellfire_blast` (installed ClientVersion 6941 source snapshot).
Decision and PvE identity rationale: Preserve the native traveling fireball and hit timing. Keep the Enfos Strength scaling, DoT and shorter boss stun. Projectile, DoT and boss values are KV-backed; actual trail/impact roles and runtime presentation remain pending.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Q ranks 1–10 are gated at hero levels 1–10, one rank per level. Point cost and actual unlock behavior: PENDING in-engine validation.
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
| Gameplay | PENDING | Mock hit timing, normal damage/control and boss stun-cap tests pass; engine validation pending. |
| Targeting | PENDING | Tracking target and spell-absorb launch guard are implemented; disjoint/target-loss rules need engine test. |
| Ranks | PENDING | All five KV entries now expose ten ranks and the suite clamps/smoke-tests the roster through rank 10; actual in-match point/unlock pacing to level 50 remains pending. |
| VFX | PENDING | Projectile, impact and debuff particle paths exist in installed VPK; roles, CPs, placement and rendering need engine test. |
| SFX | PENDING | Hellfire Blast cast event is wired; audible event and projectile/impact audio require engine test. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Boss stun cap has a mock test; damage, status resistance and boss presentation need engine test. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | EN/TR/RU/zh-CN sources and generated mirrors validate; in-game tooltip display pending. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-29; rank migration 2026-09-30): preserved tracking-projectile timing and hit-only damage/control; expanded Q to ten data-driven ranks and added target/team/spell-absorb guards. Regression covers projectile settings and deferred impact; engine travel, visuals/audio, immunity and boss behavior remain PENDING.

## Slot 5: `enfos_wk_vampiric_aura`

Classification: PVE-CONVERT
Native counterpart: `skeleton_king_vampiric_spirit` (installed ClientVersion 6941 source snapshot).
Decision and PvE identity rationale: Preserve attack lifesteal as the team-support adaptation. The aura now heals only from landed attacks rather than arbitrary spell damage; radius and lifesteal percentage are KV-backed, with a lifesteal particle on qualifying hits.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: This is the Enfos fifth-slot passive: rank 1 is granted separately, and ranks 2–10 are gated on the regular levels 2–10 ladder. Point cost and actual unlock behavior: PENDING in-engine validation.
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
| Gameplay | PENDING | Mock verifies configured landed-attack lifesteal for Wraith King and aura recipients, explicit source exclusion to prevent duplicate self-healing, and Break suppression; engine aura/multi-caster behavior pending. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | All five KV entries now expose ten ranks and the suite clamps/smoke-tests the roster through rank 10; actual in-match point/unlock pacing to level 50 remains pending. |
| VFX | PENDING | Lifesteal particle path is present and emitted on successful heals; presentation and cleanup need engine test. |
| SFX | PENDING | No dedicated passive aura sound is currently authored; test audio feedback in engine. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | EN/TR/RU/zh-CN descriptions now describe attack lifesteal; generated tokens validate, HUD display pending. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-29; rank migration 2026-09-30): expanded lifesteal to ten KV ranks; aura emission and healing now stop under Break. Added the installed lifesteal particle and corrected EN/TR/RU/zh-CN tooltips. Mock regression covers the heal, radius and Break; multi-caster behavior and in-game particle/audio remain PENDING.

## Slot 3: `enfos_wk_mortal_strike`

Classification: PVE-CONVERT
Native counterpart: `skeleton_king_mortal_strike` (installed ClientVersion 6941 source snapshot).
Decision and PvE identity rationale: Keep the native critical-strike identity and the bounded cleave as an Enfos wave adaptation. Cleave percentage and radius are KV-backed.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: E ranks 1–10 are gated at hero levels 1–10, one rank per level. Point cost and actual unlock behavior: PENDING in-engine validation.
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
| Gameplay | PENDING | Existing mock verifies crit proc and configured cleave damage; engine attack-event ordering, illusion/Break and dense-wave behavior pending. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | All five KV entries now expose ten ranks and the suite clamps/smoke-tests the roster through rank 10; actual in-match point/unlock pacing to level 50 remains pending. |
| VFX | PENDING | Mortal Strike particle path is wired and present in installed VPK; actual playback/attachment pending. |
| SFX | PENDING | CriticalStrike event is wired; audible output and frequency need engine test. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | EN/TR/RU/zh-CN descriptions now include crit and cleave values; generated tokens validate, HUD display pending. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-29; rank migration 2026-09-30): expanded crit chance/multiplier and bounded cleave values to ten ranks; the passive now returns no critical bonus under Break. Mock test covers proc and secondary damage; attack-event order, animation, VFX/SFX and dense-wave behavior remain PENDING.

## Slot 4: `enfos_wk_reincarnation`

Classification: PVE-CONVERT
Native counterpart: `skeleton_king_reincarnation` (installed ClientVersion 6941 source snapshot).
Decision and PvE identity rationale: Preserve Reincarnation as the ultimate and keep the custom death burst. Respawn delay, Strength scaling, radius, slow and normal/boss durations are KV-backed; the resurrection particle and sound are wired.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: R ranks 1–10 are gated at levels 5, 10, …, 50. Point cost and actual unlock behavior: PENDING in-engine validation.
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
| Gameplay | PENDING | Mock verifies configured reincarnation delay, burst damage and separate boss slow; native death callback/cooldown behavior pending. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | All five KV entries now expose ten ranks and the suite clamps/smoke-tests the roster through rank 10; actual in-match point/unlock pacing to level 50 remains pending. |
| VFX | PENDING | Reincarnation particle path is present and wired; position, size and lifecycle require engine test. |
| SFX | PENDING | Reincarnate event is wired; audible playback requires engine test. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Separate boss slow duration is covered by mock; full boss burst/status behavior pending. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | EN/TR/RU/zh-CN descriptions use configured values; generated tokens validate, HUD display pending. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-29; rank migration 2026-09-30): expanded R cooldown, burst, slow and boss-duration curves to ten ranks and made Reincarnation honor Break. Regression covers delay, burst and boss duration; engine death callback, VFX/SFX and Scepter interactions remain PENDING.

## Slot 2: `enfos_wk_skeleton_army`

Classification: PVE-CONVERT
Native counterpart: `skeleton_king_bone_guard` (native Ability2, verified from installed source; separate from the custom slot-5/passive grant).
Decision and PvE identity rationale: Preserve the native skeleton-summon identity as an Enfos kill-charge passive with an active summon release. Count, duration and skeleton combat stats are KV-backed; friendly deaths do not grant charges, and Break stops passive charge generation. Its cast uses a separate event from Q.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: the Enfos passive is slot 5 (Vampiric Aura) and starts at rank 1 through the separate passive grant; Skeleton Army is an active slot-2 ability with ranks 1–10 gated at hero levels 1–10. Point cost and actual unlock behavior: PENDING in-engine validation.
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
| Gameplay | PENDING | Mock verifies kill-charge cap and friendly-death filter; the shared summon helper now honors rank-10's 12-skeleton KV cap with a distinct formation. Dota spawn reliability, owner control, recast cleanup and shard behavior remain pending. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | All five KV entries now expose ten ranks and the suite clamps/smoke-tests the roster through rank 10; actual in-match point/unlock pacing to level 50 remains pending. |
| VFX | PENDING | Summon appearance uses the custom skeleton unit; cast feedback and in-game presentation need review. |
| SFX | PENDING | Summon cast now uses the Wraith King Reincarnate event instead of Q Hellfire Blast; audible suitability pending. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Kill-charge passive is KV-capped and ignores friendly deaths; Break/respawn behavior remains pending. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | EN/TR/RU/zh-CN now describe kill charges, summon stats and duration; generated tokens validate, HUD display pending. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record (2026-09-29; rank migration 2026-09-30): removed the Dota Innate marker, expanded summon caps/stats/cooldown to ten ranks and made passive charge generation honor Break. Regression covers enemy-only charge and cap; summon control, recast cleanup, shard and in-engine presentation remain PENDING.

2026-09-30 level-cap integration: all five Wraith King abilities now have explicit KV gates. Q/W/E and the Enfos passive use one rank per level; the free Enfos passive rank 1 is still granted by the separate Enfos system. Reincarnation uses levels 5, 10, …, 50 so rank 10 fits the level cap. Static KV contract passes; engine level-up buttons, rank grants, ultimate HUD marker and point pacing remain PENDING for owner testing.

2026-09-30 static Break/aura correction: Wraith King's custom passive components checked `PassivesDisabled()` in Lua, but Skeleton Army, Mortal Strike, Reincarnation and Vampiric Aura were missing the KV `IsBreakable` declaration. Added the declaration to those four entries. Vampiric Aura also explicitly excludes Wraith King from its own recipient aura and handles his landed attacks on the intrinsic modifier, so the owner receives one lifesteal application without relying on aura self-inclusion. Regression and KV contract now cover owner/ally lifesteal, Break suppression and all four breakability declarations. In-engine Break and aura propagation remain PENDING.

## 2026-10-02 individual source review closure — engine pending

Current installed6943 native comparison and complete five-slot review: [Wraith King individual review](../../audit/WRAITH_KING_INDIVIDUAL_REVIEW_2026-10-02.md). All five retain evidence-backed PVE-CONVERT classifications and recognizable stun/kill-charge skeletons/critical attacks/rebirth/lifesteal identity. Fixed Q/R post-lethal/stale guards and Q midflight allied rejection; per-record critical caching/lethal splash/finite native impact; lethal-attack lifesteal and model-child CP1; native Q/W cast declarations/strong stun dispel/bank preload; zero native summon rewards; eight modifier icons/four authored status sets and missing QDoT Strength description. Current source/rank/property checks and251behavior tests pass. Current native definitions/model/particle/sound evidence replaces old6941 discovery assumptions; detailed ledger explicitly distinguishes absent native facet/curse/wraith upgrades from current shared Fighter Shard/Scepter contract.

All five source acceptance areas have individual evidence in that record. Every gameplay/VFX/SFX/animation/precache/cleanup/tooltip/upgrade/rank/reconnect/VConsole engine area remains OWNER ENGINE PENDING. In particular, possible Q projectile endcap/explicit impact duplication, Esecondary immunity selection and W/R audio phase suitability remain owner checks, not claimed resolved from mocks. No talent/account progression, unrelated hero rewrite or publication.
