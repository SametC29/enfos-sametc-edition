# Vengeful Spirit individual review — reverse roster, 2026-10-03

Second hero after Lich under [the owner goal](HERO_INDIVIDUAL_AUDIT_GOAL_2026-10-03.md).
This is an active findings ledger, not acceptance of the kit. Historical blanket
PVE-CONVERT classifications in the dossier are superseded by the decisions below.

## Evidence and native-first decisions

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
| SOURCE REVIEW | PENDING — all five initial handlers read; defects/upgrades/resources still open |
| PROVEN DEFECTS | E source ownership and Q/R ordinary-target/callback repairs implemented; W/upgrades/resources remain unresolved |
| ISOLATION | IMPLEMENTED — static unique-class/routes and cold bootstrap tests added |
| MOCK/REGRESSION VALIDATION | PASS — four isolation tests (Venge + Lich), unchanged five handler bodies against pre-extraction HEAD, and full `node tools/checks.mjs` (0 failed); engine verification remains separate |
| RUNTIME TRACE COVERAGE | PARTIAL — Q/R instrumented through shared bounded default-off helper; W/E/D lifecycle coverage pending |
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
