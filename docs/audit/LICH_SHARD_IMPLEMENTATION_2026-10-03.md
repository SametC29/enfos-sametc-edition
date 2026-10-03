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
