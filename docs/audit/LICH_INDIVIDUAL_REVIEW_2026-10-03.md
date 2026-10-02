# Lich individual review — reverse-roster priority, 2026-10-03

## Current acceptance

- SOURCE REVIEW: PENDING; all five current Lua/KV slots inspected for discovery,
  detailed mechanics/resources/upgrades review ongoing.
- DESIGN DECISION: Q TUNE; W PVE-CONVERT; E PVE-CONVERT; R PVE-CONVERT;
  D REPLACE. Rationales and unresolved comparisons follow below.
- PROVEN DEFECTS: Q post-damage handles, W orphan pulses/invalid cast and undefined
  W sound, D recipient-vs-source Break ownership, E control/channel teardown,
  R lethal-victim/source access, undefined impact sound and instant projectile
  dispatch repaired; advanced mechanics and owner engine evidence remain open.
- MOCK/REGRESSION VALIDATION: PASS for the recorded five-slot cases (348 suite cases).
- RUNTIME TRACE COVERAGE: PARTIAL, Q cast/absorb/source-loss/primary/splash summary;
  W cast/pulse/source-loss, E channel/control lifecycle and D source/recipient
  lifecycle and R projectile launch/impact/damage/termination/slow ownership
  records added; detailed W lifecycle, D live Break/rank transitions and E
  resources/absorb remain open. R advanced immunity/upgrade evidence remains open.
- ABILITY ISOLATION: COMPLETE for current source; five custom slots and six modifiers extracted into
  explicit hero modules; source/regression verification and owner cold-start gate
  are recorded in the isolation section below. This does not close the kit review.
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
| R Chain Frost | PVE-CONVERT: authored bounded wave spreading with INT scaling and native projectile identity. | Engine tracking now replaces synchronous damage/root particles; initial/next speed1050/850, authored range600, once-per-target policy and10–18 hits preserved. Native repeated bounces/range550/damage escalation intentionally differ. Actual engine immunity/resistance, upgrades, particle/animation/audio and primary-block timing remain pending. |
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

## D external-aura ownership and inactive sources

Retain REPLACE: Ice Aura is authored allied armor/mana support, not native Death
Charge. Installed MCP CDOTA_Buff:GetCaster identifies the ability's owner;
GetParent identifies the recipient. [Current API docs](https://docs.moddota.com/lua_server/)
agree. Existing recipient properties instead tested the ally's PassivesDisabled,
so Break on Sven removed Lich's external buff while a lingering buff after Break
on Lich still supplied armor/mana. The former aura mock tested only IsAura and
never covered the recipient properties; it could not establish correct ownership.
Project Crystal Maiden's recipient contract was also inspected for consistency.
Reference-only Workshop1571786267 item_speed_rare grep shows source-owned
PassivesDisabled gating; no code imported and no license/version assumption.

Both properties now resolve active learned valid ability and actual caster; Break
on the caster zeros both, ally Break alone does not. Aura emission uses the same
source contract. Removed/unlearned sources and invalid recipients grant nothing.
Keep the existing illusion-recipient exclusion; do not silently redesign that
policy. Source-illusion duplication, engine linger/removal, two-Lich strongest
buff selection, live rank replication and death/respawn remain pending tests.

New source/recipient create/refresh/remove callbacks emit only bounded diagnostic
records when the common flag is on; no timer, new state modifier, search or
cleanup is added. No getter is logged. Explicit verified frost_nova icons are
provided. Trace flags reflect source eligibility, not proof of stats received;
engine recipient values and illusion exclusions must still be verified.

The independent regression failed before repair with a Broken recipient. It now
checks caster/recipient Break separately plus unlearned and removed abilities.
The historical IsAura fixture now supplies an ability because a real intrinsic
modifier has one; missing-source emission is no longer accepted.338 behavior
mocks pass. Engine aura timing, visuals/tooltips and all advanced interactions
remain NOT TESTED/PENDING.

## E channel/control teardown ownership

Retain PVE-CONVERT and current ranked channel duration, boss35% duration/no pull,
0.5s mana-transfer tick and normal40-unit pull. This is a lifecycle repair,
not a movement/control redesign. The debuff previously lacked OnDestroy, so
control removal could leave the channel running; the invalid-state interval
also called EndChannel on an already-removed ability handle. Targeted mocks
reproduced the missing callback and unsafe removed-handle branch before repair.

OnDestroy now checks valid ability and matching gazeTarget before clearing
ownership; it ends only the caster's currently active matching ability.
OnChannelFinish clears ownership before caster-specific modifier removal,
preventing recursive channel termination and preserving another Lich's control.
Invalid/dead caster/recipient or removed ability destroys the existing debuff;
its normal destruction callback owns interruption. Cast, channel finish and tick
execute server-only. No new timer, gameplay modifier or search is introduced.

Installed MCP CDOTA_BaseNPC:GetCurrentActiveAbility and
CDOTABaseAbility:EndChannel signatures plus
[current server API documentation](https://docs.moddota.com/lua_server/)
support the ownership guard. Actual engine active-ability state during expiry,
dispel, death and channel-finish ordering remains owner verification. A removal
record deliberately says control_removed, not an invented dispel/expiry reason.
Default-off bounded E traces cover channel start/finish, invalid-state teardown,
control removal and existing mana/pull ticks. The modifier uses the verified
lich_sinister_gaze icon. Actual Gaze particle CPs/attachment, target audio,
animation, absorb cancellation, resistance timing, movement/pathing and
Shard/Scepter remain open. Three new regressions plus the amended dead-target
fixture verify ownership, invalid-source cleanup and finish re-entry:341 suite
cases pass, project checks0fail. These are mock/source evidence, not engine PASS.

## R lethal-victim/source guards and verified impact events

Retain PVE-CONVERT, current authored once-per-victim policy,600-radius spread,
ranked damage/INT1.0 and boss35% slow duration. Before damage, capture the impact
origin and boss-adjusted slow duration. After synchronous lethal removal, skip
control on the corpse and search from the saved origin so the rest of the spread
survives. Removed caster/ability stops further damage/control dispatch. Cast is
server-only and rejects invalid/dead caster/target; candidate selection skips
removed units. Two regression fixtures fail before repair and pass afterwards:
removed lethal victim, and source removed during damage. The mock world excludes
a deleted victim from subsequent radius searches, matching entity removal rather
than forcing production to work around an impossible radius result.

The decoded installed6943 Lich bank has ChainFrostImpact.Hero and
ChainFrostImpact.Creep, not the used Hero_Lich.ChainFrost.Impact. Choose the
verified impact event by IsHero and precache its declaring bank explicitly.
Audible hero/creep impact plus cold-start loading remain NOT TESTED. Bounded
R records describe current cast/hit/next-target/source cancellation; they do
not pretend a projectile launched. Existing root particle at each recipient
and synchronous for-loop are still open: actual travel/projectile, resource
CP/attachment/lifetime, spell block, immunity, resistance, death/recast and
upgrades require further review. No premature projectile/visual acceptance.
343 behavior mocks pass and full project checks0fail; inventory refreshed only
for new callback metadata. All owner runtime gates remain NOT TESTED.

## 2026-10-03: individual ability isolation

Latest owner steering retains reverse roster order: Lich first, then Vengeful
Spirit, Jakiro, Lion and the preceding roster entries. Sven remains reopened
and pending until its turn. The separate unfinished onboarding generator was
backed up outside the repository before this work; it is not part of this repair.

Inspected all five current Lich implementations against installed hero source
again on ClientVersion6943 / SourceRevision11069754 (Oct01 2026). This extraction
preserves the current implementation and open design findings; it does not turn
the synchronous R into a verified native projectile or certify W/E resources.

| Slot | Stable class | Implementation / modifier ownership |
| --- | --- | --- |
| Q | enfos_lich_frost_blast | abilities/heroes/lich/q.lua; Frost Blast slow |
| W | enfos_lich_frost_shield | abilities/heroes/lich/w.lua; Frost Shield |
| E | enfos_lich_sinister_gaze | abilities/heroes/lich/e.lua; Gaze debuff/channel teardown |
| R | enfos_lich_chain_frost | abilities/heroes/lich/r.lua; Chain Frost slow |
| D | enfos_lich_ice_aura | abilities/heroes/lich/d.lua; aura source and recipient buff |

Each file explicitly imports shared value/enemy/Boss/intellect/damage helpers and
lib/hero_trace. Five original helper bodies were moved verbatim into
abilities/shared/pve_helpers.lua; the remaining monolith imports the same helpers.
No balance values, gameplay callbacks, searches, timers, particles or state
transitions were changed by extraction. Private D eligibility/trace helpers stay
with D. No other hero's ability classes were moved.

KV ScriptFile now points to the five isolated files. Each file links its own
modifiers. The old pve_kits bootstrap requires lich/init and preserves the shared
modifier inventory while skipping duplicate registrations for those six names.
Direct Lich module loading requires neither Sven locals nor the monolith.
Structural audit, rank-matrix modifier-owner discovery and localization intrinsic
discovery follow production KV and explicit imports; generated dossier source
links follow the actual ScriptFile values. Human evidence remains unchanged.

Verification: baseline npm run check passed before extraction. Dedicated isolation
tests check unique class definitions, KV ownership, all six modifier routes and
direct cold module load followed by compatible shared bootstrap. Focused and full
post-extraction results: 95 focused Node tests passed (including two new isolation
tests); full npm run check passed with zero failed checks and all 343 hero behavior
regressions. A migration comparison verified all 55 original Lich/shared-helper
function bodies verbatim against the pre-extraction commit. git diff --check passed.
Isolation source/regressions are COMPLETE. Owner full-restart registration, particles/sounds and five-slot live
behavior remain NOT TESTED. Existing trace and individual source review remain
PARTIAL/PENDING; extraction alone is not hero completion.

## 2026-10-03: R primary spell block and hostile targeting

Individual R inspection found no TriggerSpellAbsorb call before the synchronous
spread, despite enemy unit-target KV and native Chain Frost identity. Current
installed MCP CDOTA_BaseNPC:TriggerSpellAbsorb takes a CDOTABaseAbility and returns
a server bool; the current [server API documentation](https://docs.moddota.com/lua_server/)
and existing Q/E guards provide matching API/reference evidence. No external code
was imported. Primary absorb is checked once before cast feedback, damage or slow;
friendly primaries are rejected before consuming an enemy spell-block charge.
Cancellation traces use the existing bounded helper and add no gameplay events.

The independent blocked-primary regression failed before repair because absorb
was never attempted. Both blocked and friendly cases now require no damage,
spread or cast sound; friendly targets must not consume spell block. This repair
does not change damage/rank/Boss values, once-per-target policy or current instant
spread timing. Spell reflection, actual engine absorb behavior and subsequent
projectile integration remain pending individual/runtime work. R remains
PVE-CONVERT; SOURCE REVIEW and full trace coverage are still PENDING/PARTIAL.

Validation after this focused repair: 345 hero behavior regressions passed;
npm run check passed with zero failed checks; git diff --check passed.
OWNER RUNTIME TRACE EVIDENCE / VISUAL-AUDIO / ENGINE ACCEPTANCE remain NOT TESTED.

## 2026-10-03: R engine tracking projectile and bounded chain state

R remains PVE-CONVERT. The earlier implementation dealt every hit in one
synchronous for-loop and placed the travelling root particle directly on each
victim. This contradicted the existing four-language tooltip's frost-orb launch
and Lich's projectile identity. Replace that dispatch with an engine tracking
projectile and OnProjectileHit_ExtraData; damage and slow now occur at impact.
Preserve the authored once-per-distinct-target rule, 600 search radius, ten ranked
damage/INT1.0 values, ranked 10–18 hit limits and Boss35% slow duration. This
intentionally differs from native repeat bounces, 550 radius and escalating
per-bounce damage. No native infinite-bounce talent is restored.

Current installed native scripts/npc/heroes/npc_dota_hero_lich.txt, build6943 /
SourceRevision11069754, declares initial_projectile_speed1050 and
projectile_speed850. Current MCP server signatures and
[server API declarations](https://docs.moddota.com/lua_server/) verify the tracking
creation and impact callback interfaces. The installed root
particles/units/heroes/hero_lich/lich_chain_frost.vpcf_c was decoded read-only
with Source2Viewer CLI19.2: attraction uses CP1, movement speed override CP2,
and an explosion endcap plus launch/trail child resources are declared. The
engine now owns projectile particle positioning and destruction; no separately
created root, particle handle, timer or persistent per-cast registry remains.
Resource structure supports the integration but does not establish visible
placement, endcap playback or engine CP acceptance.

REFERENCE_ONLY: [Elfansoer Lich Chain Frost implementation](https://github.com/Elfansoer/dota-2-lua-abilities/blob/6288dfa99327b7e97ec2d1c10a2a75d256ed1368/scripts/vscripts/lua_abilities/lich_chain_frost_lua/lich_chain_frost_lua.lua),
file revision6288dfa99327b7e97ec2d1c10a2a75d256ed1368,2019-02-09.
Observed concept: nondodgeable tracking projectile followed by impact-driven
bounces. No code/assets imported; the old temp-table/thinker tracking and TI8
particle dependency are rejected. Nondodgeable preserves the prior unavoidable
instant-chain behavior; current owner engine dodge acceptance is still pending.

Each projectile carries only numeric damage/duration/hit budget and at most18
visited entity indices in ExtraData. Independent recasts do not share history.
Nil/dead/removed/friendly impact targets stop; valid dead casters retain launched
spells, removed casters/abilities stop. A lethal victim's position is captured
before damage, allowing the next projectile to depart from its saved origin.
Primary spell block remains checked once at cast; no extra block check was added
to bounces. Source/target loss creates no abandoned Lua cast state requiring
expiry cleanup. The explicit18 cap equals the current maximum authored rank
budget; future increases require changing this bound and its rank regressions.

Default-off bounded R traces now record launch ID/target/speed/engine particle
ownership, impact index/Boss/damage request/slow duration, ApplyDamage return,
termination reason and slow create/refresh/removal ownership. A nil mock damage
return is not a claim of measured engine damage. No getter or per-frame traces.

Regression fixtures explicitly deliver captured projectiles, rather than making
the mock engine auto-hit synchronously. All ten ranks preserve damage and unique
hit budgets; cast alone deals no damage. Recasts, valid caster death, nil/friendly/
dead impacts, removed caster/ability and existing lethal/source-loss cases pass.
348 hero behavior regressions and npm run check pass with zero failed checks.
Generated structural inventory reflects only the new R callbacks; localization
already describes the launch/bounce behavior, so source text stays unchanged.

R source review is still PENDING for immunity/invulnerability/control resistance,
spell reflection and primary-block timing, Shard/Scepter integration, animation
and full resource acceptance. Owner basic tests: cold load, rank1 cast, actual
travel followed by damage/slow, ordinary-creep and Boss impact sounds, exhausted
chain cleanup. Advanced tests: rank10 dense wave, lethal removal in flight,
recast/refresh/death, target disappearance/disjoint attempts, BKB/debuff immunity,
purge/resistance, two Lich ownership, upgrades and reconnect. OWNER RUNTIME TRACE
EVIDENCE / VISUAL-AUDIO / ENGINE ACCEPTANCE remain NOT TESTED; no source closure
or engine acceptance is inferred from these automated passes.
