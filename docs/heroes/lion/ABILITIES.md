# Lion: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_lion`; role: Support. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_lion_earth_spike` | 10 | DOTA_ABILITY_BEHAVIOR_POINT \| DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/heroes/lion/q | lion_impale |
| 2 | `enfos_lion_hex` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET | abilities/heroes/lion/w | lion_voodoo |
| 3 | `enfos_lion_mana_drain` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET \| DOTA_ABILITY_BEHAVIOR_CHANNELLED | abilities/heroes/lion/e | lion_mana_drain |
| 4 | `enfos_lion_finger_of_death` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET \| DOTA_ABILITY_BEHAVIOR_AOE \| DOTA_ABILITY_BEHAVIOR_ALT_CASTABLE | abilities/heroes/lion/r | lion_finger_of_death |
| 5 | `enfos_lion_demon_soul` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/heroes/lion/d | lion_mana_drain |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [abilities/heroes/lion/q](../../../game/scripts/vscripts/abilities/heroes/lion/q.lua), [abilities/heroes/lion/w](../../../game/scripts/vscripts/abilities/heroes/lion/w.lua), [abilities/heroes/lion/e](../../../game/scripts/vscripts/abilities/heroes/lion/e.lua), [abilities/heroes/lion/r](../../../game/scripts/vscripts/abilities/heroes/lion/r.lua), [abilities/heroes/lion/d](../../../game/scripts/vscripts/abilities/heroes/lion/d.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_lion.txt`; status: FILE_VERIFIED; SHA256: `8734daf1360ea784a2cb81a3afcac9f4e3d3d128f5ed0dabe47897a80e01c1c6`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/lion/lion.vmdl` |
| SoundSet | `Hero_Lion` |
| Ability1 | `lion_impale` |
| Ability2 | `lion_voodoo` |
| Ability3 | `lion_mana_drain` |
| Ability4 | `lion_to_hell_and_back` |
| Ability5 | `generic_hidden` |
| Ability6 | `lion_finger_of_death` |
| Ability7 | `` |
| Ability10 | `special_bonus_unique_lion_6` |
| Ability11 | `special_bonus_movement_speed_20` |
| Ability12 | `special_bonus_unique_lion_5` |
| Ability13 | `special_bonus_unique_lion_11` |
| Ability14 | `special_bonus_unique_lion_8` |
| Ability15 | `special_bonus_unique_lion_10` |
| Ability16 | `special_bonus_unique_lion_4` |
| Ability17 | `special_bonus_unique_lion_2` |
| AttributeStrengthGain | `2.4` |
| AttributeAgilityGain | `1.7` |
| AttributeIntelligenceGain | `3.500000` |

### Per-ability review leads

- `enfos_lion_earth_spike`: target flags, immunity, spell block/reflect if applicable, target loss; world position, travel/impact timing and radius alignment.
- `enfos_lion_hex`: target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_lion_mana_drain`: channel tick, interrupt, looping audio and thinker expiry; target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_lion_finger_of_death`: target flags, immunity, spell block/reflect if applicable, target loss; ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_lion_demon_soul`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-09-30 level-50 migration: Q/W/E/Enfos passive gates start at level 1 with interval 1; R starts at level 5 with interval 5. Static contract test added; point/HUD and gameplay acceptance remain pending for owner live test.

Static kit review (2026-09-30): added the missing startup precache for the exact
Impale hit particle used by Lua. Mana Drain now ends the actual ability channel
when its target dies or becomes invalid. Finger kill stacks now cap at 20; each
stack's Finger bonus damage and global spell amplification are KV-backed and
clamped to that cap, preventing unbounded growth over the 60-wave run. Tooltips
in EN/TR/RU/zh-CN now describe the code's actual Earth Spike area, Hex debuffs,
Mana Drain damage/mana/slow, Finger scaling/stacks, and Demon Soul cast-range /
spell-amplification bonus. Mock tests pass; Lion gameplay, VFX/SFX, channeling,
boss scaling, particle cold-start and Scepter runtime checks remain pending the
owner's Dota test. The 20-stack cap is a provisional static balance decision
and can be adjusted from live results.

Follow-up static audit (2026-09-30): rechecked all five Lua handlers against
their ten-rank KV values, EN/TR/RU/zh-CN tooltips, roster assignment, evolution
choices, Aghanim manager and targeted mocks. The shared Scepter modifier applies
the documented ultimate damage/cooldown bonuses to Finger of Death, and the
shared Support Shard effect matches the documented healing bonus. No additional
code defect was confirmed in this pass. Actual targeting, channel behavior,
damage, cold-start VFX/SFX and upgrade presentation remain pending the owner's
in-game test.

Data-mapping repair (2026-09-30): the Lua handlers contained values that were
already described by the kit but bypassed named KV fields. Earth Spike radius,
cast-direction distance and Intelligence coefficient; Hex boss duration and
base movement speed; Mana Drain channel/debuff duration and slow; and Finger's
Intelligence coefficient and boss max-health damage cap now read named
`AbilityValues`. Existing behavior values are preserved. Added mock regressions
for Earth Spike geometry/scaling, normal/boss Hex duration, Mana Drain duration/
slow, and Finger's boss cap. These checks prove the Lua/KV path only; engine
targeting, rank HUD, VFX/SFX, channel presentation, bosses and upgrades remain
PENDING for the owner's Dota test.

## Slot 1: `enfos_lion_earth_spike`

Classification: TUNE
Native counterpart: `lion_impale` (installed native hero snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot assignment is project-specific).
Decision and PvE identity rationale: TUNE; native Impale already fits creep combat. Preserve authored ten-rank/INT math while restoring verified native line travel. See the dated source unit; remaining vertical motion/engine gates are OPEN.
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

Change/test record (2026-09-30): Lion’s five Enfos ability values are now declared as named `AbilityValues` keys for Lua access; ten-rank curves are preserved and a per-hero static contract test was added. This mapping fix does not certify gameplay. Runtime behavior, targeting, VFX, SFX, modifier lifetimes, cleanup, boss and upgrade tests remain PENDING for the user’s live test.

## Slot 2: `enfos_lion_hex`

Classification: PVE-CONVERT
Native counterpart: `lion_voodoo` (installed native hero snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot assignment is project-specific).
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

## Slot 3: `enfos_lion_mana_drain`

Classification: PVE-CONVERT
Native counterpart: `lion_mana_drain` (installed native hero snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot assignment is project-specific).
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

## Slot 4: `enfos_lion_finger_of_death`

Classification: TUNE
Native counterpart: `lion_finger_of_death` (installed native hero snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot assignment is project-specific).
Decision and PvE identity rationale: TUNE native Finger identity with authored ten-rank/INT/ordinary PvE kill scaling; verified native delay, grace and Scepter burst restored. Normal/AltCast melee empowerment core restored in isolated r_punch; native fist kill attribution remains OPEN. No Elite units/waves are authored under the current product contract.
Expected cast/travel/impact/ongoing/cleanup behavior: cast snapshots base/INT/counter/upgrade and recipients; finite native beam/audio; one0.25second impact context;3second exact-source kill receipts; match-local death-persistent nondispellable capped20 counter. Dated source/mock evidence below; owner engine timing pending.
Normal creep / elite / boss, immunity / dispel / resistance rules: ordinary living enemy/nonbuilding/nonimmune eligibility with revalidation. Normal creeps/Bosses share authored values; no hero-skill Boss exception. Armor/resistance and actual native targeting/control interactions remain owner engine gates; no Elite spawn.
Current versus target rank curve; free rank / point cost: PENDING.
Shard / Scepter / Blessing / Evolution / Ascended interactions: R Scepter+100damage/325splash, existing manager/inventory/consumed/Blessing detection; generic Lion ultimate amplification/CDR disabled. Shard belongs to E. Normal cast adds20second melee empowerment; Scepter snapshots30seconds/50%cleave versus25%base. AltCast suppresses the new empowerment; fist kill attribution remains OPEN.

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
| Gameplay | PENDING | Dated source/mock review below; actual Dota acceptance pending. |
| Targeting | PENDING | Dated source/mock review below; actual Dota acceptance pending. |
| Ranks | PENDING | Static gates put rank 10 by level 50; owner live test must confirm engine points and ability HUD. |
| VFX | PENDING | Dated source/mock review below; actual Dota acceptance pending. |
| SFX | PENDING | Dated source/mock review below; actual Dota acceptance pending. |
| Animation | PENDING | Dated source/mock review below; actual Dota acceptance pending. |
| Modifiers | PENDING | Dated source/mock review below; actual Dota acceptance pending. |
| Precache | PENDING | Dated source/mock review below; actual Dota acceptance pending. |
| Cleanup | PENDING | Dated source/mock review below; actual Dota acceptance pending. |
| Boss | PENDING | Dated source/mock review below; actual Dota acceptance pending. |
| Upgrades | PENDING | Dated source/mock review below; actual Dota acceptance pending. |
| Localization | PENDING | Dated source/mock review below; actual Dota acceptance pending. |
| Performance | PENDING | Dated source/mock review below; actual Dota acceptance pending. |
| Reconnect | PENDING | Dated source/mock review below; actual Dota acceptance pending. |
| VConsole | PENDING | Dated source/mock review below; actual Dota acceptance pending. |

Change/test record: all five abilities now expose ten KV ranks; the complete 200-ability Lua mock suite passes. This confirms static/mock behavior only; in-match Dota VFX, SFX, rank-up HUD, boss and VConsole acceptance remain PENDING.

## Slot 5: `enfos_lion_demon_soul`

Classification: REPLACE
Native counterpart: `Project-specific Enfos passive; native Lion ability 4 is lion_to_hell_and_back and remains distinct` (installed native hero snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot assignment is project-specific).
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

2026-09-30 global Break metadata audit: Added KV `IsBreakable 1` to `enfos_lion_demon_soul` because its linked Lua passive implementation check `PassivesDisabled()`. Automated content validation now rejects this metadata mismatch. Actual Dota Break behavior remains PENDING.

## 2026-10-03 isolated source checkpoint

Q/W/E/R/D now route to abilities/heroes/lion/{q,w,e,r,d}; six modifiers have explicit owners and a compatibility init. This unit preserves all handler bodies and all KV values except ScriptFile. Independent regression compares against immutable pre-extraction commit3044af6 and cold-loads all modules before the monolith, rejecting duplicate modifier links/class ownership. Focused and full tools/checks.mjs PASS,0 failed checks. Gameplay bugs and authored Boss exceptions identified in the individual ledger remain OPEN; no runtime/visual/audio or full hero source acceptance. Earlier generic PVE-CONVERT dossier labels are superseded by the current evidence-led slot decisions in docs/audit/LION_INDIVIDUAL_REVIEW_2026-10-03.md; native counterparts are not inferred from icons. No foreign code imported; existing shared helpers reused unchanged.

## Q travelling-line source unit,2026-10-03

TUNE. One engine-owned linear projectile now uses width140/speed2800, base engine GetCastRange plus275buffer (production900→1175). Removed the incorrect circular scan/radius500/450offset and Boss-only0.35stun multiplier. Snapshot ten-rank damage/INT and stun at launch; living enemy impact applies saved magical damage and strong-dispellable stun, ordinary immunity/death/friendly/source-invalid gates, post-VFX/sound/damage invalidation guards and lethal-target cleanup. Valid caster death preserves launched impacts. Finite expiry uses game clock, no owned unit/timer/global query. Native flight root is engine-owned; finite hit rootWORLDORIGIN CP0 saved impact. Verified decoded Lion bank has cast Hero_Lion.Impale and target Hero_Lion.ImpaleHitTarget (finite0.641723s variants); existing sound-bank/particle precache reused. Native land sound and vertical launch remain OPEN until motion implementation, not faked.

A top-level AbilityCastRange special read was rejected by the strict all-rank smoke test; replaced with verified CDOTABaseAbility.GetCastRange(origin,target) API instead of inventing a special. Mock API expanded to export actual top-level KV range and game clock, without production fallback. Independent focused fixture FAIL before source repair /PASS after: travel before damage, native width/speed, finite expiry/no replacement/no first-hit deletion, caster INT/level change after launch, two independent casts, ordinary/Boss equal duration and damage, immunity/friendly/dead/removed gates, finiteCP0release, lethal/source-invalid reentrant cleanup, valid caster death, nil endpoint, malformed payload, zero-vector forward fallback, unit direction and current engine range. Updated obsolete instantaneous-circle expectations only in Lion regression. Full tools/checks.mjs PASS,0 failed checks before final skip-trace/current-range refinement; final checks below.

Four localized descriptions and all12 engine mirrors now describe actual travel and ordinary rules; no Boss-shortened tooltip. Bounded/default-off cast/impact/skip/endpoint and stun apply/refresh/remove traces; no diagnostic ConVar registration or per-frame scans. Historical isolation body comparison remains for W/E/R/D; Q now has its own source-backed regression. This is partial Q gameplay/resource acceptance; native vertical motion/damage timing, point/unit spell absorb, exact rendererCP/endcap/audio, status resistance/strong dispel, cold start, dense waves/respawn/reconnect and item range interactions require owner Dota/VConsole. Whole Lion and remaining four skills OPEN. No publication/push.

Final Q travel unit verification after skip tracing/current-range fixture: tools/checks.mjs PASS,0 failed checks. Full Q/native motion/engine acceptance remains OPEN as listed above.


## W Hex source repair, 2026-10-03

TUNE under the preceding native comparison. Added HEXED plus silenced/disarmed/muted (no Break), engine MODEL_CHANGE frog property, native cast animation, strong-dispel metadata and explicit frog model precache. Removed only W authored Boss duration0.8 in Lua/KV/four descriptions; ordinary duration2.5–4.6, speed140 and existing ten-rank mana/cooldown/range remain. Server validates living enemy/nonbuilding/nonimmune, preserves spell absorb, revalidates after absorb/audio and snapshots ranked duration/speed before sound. Applied modifier can outlive removed caster/ability without stale source reads. Client gets saved speed through custom transmitter; no client particle creation. Model property ends with modifier, never manually replaces/restores a cached model.

One finite native Voodoo root is modifier-owned through AddParticle. CP1 follows recipient origin, avoiding uninitialized world-origin attraction; refresh does not create another root. Creation/binding reentrant teardown destroys/releases a not-yet-owned index exactly once; engine handles owned indices on purge/death/expiry. Existing finite Voodoo cast event/bank retained. Default-off bounded apply/cast/absorb/refresh/remove traces, none in getters, no new thinkers/global scans. Resources/API evidence is in the pre-repair decision; [ModDota API](https://docs.moddota.com/lua_server/) and [KV reference](https://moddota.com/abilities/ability-keyvalues) rechecked. No foreign code imported.

Independent fixture FAIL against pre-repair HEAD / PASS repaired: model/state/no-Break, speed snapshot/client transfer, ordinary Boss duration, refresh reuse, 100 getter queries without effects/logs, basic/strong purge flags, enemy/dead/removed/building/immunity/absorb gates, post-absorb/sound invalidation, source removal after apply, double teardown and creation/binding teardown cleanup, client guard, diagnostics on/off lifecycle coverage. All-rank/200-ability and full node tools/checks.mjs PASS,0 failed checks (%TEMP%/enfos-lion-hex-verified.log). Initial inventory stale and accidental encoding changes were repaired; final diff excludes unrelated changes. Existing broad Hex fixture reads saved params because its mock does not invoke modifier OnCreated; focused fixture exercises actual callbacks. E/R/D isolation comparisons retained. This is SOURCE/MOCK evidence, not ENGINE/VFX/SFX PASS.

Owner runtime gates remain PENDING: actual frog/model priority and cosmetic restoration, visible CP1 follow/flies, cast audio/animation, strong dispel vs basic dispel, status resistance, immunity transition, all ten ranks, two Lions, upgrades/cold start/respawn/reconnect/dense waves and VConsole. Native illusion instant-kill comparison remains OPEN; do not invent an execute policy. Whole Lion remains OPEN; next is individual E channel review. Local commit only, no push/publication.


## E continuous-beam resource repair, 2026-10-03

Focused TUNE resource unit; full E PVE-CONVERT decision remains open. Removed per-tick H.effect continuous-emitter recreation. Channel OnCreated owns one beam, binds CP0caster/CP1target origins and starts only the existing0.5interval. OnRefresh clears old recipient's slow on target change, updates target index/reference, replaces the old beam with exactly one new beam and does not create another interval. OnDestroy sets closed before callbacks, destroys/releases its saved particle exactly once, removes this caster's slow from saved recipient (not a recycled entity index), and stops the original cast event. Removed source/recipient handles and reentrant creation/CP0/CP1 teardown clean without subsequent stale target binding; client lifecycle cannot create effects. No global scan/extra thinker/shared helper or other hero changes. Default-off bounded beam create/remove/refresh/teardown trace; no per-tick visual logging. Existing four-second authored damage/INT/restoration formula,0.5tick, all ten ranks and four localized text are unchanged; no new Boss branch.

Independent focused fixture FAIL before repair/PASS after: one beam over100damage ticks with unchanged120base+INT80% results, moving entity bindings, target-change refresh and no interval duplication, explicit old beam cleanup, saved-recipient teardown vs recycled index, double teardown, removed sources, reentrant teardown at all three resource stages, client guard, diagnostic on/off lifecycle and exact E KV equality against1d6a67f. Full node tools/checks.mjs PASS,0 failures (%TEMP%/enfos-lion-drain-resource-checks.log). Existing all-rank gameplay/other-kit tests pass. R/D still byte-compare immutable pre-isolation bodies; E now has its separate focused fixture. This source/mock evidence establishes bounded resource ownership only; it does not certify the E gameplay conversion.

Still OPEN: real native mana transfer vs no-mana-creep policy, engine channel state/EndChannel reentrancy, ability removal, range1100/visibility/invisibility/immunity, status and dispel, tick/partial-duration accounting, target-index reuse during tick (cleanup now uses saved recipient), simultaneous Lions, Shard extras/magic resistance and obsolete generic Support upgrade, slow client transmission/tooltip, animation and cast filter. OWNER_ENGINE/VFX/SFX/VConsole PENDING: actual native CP endpoint orientation/attachments, visible beam and audio cleanup, moving/leaving/dying recipients, cold start, death/respawn/reconnect/dense waves. Do not call E or Lion done. Local commit only.


## E saved-recipient and invalid-source repair, 2026-10-03

Focused TUNE lifecycle unit. Tick now reads the saved actual recipient rather than resolving its recycled entity index. It validates server/closed state, living caster, valid ability and living recipient before special reads/damage. After damage and mana callbacks it rechecks source/recipient and closure before further entity use. Legitimate lethal damage keeps the current authored mana reward before ending; removal or closed modifier aborts without mana side effect. Abort calls verified EndChannel only with valid caster/ability, then destroys a still-open channel modifier; no fallback special read on removed ability. Cast/finish now have explicit server/source guards. Authored mana/damage formula and every KV rank remain unchanged; no Boss exception or new mana conversion. Default-off bounded reasoned abort and authored tick values added to existing resource traces; names explicitly distinguish authored amounts from measured resource changes.

Focused fixture reproduces recycled-index misdelivery against pre-repair8f4a0fb (FAIL) and passes corrected implementation. Added11 invalidation cases: removed ability/caster, dead caster, removed/dead recipient, source/target removal during damage, callback closure, removal during mana and legitimate lethal damage. Each stops further intervals, closes particle once, and verifies mana is withheld or retained according to the stated policy. Existing100tick/no-effect-growth, refresh/client/resource tests pass. Updated the legacy manually-created dead-target fixture with its actual saved handle, rather than add a production entity-index fallback. Strict all200-modifier fixture lacked verified EndChannel on its synthetic Lion owner; provided that engine API solely for this ability's isolated mock. Full node tools/checks.mjs PASS,0 failures (%TEMP%/enfos-lion-drain-handles-verified.log). No fake engine/source acceptance or external code import.

OPEN/PENDING: recast session and engine callback ownership (including reentrant new cast), actual channel-state gating, native leash/visibility/invisibility/immunity and dispel, damage/real-mana/no-mana policy, partial final tick, source-specific slow/client values and upgrades. Owner Dota/VConsole remains required for particle/audio/animation/interrupt/death/respawn/reconnect and exact native rules. E/Lion not complete. Local commit only; contributor Lich changes excluded.


## R ordinary Boss damage unit, 2026-10-03

Removed R's authored is_boss/maxHP12% clamp and obsolete boss_damage_cap_pct KV, keeping ordinary magical base+INT250%+bounded kill-stack damage on all recipients. No Boss stats/AI/defense, other heroes, shared damage helpers, always-splash radius or existing capped20stack behavior changed. Four descriptions and12engine mirrors now use the KV INT coefficient and explicitly describe ordinary Boss damage/immunity/resistance rules. Existing native icon, finite event/particle/precache and generic upgrade dependency unchanged; actual resource/animation acceptance remains pending, not established by this narrow unit.

Independent fixture FAIL pre-repair47ad670 /PASS repaired for all10ranks ×4stack values(0/3/20/25), normal vs flagged Boss recipients with varied maxHP, same relevant mocked defense, ordinary lethal-kill stack cap and spell absorb. Existing broad regression now expects1050 instead of120 from the identical formula and drops obsolete cap fixture values. Full node tools/checks.mjs PASS,0 failed checks (%TEMP%/enfos-lion-finger-ordinary-checks.log). These mocks verify submitted raw damage; actual armor/resistance/immunity remains engine-owned and must be verified in Dota. D remains byte-preserved isolation comparison; R has dedicated focused tests.

Whole R OPEN: native0.25delay/3sgrace, alternative punch, Scepter-only splash vs current authored always-splash, exact VFX endpoints/ownership/animation, valid-source/post-damage recipient guards, counter refresh/Break/death/illusion/client semantics, trace completeness and upgrades. OWNER_ENGINE/VFX/SFX/VConsole PENDING including ordinary/Boss different resistance, all ranks, kill ownership, dense waves and reconnect. No full hero certification, local commit only.


## D authored passive source unit, 2026-10-03

REPLACE disposition for the project's numeric fifth passive, distinct from native innate. Preserved ten-rank150–600cast range/2–20spell amp, stable ID, icon, KV and free-rank/progression ownership. Readonly live getters now return0when closed, missing/removed parent or ability, rank0, Break or illusion; otherwise they read current KV rank on server/client without a transmitter or thinker. Explicit visible, nondispellable, death-persistent intrinsic with lion_mana_drain icon and engine OnTooltip/OnTooltip2 current values. Lifecycle applies/refresh/removal have bounded default-off traces, no query spam. Valid dead hero retains numeric intrinsic until normal engine respawn; no proc/resource side effect or duplicate grant is introduced. Four ability descriptions and modifier name/descriptions plus12engine mirrors added. Passive cast/travel/impact/particles/audio/gesture are N/A for this stat-only design; no invented emitter/sound/model. Icon/HUD and native intrinsic death/respawn/reconnect are OWNER_ENGINE PENDING.

Independent fixture FAIL pre-repair7093148 at rank0 bonus/PASS repaired. Covers all10ranks on server and client, live refresh, rank0, Break, illusion, removed parent/ability, visible texture/purge/death flags, tooltip-value equality, closed/double teardown, default-off/enabled lifecycle traces and100getter queries without logging. Authored D KV equality against immutable3044af6 retained; original byte-body comparison retired after individual source repair, all five now have focused fixtures and unique class/six-route cold-load checks. Full node tools/checks.mjs PASS,0 failed checks (%TEMP%/enfos-lion-passive-checks.log). No new asset/code imports. MCP API confirms GetSpecialValueFor/PassivesDisabled/OnTooltip/OnTooltip2 available both and TOOLTIP/TOOLTIP2 enum names; [primary ModDota API](https://docs.moddota.com/lua_server/) consulted.

D source/mock stat and presentation contract PASS; actual rankfreepoint/HUDbuff placeholders/Break/illusion/purge/respawn/reconnect require owner Dota/VConsole. Generic Support Shard heal description/manager still OPEN for Lion-specific upgrade work, not certified native behavior. Whole Lion remains OPEN because Q motion/targeted spell block and renderer, E mana/channel/leash/upgrade, R native timing/stack/source/VFX/upgrade and engine gates remain. Continue individual Lion review, no next-hero closure. Local commit only.


## R finite burst source unit, 2026-10-03

TUNE. The installed finite Finger root now starts at caster and explicitly binds CP0 to caster / CP1 to recipient, releasing its index once. Reentrant invalidation during creation/control binding destroys and releases the root once. Native ACT_DOTA_CAST_ABILITY_4 added to this slot only. Server cast validates living enemy, nonbuilding, ordinary immunity rules and rechecks after absorb/audio/resource callbacks. Damage/radius/stack cap are snapshotted before callbacks; splash rejects invalid recipients and stops on invalid/dead source. Removed recipients and counters are not queried after damage. Existing authored instant splash, ten-rank damage, ordinary Boss formulas and capped instant-kill stacks remain unchanged. Default-off bounded cast/hit/kill traces added; no timer, thinker, unit or global scan added.

Independent lion_finger_targets fixture PASS for all ten ranks and four stack values on ordinary/Boss recipients, CP source/destination, main/splash targeting, absorbed casts, source/recipient/counter invalidation, creation/control-point cleanup, client guards, stack caps and trace gating. Pre-repair HEAD fails the endpoint assertion; repaired source passes. Full tools/checks.mjs PASS, zero failed checks in %TEMP%/enfos-lion-finger-burst-checks.log; subsequent added main-target invalidation cases also pass focused fixture. Decoded native finite emitter and API evidence is recorded in the preceding decision. These are source/mock results, not renderer or engine certification.

OWNER_ENGINE/VFX/SFX/animation/resistance/absorb/reflect/cold-start/reconnect PENDING. Origin bindings are explicit safe fallback; native attachment/cosmetic CP parity is not established. Native delay/grace, Scepter splash/alternative punch, counter lifecycle/client presentation and Lion-specific upgrades remain OPEN. Whole Lion remains OPEN; local commit only, unrelated contributor changes excluded.


## R bounded counter source/presentation unit, 2026-10-03

TUNE. Readonly counter getter now validates modifier, owner, ability and learned rank before stack/value queries, returning zero for closed/removed/unlearned source. Capped live values drive spell amplification and OnTooltip/OnTooltip2 extra Finger damage / amplification on both server and client. Explicit native icon and four localized descriptions plus twelve engine mirrors added. Lifecycle traces are default-off and bounded, no getter logs or extra timers/scans/resources, no stack mutation/reset during refresh. Authored cap20/damage40/amp1.5 and cast credit unchanged. Break, illusion copying, death persistence and purge policy were not guessed or overridden; these remain separate review gates.

Independent fixture FAIL pre-repair416a46d at rank0 amplification / PASS corrected for ten ranks, negative/overflow stacks, valid/removed modifier-owner-ability, rank0, client, refresh/closure, tooltip values, trace gating and100readonly getter iterations. Existing manually-built broad Lion R fixture omitted engine GetLevel; supplied learned rank1 only in that fixture, not a production fallback or shared mock change. Full tools/checks.mjs PASS, zero failed checks (%TEMP%/enfos-lion-counter-verified.log). Engine buff icon, dynamic placeholder rendering, intrinsic death/respawn/reconnect/illusion/Break/purge and real amplification remain OWNER_ENGINE PENDING. No native kill-grace or upgrade parity claim. Whole Lion OPEN. Local commit only, contributor Lich files excluded.


## E ordinary target and callback source unit, 2026-10-03

TUNE. Cast now rejects invalid/dead/friendly/building/magic-immune/debuff-immune recipients and revalidates source and recipient after spell absorb, sound and channel-modifier creation before further entity use. Channel duration must come from valid production KV rather than an invented fallback. Interval applies the same ordinary target rules and rechecks team/immunity changes after damage and mana callbacks. Existing authored damage/restoration math and legitimate lethal-hit reward remain; no Boss-only branch added. Four tooltips and12engine mirrors state these target/end conditions. No source rank/upgrade/visibility/leash/session policy silently introduced.

Independent cast fixture FAIL pre-repair10e59bf for friendly target / PASS corrected: ordinary two-modifier cast, seven rejection cases, nine callback invalidation cases and client no-op. Expanded saved-recipient/visual fixture FAIL pre-repair for friendly target during channel / PASS corrected, including team conversion during damage/mana and immunity/building cases; resource teardown stays once, ticks do not create new emitters. Broad manual interruption fixture lacked real special values; only its Lion ability now reads existing production KV through the established special helper (not a runtime fallback or changed Pudge/Shaman fixture). Full tools/checks.mjs PASS,0 failed checks (%TEMP%/enfos-lion-drain-targets-verified.log). Production E KV and damage scaling unchanged. No external code imported.

OWNER_ENGINE target acquisition/control/immunity transitions, native attachment/audio cleanup, channel duration/tick timing, resistance and modifier cleanup PENDING. Native FOW/invis/leash, actual mana transfer/no-mana conversion, individual Shard, channel session/reentrant refresh/old finish remain OPEN. OnChannelFinish still has no engine session argument and name-based cleanup; this focused targeting repair does not certify recast. Whole Lion OPEN. Local commit only, contributor Lich changes excluded.


## E reentrant modifier revision source unit, 2026-10-03

TUNE. Channel modifier increments a local revision on creation/refresh. StartVisual snapshots before clearing the old root and checks revision after every create/control callback; stale outer creation destroys/releases its own unowned emitter rather than overwriting the fresh beam. OnRefresh checks revision after old-target slow removal and visual setup. Interval checks revision after damage/mana; stale damage does not reward mana or abort the refreshed target. Abort checks revision after EndChannel before explicit fallback destruction. No extra interval, timer, scan, entity, stack, numerical or KV change. Existing trace gating/locales/native resources stay unchanged. This local modifier revision is deliberately not asserted to be an engine cast-session identifier.

Independent nested-refresh fixture FAIL pre-repair184685d at beam ownership / PASS corrected. Covers particle creation/CP0/CP1 and destruction/release callbacks plus damage/mana/EndChannel refresh; fresh target remains active and receives the next tick, stale emitter and current emitter each destroy/release once. Corrected test particle factory snapshots its returned ID before nested callbacks, matching stable engine handle ownership rather than returning its mutable global allocation count. Existing source/recipient invalidation, client,100tick no-emitter-growth, recycled-index and ordinary-target cases still pass. Full tools/checks.mjs PASS,0 failed checks (%TEMP%/enfos-lion-drain-revision-checks.log).

OWNER_ENGINE reentrant/cold-start/interrupt/death/respawn/reconnect beam and audio PENDING. Full modifier replacement/name-based OnChannelFinish and slow/audio teardown identity remain OPEN, as do native channel-state, visibility/leash, mana conversion/timing and Lion Shard/Scepter work. Gameplay/VFX/SFX acceptance is not promoted by this ownership mock. Whole Lion OPEN. Local commit only; uncommitted contributor Lich changes preserved.


## E teardown ordering and saved-recipient source unit, 2026-10-03

TUNE. OnDestroy captures the saved actual recipient and caster, stops the old ManaDrain event and removes old same-caster slow before clearing the old owned particle. Fresh channels started during slow/particle destroy/release callbacks now retain their sound, slow and beam. Removed the unresolved target_idx fallback; cleanup never resolves a recycled index into a previously unowned recipient. Closed/double cleanup and invalid-caster cases remain guarded. No numerical/KV/upgrade/localization/interval changes or new APIs/resources.

Focused fixture FAIL pre-repairaad5977 for fresh sound/slow after particle destruction / PASS repaired. Three teardown reentry cases (destroy, release, slow cleanup) create a distinct fresh modifier instance and assert old emitter closes once while new emitter remains alive; separate initially unresolved/recycled-index case asserts unrelated recipient receives no slow cleanup. Existing nested-refresh/resource/invalidation/client/100tick/ordinary target cases pass. Full tools/checks.mjs PASS,0 failed checks (%TEMP%/enfos-lion-drain-teardown-checks.log). Native sound/particle evidence and verified API signatures remain those recorded in preceding resource units; no new foreign imports.

Source/mock cleanup sequencing PASS only. OWNER_ENGINE sound start/fade, complete channel replacement, native finish callback identity and name-based slow ownership still PENDING/OPEN; this ordering does not establish general cast-session isolation. Native visibility/leash/mana/timing/Shard/Scepter remain OPEN. Whole Lion OPEN. Local commit only, contributor Lich changes excluded.


## E base leash/channel-state source unit, 2026-10-03

TUNE. Added installed native base break_distance1100 and ACT_DOTA_CAST_ABILITY_3 to E KV. Server interval requires real IsChanneling before damage, reads configured positive leash and compares planar squared distance, aborting before out-of-range damage/mana. Stopped engine channel destroys only this modifier without an extra EndChannel request; channel-state rechecks after damage/mana prevent old continuation. Existing4second duration/0.5tick/authored damage and restoration unchanged, no Boss exception, additional thinker or global scan. Four descriptions and12engine mirrors describe the normal channel limit. Shared upgrade logic untouched.

Focused fixture FAIL pre-repairf5464da above1100 / PASS repaired:1099,1100,1100.01,1300 on ordinary/Boss-equivalent targets, ignores height for planar distance, moves out of leash, missing configuration, inactive channel and channel stopping during damage/mana. All ten production mana-per-second ranks assert exact authored damage and restoration with INT100; existing resource/reentrant/target/client tests pass. Strict200-modifier synthetic Lion owner now explicitly reports IsChanneling=false because it is not an actual engine channel; meaningful live-channel cases reside in dedicated fixture. Historical E KV comparison allows exactly break_distance/ACT3 additions and still checks all other fields/ranks. Derived Lion inventory refreshed; contributor Lich entries excluded from commit. Full tools/checks.mjs PASS,0 failed checks (%TEMP%/enfos-lion-drain-leash-verified.log).

OWNER_ENGINE channel state at first tick, exact interruption/leash/animation/audio/respawn/reconnect PENDING. Shard+200 native leash is not implemented or certified here: MCP does not expose guessed NPC HasShard method, existing project manager needs Lion native-permanent-buff compatibility review. Shard's extra targets/resistance, native visibility/invis, mana conversion/timing and Scepter still OPEN. Whole Lion OPEN; local commit only.


## E slow modifier source/presentation unit, 2026-10-03

TUNE. E KV and slow modifier now explicitly use native nondispellable behavior (basic and strong). Visible native lion_mana_drain texture and four localized modifier descriptions expose the live engine movement percentage. Getter checks valid modifier/ability, learned rank and ordinary living enemy target rules on server/client, returning0for closed/unlearned/removed/dead/friendly/building/immune recipients or invalid caster. No server-only channel query, transmitter, emitter or sound added to getter; channel remains resource owner. Created/refreshed/removed traces are default-off and bounded, no getter spam. Existing slow35, numerical/rank/KV values and engine death defaults preserved; only dispel metadata changed.

Independent slow fixture FAIL pre-repair1100c2c at rank0 / PASS repaired for all10ranks on server/client, changed live special42, ten invalidity/target cases, visibility/icon/purge flags, closure/double teardown,100readonly queries and four dynamic descriptions. Broad manually-created Lion E ability now supplies learned rank1 only in its slow-value fixture; no shared mock or production fallback changed. Historical E KV fixture allows exactly nondispellable metadata plus previous leash/ACT3 changes. Full tools/checks.mjs PASS,0 failed checks (%TEMP%/enfos-lion-slow-checks.log). No new asset or foreign code imports.

OWNER_ENGINE icon/dynamic modifier placeholder, actual slow/normal-Boss immunity/dispel/status resistance, death/refresh/reconnect and audio/beam remain PENDING. Native visibility, Shard/Scepter, actual mana conversion/tick timing and full engine finish-session ownership remain OPEN. Whole Lion OPEN. Local commit only; contributor Lich changes excluded.


## Lion native Shard acquisition source unit, 2026-10-03

TUNE. Existing authoritative AghanimManager native-permanent-buff recognition now includes only Lion alongside previously reviewed Lich/Venge/Jakiro. Native consumed Shard remains recognized after item leaves inventory; legacy consumed aliases/inventory detection and invalid-owner guard unchanged. No native NPC HasShard API invented, new manager/timer/scan, or changes to unreviewed native-buff policy. Current generic Support heal/Scepter behavior remains explicitly interim OPEN; this prerequisite does not implement additional Drain targets/resistance/leash bonus or replace generic upgrades. Existing four-locale descriptions retain actual current behavior.

Independent fixture FAIL pre-repair39920b3 at consumed native Lion recognition / PASS repaired. Covers native+two legacy buff forms, inventory acquisition/loss, invalid owner, repeated100acquisition/loss reconciles without duplicate application, reacquisition, preservation of three reviewed heroes and exclusion of Lina/Sven/Puck. Full tools/checks.mjs PASS,0 failed checks (%TEMP%/enfos-lion-shard-detection-checks.log), including shared Jakiro/Venge/Lich upgrade regressions. Installed native-buff token/resource evidence recorded in preceding decision; no new assets/code imports.

OWNER_ENGINE actual purchase/consumption/buff identity/refresh/reconnect PENDING. Lion-specific Shard and Scepter mechanics remain OPEN; detection is not full upgrade acceptance. Whole Lion OPEN. Local commit only, contributor Lich work preserved.


## E Shard channel defense/leash source unit, 2026-10-03

TUNE partial native upgrade. Explicit lion/upgrades.lua delegates acquisition to existing manager with lazy module loading; no duplicate manager or guessed HasShard engine method. E HasShardUpgrade metadata and data-driven +200break distance/+60magic resistance added. Channel modifier exposes debuff immunity only (verified enum, not MAGIC_IMMUNE) and live magic-resistance bonus for learned valid living Shard owner; server also requires active engine channel. Client never calls server-only IsChanneling and relies on replicated modifier removal/acquisition/rank. Closed/invalid/dead/unlearned source returns no defense. Current channel modifier gains native ManaDrain icon and nondispellable flags, four current-value descriptions plus E upgrade descriptions/12engine mirrors. No new particle/sound/timer/unit/query scan. Ordinary base1100 becomes1300live with Shard; acquisition/loss reads authoritative state rather than cached permanent power.

Independent new fixture FAIL pre-repair9a351ab (callbacks absent) / PASS for all ten ranks on server/client, acquisition/loss,0rank, closed/removed modifier/ability/caster, dead caster and inactive channel. Checks only debuff-immunity state key, declared resistance property/60value, texture/dispel flags, native permanent acquisition and client API boundary. Expanded existing damage/resource fixture verifies ordinary/Boss-equivalent normal/Shard leash at1099/1100/1100.01/1300/1300.01 (20cases); modified synthetic ability now inherits actual Lion callback instead of copied method. Full tools/checks.mjs PASS,0 failed checks (%TEMP%/enfos-lion-shard-defense-checks.log); later20boundary expansion also focused PASS. Cold-load isolation still has six unique modifier owners. Derived Lion KV/callback inventory updated only. No foreign code/assets imported.

PARTIAL SHARD source only: two additional Drain recipients, generic Support-heal replacement and full four-language coherent upgrade description still feasible OPEN. Current descriptions state implemented defense/leash without claiming extra beams. OWNER_ENGINE resistance stacking/state propagation/first tick/acquire-loss/interrupt/purge/death/reconnect/renderer/sound PENDING. Full finish-session ownership and native mana/visibility remain OPEN; Scepter OPEN. Whole Lion OPEN. Local commit only; contributor Lich changes excluded.


## E native visibility source unit, 2026-10-03

TUNE. Installed native Mana Drain FOW_VISIBLE|NO_INVIS flags now accompany a server-only visible-enemy predicate. Cast and channel ticks reject unseen/invisible targets; checks after absorb, audio, modifier, damage and mana callbacks prevent stale continuation. A valid lethal hit still earns its authored mana restoration. Client slow getters do not invoke server-only FoW APIs. Four localized descriptions and twelve engine mirrors state the visibility requirement. Damage, rank values, single-beam ownership and partial Shard defense/leash remain unchanged; no new timer, scan or Boss-specific branch.

Independent cast/tick fixtures fail against pre-repair89e9dbf on hidden targets and pass repaired. Cases cover invisible/hidden casts, visibility loss before tick and during damage/mana callbacks, cleanup and prevention of later ticks. Focused fixtures rerun PASS; full tools/checks.mjs PASS,0 failed checks (%TEMP%/enfos-lion-visibility-checks.log). General mock units supply the verified engine APIs with visible/noninvisible defaults; they do not establish engine visibility acceptance.

OWNER_ENGINE actual FoW/reveal/invisibility/channel interruption and beam/audio removal remain PENDING. Additional Shard targets, native mana conversion/timing, full finish-session ownership and Scepter remain OPEN. Whole Lion OPEN. Contributor Lich changes excluded; local commit only.


## E Shard additional recipients source unit, 2026-10-03

TUNE missing native Shard recipient count with explicit authored geometry as decided in75f38d5, not a claim of closed C++ parity. E passes data-driven shard_bonus_targets2 to its isolated drain_extras helper. At channel creation/refresh, one server FindUnitsInRadius query selects at most two distinct nearest eligible enemies inside the caster's configured leash, excluding the primary. No retargeting/per-tick scan. Saved handles receive identical authored rank damage/restoration/slow and their own continuous native beam. The original channel interval owns all three recipients; no new modifier class/thinker/timer/unit or resource path. Shard loss closes extras on the next tick; reacquisition applies next cast. An extra target's death, removal, allegiance/immunity/visibility change or leash loss closes only its link; primary loss ends the original channel. Ordinary/Boss recipients share formulas and eligibility.

Close disowns entries before callbacks, clears all old slow handles before deferred particle teardown and destroys/releases every beam exactly once. Slow ownership markers plus current-entry checks preserve a refreshed handle retained by a newer channel. Primary sound/slow cleanup precedes extra-particle callbacks so a fresh channel's audio survives old teardown. Revision guards stop further recipient damage/mana after nested refresh, closure, source removal or engine-channel stop. Four Shard descriptions and12mirrors explicitly describe nearest selection, unchanged per-recipient formula, no replacements and acquisition/loss policy. Existing native bank/event reused once per channel; actual renderer/audio remains pending.

Dedicated integrated fixture FAIL against75f38d5 (missing extras), PASS repaired: no-Shard baseline, duplicate/invalid candidates, bounded three beams and one interval over100ticks with no additional search, all ten rank formulas on ordinary/Boss labels, fifteen target/callback failure modes, acquisition/loss, changed saved primary, refresh and client gates. Nested create/CP/damage/mana recasts, two sources with overlapping recipients, engine-like reused slow handle and fresh-channel creation during old teardown covered. Reused-handle and fresh-audio/slow cases each failed during implementation and pass after ownership/order repair. Historical E fixture permits exactly the added native target-count field; other authored KV/ranks remain equal. Synthetic broad casts receive the verified IsChanneling=false API because they have no real channel; dedicated fixture exercises active channels. Full tools/checks.mjs PASS,0 failed checks (%TEMP%/enfos-lion-shard-targets-checks.log). No imported foreign code.

OWNER_ENGINE actual initial channel state, nearest-target selection in dense lanes, simultaneous-source modifier engine merging, repeated casts/interrupts/death/reconnect, visibility/immunity/leash, per-target native beam/audio and all-rank mana stacking PENDING. Native mana transfer/no-mana creep conversion, final partial ticks, exact engine finish-session identity, generic Support-heal replacement and Lion Scepter remain OPEN. This unit implements extra recipients but does not certify full Lion Shard or whole Lion. Only isolated local commit; contributor Lich work preserved.


## Lion Shard coherent role-bonus replacement, 2026-10-03

TUNE. Lion-specific Mana Drain Shard now replaces the former generic Support outgoing-healing25% bonus. Existing shared role modifier remains for acquisition/state compatibility but is hidden and returns zero healing for Lion only. D no longer advertises HasShardUpgrade; four obsolete healing descriptions/12engine mirrors removed. E retains native upgrade metadata and its implemented defense/leash/extra-target descriptions. Passive rank values, stats, Break/illusion policy and Scepter are unchanged; no new timer/modifier/resource/trace getter logging. Current installed native Lion KV reconfirmed Shard belongs to Mana Drain rather than Demon Soul/healing.

New independent manager fixture FAIL against3c0aa0e at Lion healing25% / PASS corrected. Verifies server/client Lion zero healing/hidden marker, other Support healing25%, four reviewed healing exceptions, unchanged Tank/Fighter/Carry/Mage stat values, permanent/nondispellable/death-persistent role marker and100poll acquisition/loss/reacquisition without duplicates. Existing consumed-Shard detection, channel defense/extra recipient/resource/rank and isolated cold-load regressions PASS. D historical comparison permits exactly removal of obsolete Shard metadata and retains all other KV; content contract routes Lion Shard to E. Full tools/checks.mjs PASS,0 failed checks (%TEMP%/enfos-lion-shard-role-checks.log). No external code/assets imported.

SOURCE replacement implemented; OWNER_ENGINE native Shard purchase, upgrade tooltips/marker visibility, defense/extra beams/slow/mana, repeated casts and reconnect PENDING. Mana transfer/no-mana creep policy, timing/final partial ticks, exact engine finish-session ownership and Scepter still OPEN. Whole Lion OPEN. Local commit only; contributor Lich work excluded.


## R Scepter core damage/splash source unit, 2026-10-03

TUNE native-first core upgrade. Finger now hits its explicit primary without Scepter; no base radius scan. Scepter adds configured100damage and325splash, as verified in installed Lion KV. A live server/client GetAOERadius exposes current upgrade through existing manager, with native/inventory/consumed/Ascended Blessing acquisition retained. Cast snapshots upgrade/damage/radius before sound/particle/damage callbacks. Upgraded recipient list always includes primary once and deduplicates nearby handles; ordinary eligibility/armor/resistance/immunity applies including Bosses. Ten-rank base damage, INT250%, bounded authored kill stacks and finite main beam remain unchanged. AOE metadata/current descriptions in four locales/12mirrors updated.

Lion's generic ultimate40%damage/25%CDR now return0 and generic Scepter marker is hidden; acquisition manager lifecycle remains unchanged. No unverified native cooldown reduction invented. Existing other-hero bonuses preserved, including Shadow Shaman's current0amp/25CDR asymmetry; its fixture expectation was corrected to actual baseline rather than altering unrelated gameplay. No new resource/timer/global scan or Boss compensation. Native alternative-punch/delay/grace remain explicitly OPEN.

Independent shared-manager fixture FAIL against6eb287b at generic Lion40%amp/PASS repaired. Covers server/client, six reviewed exceptions, four unreviewed generic recipients, native/inventory/four consumed-Blessing forms, removed source,100poll idempotence and acquisition/loss/reacquisition. Expanded actual R fixture covers all10ranks/four stack counts with Scepter normal/Boss damage, base no-query single-target behavior across10ranks/two target types/four stacks, omitted/duplicated primary query results and Scepter loss during audio callback preserving cast snapshot. Previous immunity/absorb/source/counter invalidation/finite-CP/trace cases PASS. Focused base/upgrade expansion rerun PASS after full suite; full tools/checks.mjs PASS,0 failures (%TEMP%/enfos-lion-scepter-core-checks.log). Existing mixed Lua regression updates only its Lion R section with explicit Scepter and100bonus; contributor Lich tail excluded. No imported code/assets.

OWNER_ENGINE base/upgrade targeting cursor, purchase/consumption/Blessing, actual area damage/resistance, native beam/audio, repeated kills and all-rank HUD PENDING. Native0.25impact delay/3second kill grace/alternative-punch behavior, E mana policy/timing and exact finish-session identity remain feasible OPEN. This core upgrade is not whole-native-R or whole-Lion acceptance. Local commit only; no push/publication.


## R delayed impact verification, 2026-10-03

TUNE: installed damage_delay 0.25 now schedules one unique finite GameModeEntity context per cast. No immediate damage; cast-time damage, upgrade and recipient snapshots remain independent across overlapping casts. Callback checks current source/recipient validity and ordinary eligibility. Completion is owned before damage callbacks, preventing duplicate/reentrant impact. Pause returns 0.03 without completing; invalid ability or dead/removed caster terminates. Current living-source requirement and cast-time area selection are retained authored policies, not proven native C++ parity. Finite native beam/audio still starts at cast; engine audiovisual synchronization remains pending.

Independent queued fixture FAIL against HEAD 80aa2df at no-immediate-damage assertion / PASS corrected. Covers exact 0.25 scheduling, two unique overlapping snapshots, repeated callbacks, death/removal/team/immunity/building changes, primary removal with surviving saved Scepter recipients, source/ability loss and pause/resume. Existing ten-rank normal/Boss/stack/absorb/resource/counter regressions PASS. Broad smoke context execution establishes API compatibility only; timing evidence comes from the queued fixture. Four descriptions/12 engine mirrors include delay. Full node tools/checks.mjs PASS, 0 failures (TEMP/enfos-lion-impact-delay-checks.log). API evidence: MCP CBaseEntity:SetContextThink and DoUniqueString, cross-checked https://docs.moddota.com/lua_server/; existing Jakiro Q scheduling pattern reused. No imported external implementation or assets, no new global scan/unit/thinker, no Boss exception.

OWNER DOTA/VCONSOLE: delay during live cast/pause, renderer/audio timing, overlapping casts, source death, Shard/Scepter and rank HUD remain PENDING OWNER TEST. Native 3-second kill grace, alternative punch, E native mana/timing and exact channel finish ownership remain OPEN; whole Lion is not complete. Isolated local commit only; contributor Lich work excluded, no push or publication.


## R grace attribution source verification, 2026-10-03

PVE-CONVERT: native grace_period3 now applies to existing eligible Enfos enemy-unit kills, including ordinary Boss recipients. Delayed impact registers one original-handle receipt before ApplyDamage, then OnDeath and post-damage fallback consume the same receipt. An ally finishing within the authored inclusive three-second impact window credits Lion once; repeat hits refresh one window, repeated/reentrant events do not multiply rewards. Receipt captures original ability and teams; replaced/unlearned/removed source, invalid or allied/building recipient cannot credit. No entity-index re-resolution, new target stats/debuff or Boss exception. Active casts still require living source before impact; an already affected enemy can credit a valid dead Lion. Counter now explicitly nondispellable/death-persistent; stacks remain match-only and cap20 with unchanged +40 damage/+1.5% amplification.

One finite expiry context per active counter scans only that counter's recent claims at expiry, using pause-frozen GetGameTime. Map plus context-token identity guards old lifecycle/completed callbacks against new state. No per-target thinker or per-frame/global unit scan. Expired/removed targets release references; idle callback terminates. Four descriptions and counter tooltips/12 engine mirrors reflect the window/persistence. Existing six Lion modifiers, isolated entrypoints and native finite beam/audio remain unchanged. Source classification derives from installed Lion KV grace_period3 and abilities_english Note1 (line1357), not a foreign implementation. MCP MODIFIER_EVENT_ON_DEATH/OnDeath, GetGameTime, IsPurgable and RemoveOnDeath API signatures cross-checked with https://docs.moddota.com/lua_server/ on2026-10-03.

Independent queued fixture FAIL against717f42b (affected later deaths not observed) / PASS repaired. Tests all10ranks, normal/Boss, immediate/2.999/exact3/3.0001 boundaries, ally kills, synchronous death plus fallback, duplicate/reentrant deaths, refresh with old deadlines, pause clock, idle reference cleanup/rearm, stale completed and recreated-lifecycle callbacks, invalid/replaced/unlearned sources, client events, caster death, cap20, distinct counters, absorbed/non-hit deaths and duplicate Scepter recipients. Existing delayed-target/snapshot/counter/isolation and full node tools/checks.mjs PASS,0 failed checks (TEMP/enfos-lion-grace-checks.log). Broad smoke is compatibility evidence only. Contributor Lich E/source/docs/tests excluded from staging.

OWNER RUNTIME/ENGINE/VISUAL-AUDIO: PENDING OWNER TEST for actual death-event ordering, ally/Boss kill credit, pause, source death/respawn, multi-Lion ownership, live tooltips, Shard/Scepter acquisition and sound/particle synchronization. Exact native C++ grace refresh/boundary semantics unavailable; inclusive impact-based receipts are an explicit authored PvE reconstruction. Native alternative punch, E mana/timing/session ownership and counter Break/illusion policy remain OPEN; whole Lion remains OPEN. Isolated local commit only, no push/Workshop/deploy.


## W ordinary illusion destruction verification, 2026-10-03

TUNE native-first: ordinary enemy illusions now use Kill(this ability, Lion) after ordinary source/target/team/building/immunity/absorb/learned-duration gates. Strong illusions and real units retain ranked frog Hex; no HP execute or Boss-name branch. Native finite Voodoo root binds CP1 and releases once before kill; source/target/team/immunity/strong-trait changes during create/bind cancel destruction and destroy/release that root. Existing ordinary Hex modifier/transmitter/model/strong dispel and engine-owned particle cleanup unchanged. Uses already precached particle/sound, no new asset, modifier, timer or global query; six-class isolation remains intact. Four ability descriptions/12 engine mirrors explain ordinary versus strong illusions.

Independent actual-W fixture FAIL against f89af1e (ordinary illusion transformed rather than destroyed) / PASS corrected. Covers ordinary/strong/real recipients across all10rank durations and normal/Boss names, low-health real unit, zero-duration gate, immunity/building/absorb/removed target, creation/binding invalidation including newly strong target, attribution API, kill-callback handle removal, client rejection, finite CP1/release and debug-gated destruction trace. Existing modifier getter polling/transmitter/refresh/cleanup cases retained. Full node tools/checks.mjs PASS,0 failed checks (TEMP/enfos-lion-hex-illusions-checks.log). No imported foreign implementation/assets; native installed localization/API/decoded effect references recorded in pre-repair decision.

OWNER ENGINE/VFX/SFX PENDING: actual illusion death attribution, strong Venge illusion interaction, native immunity/absorb, cast/instant burst/audio, cosmetic model priority, dispel/status resistance and death/reconnect. Static resource decoding/mocks are not engine acceptance. W source illusion defect repaired; whole Lion still OPEN, including R alternative punch, E mana/timing/finish ownership and remaining native parity decisions. Owner-working list and next priority Puck are recorded in active goal steering; no publication until Lion checkpoint is ready.


## E learned-source authority verification, 2026-10-03

TUNE: Lion E now requires a positive learned rank and exact ability-caster/channel-parent ownership before cast, after absorb/sound/modifier callbacks, during continuous beam creation/binding, before primary ticks and after damage/mana callbacks. Shard defense and recipient slow use the same authority predicate on server/client; no server-only channel query added to client presentation. Extra-recipient current predicate now rejects unlearned/borrowed sources before further damage/mana/resource operations. Abort only invokes EndChannel on an ability belonging to the original channel parent; another caster's channel cannot be ended by stale modifier cleanup.

Independent primary fixture FAIL against f3f4014 (rank0 interval remains active and deals INT conversion) / PASS repaired. Cases include source rank/owner loss before tick, during primary damage/mana, rank loss during cast absorb/audio/modifier and beam creation/CP0/CP1 callbacks, borrowed-source client/server defense/slow and rank/owner loss before primary and extra damage/mana. No remaining extra-recipient reward after loss; next primary interval tears down old resources. Existing ten-rank rate, main/extra target identity, visual refresh/teardown, leash/visibility/immunity and capped-two-recipient cases preserved. Two manual broad smoke fixtures supplied verified GetLevel/GetCaster APIs rather than weakening production guards. Full node tools/checks.mjs PASS,0 failed checks (TEMP/enfos-lion-drain-source-checks.log). Six modifier owners and explicit E/extras dependency unchanged; no new resource, timer, global query, Boss exception or shared helper change. Four-language numbers/visible behavior descriptions remain valid and unchanged.

OWNER ENGINE/VFX/SFX PENDING: actual unlearn/ability removal/channel stop/Shard purchase and reconnect, continuous beam/audio cleanup and native channel event ordering. Native mana transfer/no-mana creep design, final partial ticks/current authored0.5 timing and exact natural OnChannelFinish session identity remain OPEN; this authority fix is not whole E or whole Lion acceptance. R alternative punch and Q motion/native targeting still have feasible review work. Contributor Lich edits excluded; isolated local commit only. Authorized GitHub/Workshop checkpoint remains after Lion completion.


## E refresh cadence verification, 2026-10-03

TUNE source repair: successful OnRefresh restarts the existing 0.5-second interval after replacing recipients/resources; OnCreated captures its revision and cannot arm a timer for work superseded by nested refresh. No immediate refresh reward, no extra timer, no rate/duration/targeting/localization changes. Shard main/extra beams and ownership remain unchanged. Independent actual-Lua fixture FAIL on fe0fbb0, PASS corrected. Test clock records a requested deadline of0.99 after refresh at0.49, for same/new recipients; nested create/CP0/CP1 refresh schedules only its surviving revision. Existing source/target invalidation, exact-once resource teardown, Shard bounded recipients and damage/mana callback refresh cases PASS. Full node tools/checks.mjs PASS,0failed checks (TEMP/enfos-lion-drain-cadence-checks.log).

API provenance: MCP CDOTA_Buff:StartIntervalThink(float), cross-checked https://docs.moddota.com/lua_server/ and /lua_server/docs. A test clock verifies requested scheduling, not actual engine deadline semantics. OWNER DOTA/VCONSOLE timer reset, repeated casts and natural channel finish remain PENDING; final partial ticks, native mana/no-mana creep policy and exact finish-session identity still OPEN. No foreign code/assets, no Boss exceptions/shared manager rewrite. Contributor Lich work excluded. Whole Lion remains OPEN; no release yet.


## R exact counter ownership verification, 2026-10-03

TUNE: the existing counter_owner gate now owns readonly stack bonuses as well as kill receipts. Borrowed abilities return0 amplification/damage tooltips without reading stack count or changing stored stacks, on server/client across all10ranks and negative/overflow counts. A cast rejects closed, other-parent or other-ability same-name counters before its damage snapshot and future receipt registration. Legitimate cast-time snapshots remain intact after later rank/stack changes; existing inclusive3second receipts, death persistence, cap20, base/Scepter damage, normal/Boss recipients and resource/trace behavior remain unchanged. No new modifier/timer/asset/localization value or shared helper.

Independent getter and cast regressions FAIL against c970e16 (borrowed bonus / foreign counter damage), PASS corrected. Focused counter, actual R targeting/delay and grace fixtures PASS; full node tools/checks.mjs PASS,0 failed checks (TEMP/enfos-lion-counter-ownership-checks.log). Verified MCP GetAbility/GetParent/GetCaster APIs and current primary https://docs.moddota.com/lua_server/ lines2499-2521 support ownership checks; mocks are not evidence of actual engine transfer behavior. No foreign code imported. Contributor Lich source/docs/tests remain untouched and excluded.

OWNER ENGINE buff presentation, real damage, removal/reconnect and native scheduling remain PENDING. Native R alternative punch and E final timing/session/native mana policy remain OPEN; owner preference requested for real mana transfer versus authored damage/mana conversion, with no dependent gameplay change before an answer. Whole Lion remains OPEN. Isolated local commit; no remote or Workshop release.


## Q ordinary impact rules verification, 2026-10-03

TUNE: one reusable living-enemy/nonbuilding/nonimmune recipient predicate now gates initial impact, post-particle, post-audio and post-damage control. Recipient/caster team changes cannot cause friendly damage/stun after those callbacks; a newly building recipient is rejected. Valid dead caster still allows already launched saved damage/stun, preserving the established launched-spell policy. No spell-block/reflect callback added: current installed abilities_english Note1 line1325 explicitly says Earth Spike triggers neither, closing that source-policy question for both point/unit-directed casts. Native line geometry/assets, ten-rank snapshots, immunity, strong purge, ordinary Boss values and engine-owned finite travel unchanged; no new modifier/timer/scan/KV/localization number.

Independent actual-Lua regression FAIL against369c44f on building rejection, PASS fixed. Expanded test covers all10ranks x four INT values x normal/Boss recipients, unit-directed travel and impact, forbidden absorb/reflect calls, building rejection, target/caster team or building changes during particle/audio/damage callbacks, and existing death/source loss/finite resources. Harness now reports Lua stderr explicitly rather than masking its failure behind missing PASS output. Full node tools/checks.mjs PASS,0 failed checks (TEMP/enfos-lion-spike-target-checks.log). Source API verification: current https://docs.moddota.com/lua_server/ OnProjectileHit_ExtraData and installed native/localization references; no external implementation/assets imported.

OWNER ENGINE actual targeting/spell-block/reflect, control/status resistance/strong dispel, terrain and renderer/audio remain PENDING. Native vertical launch and landing-time damage remain OPEN; source correctness does not certify native C++ motion. E mana policy/finish timing and R punch remain OPEN; whole Lion is not complete. Contributor Lich edits excluded, isolated local commit only.


## E exact finish-source verification, 2026-10-03

TUNE: OnChannelFinish now finds the channel handle and destroys it only when valid/open and its generating ability and parent exactly match this ability/caster. Legitimate rank loss still cleans up; closed/foreign/null modifiers and client execution cannot tear down another channel. Destroy owns existing primary slow/audio/beam/Shard cleanup; no resource/timer/value changes. Independent actual-Lua fixture FAIL against cc4c70f, PASS corrected, covering normal/interrupted finish, rank0/1/10, foreign parent/source, missing/removed/closed state, duplicate finish and replacement during teardown. Existing channel visual, Shard defense/recipient and callback regressions PASS.

The full-suite smoke exposed an incomplete test double: CDOTA_Buff:Destroy previously only erased the handle and omitted OnDestroy. It now invokes teardown once and removes the slot only if still owned by that handle; this follows the verified API rather than weakening the interruption assertion. Full node tools/checks.mjs PASS,0 failures (TEMP/enfos-lion-drain-finish-checks.log), including all200 ability/modifier smoke execution. MCP FindModifierByName/GetAbility/GetParent/Destroy/OnChannelFinish and https://docs.moddota.com/lua_server/ verified; no foreign implementation/assets imported. Contributor Lich changes remain excluded.

SOURCE/MOCK pass only. OWNER DOTA/VCONSOLE actual expiry/finish order, cleanup, overlapping/repeated channels and reconnect PENDING. Same-ability stale finish versus new cast session identity, final partial ticks and native mana policy remain OPEN; exact source ownership is not exact engine session certification. Whole Lion OPEN, native R punch still feasible pending implementation; no release yet.


## R native alternative-punch research, 2026-10-03 — implementation OPEN

Current source diagnosis: our R implements delayed burst/kill receipts but lacks native ALT_CASTABLE behavior and the subsequent melee empowerment. Installed scripts/npc/heroes/npc_dota_hero_lion.txt exposes punch_duration20 (+10 Scepter), punch_bonus_movespeed30, punch_attack_range250, punch_bonus_damage_base20/30/40, cleave_damage25 (+25 Scepter), cleave_starting_width150, cleave_ending_width350, cleave_distance650. These are native rank3 values, not an approved Enfos10-rank curve. Installed abilities_english lines1345-1357 describe the empowerment, AltCast disabling it, Scepter duration/cleave and0.25impact/3second grace. Current beam/burst/counter units remain source-tested; full native R parity is not complete.

MCP verified server CDOTABaseAbility:ShouldAltCast returns the initial-cast choice; GetAltCastState returns mutable current state and must not substitute for a cast snapshot. Verified modifier APIs: MODIFIER_STATE_ATTACKS_ARE_MELEE59; MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE114/GetModifierAttackRangeOverride; PREATTACK_BONUS_DAMAGE/GetModifierPreAttack_BonusDamage; MOVESPEED_BONUS_CONSTANT; ON_ATTACK_LANDED; TRANSLATE_ACTIVITY_MODIFIERS/GetActivityTranslationModifiers; TRANSLATE_ATTACK_SOUND/GetAttackSound. ATTACK_RANGE_OVERRIDE is not a verified enum. DoCleaveAttack is the8argument server function (attacker,target,ability,damage,startRadius,endRadius,distance,effectName), corroborated by https://docs.moddota.com/lua_server/. GetAttackCapability/SetAttackCapability exist, but safe restoration/overlap must be proven before using them; do not copy blind RANGED restoration from another hero.

Exact installed resources decoded outside Dota with ValveResourceFormat Source2Viewer-CLI from game/dota/pak01_dir.vpk into TEMP/enfos-lion-punch-review and TEMP/enfos-lion-punch-model. Native fist buff: particles/units/heroes/hero_lion/lion_fistofdeath_buff.vpcf, SHA2565e66a98fbb54ee60af686ba317bda87c523ba8c7cf228b01b553950dd427eaae; preview PATTACH_POINT_FOLLOW attach_palm_l, continuous emitter and wisps children require explicit owner/destruction. CP3-6 literal setup and parent-to-child CP mappings are visible in source; native C++ dynamic CP20+ binding is not exposed and must not be guessed. Bank soundevents/game_sounds_heroes/game_sounds_lion.vsndevts SHA256b6c3d6a8e3a1e73cf4828774179aaece55d3e9db1cfd60023a52cbe22489767e declares Hero_Lion.Punch.PreAttack (finite whoosh) and Hero_Lion.Punch.Attack (finite impact/gore layers). Existing addon precaches the Lion soundbank but not the fist particles.

Compiled models/heroes/lion/lion.vmdl_c SHA2563b6ce617689833b8b75871e846dc541b0e8eaaa60be951a6845bad640f27e1e8 decoded block source verifies attach_palm_l/wrist_L, attack_melee, attack_melee_punch and attack_melee_backhand animations with activity tag melee. Model-driven animation events refer to lion_base_attack_melee_blur.vpcf and lion_base_attack_melee_backhand_blur.vpcf; avoid duplicating these with guessed manual attack effects. No native standalone Lion cleave particle verified. Source decoding is FILE_VERIFIED only, not visual/audio engine acceptance; no foreign code or custom assets imported.

Before implementation: classify TUNE native restoration with explicit PvE rank/stack policy; snapshot initial Alt choice, preserve target rules/absorb/delay/Scepter burst, own one recast-safe finite-duration modifier and continuous hand effect, prove attack type/range/animation/sound restoration and exact credit attribution without Boss exceptions or global scans. Add independent all-rank/source/death/Break/illusion/upgrade/recast/cleanup regressions, explicit precache and four-locale player descriptions. Engine C++ damage/event timing, rendered effect attachment and owner gameplay remain PENDING. Do not close whole Lion or release until remaining feasible source work is done.


## R punch core decision before implementation, 2026-10-03

TUNE restoration of native active empowerment, not replacement of Finger burst/counter. Normal cast grants a20second melee modifier; initial AltCast choice disables the grant. Scepter snapshots30second duration and50% cleave versus25% base. Native attack range250/move speed30 and cleave150/350/650 retained. Explicit Enfos10-rank punch base damage20,25,30,35,40,45,50,55,60,65 plus the existing live bounded Finger stack damage; this authored5-per-rank curve is not native3-rank data or balance acceptance. Active buff survives Break, expires on death and is not dispellable; illusions cannot inherit source authority. Avoid SetAttackCapability writes: verified ATTACKS_ARE_MELEE state and base-range override disappear with the modifier, so no blind ranged restoration overwrites another source. Engine state/projectile parity is pending owner testing.

Use verified native fist continuous particle attached to model-confirmed attach_palm_l, own destroy/release once, refresh duration through engine AddNewModifier without duplicating resource. Native melee activity translation and punch attack/finite preattack sounds; native animation owns melee blur events. DoCleaveAttack delegates ordinary engine physical damage/geometry/resistance to the8argument API. Explicit visual adaptation uses verified Valve Sven cleave particle (existing addon precache), not an invented Lion cleave asset. Original hand children/animation blur particles need precache. No new global scan/unit/thinker/timer or Boss branch. Current native kill-credit for fist remains a separate OPEN source/event-attribution unit; descriptions must not claim that it earns new stacks yet. Owner engine phase/attack-type/cleave/audio/hand attachment remains PENDING.


## R punch core source/mock verification, 2026-10-03

TUNE implemented: R snapshots ShouldAltCast before external callbacks; normal successful cast grants one20second active melee empowerment, while AltCast disables only the new grant. Scepter duration30/cleave50% versus base20/25% are cast snapshots, independent of later acquisition loss. Native250range/+30move/150-350-650cleave geometry retained; explicit authored ten-rank base attack bonus20-65 plus live capped Finger-stack damage. No attack-capability mutation: reversible ATTACKS_ARE_MELEE state/range override/activity melee and native Punch.Attack sound disappear when inactive. Active effect is nonpurgable, removed on death, unaffected by Break; invalid/foreign/unlearned/illusion sources expose no attack stats/translation/sound and cannot cleave. Ordinary primary attacks, including a now-dead valid primary, feed engine DoCleaveAttack physical damage; allied/building/null recipients, other attackers and nonpositive hits rejected. Reentrant cleave guarded; no Boss exceptions, global scan, added thinker/unit/timer.

New r_punch.lua explicitly routed by Lion init, total7 unique owned modifiers; cold bootstrap remains isolated/no duplicate monolith relinks. Verified continuous native hand effect owns one destroy/release across refresh and reentrant creation/binding teardown; five native particles added to existing precache. Model-confirmed melee animation owns its blur events, native finite PreAttack/Attack soundbank already precached. Cleave uses an explicit verified Valve Sven visual adaptation. Initial custom transmitter carries cleave and current stack bonus; real OnStackCountChanged callback updates the client and counter teardown publishes zero. Client readonly getters never call server-only FindModifierByName. Buff tooltips expose actual bonus damage/cleave; all4 locales and12 engine mirrors include duration, rank damage, AltCast and Scepter behavior. No imported foreign code/custom assets.

Independent cast-routing fixture FAIL against627a6af before restoration/PASS corrected. Tests now execute actual R and actual Grant with controlled callback changes to Alt/Scepter and verified snapshot decisions, absorbed/client casts, all10ranks x base/Scepter x negative/ordinary/capped/overflow stacks, current client transmission without server-only queries, active Break policy, foreign counter, counter destruction, ordinary/Boss/dead-primary cleave, rejected targets/attackers, recursion, invalid source/rank/death/illusion/client grant, repeated refresh and exact-once resource teardown. Resource/locale mirror fixtures and existing Finger delay/grace/counter/all200 smoke/isolation regressions PASS. Full node tools/checks.mjs PASS,0failed checks (TEMP/enfos-lion-punch-checks.log). Current MCP CDOTA_Modifier_Lua attack range/activity/sound/stack-change APIs confirmed both-side availability; source/API paths and decoded resource hashes are in preceding research ledger.

SOURCE/MOCK unit passed; not whole R or Lion DONE. Native fist earning its own permanent kill stacks is still OPEN and is not advertised as implemented; existing Finger-hit grace attribution remains unchanged. Actual Dota alternate cast HUD, melee projectile/type/range restoration, late attack callback order, cleave armor/resistance and geometry, model hand particle CP behavior/cosmetics, sounds, Scepter consumption, death/recast/reconnect and VConsole acceptance all PENDING OWNER TEST. E mana policy/final timing/same-ability finish identity and Q native vertical/landing order remain OPEN. Contributor Lich source/contract/KV/test changes excluded from this local commit; no release yet.
