# Troll Warlord: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_troll_warlord`; role: Fighter. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_troll_berserkers_rage` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET \| DOTA_ABILITY_BEHAVIOR_TOGGLE | abilities/pve_kits | troll_warlord_berserkers_rage |
| 2 | `enfos_troll_whirling_axes` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | troll_warlord_whirling_axes_melee |
| 3 | `enfos_troll_fervor` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | troll_warlord_fervor |
| 4 | `enfos_troll_battle_trance` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | troll_warlord_battle_trance |
| 5 | `enfos_troll_rampage` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | troll_warlord_rampage |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_troll_warlord.txt`; status: FILE_VERIFIED; SHA256: `e0ee0f9b42f07cc6924e422f831d85dde557cb40dccbd4a9eea1c058c894f722`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/troll_warlord/troll_warlord.vmdl` |
| SoundSet | `Hero_TrollWarlord` |
| Ability1 | `troll_warlord_switch_stance` |
| Ability2 | `troll_warlord_whirling_axes_ranged` |
| Ability3 | `troll_warlord_whirling_axes_melee` |
| Ability4 | `troll_warlord_fervor` |
| Ability5 | `troll_warlord_berserkers_rage` |
| Ability6 | `troll_warlord_battle_trance` |
| Ability10 | `special_bonus_unique_troll_warlord_whirling_axes_debuff_duration` |
| Ability11 | `special_bonus_unique_troll_warlord_2` |
| Ability12 | `special_bonus_unique_troll_warlord_5` |
| Ability13 | `special_bonus_unique_troll_warlord` |
| Ability14 | `special_bonus_unique_troll_warlord_battle_trance_movespeed` |
| Ability15 | `special_bonus_unique_troll_warlord_3` |
| Ability16 | `special_bonus_unique_troll_warlord_6` |
| Ability17 | `special_bonus_unique_troll_warlord_4` |
| AttributeStrengthGain | `2.500000` |
| AttributeAgilityGain | `3.30000` |
| AttributeIntelligenceGain | `1.000000` |

### Per-ability review leads

- `enfos_troll_berserkers_rage`: toggle state, mana drain, death/respawn cleanup.
- `enfos_troll_whirling_axes`: cast/impact/modifier contract and lifetime.
- `enfos_troll_fervor`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `enfos_troll_battle_trance`: ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_troll_rampage`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-09-30 level-50 migration: Q/W/E/Rampage gates are level 1 +1; Battle Trance is level 5 +5; rank 10 is available by level 50. Static contract passes; engine point/UI acceptance is pending. 2026-09-30 static special-value repair: migrated each of Troll Warlord's five Lua-read ability definitions to named `AbilityValues`, keeping the existing 10-rank curves and scalars intact. Added a content contract for all five slots. The installed source documents Troll's native stance/axe/passive/ultimate identity; this migration does not validate stance switching, attack procs, audio or visuals in Dota. The user owns those live checks.

2026-09-30 Fervor Break repair: existing stacks still granted attack speed while PassivesDisabled was active, even though new stacks were already suppressed. The attack-speed property now returns zero during Break and resumes from the retained stacks after Break ends. Mock regression verifies the active value, Break suppression, stack retention and resumed value; all 191 hero-kit mock regressions pass. Dota/VConsole/visual/audio acceptance remains PENDING.

## Slot 1: `enfos_troll_berserkers_rage`

Classification: PVE-CONVERT
Native counterpart: troll_warlord_berserkers_rage (installed native Ability5; source snapshot ClientVersion 6941 / SourceRevision 11041083).
Decision and PvE identity rationale: Preserve the signature ranged/melee stance toggle. Fix the custom melee attack capability lifecycle and use rank-backed armor, movement, proc chance, physical proc damage and boss-limited stun.
Expected cast/travel/impact/ongoing/cleanup behavior: Toggle sound and attached stance buff; switch attack capability while active and retain it through death; enemy landed hits can proc configured physical bonus and a registered Troll-specific stun modifier. Turning it off restores ranged capability.
Normal/elite/boss: Whirling Axes and Berserker proc have configured duration caps against bosses; other effects retain PvE rank behavior. Immunity, dispel, target-switch and CC resistance require live Dota confirmation.
Current versus target rank curve; free rank / point cost: 10 KV ranks; armor 3→12, movement 10→46, proc chance 10→22%, proc damage 30→120 plus Agility x 0.4→1, boss stun capped 0.2→0.45s. Rank gates are now configured: Q/W/E/Enfos passive start at level 1 and gain a rank each level; R starts at level 5 and gains a rank every 5 levels. Rank 10 is available by level 50. Engine rank/point UI remains pending.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING engine review; this pass changes no upgrade handler.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: verified from installed Troll Warlord snapshot in this dossier (ClientVersion 6941 / SourceRevision 11041083).
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: troll_warlord_rampage_attack_speed_buff.vpcf for the stance, generic_stunned.vpcf on proc; both present in installed VPK and explicitly precached.
- Sound events + declaring banks + emission target + loop termination: existing Hero_TrollWarlord sound calls retained; actual event playback remains pending runtime test.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: used particles registered in addon_game_mode.lua; VPK verification passed, cold-start Dota test pending.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated EN/TR/RU/zh-CN mirrors: updated; localization generator passed.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Not evaluated in this dossier setup. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Static KV gate contract passes and places rank 10 by level 50; owner must verify engine ability-point/UI behavior in a live match. |
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

Change/test record: 2026-09-30 — ten-rank KV/Lua update; Troll Berserker toggle/proc, Whirling Axes rank/blind/boss cap, Fervor same-target/reset/Break, Battle Trance values/ally guard and Rampage/Break tests pass in the current 191-test hero-kit mock suite. Five hero particles plus generic stun particle are present in installed Valve VPK; content/localization/project checks pass. Dota/VConsole/visual/audio runtime acceptance remains PENDING.

## Slot 2: `enfos_troll_whirling_axes`

Classification: PVE-CONVERT
Native counterpart: troll_warlord_whirling_axes_melee (installed native Ability3; ranged axes are native Ability2 and are not this implementation).
Decision and PvE identity rationale: Keep the melee spin’s point-blank PvE wave clear and blind; tune radius/damage and make blind strength and boss duration explicit.
Expected cast/travel/impact/ongoing/cleanup behavior: No-target cast sound and spinner particle; enemies in KV radius take magical base damage plus Agility factor and receive a miss-chance debuff, with boss duration cap.
Normal/elite/boss: Whirling Axes and Berserker proc have configured duration caps against bosses; other effects retain PvE rank behavior. Immunity, dispel, target-switch and CC resistance require live Dota confirmation.
Current versus target rank curve; free rank / point cost: 10 KV ranks; radius 450→600, base magic damage 90→360 plus Agility x 0.8, blind 20→56%, duration 2→4.5s. Rank gates are now configured: Q/W/E/Enfos passive start at level 1 and gain a rank each level; R starts at level 5 and gains a rank every 5 levels. Rank 10 is available by level 50. Engine rank/point UI remains pending.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING engine review; this pass changes no upgrade handler.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: verified from installed Troll Warlord snapshot in this dossier (ClientVersion 6941 / SourceRevision 11041083).
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: troll_warlord_whirling_axe_melee.vpcf; present in installed VPK and precached.
- Sound events + declaring banks + emission target + loop termination: existing Hero_TrollWarlord sound calls retained; actual event playback remains pending runtime test.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: used particles registered in addon_game_mode.lua; VPK verification passed, cold-start Dota test pending.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated EN/TR/RU/zh-CN mirrors: updated; localization generator passed.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Not evaluated in this dossier setup. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Static KV gate contract passes and places rank 10 by level 50; owner must verify engine ability-point/UI behavior in a live match. |
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

## Slot 3: `enfos_troll_fervor`

Classification: PVE-CONVERT
Native counterpart: troll_warlord_fervor (installed native Ability4; custom slot3).
Decision and PvE identity rationale: Retain repeated-attack haste, make rank-per-stack explicit, reset when changing targets, and stop counting allied hits or attacks while broken.
Expected cast/travel/impact/ongoing/cleanup behavior: Intrinsic counter records living enemy hits from the real Troll; stacks build on the same target up to KV cap and reset on retarget; attack speed is stacks times the rank value.
Normal/elite/boss: Whirling Axes and Berserker proc have configured duration caps against bosses; other effects retain PvE rank behavior. Immunity, dispel, target-switch and CC resistance require live Dota confirmation.
Current versus target rank curve; free rank / point cost: 10 KV ranks; 10-hit cap and per-stack speed 4→14 (maximum 40→140). Rank gates are now configured: Q/W/E/Enfos passive start at level 1 and gain a rank each level; R starts at level 5 and gains a rank every 5 levels. Rank 10 is available by level 50. Engine rank/point UI remains pending.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING engine review; this pass changes no upgrade handler.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: verified from installed Troll Warlord snapshot in this dossier (ClientVersion 6941 / SourceRevision 11041083).
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: Rampage attack-speed buff particle appears when stacks exist; VPK-verified and precached.
- Sound events + declaring banks + emission target + loop termination: existing Hero_TrollWarlord sound calls retained; actual event playback remains pending runtime test.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: used particles registered in addon_game_mode.lua; VPK verification passed, cold-start Dota test pending.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated EN/TR/RU/zh-CN mirrors: updated; localization generator passed.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Mock regression confirms Fervor stacks reset on retarget and existing attack speed is suppressed by Break then resumes after Break. Actual Dota attack-event ordering and buff display remain unverified. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Static KV gate contract passes and places rank 10 by level 50; owner must verify engine ability-point/UI behavior in a live match. |
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

Change/test record (2026-09-30): repaired the attack-speed property so existing Fervor stacks no longer grant haste under Break; the stacks persist and resume afterward. Mock suite passes. Engine attack behavior, VFX/audio and buff display remain PENDING.

## Slot 4: `enfos_troll_battle_trance`

Classification: PVE-CONVERT
Native counterpart: troll_warlord_battle_trance (installed native Ability6; custom slot4).
Decision and PvE identity rationale: Keep the self-only unstoppable battle window, make attack/movement speed and enemy-hit healing rank-based; do not heal from friendly attacks.
Expected cast/travel/impact/ongoing/cleanup behavior: Cast sound and cast/buff particles; duration, attack/movement speed and attack healing read from KV; minimum health remains one during buff and expiry removes its attached effect.
Normal/elite/boss: Whirling Axes and Berserker proc have configured duration caps against bosses; other effects retain PvE rank behavior. Immunity, dispel, target-switch and CC resistance require live Dota confirmation.
Current versus target rank curve; free rank / point cost: 10 KV ranks; attack speed 100→280, duration 3.5→7s, movement 15→45%, enemy-damage healing 20→50%. Rank gates are now configured: Q/W/E/Enfos passive start at level 1 and gain a rank each level; R starts at level 5 and gains a rank every 5 levels. Rank 10 is available by level 50. Engine rank/point UI remains pending.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING engine review; this pass changes no upgrade handler.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: verified from installed Troll Warlord snapshot in this dossier (ClientVersion 6941 / SourceRevision 11041083).
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: troll_warlord_battletrance_cast.vpcf and troll_warlord_battletrance_buff.vpcf; installed VPK assets and precached.
- Sound events + declaring banks + emission target + loop termination: existing Hero_TrollWarlord sound calls retained; actual event playback remains pending runtime test.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: used particles registered in addon_game_mode.lua; VPK verification passed, cold-start Dota test pending.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated EN/TR/RU/zh-CN mirrors: updated; localization generator passed.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Not evaluated in this dossier setup. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Static KV gate contract passes and places rank 10 by level 50; owner must verify engine ability-point/UI behavior in a live match. |
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

## Slot 5: `enfos_troll_rampage`

Classification: PVE-CONVERT
Native counterpart: No Enfos fifth-slot counterpart in native Troll ability fields; it is a custom Enfos passive, separate from Dota innate metadata.
Decision and PvE identity rationale: Keep the Enfos damage/resistance passive while making it rank-based, visible, breakable, and not falsely labeled as Dota Innate.
Expected cast/travel/impact/ongoing/cleanup behavior: Intrinsic modifier grants preattack damage and status resistance while passives are enabled; resistance buff particle follows the hero.
Normal/elite/boss: Whirling Axes and Berserker proc have configured duration caps against bosses; other effects retain PvE rank behavior. Immunity, dispel, target-switch and CC resistance require live Dota confirmation.
Current versus target rank curve; free rank / point cost: 10 KV ranks; bonus damage 10→100, status resistance 2→20%. The Enfos innates manager grants its initial rank; its remaining rank gates are level 2–10. Rank 10 is available by level 50. Engine rank/point UI remains pending.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING engine review; this pass changes no upgrade handler.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: verified from installed Troll Warlord snapshot in this dossier (ClientVersion 6941 / SourceRevision 11041083).
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: troll_warlord_rampage_resistance_buff.vpcf; installed VPK asset and precached.
- Sound events + declaring banks + emission target + loop termination: existing Hero_TrollWarlord sound calls retained; actual event playback remains pending runtime test.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: used particles registered in addon_game_mode.lua; VPK verification passed, cold-start Dota test pending.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated EN/TR/RU/zh-CN mirrors: updated; localization generator passed.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Not evaluated in this dossier setup. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Static KV gate contract passes and places rank 10 by level 50; owner must verify engine ability-point/UI behavior in a live match. |
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

2026-09-30 global Break metadata audit: Added KV `IsBreakable 1` to `enfos_troll_fervor`, `enfos_troll_rampage` because its linked Lua passive implementation check `PassivesDisabled()`. Automated content validation now rejects this metadata mismatch. Actual Dota Break behavior remains PENDING.
