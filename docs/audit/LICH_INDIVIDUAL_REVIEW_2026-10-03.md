# Lich individual review — reverse-roster priority, 2026-10-03

## Current acceptance

- SOURCE REVIEW: PENDING; all five current Lua/KV slots inspected for discovery,
  detailed mechanics/resources/upgrades review ongoing.
- DESIGN DECISION: Q TUNE; W PVE-CONVERT; E PVE-CONVERT; R PVE-CONVERT;
  D REPLACE. Rationales and unresolved comparisons follow below.
- PROVEN DEFECTS: Q post-damage handles, W orphan pulses/invalid cast and undefined
  W sound repaired; other findings under review.
- MOCK/REGRESSION VALIDATION: PASS for the recorded Q/W cases (337 suite cases).
- RUNTIME TRACE COVERAGE: PARTIAL, Q cast/absorb/source-loss/primary/splash summary;
  W cast/pulse/source-loss added; detailed W lifecycle and E/R/D remain open.
- OWNER RUNTIME TRACE EVIDENCE: NOT TESTED.
- OWNER VISUAL/AUDIO VERIFICATION: NOT TESTED.
- OWNER ENGINE ACCEPTANCE: NOT TESTED.
- REMAINING ENGINE-ONLY TESTS: targeting/immunity/absorb/reflect, ranks, damage
  and controls with resistance, purge/Break/death/recast, two-caster ownership,
  Shard/Scepter, actual particle/audio/animation/cold precache, reconnect.

## Sources and individual discovery

Read docs/heroes/lich/AGENTS.md and full relevant dossier, shared hero contract,
technical reference, research/runtime and development protocols. Read all five
current Lua classes and linked modifiers in abilities/pve_kits.lua, their KV at
npc_abilities_custom.txt, and current addon precache entries. Re-read installed
scripts/npc/heroes/npc_dota_hero_lich.txt through Workshop MCP; installed build6943.
Historical dossier6941 is not current acceptance. Current Lua API and
[ModDota server declarations](https://docs.moddota.com/lua_server/) are supporting
evidence, not an engine test. No external code/assets imported.

| Slot | Decision and identity | Current contract / open findings |
| --- | --- | --- |
| Q Frost Blast | TUNE: native instant enemy magic nuke/splash/slow identity; Enfos INT scaling and boss caps are explicit tuning. | Primary target damage+INT0.8, splash+INT0.5; bosses capped10%/6% maxHP and40% slow duration. Post-damage victim/caster handles were unguarded; snapshot origin and control duration before damage, skip dead recipient without dropping splash. Native primary also receives area damage; current primary/splash accounting needs a separate design/native comparison before changing balance. |
| W Frost Shield | PVE-CONVERT: retain allied protective shield/pulse, current INT pulse scaling. | Six-second buff,1s600-radius pulses; current modifier reduces all incoming physical damage, not specifically native attack damage. Invalid recipient/source and interval cleanup, native shield resource vs old armor resource, missing slow, animation and sound bank need review. |
| E Sinister Gaze | PVE-CONVERT: native channel/control/mana-drain identity, boss shorter channel/no pull. | Boss35% duration;0.5s mana transfer and40-unit pull; current origin movement/pathing/resistance, channel cancellation/cleanup ownership, absorb branch and actual Gaze resources need review. |
| R Chain Frost | PVE-CONVERT: authored bounded wave spreading with INT scaling; native projectile identity must be restored where viable. | Current Lua visits each unit once synchronously and renders particle roots at recipients instead of projectile travel. Native6943 initial/next speed1050/850, range550, repeated bounces and2.5s slow. Current authored range600 and once-per-target policy cannot be changed silently; projectile timing/ownership/cleanup are a substantial open defect. |
| D Ice Aura | REPLACE: authored allied armor/mana aura is a distinct Enfos passive, not current native Death Charge's friendly-creep sacrifice. | Recipient Break currently disables external aura benefits while caster Break is checked only by aura emitter. Source/recipient ownership, inactive sources, rank refresh, illusion and lingering-aura policies need review. |

All five slots retain10 ranks; basic/fifth gates1/1 and R5/5 fit level50.
KV/mocks do not establish engine points/free-rank/client stat acceptance.

## Q removed-handle reproduction

ApplyDamage may synchronously trigger death/removal callbacks. Existing Q applied
the primary slow and called primary:GetAbsOrigin after that event. A regression
removes the primary in the damage callback and makes those stale operations throw;
it failed before repair at AddNewModifier. A second case removes the caster and
requires no subsequent modifier application. This establishes unsafe Lua source
ordering; it does not prove a specific owner runtime crash has occurred.

Q now snapshots impact position and boss slow duration before primary damage,
skips slow on killed/removed recipients, retains splash at the snapshot position,
and stops if damage invalidates the caster or ability. Splash damage has the same
post-damage source/recipient guards. Added a server cast guard. Existing authored
damage/INT scaling/boss caps/radius/slow duration are unchanged.334 hero behavior
mocks pass; project checks are recorded after final review. The primary-removal
and source-removal cases passed after repair.

Q uses the existing shared debug-gated bounded trace helper; no extra target
search, timer, cleanup, particle or gameplay event was added. Requested damage is
labelled requested_damage, not actual post-mitigation damage. Traces and mocks do
not establish visible nova CPs, sound playback, resistance or engine acceptance.

## W source lifetime, sound and modifier icon

Retain PVE-CONVERT and authored six-second duration,1s/600-radius magical pulses,
INT0.25 scaling and physical reduction values. Cast now rejects removed/dead
caster/recipient and executes server-only. Existing pulse checks recipient/caster/
ability handles before reading position or calling damage; invalid state destroys
the existing buff, and post-damage source loss stops that pulse's traversal. A
valid dead caster is deliberately not rejected: an already-applied ally shield
is not silently cancelled when Lich dies. Engine death/expiry rules need testing.

Two targeted tests reproduced removed-recipient and invalid-cast accesses; an
ability-removal fixture also catches orphan damage dispatch. They pass after
repair. Traces record W cast, cancelled pulse and pulse recipient/count/requested
damage through the common default-off bounded helper; no extra scans or timers.

Source2Viewer-CLI19.2 decompiled current6943
soundevents/game_sounds_heroes/game_sounds_lich.vsndevts_c into an external temporary
review directory. That bank defines Hero_Lich.IceAge (ice_age_target.vsnd, finite
3.424943s), IceAge.Tick and IceAge.Damage, but not the used Hero_Lich.IceArmor.
Change cast to the verified IceAge event, add explicit ability sound-bank precache
and actual lich_frost_shield modifier texture. Native KV's legacy FrostArmor name
is also absent from this bank; do not blindly copy stale names even from KV.
Audible playback/timing remain owner tests. An attempted Workshop reference
1571786267 frost-shield Lua path was absent and supplied no implementation evidence.

The persistent lich_frost_armor resource exists, but decoded root reads CP1.x
for scale (0..1000 ->0..128) and has armor/ring/model children; GetEffectName does
not explicitly configure it. Installed assets also contain lich_ice_age.vpcf.
Actual modern shield CP/child comparison remains open; do not replace particles
from name similarity. Current W still lacks native pulse slow and uses all-physical
rather than specifically attack mitigation. Those mechanics require separate
reference/design inspection, not an undocumented change in this lifetime fix.

337 behavior mocks pass after repair. Generated structural inventory is refreshed
only for Precache/GetTexture callbacks; project checks verify repository contracts
and do not certify cold-start asset loading or in-match particles/audio.
