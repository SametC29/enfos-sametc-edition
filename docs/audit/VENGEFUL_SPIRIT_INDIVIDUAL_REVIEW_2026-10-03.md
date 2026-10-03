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
| PROVEN DEFECTS | unresolved — source findings above, focused reproductions/repairs queued |
| ISOLATION | IMPLEMENTED — static unique-class/routes and cold bootstrap tests added |
| MOCK/REGRESSION VALIDATION | PASS — four isolation tests (Venge + Lich), unchanged five handler bodies against pre-extraction HEAD, and full `node tools/checks.mjs` (0 failed); engine verification remains separate |
| RUNTIME TRACE COVERAGE | MISSING — shared bounded default-off helper exists; this kit needs slot instrumentation |
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
