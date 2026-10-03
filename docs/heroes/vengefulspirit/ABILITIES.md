# Vengeful Spirit: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

2026-10-03 Q Shard correction: the installed native one-bounce upgrade now
belongs to `enfos_vs_magic_missile`, using 75% of current effective cast range
and hero priority. D no longer advertises unrelated healing amplification.
See the [individual ledger](../../audit/VENGEFUL_SPIRIT_INDIVIDUAL_REVIEW_2026-10-03.md)
for provenance, bounded projectile policy, regression evidence and outstanding
Scepter/W/E source work. Actual Dota/VConsole acceptance remains owner-pending.

2026-10-03 W correction: native total-attack reduction was absent from the
custom wave. It now snapshots 10/15/20/25% (25% at ranks 5–10) alongside the
existing damage/armor and replicates its modifier value on creation/refresh.
Native vision/recipient VFX and real attack/immunity/dispel verification remain
open in the individual ledger; this does not certify W or the whole hero.

2026-10-03 E correction: emitter/radius now require a valid learned ability,
and Venge herself receives the native 25% extra aura benefit (relative to the
aura bonus). Ally curves and source Break behavior are preserved. See the
individual ledger for source/fixture evidence and pending Scepter/engine gates.

2026-10-03 W presentation/vision correction: native recipient root is bound to
the debuff and preloaded by the existing startup owner. The traveling wave now
grants caster-team 350-radius vision and leaves engine-expiring 4-second viewers
on its actual path. Native root/child CP evidence and outstanding visual/FOW/
performance owner tests are recorded in the individual ledger.

2026-10-03 native rules/R correction: Q/W/R declare installed immunity and
dispel metadata. R interrupts its target's channel and revalidates synchronous
callback invalidation before effects/movement. Authored defense gains its native
R icon and explicit basic purgeability. Q death/absorb timing, R trees/native
target filter and full immunity/dispel engine behavior remain review gates.

2026-10-03 Scepter source repair: E owns the upgrade, with native +10 percentage
points to its relative self multiplier (25% to 35%). A hidden rank-one native
`vengefulspirit_command_aura` alias delegates death-illusion lifecycle to the
engine; its aura damage/radius are zero to avoid duplicating authored E stats.
Slot 6 is internal, not a sixth spendable skill. Generic ultimate amplification
and cooldown bonuses are removed for Venge only. Local fixtures validate bridge
reconciliation/ownership and aura arithmetic, NOT native illusion generation.
Death, copied custom spells/ranks, XP, respawn, upgrade loss, VFX/precache and
native alias compatibility remain mandatory owner Dota/VConsole tests. See the
individual ledger for evidence and constraints. Hero remains NOT DONE.

2026-10-03 R particle repair: installed roots create particles on a model and
move/lock to the opposite model's CP1 hitboxes/bones. World-origin roots with
nil owners and position-only CP1 were incorrect. R now creates model-following
roots after safe placement, binds opposite units and releases both finite
roots. Installed source + MIT ValveExamples wiring and 20-cast mock evidence
are in the individual ledger. Actual visuals/cold-load/performance remain
owner NOT TESTED; this is not whole-hero acceptance.

2026-10-03 Q timing repair: spell block is checked at each projectile impact,
including Shard secondary impact, with callback invalidation revalidation before
damage/stun/impact feedback or bounce. Initial source attachment uses verified
ATTACK_2. The pinned Valve example supports this custom implementation pattern;
it does not certify current native C++ timing. Late/expired block, disjoint,
removed entities/ability and team change fixtures pass. Existing caster-death
policy is unchanged and remains a separate owner/native verification gate.

2026-10-03 R targeting/terrain repair: reject self before spending the cast,
delegate hero/basic both-team filtering to native UnitFilter with KV immunity
piercing flags, and clear trees at both endpoints before placement. Radius 300
is an authored reference-backed value, not a certified current C++ constant.
Tree callback invalidation aborts further operations. Four locales disclose
clearance and self restriction. Ordinary/Boss/ally, rejected casts, client filter
and tree invalidation regressions pass; real target filtering, native-radius
comparison and map tree behavior remain owner NOT TESTED.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_vengefulspirit`; role: Support. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_vs_magic_missile` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/heroes/vengefulspirit/q | vengefulspirit_magic_missile |
| 2 | `enfos_vs_wave_of_terror` | 10 | DOTA_ABILITY_BEHAVIOR_POINT | abilities/heroes/vengefulspirit/w | vengefulspirit_wave_of_terror |
| 3 | `enfos_vs_vengeance_aura` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/heroes/vengefulspirit/e | vengefulspirit_command_aura |
| 4 | `enfos_vs_nether_swap` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/heroes/vengefulspirit/r | vengefulspirit_nether_swap |
| 5 | `enfos_vs_retribution` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/heroes/vengefulspirit/d | vengefulspirit_command_aura |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [abilities/heroes/vengefulspirit/q](../../../game/scripts/vscripts/abilities/heroes/vengefulspirit/q.lua), [abilities/heroes/vengefulspirit/w](../../../game/scripts/vscripts/abilities/heroes/vengefulspirit/w.lua), [abilities/heroes/vengefulspirit/e](../../../game/scripts/vscripts/abilities/heroes/vengefulspirit/e.lua), [abilities/heroes/vengefulspirit/r](../../../game/scripts/vscripts/abilities/heroes/vengefulspirit/r.lua), [abilities/heroes/vengefulspirit/d](../../../game/scripts/vscripts/abilities/heroes/vengefulspirit/d.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_vengefulspirit.txt`; status: FILE_VERIFIED; SHA256: `3853993f2cdf388a31d6c5e4bdf60a6904a0431496ffef278995e5a40298739b`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/vengeful/vengeful.vmdl` |
| SoundSet | `Hero_VengefulSpirit` |
| Ability1 | `vengefulspirit_magic_missile` |
| Ability2 | `vengefulspirit_wave_of_terror` |
| Ability3 | `vengefulspirit_command_aura` |
| Ability4 | `vengefulspirit_retribution` |
| Ability5 | `generic_hidden` |
| Ability6 | `vengefulspirit_nether_swap` |
| Ability10 | `special_bonus_unique_vengeful_spirit_swap_damage` |
| Ability11 | `special_bonus_unique_vengeful_spirit_missile_castrange` |
| Ability12 | `special_bonus_unique_vengeful_spirit_4` |
| Ability13 | `special_bonus_unique_vengeful_spirit_1` |
| Ability14 | `special_bonus_unique_vengeful_spirit_wave_of_terror_steal` |
| Ability15 | `special_bonus_unique_vengeful_spirit_5` |
| Ability16 | `special_bonus_unique_vengeful_spirit_2` |
| Ability17 | `special_bonus_unique_vengeful_spirit_9` |
| AttributeStrengthGain | `2.6` |
| AttributeAgilityGain | `3.0` |
| AttributeIntelligenceGain | `1.5` |

### Per-ability review leads

- `enfos_vs_magic_missile`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_vs_wave_of_terror`: world position, travel/impact timing and radius alignment.
- `enfos_vs_vengeance_aura`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `enfos_vs_nether_swap`: target flags, immunity, spell block/reflect if applicable, target loss; ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_vs_retribution`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-10-03 reverse-roster individual review: see
[the current five-slot ledger](../../audit/VENGEFUL_SPIRIT_INDIVIDUAL_REVIEW_2026-10-03.md).
Its build-6943 native evidence and TUNE/TUNE/TUNE/TUNE/REPLACE decisions supersede
the historical blanket PVE-CONVERT wording below. The five stable classes are
isolated; source review, upgrades and owner engine tests are still pending.
Focused E regression reproduced an attached aura retaining damage during source
Break. The recipient getter now checks its source, handles removed/rank-zero
abilities and retains live ranks and the existing illusion-recipient policy.
Recipient Break alone does not disable this external aura. Dota linger/damage
verification remains pending owner testing.

2026-09-30 level-50 migration: Q/W/E/Enfos passive gates start at level 1 with interval 1; R starts at level 5 with interval 5. Static contract test added; point/HUD and gameplay acceptance remain pending for owner live test.

2026-09-30 static repair: Wave of Terror now flattens the cast direction and falls back to Vengeful Spirit's facing if the cursor overlaps her position, avoiding a degenerate line/particle direction. Its mock now exercises that zero-length aim while checking that only an enemy inside the line is hit. Live projectile/particle direction, visual alignment, audio and runtime targeting remain PENDING owner testing.

## Slot 1: `enfos_vs_magic_missile`

Classification: PVE-CONVERT
Native counterpart: `vengefulspirit_magic_missile` (installed native hero snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot assignment is project-specific).
Decision and PvE identity rationale: PVE-CONVERT to retain the verified native hero identity while adapting PvP-only details for wave, elite and boss combat.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve; free rank / point cost: PENDING.
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
| Ranks | PENDING | Static gates put rank 10 by level 50; owner live test must confirm engine points and ability HUD. |
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

Change/test record: all five abilities now expose ten KV ranks; the complete 200-ability Lua mock suite passes. This confirms static/mock behavior only; in-match Dota VFX, SFX, rank-up HUD, boss and VConsole acceptance remain PENDING.

Change/test record (2026-09-30): Vengeful Spirit’s five Enfos ability definitions now expose named `AbilityValues` fields for Lua while preserving ten-rank curves. Static test added for all five slots. The dossier’s existing runtime evidence rows remain pending; user live testing is required for gameplay, targeting, VFX, SFX, cleanup, boss and upgrades.

Follow-up static audit (2026-09-30): Vengeance Aura remained active when its
source was Broken, so teammates continued receiving its passive attack bonus.
The aura now checks the source hero's passives-disabled state, with a regression
test covering active and Broken states. Other four handlers, rank/value mappings,
localization, upgrade links and listed particle paths were statically checked;
no other defect was confirmed. Engine targeting, aura refresh, gameplay, VFX/SFX,
precaching, and cleanup remain pending the owner's in-game test.

## Slot 2: `enfos_vs_wave_of_terror`

Classification: PVE-CONVERT
Native counterpart: `vengefulspirit_wave_of_terror` (installed native hero snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot assignment is project-specific).
Decision and PvE identity rationale: PVE-CONVERT to retain the verified native hero identity while adapting PvP-only details for wave, elite and boss combat.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve; free rank / point cost: PENDING.
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
| Ranks | PENDING | Static gates put rank 10 by level 50; owner live test must confirm engine points and ability HUD. |
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

Change/test record: all five abilities now expose ten KV ranks; the complete 200-ability Lua mock suite passes. This confirms static/mock behavior only; in-match Dota VFX, SFX, rank-up HUD, boss and VConsole acceptance remain PENDING.

## Slot 3: `enfos_vs_vengeance_aura`

Classification: PVE-CONVERT
Native counterpart: `vengeance_aura (native passive source)` (installed native hero snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot assignment is project-specific).
Decision and PvE identity rationale: PVE-CONVERT to retain the verified native hero identity while adapting PvP-only details for wave, elite and boss combat.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve; free rank / point cost: PENDING.
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
| Ranks | PENDING | Static gates put rank 10 by level 50; owner live test must confirm engine points and ability HUD. |
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

Change/test record: all five abilities now expose ten KV ranks; the complete 200-ability Lua mock suite passes. This confirms static/mock behavior only; in-match Dota VFX, SFX, rank-up HUD, boss and VConsole acceptance remain PENDING.

## Slot 4: `enfos_vs_nether_swap`

Classification: PVE-CONVERT
Native counterpart: `vengefulspirit_nether_swap` (installed native hero snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot assignment is project-specific).
Decision and PvE identity rationale: PVE-CONVERT to retain the verified native hero identity while adapting PvP-only details for wave, elite and boss combat.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve; free rank / point cost: PENDING.
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
| Ranks | PENDING | Static gates put rank 10 by level 50; owner live test must confirm engine points and ability HUD. |
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

Change/test record: all five abilities now expose ten KV ranks; the complete 200-ability Lua mock suite passes. This confirms static/mock behavior only; in-match Dota VFX, SFX, rank-up HUD, boss and VConsole acceptance remain PENDING.

## Slot 5: `enfos_vs_retribution`

Classification: REPLACE
Native counterpart: `Project-specific Enfos passive; native innate remains distinct` (installed native hero snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot assignment is project-specific).
Decision and PvE identity rationale: REPLACE because this fifth ability is an Enfos-authored passive with no direct native counterpart; its hero identity comes from the adjacent Dota kit.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve; free rank / point cost: PENDING.
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
| Ranks | PENDING | Static gates put rank 10 by level 50; owner live test must confirm engine points and ability HUD. |
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

Change/test record: all five abilities now expose ten KV ranks; the complete 200-ability Lua mock suite passes. This confirms static/mock behavior only; in-match Dota VFX, SFX, rank-up HUD, boss and VConsole acceptance remain PENDING.

2026-09-30 global Break metadata audit: Added KV `IsBreakable 1` to `enfos_vs_vengeance_aura`, `enfos_vs_retribution` because its linked Lua passive implementation check `PassivesDisabled()`. Automated content validation now rejects this metadata mismatch. Actual Dota Break behavior remains PENDING.
