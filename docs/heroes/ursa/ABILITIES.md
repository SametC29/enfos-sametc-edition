# Ursa: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_ursa`; role: Fighter. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_ursa_earthshock` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET \| DOTA_ABILITY_BEHAVIOR_IMMEDIATE \| DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING | NOT_EXPLICIT | ursa_earthshock |
| 2 | `enfos_ursa_overpower` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET \| DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING | NOT_EXPLICIT | ursa_overpower |
| 3 | `enfos_ursa_fury_swipes` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/heroes/ursa/e | ursa_fury_swipes |
| 4 | `enfos_ursa_enrage` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET \| DOTA_ABILITY_BEHAVIOR_IMMEDIATE | NOT_EXPLICIT | ursa_enrage |
| 5 | `enfos_ursa_ursa_minor` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | ursa_fury_swipes |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [abilities/heroes/ursa/e](../../../game/scripts/vscripts/abilities/heroes/ursa/e.lua), [abilities/pve_kits](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

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

Classification: TUNE
Native counterpart: ursa_earthshock (installed native Ability1; Ursa source snapshot, ClientVersion 6941 / SourceRevision 11041083).
Decision and PvE identity rationale: Native facing hop and magical impact/slow with ten-rank authored tuning and minimal STR outgoing bridge. Boss-only slow cap and stationary physical damage replica retired.
Expected cast/travel/impact/ongoing/cleanup behavior: Native immediate no-target hop250/.25/83 toward facing, landing impact385radius/AoE and magical damage/dispellable slow; engine owns recipients, immunity, VFX/SFX/animation and cleanup. Shard3Fury uses exact native E identity; hiddeninactive exactR compatibility, no manual Enrage or purge.
Normal/elite/boss: native Fury Swipes uses ordinary enemy/stack rules without a custom Boss cap. Earthshock uses ordinary engine slow without a custom Boss cap. Engine immunity, dispel and resistance interactions remain PENDING OWNER TEST.
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
Decision and PvE identity rationale: Preserve Ursa’s rapid-attack window while scaling attack speed and attack charges over ten ranks; preserve landed-attack healing, including killing blows.
Expected cast/travel/impact/ongoing/cleanup behavior: Native no-target cast owns dispellable buff, AS, slow resistance25, charges (misses consume), presentation and cleanup. A bounded attack-record extension heals empowered enemy hits including final-charge/killing hits; no custom charge mutation. Actual event order and native buff ownership remain owner test pending.
Normal/elite/boss: native Fury Swipes uses ordinary enemy/stack rules without a custom Boss cap. Earthshock uses ordinary engine slow without a custom Boss cap. Engine immunity, dispel and resistance interactions remain PENDING OWNER TEST.
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

Classification: TUNE
Native counterpart: exact ursa_fury_swipes provider, installed build6943/revision11069754 with unchanged hero hash; paid Enfos controller is separate.
Decision and PvE identity rationale: Restore native focused attack stacks/reset/Break preserving existing effects. Minimal paid-rank/AGI bridge; retire custom radial cleave and normal/Boss caps. No native attack or target debuff clone.
Expected cast/travel/impact/ongoing/cleanup behavior: Native Fury Swipes owns attack damage, per-caster target stacks, reset, hit/debuff effects, immunity and cleanup. Provider remains rank0 until paid E learned then rank1; paid OnUpgrade refreshes only caster intrinsic cache.
Normal/elite/boss: native Fury Swipes uses ordinary enemy/stack rules without a custom Boss cap. Earthshock uses ordinary engine slow without a custom Boss cap. Engine immunity, dispel and resistance interactions remain PENDING OWNER TEST.
Current versus target rank curve; free rank / point cost: paid10ranks/base20→92+AGI0.15/reset6→10s; nativeRoshan reset8s/stun defaults0. No custom stack caps or cleave. Hidden provider manually0/1 without skill points; actual engine rank buttons/points remain pending.
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

Change/test record: 2026-10-04 source implemented; 115 focused source/client/localization checks and323 hero mocks pass. Native AGI read/cache, rank refresh target-state retention, Break, multiple casters and QShard/VFX/SFX remain owner pending.

## Slot 4: `enfos_ursa_enrage`

Classification: TUNE
Native counterpart: ursa_enrage (installed native Ability6; same source snapshot).
Decision and PvE identity rationale: Native Enrage with authored ten-rank tuning preserves self-defense and strong dispel; native Scepter owns disabled casting and explicit30..18 cooldown.
Expected cast/travel/impact/ongoing/cleanup behavior: Native Enrage owns cast, strong dispel, buff, reduction/status resistance and expiry. No Lua purge/buff replica remains.
Normal/elite/boss: native Fury Swipes uses ordinary enemy/stack rules without a custom Boss cap. Earthshock uses ordinary engine slow without a custom Boss cap. Engine immunity, dispel and resistance interactions remain PENDING OWNER TEST.
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
Normal/elite/boss: native Fury Swipes uses ordinary enemy/stack rules without a custom Boss cap. Earthshock uses ordinary engine slow without a custom Boss cap. Engine immunity, dispel and resistance interactions remain PENDING OWNER TEST.
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

2026-10-04 native-first discovery supersedes the earlier blanket PvE-conversion
assumption for future work. Fresh build6943/revision11069754 hero hash unchanged;
[full native snapshot](../../audit/URSA_NATIVE_SOURCE_2026-10-04.json) and
[pre-mutation matrix](../../audit/URSA_NATIVE_FIRST_REVIEW_2026-10-04.md) distinguish
source decisions from engine acceptance. Native Q hop/magical damage, W miss
consumption/slow resistance, E Break retaining existing stacks, R native
strong dispel/disabled Scepter and rank1 currentHP Maul need restoration.
Allfive primary classifications are TUNE. Existing production remains Lua at
this discovery boundary; no Dota/VConsole acceptance inferred from resources.

2026-10-04 R source migration: native alias `enfos_ursa_enrage` -> `ursa_enrage`
retains authored10 ranks/gates/mitigation/status resistance/duration/costs.
Explicit installed instant cast/immunity/dispel/animation/sound metadata;
Scepter cooldown30..18 overtenranks, no generic ultimateamp/CDR double bonus
for this ownedkit. No Lua class, purge, copiedbuff or emptywrapper. Fourlocales
and12mirrors updated. 4native source/ownership/localization tests pass; actual
Scepter disabledcasting/strongdispel/mitigation/ranks/lifecycle/VFX/SFX remain
PENDING OWNER TEST. Q/W/E/D stay currentLua until subsequent source units.

2026-10-04 E source migration supersedes the 2026-09-30 custom-stack/cap/cleave
record. Native Fury Swipes owns target state; stable paidE10ranks plus raw
AGI bridge and rank1 linked provider. Registered client extension, idempotent
shared restore, read-only Health, no custom attacks/debuffs/stack mutation.
See current review for exact evidence and owner pending tests. Q/W/D remain
source work; E/R source validation does not establish engine acceptance.

2026-10-04 Q source migration supersedes historical physical/no-hop/Boss-cap
records: native magical facing hop/slow/Shard with authored10rankheader
damage/duration/costs and server-only STR1.5 outgoing factor. ExactFury and
hiddeninactive exactR identities, paidR numeric helper fields; compatibility
not proof of currentnativeShard lookup. No directcast/purge/points/targetstate
mutation. 120 focused/322hero mocks pass; actual hop, damage pipeline/stacking,
Shard effects incl.no unlearnedR purge, coldVFX/SFX and ranks remain ownerpending.
Q/E/R source implemented; W/D next. See currentreview/snapshot for provenance.

2026-10-04 W source migration: native Overpower alias with correct exposed AS key, slow resistance25 and duration header; preserves authored ten-rank curves. Copied cast, buff, charge decrement and VFX/SFX removed. Independent bounded32-record sustain covers final-charge and killing hits without native mutation. Server-only/event-driven caster modifier enumeration uses originating W handle, not a guessed modifier ID. Native event ordering/charge exposure/healing amount, miss/purge/death/reconnect/upgrades and cold presentation remain PENDING OWNER TEST. 117 affected checks/321 mocks/full checks pass with0failures; no engine certification.
