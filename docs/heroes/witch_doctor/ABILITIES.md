# Witch Doctor: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_witch_doctor`; role: Support. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_wd_paralyzing_cask` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/pve_kits | witch_doctor_paralyzing_cask |
| 2 | `enfos_wd_voodoo_restoration` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET \| DOTA_ABILITY_BEHAVIOR_TOGGLE \| DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL | abilities/pve_kits | witch_doctor_voodoo_restoration |
| 3 | `enfos_wd_maledict` | 10 | DOTA_ABILITY_BEHAVIOR_POINT \| DOTA_ABILITY_BEHAVIOR_AOE | abilities/pve_kits | witch_doctor_maledict |
| 4 | `enfos_wd_death_ward` | 10 | DOTA_ABILITY_BEHAVIOR_POINT \| DOTA_ABILITY_BEHAVIOR_CHANNELLED | abilities/pve_kits | witch_doctor_death_ward |
| 5 | `enfos_wd_gris_gris` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | witch_doctor_voodoo_restoration |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_witch_doctor.txt`; status: FILE_VERIFIED; SHA256: `9bf79ef6a42ed2f24f5b26e558799eb54a5ef048e82a5fda063ed99f3561f213`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/witchdoctor/witchdoctor.vmdl` |
| SoundSet | `Hero_WitchDoctor` |
| Ability1 | `witch_doctor_paralyzing_cask` |
| Ability2 | `witch_doctor_voodoo_restoration` |
| Ability3 | `witch_doctor_maledict` |
| Ability4 | `witch_doctor_voodoo_switcheroo` |
| Ability5 | `witch_doctor_gris_gris` |
| Ability6 | `witch_doctor_death_ward` |
| Ability10 | `special_bonus_unique_witch_doctor_4` |
| Ability11 | `special_bonus_hp_200` |
| Ability12 | `special_bonus_unique_witch_doctor_6` |
| Ability13 | `special_bonus_unique_witch_doctor_7` |
| Ability14 | `special_bonus_unique_witch_doctor_maledict_spread` |
| Ability15 | `special_bonus_unique_witch_doctor_2` |
| Ability16 | `special_bonus_unique_witch_doctor_3` |
| Ability17 | `special_bonus_unique_witch_doctor_5` |
| AttributeStrengthGain | `2.100000` |
| AttributeAgilityGain | `1.400000` |
| AttributeIntelligenceGain | `3.100000` |

### Per-ability review leads

- `enfos_wd_paralyzing_cask`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_wd_voodoo_restoration`: toggle state, mana drain, death/respawn cleanup.
- `enfos_wd_maledict`: world position, travel/impact timing and radius alignment.
- `enfos_wd_death_ward`: channel tick, interrupt, looping audio and thinker expiry; world position, travel/impact timing and radius alignment; ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_wd_gris_gris`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-09-30 implementation record: all five core Enfos abilities now have KV `MaxLevel 10`; Gris-Gris has no Dota `Innate` flag. Rank values for Cask, Restoration, Maledict, Death Ward, and Gris-Gris are explicit in KV. Fixed Maledict to read its configured duration, burst interval, normal/boss percentages, and measure health loss per burst window. Cask boss stun cap is data-driven. Restoration's VPK-verified aura particle is precached and destroyed with its toggle modifier. Mock coverage passes for Cask and Maledict; 102 hero-kit mock regressions pass. Four selected Witch Doctor particle files exist in installed Dota VPK. These checks do not prove in-engine VFX/audio/channel behavior; Dota/VConsole cold-start and live playtest remain PENDING.

2026-09-30 static special-value migration: moved every Lua-read value for all five abilities from legacy numbered `AbilitySpecial` rows into named `AbilityValues`, preserving the existing 10-rank arrays and scalars. This is based on the Sven live finding in this project: Lua callbacks loaded while `GetSpecialValueFor` read zero from that legacy layout, and returned configured values after migration on ClientVersion 6941. The Witch Doctor conversion passes current KeyValues, inventory, and mock ability checks; it is not a Witch Doctor engine test. VFX/SFX/channel/targeting and progression behavior remain pending actual Dota verification.

2026-09-30 Death Ward static repair: the Lua channel previously dealt its periodic damage without creating the iconic ward entity. It now creates the installed native `npc_dota_witch_doctor_death_ward` at the cast point, disables its autonomous acquisition, applies an invulnerable/noninteractive visual modifier, emits the VPK-verified `particles/units/heroes/hero_witchdoctor/witchdoctor_ward_summon.vpcf`, and removes the ward when the channel modifier ends. The installed unit definition uses `models/heroes/witchdoctor/witchdoctor_ward.vmdl` and `Hero_WitchDoctor_Ward`; those native resources are source evidence, not confirmation that the custom cast looks or sounds correct in game. The summon particle and unit are precached and checked by a behavior mock plus static content contract. Gris-Gris' tooltip now uses its live `gold_per_interval`/`interval` KV values in all four locales, so rank 1–4, 5–8, and 9–10 descriptions can match their configured gold. Dota/VConsole tests for summon visibility, attack animation, channel interruption, looping audio, sounds, particles, boss interactions and localization display remain PENDING for the owner.

Follow-up static audit (2026-09-30): Death Ward's KV declares that attacks can
hit spell-immune enemies, but its Lua radius search omitted the corresponding
target flag; it now includes that flag and has a query regression. Gris-Gris
could grant gold through Break and to player-owned illusions; payouts now stop
for both, with a regression. Maledict's EN/RU/zh-CN descriptions used fixed
duration, interval and burst percentages while the Lua reads them from KV; those
tooltips now use the actual configured placeholders. In-game target immunity,
economy, VFX/SFX, channel and boss behavior remain pending owner testing.

2026-09-30 follow-up: Gris-Gris now declares KV `IsBreakable 1`, matching its
Lua `PassivesDisabled()` check so Break can suppress its gold payout. Content
contract coverage asserts this metadata; engine Break behavior remains pending.

## Slot 1: `enfos_wd_paralyzing_cask`

Classification: PVE-CONVERT
Native counterpart: `witch_doctor_paralyzing_cask` (installed Ability1).
Decision and PvE identity rationale: preserve the signature bouncing stun while using a bounded server-side PvE chain; values and boss stun cap are rank/KV driven.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Paralyzing Cask Q ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
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
| Ranks | PENDING | Q gate levels 1–10 declared; HUD/point behavior remains PENDING engine verification. |
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

## Slot 2: `enfos_wd_voodoo_restoration`

Classification: PVE-CONVERT
Native counterpart: `witch_doctor_voodoo_restoration` (installed Ability2).
Decision and PvE identity rationale: keep the toggle healing aura identity; rank-scaled healing/mana and persistent native aura particle now have explicit cleanup and precache.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Voodoo Restoration W ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
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
| Ranks | PENDING | W gate levels 1–10 declared; HUD/point behavior remains PENDING engine verification. |
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

## Slot 3: `enfos_wd_maledict`

Classification: PVE-CONVERT
Native counterpart: `witch_doctor_maledict` (installed Ability3).
Decision and PvE identity rationale: retain damage-over-time and health-loss burst; bursts use the health loss since the preceding burst and separate boss percentage, all from KV.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Maledict E ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
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
| Ranks | PENDING | E gate levels 1–10 declared; HUD/point behavior remains PENDING engine verification. |
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

## Slot 4: `enfos_wd_death_ward`

Classification: PVE-CONVERT
Native counterpart: `witch_doctor_death_ward` (installed Ability6).
Decision and PvE identity rationale: retain a stationary channeling ward identity with bounded random target attacks; channel duration and damage are data driven.
Expected cast/travel/impact/ongoing/cleanup behavior: channels at the selected point; a stationary native ward should be visible during the channel; the channel modifier owns its periodic damage and removes the spawned ward when channeling ends or is interrupted. Runtime confirmation is PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Death Ward R ranks 1–10 are KV-gated at levels 5, 10, …, 50; ultimate UI and point behavior remain PENDING.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: PENDING.
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: summon `particles/units/heroes/hero_witchdoctor/witchdoctor_ward_summon.vpcf` at ward entity; attack `particles/units/heroes/hero_witchdoctor/witchdoctor_ward_attack.vpcf` on selected target. Paths present in installed VPK; in-engine appearance and control-point behavior PENDING.
- Sound events + declaring banks + emission target + loop termination: `Hero_WitchDoctor.Death_Ward` on caster and native ward unit `Hero_WitchDoctor_Ward`; bank/playback/loop verification PENDING.
- Model/animation/gesture/icon evidence: installed `npc_dota_witch_doctor_death_ward` uses `models/heroes/witchdoctor/witchdoctor_ward.vmdl`; attack animation and icon fidelity PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: `addon_game_mode.lua` precaches the native unit and summon particle; cold-start engine test PENDING.
- One-shot/persistent cleanup owner and repeated-use test: channel modifier removes ward in `OnDestroy`; mock regression passes; interrupt/recast engine test PENDING.
- Localization keys and generated mirrors: PENDING.

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
| Precache | PASS | Native unit/particle precache calls and content contract checked; cold-start Dota test PENDING. |
| Cleanup | PASS | Channel teardown removal covered by mock; interrupt/recast engine test PENDING. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | Not evaluated in this dossier setup. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 5: `enfos_wd_gris_gris`

Classification: PVE-CONVERT
The installed Witch Doctor source names native Ability5 `witch_doctor_gris_gris`; it is a passive identity and suits Enfos' separately granted fifth slot. Enfos' rank curve grants 1 reliable gold every 3 seconds at ranks 1–4, 2 at ranks 5–8 and 3 at ranks 9–10. The localized description now reads the configured values. The exact current native item accumulation and activation behavior is not claimed as reproduced; this is a bounded Enfos adaptation.
Native counterpart: `witch_doctor_gris_gris` (installed source record above).
Decision and PvE identity rationale: retain Witch Doctor's gold-charm identity as a low-impact passive economy trickle; native Dota innate and Enfos slot granting remain separate systems.
Expected cast/travel/impact/ongoing/cleanup behavior: no cast; server-side 3-second interval modifier persists through death and pays only to a valid player owner.
Normal creep / elite / boss, immunity / dispel / resistance rules: no combat interaction.
Current versus target rank curve; free rank / point cost: ten ranks are defined; the Enfos passive rank 1 grant is separate from Dota innate metadata, ranks 2–10 are gated at levels 2–10; in-game points remain pending.
Shard / Scepter / Blessing / Evolution / Ascended interactions: generic Support Shard heal amplification remains; Switcheroo is granted as a separate Shard active.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: PENDING.
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: PENDING.
- Sound events + declaring banks + emission target + loop termination: PENDING.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: PENDING.
- Precache owner and cold-start test: PENDING.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated mirrors: four locale templates resolve configured gold and interval values; generated engine resource mirrors checked. In-engine display PENDING.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Not evaluated in this dossier setup. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Separate passive rank 1 grant retained; ranks 2–10 gates declared; in-game HUD/point behavior remains PENDING. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PASS | `localization.mjs` generates rank-aware text in all four locales; live tooltip display PENDING. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: 2026-09-29 fifth slot moved from Switcheroo to Gris-Gris; Shard acquisition now grants Switcheroo and loss removes it. 2026-09-30 tooltip templates updated to reflect rank-based gold values. Dota/VConsole verification, gold pacing, visual/icon and audio acceptance remain PENDING. A mock pass is not ENGINE_PASS.

## Shard active: `enfos_wd_voodoo_switcheroo`

Classification: PVE-CONVERT
Valve's Mistwoods Shard note identifies Voodoo Switcheroo as Witch Doctor's Shard ability; use that as identity/provenance reference ([Valve Mistwoods](https://www.dota2.com/mistwoods)). This project grants the custom active only while Shard is owned; its Enfos behavior is 2 seconds of invulnerability/disarm with bounded random ward attacks. Exact native transformation visuals, hidden state and attack-speed penalty are not implemented and remain runtime/design gaps.
Implementation: `AghanimManager:OnShardAcquired` adds/levels/unhides/activates once; `OnShardLost` removes the ability. Custom effect remains bounded to a 2-second modifier.
Engine verification: PENDING; verify ability slot placement, reconnect, icon, transformation model/particle/audio and interruption in Dota/VConsole.

### Presentation and toggle lifecycle repair — 2026-10-01

Classification remains **PVE-CONVERT** for Restoration, Maledict, Death Ward
and Switcheroo. This focused change restores native presentation metadata and
audio lifecycle without replacing the healing, damage or rank values.

Current installed source: ClientVersion **6942**, SourceRevision **11055158**,
Sep 29 2026. `scripts/npc/heroes/npc_dota_hero_witch_doctor.txt` is read from
the installed VPK; its SHA256 and the explicitly mapped custom/native fields
are in `../../audit/HERO_NATIVE_PRESENTATION_2026-10-01.json`. The earlier
6941 inventory records remain historical evidence, not this repair's build.

The installed native bank `soundevents/game_sounds_heroes/game_sounds_witchdoctor.vsndevts_c`
was decoded with Source2Viewer CLI 19.2 without launching Dota. It defines
`Hero_WitchDoctor.Voodoo_Restoration`, `.Loop`, `.Off`, and
`Hero_WitchDoctor.Death_WardBuild`. It does **not** define the previously used
`Hero_WitchDoctor.Death_Ward`. Decoded bank hashes and literal call sites are
in `../../audit/HERO_SOUND_EVENTS_2026-10-01.json`.

- W now starts its on/loop sounds on the caster exactly when its server aura
  is created. Aura destruction stops the loop, plays Off and destroys/releases
  its particle; repeated heal ticks do not restart sound. Toggle changes are
  server-only and the aura cannot be purged out from under an enabled toggle.
- W uses native `ACT_DOTA_CAST_ABILITY_2` and `IGNORE_CHANNEL`, preserving
  native ability to change Restoration state while channeling Death Ward.
- E uses native `ACT_DOTA_CAST_ABILITY_5` (not an inferred third-slot gesture).
- R uses native cast/channel activities 4 and the verified `Death_WardBuild`
  event. Modifier teardown stops it on expiry/death as well as channel finish.
- Switcheroo uses native cast activity 3; its two-second modifier stops the
  otherwise eight-second WardBuild audio when it ends. Its documented model
  transformation, ward attack-animation and visual gaps remain unresolved.
- W/R/Shard declare the verified native sound bank in their ability precache
  blocks. W also declares its existing aura particle there. Existing addon
  unit/particle precache stays in place; no all-hero synchronous loading added.

**MOCK_PASS**: Restoration on/off, non-purgability, mana/heal preservation,
no per-tick audio restart, mana exhaustion, predicted-client exclusion, particle
handle cleanup, R modifier teardown and Shard audio expiry. Full Dota visual,
audio, channel-animation and cold-start client acceptance remain **PENDING**.
No native ward attack behavior or travel projectile was certified by this work.

Follow-up asset decode proves `witchdoctor_ward_attack.vpcf` is a projectile
parent: `C_OP_AttractToControlPoint` reads destination CP1, child trail/launch
effects are present, and decay/explosion use the end-cap lifecycle. Calling the
generic `effect(path, target)` helper neither supplied CP1 nor ended that parent.
R/Shard now launch engine-owned tracking projectiles with this verified native
resource and speed **1000**, matching installed
`npc_dota_witch_doctor_death_ward` (MCP `base_kv_entry`, units, 6942).
The existing 0.22-second R cadence matches its native AttackRate; Shard retains
its existing 0.25-second cadence. Ranked physical damage/Intelligence scaling
is preserved, but damage now occurs on impact rather than before the visual.
Projectiles deliberately retain the old adaptation's guaranteed-hit policy
(`bDodgeable=false`); exact native evasion/attack-proc rules are not reproduced.
Lost/dead/allied targets cause no hit. Native ward attack/impact sounds play
at their respective source/target. Travel appearance, ward attack gesture,
engine termination after source removal, immunity and second-client precache
remain owner runtime checks. Mock launch/impact tests pass for R and Shard.

2026-09-30 level-cap integration: all five Witch Doctor hero slots now declare KV rank gates. Q/W/E and the Enfos passive use one rank per level; passive rank 1 remains a separate Enfos grant. Death Ward ranks 1–10 unlock on levels 5, 10, …, 50. Static KV contract passes; actual rank buttons, level-up points, ultimate badge and match-start level 6 remain PENDING for owner testing.
