# Tidehunter native-first source migration

Status: DISCOVERY / IMPLEMENTATION PENDING / OWNER_RUNTIME PENDING.
This record supersedes the old PvE-conversion assumption for the migration
plan, not the existing production implementation or its proven source fixes.
The owner permits proceeding to the next source hero without live acceptance.

## Evidence and boundary

Installed Dota: ClientVersion/ServerVersion6943, SourceRevision11069754,
Oct01 2026. The exact hero file SHA256 remains
`8c96be768e85e8d845bc6ef04f99ad261c0f9bd5c0e45503aedb6ab4c5c78cda`.
[Snapshot](TIDEHUNTER_NATIVE_SOURCE_2026-10-04.json) records all eight native
ability definitions, installed English descriptions, exact source hashes,
hero assignments and queried API availability. The unchanged hero hash does
not establish engine compatibility or acceptance.

Current implementation: five Lua abilities in `abilities/pve_kits.lua` with
stable `enfos_tide_*` IDs and ten ranks. The native header explicitly assigns
Gush, Kraken Shell, Anchor Smash, Dead in the Water, Ravage and Leviathan's
Catch. Arm of the Deep and Blubber also have definitions; definition presence
alone does not establish automatic grant or an additional innate requirement.
Both historical facets are deprecated. Do not introduce talents/facet grants.

Native aliasing follows the documented exposed-variable pattern in
[ModDota Ability KeyValues](https://moddota.com/abilities/ability-keyvalues).
That pattern cannot rewrite internal C++ relationships. The successful source
patterns for Luna/Slark are integration references, not proof for Tidehunter.
Prior Pathfinders2208582400 Gush reference uses custom Lua and an older1600
projectile speed; installed2500 takes precedence. No external code is imported.

## Five-slot decisions before implementation

These are migration decisions/leads; no row below claims migration delivered.

| Slot / stable ID | Current behavior | Verified native counterpart | Primary class | Intended ownership / reason |
| --- | --- | --- | --- | --- |
| Q `enfos_tide_gush` | Authored tracking projectile, damage + STR, armor/slow; bespoke Scepter linear wave | `tidehunter_gush` | TUNE | Native alias owns targeting, projectile, block/reflect, effects and Scepter. Authored ten-rank curves and minimal STR damage bridge; creep targets already supported natively. |
| W `enfos_tide_kraken_shell` | Passive block + STR, flat regen, custom damage counter/purge and reactive Shard smash | `tidehunter_kraken_shell` | TUNE | Native active/passive shell with numeric tuning. Flat regen is an explicit Enfos extension. Establish native cleanse ownership before retiring the custom counter; no duplicate Blubber/purge. Shard conversion remains a separate evidence item. |
| E `enfos_tide_anchor_smash` | Fixed400 radius; average attack + bonus + STR through flat physical damage; custom debuff | `tidehunter_anchor_smash` | TUNE | Native attacks and native attack-range-plus-additional-range geometry. Tune native bonus damage/reduction with STR bridge. Items, attack procs, attack immunity and native effects belong to engine. |
| R `enfos_tide_ravage` | Five custom timed damage bands and stun, STR scaling, one-second boss stun cap | `tidehunter_ravage` | TUNE | Native expanding Ravage, damage/stun/effects and ordinary engine immunity/resistance. Preserve authored rank/cost curves where exposed. Direct native AbilityDamage read-path must be established before claiming STR scaling. |
| D `enfos_tide_colossal_presence` | Authored self HP/armor plus enemy slow/damage aura | `tidehunter_leviathans_catch` | PVE-CONVERT (provisional) | Native fish passive is meaningful through free fish on even hero levels; hero-kill fish alone loses value against waves. Research native provider, rank bridge and bounded creep component before choosing minimal extension. Do not discard it merely because the existing aura is simpler. Production D stays unchanged during this discovery gate. |

D's provisional class is a research lead, not authorization for a guessed fish
entity/modifier or a fully custom replacement. Resolve it before touching D.
Retain fifth-slot free rank, ten total ranks, match-only progression and the
existing shared restore service. Hidden native providers must not consume points,
duplicate free ranks, or create permanent account state.

## Confirmed differences and migration contracts

Q native fields are `gush_damage`, `projectile_speed`, signed `movement_speed`,
positive `negative_armor`, top-level `AbilityDuration`, and Scepter
`speed_scepter`, `aoe_scepter`, `cooldown_scepter`, `cast_range_scepter`.
Current custom `slow_pct`, `armor_reduction`, `duration` and `scepter_*` names
cannot simply be carried into a native alias. Ordinary native range700 differs
from current750. Native Scepter cooldown7 also differs from the custom
`min(authored cooldown,7)` at late ranks. Record the chosen tuning and update all
four languages before changing these balances. Native effects/animation are
engine-owned; no parallel Lua projectile or debuff should remain after conversion.

W's native NO_TARGET/IMMEDIATE active lasts4 seconds, uses45 mana, cooldown30,
doubles block (`active_pct_effectiveness=200`) with40% movement penalty. Native
creep block penalty50% and non-stacking item-block note differ from the current
unconditional block getter. Keep defense/sustain identity. Installed Kraken
description includes cleanse, while a separate Blubber description restricts
its counter to player-owned damage. Neither text proves the actual C++ dependency.
Inspect alias/provider restoration and make this a precise owner runtime case;
do not add both listeners or silently invent neutral-wave cleanse parity.

E native `attack_damage`, signed `damage_reduction`, `reduction_duration` and
`additional_range` replace current custom names. Native description specifies
real attacks, not `GetAverageTrueAttackDamage` plus `ApplyDamage`. Native
immunity metadata is ENEMIES_NO; current custom KV/queries allow magic-immune
enemies. This is a material behavior change to disclose. Preserve the previous
CP2 radius fix only while Lua owns presentation; native conversion must retire
the duplicate particle/query rather than leave two executions.

R installed damage is top-level `AbilityDamage`; radius1250, speed725 and
duration2/2.2/2.4 are native values. Current radius1000 and authored duration
2.4..3.2 are deliberate tuning candidates. `GetLevelSpecialValueNoOverride`
documentation only promises the special-value block; it does not prove a
top-level AbilityDamage override is consumed by Ravage. Avoid the earlier SF
mistake of inferring actual damage from a reported special. A source solution
must expose that question explicitly; no fabricated engine PASS. Remove the
custom boss-only stun cap when native ownership is established, without editing
boss AI, wave rules or global boss classification.

D native catch has MaxLevel1/Innate1, dynamic accumulated HP/range/block and
native even-level fish grants. Ten-rank Enfos progression must stay separate
from exact native provider rank1. Fish bonuses are match-only. Resource identity,
automatic level6 catch-up, cleanup, Break, restore and stacking are unanswered;
do not guess constructors, duplicate native level grants or spawn unbounded fish.
The current D recipient getters also read ability values without the owner's
invalid-source/Break helper; decide correction alongside D's source choice.

## Upgrades and acceptance

Scepter belongs to Q. Existing generic Tidehunter Scepter suppression must remain
compatible with the chosen native owner. Blessing should follow Scepter checks.
The native hero header assigns Dead in the Water (enemy HERO only); Arm of the
Deep's definition is not evidence that the live kit grants it. Current Enfos
Shard is W's half-strength reactive smash at a five-second cooldown. Resolve
the PvE Shard contract from these facts, including native reflected-damage
semantics, before retaining/replacing it; avoid a second full active E attack
masquerading as a half-strength reflected proc.

Existing precache owns Tidehunter sound bank, Gush ordinary/upgraded projectile,
Anchor root and Ravage root. Verify resources and cold start before changing
ownership. Client scaling/modifier links must use the established minimal
bootstrap, never load server integration managers on clients. GetStrength and
GetLevelSpecialValueNoOverride API availability is both realms; that says
nothing about live native handles or C++ consumption.

Validation so far: installed snapshot parsed and native header/source re-read;
production unchanged. Automated gameplay validation is not newly claimed.
Pending owner cases: full restart, ranks1/10, Q ordinary/Scepter/Blessing aiming
and cooldown, W active block/movement/creep penalty/cleanse, E real attacks and
items, R damage/STR/radius/speed/status resistance/bosses, D native even-level
and wave behavior, Shard, Break, illusion, invalid handles, repeated casts,
death/respawn/reconnect, client HUD/tooltips, precache/VFX/SFX and VConsole.
Health report runs automatically; owner supplies logs. No collector or Dota
control is authorized. Next implementation unit is Q; resolve the remaining
native dependencies sequentially through this hero before moving to Ursa.
