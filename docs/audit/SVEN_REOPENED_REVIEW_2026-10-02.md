# Sven full-kit reopened review — 2026-10-02

Owner reported Sven broken in local Workshop Tools testing and requested the entire
hero be rechecked against the existing goal, not a single inferred symptom.
This reopens the prior source review; it does not revoke or manufacture historical
runtime evidence. **Current engine acceptance is PENDING.**

## Evidence and scope

### Current acceptance ledger — owner-expanded goal, 2026-10-03

- SOURCE REVIEW: PENDING (reopened individual review and standardized tracing unfinished).
- DESIGN DECISION: Q TUNE; W PVE-CONVERT; E TUNE; R PVE-CONVERT; D REPLACE.
  The rationale remains in the per-slot review below; these are not engine passes.
- PROVEN DEFECTS: repaired findings below; further individual review in progress.
- MOCK/REGRESSION VALIDATION: PASS for the recorded repaired cases; no engine simulation claim.
- RUNTIME TRACE COVERAGE: PARTIAL. Q/W, E cleave dispatch and R pulse now use the
  common default-off debug gate; ultimate pulses correctly use R. Detailed
  lifecycle/upgrade/control branches and actual fifth-slot D coverage remain open.
- OWNER RUNTIME TRACE EVIDENCE: NOT TESTED for the current revised source/build.
- OWNER VISUAL/AUDIO VERIFICATION: NOT TESTED for the current revised source/build.
- OWNER ENGINE ACCEPTANCE: NOT TESTED.
- REMAINING ENGINE-ONLY TESTS: every row in SVEN_RUNTIME_CHECKLIST.md remains pending.

- Installed `steam.inf`: ClientVersion/ServerVersion 6943, SourceRevision 11069754.
- Re-read full native `scripts/npc/heroes/npc_dota_hero_sven.txt` through Workshop MCP.
  Native Storm Hammer/Great Cleave/Warcry/God's Strength identifiers, target rules,
  animations, sound events and AbilityValues agree with the recorded counterparts.
- Read hero KV, all five ability KV/Lua classes, linked modifiers, bootstrap,
  precache, roster, match levels, innates and Aghanim manager. All five still use
  modern AbilityValues, ten ranks and the intended gates. No talent/profile system
  was restored. Match level 50, initial level 6/five spendable points and free fifth
  rank remain owned by existing match/innate managers.
- Local addon directory is a junction to this repository's `game` directory.
  There is no separate stale copied Lua directory at that local path. A running
  match still needs a full restart to load changed scripts/resources.
- Git diff from published source `90ac68d` to the starting review tree contains
  no Sven kit changes. The owner's suspected model-switch origin is **unproven**;
  changing an assistant model is not itself evidence of a gameplay regression.
- Read-only live MCP console buffer was empty. Disk console.log last modified
  2026-10-02 23:25:15 contains TreeShop_OnStartTouch/EndTouch errors, but no matching
  Sven traces or pve_kits traceback in the inspected filter. Those map-shop errors
  are separate findings; absence of a Sven traceback is not a gameplay pass.
- Reference-only comparison: Workshop 1571786267,
  `scripts/vscripts/heroes/hero_sven/sven_warcry_lua/sven_warcry_lua.lua` read again.
  Its cast head binding matches the independently decoded native cast evidence.
  Version/license unresolved; no external code imported.
- [Current cleave API declaration](https://docs.moddota.com/lua_server/declaration)
  confirms eight arguments. No guessed API signature or manual cone replacement.
- [Modifier tooltip documentation](https://moddota.com/abilities/modifier-properties-in-tooltips)
  supports live modifier properties and TOOLTIP2. W's remaining barrier uses its
  replicated stack count, not a server-only client variable.

## Full-kit decisions and repairs

| Slot | Classification retained | Source review / repair | Engine gate |
| --- | --- | --- | --- |
| Q Storm Hammer | TUNE | Tracking travel, magical AoE, boss stun cap, ten ranks, KV cast animation/sound preserved. Stop after damage invalidates source; never stun a killed/removed victim. Snapshot trace name before damage; reject primary that became friendly in flight. Bind native impact CP1/CP3 to hit position. | Dodge/loss, absorb/reflect timing, magic/debuff immunity, resistance, Scepter landing, rank1/10 VFX/audio pending. |
| W Warcry | PVE-CONVERT | Existing armor/speed/barrier/taunt/runner exclusion/boss25% retained. Replace unconfigured legacy persistent root with decoded native armor child and glow, overhead CP1 bound to each recipient. Modifier owns cleanup; refresh creates no extra particle. Refresh taunt orders to current caster; invalid/dead/friendly sources cannot start taunt. Add actual taunt name/icon and current armor/speed/remaining-barrier tooltip in four locales. | Actual shield visibility/height, purge/death, multi-caster overwrite, barrier mitigation and Shard reflection pending. |
| E Great Cleave | TUNE | Verified native DoCleaveAttack still owns damage/VFX. Ten-rank curves, half-width API convention, lethal-primary dispatch, normal/R particles preserved. No dispatch from removed/unlearned sources, invalid parent, Break or illusions. | Native collision/geometry, armor/immunity, buildings/wards and lethal hits in real packs pending. |
| R God's Strength | TUNE | Existing base damage/STR/defense and1.5s physical pulses preserved, non-dispellable primary modifier. Remove undocumented +150% fallback from removed ability. Invalid interval stops, invalid/dead sources destroy modifier, source removal during damage stops traversal. Pulse impact uses decoded CP1/CP3 binding, still max six visual victims. | Transform appearance, cast/expiry, refreshed STR stats, boss behavior and Scepter ally duration/removal/Blessing pending. |
| Fifth Unbreakable | PVE-CONVERT | Authored tank sustain remains distinct from native innate/facet. No bonuses from unlearned/removed source, invalid parent, Break or illusions. Existing live rank KV reads and strict below40% Shard regen threshold preserved. | Free rank presentation, rank refresh, maxHP recalculation, death/reconnect and client stats pending. |

### Native particle evidence

Source2Viewer-CLI 19.2 decoded the installed native files into an external temporary
review directory; no native assets were copied into the addon.

- `sven_warcry_buff.vpcf`: root CP1.x remaps0..1000 to a radius multiplier0..32.
  Its `sven_warcry_armor_buff_model.vpcf` child and glow both position-lock and
  initialize at CP1. The old GetEffectName supplied neither contract. A guessed
  numeric CP1 radius would move the armor child to a bogus world location.
- Use the independently decoded armor child directly, with CP1 entity-bound to
  the recipient's `PATTACH_OVERHEAD_FOLLOW` (current MCP enum7), one AddParticle
  owner. Armor model SHA256:
  `64706e1b84c46061f0332f76b2e59a9f4a68f65015365335e1f693680a795205`.
- `sven_storm_bolt_projectile_explosion.vpcf` root and flash/trail initializers
  use CP3; wave child PositionLock uses CP1. Both were unset in Q and R pulses.
  A Sven-only helper sets CP0/1/3 to impact position and releases the finite index.
- God's Strength cast root was decoded: finite burst, own CP-position setup and
  children. No arbitrary head/weapon binding was added based on unrelated ambient
  particles; sustained transformation/cosmetic composition is an engine gate.
- Warcry head cast burst, cleave resources and God's Strength resources keep their
  existing precache owners. New armor-child resource has explicit W precache.
  Names/paths and declarations alone do not prove visible or audible playback.

## Verification

Baseline:318 mock hero tests passed before edits. Added seven meaningful cases:
removed Q victim; inactive passive sources; W CP1/ownership/refresh; multi-caster
taunt refresh; removed-R fallback/interval; removed caster during R pulse; Q/R
impact CP coordinates away from world origin. The removed-Q, removed-R and impact
coordinate tests were each observed failing before their corresponding repairs.
After repairs: **325 mock hero tests pass**. Full project checks are recorded after
the final validation below. Tests do not render particles, simulate native cleave
collision or certify current engine event/point behavior.

Final validation: `npm run check` passed with0 failures (project contracts,
behavior suites, localization mirrors, progression,48 normal-wave pressure checks,
12 native boss preparation/activation mocks). `git diff --check` passed. Generated
localization diff is limited to W's live modifier text and the missing taunt labels.
An unrelated untracked `game/panorama_debugger.cfg` appeared during review; it was
left untouched and excluded from this work unit.

No Dota launch, NVIDIA changes, Workshop upload or remote publication in this work
unit. Owner retains runtime testing. See [owner checklist](SVEN_RUNTIME_CHECKLIST.md).

## 2026-10-03: owner reports intermittent E; prior width assumption corrected

No chance roll, cooldown or intentional alternating-hit rule exists in E. A valid
learned real Sven's landed hostile attack should dispatch cleave unless Break is
active or resolved damage is zero; eligible secondary targets still depend on
native cone collision. The owner reports E sometimes failing in local testing;
the actual failed hit has not been captured. MCP stream health probe failed after
the available buffer showed game shutdown; an empty follow-up cannot certify an
error-free match. Disk log has only the earlier unrelated tree-shop errors in the
inspected filter. Owner engine reproduction remains required.

Re-read current6943 native `sven_great_cleave`: starting width150, ending
270/300/330/360, distance400/500/600/700. Current MCP's eight-argument
`DoCleaveAttack` declaration names startRadius/endRadius. Reference-only Workshop
1571786267 `heroes/hero_sven/sven_great_cleave_lua/sven_great_cleave_lua.lua`
passes150/360 directly and computes cleave from `params.damage`. No imported code;
source version/license remains unresolved. An attempted raw Elfansoer path404ed
and was not used as evidence.

The previous conversion commit `2f00cd6` halved the authored width values because
the reviewer treated them as full cone widths. This was an unsupported mapping
for the native convention. The previous mock expected those same half values,
so passing it did not validate the convention. **That earlier source acceptance
was too broad.** Retain TUNE identity and native engine dispatch, remove the extra
halving; authored KV numbers/ten-rank percentages/distance are unchanged. Actual
side reach doubles relative to the faulty conversion; localized descriptions now
explicitly describe side reach from the centerline in all four languages.

The old `e.original_damage or get_atk(...)` also ignores `e.damage`: an explicit
zero original_damage is truthy in Lua and yields zero cleave despite positive
landed damage; absent original_damage substitutes an average rather than the
actual critical hit. E now prioritizes numeric landed `damage`, uses original_damage
only if that field is absent, and invents no average damage. Nonpositive resolved
damage/distance dispatches nothing. Break, illusion, learned-source and lethal
primary checks remain.

Updated geometry dispatch regression first failed before repair. Added landed
damage cases:damage200/original0 =>100 cleave at50%; critical600 without original
=>300; damage0/original200 =>no dispatch.328 hero mock tests and project checks
pass. Native collision, event fields/armor interaction, actual secondary damage
and visible effect still need owner verification; these source defects are
plausible contributors, not a proven diagnosis of the specific missed hit.

## 2026-10-03: Q cursor radius and immediate consumed-Shard recognition

Q retains TUNE: the unit-target/AOE KV has a live radius special (250 at rank1,
340 at rank10), but no AoERadius field or Lua GetAOERadius implementation supplied
that value to the cursor. Installed MCP CDOTA_Ability_Lua:GetAOERadius confirms
the both-realms cursor callback; [API documentation](https://docs.moddota.com/lua_server/)
agrees. Add the callback using the same radius as impact, with no gameplay changes.
The targeted test failed on the absent method before repair. Visible circle remains
an owner engine test, not certified from the callback alone.

W and D checked only the legacy item marker or modifier_enfos_shard_upgrade.
The existing Aghanim manager recognizes modifier_item_aghanims_shard_consumed
and modifier_aghanims_shard_consumed, then attaches the role marker during its
one-second poll (only for living selected heroes). A cast before that poll could
snapshot a W barrier without its extra25% maxHP for the whole buff. Recognition
now includes both existing consumed markers immediately for barrier, physical
reflection and low-health regen, retaining both previously supported markers.
No manager, timer, upgrade balance or other hero is changed. The targeted consumed
marker case failed before repair; both markers, the40% HP boundary and marker
removal are checked. The test fixture explicitly calls OnCreated because this
mock does not implement the engine modifier lifecycle; damage is asserted from
ApplyDamage dispatch, not an HP simulation this mock does not provide.

Scepter/Blessing was also inspected: items/aghanims_blessing.lua and
economy/ascended_shop.lua apply the native modifier_item_ultimate_scepter_consumed
alongside the custom stats marker. The custom stats marker alone declares no
Scepter property, but the real purchase/consume paths provide the native marker.
Do not infer a proven HasScepter failure from the custom modifier alone. Actual
consumption, status-resistance replication and Q/R effects remain owner tests.

330 hero regression mocks pass after these repairs. Standardized trace work is
still pending; this is not a Sven source-closure or engine-acceptance claim.

## 2026-10-03: bounded runtime trace foundation, Sven first

Inspected lib/log.lua and addon/shared-kit logging before introducing the small
lib/hero_trace.lua diagnostic helper. Existing Log has level/subsystem filters,
but no single hero-trace convar or dense-wave output cap. Workshop MCP confirms
Convars:RegisterConvar and GetBool are available in both realms. The helper
registers `enfos_hero_trace` default0 and permits server output only. Set it to1
in the owner's VConsole for diagnostics, and0 to silence traces. Registration and
actual console use remain engine-pending. No game is launched by this change.

The helper caps total output at100 lines per existing game-clock second, across
all users of this shared module; without a clock it conservatively caps the module
lifetime. Diagnostic counters are not hero gameplay state. There are no added
timers, modifiers, target scans, particles, cleanup calls or damage events. Safe
entity names tolerate null/deleted/throwing handles; formatting failure cannot
escape as a gameplay error. No getter is instrumented.

Sven's previous unconditional Q/W traces now use this gate. E records the real
cleave dispatch damage and geometry after the existing engine call; it does not
claim a secondary hit count, because the engine return contract does not prove
that count and adding a target search merely for logging is forbidden. The old
ultimate pulse D label was corrected to R. This is only PARTIAL coverage: fifth
slot lifecycle, upgrade/control branches and other important events are still
being reviewed, so source completion remains PENDING.

A meaningful helper regression verifies default0 registration, disabled output,
server-only output, removed handles, format failures, the100-line cap and next
second rollover.331 hero regressions pass. Actual convar registration and output,
native E collisions, particle appearance and audio remain owner engine tests.
