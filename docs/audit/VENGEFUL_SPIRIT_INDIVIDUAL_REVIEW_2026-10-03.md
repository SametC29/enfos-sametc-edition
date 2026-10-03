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
