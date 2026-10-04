# Dragon Knight: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_dragon_knight`; role: Tank. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_dk_breathe_fire` | 10 | DOTA_ABILITY_BEHAVIOR_DIRECTIONAL \| DOTA_ABILITY_BEHAVIOR_POINT \| DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | NOT_EXPLICIT | dragon_knight_breathe_fire |
| 2 | `enfos_dk_dragon_tail` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/pve_kits | dragon_knight_dragon_tail |
| 3 | `enfos_dk_dragon_blood` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/heroes/dragon_knight/e | dragon_knight_dragon_blood |
| 4 | `enfos_dk_elder_dragon_form` | 10 | DOTA_ABILITY_BEHAVIOR_NO_TARGET | abilities/pve_kits | dragon_knight_elder_dragon_form |
| 5 | `enfos_dk_wyrm_vigor` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/pve_kits | dragon_knight_wyrms_wrath |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [abilities/pve_kits](../../../game/scripts/vscripts/abilities/pve_kits.lua), [abilities/heroes/dragon_knight/e](../../../game/scripts/vscripts/abilities/heroes/dragon_knight/e.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_dragon_knight.txt`; status: FILE_VERIFIED; SHA256: `3dcfc11fbe634effac91207ead048537ffdda6b22ad030c7c097c1d43b3b2043`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/dragon_knight/dragon_knight.vmdl` |
| SoundSet | `Hero_DragonKnight` |
| Ability1 | `dragon_knight_breathe_fire` |
| Ability2 | `dragon_knight_dragon_tail` |
| Ability3 | `dragon_knight_wyrms_wrath` |
| Ability4 | `dragon_knight_fireball` |
| Ability5 | `dragon_knight_dragon_blood` |
| Ability6 | `dragon_knight_elder_dragon_form` |
| Ability10 | `special_bonus_attack_damage_15` |
| Ability11 | `special_bonus_unique_dragon_knight_3` |
| Ability12 | `special_bonus_unique_dragon_knight_2` |
| Ability13 | `special_bonus_hp_300` |
| Ability14 | `special_bonus_unique_dragon_knight_7` |
| Ability15 | `special_bonus_unique_dragon_knight_9` |
| Ability16 | `special_bonus_unique_dragon_knight` |
| Ability17 | `special_bonus_unique_dragon_knight_wyrms_wrath_damage` |
| AttributeStrengthGain | `3.200000` |
| AttributeAgilityGain | `2.000000` |
| AttributeIntelligenceGain | `1.700000` |

### Per-ability review leads

- `enfos_dk_breathe_fire`: target flags, immunity, spell block/reflect if applicable, target loss; world position, travel/impact timing and radius alignment.
- `enfos_dk_dragon_tail`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_dk_dragon_blood`: intrinsic modifier, Break/illusion behavior, live rank refresh.
- `enfos_dk_elder_dragon_form`: ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_dk_wyrm_vigor`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-10-04 native-first discovery: current installed build6943/revision11069754
and unchanged hero SHA2563dcfc11f...3b2043 re-read. Six native definitions,
eleven compiled resource hashes and English tokens recorded in
[native snapshot](../../audit/DRAGON_KNIGHT_NATIVE_SOURCE_2026-10-04.json).
The [pre-mutation five-slot matrix](../../audit/DRAGON_KNIGHT_NATIVE_FIRST_REVIEW_2026-10-04.md)
classifies all slots TUNE / NATIVE+MINIMAL EXT as implementation candidates.
Production still uses the earlier CUSTOM Lua below; no native migration or
engine PASS is claimed. Native Q travels, W is magical/non-piercing, Dragon
Blood is an innate with a50% form bonus, Wyrm's Wrath is attack magic/AoE,
R has cumulative green/red/blue plus Scepter black tiers and Shard Fireball.
Old color facets are Deprecated=true. Ten-rank native form-tier/read paths
and exact linked providers require focused implementation; do not infer C++
rank10 support or use old facet-reference code. Existing lifecycle fixes stay.
Next source unit Q; all gameplay/presentation/upgrade/lifecycle gates PENDING.

2026-10-03 form policy/presentation: current6943 native R source explicitly
declares no dispel. The authored PVE-CONVERT form now has `IsPurgable=false`
and matching ability KV metadata; cast has server/valid-caster guards. Real
form/frost secondary modifiers now have four-language names and dynamic values
plus verified form icon.327 hero behavior mocks and project checks pass; actual
purge, transformation cleanup, HUD values/VFX/audio remain owner PENDING.
See the [individual ledger](../../audit/DRAGON_KNIGHT_INDIVIDUAL_REVIEW_2026-10-02.md).

2026-10-02 Breathe Fire planar targeting: old3D normalization followed by
Length2D<1 could discard the selected direction when terrain heights differ.
Q now flattens z before the near-zero check and normalization, retaining its
forward fallback. The shared planar mock initially hid this; a targeted3D fixture
reproduced the before-edit failure and passes after repair.318 mocks/full checks
pass. Range/width/damage and immediate timing unchanged; real terrain targeting,
native travel/VFX and audio remain owner PENDING.

2026-10-02 Q/W lifetime repair: targeted mock reproduced modifier application
after damage removed a recipient. Both casts now validate owner/ability/target
after damage; Q checks later recipients too. No new modifier is applied to
dead/removed/now-friendly targets. Valid hostile Q corpses keep the impact burst.
Removed/dead source or deleted ability stops further impacts. Damage/range/
duration/Boss cap unchanged.317 mocks and full checks pass; runtime remains
PENDING and the hero's individual review remains open.

2026-10-02 form cleanup: Elder Dragon Form now captures/restores the previous
attack capability, rather than forcing melee on removal, and avoids all getter/
setter calls on removed/null parents. Installed MCP getter/setter signatures
verified. Pre-change ranged-owner and removed-parent tests failed; repaired
tests and existing model/projectile restoration pass (316 mocks, full checks
zero failures). Native model/animation, death/expiry/refresh/cosmetics and
interaction with other transformations remain owner engine tests.

2026-10-02 passive validity repair: Dragon Blood and Wyrm Vigor now require a
valid owner and learned live ability, preserving Break and illusion suppression.
Rank0/source-removal mock reproduced a residual-bonus defect, including Dragon
Blood's Strength regen. The repaired callbacks return zero for absent/null
parent/ability and restore existing values when learned. All315 hero mocks and
full checks pass; live rank-up/health recalculation, passive free grant, death
and reconnect remain OWNER_RUNTIME PENDING. No curve or balance change.

2026-10-02 Sol re-review, R splash: installed native Elder Dragon Form definition
was reread through MCP, not inferred from icon/slot. Existing PVE-CONVERT splash
rejected a primary killed by the attack; targeted mock reproduced this. It now
accepts a valid hostile dead primary while requiring live enemy recipients and
learned/live ability source; nil/friendly/zero-damage events are rejected.
Synchronous damage callbacks cannot continue through removed recipient/owner/
ability or later targets. Existing percentages/radius/slow/flags preserved.
314 hero behavior mocks and full checks pass; actual Dota lethal-splash events,
effects, audio and Boss/immune behavior remain pending owner testing.

2026-09-30 implementation record: all five Enfos slots now have ten KV ranks and Wyrm Vigor is no longer marked as Dota `Innate`. Installed source mapping: Breathe Fire=`dragon_knight_breathe_fire` (Ability1), Dragon Tail=`dragon_knight_dragon_tail` (Ability2), Dragon Blood=`dragon_knight_dragon_blood` (Ability5), Elder Dragon Form=`dragon_knight_elder_dragon_form` (Ability6), Wyrm Vigor=`dragon_knight_wyrms_wrath` (Ability3). Q now queries a forward line with configured width/range and reads debuff duration; W rejects allies/spell block and reads boss cap from KV; passive bonuses honor Break; R reads rank-scaled form, range, splash and slow values and emits verified impact/transform particles. Six used particle assets were found in installed ClientVersion 6941 VPK; Q/W/R tests added. Live Dota visuals, audio, dragon model transformation, projectile display and 10-rank balance remain PENDING.

2026-09-30 static special-value repair: migrated all five Lua-driven abilities from legacy numbered `AbilitySpecial` rows to named `AbilityValues`, preserving all rank arrays and scalar values. Added a contract for the five Enfos slots. This follows the confirmed Sven special-value loading defect; no Dragon Knight live test is claimed. Remaining gameplay, VFX, SFX, transformation and boss checks are for the user in Dota.

2026-09-30 mock regression evidence: the current hero-kit suite passes Dragon Knight Breathe Fire line width, damage type and attack-damage debuff duration; Dragon Tail spell-block cancellation, boss stun cap and damage; Dragon Blood/Wyrm Vigor Break suppression and configured passive values; and Elder Dragon Form dragon-model application/restoration on modifier removal. These are mocked Lua behavior checks only. The KV rank gates and named-value inventory are structurally checked by the project suite; actual Dota cast behavior, 10-rank values, transformation/attack capability, particles, audio, boss effects and HUD/point behavior remain PENDING for owner testing.

2026-09-30 follow-up audit: Dragon Blood and Wyrm Vigor now declare KV
`IsBreakable 1`, matching their `PassivesDisabled` checks. Their armor, regen,
magic resistance and Strength bonuses also suppress on illusions. Content and
mock regressions cover both passive flags and illusion suppression. Runtime
Break/illusion, VFX, SFX, transformation and boss checks remain pending.

## Slot 1: `enfos_dk_breathe_fire`

Classification: TUNE
Native counterpart: `dragon_knight_breathe_fire` (installed Ability1).
Decision and PvE identity rationale: Pure native cone restores travel/targeting/attack reduction/feedback; minimal raw STR1.2 extension preserves authored damage and ten paid ranks.
Expected cast/travel/impact/ongoing/cleanup behavior: Native point/unit/directional traveling cone, range750/speed1050/start150/end250; magical120..660+STR1.2 and dispellable35..62% reduction for6..9s. Actual engine read path/cache/targeting/impact/presentation/cleanup remains OWNER_RUNTIME PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: Native ordinary targets/immunityNO/magical/dispellable reduction, no Boss-only exception; actual native engine interactions pending.
Current versus target rank curve: Breathe Fire Q ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING.

2026-10-04 source implementation: [Q decision, implementation and engine gates](../../audit/DRAGON_KNIGHT_NATIVE_FIRST_REVIEW_2026-10-04.md).
115 affected checks/311 hero mock regressions PASS. Old copied-line/terrain tests retired, W lifetime regressions retained.21 reviewed client classes; native cone/rank10/cache/actual damage remains pending.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: FILE_VERIFIED build6943/revision11069754, hero SHA2563dcfc11f...3b2043; full record in native snapshot.
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: PENDING.
- Sound events + declaring banks + emission target + loop termination: PENDING.
- Model/animation/gesture/icon evidence: PENDING.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: One raw scaling class/path on both contexts; no copied reduction modifier. Shared restore idempotent, no points/ranks/provider writes. Native effects remain PENDING.
- Precache owner and cold-start test: PENDING.
- One-shot/persistent cleanup owner and repeated-use test: PENDING.
- Localization keys and generated mirrors: Four descriptions/summaries and twelve mirrors match native cone/reduction fields; source checked.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Not evaluated in this dossier setup. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Q gates at levels 1–10 declared; in-game HUD/point behavior remains PENDING. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Not evaluated in this dossier setup. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PASS | Native cone/reduction text and resolved values checked in four locales and twelve mirrors. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: PENDING. Record exact build, date, reproduction steps, result and evidence paths. A mock pass is not ENGINE_PASS.

## Slot 2: `enfos_dk_dragon_tail`

Classification: PVE-CONVERT
Native counterpart: `dragon_knight_dragon_tail` (installed Ability2).
Decision and PvE identity rationale: preserve the close-range stun and add rank-scaled damage; boss duration is capped by KV rather than a hidden constant.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Dragon Tail W ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING.

2026-10-02 source comparison: the installed native Ability2 uses
`SpellImmunityType SPELL_IMMUNITY_ENEMIES_NO`; the Enfos W currently uses
`SPELL_IMMUNITY_ENEMIES_YES`, physical damage, and a separately capped Boss
stun. This changes native immunity behavior. No design decision was found that
explicitly authorizes the piercing exception. Keep this PvE-conversion choice
flagged for owner/runtime validation; do not infer it is correct merely because
the mock cast succeeds. KV and Lua currently agree on the physical damage and
boss-duration cap.

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
| Ranks | PENDING | W gates at levels 1–10 declared; in-game HUD/point behavior remains PENDING. |
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

## Slot 3: `enfos_dk_dragon_blood`

Classification: TUNE
Native counterpart: `dragon_knight_dragon_blood` (installed Ability5).
Decision and PvE identity rationale: NATIVE+MINIMAL EXT; paid ten-rank controller tunes exact native innate armor/regen, retaining STR.05. Native owns the sole stat intrinsic and50% form multiplier; copied stat modifier removed.
Expected cast/travel/impact/ongoing/cleanup behavior: passive; raw overrides replace native base/hero-level stats, zero before training/during Break/on illusions. Live native cache/stat result remains PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: self passive, no target searches or Boss exceptions; native stat/Break behavior pending engine.
Current versus target rank curve: Dragon Blood E ranks 1–10 are KV-gated at levels 1–10; engine point/UI behavior remains PENDING.
Shard / Scepter / Blessing / Evolution / Ascended interactions: native form multiplier stays native. R native linkage remains a dependent source unit; current custom form is not certified to trigger it. Full upgrades PENDING.

### Resource and implementation evidence

- Native ability data source + build + hash/revision: installed6943/revision11069754, unchanged SHA2563dcfc11f...3b2043 freshly re-read; [snapshot](../../audit/DRAGON_KNIGHT_NATIVE_SOURCE_2026-10-04.json) and [E decision/references](../../audit/DRAGON_KNIGHT_NATIVE_FIRST_REVIEW_2026-10-04.md).
- Cast/travel/impact/persistent particle paths + type + CP meanings + attachments: no extension cast/particle; native passive and form own feedback, engine PENDING.
- Sound events + declaring banks + emission target + loop termination: no extension sound; existing DragonKnight bank retained, native engine PENDING.
- Model/animation/gesture/icon evidence: verified native Dragon Blood icon; E does not transform models or animate casts.
- Modifier links, ownership, refresh, stacks, death/purge/Break rules: existing reviewed client/server scaling class/path, no extra class; live native intrinsic name queried. Server-only paid rank-up refresh; ordinary restore never refreshes. Break/illusion zero raw queries; actual native stats PENDING.
- Precache owner and cold-start test: existing native hero/model/bank owns kit resources; no new asset, cold-load PENDING.
- One-shot/persistent cleanup owner and repeated-use test: native intrinsic lifecycle; idempotent exact provider restore, no timers/points/stat copy. Engine death/reconnect PENDING.
- Localization keys and generated mirrors: four authored descriptions/summaries and12 mirrors; retired custom passive/direct modifier aliases removed.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Raw ten-rank replacements/STR/source guards pass both-context fixtures; actual armor/regen/hero-level math/cache pending owner. |
| Targeting | N/A | Passive self statistics, no target or cast. |
| Ranks | PENDING | E gates at levels 1–10 declared; in-game HUD/point behavior remains PENDING. |
| VFX | PENDING | No Lua duplicate, native passive/form feedback owner test pending. |
| SFX | PENDING | Native passive/form, no extension emitter; owner test pending. |
| Animation | N/A | Passive has no manual cast; R transformation is recorded separately. |
| Modifiers | PENDING | Source idempotence/rank-up refresh/zero-source fixtures pass; native creation/cache/Break/illusion pending. |
| Precache | PENDING | No new asset; native kit ownership retained, actual cold-load pending. |
| Cleanup | PENDING | No extension thinker/particle; native death/recast/reconnect pending. |
| Boss | N/A | Self stats have no enemy-type or Boss branch. |
| Upgrades | PENDING | Native50% form multiplier untouched; dependent native R linkage and upgrades pending. |
| Localization | PENDING | Four-language canonical/mirror contracts pass; actual native/paid HUD pending. |
| Performance | PENDING | No scan/timer, bounded trace and paid-upgrade refresh; dense engine session pending. |
| Reconnect | PENDING | One hidden exact innate/single scaling restore fixtures pass, no points writes; engine restore pending. |
| VConsole | PENDING | No owner E session; automatic read-only provider/intrinsic/stat queries added. |

Change/test record2026-10-04:106 affected source checks/311 hero mocks PASS. SOURCE_REVIEW implemented, OWNER_RUNTIME PENDING. Full restart later for KV/bootstrap. Native form multiplier needs R source unit; raw query fixtures do not prove native cache or actual stats. No imported reference code/assets.

## Slot 4: `enfos_dk_elder_dragon_form`

Classification: PVE-CONVERT
Native counterpart: `dragon_knight_elder_dragon_form` (installed Ability6).
Decision and PvE identity rationale: preserve the signature transformation and ranged attack, with bounded rank-scaled splash/slow values.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve: Elder Dragon Form R ranks 1–10 are KV-gated at levels 5, 10, …, 50; ultimate UI and point behavior remain PENDING.
Shard / Scepter / Blessing / Evolution / Ascended interactions: PENDING.

2026-10-02 lifecycle repair: the form temporarily replaces the ranged attack
projectile. The modifier now stores the pre-form projectile name and restores it
with the model when the form ends. Both API methods were confirmed in the
installed VScript catalog; mocked lifecycle regression passes. Engine transition
and death/reconnect cleanup are still PENDING.

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
| Ranks | PENDING | R gates at levels 5–50 in five-level steps declared; ultimate HUD/point behavior remains PENDING. |
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

## Slot 5: `enfos_dk_wyrm_vigor`

Classification: PVE-CONVERT
Native counterpart: `dragon_knight_wyrms_wrath` (installed Ability3).
Decision and PvE identity rationale: adapt the dragon's innate toughness identity as an Enfos separately granted fifth passive; Break suppresses its rank-scaled resistance and strength.
Expected cast/travel/impact/ongoing/cleanup behavior: PENDING.
Normal creep / elite / boss, immunity / dispel / resistance rules: PENDING.
Current versus target rank curve; free rank / point cost: ten ranks are defined; the Enfos passive rank 1 grant is separate from Dota innate metadata, ranks 2–10 are KV-gated at levels 2–10; in-engine points remain pending.
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
| Ranks | PENDING | Passive rank 1 grant remains separate; ranks 2–10 gates declared; in-game HUD/point behavior remains PENDING. |
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

2026-09-30 level-cap integration: all five Dragon Knight abilities now declare KV rank gates. Q/W/E and the Enfos passive use one rank per level; passive rank 1 remains a separate Enfos grant. Elder Dragon Form ranks 1–10 unlock on levels 5, 10, …, 50. Static KV contract passes; actual rank buttons, level-up points, ultimate badge and match-start level 6 remain PENDING for owner testing.
