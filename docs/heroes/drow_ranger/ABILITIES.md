# Drow Ranger: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_drow_ranger`; role: Carry. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_drow_frost_arrows` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | drow_ranger_frost_arrows |
| 2 | `enfos_drow_gust` | 10 | DOTA_ABILITY_BEHAVIOR_POINT | abilities/pve_kits | drow_ranger_wave_of_silence |
| 3 | `enfos_drow_multishot` | 10 | DOTA_ABILITY_BEHAVIOR_POINT \| DOTA_ABILITY_BEHAVIOR_CHANNELLED | abilities/pve_kits | drow_ranger_multishot |
| 4 | `enfos_drow_marksmanship` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | drow_ranger_marksmanship |
| 5 | `enfos_drow_precision_aura` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | drow_ranger_trueshot |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_drow_ranger.txt`; status: FILE_VERIFIED; SHA256: `6b39eaee2c9b731438cb89105a6edfc254c38b56286bb0e6ca17d72ede3afd7b`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/drow/drow_base.vmdl` |
| SoundSet | `Hero_DrowRanger` |
| Ability1 | `drow_ranger_frost_arrows` |
| Ability2 | `drow_ranger_wave_of_silence` |
| Ability3 | `drow_ranger_multishot` |
| Ability4 | `drow_ranger_glacier` |
| Ability5 | `drow_ranger_trueshot` |
| Ability6 | `drow_ranger_marksmanship` |
| Ability10 | `special_bonus_unique_drow_ranger_7` |
| Ability11 | `special_bonus_unique_drow_ranger_2` |
| Ability12 | `special_bonus_attack_range_75` |
| Ability13 | `special_bonus_unique_drow_ranger_6` |
| Ability14 | `special_bonus_unique_drow_ranger_gust_selfmovespeed` |
| Ability15 | `special_bonus_unique_drow_ranger_1` |
| Ability16 | `special_bonus_unique_drow_ranger_3` |
| Ability17 | `special_bonus_unique_drow_ranger_8` |
| AttributeStrengthGain | `1.900000` |
| AttributeAgilityGain | `2.800000` |
| AttributeIntelligenceGain | `1.400000` |

### Per-ability review leads

- `enfos_drow_frost_arrows`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `enfos_drow_gust`: world position, travel/impact timing and radius alignment.
- `enfos_drow_multishot`: channel tick, interrupt, looping audio and thinker expiry; world position, travel/impact timing and radius alignment.
- `enfos_drow_marksmanship`: intrinsic modifier, Break/illusion behavior, live rank refresh; ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_drow_precision_aura`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

### Pilot review and data/ownership repair — 2026-09-29

The installed ClientVersion 6941 source snapshot identifies Drow's native
Q/W/E/R and aura counterparts as `drow_ranger_frost_arrows`,
`drow_ranger_wave_of_silence`, `drow_ranger_multishot`,
`drow_ranger_marksmanship`, and `drow_ranger_trueshot`. The Enfos kit is
PVE-CONVERT, keeping Drow's slows, silence, volley, precision and team-attack
identity while adding wave coverage and bounded PvE procs.

All five definitions now use named `AbilityValues` for the values their Lua
callbacks read. The existing numeric curves/ranks are unchanged. After the
Lina, Wraith King, Juggernaut, Drow and Omniknight pilot migrations the audit
reports 157 of 200 abilities still using legacy-only rows. Gust now takes
its projectile width and normal-creep displacement from the configured values
instead of duplicating those numbers in Lua. Frost Arrow's death shatter now
requires the matching slow to have been applied by this Drow and this ability;
the regression test covers a different Drow's slow. Static checks pass; live
projectile, channel interruption/audio, aura, Break, boss and VFX tests remain
pending. At the time of this 2026-09-29 review, level-50 / ten-rank progression was not implemented.

Follow-up review (2026-09-29): Drow's Frost Arrows shatter, Gust physical
vulnerability/boss control, Multishot arrow layout/slow, Marksmanship splinter
and Precision Aura radius are now KV-driven. The Drow-only tooltip for the
precision aura was corrected: the Lua aura searches friendly heroes and basics.
Regression covers Gust's configured damage amp and the aura's friendly-team
radius; Frost Arrow ownership and Marksmanship splinter remain covered by the
existing mock tests. Engine visuals/audio, aura application in Dota, boss and
channel-interruption tests remain PENDING.

### Source-backed follow-up — 2026-09-30

All five Enfos slots now have `MaxLevel=10`; the multi-rank values and
Multishot mana cost have ten explicit entries. This is ability data capacity,
not proof that level-50 XP, point grants, starting free passive rank, or unlock
timing is implemented. The installed source is ClientVersion 6941,
SourceRevision 11041083 (hero source SHA256 above).

Native checks: Frost Arrows declares `Hero_DrowRanger.FrostArrows`, physical
damage, enemy spell immunity NO, dispellable YES, and cast animation 1. Gust
declares `Hero_DrowRanger.Silence`, animation 2, spell immunity NO, and
dispellable YES. Multishot is a 1.75-second channel with physical damage,
spell immunity YES, and `ACT_DOTA_CHANNEL_ABILITY_3`. Marksmanship is a
physical ultimate with spell immunity YES and animation 4. Trueshot is the
native Ability5 innate; Enfos Precision Aura stays a separate Enfos passive,
so its custom KV no longer sets Dota's `Innate` marker.

The installed VPK contains the exact particle paths used by Frost Arrows
(`drow_frost_arrow.vpcf`), Gust (`drow_silence_wave.vpcf`), Multishot
(`drow_multishot_proj_linear_proj.vpcf`) and Marksmanship
(`drow_marksmanship_frost_arrow.vpcf`). Frost/Gust sound events are confirmed
in native KV. The Multishot channel event name and all live audio/VFX behavior
remain unverified in Dota.

Repairs: Gust now falls back to Drow's forward vector when the cursor is at her
origin, uses the cast direction for knockback, and handles a target at most
once per wave. Multishot projectiles explicitly include spell-immune targets,
matching the native ability. Marksmanship's primary bonus hit now uses the
physical-armor-ignore damage flag; its nearby splash search also includes
spell-immune enemies. Frost/Marksmanship callbacks reject dead or invalid
attack targets, Frost's death burst respects Break, and Precision Aura shuts
off under Break. Regression tests cover these contracts; live engine and
VConsole testing remains pending.

The unconsumed custom `disable_range=400` field was removed. Native source has
a `disable_range` value of 300, but this custom Lua implementation did not read
it; its gameplay meaning and PvE policy still need source-level verification
before any behavior is recreated.

## Slot 1: `enfos_drow_frost_arrows`

Classification: PVE-CONVERT
Native counterpart: `drow_ranger_frost_arrows` (installed ClientVersion 6941 source snapshot).
Decision and PvE identity rationale: Keep the attack-applied frost slow and add a bounded death shatter to support wave clear.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Frost Arrows Q ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: scripts/npc/heroes/npc_dota_hero_drow_ranger.txt, ClientVersion 6941 / SourceRevision 11041083, SHA256 6b39eaee2c9b731438cb89105a6edfc254c38b56286bb0e6ca17d72ede3afd7b.
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
| Gameplay | PENDING | Mock regressions cover configured damage, Gust targeting and aura Break; Dota creep/elite/boss results remain pending. |
| Targeting | PENDING | Native immunity rules and custom projectile flags were reviewed; Dota immune, range-edge and target-loss tests remain pending. |
| Ranks | PENDING | Q gate levels 1–10 are declared; in-game HUD and point behavior remain PENDING. |
| VFX | PENDING | Referenced Drow particles exist in the installed VPK; attachment, control points, size and in-engine appearance remain pending. |
| SFX | PENDING | Frost/Gust event names are present in native KV; Multishot channel bank lookup and audible playback remain pending. |
| Animation | PENDING | Native Gust and Multishot animation identifiers are in KV; cast/channel playback remains pending. |
| Modifiers | PENDING | Break, target guards and aura behavior were statically reviewed and mocked; runtime purge, status resistance and refresh remain pending. |
| Precache | PENDING | Drow particle paths are registered in addon precache; cold-start loading remains pending. |
| Cleanup | PENDING | One-shot particle release and channel StopSound paths are present; repeated casts and interrupted/death cleanup remain pending. |
| Boss | PENDING | Gust has a 30% boss control duration; boss damage, immunity and kill-credit cases remain pending in engine. |
| Upgrades | PENDING | Generic class Scepter/Shard paths are configured; Drow-specific upgrade runtime effects remain pending. |
| Localization | PENDING | EN/TR/RU/zh-CN descriptions and generated mirrors were synchronized; in-game tooltip display remains pending. |
| Performance | PENDING | Multishot emits at most 24 arrows per cast; dense-wave projectile and Marksmanship proc cost remain unmeasured. |
| Reconnect | PENDING | Passive and aura reapplication after reconnect has not been tested in Dota. |
| VConsole | PENDING | No live Dota/VConsole session was used for this review. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 2: `enfos_drow_gust`

Classification: PVE-CONVERT
Native counterpart: `drow_ranger_wave_of_silence` (installed ClientVersion 6941 source snapshot).
Decision and PvE identity rationale: Keep the traveling silence wave and push; shorten boss silence and add a physical vulnerability window for PvE teams.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Gust W ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: scripts/npc/heroes/npc_dota_hero_drow_ranger.txt, ClientVersion 6941 / SourceRevision 11041083, SHA256 6b39eaee2c9b731438cb89105a6edfc254c38b56286bb0e6ca17d72ede3afd7b.
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
| Gameplay | PENDING | Mock regressions cover configured damage, Gust targeting and aura Break; Dota creep/elite/boss results remain pending. |
| Targeting | PENDING | Native immunity rules and custom projectile flags were reviewed; Dota immune, range-edge and target-loss tests remain pending. |
| Ranks | PENDING | W gate levels 1–10 are declared; in-game HUD and point behavior remain PENDING. |
| VFX | PENDING | Referenced Drow particles exist in the installed VPK; attachment, control points, size and in-engine appearance remain pending. |
| SFX | PENDING | Frost/Gust event names are present in native KV; Multishot channel bank lookup and audible playback remain pending. |
| Animation | PENDING | Native Gust and Multishot animation identifiers are in KV; cast/channel playback remains pending. |
| Modifiers | PENDING | Break, target guards and aura behavior were statically reviewed and mocked; runtime purge, status resistance and refresh remain pending. |
| Precache | PENDING | Drow particle paths are registered in addon precache; cold-start loading remains pending. |
| Cleanup | PENDING | One-shot particle release and channel StopSound paths are present; repeated casts and interrupted/death cleanup remain pending. |
| Boss | PENDING | Gust has a 30% boss control duration; boss damage, immunity and kill-credit cases remain pending in engine. |
| Upgrades | PENDING | Generic class Scepter/Shard paths are configured; Drow-specific upgrade runtime effects remain pending. |
| Localization | PENDING | EN/TR/RU/zh-CN descriptions and generated mirrors were synchronized; in-game tooltip display remains pending. |
| Performance | PENDING | Multishot emits at most 24 arrows per cast; dense-wave projectile and Marksmanship proc cost remain unmeasured. |
| Reconnect | PENDING | Passive and aura reapplication after reconnect has not been tested in Dota. |
| VConsole | PENDING | No live Dota/VConsole session was used for this review. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 3: `enfos_drow_multishot`

Classification: PVE-CONVERT
Native counterpart: `drow_ranger_multishot` (installed ClientVersion 6941 source snapshot).
Decision and PvE identity rationale: Keep the aimed channel volley and tune arrow count/damage for wave lanes.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Multishot E ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: scripts/npc/heroes/npc_dota_hero_drow_ranger.txt, ClientVersion 6941 / SourceRevision 11041083, SHA256 6b39eaee2c9b731438cb89105a6edfc254c38b56286bb0e6ca17d72ede3afd7b.
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
| Gameplay | PENDING | Mock regressions cover configured damage, Gust targeting and aura Break; Dota creep/elite/boss results remain pending. |
| Targeting | PENDING | Native immunity rules and custom projectile flags were reviewed; Dota immune, range-edge and target-loss tests remain pending. |
| Ranks | PENDING | E gate levels 1–10 are declared; in-game HUD and point behavior remain PENDING. |
| VFX | PENDING | Referenced Drow particles exist in the installed VPK; attachment, control points, size and in-engine appearance remain pending. |
| SFX | PENDING | Frost/Gust event names are present in native KV; Multishot channel bank lookup and audible playback remain pending. |
| Animation | PENDING | Native Gust and Multishot animation identifiers are in KV; cast/channel playback remains pending. |
| Modifiers | PENDING | Break, target guards and aura behavior were statically reviewed and mocked; runtime purge, status resistance and refresh remain pending. |
| Precache | PENDING | Drow particle paths are registered in addon precache; cold-start loading remains pending. |
| Cleanup | PENDING | One-shot particle release and channel StopSound paths are present; repeated casts and interrupted/death cleanup remain pending. |
| Boss | PENDING | Gust has a 30% boss control duration; boss damage, immunity and kill-credit cases remain pending in engine. |
| Upgrades | PENDING | Generic class Scepter/Shard paths are configured; Drow-specific upgrade runtime effects remain pending. |
| Localization | PENDING | EN/TR/RU/zh-CN descriptions and generated mirrors were synchronized; in-game tooltip display remains pending. |
| Performance | PENDING | Multishot emits at most 24 arrows per cast; dense-wave projectile and Marksmanship proc cost remain unmeasured. |
| Reconnect | PENDING | Passive and aura reapplication after reconnect has not been tested in Dota. |
| VConsole | PENDING | No live Dota/VConsole session was used for this review. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 4: `enfos_drow_marksmanship`

Classification: PVE-CONVERT
Native counterpart: `drow_ranger_marksmanship` (installed ClientVersion 6941 source snapshot).
Decision and PvE identity rationale: Keep the precision proc and add a capped splinter burst against nearby creeps.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Marksmanship R ranks 1–10 are KV-gated at levels 5, 10, …, 50; ultimate UI and point behavior remain PENDING.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: scripts/npc/heroes/npc_dota_hero_drow_ranger.txt, ClientVersion 6941 / SourceRevision 11041083, SHA256 6b39eaee2c9b731438cb89105a6edfc254c38b56286bb0e6ca17d72ede3afd7b.
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
| Gameplay | PENDING | Mock regressions cover configured damage, Gust targeting and aura Break; Dota creep/elite/boss results remain pending. |
| Targeting | PENDING | Native immunity rules and custom projectile flags were reviewed; Dota immune, range-edge and target-loss tests remain pending. |
| Ranks | PENDING | R gate levels 5–50 in five-level steps is declared; ultimate HUD and point behavior remain PENDING. |
| VFX | PENDING | Referenced Drow particles exist in the installed VPK; attachment, control points, size and in-engine appearance remain pending. |
| SFX | PENDING | Frost/Gust event names are present in native KV; Multishot channel bank lookup and audible playback remain pending. |
| Animation | PENDING | Native Gust and Multishot animation identifiers are in KV; cast/channel playback remains pending. |
| Modifiers | PENDING | Break, target guards and aura behavior were statically reviewed and mocked; runtime purge, status resistance and refresh remain pending. |
| Precache | PENDING | Drow particle paths are registered in addon precache; cold-start loading remains pending. |
| Cleanup | PENDING | One-shot particle release and channel StopSound paths are present; repeated casts and interrupted/death cleanup remain pending. |
| Boss | PENDING | Gust has a 30% boss control duration; boss damage, immunity and kill-credit cases remain pending in engine. |
| Upgrades | PENDING | Generic class Scepter/Shard paths are configured; Drow-specific upgrade runtime effects remain pending. |
| Localization | PENDING | EN/TR/RU/zh-CN descriptions and generated mirrors were synchronized; in-game tooltip display remains pending. |
| Performance | PENDING | Multishot emits at most 24 arrows per cast; dense-wave projectile and Marksmanship proc cost remain unmeasured. |
| Reconnect | PENDING | Passive and aura reapplication after reconnect has not been tested in Dota. |
| VConsole | PENDING | No live Dota/VConsole session was used for this review. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 5: `enfos_drow_precision_aura`

Classification: PVE-CONVERT
Native counterpart: `drow_ranger_trueshot` (installed ClientVersion 6941 source snapshot).
Decision and PvE identity rationale: Preserve the team precision aura and give it a PvE range/agility profile.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: The Enfos passive rank 1 is granted separately; ranks 2–10 are KV-gated at levels 2–10; engine point/UI behavior remains PENDING.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: scripts/npc/heroes/npc_dota_hero_drow_ranger.txt, ClientVersion 6941 / SourceRevision 11041083, SHA256 6b39eaee2c9b731438cb89105a6edfc254c38b56286bb0e6ca17d72ede3afd7b.
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
| Gameplay | PENDING | Mock regressions cover configured damage, Gust targeting and aura Break; Dota creep/elite/boss results remain pending. |
| Targeting | PENDING | Native immunity rules and custom projectile flags were reviewed; Dota immune, range-edge and target-loss tests remain pending. |
| Ranks | PENDING | The separate passive rank 1 grant remains; ranks 2–10 gates are declared; in-game HUD and point behavior remain PENDING. |
| VFX | PENDING | Referenced Drow particles exist in the installed VPK; attachment, control points, size and in-engine appearance remain pending. |
| SFX | PENDING | Frost/Gust event names are present in native KV; Multishot channel bank lookup and audible playback remain pending. |
| Animation | PENDING | Native Gust and Multishot animation identifiers are in KV; cast/channel playback remains pending. |
| Modifiers | PENDING | Break, target guards and aura behavior were statically reviewed and mocked; runtime purge, status resistance and refresh remain pending. |
| Precache | PENDING | Drow particle paths are registered in addon precache; cold-start loading remains pending. |
| Cleanup | PENDING | One-shot particle release and channel StopSound paths are present; repeated casts and interrupted/death cleanup remain pending. |
| Boss | PENDING | Gust has a 30% boss control duration; boss damage, immunity and kill-credit cases remain pending in engine. |
| Upgrades | PENDING | Generic class Scepter/Shard paths are configured; Drow-specific upgrade runtime effects remain pending. |
| Localization | PENDING | EN/TR/RU/zh-CN descriptions and generated mirrors were synchronized; in-game tooltip display remains pending. |
| Performance | PENDING | Multishot emits at most 24 arrows per cast; dense-wave projectile and Marksmanship proc cost remain unmeasured. |
| Reconnect | PENDING | Passive and aura reapplication after reconnect has not been tested in Dota. |
| VConsole | PENDING | No live Dota/VConsole session was used for this review. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

2026-09-30 level-cap integration: all five Drow Ranger abilities now declare KV rank gates. Q/W/E and the Enfos passive use one rank per level; passive rank 1 remains a separate Enfos grant. Marksmanship ranks 1–10 unlock on levels 5, 10, …, 50. Static KV contract passes; actual rank buttons, level-up points, ultimate badge and match-start level 6 remain PENDING for owner testing.
