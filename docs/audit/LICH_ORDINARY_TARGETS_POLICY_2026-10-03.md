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
