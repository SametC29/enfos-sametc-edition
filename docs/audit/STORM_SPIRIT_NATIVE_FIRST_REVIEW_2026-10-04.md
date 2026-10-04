# Storm Spirit native-first discovery

SOURCE_REVIEW: discovery complete, implementation pending. OWNER_RUNTIME:
PENDING for every slot. This report precedes production changes; historical
mock PASS entries in the dossier do not certify the proposed native kit.

## Evidence

Installed Dota build6943 / revision11069754 / Oct01 2026. Re-read native
`scripts/npc/heroes/npc_dota_hero_storm_spirit.txt`; SHA256
`02996ee5b413c86b193d109253e723ed3dabe87cbbe5002362f863b1b02c823c`
matches the [fresh snapshot](STORM_SPIRIT_NATIVE_SOURCE_2026-10-04.json).
It records six definitions, native English localization and seven verified
resource hashes. Repeated native header `resource` keys are preserved in
headerRaw; only AbilityDefinitions uses the strict project KV parser.
AbilityDraft's nested slots are not the native hero's assigned slots.

Production inspected: Storm's five KV blocks in npc_abilities_custom.txt,
all five Lua implementations in abilities/pve_kits.lua, hero dossier,
heroes/innates.lua restore dispatch and addon_game_mode.lua precache.
All five are currently CUSTOM Lua. No Storm-specific native restore branch
exists. Six Storm particles are registered, but the explicit sound-bank
list lacks `stormspirit`; native bank existence alone does not prove audible
playback. No new engine session was launched.

[ModDota's BaseClass reference](https://moddota.com/abilities/ability-keyvalues)
supports native aliases with exposed KV values; it does not establish their
internal linked-name lookups or ten-rank C++ behavior. Those remain test gates.

## Pre-mutation slot matrix

| Slot / stable ID | Existing authored behavior | Verified native counterpart | Class / planned ownership |
| --- | --- | --- | --- |
| Q `enfos_storm_static_remnant` | Self-planted thinker; trigger and damage share240..330 radius; damage100..390 + INT1.2; lifetime8..12; manual feedback | `storm_spirit_static_remnant`: trigger235, damage300, delay.75; point-target field1/range800/travel300; native remnant and cleanup | TUNE; NATIVE preferred, NATIVE+MINIMAL EXT only if preserving INT needs a verified damage bridge. Preserve authored damage/CD/cost/lifetime, keep trigger and damage keys distinct. |
| W `enfos_storm_electric_vortex` | Target-centered AoE stun, no pull; duration.8..2.6; main target Boss flag changes everyone's duration | `storm_spirit_electric_vortex`: native single-target pull, tether1200, strong dispel; Scepter radius475 conditional | TUNE; NATIVE alias restores pull and Scepter. Retire ordinary-cast custom AoE stun/Boss duration. Preserve authored ten-rank duration/CD/cost/range; use verified native pull keys. |
| E `enfos_storm_overload` | One boolean charge; items can charge; five-second expiry; excludes killing target; damage25..190 + INT.6; movement slow only | `storm_spirit_overload`: native charges/discharge, attack and movement slow, Shard activation3 charges/12s/40AS | TUNE; NATIVE preferred, minimal raw INT scaling bridge only if verified. Preserve authored damage/radius; native owns charging, slows, Shard and feedback. No second Lua proc. |
| R `enfos_storm_ball_lightning` | Instant teleport clamped900..1800; arrival-only damage35..80 + INT.1 per100; flat travel mana18..9; Boss cap | `storm_spirit_ball_lightning`: continuous flight1400/1850/2300, root restriction, path damage, native mana exhaustion; initial25+7.5% and travel10+.65% per100 described in native text | TUNE; NATIVE preferred. Retire teleport/arrival damage/Boss cap. Damage header6/10/14 differs from tooltip per100 units: verify native interpretation before translating authored35..80. Preserve native percentage mana component; record flat-cost tuning explicitly. |
| D `enfos_storm_galvanic_core` | Independent paid ten-rank mana regen1..4.2/INT4..24, Break/illusion suppressed; no native innate | `storm_spirit_galvanized`: rank1 innate, charge every3 levels/kills, lose2 on death, regen.2 plus match-local permanent.1 per gained charge | TUNE; exact native innate plus separate CUSTOM paid stat modifier, NATIVE+MINIMAL EXT overall. No cloned charge/death logic. Creep credit remains unproven; PVE-CONVERT only if evidence establishes the missing component. |

These are implementation targets, not assertions that a native alias already
works. Every stable paid slot remains10 ranks; Q/W/E/D gates1/1, R5/5;
level50, level6 start, five ordinary starting points and free D1 stay in the
existing shared service. Exact native helper ranks must not consume points.
No talent or persistent profile progression is introduced.

## Specific source findings and unresolved read paths

Q's native header says NO_TARGET, while `is_point_targeted=+1` and the current
English description specify a remnant walking to the chosen point, including
self-cast. Preserve those exact native fields and inspect the real targeting
HUD before adding behavior overrides. Do not assume a facet grant. Current
Lua deletes its thinker on caster death and scans every.2s; migration should
delegate actual remnant lifetime, arming, vision and cleanup to C++.

W currently never pulls. Ordinary native targeting, block/reflection, immunity,
status resistance, target death and Scepter transition belong to native code.
The conditional radius object has no base `value`; adding475 unconditionally
would change ordinary casts. Native enemy_overload_duration is0; no invented
extra Overload buff or blanket Boss control exemption.

E must precede linked casts in the migration. Exact native Overload identity
may be necessary for Q/W/R C++ charge lookups; an alias-only lookup has not
been proven. Native modifier names must be queried rather than guessed.
Current code accepts items as charge events, skips killing hits and lacks
native attack slow. Preserve engine charging and attack resolution instead
of patching the copied proc. `storm_spirit_electric_rave` is defined but not
assigned in the native hero header. Definition existence does not authorize
an additional button; verify whether native E handles Shard activation.

R has AbilityManaCost30 alongside initial25+7.5% keys: do not add both manually
or claim their actual C++ arithmetic from KV alone. Damage header6/10/14 also
requires actual read-path/unit verification. scepter_remnant_interval300
exists without HasScepterUpgrade on R; do not assign ownership from its name.
Native flight/path damage/untargetability/arrival/exhaustion/recast remain
owner tests, including behavior when rooted and when mana runs out mid-flight.

D's native permanent regen refers to the current match, not account storage.
Kill eligibility, level50 charge increments, Break and death/respawn behavior
remain unverified. Do not manually write native stacks or ForceRefresh the
innate on restore. Keep paid stats separate from native level-based charges.

Installed W owns Scepter and E owns Shard. Current custom R/D flags and generic
Mage upgrade bonuses must be reviewed against the existing scoped ownership
patterns before migration. Suppression must apply only to the migrated Storm
kit and preserve every other Mage. No facet/talent/legacy button restoration.

## Other-game references and imports

WORLD OF DOTA2880603428 has no searched native remnant implementation;
Boss Survival1571786267 has no searched Storm match; Watcher3164617180
matches native headers/cosmetic mappings, not a five-slot conversion.
AGHANIM'S PATHFINDERS2208582400 `scripts/npc/npc_abilities_override.txt`
remnant block uses native NO_TARGET with separate235 trigger/260 damage radii,
delay1, mana25 and damage100. Its Brewmaster encounter precaches the native
Storm bank/remnant. This is an older native override example, not proof of
current point targeting, hero INT composition or linked charge behavior.
Exact upstream version/license not established: REFERENCE_ONLY, no imports.
All proposed code remains independent and uses verified Valve resources.

## Implementation sequence and owner acceptance

Establish E native identity/raw rank bridge first, then Q linked charging/
targeting, W pull/Scepter, R flight/mana/damage, and D innate/stat separation.
Use existing restore/client registration/automatic Health and bounded trace;
no new manager, per-frame scan, console command or gameplay probe for logging.
Only custom modules need ScriptFile; pure native aliases have no empty wrapper.
Read-only Health queries do not prove actual damage or cached scaling.

Focused meaningful fixtures cover raw value lookup, context availability,
untrained/ten-rank/Break/illusion guards, native identity restoration without
point or stack duplication, scoped upgrades, locales and removal of duplicate
casts/damage. Full checks belong at a production source boundary; this unit
only validates discovery records and makes no new gameplay-test claim.

Owner runtime later: full restart after structural KV/bootstrap changes;
select Storm and obtain automatic Health. Test Q point/self placement and
separate trigger/damage rings; E spell/item/miss/killing-hit charging; W pull,
block/reflect, Scepter groups; R path hits, mana exhaustion, root and recast;
D level milestones, Break, death/respawn and creep/hero kill credit. Cover
rank1/10, points/HUD, dense waves, visual/audio loops, cleanup and reconnect.
VConsole must be correlated to the tested revision. No engine PASS until
actual observations establish each applicable acceptance field.

## E source unit — implemented, engine pending

Paid E now uses abilities/heroes/storm_spirit/e.lua with one exact native
storm_spirit_overload provider. Native rank0 until learned, rank1 thereafter;
the hidden provider satisfies exact-name lookup compatibility without a
second native intrinsic on the paid slot. Existing pre-XP free-D restoration
creates the scaling modifier before provider rank-up, only for the real
owned hero. Restore never refreshes charges, writes stacks/points or resets
cooldown. All ten paid ranks use raw overload_damage25..190/overload_aoe220..360
plus INT.6; C++ owns charging, item/miss/killing-hit decisions and feedback.
Whether it reads those raw values at creation or discharge is engine-pending.

Decision: native movement slow80%, attack slow90 and duration.8 replace
the former18..55% movement-only slow/.4..1.3 duration. The five-second Lua
charge timeout and manual damage/slow/particle/sound paths are retired.
Break/illusion charge behavior remains native; do not infer its acceptance
from the removed custom guards. Paid E forwards dynamic native behavior,
strips HIDDEN for the HUD, reads conditional native Shard cost/CD/radius and
delegates one server-only native OnSpellStart. It does not grant Electric Rave.
Actual Shard activation through this bridge, charge count and whether the
paid cast itself generates an unintended charge remain owner test gates.

GetBehavior/GetSpecialValueFor are BOTH, OnSpellStart SERVER;
CDOTA_BaseNPC_Hero:GetIntellect(skipNoConsume) BOTH, called with false.
CDOTA_BaseNPC:HasShard was not found: no guessed call was added. Native
conditional Shard values determine cost/CD without importing server managers
into client callbacks. GetCastRange returns0; no client native range call.
One new scaling class makes19 reviewed client links; native intrinsic name
is queried by automatic Health rather than hard-coded. Health reads rank,
presence, damage/radius/Shard charges without mutation or a new timer.

Storm-only Shard ownership hides/disables generic Mage15% spell amp and
removes paid D's obsolete Shard flag/tooltip. Manager mana_restore_pct5 is
configuration only: no mana-restoration callback exists there, so do not
claim a removed implemented5% restore. Other Mage bonuses remain unchanged.
Scepter stays for the later W unit. Storm sound bank is now explicitly
registered; its compiled file hash was verified, actual audibility pending.
Four descriptions/Shard explanations and12mirrors agree with these changes.

AUTOMATED_VALIDATION:117 affected checks and316 hero mock regressions pass.
The old Overload test asserted the retired copy; replaced by8 meaningful
native ownership/raw values/context/restore/Shard/Health/locale contracts.
OWNER_RUNTIME:PENDING for all E gameplay, ranks/HUD, damage read/cache,
item casts/miss/killing hits, Break/illusions, Shard acquisition/activation,
death/reconnect and VFX/SFX/cleanup. Full restart required before later tests.
Q/W/R/D source migrations remain open; do not mark the kit complete.

E full source boundary:0 failed check(s). Initial failures identified missing
bootstrap import, progression/refund fixture coverage and stale generated
records; fixed and rerun successfully. Static unreferenced overload_aoe
candidate is a routing-key heuristic, not a gameplay failure. No engine test.

## Q pre-mutation decision

TUNE / NATIVE+MINIMAL EXT. Use a pure native static_remnant alias, not a
custom cast wrapper. Copy installed fields including NO_TARGET header and
is_point_targeted1/range800/travel300, .75 arming delay, vision and animation.
Preserve authored damage100..390 + INT1.2, CD3.5..2.6, mana70..115 and
lifetime8..12. Keep native trigger235; map the old240..330 effective damage
radius to static_remnant_damage_radius. This intentionally narrows the old
trigger at higher ranks while preserving its damage area. Damage radius is
larger than trigger at every rank; copying the old trigger330 with fixed
native damage300 would allow a trigger outside the damage circle.
The old3-remnant eviction policy retires with the copied thinker: native
expiry/cooldown owns lifetime, not a second Lua timer/cap. Actual repeated
cast/expiry/performance behavior remains owner-pending. The existing scaling
modifier only overrides the native damage special with raw rank + INT;
it must not spawn, damage or scan. Q targeting and native read-time/cache
remain owner gates; do not force a POINT flag or fabricate a facet.

Q source implementation: native alias and explicit installed AbilityValues
now replace custom OnSpellStart/thinker/.2s scans/manual damage/VFX/SFX.
The existing E-created scaling modifier supplies only native raw damage
+INT1.2 and remains installed while E is untrained; no extra native Q
provider, intrinsic or cast is created. Q uses no ScriptFile/empty wrapper.
Native talent metadata is preserved but no talent is unhidden/granted.
No new client classes, server managers, timers, entities or target writes.
An optional default-off bounded Q trace reports the extension value query;
it does not prove a damage application. Native damage caching, caster death
and Break behavior still need actual observations.

Automatic Health reads native Q damage/trigger/damage-radius/point fields;
rank0/zero queries are valid diagnostic evidence, not damage certification.
Four localized descriptions and12mirrors describe walking/arming/self-cast,
separate radii and ranked lifetime, and retire the3-remnant claim.
Four Q-focused contracts cover exact alias metadata, geometry/curves,
raw queries on both contexts and read-only Health/locales. The replaced
old remnant mock asserted copied thinker behavior and is retired.
121 affected checks and315 hero mock regressions PASS. OWNER_RUNTIME
PENDING for Q aiming/HUD, ten ranks/points, native delay/travel/vision,
actual damage/INT/cache, remnant expiry/repeated casts/caster death,
Overload charge generation and VFX/SFX/cleanup/VConsole. W/R/D remain.

Q full source boundary:0 failed check(s). The generic Health fixture now
provides the real read-only special getter; KV/native JSON comparisons
normalize parser object prototypes without relaxing field comparisons.
No engine launch, console action or publication occurred.

## W pre-mutation decision

TUNE / NATIVE. Replace copied AoE stun/Boss duration with native Electric
Vortex pull. Keep authored duration.8..2.6, CD16..7, mana80..170 and range450;
restore native castpoint.3/animation2/strong dispel/ordinary enemy targeting.
Populate native pull_distance180..300 across ten ranks by linear interpolation
of installed four-rank endpoints; tether1200/self-slow source fields preserved.
Scepter radius475 remains conditional with no base value. Native W gets the
exact installed Overload provider from the existing E restore; no second
charge cast, manual absorb, stun, motion controller or Lua wrapper.
Move Scepter ownership from generic R40%amp/25%CDR to native W only for
the owned Storm kit; remove obsolete R flag/tooltip. Actual pull/status
resistance/block/reflect/Overload and dynamic Scepter behavior remain pending.

W source implementation: pure native alias now includes all installed
target/immunity/strong-dispel/cast/animation/source fields. Duration is
declared consistently in header and AbilityValues; authored range450/cost/
CD and ten-rank gates retained. No manual spell absorb, radius scan,
damage/stun, motion controller, particle or sound call remains in Lua.
No extra provider, points, client class, timer or native state write.
Shared Boss AI/stats/waves/is_boss logic is unchanged. Conditional Scepter
metadata includes475 without a base value; no unconditional ordinary AoE.
Existing exact native E is the linkage compatibility path, still unverified
in actual Q/W/R casts. R's obsolete generic Scepter flag/tooltip removed;
native W ownership suppresses generic40%amp/25%CDR only for Storm, on both
contexts. Other Mages retain their bonuses; Shard remains native E.

Automatic Health reads pull distance/duration/conditional Scepter radius
without restoring anything. Native zero/untrained queries are not errors
or proof of target effect. Four localized descriptions/upgrade explanations
and12mirrors now describe pull. Native Scepter targeting/HUD behavior must
be observed after full restart; no POINT/AOE flag is guessed to force it.

Reference search storm_spirit_electric_vortex found only Watcher3164617180
native header assignments, no conversion implementation. REFERENCE_ONLY,
no imports. Installed hero hash/build6943 remain unchanged; ModDota native
alias guidance rechecked, not used as proof of C++ internals. Existing
verified Vortex particles and Storm bank stay under startup precache.

125 affected checks/314 hero mock regressions PASS. Four W-focused tests
cover exact native field/conditional upgrade data, ten-rank interpolation,
scoped both-context upgrade suppression, read-only Health and locales.
Retired the old mock asserting copied Boss AoE stun. OWNER_RUNTIME PENDING:
native pull, movement interruption/target death, strong dispel/status
resistance/immune targets, block/reflect, Scepter acquisition/removal/HUD,
Overload charging, ten-rank progression/points, death/reconnect, VFX/SFX/
cleanup and VConsole. R/D source units remain; no kit completion claim.

W full source boundary:0 failed check(s). No owner engine session, remote
push, deployment or Workshop publication. Existing contributor hunks remain
outside this atomic source unit.
