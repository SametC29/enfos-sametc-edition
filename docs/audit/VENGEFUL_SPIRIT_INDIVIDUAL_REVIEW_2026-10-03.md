# Vengeful Spirit individual review — reverse roster, 2026-10-03

Second hero after Lich under [the owner goal](HERO_INDIVIDUAL_AUDIT_GOAL_2026-10-03.md).
This is an active findings ledger, not acceptance of the kit. Historical blanket
PVE-CONVERT classifications in the dossier are superseded by the decisions below.

## Evidence and native-first decisions

The initial findings below are historical discovery. Later focused receipts and
the current closure matrix supersede their unresolved/pending implementation
claims; owner runtime acceptance remains separate.

Installed Dota: ClientVersion/ServerVersion 6943, SourceRevision 11069754,
VersionDate Oct 01 2026. MCP `vpk_read` directly read
`scripts/npc/heroes/npc_dota_hero_vengefulspirit.txt` on 2026-10-03.
The native counterpart names below come from its AbilityDefinitions, not icons.
Native implementation is engine C++; KV alone cannot establish complete behavior
or compatibility of native abilities with ten ranks and Enfos AGI scaling.
MCP reference search for `modifier_vengefulspirit_command_aura` returned no corpus
matches; no custom-game code was imported or treated as a working reference.
API reference: [ModDota Lua server declarations](https://docs.moddota.com/lua_server/).

| Slot | Disposition | Native evidence and custom behavior being reviewed |
| --- | --- | --- |
| Q `enfos_vs_magic_missile` | TUNE | Native `vengefulspirit_magic_missile`: enemy hero/basic, magical, speed 1350, strong-dispellable stun, ACT_DOTA_CAST_ABILITY_1. Custom tracking projectile uses speed 1250, ten damage/stun ranks, damage + 0.9 AGI. Preserve identity; native ten-rank/scaling conversion remains unproven. |
| W `enfos_vs_wave_of_terror` | TUNE | Native `vengefulspirit_wave_of_terror`: point cast, range 1400, speed 2000, width 325, armor and attack reduction, duration 8, vision 350/4s, ACT_DOTA_CAST_ABILITY_2. Current custom code instead applies immediate damage + 0.6 AGI and armor loss in a 140 half-width line; no travel callback, attack reduction or vision. These are native-fidelity gaps requiring a focused restoration decision, not evidence that every native feature is PvP-only. |
| E `enfos_vs_vengeance_aura` | TUNE | Native `vengefulspirit_command_aura`: friendly passive/aura, Breakable, bonus base damage, radius 1200, Scepter metadata. Custom has ten 15–36% base-damage ranks and radii 900–1350. Review actual source ownership and linger, not only emitter IsAura. |
| R `enfos_vs_nether_swap` | TUNE | Native `vengefulspirit_nether_swap`: custom target filter, enemy debuff-immunity piercing, cast .4, ACT_DOTA_CAST_ABILITY_4, damage 150/300/450, damage_reduction 0 and duration 10 in this build. Custom ten-rank swap uses damage + 1.2 AGI and an authored 4s/30% caster defense. Do not cite old native shield values as evidence. Target restrictions, safety and authored Boss exclusions require review. |
| D `enfos_vs_retribution` | REPLACE | Authored ten-rank AGI/attack-speed passive, not native `vengefulspirit_retribution` (rank-one unlearnable innate with bonus_damage 20). Preserve this stable Enfos identity while auditing source/rank/Break/death behavior. Same-looking names do not establish equivalent behavior. |

## Confirmed source findings and unresolved work

- Q has authored Boss damage cap (10% maximum HP) and stun multiplier (0.4).
  R has the same damage cap and refuses to move a Boss. These conflict with the
  owner's ordinary-target policy; removal is pending a separate tested repair.
- Q/W/R have no explicit server gate. Q/R do not revalidate synchronous absorb
  callbacks; W applies its debuff after damage without revalidating the victim.
  Their concrete invalidation regressions remain to be reproduced.
- E emitter checks source Break, but the existing recipient getter checks the
  recipient's Break instead of the source's state. Source/recipient/linger tests
  are required before claiming the earlier emitter-only repair covers the aura.
- D getter safety, live rank updates, illusions and removal remain under review.
- All four projectile/particle paths are listed in addon precache, but that is
  not CP/lifetime validation. Native bank is
  `soundevents/game_sounds_heroes/game_sounds_vengefulspirit.vsndevts`;
  exact event membership and cold-start precache remain to be checked.
- Shard metadata currently sits on D and Scepter on R. Native Q Shard and E
  Scepter behavior is not reproduced by those flags alone. Audit generic Aghanim
  manager effects and four-language descriptions before changing upgrades.

## Isolation work unit

Q/W/E/R/D now have explicit modules in `abilities/heroes/vengefulspirit/` with
stable IDs and a compatibility `init.lua`. Each modifier has exactly one owning
module; the shared bootstrap skips duplicate links. Q retains its existing stun call; discovery found that
`modifier_generic_stunned_lua` has no project definition/link (a further source
defect requiring repair, not a shared owner to invent during extraction). The existing safe `get_agi` helper moved unchanged into
`abilities/shared/pve_helpers.lua`; unreviewed heroes keep the same helper body.

This extraction deliberately preserves current mechanics, including the known
Boss exceptions. It is a prerequisite for focused repairs, not their closure.
No new timers, searches, effects or gameplay values are introduced by extraction.
KV ScriptFile changes require the owner's full Dota restart, not Lua hot reload.

## Acceptance gates

| Gate | Status / evidence |
| --- | --- |
| SOURCE REVIEW | PASS — five source slots, shared dependencies, installed data/resources and feasible repairs reviewed; engine-only gates remain below |
| PROVEN DEFECTS | Feasible Q/W/E/R/D source repairs implemented in focused units below; native Scepter alias compatibility remains OWNER NOT TESTED |
| ISOLATION | IMPLEMENTED — static unique-class/routes and cold bootstrap tests added |
| MOCK/REGRESSION VALIDATION | PASS — four isolation tests (Venge + Lich), unchanged five handler bodies against pre-extraction HEAD, and full `node tools/checks.mjs` (0 failed); engine verification remains separate |
| RUNTIME TRACE COVERAGE | IMPLEMENTED — Q/R cast/projectile/impact/rejection/swap, W projectile/impact/debuff, E/D modifier lifecycle and Scepter reconciliation; bounded default-off, no getter spam |
| OWNER RUNTIME TRACE EVIDENCE | NOT TESTED |
| OWNER VISUAL/AUDIO VERIFICATION | NOT TESTED |
| OWNER ENGINE ACCEPTANCE | NOT TESTED |

Remaining owner tests: cold restart and five-slot rank-up to ten; Q travel,
dodge/disjoint, stun/strong dispel and ordinary Boss result; W travel/impact and
debuff timing; aura source Break vs recipient Break and linger; R ally/enemy/Boss
movement, absorb and immunity; D Break/rank/respawn; Shard/Scepter/Blessing;
all cast/impact/ongoing resources and audio; recast/death/reconnect and dense waves.
The agent does not launch/control Dota or publish this work.

## Focused E source-ownership repair

`vengefulspirit_aura.test.mjs` reproduced the attached-recipient bug before the
repair: source Break left the base-attack bonus active. The recipient getter now
checks its actual `GetCaster()` source, including engine-owned aura linger; an
unrelated recipient Break cannot switch off an external aura. Removed/missing
source, recipient, ability and rank-zero ability yield zero without stale reads.
The prior illusion-recipient exclusion and live special-value lookup remain.
There is no new interval, thinker, particle, sound or aura-lifetime override.
MCP API confirms `CDOTA_Buff:GetCaster(): CDOTA_BaseNPC|nil` is available on both
server and client and returns the ability owner. The native E is marked Breakable.

Regression covers ordinary recipient, source Break/recovery, recipient Break,
illusion, live rank changes, rank zero, removed ability/source/recipient and
missing source. Engine aura removal/linger and actual damage output remain
PENDING OWNER TEST; no runtime or visual/audio acceptance is claimed.

## Q/R ordinary-target and callback repair

Removed Q's 10%-max-HP damage cap and 0.4 Boss stun multiplier, and R's matching
cap and Boss no-swap branch. Q remains damage + 0.9 AGI; R remains damage + 1.2
AGI on enemies only, with its existing 4s/30% defense. No Boss stats/AI/waves or
other heroes changed. `is_boss` is no longer imported by these two modules.

Q's undefined/unlinked `modifier_generic_stunned_lua` call now uses the engine
`modifier_stunned`. Evidence: project-wide definition/link search found none for
the old name; MCP reference corpus found the engine name in Aghanim's Pathfinders
2208582400 (`aghanim_summon_portals.lua:192`, `aghsfort_explosive_barrel.lua:68`).
Those snippets are API-pattern evidence only, not imported code or fresh runtime
certification. [ModDota's built-in modifier guide](https://moddota.com/abilities/reutilizing-built-in-modifiers)
documents reuse through AddNewModifier; MCP confirms that API is server-only.
Native Q metadata requests strong dispel; actual stun/status-resistance/strong
dispel behavior is still an owner engine gate, not established by the mock.

Both casts now reject client execution, invalid/dead/self targets and sources,
and revalidate after synchronous spell-block callbacks. Q rejects allies at cast
and impact; lost targets cannot receive damage/control. R revalidates after
movement and before adding its caster defense after damage callbacks.

The Q/R fixture failed before repair on the undefined stun call and now covers
equivalent ordinary/Boss formulas (Boss max HP deliberately only 100), full stun
duration, actual two-unit swap, allied swaps without damage, absorbed casts,
removed target/caster/ability during absorb, client calls, and lost/newly allied
Q projectile targets. Existing historical normal swap regressions also remain.

Shared debug-gated, rate-limited `VENGEFUL_SPIRIT_TRACE` Q/R events cover casts,
spell-block cancellation, projectile creation, cancelled impacts, requested and
returned damage, control apply result, swaps and defense. This is PARTIAL kit
trace coverage; W/E/D and actual owner trace evidence remain pending. No timer,
extra projectile, target search or duplicate cleanup exists solely for tracing.
EN/TR/RU/zh-CN Q/R descriptions now state AGI scaling, defense, ally behavior and
ordinary Boss rules. Native projectile/resource fidelity and upgrades remain open.

Validation for Q/R repair: focused Venge tests PASS; full `node tools/checks.mjs`
PASS, 0 failed. All owner runtime/visual/audio/engine gates remain NOT TESTED.

## W travel and collision restoration

Replaced instant radius scan/line damage with one engine-owned linear projectile.
Native build-6943 data supplies distance 1400, speed 2000 and width 325; width is
passed as the projectile collision radius (not halved arbitrarily). The previous
custom 140 half-width was narrower and did not match the installed native value.
Damage remains the authored ten-rank curve + 0.6 AGI. Each projectile carries its
own numeric damage/duration/armor snapshot, so a later cast or rank change cannot
overwrite an earlier traveling wave. No per-frame scan, retained cast table,
gameplay timer or manually owned duplicate particle is introduced.

VRF 19.2 decoded the installed
`particles/units/heroes/hero_vengeful/vengeful_wave_of_terror.vpcf_c` into temporary
read-only review output. Root initializer `C_INIT_VelocityFromCP` reads CP1 as
velocity; the old script gave it `direction * 1400` independently of hit timing.
Root renders `vengeful_terror_head.vmdl`, with `jaw_bite` and timed end-cap decay.
The projectile manager now owns effect creation/movement/termination, rather
than an independently released cast particle. Actual engine CP binding, child
appearance, width readability and end-cap cleanup still require owner visuals.

MCP confirms server-only `ProjectileManager:CreateLinearProjectile`. API declaration
[OnProjectileHit_ExtraData](https://docs.moddota.com/lua_server/declaration)
describes target collisions and the invalid-target destination callback.
Reference-only Aghanim's Pathfinders 2208582400
`scripts/vscripts/abilities/creatures/boss_visage_grave_chill.lua` uses the same
effect as a linear-projectile EffectName. Its source was read for the engine
pattern; no proprietary code was imported and that older kit is not evidence of
fresh acceptance in our build.

Collision applies damage once through the engine callback and checks victim,
caster, ability and team again before applying the armor debuff; lethal/deleted
victims receive no post-damage modifier. Continuing enemy hits return false;
destination terminates. Debuff is explicitly purgable with the native W icon.
Integer armor loss is stored in the engine-replicated modifier stack, so the
client property agrees with the server's cast snapshot and refresh replaces it.

Regression reproduced the old separate fake particle before repair, then covers
no cast-time damage/search, zero aim facing, native speed/distance/width,
independent recasts, Boss ordinary damage, lethal/removed/allied impacts,
destination, removed source, client cast and armor snapshot/refresh client values.
The historical zero-aim fixture now drives a projectile collision instead of
asserting the old instant-hit behavior; unrelated contributor cases are preserved.
W tracing covers projectile creation/finish, damage and modifier apply/refresh/
removal, through the same bounded debug flag. Four-language descriptions reflect
the new timing and values.

This closes the travel/impact defect only. Native attack reduction, trailing
vision, recipient VFX, cast animation, sound-bank ownership and upgrades remain
open; they are not silently certified or substituted with generic effects.
Owner runtime/visual/audio/engine: NOT TESTED.

## D source safety and E/D lifecycle diagnostics

D remains the authored Enfos REPLACE passive, with ten ranks of 20–38 AGI and
25–52 attack speed. Before repair, its getters queried removed parents and could
grant values with no parent or an unlearned ability. The focused fixture failed
on rank-zero bonus leakage before implementation. Both getters now use one
local source/rank gate; missing/removed source or ability, rank zero, Break and
illusion sources grant zero. Values remain live on valid rank changes; no cache,
periodic thinker, stat mutation or rank auto-grant is added.

E emitter, E recipient and D now trace only actual modifier creation, refresh
and removal through the existing shared default-off rate limiter. Disabled
tracing reads no diagnostic properties; ordinary stat getters never log. The
trace fixture verifies silence by default, exactly nine lifecycle records when
enabled, and no additional records after 100 repeated E/D stat queries.
All five base slots now have diagnostic coverage, but the full kit remains
PARTIAL while upgrades, unresolved native features and their branches are open.
Lifecycle records do not establish Break/dispel/death correctness by themselves.

Native icon identity comes from the already verified production/native command
aura texture. E/D explicit modifier textures now use that resource. Four-language
ability descriptions include radius/source Break and D illusion rules; recipient
modifier names/descriptions use declared live modifier properties rather than
hard-coded stats. [ModDota tooltip property documentation](https://moddota.com/abilities/modifier-properties-in-tooltips)
documents that substitution format and its client-side requirements. MCP confirms
OnRefresh runs on both sides; diagnostic helper suppresses client output.
Actual client tooltip rendering and passive respawn/reconnect remain owner gates.

Remaining source work includes native W attack reduction/vision and recipient
presentation, Q/R resource/animation/immunity review, E aura emitter rank policy,
and dedicated Shard/Scepter behavior. Do not advance to Jakiro or certify this
hero merely because the source-safety fixtures pass.

## Native animation and sound-bank restoration

Re-read installed native hero AbilityDefinitions (build 6943) and decoded its
declared `game_sounds_vengefulspirit.vsndevts_c` with VRF 19.2. Decoded-bank SHA256:
`759f19cfa71de6ee5559c66ae6383cddd6bbbe31deb208f060625fccb9593480`.
Verified membership: `Hero_VengefulSpirit.MagicMissile`, `MagicMissileImpact`,
`WaveOfTerror`, `NetherSwap`, all under that prefix. Their durations are finite
(1.23102s, 1.835125s, 4.821338s, 2.157959s); no looping event was introduced.
Existing cast/impact emitters remain; the R two-endpoint emission is preserved
pending owner listening, not asserted acoustically correct from declarations.

The startup bank loop did not include Vengeful Spirit and all three custom
actives omitted AbilityCastAnimation. Added the native bank to the existing
precache owner and the installed ACT_DOTA_CAST_ABILITY_1 / 2 / 4 for Q/W/R.
No new precache service, duplicate gesture or passive cast animation was added.
KV cast points and rank/mana/cooldown curves remain unchanged in this unit.

Q now reads native `magic_missile_speed` 1350 from KV, replacing the unexplained
1250 literal; its targeting, damage/scaling and stun curves are preserved.
The presentation fixture failed on missing animation before repair and now
checks all three mappings, the actual startup bank loop and native speed KV;
Q cast fixture also asserts the projectile receives that speed.
[ModDota Ability KV documentation](https://moddota.com/abilities/ability-keyvalues)
documents the animation field and asset preload requirement. Those declarations
support implementation, not visual/audio acceptance.

Native particle CP/attachment/impact presentation, cold-start playback, gesture
appearance and audible timing remain PENDING OWNER TEST. Source review remains
PENDING for upgrades, W native attack reduction/vision and immunity interactions.

## Q Shard: native one-bounce restoration

Installed build 6943 hero KV and `resource/localization/abilities_english.txt`
(Q Shard token near line 1403) specify one bounce, enemy hero priority and
`bounce_range_pct` 75% of current cast range from the first impact. Native
localization identifies `modifier_item_aghanims_shard_permanent_buff` as the
consumed item modifier. MCP confirms server `GetEffectiveCastRange` includes
modifiers. Native C++ is unavailable; this is a custom implementation of the
documented behavior, not certification of identical engine semantics.

Previous Q had no bounce; D advertised a generic +25% outgoing-heal upgrade
despite having no healing mechanic. Q now owns HasShardUpgrade and the native
percentage value; D's flag and misleading four-language description are removed.
Permanent Shard detection and removal of unrelated Support heal amplification
are scoped to Venge (and preserve the earlier Lich exception). Other Support
heroes retain their existing behavior pending their individual audits.

Cast captures a single numeric bounce entitlement in projectile ExtraData.
First impact saves its position before damage, so a lethal hit can still bounce.
One radius search prioritizes a valid enemy hero over a closer basic unit,
excludes the first target, and starts a dodgeable second missile from the impact
position. Its remaining count is zero; no chain table, timer or global scan is
retained. Losing Shard after launch does not revoke that projectile entitlement;
damage/stun still use the existing live impact values. A lost/disjointed first
target cancels the chain. Existing caster-death and spell-block behavior is
preserved for the dedicated immunity/death-semantics review, not asserted native.

Baseline fixture reproduces missing entitlement. Repaired fixture covers native
consumed Shard, modified 900 range -> 675 search radius, hero priority, lethal
first impact, one-bounce limit, disjoint, no-Shard cast and unchanged unreviewed
Support healing behavior. Four languages and all localization mirrors include
the actual Q upgrade. Source fixtures are PASS; real Shard consumption, flight
origin/impact visuals, effective-range behavior, target immunity/absorb and
client tooltip rendering remain PENDING OWNER TEST. Scepter, W native attack
reduction/vision/recipient presentation and E emitter rank gate remain open;
do not advance to Jakiro or mark this hero DONE yet.

## W missing attack reduction restoration

Re-read installed hero AbilityDefinitions (build 6943) and native English tokens
1408/1411/1455: W reduces total attack damage as well as armor. Native ranks are
10/15/20/25%; native recipient localization explicitly uses
`MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE`, not base-damage-only reduction.
Our W only declared physical armor and never captured attack reduction. This is
a confirmed omission, not a Boss balance branch. W remains TUNE.

Added native first-four-rank attack reduction, held at 25% for ranks 5–10 rather
than extrapolating stronger suppression without balance evidence. Existing
10-rank damage, Agility scaling, armor, travel and duration remain unchanged.
Projectile captures attack reduction at cast and passes it only to a surviving,
valid hostile collision target. The existing armor stack snapshot is retained;
the second numeric property uses the engine custom transmitter on creation and
refresh. No polling timer, stat-getter log, global scan or added particle exists.
The native modifier property applies ordinary engine rules to normal units and
Bosses alike. Negative getter output is deliberate; four-language modifier
tooltips display the actual signed property, with spell descriptions listing
positive reduction amounts.

[ModDota's transmitter guide](https://moddota.com/abilities/server-to-client)
documents multiple-field replication; current MCP confirms
`CDOTA_Modifier_Lua:SetHasCustomTransmitterData` and
`CDOTA_Buff:SendBuffRefreshToClients`. Initial lookup under CDOTA_Buff failed;
the correct Lua modifier class resolves. Indexed Boss Survival Adventure reference
search found native-named ability mappings, but no code was imported and these
mappings do not establish runtime correctness or licensed implementation reuse.

The updated wave fixture fails on the pre-fix module's missing cast snapshot.
Repaired tests cover independent recasts/rank changes, normal Boss collision,
lethal-target cleanup, transmitted client values (15 -> 25), refresh and no
client authoritative mutation. Native projectile path/audio/animation remain
as previously verified. Native vision trail and recipient particle binding are
still OPEN. Actual attack reduction against base+bonus attack damage, dispel,
immunity, tooltip sign/rendering and refresh replication remain PENDING OWNER
DOTA/VCONSOLE TEST; no mock proves those engine gates.

## E emitter rank gate and native self bonus

Installed build-6943 command-aura KV has `self_multiplier` 25; native English
description at line 1417 says Venge receives extra benefit herself. The custom
getter previously gave the same value to source and allies. Restored the native
relative self benefit: aura 15% gives its source 18.75%, not 40%. Allies retain
their existing ten-rank base-damage curve/radius; Scepter's extra multiplier and
strong illusion are still a separate outstanding upgrade unit. E remains TUNE.

The recipient rank-zero guard already prevented actual stat gain, but IsAura
and radius had no corresponding learned-ability gate. A valid rank-zero emitter
could create empty recipient modifiers. IsAura now requires a valid trained
ability, with zero radius for missing/removed/unlearned ability, and still uses
source Break. No new tick, aura manager, modifier, particles or source-death
override is introduced. Engine aura duration/death defaults remain unchanged.
Client/server stat getters use the same live ability values; no new transmission
is needed for this bonus. Existing illusion-recipient exclusion remains for its
later native/Scepter audit, not asserted native from this patch.

Baseline fixture reproduces rank-zero emission. Focused E tests now cover emitter
rank zero/rank one, removed ability, Break, live rank updates, self vs unrelated
recipient, relative (not flat) multiplier and lingering invalid recipients.
The historical Break fixture now supplies a learned ability as the engine does;
contributor Lich tests remain outside this commit. Four-language descriptions
and mirrors disclose the self benefit and learned-rank rule. The public
[ModDota API reference](https://docs.moddota.com/lua_server/) documents GetLevel,
IsAura and GetAuraRadius; installed native KV/localization supplies the gameplay
evidence. Real self/ally damage, rank-up/respawn/reconnect and aura presentation
remain PENDING OWNER DOTA/VCONSOLE TEST. Scepter, W vision/VFX and Q/R immunity
semantics remain open; this unit does not close the hero review.

## W native recipient root and temporary path vision

Installed native W values are vision_aoe 350 and vision_duration 4 (build 6943).
Our projectile explicitly disabled vision and had no FOW callback. It now uses
engine projectile vision for its caster team, plus temporary viewers along the
actual OnProjectileThink_ExtraData path and final nil-target location. Radius,
duration and team are numeric cast snapshots; no future path is revealed at cast.
Caster death does not change the recorded team or cancel an otherwise existing
wave. AddFOWViewer expires viewers in the engine; there is no retained Lua cast
table, timer, dummy unit, world/entity scan or per-think diagnostic output.
Viewer creation runs at engine projectile callback frequency for the finite
1400/2000 travel, not an independent indefinite loop. Dense recasts/FOW cost are
an owner performance gate. `obstructedVision=false` selects unobstructed path
vision; terrain/obstruction parity needs owner comparison, not a native C++ claim.

MCP resolves `ProjectileManager:CreateLinearProjectile`,
`CDOTA_Ability_Lua:OnProjectileThink_ExtraData` and AddFOWViewer. Initial lookup
under CProjectileManager failed; API search resolved the correct owner.
[ModDota projectile documentation](https://moddota.com/scripting/particle-attachment)
confirms vision fields; no external implementation was imported.

VPK confirms recipient root plus _b/_c/_reduction children. VRF-decoded root
SHA256 is `c02070c4d625ec59762cd02bb5f02195952570421976634e811195202baff701`.
Root emits one terror-head model, jaw_bite sequence, finite 1.5-second particle,
PositionLock and Decay. It internally drives CP1 from its particle for _b; its
reduction child has continuous emission and endcap decay. Bind the full root
through modifier GetEffectName / PATTACH_ABSORIGIN_FOLLOW so parent-origin CP0
follows the victim and child CP1 retains its native internal driver. Do not
manually overwrite CP1 or create a duplicate free particle. The modifier/engine
owns cleanup on expiry, dispel and death. Added root to existing startup precache;
children/model remain native dependencies, not copied custom assets.

Updated fixture reproduces missing vision before repair and verifies caster team,
350/4 snapshots despite later rank values, client/malformed callback suppression,
root identity/attachment and startup precache. Four languages disclose path
vision. Source bindings are implemented; actual cold-start head/swirl appearance,
refresh/expiry/purge cleanup, FOW trail duration, terrain behavior and dense-wave
performance remain PENDING OWNER DOTA/VCONSOLE TEST. Q/R immunity/death semantics
and dedicated Scepter remain source-open; this is not whole-hero completion.

## Native dispel/immunity metadata and R channel interruption

Installed build-6943 KV explicitly declares Q/W non-piercing enemy immunity,
Q strong dispel, W basic dispel, and R enemy immunity piercing/basic dispel.
Those fields were absent from the custom actives. Added the same metadata,
without custom IsMagicImmune early returns, Boss exceptions or damage flags.
[ModDota KV documentation](https://moddota.com/abilities/ability-keyvalues)
describes those exposed fields; ability_lua/builtin-stun/modifier behavior still
requires the owner immunity/dispel test, not certification from metadata alone.

Native English Nether Swap Note2 (line 1434) explicitly says channeling spells
are interrupted. Custom R moved units but never called Interrupt. After valid
target/absorb validation it now interrupts the target, then revalidates caster,
target and ability before any swap effects, movement or damage. MCP confirms
server `CDOTA_BaseNPC:Interrupt`. Channel-end callbacks can synchronously remove
entities; regression covers target, caster and ability invalidation there.
Allies, normal hostile units and Bosses use the same interruption path. Rejected
or spell-blocked casts never interrupt. Added native R modifier icon and explicit
basic purgeability for the existing authored 4-second/30% defense; its numbers
are not claimed to be current Dota's zero-valued reduction mechanic.

Baseline fixture reproduces no target interruption. Repaired fixture checks
exactly one interruption for valid swaps and no subsequent feedback/gameplay
after callback invalidation. Historical R mock now supplies Interrupt as the
engine does, without including contributor Lich edits. Native metadata is
asserted against installed values. Four languages disclose interruption and
defense modifier properties. No new thinker, particle, timer or manager is added.

Q cast-time absorption and caster-death cancellation remain source-open: native
C++ is unavailable and reference searches did not provide current authoritative
timing evidence. Do not silently move absorption or retain a dead-caster change
based on intuition. R tree clearing radius/native target filtering and native
CP/attachment fidelity also remain review leads. Actual channel cancellation,
BKB/debuff immunity, strong/basic purge and modifier rendering require owner
Dota/VConsole evidence; Scepter remains outstanding.

## E Scepter: native lifecycle delegation, not engine certification

Installed native `scripts/npc/heroes/npc_dota_hero_vengefulspirit.txt`, build
6943 / SourceRevision 11069754, places Scepter on `vengefulspirit_command_aura`.
It adds 10 to native self_multiplier 25 and declares illusion outgoing/incoming
100%, movement bonus 0. Native English ability token at line 1418 describes
strong illusion on death, all spells, XP transfer to hero and hero replacing
the surviving illusion on respawn. The previous generic R +40% spell damage /
25% cooldown bonus did none of this. Classification remains E TUNE, R TUNE.

[ModDota's native BaseClass documentation](https://moddota.com/abilities/ability-keyvalues)
permits native ability inheritance but explicitly says internal C++ structure
is inaccessible. MCP confirms `CDOTA_BaseNPC:IsStrongIllusion()` on both realms.
No current exact alias reference was found. Therefore this is an owner-test
candidate implementation, not a proven native C++ compatibility result.

Slot 6 now holds hidden/not-learnable rank-one `enfos_vs_scepter_native`, native
BaseClass `vengefulspirit_command_aura`. Its aura damage and radius are zero;
only the engine owns death illusion, XP and respawn lifecycle. No guessed hybrid
modifier ID, new Lua illusion manager, death event, thinker, summon loop or
world scan. Existing Aghanim periodic reconciliation and E rank-up reconcile
rank 1 iff E is learned and Scepter is held/consumed; otherwise rank 0. Handles
missing slot idempotently and revalidates synchronous rank-change callbacks.
Five spendable ten-rank skills/level-50 point budget remain unchanged.

Custom E adds the native relative self benefit: base aura 20 becomes 25 without
Scepter and 27 with Scepter, while allied recipients retain 20. Only its own
strong illusion may receive copied self aura; ordinary illusion recipients
remain excluded, source Break still suppresses it. D's illusion exclusion stays
to avoid double copied AGI/AS. Venge generic Scepter modifier is hidden and its
ultimate spell amp/CDR return 0; other heroes' policy is untouched. Ascended
Blessing source already adds native `modifier_item_ultimate_scepter_consumed`,
alongside its stats modifier, supporting the native HasScepter path in source.

Focused regression validates bridge rank/hidden state, repeated reconciliation,
loss/regain, E rank zero/ten, missing AddAbility, client/removed handles,
rank-callback invalidation, existing manager restoration without duplicated
upgrade modifiers, consumed Blessing detection, self/ally/strong-illusion/Break
arithmetic, E OnUpgrade and preserved other-hero generic bonuses. KV contract
validates native BaseClass, rank one, hidden slot and zero duplicate aura damage.
Four languages move Scepter description to E and localize the hidden ability.
Fixtures do NOT simulate or certify native death/XP/respawn.

**Owner NOT TESTED / release gate:** native alias must actually generate exactly
one controllable strong illusion on death with Scepter/Blessing; copied custom
Q/W/E/R ten-rank values and resources must work; XP transfer, repeated deaths,
respawn replacement, illusion expiry/death, dropped Scepter and reconnect must
not duplicate/retain stale units or bonuses. Verify rank-zero deactivation,
zero-radius native aura feedback, engine IsStrongIllusion flag, client self
multiplier, HUD hidden slot and cold resource loading/VConsole. Existing roster
unit/sound/explicit custom particle precache is present, but native alias's
implicit hybrid resources are not proven by static inspection. If alias is
incompatible, retain a documented unresolved engine gate and choose an evidenced
alternative; do not conceal failure with a broad replacement summon service.
Q timing and R tree/target/CP leads remain open. No owner runtime evidence yet.

## R model-bound particle repair

Build-6943 decoded native roots `vengeful_nether_swap.vpcf` and `_target.vpcf`
use `C_INIT_CreateOnModel`, CP1 `C_OP_MoveToHitbox` and `C_OP_LockToBone`;
`m_bShouldHitboxesFallbackToRenderBounds=false`. Custom roots used nil owners
at PATTACH_WORLDORIGIN and static vector CP1, providing no required model/bone
binding. Root decoded SHA256: 64fa6d5945a98145ac52e90a9e72700c77a3f499dede0e3de61d901a576763d7;
target: 59a19464f0b15bc4416f5146cc9ae7a9f30e6eca086ec3a4ba4a42883a7e143d.
Both emit instantaneous particles with .35–.6s lifetimes and decay. Children
`_b` are instantaneous; `_c`, `_blue`, `_pink` continuous emitters explicitly
stop after .2s and include decay. Existing startup precaches both roots.

LICENSED_REUSE import inventory: adapted the two root/CP1/release wiring
patterns from ModDota/ValveExamples, commit
`9a438c475a8b2c3d0df9dc2de2f99a8471037174`,
`game/lua_ability_example/scripts/vscripts/vengefulspirit_nether_swap_lua.lua`
lines 74–79. [Pinned source](https://github.com/ModDota/ValveExamples/blob/9a438c475a8b2c3d0df9dc2de2f99a8471037174/game/lua_ability_example/scripts/vscripts/vengefulspirit_nether_swap_lua.lua).
MIT, Copyright (c) 2016 ModDota; full notice is embedded in production R Lua
and retained at `docs/reference-analysis/licenses/ValveExamples-MIT.txt`.
Permissive distribution is compatible, preserving notices. Imported scope is
API particle wiring only: no assets, helper libraries, target restrictions,
old Scepter behavior, trees or channel gesture copied. Native Valve resources
stay references to the installed Dota archive; MIT does not license those assets.

MCP verifies SetParticleControlEnt's both-realm entity/attachment/offset API.
Our adaptation binds caster-owned root CP1 to target and target-owned root CP1
to caster with PATTACH_ABSORIGIN_FOLLOW, empty attachment and current position.
Creation follows both clear-space placements and revalidation. Invalid placement
callbacks therefore cannot bind removed models. Each root index is released
once; native finite particle definitions own lifetime, no Lua timers or retained
handles. Existing swap formula, interruption, target policy and defense remain.

Independent fixture performs 20 casts, checks model owners, opposite CP1 entity,
attachment, fresh post-placement offset, 40 creations/bindings/releases and
no change to swap positions. A clear-space callback invalidating target creates
no roots. Ordinary/Boss/ally/absorb/interruption regression still passes. Fixture
validates Lua wiring/ownership only, not renderer behavior. Owner NOT TESTED:
both colored model-transfer effects, cold child/material loading, consecutive
casts, death during finite effect and actual particle/performance/VConsole.
Q timing and R tree radius/custom target semantics remain open source leads.

### Q pre-implementation timing decision (TUNE)

Pinned ValveExamples `vengefulspirit_magic_missile_lua.lua` at
9a438c475a8b2c3d0df9dc2de2f99a8471037174 checks TriggerSpellAbsorb at projectile
impact and declares ATTACK_2 source attachment. Current custom Q consumes spell
block before launch and never checks a block acquired during flight; its Shard
secondary target never receives an absorption check. Installed build-6943 KV
confirms the native projectile ID/speed but does not expose internal absorption
timing. Adopt the supported impact-check pattern for our custom Q, with safe
callback revalidation and bounded secondary impact handling; do not claim this
as proof of current C++ parity. Keep the existing caster-death policy pending
owner/native timing evidence; do not silently change it in this fix. Native
post-7.33 immunity semantics are not copied from the old example's IsMagicImmune
early return. No author-defined Boss exception. No external code imported for
this timing change; our guarded implementation is written independently from
the documented behavior. Actual spell block during flight and Shard interactions
remain owner engine acceptance gates.

### Q implementation and regression receipt

The launch path no longer consumes spell block. Each valid impact now calls
TriggerSpellAbsorb before origin reads, stun, damage, impact audio or Shard
bounce. A non-absorbing callback is followed by source/target/ability/team
revalidation. Absorbed primary impacts do not bounce; secondary impacts receive
their own check and cannot cause another bounce. Caster alive checks remain
unchanged; this receipt does not resolve the earlier dead-caster parity lead.
Initial projectile source uses DOTA_PROJECTILE_ATTACHMENT_ATTACK_2; the MCP
DOTAProjectileAttachment_t enum confirms member value 2. Native installed hero
showcase metadata exposes attach_attack2 and the pinned Valve example uses the
same source attachment. Secondary projectile retains its explicit impact origin.

An independent fixture reproduces old pre-flight block consumption, then checks
new no-launch-consumption behavior, late/expired block, blocked secondary,
disjoint, callback-removed source/target/ability, callback team change and the
unchanged dead-source cancellation. It checks exact damage/stun/impact-feedback
and bounded search/projectile counts. Existing ordinary/Boss/ally Q/R fixture
now distinguishes launch feedback from rejected-impact feedback. Shard lethal
hit regression remains. Four language descriptions expose impact-time blocking.
No new manager, timer, entity table, global scan, damage formula or Boss policy.

Owner NOT TESTED: real Linken/Counterspell interaction while projectile travels,
secondary absorption, engine source attachment, native compare for caster death,
and actual post-7.33 debuff immunity. Old Valve example's IsMagicImmune return is
deliberately not transplanted. Target immunity/reflect/bounce interactions still
require real Dota/VConsole evidence; mocks certify only authored flow boundaries.

### R pre-implementation tree/target decision (TUNE)

Installed English Nether Swap Note1 explicitly states nearby trees are destroyed;
our R never calls GridNav, so placement can be displaced by trees. The pinned
MIT Valve example clears both origins within 300 before placement. Use an
authored configurable 300-radius tree clearance, independently implemented and
documented as a supported reference value, not a claim that current closed C++
uses exactly 300. No change to map geometry or general pathing. Revalidate tree
callbacks before another operation or placement.

Reject self-target before spending the cast, then delegate ordinary hero/basic,
both-team unit filtering to UnitFilter using the ability's own KV. Explicit
MAGIC_IMMUNE_ENEMIES target flag matches native R immunity piercing. Keep PvE
creeps/Bosses eligible under the existing hero/basic policy; do not transplant
the old example's Scepter-required creep restriction or Ancient exclusion.
This restores cast UX without inventing a Boss exception. Current native
CUSTOM target C++ semantics and exact radius remain owner comparison gates.

### R implementation and terrain regression receipt

Added both-realm CastFilterResultTarget: self/missing/removed handles fail custom,
other units delegate to native UnitFilter and retain its rejection code. The
ability's team/type/flags come from KV, with native-piercing enemy immunity flag.
Built-in self-target error key comes from the pinned primary example; invalid
custom target key is provided in all four locales. This custom PvE target policy
allows ordinary basic units/Bosses independently of Scepter; native CUSTOM's
closed exact restrictions are not claimed to be reproduced.

R clears trees at both saved origins before placement, through verified server
GridNav:DestroyTreesAroundPoint(position,300,false), then revalidates caster,
target and ability after each tree operation. Radius is data-driven and unchanged
by target identity. No world scan, map rewrite, global pathing flag or new timer.
New diagnostic records two cleared origins/radius under existing bounded switch.
The engine owns tree-regrowth behavior; no Lua tree restoration service added.

Focused fixture checks self/missing target rejection without delegating, forwarded
native rejection, client filtering, exact KV inputs and clearance-before-movement
for normal/Boss/ally targets. Blocked/client casts clear no trees; a tree callback
removing caster/target/ability prevents subsequent clears, movement or particles.
All-200 and historical mock fixtures now provide the real GridNav API surface;
those stubs are not map/pathing simulation. No contributor Lich changes included.

Owner NOT TESTED: self cast rejected without mana/cooldown, target filter against
real immunity/invulnerability/buildings/basic-unit categories, tree geometry and
regrowth, legal clear-space landing near walls/cliffs and normal/Boss swaps.
Explicitly compare authored 300 radius to native behavior when runtime evidence
is available. Existing 4s/30% defense is authored tuning, not a claim of current
native barrier parity (installed English describes a damage-sized barrier while
KV's reduction special is zero). Q caster-death parity and upgrade alias remain
engine gates; passive modifier dispel/death behavior still needs source review.

### E/D pre-implementation passive lifecycle decision

Custom E emitter, E recipient and D intrinsic declare no dispel/death policy.
Do not claim missing overrides prove a runtime purge bug: engine defaults and
intrinsic restoration have not been observed. Harden the authored passive
contract explicitly: emitter is hidden, D and recipient stay visible with
existing localized modifier tooltips; E/D intrinsic modifiers are retained on
death and non-dispellable, E emits no aura while dead, recipient buff is
non-dispellable and removed when its recipient dies. Engine aura distance/linger
and native strong-illusion owner remain unchanged; no respawn timer or manual
duplicate intrinsic application. Break still suppresses getters/emission rather
than destroying permanent skill ownership. E TUNE / D REPLACE classifications
remain unchanged.

Primary callback declarations confirm IsHidden, IsPurgable, IsPurgeException,
RemoveOnDeath and IsAuraActiveOnDeath semantics:
[TypeScriptToLua modifier declarations](https://github.com/TypeScriptToLua/Dota2Declarations/blob/master/dota-modifier-properties.d.ts).
The pinned Valve aura example hides its emitter, but includes obsolete negative
death aura mechanics absent from this installed build; those are not imported.
Native Retribution KV is non-dispellable. Our authored AGI/AS replacement is not
claimed to equal its native nemesis damage mechanic. These explicit policy
overrides require actual purge/death/respawn validation, not fake mock purge.

## Current source-review closure matrix

Source review PASS means the authored implementation and resource contracts were
individually inspected and feasible source defects repaired. It is NOT whole-kit
DONE or engine acceptance. All OWNER RUNTIME / VISUAL-AUDIO / ENGINE statuses
remain NOT TESTED. Historical discovery and old blanket classifications above
and in the seeded dossier are superseded by this matrix and focused receipts.

| Slot | Current authored contract / evidence | Engine-only acceptance still required |
| --- | --- | --- |
| Q TUNE | 10 ranks; native speed 1350 and ATTACK_2; dodgeable tracking missile, damage +0.9 AGI, builtin stun/strong dispel metadata; impact absorption/revalidation; one bounded hero-prioritized Shard bounce; ordinary Boss formula. Native particle/bank/ACT1 preload and finite tracking owner inspected. | Actual damage/stun/status resistance/debuff immunity/reflect/disjoint, caster-death cancellation comparison, real Linken and Shard interactions, attachment/audio/cold precache. |
| W TUNE | 10 ranks; numeric cast snapshots, engine linear projectile 2000/1400/325; damage +0.6 AGI, armor and attack debuff; replicated modifier values, native recipient root, 350/4s path FOW; source/target invalidation; basic purge metadata and ACT2. No cast-state tables/timers/global unit scan. | Engine status resistance/dispel/immunity, recipient visuals/child loading, terrain vision parity and dense-wave viewer cost; real hit timings and multi-source refresh behavior. |
| E TUNE | 10 ranks, source-owned learned aura 15–36%, 900–1350; self-relative multiplier 25% (+10 Scepter); Break/source/recipient/illusion guards; hidden retained non-dispellable emitter, no death emission, visible non-dispellable recipient; E upgrades reconcile hidden rank-one native lifecycle bridge. | Native alias death illusion/XP/respawn/strong flag/copied spells and ranks, actual client self multiplier/Scepter loss, aura linger/death/purge/reconnect and cold hybrid resources. |
| R TUNE | 10 ranks with level5/interval5 gates; both-team hero/basic filter rejects self, immunity-piercing KV; target interruption/callback checks, tree clearance300, clear-space placement, model-bound opposite CP1 finite roots; enemy damage +1.2 AGI; authored 4s/30% defense, no generic Scepter. | Actual target categories/immunity/absorb/dispel, landing near walls/cliffs, tree/regrowth and current native radius/filter comparison, effect/color/audio and repeated deaths/reconnect. Authored defense intentionally differs from native barrier. |
| D REPLACE | 10-rank Enfos passive, +20–38 AGI/+25–52 AS; learned live getters, source Break/illusion/null safety; visible retained non-dispellable intrinsic with localized dynamic properties; no generic Support Shard heal. No timers, particles or sound warranted for stat-only passive. | Actual rank/free-rank/point HUD, native intrinsic retention/recreation without duplicate stats, Break/strong dispel/death/reincarnation/reconnect and illusion stat-copy behavior. |

Shared dependencies inspected: pve_helpers value/AGI/damage only (no reviewed
Boss helper dependency), current Aghanim manager and Blessing consumed modifiers,
unique modifier/KV routes, existing startup hero/resource precache, HeroTrace
bounded default-off helper and four-locale generated mirrors. No account storage,
talents or permanent progression introduced. No boss-owned state/AI/waves changed.
Native ten-rank + AGI formulas were not proven in closed C++; focused custom
handlers are retained, with supported engine projectiles/stun/placement/aura
lifetimes and explicitly pending rank-one native Scepter alias.

Passive policy tests verify authored callback returns together with existing
Break/rank/removed-source arithmetic and silent/default-off lifecycle traces.
They do not mock Purge or pretend to run engine death restoration. Localized
recipient and D tooltips now disclose non-dispellability. Intrinsic retention and
IsAuraActiveOnDeath use the engine lifecycle, never an added respawn manager.
Feasible source units are ready for owner tests; next individual source review
is Jakiro. Contributor Lich E work remains separate and uncommitted by this agent.
