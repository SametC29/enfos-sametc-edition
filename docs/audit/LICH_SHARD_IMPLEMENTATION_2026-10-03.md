# Lich Shard — native Ice Spire integration, 2026-10-03

Status: IN PROGRESS. This record supplements the individual Lich ledger; it is
not source closure or engine certification. No Shard ability is granted by this
work unit. Complete summon, W repair and R bridge integration before exposure.

## Evidence and disposition

Installed `steam.inf`: ClientVersion/ServerVersion6943, SourceRevision11069754,
Oct01 2026. Re-read `scripts/npc/heroes/npc_dota_hero_lich.txt` through Workshop
MCP on Oct03. `lich_ice_spire`: Shard-granted, rank1, cast range750, cast point0.3,
animation ACT_DOTA_CAST_ABILITY_5, cooldown25, mana150, radius550, movement slow25%,
duration15, hero attacks4, creep attacks8, aura linger0.5. Current native English
`DOTA_Tooltip_ability_lich_ice_spire_Description`, extracted from the installed
archive, explicitly describes death Frost Blast, W pulse healing by one hero
attack, and R fallback bouncing to the Spire for one hero attack of damage.

The existing Support Shard healing25% has no recipient healing in this five-slot
kit. Classification: **TUNE**, restoring recognizable native Shard interactions
with the existing custom Q/W/R stable IDs and authored ten-rank curves. Native
C++ compatibility with those IDs is unproven; custom glue must remain explicit,
isolated and independently tested. No external implementation code is imported.
Optional owner preference was unanswered; use the native-style Ice Spire path
without exposing an incomplete extra ability. This does not add talents or
persistent progression.

MCP confirms native `models/heroes/lich/ice_spire.vmdl_c`, native icon and particle
family exist. Resource existence does not establish rendered correctness. For
Nova, reuse the already decoded Frost Nova CP0 origin and CP1.xyz radius contract.
MCP `ParticleAttachment_t` confirms PATTACH_WORLDORIGIN; MCP
`EmitSoundOnLocationWithCaster(location,soundName,caster)` confirms server API.
The installed decoded Lich bank defines Ability.FrostNova using
`sounds/weapons/hero/lich/frost_nova.vsnd`, reported duration4.005986. Reported
duration alone is not proof of audible playback or loop policy.

Web research cross-check: [Valve scripting constants](https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Constants)
and [Valve hero ability model requirements](https://help.steampowered.com/en/faqs/view/2ABE-09A8-DB83-3327).
Use the installed MCP API and archive as current evidence; older reference pages
do not prove this build's runtime behavior.

## Implemented foundation: Q death Nova

`enfos_lich_frost_blast:BlastAtPoint(origin)` performs learned-Q splash only:
radius_damage + INT*0.5, ranked radius and duration, ordinary magical damage and
native purgable slow. No primary target bonus, artificial cast, mana payment,
cooldown, projectile, talent or Boss exception. Rank0/client/deleted source/
nil position produces no effect. A still-existing dead owner is permitted for a
surviving summoned Spire; owner engine tests must establish death behavior.

Visual/audio creation uses captured world position and surviving caster, never
the destroyed Spire. One Nova particle is released to its finite resource
lifecycle; one location sound. The Spire controller will own calling it once.
No controller or acquisition path currently calls this method.

Targeted Q and death Nova share only splash application. Targeted Q retains the
pre-primary rank/INT/radius/duration snapshot, distinct primary damage, source
checks, enemy search and existing effects. Revalidate cached splash candidates
before damage: a prior damage callback can kill/delete later candidates. Count
only live eligible enemies; do not slow lethal victims or call deleted sources.
Default-off bounded Q trace records requested per-target splash, measured actual
aggregate, affected count, position and finite particle ownership.

## Validation and remaining work

- SOURCE REVIEW: PARTIAL; death-Nova foundation implemented, full Shard open.
- MOCK/REGRESSION: dedicated real-Q fixture covers all ten ranks, ordinary/Boss
  parity, friendly/dead/deleted exclusions, lethal victim, source/ability deletion,
  dead but existing caster, zero-rank/client rejection, finite effects/single
  sound, and targeted-Q pre-primary snapshot despite synchronous rank/INT change.
- OWNER RUNTIME TRACE EVIDENCE: NOT TESTED.
- OWNER VISUAL/AUDIO VERIFICATION: NOT TESTED.
- OWNER ENGINE ACCEPTANCE: NOT TESTED.

Remaining: single owned finite-lifetime Spire, native attack-count health/slow,
recast/Shard-loss retirement without duplicate Nova, summon model/VFX/SFX and
cleanup; W own-Spire target and one-hero-hit repair; bounded R bridge and one-hit
Spire damage; acquisition/loss/consumed-Shard paths; native-style extra ability
KV and four-language UI/tooltips; focused regressions and owner checklist.
Do not declare Shard complete from this prerequisite fixture.

Validation for this work unit: all10 ordinary-target tests PASS, including the
new ten-rank death-Nova fixture; full working-tree checks0failed after inventory
refresh. The historical352 hero regressions also PASS using indexed E and
indexed tests, excluding contributor-only changes. These are mock/static
results. No Dota launch, owner runtime evidence, remote push or publication.

## Controller foundation — second work unit

Added isolated `abilities/heroes/lich/spire.lua` and one custom immobile Other/
summoned ward definition. This is a dormant foundation: no extra ability KV,
hero slot, bootstrap route or Aghanim grant exposes it yet. W/R integration must
precede exposure. Native model/scale0.8, ward classification, no attack/movement,
native `neutral_spell_immunity`, vision800, health-bar offset350 and ring65 come
from the re-read installed `npc_dota_lich_ice_spire` record. Ordinary creature
BaseClass delegates hit-count behavior to the isolated controller rather than
assuming native C++ links to custom Q/W/R IDs. Bounty/XP are intentionally zero
instead of native20 to avoid funding opponents from a temporary summon. This is
a declared match-only tuning, not a change to hostile waves/economy managers.

One successful summon replaces the prior owned summon; failed spawn/controller
leaves the previous one intact. Ownership uses server-only GetOwnerEntity and
team/unit identity; client paths do not invoke that API. Synchronous creation is
one unit per cast because the protection controller is needed immediately. No
global search, mass creation or custom permanent lifetime. Invalid lifetime is
rejected. Source/ownership checks occur once per0.5s on the single finite unit.

Durability normalizes eight creep attacks to health8; a hero attack or R bridge
spends2, and W helper repairs2 capped at8. Absolute physical/magical/pure damage
properties keep ordinary attack damage from replacing the hit counter. Whether
OnAttackLanded fires under those properties must be verified by the owner in
Dota; the mock cannot prove it. Hero classification includes IsHero illusions,
not IsRealHero; creep attacks count1. Friendly attacks are ignored intentionally;
deny behavior is an authored ward restriction, pending owner review/testing.

Termination detaches current caster pointer before reentrant kill/Nova callbacks,
and marks itself terminated once. Actual destruction and finite expiry request
Q death Nova with valid surviving source, even if caster is dead. Treat expiry
Nova as an explicit authored choice under native's destruction description;
installed text does not independently prove expiry behavior. Recast/Shard-loss
retirement, missing source/owner, allegiance loss and failed creation do not
request Nova. Old callbacks cannot clear the replacement. Removal/death callbacks
cannot kill or detonate twice. Source deletion may leave a stale pointer on a
deleted owner which is no longer read; no retained global ownership table exists.

Engine-distributed enemy Hero/Basic aura uses native radius550, linger0.5 and
movement slow25%; no scan is introduced solely for aura telemetry. Active summon
aura does not become a caster passive subject to Break. Modifier/unit labels and
slow property description are translated into EN/TR/RU/zh-CN and mirrors.

Precache covers native model, Lich bank and death Nova. Spawn uses verified
Ability.FrostNova location event; destruction uses verified
Hero_Lich.IceSpire.Destroy (installed bank's reported duration2.904422). The native
Spire root particle was decoded with VRF19.2; its preview specifies CP0–5 and
children. Preview offsets alone are not verified runtime attachment semantics,
so a speculative persistent particle has not been attached. Model rendering,
root particle integration, animation, sound and cold-start acceptance are open.

MCP verifies CreateUnitByName, ForceKill, SetBaseMaxHealth, SetMaxHealth, SetHealth,
FindModifierByName, GetOwnerEntity, OnAttackLanded and absolute damage property
callbacks/enums. No Dota process was launched. The real controller fixture covers
4hero/8creep hits, mixed/partial/full repair, bounded expiry, dead-owner survival,
reentrant destruction, recast, stale callbacks, failed creation, invalid lifetime,
source/ownership/allegiance loss, no retired Nova, client guards and aura values.
SOURCE REVIEW: PARTIAL; regression PASS does not complete Shard or engine gates.

Second-unit validation: all14 focused Lich tests PASS (10 ordinary-target,
2 Scepter,2 Spire), full checks0failed before the final non-gameplay tooltip sign
correction and invalid-lifetime guard; the focused fixture passes after that
guard. Ordinary checks do not load the dormant module; the dedicated controller
fixture loads its actual source. No owner runtime/visual/audio evidence supplied.

## W/R integration — third work unit

Connected actual W and R to the isolated controller without yet granting the
extra Shard ability. Their KV types include Other; R's broad team metadata is
BOTH solely to admit the allied Spire, with a Lua filter restoring ordinary
enemy Hero/Basic selection for every other target. W remains FRIENDLY. Verified
UnitFilter and UnitFilterResult retain ordinary type/immunity/target rejection;
no guessed GetAbilityTargetFlags client call (current API marks it server-only).
Both core definitions previously had no target flags, so their filter uses NONE.
Client predicts only named friendly Spire; ownership is checked authoritatively
on the server. Foreign or ordinary ward targets are rejected. Recheck allegiance/
ownership in W creation/pulses and R impacts, including ownership loss in flight.
Shield mitigation checks ward ownership only on server; client tooltip values
do not invoke server-only GetOwnerEntity. The two modifier routes now belong to
the shared bootstrap and are tested for single registration/cold import.

W calls capped one-hero-hit repair once per existing pulse, before ordinary
damage/slow. It does not add HP healing, healing amplification, extra timers or
repair ordinary heroes/creeps. Rank damage, radius, mitigation and finite shield
duration remain unchanged. Losing ward ownership stops both protection and pulse.

R may initially target own live Spire, bypassing hostile spell absorption only
for that friendly ward. Each ward contact spends one hero hit of durability and
one normal impact from the existing ten-rank, maximum18 budget. No magical damage
or hostile slow is applied to a ward. The existing native non-hero Chain Frost
impact sound is reused before possible destruction; this is an explicit feedback
choice, not a proven C++ ward-audio mapping. Projectile VFX remain engine-owned.

Normal enemy traversal retains distinct-target history. If no unvisited enemy is
within the existing600 bounce radius, an owned Spire within600 is eligible as a
bridge. Only a bridge permits the next enemy to have been previously hit. Its
contact remains in numeric bounded history, and bridge state is a numeric
ExtraData field. A lethal ward impact may resume from captured origin; if Q death
Nova kills every enemy, the search ends. An invalid/lost ward during projectile
flight terminates normally. No delayed fallback timer or retained global chain
table is added. Continuous W repair cannot make a chain exceed the original
impact budget. Multiple projectiles retain independent serialized history.

Four-language W/R descriptions now explain repair, repeats and total impacts
accurately; EN/RU/zh descriptions no longer promise exclusively different enemies
when Ice Spire is used. Scepter channel-cast flags remain unchanged.

The real W/R + real controller regression covers capped actual-pulse repair,
lost ownership, server/client filters and tooltip boundary, hostile/friendly
filtering, numeric projectile serialization/speeds, lone-enemy repeated bridge,
lethal ward continuation, direct ward cast, repaired18-impact limit,601-range
rejection and allegiance loss in flight. Ordinary ten-rank and historical kit
checks still exercise non-Shard behavior. All17 focused Lich tests and full
working-tree checks PASS; these do not prove engine filtering, projectile lifetime,
native ward effects, HUD/resource/audio or cold-start acceptance.

Remaining: extra ability KV/slot and manager acquisition/loss/consumed-Shard
paths, removing Lich-only generic healing bonus, extra ability localization,
resource/animation and owner-engine checks. This unit still exposes no Shard cast.
