# Monkey King: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_monkey_king`; role: Fighter. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_mk_boundless_strike` | 10 | DOTA_ABILITY_BEHAVIOR_POINT \| DOTA_ABILITY_BEHAVIOR_DIRECTIONAL | abilities/pve_kits | monkey_king_boundless_strike |
| 2 | `enfos_mk_primal_spring` | 10 | DOTA_ABILITY_BEHAVIOR_POINT | abilities/pve_kits | monkey_king_primal_spring |
| 3 | `enfos_mk_jingu_mastery` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | monkey_king_jingu_mastery |
| 4 | `enfos_mk_wukongs_command` | 10 | DOTA_ABILITY_BEHAVIOR_POINT | abilities/pve_kits | monkey_king_wukongs_command |
| 5 | `enfos_mk_mischief` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | monkey_king_mischief |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_monkey_king.txt`; status: FILE_VERIFIED; SHA256: `6d7a10c3601871804fe1a69420f26192f09ff2267e138eb9799371bd448313a6`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/monkey_king/monkey_king.vmdl` |
| SoundSet | `Hero_MonkeyKing` |
| Ability1 | `monkey_king_boundless_strike` |
| Ability2 | `monkey_king_tree_dance` |
| Ability3 | `monkey_king_primal_spring` |
| Ability4 | `monkey_king_jingu_mastery` |
| Ability5 | `monkey_king_mischief` |
| Ability6 | `monkey_king_wukongs_command` |
| Ability7 | `monkey_king_primal_spring_early` |
| Ability8 | `monkey_king_untransform` |
| Ability9 | `monkey_king_transfiguration` |
| Ability10 | `special_bonus_unique_monkey_king_7` |
| Ability11 | `special_bonus_unique_monkey_king_9` |
| Ability12 | `special_bonus_unique_monkey_king_8` |
| Ability13 | `special_bonus_unique_monkey_king_2` |
| Ability14 | `special_bonus_unique_monkey_king_3` |
| Ability15 | `special_bonus_unique_monkey_king_10` |
| Ability16 | `special_bonus_unique_monkey_king_11` |
| Ability17 | `special_bonus_unique_monkey_king_6` |
| AttributeStrengthGain | `2.8` |
| AttributeAgilityGain | `3.700000` |
| AttributeIntelligenceGain | `1.8` |

### Per-ability review leads

- `enfos_mk_boundless_strike`: world position, travel/impact timing and radius alignment.
- `enfos_mk_primal_spring`: world position, travel/impact timing and radius alignment.
- `enfos_mk_jingu_mastery`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `enfos_mk_wukongs_command`: world position, travel/impact timing and radius alignment; ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_mk_mischief`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-10-04 native-first discovery: installed6943/revision11069754 freshly
read, unchanged SHA2566d7a10c...313a6; nine definitions, three deprecated facets,
native English tokens and ten compiled resources hashed in the [current
snapshot](../../audit/MONKEY_KING_NATIVE_SOURCE_2026-10-04.json). [Pre-mutation
five-slot matrix and provenance](../../audit/MONKEY_KING_NATIVE_FIRST_REVIEW_2026-10-04.md)
records Q TUNE/native candidate, W REPLACE/native tree-channel linkage, E/R
PVE-CONVERT hero-only restrictions, D KEEP authored passive plus separate native
Mischief innate. Production remains CUSTOM Lua below; no source migration or
engine PASS. Jingu per-target hero-only acquisition and soldier hero-only
targeting are explicit technical gates, not solved by unverified KV flags.
Existing level/point/restore/client services retained. Next focused Q/link
research; all skill/upgrades/lifecycle/presentation acceptance stays PENDING.


2026-10-02 source review: the installed hero KV maps its native sound bank to `soundevents/game_sounds_heroes/game_sounds_monkey_king.vsndevts`; the Enfos kit emits multiple `Hero_MonkeyKing` events but the bank was absent from startup precache. Added it. Native Boundless Strike AbilityDefinitions specify the distinct `ACT_DOTA_MK_STRIKE` gesture, which was missing from the custom ability KV and is now set. Native Primal Spring and Wukong's Command specify `ACT_INVALID`; no guessed animation was added for those conversions. Static checks cover Boundless Strike and bank registration; rendered gesture and live sound playback remain PENDING owner Dota/VConsole review.

2026-09-30 Boundless Strike targeting repair: a cursor position equal to Monkey King's origin produced a zero-length direction. Lua now falls back to the caster's facing after flattening the vector to the ground plane. A mock regression sets facing along Y and confirms the strike hits the enemy along that line when the cursor is at the caster. The current hero-kit mock suite passes 191 tests. In-game targeting, display, animation, audio, damage balance and rank/HUD checks remain PENDING for owner testing.

2026-09-30 static special-value repair: moved Lua-read values for all five Monkey King abilities from numbered `AbilitySpecial` to named `AbilityValues`, preserving ten-rank curves and scalars. Added a five-slot content contract. This addresses the value-loading failure observed on Sven in the installed Dota build; Monkey King gameplay, VFX, audio and summon behavior remain for the user to test in-game.

## Slot 1: `enfos_mk_boundless_strike`

Classification: PVE-CONVERT
Native counterpart: monkey_king_boundless_strike (installed native Ability1; Monkey King source snapshot, ClientVersion 6941 / SourceRevision 11041083).
Decision and PvE identity rationale: Keep the signature staff line strike; convert targeting to a verified line query instead of a broad offset circle, use attack-damage percentage from KV, and cap boss stun.
Expected cast/travel/impact/ongoing/cleanup behavior: Directional line from caster to configured endpoint; cast and per-hit particles; physical damage; normal/boss stun durations from KV; one-shot particles are released.
Normal/elite/boss rules: Boundless Strike caps stun against bosses; the other effects use configured area/rank rules. Dota immunity, status resistance, dispel and elite interactions remain pending actual-engine validation.
Current versus target rank curve; free rank / point cost: 10 KV ranks; attack damage 150→300%, range 1200, width 150, standard stun 0.8→1.7s and boss stun 0.4→0.85s. Boundless Strike Q ranks 1–10 are gated at levels 1–10; engine HUD/point behavior remains pending.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING engine review; no upgrade handler was changed in this pass.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: verified from installed Monkey King snapshot in this dossier (ClientVersion 6941 / SourceRevision 11041083).
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: monkey_king_strike.vpcf and mk_strike_path_pulse_hit.vpcf; both present in installed ClientVersion 6941 VPK and registered for precache.
- Sound events + declaring banks + emission target + loop termination: existing Hero_MonkeyKing events are emitted by the cast code; installed sound bank exists, exact in-game event playback remains pending.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: all referenced particles registered in addon_game_mode.lua; VPK lookup passed, cold-start Dota test pending.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated EN/TR/RU/zh-CN mirrors: updated; localization generator passed.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Not evaluated in this dossier setup. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Q gate levels 1–10 declared; HUD/point behavior remains PENDING. |
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

Change/test record: 2026-09-30 — ten-rank KV/Lua update; 118 Lua mock regressions pass (Boundless Strike line/rank damage/boss stun, Primal Spring damage/area/slow, Jingu enemy hit charges/heal, Wukong ring radius/interval, Mischief Break). Seven used Monkey King particles found in installed Valve VPK; localization and content-contract checks pass. No Dota/VConsole playtest was performed, so actual visual/audio/game acceptance remains PENDING. A mock pass is not ENGINE_PASS.

## Slot 2: `enfos_mk_primal_spring`

Classification: PVE-CONVERT
Native counterpart: monkey_king_primal_spring (installed native Ability3; same source snapshot; custom slot 2 is not native ability slot 2).
Decision and PvE identity rationale: Retain the iconic target relocation and impact AoE, preserve physical damage and turn the existing fixed agility scaling, radius and slow into rank-configured PvE values.
Expected cast/travel/impact/ongoing/cleanup behavior: Cast particle at the caster, impact particle at the chosen point, caster relocates through FindClearSpaceForUnit; enemies in KV radius take physical damage and receive a rank-based slow. Actual jump arc/channel parity remains a live-game acceptance item.
Normal/elite/boss rules: Boundless Strike caps stun against bosses; the other effects use configured area/rank rules. Dota immunity, status resistance, dispel and elite interactions remain pending actual-engine validation.
Current versus target rank curve; free rank / point cost: 10 KV ranks; damage 140→500 plus Agility x 1→1.9, radius 350→485, slow 25→52% for 2.5→4.5s. Primal Spring W ranks 1–10 are gated at levels 1–10; engine HUD/point behavior remains pending.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING engine review; no upgrade handler was changed in this pass.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: verified from installed Monkey King snapshot in this dossier (ClientVersion 6941 / SourceRevision 11041083).
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: monkey_king_spring_cast.vpcf and monkey_king_spring.vpcf; both present in installed ClientVersion 6941 VPK and registered for precache.
- Sound events + declaring banks + emission target + loop termination: existing Hero_MonkeyKing events are emitted by the cast code; installed sound bank exists, exact in-game event playback remains pending.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: all referenced particles registered in addon_game_mode.lua; VPK lookup passed, cold-start Dota test pending.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated EN/TR/RU/zh-CN mirrors: updated; localization generator passed.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Not evaluated in this dossier setup. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | W gate levels 1–10 declared; HUD/point behavior remains PENDING. |
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

## Slot 3: `enfos_mk_jingu_mastery`

Classification: PVE-CONVERT
Native counterpart: monkey_king_jingu_mastery (installed native Ability4; same source snapshot; custom slot 3).
Decision and PvE identity rationale: Preserve the four-hit empowered attack identity; only living enemy hits count, the passive respects Break/illusion rules, buff hits consume configured charges and heal from enemy damage.
Expected cast/travel/impact/ongoing/cleanup behavior: Enemy hit counter grants configured empowered attack charges; buff adds rank-based preattack damage and heals on enemy attacks; upgraded proc provides validated one-shot swipe particle.
Normal/elite/boss rules: Boundless Strike caps stun against bosses; the other effects use configured area/rank rules. Dota immunity, status resistance, dispel and elite interactions remain pending actual-engine validation.
Current versus target rank curve; free rank / point cost: 10 KV ranks; preattack bonus 60→240 plus Agility x 0.3→1.02, four enemy hits, four buff attacks, 25→45% damage heal. Jingu Mastery E ranks 1–10 are gated at levels 1–10; engine HUD/point behavior remains pending.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING engine review; no upgrade handler was changed in this pass.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: verified from installed Monkey King snapshot in this dossier (ClientVersion 6941 / SourceRevision 11041083).
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: monkey_king_furarmy_singlemonkey_attack_swipe.vpcf; present in installed ClientVersion 6941 VPK and registered for precache.
- Sound events + declaring banks + emission target + loop termination: existing Hero_MonkeyKing events are emitted by the cast code; installed sound bank exists, exact in-game event playback remains pending.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: all referenced particles registered in addon_game_mode.lua; VPK lookup passed, cold-start Dota test pending.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated EN/TR/RU/zh-CN mirrors: updated; localization generator passed.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Not evaluated in this dossier setup. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | E gate levels 1–10 declared; HUD/point behavior remains PENDING. |
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

## Slot 4: `enfos_mk_wukongs_command`

Classification: PVE-CONVERT
Native counterpart: monkey_king_wukongs_command (installed native Ability6; same source snapshot; custom slot 4).
Decision and PvE identity rationale: Keep the command-ring ultimate as bounded area pressure; scale lifetime, radius and attack-damage pulses across ten ranks and retain caster-owned effect cleanup.
Expected cast/travel/impact/ongoing/cleanup behavior: Point cast owns one ground-effect thinker for configured duration; area visual follows thinker; bounded interval pulses deal physical attack-damage percentage to enemies, including magic-immune targets allowed by the ability KV; death/expiry cleans the ring particle and thinker.
Normal/elite/boss rules: Boundless Strike caps stun against bosses; the other effects use configured area/rank rules. Dota immunity, status resistance, dispel and elite interactions remain pending actual-engine validation.
Current versus target rank curve; free rank / point cost: 10 KV ranks; duration 8→14s, ring radius 400→650, pulse damage 100→150% of attack damage, interval 1.1s. Wukong’s Command R ranks 1–10 are gated at levels 5, 10, …, 50; ultimate HUD/point behavior remains pending.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING engine review; no upgrade handler was changed in this pass.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: verified from installed Monkey King snapshot in this dossier (ClientVersion 6941 / SourceRevision 11041083).
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: monkey_king_furarmy_aoe.vpcf and monkey_king_fur_army_attack.vpcf; both present in installed ClientVersion 6941 VPK and registered for precache.
- Sound events + declaring banks + emission target + loop termination: existing Hero_MonkeyKing events are emitted by the cast code; installed sound bank exists, exact in-game event playback remains pending.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: all referenced particles registered in addon_game_mode.lua; VPK lookup passed, cold-start Dota test pending.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated EN/TR/RU/zh-CN mirrors: updated; localization generator passed.

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

## Slot 5: `enfos_mk_mischief`

Classification: PVE-CONVERT
Native counterpart: monkey_king_mischief (installed native Ability5; same source snapshot). Enfos custom slot 5 is a passive adaptation; it is not Dota innate metadata.
Decision and PvE identity rationale: Use Mischief as the Enfos-only passive identity layer; remove the mistaken Dota Innate marker and make its attack range/evasion benefits rank-scaled and breakable. The native active disguise is not retained in this passive adaptation.
Expected cast/travel/impact/ongoing/cleanup behavior: Intrinsic passive grants attack range and evasion from KV and returns zero while PassivesDisabled is active. No bespoke particle/sound is required for these numeric passive stats.
Normal/elite/boss rules: Boundless Strike caps stun against bosses; the other effects use configured area/rank rules. Dota immunity, status resistance, dispel and elite interactions remain pending actual-engine validation.
Current versus target rank curve; free rank / point cost: 10 KV ranks; attack range 20→100, evasion 8→26%. One free Enfos passive rank is applied by heroes/innates.lua; passive rank 1 remains separately granted; ranks 2–10 are gated at levels 2–10; engine HUD/point behavior remains pending.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING engine review; no upgrade handler was changed in this pass.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: verified from installed Monkey King snapshot in this dossier (ClientVersion 6941 / SourceRevision 11041083).
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: No custom PFX/SFX claimed for static passive stats.
- Sound events + declaring banks + emission target + loop termination: existing Hero_MonkeyKing events are emitted by the cast code; installed sound bank exists, exact in-game event playback remains pending.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: all referenced particles registered in addon_game_mode.lua; VPK lookup passed, cold-start Dota test pending.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated EN/TR/RU/zh-CN mirrors: updated; localization generator passed.

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

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

2026-09-30 level-cap integration: all five Monkey King abilities now declare KV rank gates. Q/W/E and the Enfos passive use one rank per level; passive rank 1 remains a separate Enfos grant. Wukong’s Command ranks 1–10 unlock on levels 5, 10, …, 50. Static KV contract passes; actual rank buttons, level-up points, ultimate badge and match-start level 6 remain PENDING for owner testing.

2026-09-30 follow-up audit: Jingu Mastery's earned attack buff now suppresses
its bonus damage, healing and charge consumption while Monkey King is Broken;
Mischief's attack-range and evasion bonuses suppress on Break and illusions.
Both passives declare KV `IsBreakable 1`. Mock regressions cover active Jingu
buff behavior under Break and Mischief illusion suppression. Dota's treatment
of already-earned Jingu charges during Break remains pending engine review.

2026-10-04 test-room VConsole attachment `82fe0b92-9ba6-4112-ab13-f6e20a92f2ff`
reports Monkey King ready at level 10 with Scepter/Shard and 10 repeated client
errors in the shared Aghanim cooldown getter: the callback's ability handle
did not expose `GetAbilityType`. The shared getter now returns zero when the
method is unavailable; the corresponding spell amplification getter has the
same guard. Source/mock regression passes for opaque handles. This does not
verify Monkey King's individual skills, Scepter effects, audiovisual behavior
or the actual Dota retest; those acceptance areas remain PENDING.
