# Jakiro: ability evidence dossier

This dossier starts UNASSESSED/PENDING. It is a work reference, not proof that the kit works. The existing [structural inventory](../../audit/HERO_ABILITY_CONTRACTS.json) remains the source for static audit candidates.

<!-- BEGIN GENERATED INVENTORY -->
## Current inventory (generated; not certification)

Hero: `npc_dota_hero_jakiro`; role: Support. Progression target: hero level 50 / all five abilities 10 total ranks; the KV rank inventory below and runtime unlock acceptance are tracked separately.

| Slot | Stable ability ID | Current explicit MaxLevel | Behavior | Script | Icon (not native counterpart proof) |
| --- | --- | --- | --- | --- | --- |
| 1 | `enfos_jakiro_dual_breath` | 10 | DOTA_ABILITY_BEHAVIOR_POINT | abilities/heroes/jakiro/q | jakiro_dual_breath |
| 2 | `enfos_jakiro_ice_path` | 10 | DOTA_ABILITY_BEHAVIOR_POINT | abilities/heroes/jakiro/w | jakiro_ice_path |
| 3 | `enfos_jakiro_liquid_fire` | 10 | DOTA_ABILITY_BEHAVIOR_UNIT_TARGET \| DOTA_ABILITY_BEHAVIOR_AUTOCAST | abilities/heroes/jakiro/e | jakiro_liquid_fire |
| 4 | `enfos_jakiro_macropyre` | 10 | DOTA_ABILITY_BEHAVIOR_POINT | abilities/heroes/jakiro/r | jakiro_macropyre |
| 5 | `enfos_jakiro_double_trouble` | 10 | DOTA_ABILITY_BEHAVIOR_PASSIVE | abilities/heroes/jakiro/d | jakiro_liquid_fire |

Source: [hero KV](../../../game/scripts/npc/npc_heroes_custom.txt), [ability KV](../../../game/scripts/npc/npc_abilities_custom.txt), [abilities/heroes/jakiro/q](../../../game/scripts/vscripts/abilities/heroes/jakiro/q.lua), [abilities/heroes/jakiro/w](../../../game/scripts/vscripts/abilities/heroes/jakiro/w.lua), [abilities/heroes/jakiro/e](../../../game/scripts/vscripts/abilities/heroes/jakiro/e.lua), [abilities/heroes/jakiro/r](../../../game/scripts/vscripts/abilities/heroes/jakiro/r.lua), [abilities/heroes/jakiro/d](../../../game/scripts/vscripts/abilities/heroes/jakiro/d.lua), [structural contracts](../../audit/HERO_ABILITY_CONTRACTS.json).

### Installed native source (not a custom-slot mapping)

Source: `scripts/npc/heroes/npc_dota_hero_jakiro.txt`; status: FILE_VERIFIED; SHA256: `da0a519bfad3795e143cd0f8e595d83ed20ea1354a8391beed27400aadcc0f34`.
Installed build: ClientVersion=6941; SourceRevision=11041083; Sep 25 2026. Snapshot observation UTC: 2026-09-29T20:43:45.203Z.
Archive provenance: [source snapshot](../../audit/HERO_REFERENCE_SOURCE_SNAPSHOT.json). Re-read installed resources after a patch.

| Native field | Observed value |
| --- | --- |
| Model | `models/heroes/jakiro/jakiro.vmdl` |
| SoundSet | `Hero_Jakiro` |
| Ability1 | `jakiro_dual_breath` |
| Ability2 | `jakiro_ice_path` |
| Ability3 | `jakiro_liquid_fire` |
| Ability4 | `jakiro_liquid_ice` |
| Ability5 | `jakiro_double_trouble` |
| Ability6 | `jakiro_macropyre` |
| Ability10 | `special_bonus_unique_jakiro_4` |
| Ability11 | `special_bonus_unique_jakiro_6` |
| Ability12 | `special_bonus_attack_range_175` |
| Ability13 | `special_bonus_unique_jakiro_dualbreath_cooldown` |
| Ability14 | `special_bonus_unique_jakiro` |
| Ability15 | `special_bonus_unique_jakiro_7` |
| Ability16 | `special_bonus_unique_jakiro_2` |
| Ability17 | `special_bonus_unique_jakiro_3` |
| AttributeStrengthGain | `2.6` |
| AttributeAgilityGain | `1.200000` |
| AttributeIntelligenceGain | `3.300000` |

### Per-ability review leads

- `enfos_jakiro_dual_breath`: world position, travel/impact timing and radius alignment.
- `enfos_jakiro_ice_path`: world position, travel/impact timing and radius alignment.
- `enfos_jakiro_liquid_fire`: manual/autocast parity, attack proc and duplicate events; target flags, immunity, spell block/reflect if applicable, target loss.
- `enfos_jakiro_macropyre`: world position, travel/impact timing and radius alignment; ultimate unlock curve, Scepter/Blessing and boss burst.
- `enfos_jakiro_double_trouble`: Enfos passive free starting rank, native innate separation, respawn/point budget; intrinsic modifier, Break/illusion behavior, live rank refresh.

<!-- END GENERATED INVENTORY -->

## Human decisions and runtime evidence (preserve on refresh)

2026-09-30 level-50 migration: Q/W/E/Enfos passive gates start at level 1 with interval 1; R starts at level 5 with interval 5. Static contract test added; point/HUD and gameplay acceptance remain pending for owner live test.

2026-09-30 Double Trouble passive repair: the fifth-slot Intelligence and attack-speed bonuses now honor Break and are not inherited by illusions. KV marks the custom passive breakable; a mock regression covers both stats under normal, Broken and illusion states. Modifier lifecycle and live Dota behavior remain PENDING.

## Slot 1: `enfos_jakiro_dual_breath`

Classification: TUNE
Native counterpart: `jakiro_dual_breath` (installed native hero snapshot, ClientVersion 6943 / SourceRevision 11069754; rechecked 2026-10-03; Enfos slot assignment is project-specific).
Decision and PvE identity rationale: TUNE — the native mechanic already fits creeps; ten authored ranks/INT scaling require compatibility review. See the 2026-10-03 individual ledger for identified source defects and pending repair; no blanket PvP conversion is justified.
Expected behavior: two engine projectiles, ice then fire0.2s later, speed1050/radii150–275/distance850 plus engine cast-range bonuses. Ice applies saved slow; fire applies finite5s elapsed burn. No initial burst. Source implemented; owner engine confirmation PENDING.
Normal/Boss use identical formulas; no authored Boss branches. Enemy hero/basic engine collision; ordinary immunity suppresses control/burn, magic resistance through ApplyDamage, basic-purgeable modifiers, engine duration/tenacity. No elite spawns. Actual engine immunity/status-resistance/overlapping-caster semantics PENDING.
Ten existing Q rank gates and full-duration base damage100–490 + INT0.8 preserved; DPS equals saved full-duration budget divided by5s. No new ordinary skill points/free ranks. Owner HUD/point engine gate PENDING.
No Q-specific installed Shard/Scepter upgrade. Ordinary shared item amp/cooldown rules retained; current generic Support Shard and R native Scepter fidelity are unresolved in E/R review. No talents/progression restored.

### Resource and implementation evidence

- Installed scripts/npc/heroes/npc_dota_hero_jakiro.txt AbilityDefinitions + steam.inf Client/Server6943 SourceRevision11069754; MCP read and decoded native resources inspected on2026-10-03. Native C++ ten-rank custom-scaling compatibility not certified.
- Projectile EffectName: native jakiro_dual_breath_ice/fire.vpcf; decoded root CP1 velocity initializer, engine endcaps. Modifier effects: verified generic_slowed_cold.vpcf and deliberately reused jakiro_liquid_fire_debuff.vpcf, PATTACH_ABSORIGIN_FOLLOW, engine modifier cleanup. Actual projectile CP/width/head attachment presentation PENDING.
- Existing startup Jakiro bank: valid Hero_Jakiro.DualBreath.Cast and .Burn, .DualBreath itself null-start not used. Cast emitted from caster, finite burn cue from target once; stop on teardown. Multi-caster sound overlap remains PENDING.
- Verified native jakiro_dual_breath icon and installed ACT_DOTA_CAST_ABILITY_1 set in KV. Actual animation/visual gate PENDING.
- Two Q-owned linked modifiers, per-hit snapshots/custom transmitters. Refresh settles elapsed old burn, then switches DPS; basic purge pays no remaining budget. Valid dead caster cast continues; removed sources cancel. Active spell unaffected by Break. Engine lifecycle PENDING.
- addon_game_mode.lua startup includes ice/fire/cold slow/Liquid Fire debuff and existing Jakiro sound bank. Cold/legacy import fixture confirms seven unique Jakiro modifiers; actual Dota cold resources PENDING.
- One pause-aware0.2s context callback per cast, no retained cast-hit table/global scan. Finite engine-distance projectiles; modifier stops local0.5s interval/sound once. Independent invalid-owner/expiry/purge/recast fixture PASS; engine/performance PENDING.
- Four locales +12 generated mirrors: two traveling breaths, total budget/duration, no debuff-immunity piercing, purge/refresh and dynamic slow/burn modifier tooltips. Installed abilities_english.txt confirms %f tooltip substitution and %%% literal percent form; owner rendering PENDING.

### Acceptance ledger

| Area | Status | Source/build/test evidence or N/A reason |
| --- | --- | --- |
| Gameplay | PENDING | Independent traveling/burn fixture FAIL before repair / PASS after; full-duration budget412 on equivalent normal/Boss targets. Actual gameplay PENDING. |
| Targeting | PENDING | Engine expanding linear projectile args verified in mocks, ally/immune/invalid rejects, flat/zero aim; engine hull/width/flags PENDING. |
| Ranks | PENDING | Static gates put rank 10 by level 50; owner live test must confirm engine points and ability HUD. |
| VFX | PENDING | Installed root/child resources decoded and engine-owned particle routes authored; actual head attachment/scale/timing PENDING. |
| SFX | PENDING | Installed Cast/Burn definitions verified; start/stop lifecycle mocked, actual audio/overlapping caster PENDING. |
| Animation | PENDING | Installed ACT_DOTA_CAST_ABILITY_1 in production KV; owner animation PENDING. |
| Modifiers | PENDING | Snapshot/client/refresh/invalid-handle/immune getters and finite burn lifecycle fixtures PASS; actual purge/tenacity/overlap PENDING. |
| Precache | PENDING | Verified startup resource names and unique module links; actual cold Dota load PENDING. |
| Cleanup | PENDING | Natural-expiry final fraction, no early-removal payout, idempotent teardown and removed-owner cancel mocked; actual engine order PENDING. |
| Boss | PENDING | Identical ordinary normal/Boss full-duration formula412 in fixture; armor/resistance/immunity remain ordinary engine rules. Owner Boss hit PENDING. |
| Upgrades | PENDING | No Q-specific upgrade; general item amp/CD mechanisms retained. Native E/R upgrades remain under review. |
| Localization | PENDING | EN/TR/RU/zh-CN descriptions and dynamic modifier tooltips generated; actual engine rendering PENDING. |
| Performance | PENDING | Two finite engine projectiles/cast and per-affected-unit two5s modifiers; no global scan. Dense-wave runtime cost PENDING. |
| Reconnect | PENDING | Cast numeric snapshots and engine modifier state, no account or retained per-cast gameplay table; actual reconnect PENDING. |
| VConsole | PENDING | Shared bounded default-off Q launch/finish/hit/modifier lifecycle and total burn traces; owner VConsole PENDING. |

Change/test record: all five abilities now expose ten KV ranks; the complete 200-ability Lua mock suite passes. This confirms static/mock behavior only; in-match Dota VFX, SFX, rank-up HUD, boss and VConsole acceptance remain PENDING.

Change/test record (2026-09-30): all five Jakiro skill value blocks now use named `AbilityValues` keys consumed by Lua; ten-rank curves are unchanged. A five-slot static contract test was added. In-game damage/timing, auto-cast, VFX, SFX, modifier cleanup, boss and upgrade checks remain PENDING for the user.

Follow-up review (2026-09-30): Ice Path's configured 0.5-second `path_delay` was not read, so damage and stun occurred before the warning completed. The implementation now snapshots the cast origin/direction and applies its ranked hit and shortened boss stun after that delay. Mock regression passes; VFX/SFX, actual timing and cleanup remain pending for the user’s Dota test.

Follow-up static audit (2026-09-30): rechecked Dual Breath, Liquid Fire,
Macropyre and Double Trouble against their ten-rank KV values, EN/TR/RU/zh-CN
tooltips, evolution choices, shared Aghanim handling and targeted mocks. Liquid
Fire's manual and autocast paths both route through the same effect implementation;
Macropyre's line filtering and per-cast boss cap have regression coverage. No
additional code defect was confirmed in this pass. In-game cast/attack behavior,
rank scaling, particle controls, audio, channel/effect cleanup and upgrades remain
pending the owner's live Dota test.

## Slot 2: `enfos_jakiro_ice_path`

Classification: TUNE
Native counterpart: `jakiro_ice_path` (installed native hero snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot assignment is project-specific).
Decision and PvE identity rationale: TUNE — the native mechanic already fits creeps; ten authored ranks/INT scaling require compatibility review. See the 2026-10-03 individual ledger for identified source defects and pending repair; no blanket PvP conversion is justified.
Expected behavior: Snapshot a planar path at cast origin, show matching endpoint warning, then use engine line targeting after 0.5 seconds with ordinary ranked engine stun for all valid enemies. A finite modifier now catches later entrants once per cast, snapshots each path, bounds late stuns by remaining lifetime and owns effect cleanup. Actual engine/particle timing and parity remain pending under the current individual ledger.
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
| Gameplay | PENDING | Historical mock protected a circular hit and Boss-only stun reduction; reopened under the 2026-10-03 individual audit. Engine timing and native path geometry remain unverified. |
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

## Slot 3: `enfos_jakiro_liquid_fire`

Classification: TUNE
Native counterpart: `jakiro_liquid_fire` (installed native hero snapshot, ClientVersion 6943 / SourceRevision 11069754; rechecked 2026-10-03; Enfos slot assignment is project-specific).
Decision and PvE identity rationale: TUNE — the native mechanic already fits creeps; ten authored ranks/INT scaling require compatibility review. See the 2026-10-03 individual ledger for identified source defects and pending repair; no blanket PvP conversion is justified.
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
| Gameplay | PENDING | Independent resource/invalid-callback fixture PASS; landed-event instant impact is interim, native attack/burn conversion OPEN. |
| Targeting | PENDING | Not evaluated in this dossier setup. |
| Ranks | PENDING | Static gates put rank 10 by level 50; owner live test must confirm engine points and ability HUD. |
| VFX | PENDING | Not evaluated in this dossier setup. |
| SFX | PENDING | Not evaluated in this dossier setup. |
| Animation | PENDING | Not evaluated in this dossier setup. |
| Modifiers | PENDING | Independent slow snapshot/client/refresh/immune fixture PASS; hidden nonpurge/death-retained proc owner explicit. Engine lifecycle and Break/orb fidelity OPEN. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Ordinary/Boss equivalent fixture damage120; no authored Boss branch. Engine damage/resistance acceptance PENDING. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | Four locales and12 mirrors describe current resource/impact/slow rules and dynamic modifier tooltip. Actual rendering PENDING. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: all five abilities now expose ten KV ranks; the complete 200-ability Lua mock suite passes. This confirms static/mock behavior only; in-match Dota VFX, SFX, rank-up HUD, boss and VConsole acceptance remain PENDING.

## Slot 4: `enfos_jakiro_macropyre`

Classification: TUNE
Native counterpart: `jakiro_macropyre` (installed native hero snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot assignment is project-specific).
Decision and PvE identity rationale: TUNE — the native mechanic already fits creeps; ten authored ranks/INT scaling require compatibility review. See the 2026-10-03 individual ledger for identified source defects and pending repair; no blanket PvP conversion is justified.
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

## Slot 5: `enfos_jakiro_double_trouble`

Classification: REPLACE
Native counterpart: `Project-specific Enfos passive; native Jakiro innate remains distinct` (installed native hero snapshot, ClientVersion 6941 / SourceRevision 11041083; Enfos slot assignment is project-specific).
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
| Modifiers | PENDING | MOCK_PASS: Double Trouble's two bonuses are checked for Break/illusion suppression; engine modifier and Break presentation remain unverified. |
| Precache | PENDING | Not evaluated in this dossier setup. |
| Cleanup | PENDING | Not evaluated in this dossier setup. |
| Boss | PENDING | Not evaluated in this dossier setup. |
| Upgrades | PENDING | Not evaluated in this dossier setup. |
| Localization | PENDING | Not evaluated in this dossier setup. |
| Performance | PENDING | Not evaluated in this dossier setup. |
| Reconnect | PENDING | Not evaluated in this dossier setup. |
| VConsole | PENDING | Not evaluated in this dossier setup. |

Change/test record: all five abilities now expose ten KV ranks; the complete 200-ability Lua mock suite passes. This confirms static/mock behavior only; in-match Dota VFX, SFX, rank-up HUD, boss and VConsole acceptance remain PENDING.

## Active individual audit — 2026-10-03

[Individual review](../../audit/JAKIRO_INDIVIDUAL_REVIEW_2026-10-03.md) supersedes historical source closures. All five handlers reviewed against installed build 6943 / revision 11069754; native-first Q/W/E/R TUNE, D REPLACE. Isolation preserves existing mechanics and known defects. Source repair, traces and every engine/visual/audio gate remain pending. Ice Path Boss reduction and Macropyre cap are defects to remove under the owner contract, not accepted behavior.

2026-10-03 R focused repair: removed the cumulative Boss-only 10% maxHP cap/table. Independent fixture reproduced truncation before the change and passes for ordinary/flagged/named Boss targets afterward; ordinary magical flags and existing line rejection remain unchanged. Native path/Scepter/VFX/SFX/engine acceptance remains PENDING.

2026-10-03 W focused repair: matching saved visual/hit endpoints, native-radius150 line query, zero-aim facing fallback, built-in stun without Boss multiplier, server/removal/reentrant callback protections, startup native bank and four-locale formula/immunity/dispel text. Independent fixture reproduced endpoint mismatch before repair and covers rank1/10/invalid callbacks afterward. Persistent native path behavior and engine/VFX/SFX/width verification remain PENDING.

2026-10-03 W persistent follow-up: independent path_duration3–7.5s, warning0.5s, one W-owned modifier per cast, existing max-three ground entities, 0.1s local engine line checks and once-per-target hits; modifier owns particle/sound destruction. Source/lifecycle tests pass, engine/VFX/SFX/performance remain PENDING.

2026-10-03 D focused repair: learned-rank and removed-handle gates, explicit nonpurge/death-retained intrinsic, visible verified Liquid Fire icon, dynamic INT/AS modifier tooltip and bounded lifecycle traces. Rank-zero defect reproduced before repair; independent ranks0–10/Break/illusion/removed-owner/tooltip/logging fixture. All engine/respawn/reconnect/tooltip presentation gates remain PENDING. No native second attack claimed.

2026-10-03 Q modifier-focused repair: hit snapshots freeze move/attack slow, custom transmitter restores client values, recast refreshes, getters avoid invalid ability, basic purge/native icon/dynamic tooltip explicit. Independent fixture reproduced absent application ownership before repair; actual client/server tooltip, dispel/status resistance remain PENDING. Traveling ice/fire cones and burn remain OPEN, current circleburst is not certified native behavior.

2026-10-03 E focused resource/safety repair:20 mana authored KV matching installed ordinary cost; IsFullyCastable before automatic proc, UseResources(true,false,false,true) once; manual engine spend not repeated. Server/learned/removed-owner/team and absorb/resource/damage callback guards; valid killed attack target retains impact origin. Slow snapshots/custom client transmitter/native icon/basic purge; hidden nonpurge/death-retained proc owner; bounded impact/resource/modifier lifecycle traces. Independent fixture FAIL before resource repair / PASS after. Native attack launch/record/miss/projectile, five-second DoT/building rules/Break fidelity and Shard Liquid Ice/mana0/cooldown linkage remain OPEN; engine gates PENDING.

### 2026-10-03 E burn restoration (source evidence only)

TUNE retained. Installed6943 native Liquid Fire duration5/tick0.5/building75% re-read; IsBuilding verified via current MCP API. Existing instant burst now becomes a snapshotted complete five-second magical damage budget (bonus_damage + INT0.3), with saved AS slow. Local E query includes buildings; no Boss branch. Same existing debuff owns periodic damage, basic dispel, native liquid_fire_debuff VFX, client AS/DPS tooltip, refresh and finite interval cleanup. Impact LiquidFire sound definition lasts1.459206s; no burn loop added. Natural expiry final partial slice only; purge/death cancels future damage; immune time skipped; dead valid caster preserves already-cast burn; invalid owners cancel.

Independent source fixture initially FAIL on omitted building target mask; after repair tests cover no instant hit, saved normal/Boss120 and building90 over5s, fractional expiry, early purge, refresh old-slice settlement, immunity/no catch-up, removed handles, caster death and client ticks. Resource safety regressions now assert effect applications before burn rather than preserving old burst. Four locales describe actual burn and dynamic DPS. Native attack-launch/records/projectile/miss/manual attack/Break fidelity and Shard remain OPEN; actual Dota/VConsole, building immunity, VFX CP/attachment, audio, rank/upgrade/reconnect acceptance PENDING. No whole-hero certification.

### 2026-10-03 R ground lifecycle and line repair

TUNE/native-first retained; installed6943 width500/tick0.5/ACT4/nonpiercing/nondispellable source verified. Ground owner now saves flat endpoints, native radius250, authored DPS + INT0.7 and configured duration. Engine line query replaces broad circle/manual membership. Server/learned/valid callback gates, facing fallback, valid dead caster continuing existing fire, and modifier-owned particle destruction/release exactly once. Root decoded CP1=end, CP2.x=duration and CP4.x=radius supplied. Existing max-three thinkers unchanged. Elapsed-time integration settles final expiry slice and prevents repeated/reentrant same-time payout; early cancel pays no future damage. Shared default-off traces cover field create/remove and aggregate requested/applied damage. Four locales explain current behavior. Independent fixture reproduced client creation before repair and tests saved geometry/damage, caster death, expiry, zero aim, bounded recasts and invalid ability cleanup. Source test PASS does not establish native visual width/CP child fit or engine collisions. Lingering burn outside path and native Scepter remain OPEN source work; actual Dota/VConsole/VFX/SFX/rank/upgrade/reconnect PENDING.

### 2026-10-03 E automatic attack-record repair

TUNE. Automatic resource spend moves from landed event to OnAttack; each funded engine record saves exact target and launch values. Hit consumes record before calling area burn, so changed rank/INT/cooldown/autocast/Break or valid caster death during flight does not alter a fired orb. Miss and engine record destruction clear ownership without refund or impact; modifier teardown clears all records. Illusion/silence/rank0/invalid/dead launch rejected, missing record rejected rather than creating untracked orb. Records live only until corresponding engine terminal event/owner teardown, no global table, thinker or scan. Native E active-orb Break suppression removed; authored fifth passive retains its own Break policy. Reference-only generic orb from Workshop1571786267 inspected; no foreign code imported. API eight-argument PerformAttack verified for later manual review. New independent fixture reproduces missing record lifecycle before change and tests launch funding, duplicate/wrong/failed/destroyed record, saved values, client/silence, caster death and teardown. Existing resource suite adapted to full attack->landed flow. Four locale text reflects launch cost/miss/no refund. Actual Dota record event order, projectile art, manual attack conversion, Shard and native orb priority remain OPEN/PENDING.

### 2026-10-03 E manual attack bridge

TUNE, current8-argument PerformAttack/IsDisarmed APIs verified. Manual cast launches one real ranged attack with normal procs/projectile, ordinary attack cooldown, no fake/never-miss flags. Matching synchronous OnAttack consumes a one-use engine-funding token without another mana/CD spend; saved record then shares automatic impact/miss/terminal handling. Missing launch record cancels rather than falling back to instant spell damage. Token clears when PerformAttack returns; no timed stale manual state or extra projectile. Direct spell-absorb branch removed from attack bridge (native attack policy inferred from KV/API, Linken interaction remains actual-engine PENDING). Disarmed/illusion/silence/invalid launches rejected. Native current ACT3/castpoint0 restored. Native base-attack projectile remains supplied by hero; dedicated orb appearance not certified. Independent fixture FAIL before bridge / PASS after: one launch, delayed single burn, miss, no event, removed ability/target, client, disarm, exact flags and no extra funding. Existing resource and all200 smoke fixtures model attack->hit instead of preserving instantaneous manual burst. Four locales describe one enhanced normal attack requiring impact. Real engine PerformAttack event order, item secondary procs, attack range/state/animation, projectile/head appearance and Shard remain PENDING; R linger/Scepter still OPEN.

### 2026-10-03 R recipient burn follow-up (supersedes direct field pulses)

TUNE. Native linger_duration1 restored: bounded saved line field refreshes one recipient burn every0.5s, initially at creation. Recipient owns saved DPS, periodic elapsed damage, nondispellable status and native macropyre_firehit VFX; it lives for1s after the last field application even when field expires or a valid caster dies. Ground owner now only registers/refreshes burn and cleans its own particle; old direct-field final-partial damage and aggregate trace statements above are superseded. Recipient expiry settles its final fractional slice exactly once, while early removal/target death/removed ability or caster cancels future damage. Same-DPS refresh does not restart ticks or emit extra damage; changed DPS settles old elapsed slice. Client DPS transmitter/tooltip in EN/TR/RU/zh-CN. Modifier/precache routes total8; max3 ground fields unchanged. No Boss branch/cap or global timer added.

Independent recipient and integrated field fixtures PASS: no initial burst, sustained2700 ordinary/Boss damage over10s for270DPS, off-line exclusion, post-field135 last-half-second damage, quantized fractional field's2s total burn540, same-DPS overlap, changed-DPS settlement, immunity without catch-up, valid caster death, source/target loss, early removal, reentrant damage removal, client tooltip and exact particle cleanup. Existing358 mixed hero regressions and full node tools/checks.mjs PASS,0 failed checks. Current ModDota GetElapsedTime/GetRemainingTime/interval and refresh API checked; installed native KV/firehit resource consulted. These fixtures model elapsed clocks and refresh ownership rather than asserting direct zone damage.

Actual Dota exit sampling (0.5s), refresh ordering, multi-caster ownership, natural-expiry callback ordering, status resistance, immunity, model attachment, audio, upgrade/rank HUD and reconnect remain owner PENDING. R Scepter and E dedicated orb appearance/Shard still OPEN; no whole-hero or live acceptance claimed.

### 2026-10-03 E fixed impact origin and native radius controls

TUNE. Confirmed missing CP1 in generic effect helper prevented native explosion RingWave radius/speed inputs from receiving the saved AoE radius. E now owns its short native impact setup locally: WORLDORIGIN with target context, CP0 saved hit position, CP1 saved radius on all components, finite native release once. Native decoded CP1.x radius multiplier0.25 / CP1.z speed multiplier2 verified; reference-only Boss Survival Adventure1571786267 same resource radius convention inspected, no code imported. Burn/record/funding/sound/query formulas unchanged; shared helper and other heroes unchanged. Independent fixture FAIL before / PASS after: exact resource/attachment/owner, position and radius match saved query even if sound moves target, single release, server/invalid-owner gates, source removal during particle callback stops query without leaking index. Existing burn/resource fixtures supplied actual particle API mocks; full node tools/checks.mjs PASS,0 failed checks. No new visible text; existing four-language AoE descriptions remain accurate. Current [particle API](https://docs.moddota.com/lua_server/) consulted.

Owner Dota terrain/hull/child visual width, dead target attachment, finite expiry and audio remain PENDING; input agreement is not renderer acceptance. E launched projectile and ready-head appearance, native Shard, and R Scepter remain OPEN before Jakiro source closure. No live promotion.

### 2026-10-03 E Shard mana component (partial upgrade audit)

TUNE. Installed hero-file nested native Liquid Fire values20mana /Shard0 verified. E GetManaCost delegates ordinary cost to engine BaseClass and returns0 while authoritative AghanimManager detects Shard. Added only Jakiro to existing native permanent-buff compatibility; inventory and legacy consumed forms retained, removed caster rejected, no cached upgrade state. E HasShardUpgrade and four-language mana explanation added; existing D Support-heal description remains truthful until coherent replacement. GetManaCost client/server API verified against current installed MCP and [ModDota](https://docs.moddota.com/lua_server/).

Independent fixture FAIL before callback / PASS after: all10 base costs including changed engine cost, permanent/legacy/inventory acquisition and loss, client agreement, removed caster, unreviewed hero recognition unaffected; zero-mana Shard automatic launch still consumes ordinary cooldown once, second launch blocked, miss record cleared. Full checks PASS before final KV visibility flag; final checks recorded below. Native Liquid Ice extra ability and separate cooldowns, removal of existing generic Support heal, dedicated projectile/head art and Macropyre Scepter remain OPEN. Owner purchase/consumption/reconnect, HUD cost, manual engine payment and zero-mana autocast remain PENDING; no full Shard/Jakiro acceptance.

Final Shard mana component checks after KV visibility flag and zero-mana cooldown fixture: node tools/checks.mjs PASS,0 failed checks. Engine acceptance remains pending.

### 2026-10-03 R Scepter core repair (icy edges remain OPEN)

TUNE. Existing R now snapshots authoritative Scepter/Blessing at cast: duration+5, pure damage and immunity-piercing line target flags/recipient damage gates. Acquiring or losing item later does not rewrite a saved field. When an overlapping application changes type/piercing, old elapsed damage is settled using old policy before new policy; same policy refresh retains its interval. Removed only Jakiro's old generic40%ultimate amp/25%CDR and hid its obsolete generic Scepter modifier; native item stats and unreviewed heroes unchanged. KV has scepter_duration_bonus5, all four tooltips reflect only implemented core. Default-off field/burn traces include saved type/piercing. No Boss formula or extra owner/global scan.

Pre-change HEAD R reproduces missing Scepter snapshot failure in focused fixture; changed source PASS. Tests cover15s upgraded vs10s ordinary, pure burn of immune target, ordinary immunity exclusion, type transition old-slice settlement, loss during existing burn, consumed Blessing, generic bonus suppression and unreviewed hero generic bonus regression. Normal Macropyre fixtures retain ordinary/Boss equality, finite particle/recipient cleanup and client gating. Full node tools/checks.mjs PASS,0 failed checks after locale generation repair: upgrade description suffix does not resolve special placeholders, so its localized text states verified5 explicitly; base ability text resolves KV token.

PARTIAL overall Scepter source acceptance: icy flank path/60%slow/0.4linger still feasible OPEN work and must be implemented before closure; inspected native edge resource uses endpointCP1/durationCP2. Actual Dota BKB AddNewModifier behavior, damage flags/resistance, pure tooltip header, native-item/Blessing buy/sell, rank10+duration, multi-caster/overlap order, audio/visual/reconnect remain owner PENDING. No hero completion or live upload.

### 2026-10-03 R Scepter icy flanks source repair

TUNE. Same finite owner now owns two saved parallel edge paths (center offset halfwidth250+20, radius50) and two verified native ice_edge particles with CP0/1 endpoints/CP2saved duration. No additional ground thinker/unit per flank or recipient; max3fields retained, each owns fire+2ice particles. Local0.1s edge checks maintain0.4s linger without0.5s polling gaps; ordinary fire refresh remains0.5s and normal cast uses previous poll rate. Saved60% movement-only slow applies to enemy HERO|BASIC, includes immune targets and ordinary/Boss uniformly, adds no damage. Engine owns recipient expiry, source-invalid/dead-target property returns0, valid caster death preserves field. Slow custom transmitter, native Macropyre icon and EN/TR/RU/zh-CN descriptions included. Nine modifier bootstrap routes; native edge root explicit precache. Idempotent field destroy stops polling and destroys/releases3particles once. Bounded default-off apply/remove slow traces, no refresh spam.

Independent fixture FAIL before /PASS after; saved top/bottom endpoints+height, native CPs, equal normal/Boss/immune slow, center/outside rejection, no edge damage, uninterrupted sampled expiry, fire refresh not multiplied, client tooltip, source loss/natural expiry cleanup and no client creation verified. Existing ordinary R/burn/Scepter/isolation regressions and full node tools/checks.mjs PASS,0 failed checks. Reentrant edge callback source-removal fixture added and independently rechecked. Native localization verifies slow property; installed decoded particle verifies endpoint/duration inputs, exact current KV values verify authored tuning. ModDota query yielded no exact primary edge implementation; nonprimary search results were not adopted as engine facts. No foreign code imported.

Source effect exists now; OWNER_RUNTIME remains PENDING. Compare native geometry/offset/collision hull, per-component purge, slow/tenacity/immune rendering, late crossing, performance with3upgraded fields and large wave,3particle lifecycle/audio, valid caster death/reconnect and Scepter timing in Dota. Geometry is documented reconstruction, not C++ equivalence. Existing cast snapshot upgrade policy is Enfos behavior. E flight/head assets, full Shard/Liquid Ice and whole Jakiro review closure remain OPEN.

2026-10-03 E projectile source update: declared no-argument engine PROJECTILE_NAME selector and explicit native jakiro_base_attack_fire precache. Pure server eligibility query; client/dead/invalid/off/cooldown queries retain ordinary projectile; manual already-funded token is considered without a second spend. Three focused projectile/funding/manual fixtures PASS. Owner property-query order, launch visibility, concurrent flights/secondary attacks and ready-head visual remain PENDING; no per-record renderer acceptance. See individual audit ledger for reconstructed eligibility limitations. Full Liquid Ice Shard remains OPEN.

Full Shard research correction (2026-10-03): installed internal jakiro_liquid_ice is visibly Liquid Frost and belongs to baseline native kit; Shard removes mana/shared cooldown rather than granting it. Baseline linked frost is missing in Enfos. Its native tooltip describes impact plus bonus attack/other-ability damage, not a guaranteed periodic frost burn. Auxiliary rank/resource design and native LinkedAbility compatibility remain OPEN; preserve D and49 paid points. Exact references/next acceptance unit in individual ledger.
