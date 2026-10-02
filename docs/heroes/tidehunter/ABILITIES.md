# Tidehunter: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_tidehunter`; role: Tank. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_tide_gush` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/pve_kits | tidehunter_gush |
| 2 | `enfos_tide_kraken_shell` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | tidehunter_kraken_shell |
| 3 | `enfos_tide_anchor_smash` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | tidehunter_anchor_smash |
| 4 | `enfos_tide_ravage` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | tidehunter_ravage |
| 5 | `enfos_tide_colossal_presence` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | tidehunter_kraken_shell |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [Lua](../../../game/scripts/vscripts/abilities/pve_kits.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_tidehunter.txt`; status: FILE_VERIFIED; SHA256: `8c96be768e85e8d845bc6ef04f99ad261c0f9bd5c0e45503aedb6ab4c5c78cda`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/tidehunter/tidehunter.vmdl` |
| SoundSet | `Hero_Tidehunter` |
| Ability1 | `tidehunter_gush` |
| Ability2 | `tidehunter_kraken_shell` |
| Ability3 | `tidehunter_anchor_smash` |
| Ability4 | `tidehunter_dead_in_the_water` |
| Ability5 | `generic_hidden` |
| Ability6 | `tidehunter_ravage` |
| Ability7 | `tidehunter_leviathans_catch` |
| Ability10 | `special_bonus_unique_tidehunter_3` |
| Ability11 | `special_bonus_unique_tidehunter_5` |
| Ability12 | `special_bonus_unique_tidehunter_2` |
| Ability13 | `special_bonus_unique_tidehunter_ravage_cooldown` |
| Ability14 | `special_bonus_unique_tidehunter_smash_on_blubber` |
| Ability15 | `special_bonus_unique_tidehunter` |
| Ability16 | `special_bonus_unique_tidehunter_7` |
| Ability17 | `special_bonus_unique_tidehunter_10` |
| AttributeStrengthGain | `3.7` |
| AttributeAgilityGain | `1.500000` |
| AttributeIntelligenceGain | `1.700000` |

### Per-ability review leads

- `enfos_tide_gush`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_tide_kraken_shell`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `enfos_tide_anchor_smash`: cast/impact/modifier contract and lifetime.
- `enfos_tide_ravage`: ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_tide_colossal_presence`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-10-02 Sol re-review: a targeted regression reproduced Gush/Anchor Smash attempting debuff application after synchronous damage callbacks removed the target, caster or ability. Both now revalidate handles before debuff calls; Anchor Smash also validates each remaining target/source before continued area work. Damage formulas, flags, durations and current timing are retained (PVE-CONVERT classification unchanged). Actual engine deletion/death, visuals/audio and Boss behavior remain owner PENDING; the existing individual ledger remains in progress.

2026-09-30 static special-value repair: converted all five Lua-driven Tidehunter abilities from legacy numbered `AbilitySpecial` entries to named `AbilityValues`, retaining the existing ten-rank curves and scalars. A content contract now guards the schema. This follows the project-specific Sven value-loading finding; no Tidehunter Dota playtest is claimed. Boss response, VFX/SFX and gameplay in the engine remain for the user to test.

## Slot 1: `enfos_tide_gush`

Classification: PVE-CONVERT
Native counterpart: `tidehunter_gush` (native Ability1).
Decision and PvE identity rationale: Keep the recognizable single-target Gush impact; convert PvP-only utility to wave damage and a short armor/movement slow. Native source mapping verified in installed hero KV (ClientVersion 6943, SourceRevision 11069754).
Expected cast/travel/impact/ongoing/cleanup behavior: On valid enemy cast, launch the verified native Gush tracking particle at 2500 speed; apply damage and armor/movement debuff only on live-target projectile impact; a dodged, dead, missing or friendly target has no impact. Tracking projectile ends on callback return.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Gush Q ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING.

### Resource and implementation evidence

#### 2026-10-02 projectile correction

Static root cause confirmed: Lua previously attached the native travel trail at the target and applied damage/modifiers immediately, while the installed VPCF is a source-to-target travelling projectile. Gush now uses a tracking projectile at the native 2500 speed and applies damage/debuff on impact. Regression coverage checks cast delay, particle/speed, lost target, spell block/ally rejection and the existing Strength-scaled impact. Dota runtime VFX, audio, dodge and collision behavior remain pending owner testing. Native Scepter speed/AoE/range modifiers are not claimed as implemented; Enfos Scepter policy needs a separate review.

- Native ability data source + build + hash/revision: `tidehunter_gush` in installed ClientVersion 6943 / SourceRevision 11069754; SHA256 is recorded in the installed-source section above and matches the saved snapshot.
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: travel particle confirmed in installed VPK and configured through tracking projectile source/target; in-engine attachment and rendered result remain PENDING.
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
| Ranks | PENDING | Q gate levels 1–10 are declared; in-game HUD and point behavior remain PENDING. |
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

Change/test record (2026-09-30): mapped native counterparts from the installed Tidehunter hero KV (ClientVersion 6941, SourceRevision 11041083); set all five Enfos slots to MaxLevel 10; added Gush spell-absorb/friendly-target guards and localization alignment; made Kraken Shell block/regen obey Break; made Anchor Smash read its documented bonus special while retaining attack and Strength damage; moved Ravage boss stun cap into KV; removed the false Dota Innate marker and made Colossal Presence values data-driven/Break-aware. Automated regression status: PASS — `node_modules/.bin/fengari tests/hero_kit_regressions.lua` (98 mock regressions) and `node tools/checks.mjs` (0 failed checks); all three particle paths exist in the installed Valve VPK. Dota/VConsole gameplay, visual/audio quality, particle control-point placement, live boss behavior, and cold-start precache verification remain PENDING; mocks are not ENGINE_PASS.

2026-09-30 static follow-up: Kraken Shell's constant-health-regeneration callback was implemented but its property was missing from `DeclareFunctions`, so Dota would not request the callback. Registered `MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT` and strengthened the mock regression to require that engine property declaration. In-game health regeneration remains PENDING.

2026-09-30 target-flag repair: Anchor Smash declares
`SPELL_IMMUNITY_ENEMIES_YES`, but its Lua radius query used the default flags,
which exclude spell-immune enemies. The query now explicitly includes
`DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES`; its regression asserts the flag.
Actual interaction with immune units and the debuff's engine behavior remain
PENDING for owner testing.

2026-09-30 value/tooltip repair: Gush and Anchor Smash now read their Strength
coefficients from named KV specials; EN/TR/RU/zh-CN descriptions expose those
formulas. Kraken Shell's existing 450 accumulated-damage dispel threshold is
now a named KV value, described in all four languages, and covered by a
threshold regression. The values and existing behavior are preserved. This
does not certify the engine's damage event semantics or real spell-immunity
interaction; both remain PENDING for owner testing.

## Slot 2: `enfos_tide_kraken_shell`

Classification: PVE-CONVERT
Native counterpart: `tidehunter_kraken_shell` (native Ability2).
Decision and PvE identity rationale: Keep the defensive shell identity; retain physical damage block, add the existing Enfos health-regeneration special, and make both obey Break. This is a focused passive implementation, not a native innate.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Kraken Shell W ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
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
| Gameplay | PENDING | Kraken Shell computes its configured HP regeneration, and its Lua modifier now declares the engine's constant-health-regen property so the engine can request it; a regression checks the declaration. Actual in-game regeneration still requires owner testing. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | W gate levels 1–10 are declared; in-game HUD and point behavior remain PENDING. |
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

Change/test record (2026-09-30): Included in the 98 passing hero-kit mock regressions and full repository checks. No real Dota/VConsole test has been performed; gameplay, VFX/SFX quality, modifier edge cases, and engine acceptance remain PENDING.

## Slot 3: `enfos_tide_anchor_smash`

Classification: PVE-CONVERT
Native counterpart: `tidehunter_anchor_smash` (native Ability3).
Decision and PvE identity rationale: Keep the close-range anchor sweep and attack-damage debuff; add Strength scaling for PvE and retain configured radius/duration. Both native identity and Enfos scaling are explicit.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Anchor Smash E ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
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
| Ranks | PENDING | E gate levels 1–10 are declared; in-game HUD and point behavior remain PENDING. |
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

## Slot 4: `enfos_tide_ravage`

Classification: PVE-CONVERT
Native counterpart: `tidehunter_ravage` (native Ability6).
Decision and PvE identity rationale: Keep Ravage area damage/stun; cap boss stun with a KV value so bosses cannot be locked for the full creep duration.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Ravage R ranks 1–10 are KV-gated at levels 5, 10, …, 50; ultimate UI and point behavior remain PENDING.
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
| Ranks | PENDING | R gate levels 5–50 in five-level steps is declared; ultimate HUD and point behavior remain PENDING. |
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

## Slot 5: `enfos_tide_colossal_presence`

Classification: REPLACE
Native counterpart: No native counterpart — custom Enfos passive in slot 5.
Decision and PvE identity rationale: Use the free-start Enfos passive system (heroes/innates.lua), entirely separate from Dota Innate metadata. Grants Tidehunter flat health/armor and weakens nearby enemies; Break disables the passive.
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
| Gameplay | PENDING | Not evaluated in this dossier setup. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | The separate passive rank 1 grant remains; ranks 2–10 gates are declared; in-game HUD and point behavior remain PENDING. |
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

2026-09-30 level-cap integration: all five Tidehunter abilities now declare KV rank gates. Q/W/E and the Enfos passive use one rank per level; passive rank 1 remains a separate Enfos grant. Ravage ranks 1–10 unlock on levels 5, 10, …, 50. Static KV contract passes; actual rank buttons, level-up points, ultimate badge and match-start level 6 remain PENDING for owner testing.

2026-09-30 global Break metadata audit: Added KV `IsBreakable 1` to `enfos_tide_kraken_shell`, `enfos_tide_colossal_presence` because its linked Lua passive implementation check `PassivesDisabled()`. Automated content validation now rejects this metadata mismatch. Actual Dota Break behavior remains PENDING.

2026-10-02 individual presentation review: Installed ClientVersion 6943 / SourceRevision 11069754 confirms Gush, Anchor Smash, and Ravage cast activities `ACT_DOTA_CAST_ABILITY_1`, `_3`, and `_4`, respectively. The custom KV omitted them. Added the exact activities. Native definitions declare Gush sound `Ability.GushCast` and Ravage `Ability.Ravage`; the prior Lua literals `Hero_Tidehunter.Gush.Cast` and `Hero_Tidehunter.Ravage` were absent from the decoded Tidehunter hero-bank snapshot, so moved playback to native KV `AbilitySound` and removed duplicate/unverified Lua emissions. Anchor Smash remains on the exact native `Hero_Tidehunter.AnchorSmash` event. Tidehunter's sound bank is now explicitly precached at bootstrap. Content contract regression covers these declarations. This verifies IDs and static wiring, not in-game animation/audio playback or cold-start load.

See [the individual review ledger](../../audit/TIDEHUNTER_INDIVIDUAL_REVIEW_2026-10-02.md) for per-slot behavior, provenance and remaining engine tests.

2026-10-02 Sol Kraken Shell follow-up: the source-backed inactivity interval is now a named KV value (`purge_reset_interval=7`). Positive damage after at least seven paused-aware game-time seconds resets prior cleanse progress; zero/negative events neither change the counter nor extend the window. Regression reproduced the old nonpositive-event/counter behavior before repair and now covers exact-boundary reset, continued accumulation and threshold purge. All 299 hero-kit mock regressions and the full repository checks pass (0 failures). Four source locales and their generated mirrors describe the reset. This preserves the authored passive conversion, not the native active Kraken Shell. Actual damage ordering, pause timing, strong dispel, Break and death/respawn remain owner engine PENDING.

2026-10-02 Sol inactive-source repair: Kraken Shell and Colossal Presence now validate a live learned originating ability before granting their effects. This closes residual Strength block/default cleanse and active-aura behavior when the source is missing, removed or unlearned. Focused pre-change regression failed; all 300 hero-kit mock regressions and full repository checks now pass. Existing learned values and Break behavior are preserved. Learning/removing the source in Dota, aura fade and health recalculation remain ENGINE_PENDING.

2026-10-02 formula reconciliation: Kraken Shell's authored Strength × 0.05 block and Ravage's Strength × 2 damage are unchanged but now named `strength_factor` KV values and present in EN/TR/RU/zh-CN descriptions. Modified coefficient regressions verify Lua actually reads the fields. Full checks pass; in-client tooltip and post-mitigation damage verification remain PENDING. This does not certify the current instant Ravage as native expanding-wave behavior.

2026-10-02 Ravage lifetime repair: each recipient and source is revalidated before stun and after modifier callbacks before damage. A previous hit removing later units/source/ability or switching team no longer passes stale handles to modifier/damage calls. Pre-change two-target regression failed; added damage- and modifier-callback cases now pass with all 302 mock regressions and full checks. Damage, boss cap, instant timing and asset wiring stay unchanged. Dota callback behavior and presentation remain PENDING.

2026-10-02 unique Scepter: supersedes previous generic ultimate-upgrade notes. Gush owns the Scepter upgrade: a point-target piercing wave with native-source 2200 range, 260 collision radius, 1500 speed and 7-second base cooldown. Existing ten-rank damage/Strength/debuff values stay. Without Scepter, native-theme single-target tracking/spell block remains. Cast metadata keeps penetration stable after item drop. Tidehunter's generic ultimate damage/cooldown bonus is disabled, other heroes unchanged. The wave uses the verified native upgrade particle and existing Gush sound/animation; explicit precache added. Four descriptions and upgrade metadata moved from Ravage to Gush. Shard is still pending a unique conversion. ENGINE_PENDING includes dynamic targeting updates, projectile appearance/collision/audio, immunity/dodge/absorb, boss balance and VConsole; mocks do not certify these.

Scepter cooldown adaptation: uses min(normal ranked cooldown, 7 seconds), preserving the existing 6-second rank-ten cooldown. Four upgrade tooltips state the 7-second ceiling; regression covers the high-rank case. Prior fixed-cooldown wording is superseded.
