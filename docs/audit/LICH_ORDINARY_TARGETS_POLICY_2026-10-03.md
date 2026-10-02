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
