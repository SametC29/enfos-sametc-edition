# Slark native-first review

SOURCE WORK IN PROGRESS; all engine acceptance remains pending owner testing.
This supersedes the old blanket PVE-CONVERT entries for the next implementation
units; their prior mock results are historical evidence only.

## Installed evidence

[Native snapshot](SLARK_NATIVE_SOURCE_2026-10-04.json): current build 6943,
SourceRevision11069754, Oct01 2026; exact hero and English ability-localization
source hashes and observation time are recorded there. The balanced
AbilityDefinitions subtree was parsed, preserving strict project KV validation.
The native dossier's older slot mapping is still useful, but not enough: current
Essence Shift is hidden innate MaxLevel1; Saltwater Shiv is a hero-targeted active
attack, and both Fish Bait and Depth Shroud definitions are shard-granted.

Source reviewed: five production KV definitions, the Slark section and modifier
links in pve_kits.lua, current addon precache, progression/Health hooks and the
four-language descriptions. Existing native alias/value-bridge patterns from
Luna/SF/BB are reused; no new hero manager or spawn listener is needed.

## Matrix recorded before implementation

| Slot | Exact native counterpart | Class | Preferred implementation and evidence boundary |
| --- | --- | --- | --- |
| Q enfos_slark_dark_pact | slark_dark_pact | TUNE | NATIVE plus one AGI special-value bridge. Self-purge and radial damage already fit waves. Restore native delay, self-damage, strong dispel, effects and cleanup; preserve authored damage/cost/CD/radius and AGI scaling. No Lua pulse replica. |
| W enfos_slark_pounce | slark_pounce | TUNE (reviewed2026-10-04) | NATIVE directional leap, first-hero leash and Scepter charges. Mobility remains meaningful against waves; Q provides wave damage/purge, E provides creep attack scaling and R concealment/sustain. A wave nuke/root is unnecessary to preserve this slot’s role. Preserve native hero-only latch and zero direct damage; remove endpoint-only movement/control imitation. Native KV keys tune paid leash/CD/mana curves; ten-rank C++ acceptance remains pending. |
| E enfos_slark_essence_shift | slark_essence_shift | PVE-CONVERT | NATIVE hero essence/attribute interactions with minimal bounded creep AGI extension. Native is hidden, nonlearnable, innate rank1 and supports hero kill AGI within the match. Paid ten-rank E must remain separate from innate auto-scaling. Creeps lack the hero attributes assumed by native stealing; avoid duplicating the native hero attack bonus. Existing whole-buff refresh/cap is an authored creep conversion, not proof of native per-stack expiry. |
| R enfos_slark_shadow_dance | slark_shadow_dance | TUNE | NATIVE concealment/passive visibility rules and native regen, with minimal authored rank integration. Source bonus_regen is flat 60/90/120, not the current custom health_regen_pct=8..18; do not silently route percentages into that field. Native passive works while not visible to enemy team and has neutral damage suppression. Current custom invisibility/truesight states do not prove those rules. |
| D enfos_slark_fish_bait | slark_saltwater_shiv (historical design counterpart); slark_fish_bait is a different shard active | REPLACE | Dedicated Enfos passive, custom by necessity. Current native candidates are active abilities; rank/target tuning cannot turn their C++ attack/cast transaction into the mandatory free-rank passive. Keep the existing capped armor/cleave attack reward, isolate and repair its source guards, zero-damage behavior and caster ownership. Do not imitate or double-trigger native Shiv attacks or label this passive native. |

## Confirmed source differences

Q custom starts immediate purges/pulses with no blood cost. Native declares
delay1.5, pulse_duration1, total_pulses10, pulse_interval0.1 and
self_damage_pct30. Its current English description explicitly identifies strong
dispel and self-damage. The authored tick interval is0.15; tune native pulse
duration to1.5 when preserving that interval, while retaining the native delay.
Native total_damage is the verified key; damage/pulse_count/tick_interval are
custom names. Merely setting the texture does not make those engine-readable.

W custom sets absolute position every0.03 seconds, lacks a native motion-controller
claim and tests only its final point; it can miss a unit passed along the path.
Its damage is physical and applies a fixed80% slow. Native Pounce is ROOT_DISABLES,
non-dispellable, magical metadata, pounce_damage0, radius120, leash_radius400,
and applies Essence Shift stacks. Scepter belongs to W charges/range, not the
current generic R amp/CD bonus. Existing boss-only duration compensation is an
Enfos deviation; normal native resistance rules must be reviewed before retaining it.

R custom has no passive visibility detection, applies percentage regen during its
timed buff and manually owns a particle. Native attack/item/spell use does not
reveal the active concealment, although the cloud remains visible. Exact native
bonus_regen units and modifier state must be checked before numeric conversion.

E/D existing callbacks lack some removed-handle/source guards and refresh all
stacks together. These known source issues must be repaired before Slark source
closure, whether through native ownership or the justified minimal extension.

## First source unit: native Q

Use the stable alias enfos_slark_dark_pact with BaseClass slark_dark_pact,
verified native special keys and an additive AGI query modifier. Preserve ten
rank arrays and ordinary rank gates. Remove the Q Lua class/custom pulse modifier
and its links; replace imitation-only tests with native-source/rank/registration
contracts. Engine owns timing, purge, targets, particles, sound and cleanup.
MaxLevel10 and a passing special-value mock do not prove native C++ rank acceptance.
W/E/R/D remain open until their coherent source units are completed.

## References and resource evidence

[ModDota ability KV](https://moddota.com/abilities/ability-keyvalues), accessed
2026-10-04, documents native BaseClass aliases and the limit of exposed fields.
[Valve Slark page](https://www.dota2.com/hero/slark) was checked, but its fetched
body yielded no ability text; installed localization is the behavior evidence.
Reference-only corpus: Aghanim's Pathfinders Workshop2208582400,
scripts/npc/heroes/slark/slark.txt:6 and scripts/npc/npc_abilities_override.txt:2975.
No imported code/assets and no claim of license-verified reuse or engine proof.

Archive verifies soundevents/game_sounds_heroes/game_sounds_slark.vsndevts_c and
particles/units/heroes/hero_slark/slark_dark_pact_pulses.vpcf_c. The latter is
already explicitly precached; add the verified sound bank to the existing list.
Native owns particle attachments/CPs; no manual attachment is inferred here.

Pending owner Q tests after a full restart: ranks1/10, actual damage versus raw
query/AGI, delay/pulses, self-damage, strong dispel, caster death during delay,
recasts, immune/boss/ordinary targets, mana/cooldown, VFX/SFX/cold-start, clean
client/server VConsole and progression/respawn. All other Slark engine areas
remain pending, with no engine launch or gameplay-control tool authorization.

Q source implementation2026-10-04: native stable alias and one additive AGI
special-value modifier are installed. Removed the custom Q class, pulse modifier
and link; one obsolete pulse-loop mock is replaced with three native contracts.
No ApplyDamage, target scans, purge loop, manual particles or pulse timer remains
for Q. The existing free-passive service restores the scaler idempotently;
Q's native ten-rank metadata and ordinary point schedule are unchanged. Existing
particle precache remains and the verified Slark bank is added. Source tests
cover native fields, raw paid ranks1–10, AGI addition on client/server, untrained
zero, no native providers/point grants and idempotent restore. Shared client test
now covers seven Luna/SF/BB/Slark links once and rejects server integrations.

Final Q source boundary: `node tools/checks.mjs` passes with zero failed checks;
three focused native/source/AGI tests pass. This closes only the Q source unit,
not its engine gates or Slark's remaining four source units. No game launch,
console command, remote push or publication occurred.

## R source decision before implementation

The installed English label for bonus_regen is health gained per second, while
bonus_movement_speed has a percentage marker. This confirms the authored unit
distinction: restore native flat regen, not 8–18 interpreted as a flat value
or an unverified max-health conversion inside cached C++ modifiers. Use native
60/120 endpoints interpolated over ten paid ranks (60,67,73,80,87,93,100,107,113,120).
This explicitly changes the old percentage heal balance. Keep the authored
duration, movement-speed, mana and cooldown curves, with native special keys.
Native owns passive visibility checks, neutral-hit suppression, active concealment,
non-dispellability, effects and cleanup. Full-map AddFOWViewer is pre-existing;
do not alter it for R or assume that a passive is active under that vision policy.

Keep the current generic Scepter R cooldown reduction temporarily until the
coherent native W/Scepter unit replaces it. R deals no direct spell damage,
so its tooltip must not advertise a damage increase. Existing Fighter Shard
stays in D until its own integration unit; no Depth Shroud is added in R-only work.
Native C++ rank acceptance, concealment versus detection/full vision and actual
flat regen remain pending owner testing. No Lua state/particle replica is retained.

## R source implementation and validation

Stable R alias now uses native slark_shadow_dance, immediate/no-target behavior,
verified sound/animation and non-dispellability metadata. Removed the custom R
Lua class, buff, registration and imitation-only particle/state mock. Native
fields bonus_movement_speed and bonus_regen replace custom-only keys. Four
languages and generated resources now describe passive and active behavior.

Five focused Slark contracts pass, covering source ownership, ten-rank fields,
Q additive AGI bridge and the installed regen unit/endpoint interpolation.
The full node tools/checks.mjs boundary passes with zero failed checks. These
results establish source consistency only; every R engine gate remains pending.
No game launch, console command, remote push or publication occurred.

## E source decision before implementation

Use a paid ten-rank E controller and the exact hidden native slark_essence_shift
provider at rank1, following the reviewed linked-provider pattern. Native
hero attacks/attribute loss, kill-radius permanent match-local AGI, per-stack
expiry and effects stay in C++; no manual constructor names are guessed.
An existing shared scaler bridges agi_gain/stat_loss/duration/steal_radius
from the paid E, returning zero while untrained. ForceRefresh resolves the
native intrinsic through GetIntrinsicModifierName on the server. No points
or second innate slot are granted. This also preserves the exact provider ID
for later native Pounce integration. Provider restores once after spawn.

Creep extension listens only to this real Slark's landed attacks against enemy
creeps, excluding heroes/hero illusions to prevent duplicate native gains. It
keeps the authored1–4 AGI/rank and30–75 stack cap,30-second shared buff refresh,
including killing attacks. Break blocks new temporary gains; existing bonuses
remain active, matching installed Essence Shift Note4. The previous mock
incorrectly certified suppression of existing stacks under Break. Illusions
receive no extension, untrained/removed handles return zero, and no global scan,
interval, damage, permanent creep steal or external progression is added.

Installed snapshot has agi_gain3/stat_loss1/steal_radius300, duration10 with
hero_levelup+2.5; choose the existing authored30-second duration and1–4 gain
for both hero and creep paths, explicitly replacing native level-duration
scaling. Native hero stacks retain native lifetime/cap rules, while creep
stack cap/whole-buff refresh are the documented PvE conversion. Native
kill-radius match-local steal and neutral/wave classification await engine tests.

API index verifies IsCreep/IsHero on both sides; OnAttackLanded event;
GetIntrinsicModifierName server-only and ForceRefresh both. ModDota BaseClass
documentation rechecked2026-10-04; reference-only Pathfinders2208582400
slark hero mapping and item essence upgrades reviewed, with no code imports.

## E source implementation and validation

Paid E controller, exact rank1 hidden native provider and four-key native-value
bridge are installed. Existing free-passive spawn service restores the provider
idempotently. Rank updates refresh the server-native intrinsic resolved from
the engine; a missing intrinsic emits missing and cannot claim ready. Orphaned
or untrained paid E returns zero through the bridge rather than native defaults.
Creep listener/buff are isolated in Slark modifiers, registered on both sides,
with no native hero double gains, scans, per-target modifiers or interval timers.
Existing hit glow is retained via the shared effect helper and existing precache;
VPK SHA f20ecca6f983e67c232168161ee56b66b74bd69365005664f3815f1e70e2ee98.
Attachment/one-shot appearance/termination remain owner engine checks.
Localized ability and buff text exists in all four languages. Debug-gated bounded
trace reports creep stack changes without adding gameplay work solely for logging.

Seven focused Slark tests and twelve shared Luna/bootstrap tests pass. They
cover all paid E ranks, provider reuse, no free points, native-name refresh,
missing intrinsic/source, client-safe reads, cap/kill-hit filtering, heroes and
noncreeps/allies, Break and illusions. First broad source run detected the new
controller missing from the existing shared server loader (class absent in
smoke checks); added its explicit module import and verified rank1–10 smoke
execution. Final full checks are recorded below; no owner engine pass is implied.

Final E source boundary: node tools/checks.mjs passes with zero failed checks.
Q/R/E source units are implemented; W/D remain open. All native C++ queries,
rank HUD, actual stats, effects/audio, upgrades, respawn/reconnect and clean
VConsole remain PENDING OWNER TEST. No remote push or publication occurred.

## W decision before implementation — supersedes provisional conversion

The initial PVE-CONVERT lead depended on creep contact being necessary. Full
kit review shows a separate role for native mobility: position Dark Pact,
engage/disengage and move around wave bodies without adding another wave nuke.
Q/E already provide wave offense and R sustain; native first-hero latch also
retains PvEvP identity. The installed Pounce description and pounce_damage0
support native mobility/control, not the old physical endpoint blast. Reclassify
W as TUNE before changes: native stable alias, pounce_damage0, native radius120,
distance700/speed933.33/acceleration7000/leash-radius400, authored leash2.5–4.3,
CD12–6 and mana75–140. This explicitly removes the old100–550+0.8AGI endpoint
damage, fixed80% slow and boss-specific short duration. Creeps are passed over;
no custom creep root, damage or guessed native modifier constructor is added.
This is a role/identity decision, not a claim that custom contact was verified.

Retain native Scepter max_charges2, charge_restore_time12 and distance900 using
installed special_bonus_scepter fields. Replace the generic R25% cooldown
reduction with W's native Scepter; preserve existing role Shard until D review.
Paid W has ten ranks directly; native essence_stacks endpoints1–4 are mapped
to ten explicit ranks, and its exact hidden Essence Shift provider exists from
the E unit. C++ ten-rank reads/charges/linked E still require owner verification.

Primary ModDota built-in modifier guide confirms constructor fields are specific;
older official China Workshop modifier-name list confirms names only, not current
constructor semantics. Reference-only World of Dota2880603428 custom pounce
lines4/283/298/601 shows a custom class, not a native constructor. No source is
imported, and no external name list is treated as native engine proof.

## W source implementation and validation

Native stable alias installed with authored ten-rank leash/CD/mana and native
charge keys. Removed custom dash, endpoint blast, fake slow/tether, manual
particles and links; removed the imitation-only dash mock. Exact E provider
remains owned by existing restore service. Native ownership guard suppresses
generic R spell amp/CD and hides that obsolete upgrade modifier only for the
owned Slark W; missing/invalid ability and unrelated heroes keep their behavior.
Four languages now describe directional movement, hero-only latch, no direct
damage, root restriction and native Scepter2/12/900.

Ten focused Slark contracts and twelve Luna/shared client tests pass. The broad
run uncovered two stale source contracts: dossier classification parser requires
a bare classification line, and roster upgrade inventory still assumed Slark's
Scepter belongs to R. Corrected dossier format and changed the inventory check
to verify Slark Ability2 instead of Ability4, supported by installed source and
the independent native-key/suppression tests. No acceptance gate was removed.

Final W source boundary: node tools/checks.mjs passes with zero failed checks.
Ten focused Slark tests, twelve shared Luna/client tests and93 content contracts
pass. These establish source consistency only. Actual native movement/rank10,
hero latch/creep pass-over, root restrictions, essence stacks, Scepter/Blessing
charge HUD/restore, Refresher, effects/audio and lifecycle/VConsole remain
PENDING OWNER TEST. Q/W/E/R source units are implemented; D source work remains
open. No Dota control, remote push or publication occurred.

References checked2026-10-04: [ModDota built-in modifiers](https://moddota.com/abilities/reutilizing-built-in-modifiers),
[official China Workshop modifier list](https://www.dota2.com.cn/wiki/Dota_2_Workshop_Tools/Scripting/Built-In_Modifier_Names.htm).
Neither name lists nor examples verify Pounce's current private constructor.

## D decision before implementation

D is an Enfos-only passive, classified REPLACE before changes. KEEP/TUNE fail
because both installed candidates are active casts. Target-only PvE conversion
would still be an active; dispatching native Saltwater Shiv from OnAttackLanded
could add another native attack/resource transaction, and no verified passive
proc API/constructor evidence exists. Do not invent that bridge or duplicate
health-restoration stealing. Keep the existing five-slot passive contract,
25% proc, authored20–60% circular physical cleave, rank1–5 armor loss with5
per-caster stacks/4-second duration and250 radius; this is a dedicated attack
reward for Enfos waves, not current native Saltwater Shiv or Shard Fish Bait.

Repair confirmed source defects: invalid ability/caster guards before RNG,
removed sources during debuff/damage callbacks, fabricated150 damage when the
attack event omits damage, dead-target exclusion suppressing killing-hit cleave,
client armor getters from removed/untrained abilities, and caster ownership for
multi-Slark debuffs. Snapshot impact center and cleave budget before callbacks.
Killing hits cleave but do not place armor on a dead target. Missing/zero/invalid
damage can apply landed-hit armor but cannot invent cleave damage. Break and
illusions block new procs; already applied armor remains independent.

Separate modifiers per caster via MULTIPLE, reusing the matching caster handle
for capped refresh; no unbounded per-hit modifiers, summons or interval scans.
One engine radius query per actual damaging proc; never cap scheduled waves.
Keep existing Fighter Shard35AS/slow as explicit Enfos extension; native active
Depth Shroud is not added to the mandatory passive slot. No new passive sound;
normal Slark attack audio remains native. Existing proc splash/helper/precache
retained; VPK SHA1d1a127ccd1833e8268fd1f46db8b40515906976e27f5b1bcaef044366522c91.
Actual attachments, one-shot cleanup, audio and physical mitigation await owner.

Native source snapshot6943/rev11069754 and installed Shiv localization reviewed.
API confirms server-only FindModifierByNameAndCaster. Rechecked ModDota built-in
modifier/API docs; reference-only World of Dota2880603428 KV1950/hero2086 has
native Shiv slot/definition, no verified passive transaction. No imports.

## D implementation and Slark source closure

D's isolated passive/debuff are loaded and linked on server/client by the
existing Slark bootstrap; no source classes remain in pve_kits. No extra hero
manager, points, native active cast or native attack transaction is added.
Landed-hit validation and snapshots guard removed sources during callbacks;
per-caster capped armor refresh uses verified server FindModifierByNameAndCaster.
Client armor getter handles removed/untrained sources, with no server-only
lookup/alive calls. Splash and native attack sound remain as documented;
trace is default-off/bounded with no timer or search solely for logging.

Twelve focused Slark tests and twelve Luna/shared-client tests pass;342
hero-kit regressions pass. D-specific contracts cover missing/zero damage,
killing hits, cap/refresh, independent caster modifiers, Break/illusions, invalid
input/source and mid-callback invalidation, physical magic-immune inclusion
and client getters. A full source run exposed only the broad smoke fixture
missing the supported FindModifierByNameAndCaster API; added the exact
matching-caster fixture method, with no production fallback or weaker gate.
Final full-check result is recorded below. Four-language ability/buff text and
Q/R dossiers are aligned with the current native ownership and slot matrix.

Remaining owner checklist after full restart: initial selected-hero Health
prints once;5 paid skills/10 ranks/5 initial points/free D1; Q ranks1/10 actual
damage/delay/purge/blood cost; W face direction/hero latch/creep pass-over/
root restriction/Essence link/Scepter2 charges12s900/Blessing/Refresher;
E hero temporary/permanent match-only AGI and creep cap/Break/kill-hit split;
R flat regen/visibility/full-map vision/cloud/detection; D actual hit damage
versus physical mitigation,0/missing damage,killing-hit spread,stack refresh/
purge/two casters/Fighter Shard; all slots cold-start VFX/SFX/cleanup,
death/respawn/reconnect/rank refresh, dense waves and clean client/server
VConsole. Source closure is IMPLEMENTED BUT NOT ENGINE-VERIFIED.

Final source target audit: wave definitions use BaseClass npc_dota_creature.
Indexed IsCreature is available on both sides. E/D explicitly accept Creature
NPCs as well as IsCreep, while E still excludes heroes and D still excludes
allies/noncombat targets. This does not assume IsCreep and IsCreature are
identical in C++; an independent mock with IsCreep=false/IsCreature=true covers
both extension paths. Actual wave/Boss combat still needs owner verification.

Final Slark source boundary: node tools/checks.mjs passes with zero failed
checks;13 focused Slark contracts and12 shared Luna/client tests pass.
Source statuses: Q/W/R NATIVE, E NATIVE plus bounded creep/Creature extension,
D CUSTOM with documented REPLACE reason. Scepter native W; Fighter Shard
explicit Enfos extension. All five source units are implemented and reviewed.
OWNER_RUNTIME remains PENDING OWNER TEST, not DONE/ENGINE_PASS. Next ordered
source hero is Tidehunter; deferred live tests do not block source progression.
Local atomic commit only; no game launch, remote push or publication.
