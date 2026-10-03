# Lich ordinary-target policy follow-up — 2026-10-03

Supplement to `LICH_INDIVIDUAL_REVIEW_2026-10-03.md`, following owner goal
revision db8ef7c. Historical Boss-cap/duration statements in that ledger and the
hero dossier describe superseded behavior for Q/R; they are not current policy.
The main ledger/dossier and E/tests/KV are concurrently being edited by another
hero session and were deliberately excluded from this isolated commit.

## Current scoped result

Latest policy update below supersedes historical E-pending statements in this
document: all authored Lich Q/R/E Boss gameplay exceptions are removed in current
source. Engine acceptance and full hero source/upgrade review remain pending.

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

## D four-language passive and recipient tooltip repair

Runtime-checklist preparation exposed a source localization defect: only Turkish
authored D title/description; EN/RU/zh-CN generated mirrors silently fell back to
Turkish. The description omitted friendly recipients, ranked radius, source
Break and recipient illusion exclusion. The recipient aura buff had no authored
localized property description. These are observed source omissions, not a
claimed engine tooltip failure.

Author explicit D title/description/summary plus intrinsic and recipient modifier
names/descriptions in all four locales. Ability text uses real radius/armor/mana
KV placeholders and explains existing source-Break and illusion behavior. Buff
text uses current armor and constant-mana property placeholders instead of
freezing rank1 values. The intrinsic tooltip describes aura ownership; it does
not claim the intrinsic itself grants property bonuses. Gameplay, rank curves,
engine aura distribution and death/linger policies stay unchanged.

Regression requires explicit locale keys, three ranked ability placeholders and
both actual recipient property references, preventing missing text from being
masked by Turkish fallback. Existing localization generator synchronizes source
mirrors. Actual signed/decimal property interpolation, range display and passive
HUD integration remain owner tests; source texts and mocks are not visual PASS.

## E ordinary-target policy removal with isolated staging

Revalidated Codex task state: this was the only active Codex task in the workspace;
other listed tasks were idle/not loaded. Inspect E's exact contributor diff
before editing. Preserve its targeting/mana/ownership/precache/trace changes,
contributor KV/tests/main-ledger/dossier edits and external pre-change copies.
Remove only the unchanged legacy Boss branches: channel35%, control35%, no-pull.
No ordinary formula, native target/unit rule, state, cadence or Boss-owned code
changed. E remains PVE-CONVERT for custom ten-rank channel/mana tuning and
authored pull; native-first compatibility and resource acceptance remain open.

Build the Git index E/tests entries from HEAD with only these policy/expectation
edits applied. Review cached diff to prove unrelated uncommitted contributions
are excluded, rather than committing the full working file. Contributor work
stays uncommitted and active in the worktree. Update the pre-existing regression
that asserted1.33 Boss channel to ordinary3.8; unrelated hero expectations stay.

New real-E fixture reads actual ten-rank duration/mana curves and compares
ordinary/Boss units differing only in Boss identification. It fails before
repair on the shortened channel. After removal both channel/control use the
ordinary ranked duration, mana transfer remains maxMana×rankedPercent×0.5,
and both recipients use the same40-unit pull/clear-space handling beyond100.
This test does not simulate engine status resistance, immunity or actual paths.
Four-locale E description/summary and generated mirrors remove stale Boss rules;
owner checklist now expects source parity, not certification. All source-owned
Lich Boss exceptions are removed; resource CPs, upgrades and owner-engine tests
are still pending. Historical contributor ledger statements remain superseded
by this supplement and are not overwritten.

Validation: full working-tree checks0failed; contributor-aware suite still passes.
Independently execute the staged E implementation with staged historical hero
regressions:352 cases pass. Execute the new ten-rank ordinary/Boss fixture against
that staged E too:PASS. This avoids relying only on contributor code that the
isolated commit will not contain. Native engine distribution/mitigation remains
outside these mocks; no engine acceptance is asserted.

## E explicit dispel policy and channel-removal regression

Installed build6943 native `scripts/npc/heroes/npc_dota_hero_lich.txt`,
`lich_sinister_gaze`, declares `SpellDispellableType=SPELL_DISPELLABLE_YES`.
[Current Lua API](https://docs.moddota.com/lua_server/docs) distinguishes
`IsPurgable` from `IsStunDebuff` (stun classification for purge reasons).
The custom modifier previously left both policies implicit. Declare purgable=true
and stun-debuff=false to preserve native hypnosis basic-dispel intent while
retaining its existing action lock. This makes policy explicit; it does not prove
the previous engine default was faulty, or certify actual Purge behavior.
Disposition remains PVE-CONVERT; no duration, damage, pull or Boss-owned rule changes.

New real-module regression checks ownership detach before EndChannel callback,
matching-channel interruption, duplicate removal, stale target versus newer cast,
another active ability, removed source and client-side cleanup. It does not
simulate engine Purge or establish actual visual/audio cleanup. Add explicit
four-locale control modifier names/descriptions and generated mirrors.
Basic/strong dispel, repeated casts and native hypnosis classification remain
PENDING OWNER TEST. Existing contributor E work remains uncommitted and excluded
from the isolated index entry.

## W native pulse slow restored (TUNE)

The native `lich_frost_shield` KV in installed build6943 explicitly declares
movement_slow20/25/30/35, slow_duration0.5, interval1 and radius600. The existing
custom pulse only applied damage, losing the native area-control component that
is useful against creeps too. Restore it with an isolated W slow modifier and
explicit bootstrap dependency. No other custom game code is imported.

Balance decision: retain the native first four slow anchors and hold35% at ranks
5–10 rather than invent stronger control. This is authored ten-rank tuning, not
a claim that native Dota has ten ranks. Ordinary and Boss units use identical
duration/slow formulas. Preserve current pulse damage, INT scaling, duration,
friendly-target contract and physical reduction. Native attack-only versus
authored all-physical mitigation remains an explicit comparison; do not silently
change the existing defensive promise as part of this pulse repair.

Apply slow only after damage, on a still-valid living victim and source. Reuse
the existing one-second pulse search: no new thinker, timer or target scan.
Slow is a visible purgable debuff with Frost Shield icon, safe live rank getter,
and bounded shared creation/refresh/removal diagnostics. Removal needs no custom
particle or sound disposal: those remain owned by the shield modifier. Actual
native slow/status visuals and immunity/status-resistance behavior remain owner
checks, not established by absence of Lua errors.

Real-module regression covers all ten ranks, independent native slow anchors,
ordinary/Boss parity, half-second duration, unchanged scaled magical damage,
lethal victim guard and removed-source getter. EN/TR/RU/zh-CN descriptions and
live modifier-property text are regenerated. Preserve contributor E/KV/ledger
work and stage only the W KV and inventory entry from HEAD. Source slow repair
is complete; full hero/upgrades and owner-engine acceptance remain pending.

Validation: all9 focused Lich regressions PASS; cold-load isolation route includes
the new W modifier and remains PASS; full working-tree checks0failed. Separately
run the indexed historical hero suite with indexed E, excluding its contributor
edits:352 regressions PASS with the new W module. No real Dota test was performed.

## Native localization closes W mitigation comparison; cast identity corrected

Extract the complete installed build6943
`resource/localization/abilities_english.txt` outside the repo with Source2Viewer
CLI19.2; the MCP200000-character read truncates this1,844,945-character file before
the relevant Lich ability entries. Inspect the full extracted text instead.
Native Frost Shield description explicitly says damage from attacks, not all
physical damage. Its native modifier description agrees. These primary source
texts resolve the earlier W mitigation comparison: TUNE native attack reduction,
preserve the authored ten-rank percentages and shield ownership/lifetime.

Replace the incoming-physical property with incoming-damage conditioned on the
engine `DamageCategory_t.DOTA_DAMAGE_CATEGORY_ATTACK` event field. Verified
Workshop API declares GetModifierIncomingDamage_Percentage(event), OnTooltip,
and DamageCategory_t values SPELL0/ATTACK1/BARRIER2. No category or a spell/barrier
event gives0; an attack may qualify independently of physical/magical/pure type.
No Boss-specific policy or per-hit diagnostic logging is added. The live tooltip
reads a separate guarded reduction getter via MODIFIER_PROPERTY_TOOLTIP; it does
not depend on a combat event being available while hovering. Four-locale skill/
buff texts now describe attacks and pulses, superseding historical physical-only
text. Expanded real-module tests cover categories, missing data, live tooltip,
all ranks and source/recipient ownership. Actual engine category/proc routing and
damage ordering remain PENDING OWNER TEST, especially attack-associated spell
procs and physical spells.

Installed hero KV specifies Frost Nova ACT_DOTA_CAST_ABILITY_1, Frost Shield2,
Sinister Gaze3 and Chain Frost6. Enfos R is in slot4, so relying on slot-derived
animation loses the native ultimate activity. Set Q/W/R explicit verified
activities1/2/6 without changing cast points or forcing Lua gestures.
[KV animation documentation](https://moddota.com/abilities/ability-keyvalues#abilitycastanimation)
confirms explicit activity selection. Q/W are explicit identity metadata, not
claims that their prior default was visibly broken. Contributor E animation3 is
already in the worktree and stays excluded from this commit. Observe Q/W/R casts
on the actual Lich model; source activity presence does not certify animation.

## Upgrade investigation — still open, not certified

Full installed localization establishes native Scepter Gaze affects a target
area and allows other abilities while channeling; KV aoe_scepter400. Current
generic ulti40% damage/25% cooldown is not that feature. Native Ice Spire is an
extra Shard ability: slowing totem, hero/creep hit counts4/8, duration15, death
Frost Blast, a Chain Frost bounce/primary target and Frost Shield healing per
pulse. Installed unit `npc_dota_lich_ice_spire` has model
`models/heroes/lich/ice_spire.vmdl`, immobile/no attack/Other ward classification;
its icon and root particles exist in VPK. Availability does not prove native C++
integration with stable custom Q/W/R IDs or engine modifiers.

Current Support Shard adds healing25%; `pulse_heal200` in role data is unused by
the manager and none of Lich's five abilities heals. Items/other effects may use
the amplification; do not falsely claim the item has no effect anywhere.
Ask owner whether to add native-style extra Ice Spire or adapt existing five
slots. No silent new ability, native alias, fake sixth passive, guessed resource
binding or generic extra healing implementation is introduced while comparing
the full interaction. Unique Shard/Scepter implementation and its resource/
channel/reconnect acceptance remain open; they are not marked DONE by green
regressions or purchase detection. The new source evidence is stronger than
the earlier KV-only generic-upgrade comparison.
