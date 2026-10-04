# Slark: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_slark`; role: Fighter. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_slark_dark_pact` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET \| DOTA_ABILITY_BEHAVIOR_IMMEDIATE | NOT_EXPLICIT | slark_dark_pact |
| 2 | `enfos_slark_pounce` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | slark_pounce |
| 3 | `enfos_slark_essence_shift` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | slark_essence_shift |
| 4 | `enfos_slark_shadow_dance` | 10 | DOTA_ABILITY_BEHAVIOR_IMMEDIATE \| DOTA_ABILITY_BEHAVIOR_NO_TARGET | NOT_EXPLICIT | slark_shadow_dance |
| 5 | `enfos_slark_fish_bait` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | slark_fish_bait |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_slark.txt`; status: FILE_VERIFIED; SHA256: `c3bf34ff95deb386eaa918b14920ecd76b5a2a6060d7c07868ac39b8047cc752`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/slark/slark.vmdl` |
| SoundSet | `Hero_Slark` |
| Ability1 | `slark_dark_pact` |
| Ability2 | `slark_pounce` |
| Ability3 | `slark_saltwater_shiv` |
| Ability4 | `slark_depth_shroud` |
| Ability5 | `slark_essence_shift` |
| Ability6 | `slark_shadow_dance` |
| Ability10 | `special_bonus_unique_slark_6` |
| Ability11 | `special_bonus_unique_slark` |
| Ability12 | `special_bonus_unique_slark_2` |
| Ability13 | `special_bonus_unique_slark_8` |
| Ability14 | `special_bonus_unique_slark_4` |
| Ability15 | `special_bonus_unique_slark_7` |
| Ability16 | `special_bonus_unique_slark_3` |
| Ability17 | `special_bonus_unique_slark_5` |
| AttributeStrengthGain | `2.100000` |
| AttributeAgilityGain | `1.500000` |
| AttributeIntelligenceGain | `1.900000` |

### Per-ability review leads

- `enfos_slark_dark_pact`: cast/impact/modifier contract and lifetime.
- `enfos_slark_pounce`: cast/impact/modifier contract and lifetime.
- `enfos_slark_essence_shift`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `enfos_slark_shadow_dance`: ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_slark_fish_bait`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-10-04 native-first reopening: use the [current slot matrix/source
review](../../audit/SLARK_NATIVE_FIRST_REVIEW_2026-10-04.md) and [installed
build6943 ability/localization snapshot](../../audit/SLARK_NATIVE_SOURCE_2026-10-04.json).
Historical custom implementations and mocks below do not certify native behavior.
Q is classified TUNE and now delegates to native slark_dark_pact, with one
AGI special-value modifier rather than a custom pulse/dispelling loop. It preserves
authored ten-rank totals/radius/cost/CD, restores the native1.5-second delay and
30% blood cost, and tunes native pulses to the existing0.15-second interval.
The shared spawn service restores only the scaler; no points or native providers
are added. Both client/server register the class separately from server services.
EN/TR/RU/zh-CN descriptions include delay, blood cost and configured total.
Three native/source/scaling tests pass; actual C++ ten-rank reads, damage, purge,
VFX/SFX and lifecycle remain PENDING OWNER TEST. W/E/D source work remains open.

R source implementation2026-10-04: Shadow Dance now delegates to native
slark_shadow_dance through its stable ten-rank alias. The custom invisibility,
percentage-heal modifier and manual particle lifecycle are removed. Native owns
visibility-dependent passive bonuses, neutral-hit suppression and active cloud
concealment. Movement speed/duration/cost/CD retain authored curves; flat regen
uses native60–120 endpoints over ten ranks, replacing the prior8–18% healing.
Four-language tooltips describe this explicit balance change. Generic Scepter
CD reduction remains provisional until the coherent W/upgrade source unit.
Five focused Slark contracts and the full source checks pass (zero failed).
Native ten-rank reads, actual healing under the existing full-map vision policy,
concealment/detection, audio/visuals, upgrades and lifecycle remain PENDING OWNER TEST.

2026-09-30 implementation record: all five Enfos abilities now have ten KV ranks; Fish Bait is separated from Dota `Innate`. Installed source mapping: Dark Pact=`slark_dark_pact` (Ability1), Pounce=`slark_pounce` (Ability2), Essence Shift=`slark_essence_shift` (Ability5), Shadow Dance=`slark_shadow_dance` (Ability6), Fish Bait adapts `slark_saltwater_shiv` (Ability3). Dark Pact now uses KV pulse count/timing/radius and a verified Dota particle; Pounce now moves over timed 0.03-second steps instead of teleporting, uses start/trail/landing/leash effects and a true `MODIFIER_STATE_TETHERED` debuff; Essence Shift reads stack/agi/duration values and honors Break; Shadow Dance owns and cleans its persistent VFX; Fish Bait now reads its proc/cleave/armor values and applies capped armor stacks. Mock coverage passes for Q/W/Essence/Fish Bait. Eight used Slark particles are present in installed ClientVersion 6941 VPK. Live dash collision, particle CP/size, audio and PvE/boss balance remain PENDING.

2026-09-30 static special-value repair: migrated all five abilities' Lua-read values from legacy numbered `AbilitySpecial` rows to named `AbilityValues`, preserving each ten-rank curve and scalar. This follows the project-specific ClientVersion 6941 Sven finding: legacy values returned zero in live Lua callbacks and the named layout returned configured values after migration. Added a roster contract preventing the Slark values from reverting to the legacy layout. `node tools/checks.mjs` validates KV, ten-rank values, mocks and localization; this is not a Slark engine playtest. User-owned gameplay/audio/VFX checks remain pending.

2026-09-30 follow-up audit: Essence Shift's existing Agility stacks now stop
granting stats under Break, and neither Essence Shift nor Fish Bait can proc
from illusions. Both passive KV abilities now declare `IsBreakable 1`. Fish
Bait's physical cleave includes magic-immune units, and EN/TR/RU/zh-CN
descriptions now accurately describe the self-only Agility gain and Fish Bait
proc chance/cleave/armor stack values. Mock regressions cover Break, illusion
suppression and the target flag. In-engine behavior remains pending.

## Slot 1: `enfos_slark_dark_pact`

Classification: PVE-CONVERT
Native counterpart: `slark_dark_pact` (installed Ability1).
Decision and PvE identity rationale: preserve the self-purge and radial pulse pattern; distribute a rank-scaled total over configured pulses for PvE.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Dark Pact Q ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
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
| Ranks | PENDING | Q gates levels 1–10 declared; HUD/point behavior remains PENDING engine verification. |
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

## Slot 2: `enfos_slark_pounce`

Classification: PVE-CONVERT
Native counterpart: `slark_pounce` (installed Ability2).
Decision and PvE identity rationale: preserve Slark's forward leap and leash while resolving the previous instant teleport and adding boss-limited tether duration.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Pounce W ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
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
| Ranks | PENDING | W gates levels 1–10 declared; HUD/point behavior remains PENDING engine verification. |
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

## Slot 3: `enfos_slark_essence_shift`

Classification: PVE-CONVERT
Native counterpart: `slark_essence_shift` (installed Ability5).
Decision and PvE identity rationale: keep attack-earned Agility stacks with rank-driven Agility, duration and cap; Break disables stack gain and benefits.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Essence Shift E ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
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
| Ranks | PENDING | E gates levels 1–10 declared; HUD/point behavior remains PENDING engine verification. |
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

## Slot 4: `enfos_slark_shadow_dance`

Classification: PVE-CONVERT
Native counterpart: `slark_shadow_dance` (installed Ability6).
Decision and PvE identity rationale: retain invisibility and sustain with rank-scaled duration, movement and regeneration plus modifier-owned visual cleanup.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Shadow Dance R ranks 1–10 are KV-gated at levels 5, 10, …, 50; ultimate UI and point behavior remain PENDING.
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
| Gameplay | PENDING | Mock verifies the ranked duration, invisibility/truesight states, movement speed and regeneration; engine invisibility and regen behavior remain unverified. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | R gates levels 5–50 in five-level steps declared; ultimate HUD/point behavior remains PENDING. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Mock verifies modifier destruction destroys/releases the persistent particle; repeated live casts and engine cleanup remain unverified. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | Not evaluated in this dossier setup. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 5: `enfos_slark_fish_bait`

Classification: PVE-CONVERT
Native counterpart: `slark_saltwater_shiv` (installed Ability3).
Decision and PvE identity rationale: adapt the attack-proc identity as Enfos cleave and capped armor-reduction stacks, while keeping this fifth slot separate from Dota innate metadata.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve; free rank / point cost: ten ranks are defined; the Enfos passive rank 1 grant is separate from Dota innate metadata, ranks 2–10 are gated at levels 2–10; in-engine points remain pending.
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
| Ranks | PENDING | Separate passive rank 1 grant retained; ranks 2–10 gates declared; in-game HUD/point behavior remains PENDING. |
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

2026-09-30 level-cap integration: all five Slark abilities now declare KV rank gates. Q/W/E and the Enfos passive use one rank per level; passive rank 1 remains a separate Enfos grant. Shadow Dance ranks 1–10 unlock on levels 5, 10, …, 50. Static KV contract passes; actual rank buttons, level-up points, ultimate badge and match-start level 6 remain PENDING for owner testing.

2026-09-30 static regression follow-up: Shadow Dance now has mock coverage for its ranked timed modifier, invisibility/truesight states, movement/regen values, and persistent-particle destruction/release. Actual Dota state semantics, visibility, audio and repeated-cast cleanup remain PENDING owner testing.
