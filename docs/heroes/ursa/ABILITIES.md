# Ursa: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_ursa`; role: Fighter. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_ursa_earthshock` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | ursa_earthshock |
| 2 | `enfos_ursa_overpower` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | ursa_overpower |
| 3 | `enfos_ursa_fury_swipes` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | ursa_fury_swipes |
| 4 | `enfos_ursa_enrage` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | ursa_enrage |
| 5 | `enfos_ursa_ursa_minor` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | ursa_fury_swipes |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_ursa.txt`; status: FILE_VERIFIED; SHA256: `613c2cefe0a70e0a5582c5dd9def317fb93da2a346d0da650070a147b4faad9a`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/ursa/ursa.vmdl` |
| SoundSet | `Hero_Ursa` |
| Ability1 | `ursa_earthshock` |
| Ability2 | `ursa_overpower` |
| Ability3 | `ursa_fury_swipes` |
| Ability4 | `ursa_maul` |
| Ability5 | `generic_hidden` |
| Ability6 | `ursa_enrage` |
| Ability10 | `special_bonus_unique_ursa_4` |
| Ability11 | `special_bonus_mp_regen_175` |
| Ability12 | `special_bonus_unique_ursa_maul_health` |
| Ability13 | `special_bonus_unique_ursa_8` |
| Ability14 | `special_bonus_unique_ursa_2` |
| Ability15 | `special_bonus_unique_ursa` |
| Ability16 | `special_bonus_unique_ursa_3` |
| Ability17 | `special_bonus_unique_ursa_7` |
| AttributeStrengthGain | `2.4` |
| AttributeAgilityGain | `2.8` |
| AttributeIntelligenceGain | `1.5` |

### Per-ability review leads

- `enfos_ursa_earthshock`: cast/impact/modifier contract and lifetime.
- `enfos_ursa_overpower`: cast/impact/modifier contract and lifetime.
- `enfos_ursa_fury_swipes`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `enfos_ursa_enrage`: ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_ursa_ursa_minor`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-10-02 source review: installed hero KV declares `GameSoundsFile` as `soundevents/game_sounds_heroes/game_sounds_ursa.vsndevts`; this bank was absent from startup precache although the kit emits Earthshock, Overpower and Enrage events from it. Added Ursa to the shared native bank list. Native AbilityDefinitions specify Earthshock `ACT_DOTA_CAST_ABILITY_1`, Overpower `ACT_DOTA_OVERRIDE_ABILITY_3`, and Enrage `ACT_DOTA_OVERRIDE_ABILITY_4`; these presentation fields were missing from the Enfos active abilities and are now explicit. Static checks cover the values and bank registration. Dota animation and cold-client sound playback remain PENDING owner test.

2026-09-30 static special-value repair: migrated all five Ursa abilities to named `AbilityValues`, preserving the authored ten-rank arrays and scalar values. Added a content contract preventing a return to legacy Lua-read KV fields. Existing combat mocks cover selected Ursa mechanics; this schema migration is not a Dota test. The user owns in-game behavior, audio and VFX checks.

## Slot 1: `enfos_ursa_earthshock`

Classification: PVE-CONVERT
Native counterpart: ursa_earthshock (installed native Ability1; Ursa source snapshot, ClientVersion 6941 / SourceRevision 11041083).
Decision and PvE identity rationale: Keep the recognizable point-blank ground slam, physical damage, and slow; convert it for PvE with ten ranks, Strength scaling, configurable radius/slow, and a shorter boss slow cap.
Expected cast/travel/impact/ongoing/cleanup behavior: No-target cast emits Hero_Ursa.Earthshock and the verified ursa_earthshock particle; damage and slow only enemies in KV radius; slow expires with modifier and boss duration is capped.
Normal/elite/boss: enemies only; Fury Swipes has a separate boss stack cap, Earthshock has a boss slow cap. Engine immunity, dispel and resistance interactions remain to be confirmed in Dota.
Current versus target rank curve; free rank / point cost: 10 ranks in KV; damage 120→660, radius 385, Strength factor 1.5. Q rank gates at levels 1–10 are now declared; in-game points/HUD remain pending.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING engine review; no upgrade handler was changed in this pass.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: verified from installed Ursa snapshot in this dossier (ClientVersion 6941 / SourceRevision 11041083).
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: particles/units/heroes/hero_ursa/ursa_earthshock.vpcf; present in installed ClientVersion 6941 VPK and registered for precache.
- Sound events + declaring banks + emission target + loop termination: existing Hero_Ursa event emitted; event bank/playback and in-game audio remain pending runtime verification.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: registered in addon_game_mode.lua; VPK asset lookup passed, cold-start Dota test pending.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated EN/TR/RU/zh-CN mirrors: updated and localization generator passed.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Not evaluated in this dossier setup. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Q gate levels 1–10 declared; HUD and point behavior remain PENDING. |
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

Change/test record: 2026-09-30 — ten-rank KV/Lua update. Current hero-kit suite passes 190 mocked regressions, including Ursa radius/damage/boss slow, Overpower enemy-only charge use, Fury Swipes rank scaling/cap/cleave, and Enrage values/Break. All five used particles are present in the installed Valve VPK; project localization and ability-contract checks pass. No Dota/VConsole playtest was performed, so visual/audio/game acceptance remains PENDING. A mock pass is not ENGINE_PASS.

## Slot 2: `enfos_ursa_overpower`

Classification: PVE-CONVERT
Native counterpart: ursa_overpower (installed native Ability2; same source snapshot).
Decision and PvE identity rationale: Preserve Ursa’s rapid-attack window while scaling attack speed and attack charges over ten ranks; heal only from landed attacks on living enemies.
Expected cast/travel/impact/ongoing/cleanup behavior: No-target cast applies the buff particle, attack-speed bonus, duration and charge count from KV; enemy attacks consume one charge and heal by configured share of landed damage; allied attacks do not consume charges.
Normal/elite/boss: enemies only; Fury Swipes has a separate boss stack cap, Earthshock has a boss slow cap. Engine immunity, dispel and resistance interactions remain to be confirmed in Dota.
Current versus target rank curve; free rank / point cost: 10 ranks in KV; charges 3→10, attack speed 350→800, duration 8→15s, attack-heal share 10→28%. Rank gates at levels 1–10 are now declared; in-game points/HUD remain pending.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING engine review; no upgrade handler was changed in this pass.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: verified from installed Ursa snapshot in this dossier (ClientVersion 6941 / SourceRevision 11041083).
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: particles/units/heroes/hero_ursa/ursa_overpower_buff.vpcf; present in installed ClientVersion 6941 VPK and registered for precache.
- Sound events + declaring banks + emission target + loop termination: existing Hero_Ursa event emitted; event bank/playback and in-game audio remain pending runtime verification.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: registered in addon_game_mode.lua; VPK asset lookup passed, cold-start Dota test pending.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated EN/TR/RU/zh-CN mirrors: updated and localization generator passed.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Not evaluated in this dossier setup. |
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
| Localization | PENDING | Not evaluated in this dossier setup. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 3: `enfos_ursa_fury_swipes`

Classification: PVE-CONVERT
Native counterpart: ursa_fury_swipes (installed native Ability3; same source snapshot).
Decision and PvE identity rationale: Retain stacking claw hits, tune their per-rank damage for PvE, cap stacks separately for bosses, add a configurable cleave, and disable on Break.
Expected cast/travel/impact/ongoing/cleanup behavior: A landed attack by a non-illusion Ursa against a living enemy increases/refreshes the owned debuff to its normal or boss cap, deals rank-based physical bonus damage, and cleaves nearby enemies; both hit and debuff particles are verified VPK assets.
Normal/elite/boss: enemies only; Fury Swipes has a separate boss stack cap, Earthshock has a boss slow cap. Engine immunity, dispel and resistance interactions remain to be confirmed in Dota.
Current versus target rank curve; free rank / point cost: 10 ranks in KV; per-stack base bonus 20→92, Agility factor 0.15, 12→50 normal cap, 8→25 boss cap, cleave 20→47%. The shared level-50 XP/point curve is implemented; engine point/HUD behavior remains pending owner verification.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING engine review; no upgrade handler was changed in this pass.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: verified from installed Ursa snapshot in this dossier (ClientVersion 6941 / SourceRevision 11041083).
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: ursa_fury_swipes.vpcf and ursa_fury_swipes_debuff.vpcf; both present in installed ClientVersion 6941 VPK and registered for precache.
- Sound events + declaring banks + emission target + loop termination: existing Hero_Ursa event emitted; event bank/playback and in-game audio remain pending runtime verification.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: registered in addon_game_mode.lua; VPK asset lookup passed, cold-start Dota test pending.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated EN/TR/RU/zh-CN mirrors: updated and localization generator passed.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Not evaluated in this dossier setup. |
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
| Localization | PENDING | Not evaluated in this dossier setup. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 4: `enfos_ursa_enrage`

Classification: TUNE
Native counterpart: ursa_enrage (installed native Ability6; same source snapshot).
Decision and PvE identity rationale: Keep the recognizable self-buff and purge while making ten-rank mitigation, duration and status resistance explicit and KV-driven.
Expected cast/travel/impact/ongoing/cleanup behavior: Cast sound, purge, and attached Enrage buff; incoming damage reduction and status resistance read current rank values and end with the modifier.
Normal/elite/boss: enemies only; Fury Swipes has a separate boss stack cap, Earthshock has a boss slow cap. Engine immunity, dispel and resistance interactions remain to be confirmed in Dota.
Current versus target rank curve; free rank / point cost: 10 ranks in KV; duration 4.5→8s, reduction 60→90%, status resistance 20→60%. The shared level-50 XP/point curve is implemented; engine point/HUD behavior remains pending owner verification.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING engine review; no upgrade handler was changed in this pass.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: verified from installed Ursa snapshot in this dossier (ClientVersion 6941 / SourceRevision 11041083).
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf; present in installed ClientVersion 6941 VPK and registered for precache.
- Sound events + declaring banks + emission target + loop termination: existing Hero_Ursa event emitted; event bank/playback and in-game audio remain pending runtime verification.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: registered in addon_game_mode.lua; VPK asset lookup passed, cold-start Dota test pending.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated EN/TR/RU/zh-CN mirrors: updated and localization generator passed.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Not evaluated in this dossier setup. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | R gate levels 5–50 in five-level steps declared; ultimate HUD/point behavior remains PENDING. |
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

## Slot 5: `enfos_ursa_ursa_minor`

Classification: TUNE
Native counterpart: No Ursa native Ability5 (installed field is generic_hidden); explicitly an Enfos-only fifth-slot passive, separate from Dota Innate.
Decision and PvE identity rationale: Preserve the current mobility passive as Ursa’s Enfos identity layer; remove the incorrect Innate metadata and the tooltip’s unsupported lifesteal claim; honor Break.
Expected cast/travel/impact/ongoing/cleanup behavior: Intrinsic passive grants rank-based constant movement speed and returns zero while PassivesDisabled is active.
Normal/elite/boss: enemies only; Fury Swipes has a separate boss stack cap, Earthshock has a boss slow cap. Engine immunity, dispel and resistance interactions remain to be confirmed in Dota.
Current versus target rank curve; free rank / point cost: 10 ranks in KV; movement bonus 8→30. Initial free rank remains granted by the separate Enfos manager; ranks 2–10 are gated at levels 2–10; in-game point/HUD behavior remains pending.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING engine review; no upgrade handler was changed in this pass.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: verified from installed Ursa snapshot in this dossier (ClientVersion 6941 / SourceRevision 11041083).
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: No dedicated particle or sound is required for this numeric mobility passive.
- Sound events + declaring banks + emission target + loop termination: existing Hero_Ursa event emitted; event bank/playback and in-game audio remain pending runtime verification.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: registered in addon_game_mode.lua; VPK asset lookup passed, cold-start Dota test pending.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated EN/TR/RU/zh-CN mirrors: updated and localization generator passed.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Not evaluated in this dossier setup. |
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
| Localization | PENDING | Not evaluated in this dossier setup. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

2026-09-30 level-cap integration: all five Ursa abilities now declare KV rank gates. Q/W/E and the Enfos passive use one rank per level; passive rank 1 remains a separate Enfos grant. Enrage ranks 1–10 unlock on levels 5, 10, …, 50. Static KV contract passes; actual rank buttons, level-up points, ultimate badge and match-start level 6 remain PENDING for owner testing.

2026-09-30 follow-up audit: Fury Swipes stacks are now looked up by both
modifier name and Ursa caster, so two Ursas cannot share or overwrite each
other's target stacks. Its physical cleave search includes magic-immune enemy
units. Fury Swipes and the fifth-slot Ursa Minor declare `IsBreakable 1`,
matching the Lua passive checks; Ursa Minor's move-speed bonus also suppresses
on illusions. Mock regressions cover caster-separated stacks, the physical
cleave target flag and the existing Break behavior. Actual Dota verification of
these interactions remains pending.
