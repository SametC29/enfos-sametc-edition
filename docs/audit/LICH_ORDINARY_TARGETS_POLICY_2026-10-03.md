# Lich ordinary-target policy follow-up — 2026-10-03

Supplement to `LICH_INDIVIDUAL_REVIEW_2026-10-03.md`, following owner goal
revision db8ef7c. Historical Boss-cap/duration statements in that ledger and the
hero dossier describe superseded behavior for Q/R; they are not current policy.
The main ledger/dossier and E/tests/KV are concurrently being edited by another
hero session and were deliberately excluded from this isolated commit.

## Current scoped result

- SOURCE REVIEW: PENDING for the full hero; Q/R policy removal reviewed.
- DESIGN DECISION: Q TUNE; R PVE-CONVERT. These preserve recognizable frost
  damage/control and Chain Frost projectile identity; no new kit or balance curve.
- BOSS-SPECIFIC SKILL EXCEPTIONS: PARTIAL. Q primary10% and splash6% maxHP caps,
  Q40% slow duration and R35% slow duration removed. E channel35% and no-pull
  remain pending its current editor's commit and subsequent focused review.
  W/D inspection found no authored Boss-only gameplay formulas; W/R Boss labels
  in traces are diagnostic classifications, not mechanics.
- PROVEN DEFECTS: stale Q/R policy and their four-language descriptions corrected.
  Earlier lethal-target/source/ownership/projectile repairs are preserved.
- MOCK/REGRESSION VALIDATION: PASS; the new ten-rank ordinary/Boss comparison
  fails against the old Q cap before production change and passes after removal.
  Full repository checks pass with current contributor work present; that does
  not certify or take ownership of those changes.
- ABILITY ISOLATION: existing Q/R modules retained; no extraction in this unit.
- RUNTIME TRACE COVERAGE: inherited PARTIAL; existing Q/R records now report
  ordinary duration/damage. This change adds no timer, search or gameplay state.
- OWNER RUNTIME TRACE EVIDENCE: NOT TESTED.
- OWNER VISUAL/AUDIO VERIFICATION: NOT TESTED.
- OWNER ENGINE ACCEPTANCE: NOT TESTED.

## Source and native-first checkpoint

Re-read installed `scripts/npc/heroes/npc_dota_hero_lich.txt` through Workshop MCP
on2026-10-03. It identifies native Frost Nova's damage/aoe_damage/radius/slow and
native Chain Frost identity; these do not justify our authored Boss exceptions.
Inspect isolated Q/R, shared pve_helpers, production KV, four source locales,
existing damage/slow/death tests and trace helper before editing. No external
code or asset imported. Required research/runtime and hero guidelines apply.

Q remains custom provisionally for the authored ten-rank curves and primary
INT0.8/splashINT0.5 formulas. Native files alone do not prove that native tuning
supports ten ranks and those independent stat-scaled components in this addon.
Do not claim native conversion impossible from its shipped rank counts. Native
override compatibility remains a required owner-engine investigation before
replacing correct Lua. Primary-versus-area accounting is a separate open review.

R remains a focused conversion for the authored once-per-distinct-target budget
and INT-scaled damage, using the actual engine tracking-projectile API. Installed
native repeat-bounce behavior differs. Compatibility of a native override with
the authored history/budget/scaling and ten ranks is not established; do not
silently restore repeated hits as a policy removal side effect.

## Regression scope and remaining gates

`tools/tests/lich_ordinary_targets.test.mjs` reads actual KV curves and executes
real isolated Q/R callbacks. All10 ranks compare normal and Boss targets with
identical relevant properties, low100maxHP and high1000INT, detecting old caps
as well as duration multipliers. R impact uses its real callback with ordinary
ranked damage and configured slow duration. Added to existing full-check runner.
Mocks do not simulate engine mitigation or status resistance, and no engine
rule was removed. Shared is_boss, unreviewed heroes and Boss-owned skills/AI/
waves/stats are unchanged. EN/TR/RU/zh-CN source strings and generated mirrors
remove only Q/R Boss-duration claims.

Owner checks: normal/Boss Q primary/splash and R projectile slow at rank1/10;
actual mitigation/status resistance/immunity/dispel; spell block and lethal
targets; concurrent chains; cold-start imports/resources; audible/visible
feedback; Shard/Scepter; reconnect and skill-point presentation. Full Lich source
review remains open; this supplement is not hero completion or runtime acceptance.

## Q particle control-point evidence follow-up

Current installed Frost Nova root and its ten children were decompiled outside
addon source using Source2Viewer-CLI19.2. Child e/f RingWave reads CP1.x for initial
radius, CP1.y for thickness and CP1.z for speed; child g uses all three for its
larger ice wave. Our Q only set CP0, leaving those inputs unconfigured. Bind
CP1 to Vector(ranked_radius,ranked_radius,ranked_radius), after resolving the
existing KV radius/fallback and before release. No damage, rank, targeting or
control formula changed in this resource repair.

Reference-only Workshop1571786267 scripts/vscripts/abilities/bosses/lich/lich.lua
PlayEffects uses that same vector binding; its source/version/license and live
compatibility are not certified and no code was imported. Installed resource
semantics, not that example alone, establish the missing input. Current MCP
CScriptParticleManager:SetParticleControl confirms API signature. Generic
[Valve particle documentation](https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Particles/Particle_System_Overview)
is background, not evidence for this resource's exact CP meanings.

Root owns ten finite children; inspected child emitters are instantaneous except
h's explicit1s continuous burst, with decay/lifetime operators. Existing index
release remains; no new lifetime timer or manual destroy is added. Owner still
must confirm disappearance after repeated casts, lethal recipients and actual
rank1/10 appearance. Cold-start resource precache already exists at
addon_game_mode.lua's explicit lich_frost_nova entry. Bounded Q trace records
resource index/radius/origin and release ownership, not a claimed visible result.

Ten-rank Q/R test now verifies actual CP1 arguments for normal and Boss casts;
it fails before binding and passes afterwards. Full project checks0fail with
contributor E work present. Q shader rendering, exact visual footprint, animation
and audio remain NOT TESTED. Duplicate caster/target FrostNova emission and
modifier lifecycle/identity still require focused follow-up. Lich SOURCE REVIEW
remains PENDING. Concurrent main ledger/dossier/E/tests changes are not claimed.

## Q targeting/sound and upgrade audit follow-up

Q now rejects friendly cursor recipients before absorb, feedback or damage,
matching native/project enemy-only KV and the explicit R/E team guards. A
meaningful fixture failed before repair when an ally's spell-absorb callback
was invoked, and now passes without feedback/damage. Emit Ability.FrostNova
once at the recipient; the duplicate identical caster emission was removed.
Existing decoded bank and reference target-centered nova emission supply source
evidence. Ten-rank fixtures check a single target emission. Actual playback,
reflect/cast-order behavior and engine targeting remain owner tests.

Read heroes/aghanim_manager.lua and four-language upgrade tokens: current Lich
is Support. Shard supplies outgoing healing25%; pulse_heal200 is configuration
without a handler. None of Lich's five spells heals, so this does not evolve
his kit, though healing items can still use the property. Scepter supplies
ultimate40% spell amplification/25% cooldown via shared properties; no Lich-
specific mechanic is implemented. Existing tooltip states those generic values
accurately. Do not count acquisition, token presence or those generic properties
as completing the owner's unique Shard/Scepter request. Native build6943 Gaze
Scepter AoE400 and Ice Spire relationship require focused native resource/
rank/slot/PvE design inspection; no arbitrary heal pulse or new active spell is
added merely to fill the gap. Upgrade source/design implementation is OPEN.

## Q/R removed-source slow properties

Inspection found inconsistent orphan properties: Q's movement slow returned0
through the safe shared value helper after ability removal, but its attack slow
fell back to40; R returned50 for both without a valid source. Those constants
were fallback values, not captured cast data. Add valid-source guards to the
three affected existing getters, matching Q's existing movement and W's orphan
mitigation guards. Valid-source ranked values and legacy fallback behavior are
preserved. No new cleanup, modifier, timer or gameplay transition is added;
existing finite modifier expiry still owns removal.

The regression exercises valid getters and then a removed ability whose value
getter throws on access. Before repair it fails on orphan bonuses; after repair
all four slow properties return0 without touching the removed source. Full
repository checks0fail. Actual removal/expiry/client replication remains an
owner-engine test; this does not claim native source-removal equivalence.
Modifier basic/strong dispel policy is separately open: current Q/W/E/R KV does
not declare SpellDispellableType and source modifiers rely on defaults. Installed
native Frost Nova, Shield and Gaze declare SPELL_DISPELLABLE_YES; current
[modifier API declarations](https://docs.moddota.com/lua_server/docs) expose
IsPurgable/IsPurgeException/IsStunDebuff. No guessed engine default or unrelated
aura purge policy is changed in this orphan-property repair.

## D source/rank ownership checkpoint

Inspected isolated D, intrinsic/recipient links, current production KV and the
shared safe value/trace helpers. D is an authored Enfos support passive, not a
native Death Charge implementation: provisionally REPLACE for this fifth Enfos
slot, preserving frost-themed allied sustain without pretending that native
creep sacrifice and this aura are interchangeable. The native-first decision
for retaining this custom mechanic and its balance remains open in the full
hero review; no ability behavior was changed in this checkpoint.

Actual current values are flat8 armor at all ten ranks, mana regeneration
4/4.6/5.2/5.8/6.4/7/7.6/8.2/8.8/9.4 and radius
400/450/500/550/600/650/700/750/800/900. Do not report armor growth per rank or
use the old unverified900-radius assumption at rank1. Property getters read
live ability values; they do not cache the initial rank.

Extended the isolated regression with real D classes and production curves.
Across all ten ranks it checks allied hero/basic aura selection, live rank
changes, Break on the actual aura source, restoration after Break, an externally
Broken recipient retaining the source's buff, recipient illusion exclusion,
unlearned source, removed source/ability and restoration of a valid source.
The removed-ability getter throws if accessed. Expectations for armor and mana
progression are stated independently of the getters rather than comparing one
getter to itself. Existing source guards pass these cases; no speculative
production patch was made to manufacture a defect.

These tests call real Lua getters, not the engine aura distributor. Death and
aura linger, multiple Lich casters/stacking, source illusions, allegiance changes,
client tooltip updates, respawn/reconnect and rank/point HUD remain NOT TESTED.
The current [modifier API](https://docs.moddota.com/lua_server/docs) separately
declares IsAuraActiveOnDeath, GetAuraDuration, GetAuraEntityReject and
AllowIllusionDuplicate; their existence does not establish defaults or prove
this aura's runtime behavior. No guessed death/purge/illusion policy, aura timer
or new global scan was added. Concurrent E/main-ledger/dossier work remains
excluded. Full hero source and engine acceptance remain PENDING.

## W immediate protection ownership repair

Re-read installed build6943 native lich_frost_shield KV through Workshop MCP:
friendly hero/basic/building targeting, damage_reduction, movement_slow,
slow_duration0.5, interval1, radius600 and dispellable=yes. Production W currently
has a narrower friendly hero/basic target contract, authored incoming-physical
reduction and INT-scaled pulses without native pulse slow. Its four-language
description accurately describes the current physical reduction/pulses; missing
native slow and native-vs-authored mitigation semantics remain design review
items, not presumed restored behavior. W remains TUNE provisionally; custom
ten-rank/scaled behavior compatibility with a native override is unproven.

Confirmed ownership defect: OnCreated and OnIntervalThink reject an invalid
caster/recipient or an enemy recipient, but the physical mitigation getter only
checked the ability. After allegiance change it could still return protection
before the next one-second pulse removed the modifier. The new real-getter
fixture fails against that pre-repair code on immediate enemy protection.
Apply the existing shield ownership conditions to the getter, without destroying
a modifier from a property callback. Invalid/removed/dead recipients, removed
casters and changed allegiance immediately return0. Caster death alone retains
the existing finite shield, matching the pulse's distinction between dead and
removed casters; no new death cancellation was invented.

Regression checks all ten production reduction ranks, immediate allegiance
change, removed caster/recipient/ability, recipient death and caster-death
continuation. It passes after repair. Current modifier API declares the existing
incoming-physical callback; no callback signature, modifier ID, shared manager,
KV or tooltip meaning changes. No Boss branch is added. Engine damage ordering,
client prediction, death/dispel cleanup and actual recast remain owner checks.
Full Lich source/design/upgrade review is still PENDING.

## Q measured damage and control lifecycle instrumentation

Existing Q primary trace contained only requested damage and cast-configured
slow duration. Capture the existing damage helper's ApplyDamage return separately
for primary impact and aggregate numeric splash returns in the existing loop.
Use actual_damage / splash_actual_total; unavailable returns are explicitly
<unavailable>, never a guessed zero or the requested number. Requested damage
continues to describe the authored formula, not an assertion that mitigation,
immunity or absorption was bypassed. The result is recorded even if damage
callbacks remove the source; safe-name logging handles removed entities.

Add diagnostic-only OnCreated/OnRefresh/OnDestroy records to Q's existing slow
modifier using the current modifier callback declarations. They do not create,
refresh, destroy or otherwise alter any modifier/particle/timer. They use the
existing server-only, default-off, shared100-per-game-second trace cap. No new
gameplay scan/state or Boss exception. Ability-class inventory callbacks remain
unchanged; concurrent inventory/E edits are not regenerated or committed.

The real-Q regression checks requested180 vs measured90 primary and measured50
splash with a50% mock ApplyDamage return; before this change the missing result
record fails. Enabled/disabled tracing yields identical requested damage and
slow durations. It verifies all three slow lifecycle records, client silence,
disabled silence, shared rate limiting and explicit unavailable measurements.
These are diagnostic/mock checks, not actual Dota damage or duration results.
Owner VConsole, audiovisual, immunity/dispel/status resistance and removal/
recast evidence remain NOT TESTED. Full Lich source/upgrade acceptance is open.

## Q/W/R explicit dispel and modifier identity

Installed build6943 native Frost Nova, Frost Shield and Chain Frost all declare
SPELL_DISPELLABLE_YES. Current Lua classes omitted IsPurgable; absence alone
does not prove they were unpurgable, because the engine's Lua defaults were not
observed. Make the native-compatible policy explicit on these three existing
effects: IsPurgable=true, Q/R harmful slows, W positive allied shield. No stun
or strong-only exception is introduced. E is excluded while its contributor
ownership is unresolved; D aura policy is separate. Current Workshop MCP modifier
API verifies IsPurgable on both realms. Data-driven KV default documentation is
not used as proof of Lua modifier defaults.

Q/R lacked explicit modifier textures and their own modifier name/description
tokens. Assign their verified existing native ability icons; add localized
modifier names, live movement/attack property text and basic-dispel information
in EN/TR/RU/zh-CN. Shield's existing live mitigation description gains a dispel
note. Regenerate only the existing localization mirrors. Descriptions use the
project's existing modifier-property token syntax, not frozen rank1 numbers.
Actual tooltip interpolation/display remains owner-engine verification.

An explicit source contract checks the three modifier policies, positive vs
negative identity and exact icon IDs; it failed before these declarations and
passes afterwards. This proves authored declarations, not execution of Dota's
Purge or particle disposal. Owner checklist: basic ally dispel removes Q/R
slows; enemy dispel removes the W shield and its modifier-owned particle/pulses;
strong dispel also works as applicable; names/icons/live values appear in all
four locales. Full Lich source/upgrade and engine acceptance remain PENDING.

## E resource decoding checkpoint (no contributor source edit)

Current installed steam.inf confirms ClientVersion6943 / SourceRevision11069754.
Decoded lich_gaze root and22 matching children outside the addon with
Source2Viewer-CLI19.2. No asset imported. Decoded-text SHA256 (not VPK binary
hash): root8AFF9DE6F773EF726949786BFE0339604E7434B67384F1BC82673FD0ED40DC02;
caster_head0E7FE26D1498320DCE66709A0993B49278FA3CAE6CA0271B32EE69FE64772730;
caster_groundAA13A5336D697218EB97424C651A6A731857B8704296DD89C389ECD21B2F21CE.

| Resource below particles/units/heroes/hero_lich/ | Observed input/operator |
| --- | --- |
| lich_gaze.vpcf | Root max particles0; eight direct child references, no root position operators |
| lich_gaze_caster_head.vpcf | CreateOnModel and LockToBone read CP2 and head hitbox; orientation initializer reads CP1; writes child CP10+ |
| lich_gaze_caster_ground.vpcf | PositionLock/CreateWithinSphere read CP3; continuous emitter2 particles/sec without explicit stop duration |
| lich_gaze_rings.vpcf | PositionLock/CreateWithinSphere read CP3; continuous emitter5 particles/sec without explicit stop duration |
| lich_gaze_head.vpcf | Model/head-dependent operators, CP1 local offset; publishes child CP10+ |

Current E uses GetEffectName on the recipient and ABSORIGIN_FOLLOW, with no
explicit SetParticleControlEnt. This is not sufficient evidence that the engine
automatically supplies this root's CP1/2/3/model inputs correctly. Conversely,
the decoded files alone do not prove which additional bindings the engine's
modifier-effect path supplies: do not label every missing explicit binding an
observed engine defect. Persistent children require modifier-owned cleanup;
releasing an index on cast alone would not establish channel termination.

Reference-only current local corpus: Workshop2578571357 (IMBA-AI Ver0.53),
scripts/vscripts/abilities/hero_ability/lich/imba_lich_sinister_gaze.lua,
recipient PlayEffect explicitly uses CP0 recipient hitloc, CP1 caster portrait,
CP2/3 recipient origin and manual destroy/release on removal. Its separate caster
eyes effect uses attach_eye_l/attach_eye_r. Importantly, this maps CP2/3 to the
recipient despite misleading caster_* child filenames. It cannot certify the
current native C++ bindings, and no code/assets were copied. Exact upstream
version/license/asset permissions remain unverified. Workshop2208582400
(Aghanim's Pathfinders), scripts/vscripts/heroes/lich/lich_pf_sinister_gaze.lua,
also separates caster eyes and recipient feedback, emits Target on recipients,
and stops Cast/Target events on channel/effect removal. Its custom Boss rules
and extra mechanics are outside our policy and are not adopted.

Decoded current sound bank declares SinisterGaze.Cast using dark_ritual,
duration3.320204s/fade-out0.25, and SinisterGaze.Target using
frost_blast_immortal, duration3.96s/fade-out1. These event declarations do not
establish underlying sound looping. Current E emits Cast only, with no matching
StopSound or target event. The stop/target-feedback policy is open; do not claim
an infinite audio leak from event duration alone. Stop ownership must account
for interrupted/replaced channels and avoid stopping a newer cast's audio.

Next E resource acceptance needs a current-native or owner-engine CP/binding
comparison, explicit resource ownership if required, caster/recipient movement,
rank1/10 duration, normal/Boss targets, interrupt/expiry/dispel/death/recast and
no stale audio/particle after removal. Retain this evidence while waiting for
the editor ownership clarification; E, contributor tests/KV/main ledger/dossier
are unchanged. E Boss35% duration and no-pull remain known pending policy
removals. No Lich source/visual/audio/engine completion is claimed.
