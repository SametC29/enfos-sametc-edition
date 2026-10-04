# Tidehunter native-first source migration

Status: Q/W/E/R SOURCE IMPLEMENTED / D IMPLEMENTATION PENDING / OWNER_RUNTIME PENDING.
This record supersedes the old PvE-conversion assumption for the migration
plan, not the existing production implementation or its proven source fixes.
The owner permits proceeding to the next source hero without live acceptance.

## Evidence and boundary

Installed Dota: ClientVersion/ServerVersion6943, SourceRevision11069754,
Oct01 2026. The exact hero file SHA256 remains
`8c96be768e85e8d845bc6ef04f99ad261c0f9bd5c0e45503aedb6ab4c5c78cda`.
[Snapshot](TIDEHUNTER_NATIVE_SOURCE_2026-10-04.json) records all eight native
ability definitions, installed English descriptions, exact source hashes,
hero assignments and queried API availability. The unchanged hero hash does
not establish engine compatibility or acceptance.

At discovery: five Lua abilities in `abilities/pve_kits.lua` with stable
`enfos_tide_*` IDs and ten ranks. Q/W/E/R are now native aliases; D remains Lua.
The native header explicitly assigns
Gush, Kraken Shell, Anchor Smash, Dead in the Water, Ravage and Leviathan's
Catch. Arm of the Deep and Blubber also have definitions; definition presence
alone does not establish automatic grant or an additional innate requirement.
Both historical facets are deprecated. Do not introduce talents/facet grants.

Native aliasing follows the documented exposed-variable pattern in
[ModDota Ability KeyValues](https://moddota.com/abilities/ability-keyvalues).
That pattern cannot rewrite internal C++ relationships. The successful source
patterns for Luna/Slark are integration references, not proof for Tidehunter.
Prior Pathfinders2208582400 Gush reference uses custom Lua and an older1600
projectile speed; installed2500 takes precedence. No external code is imported.

## Five-slot decisions before implementation

These are migration decisions/leads. Q/W/E/R are source-implemented; none is
engine-certified. Remaining rows describe planned work.

| Slot / stable ID | Current behavior | Verified native counterpart | Primary class | Intended ownership / reason |
| --- | --- | --- | --- | --- |
| Q `enfos_tide_gush` | Authored tracking projectile, damage + STR, armor/slow; bespoke Scepter linear wave | `tidehunter_gush` | TUNE | Native alias owns targeting, projectile, block/reflect, effects and Scepter. Authored ten-rank curves and minimal STR damage bridge; creep targets already supported natively. |
| W `enfos_tide_kraken_shell` | Passive block + STR, flat regen, custom damage counter/purge and reactive Shard smash | `tidehunter_kraken_shell` | TUNE | Native active/passive shell with numeric tuning. Flat regen is an explicit Enfos extension. Establish native cleanse ownership before retiring the custom counter; no duplicate Blubber/purge. Shard conversion remains a separate evidence item. |
| E `enfos_tide_anchor_smash` | Fixed400 radius; average attack + bonus + STR through flat physical damage; custom debuff | `tidehunter_anchor_smash` | TUNE | Native attacks and native attack-range-plus-additional-range geometry. Tune native bonus damage/reduction with STR bridge. Items, attack procs, attack immunity and native effects belong to engine. |
| R `enfos_tide_ravage` | Five custom timed damage bands and stun, STR scaling, one-second boss stun cap | `tidehunter_ravage` | TUNE | Native expanding Ravage, damage/stun/effects and ordinary engine immunity/resistance. Preserve authored rank/cost curves where exposed. Direct native AbilityDamage read-path must be established before claiming STR scaling. |
| D `enfos_tide_colossal_presence` | Authored self HP/armor plus enemy slow/damage aura | `tidehunter_leviathans_catch` | PVE-CONVERT (provisional) | Native fish passive is meaningful through free fish on even hero levels; hero-kill fish alone loses value against waves. Research native provider, rank bridge and bounded creep component before choosing minimal extension. Do not discard it merely because the existing aura is simpler. Production D stays unchanged during this discovery gate. |

D's provisional class is a research lead, not authorization for a guessed fish
entity/modifier or a fully custom replacement. Resolve it before touching D.
Retain fifth-slot free rank, ten total ranks, match-only progression and the
existing shared restore service. Hidden native providers must not consume points,
duplicate free ranks, or create permanent account state.

## Confirmed differences and migration contracts

Q native fields are `gush_damage`, `projectile_speed`, signed `movement_speed`,
positive `negative_armor`, top-level `AbilityDuration`, and Scepter
`speed_scepter`, `aoe_scepter`, `cooldown_scepter`, `cast_range_scepter`.
Current custom `slow_pct`, `armor_reduction`, `duration` and `scepter_*` names
cannot simply be carried into a native alias. Ordinary native range700 differs
from current750. Native Scepter cooldown7 also differs from the custom
`min(authored cooldown,7)` at late ranks. Record the chosen tuning and update all
four languages before changing these balances. Native effects/animation are
engine-owned; no parallel Lua projectile or debuff should remain after conversion.

W's native NO_TARGET/IMMEDIATE active lasts4 seconds, uses45 mana, cooldown30,
doubles block (`active_pct_effectiveness=200`) with40% movement penalty. Native
creep block penalty50% and non-stacking item-block note differ from the current
unconditional block getter. Keep defense/sustain identity. Installed Kraken
description includes cleanse, while a separate Blubber description restricts
its counter to player-owned damage. Neither text proves the actual C++ dependency.
Inspect alias/provider restoration and make this a precise owner runtime case;
do not add both listeners or silently invent neutral-wave cleanse parity.

E native `attack_damage`, signed `damage_reduction`, `reduction_duration` and
`additional_range` replace current custom names. Native description specifies
real attacks, not `GetAverageTrueAttackDamage` plus `ApplyDamage`. Native
immunity metadata is ENEMIES_NO; current custom KV/queries allow magic-immune
enemies. This is a material behavior change to disclose. Preserve the previous
CP2 radius fix only while Lua owns presentation; native conversion must retire
the duplicate particle/query rather than leave two executions.

R installed damage is top-level `AbilityDamage`; radius1250, speed725 and
duration2/2.2/2.4 are native values. Current radius1000 and authored duration
2.4..3.2 are deliberate tuning candidates. `GetLevelSpecialValueNoOverride`
documentation only promises the special-value block; it does not prove a
top-level AbilityDamage override is consumed by Ravage. Avoid the earlier SF
mistake of inferring actual damage from a reported special. A source solution
must expose that question explicitly; no fabricated engine PASS. Remove the
custom boss-only stun cap when native ownership is established, without editing
boss AI, wave rules or global boss classification.

D native catch has MaxLevel1/Innate1, dynamic accumulated HP/range/block and
native even-level fish grants. Ten-rank Enfos progression must stay separate
from exact native provider rank1. Fish bonuses are match-only. Resource identity,
automatic level6 catch-up, cleanup, Break, restore and stacking are unanswered;
do not guess constructors, duplicate native level grants or spawn unbounded fish.
The current D recipient getters also read ability values without the owner's
invalid-source/Break helper; decide correction alongside D's source choice.

## Upgrades and acceptance

Scepter belongs to Q. Existing generic Tidehunter Scepter suppression must remain
compatible with the chosen native owner. Blessing should follow Scepter checks.
The native hero header assigns Dead in the Water (enemy HERO only); Arm of the
Deep's definition is not evidence that the live kit grants it. Current Enfos
Shard is W's half-strength reactive smash at a five-second cooldown. Resolve
the PvE Shard contract from these facts, including native reflected-damage
semantics, before retaining/replacing it; avoid a second full active E attack
masquerading as a half-strength reflected proc.

Existing precache owns Tidehunter sound bank, Gush ordinary/upgraded projectile,
Anchor root and Ravage root. Verify resources and cold start before changing
ownership. Client scaling/modifier links must use the established minimal
bootstrap, never load server integration managers on clients. GetStrength and
GetLevelSpecialValueNoOverride API availability is both realms; that says
nothing about live native handles or C++ consumption.

Validation so far: installed snapshot parsed and native header/source re-read;
production unchanged. Automated gameplay validation is not newly claimed.
Pending owner cases: full restart, ranks1/10, Q ordinary/Scepter/Blessing aiming
and cooldown, W active block/movement/creep penalty/cleanse, E real attacks and
items, R damage/STR/radius/speed/status resistance/bosses, D native even-level
and wave behavior, Shard, Break, illusion, invalid handles, repeated casts,
death/respawn/reconnect, client HUD/tooltips, precache/VFX/SFX and VConsole.
Health report runs automatically; owner supplies logs. No collector or Dota
control is authorized. Resolve the remaining
native dependencies sequentially through this hero before moving to Ursa.

## Q source implementation, 2026-10-04

Stable Q now aliases `tidehunter_gush`, with explicit target/cast/immunity/dispel
fields and all used native named values. No native ID is shadowed. The custom
tracking/linear projectile, hit callback, Gush debuff class/link and obsolete
modifier localization are retired. Preserve other Tidehunter Lua abilities and
their historical invalidation/presentation repairs. This is not a whole-kit
rewrite. Existing ordinary cast range750 and authored CD/mana/damage/armor/slow
remain tuning choices; native Scepter field names and metadata are copied exactly.
Scepter now exposes native base cooldown7, replacing the former Lua min-rule at
ranks9/10. The full native C++ Scepter path still needs owner verification.

One hidden, nonpurgable, death-persistent modifier overrides only Q gush_damage
as raw paid rank damage + live STR * strength_factor. Missing/untrained/removed
query sources return0; client uses GetStrength and raw special API, never IsAlive
or native modifier-handle lookup. Existing Innates service restores it once,
without providers, rank grants or new points. Server and client register the
class through isolated modifier_links; client test checks all12 current classes
and prohibits server integration imports. Native getters, projectile snapshots
and actual damage consumption are engine questions.

Four-language descriptions use the negative native movement_speed through the
existing abs display formatter. Existing Q ordinary/upgraded roots and native
sound bank remain precached; compiled resource hashes are recorded in the snapshot.
Native owns animation, sounds, projectile/debuff lifetime, block/reflect/immunity
and modifiers. File existence never establishes correct rendered/audio behavior.

Focused evidence:108 native/client/content contracts pass;340 hero-kit mock
regressions pass after removing obsolete Lua-Gush imitation tests and retaining
the independent Anchor invalidation/dispels cases. Actual KV ranks1–10 smoke
passes; static audit/localization/reference inventories regenerate successfully.
Final repository checks report0 failed after the shared free-passive fixture
recognizes the new Q restore lookup without inventing a native kit or changing
point-budget assertions. This is source validation only.
No Dota control was used. Owner Q ranks1/10, actual damage/STR, ordinary/Scepter
aiming, rank9/10 upgraded cooldown, Blessing, dodge/reflect/dispel, caster/target
death, respawn/reconnect, VFX/SFX/cold start and logs all remain pending.
Next source unit: W Kraken Shell and its native cleanse/Shard dependency.

## W implementation decision before mutation

Use a native Kraken Shell alias with all exposed native active/block/cleanse
values explicit. Retain20–80 + STR*0.05 block and flat5–20 Enfos regeneration;
native owns block stacking,50% creep penalty,4-second200% active,40% movement
penalty,45 mana/30s cooldown and cleanse. Do not instantiate Blubber merely
because its definition exists. Native cleanse consumption/source eligibility
remains an owner test, especially non-player-owned wave damage.

Retire the custom purge call and its block getter. Preserve the existing Shard
half-Anchor utility as an explicitly independent450 received-damage trigger,
seven-second inactivity reset and five-second cap. This small extension does
not observe or duplicate native cleanse. Its tooltip must say damage threshold,
not assert it fires on a native purge. Keep generic Tank Shard suppression.
Native installed Anchor Note1 specifies reflected damage for reactive smashes:
pass DOTA_DAMAGE_FLAG_REFLECTION only on this Shard path, retaining ordinary
manual E flags. Native E migration will replace the remaining Anchor implementation
as a coherent follow-up; don't silently dispatch a full-strength native attack
and advertise half damage. No new Shard active/fish entity/talent is added.

W source implemented: native alias with explicit active and defensive values;
block20–80 + STR*0.05, creep penalty50%, active200% for4s with40% movement
penalty,45 mana/30s cooldown, cleanse450/reset7. Flat regen5–20 and a bounded
independent Shard counter are isolated in the client-safe modifier module.
Custom W block, damage cleanse and Purge implementation are removed. Native
smash_on_purge/bonus_reduction_per_kill are0 (no talent/facet grant).
The extension never purges or adds block. Shard requires learned E, obeys Break,
resets its counter on death/no Shard/invalid sources, suppresses recursive callbacks
and caps one half-damage reflected smash per5s. Ordinary E damage remains unflagged.
Native block item-stacking and actual cleanse eligibility, including neutral-wave
sources and the separate Blubber definition, remain owner questions. No arbitrary
Blubber modifier/provider was instantiated.

Restore adds the shell extension idempotently through the existing service;
13 client classes load without server managers. Four-language W/Shard tooltips
distinguish native cleanse from the independent Shard threshold. No new particle
path/bank/thinker/query loop is added. Existing E root/CP2 and Tidehunter sound
bank remain precached. Installed6943 source evidence is reused; automated checks
are source evidence only. Next source unit: E native attacks, geometry and
reactive Shard compatibility.

W validation: full `node tools/checks.mjs` completed with zero failed checks,
including 337 mock-engine hero regressions and 46 native/diagnostic tests.
Ten-rank block/STR queries, client-safe regen, source/Break/death guards,
Shard threshold/cooldown/reentry and manual-versus-reflected E flags pass.
These checks do not certify native block, cleanse, active presentation or
actual engine damage; all corresponding owner tests remain pending.

## E dependency review, 2026-10-04

Installed hero hash re-read from VPK and still matches the snapshot. E retains
TUNE classification. Native has cast point0.4 (current0.3), attack-range-plus225
geometry (current fixed400), real attacks plus attack_damage (current average
attack plus authored bonus/STR through ApplyDamage), signed reduction and
ENEMIES_NO immunity (current ENEMIES_YES). Migration must disclose these changes;
copying old flat damage is not native attack parity. Ten-rank bonus80..230,
STR0.75, reduction40..70 and six-second duration remain explicit tuning leads.

API re-read: OnSpellStart is server-only with no parameters. It is not evidence
for OnSpellStart(0.5) or a reflected native cast. Script_GetAttackRange is both
realms; GetAOERadius is server-only. PerformAttack is server-only and does not
expose reflection flags or document all native Anchor proc exclusions. Search
for Anchor returned no indexed API; this is a documented evidence limit, not
proof that no internal engine method exists. Added these results to the snapshot.

Reference corpus World of Dota2880603428,
`scripts/vscripts/heroes/npc_dota_hero_tidehunter_custom/tidehunter_anchor_smash_custom.lua`:
real attacks with temporary bonus/suppress-cleave and custom recipient modifiers.
It does not solve native reflected half damage. License/version not established;
REFERENCE_ONLY, no code imported. Pathfinders native-name references were found
but the attempted Lua path was absent; no behavior was inferred from that miss.
The [native alias documentation](https://moddota.com/abilities/ability-keyvalues)
limits inheritance to exposed values; it does not expose internal C++ structure.

Before E mutation, choose and verify the minimal reactive path alongside native
manual E. Half-scaling only attack_damage would leave base attack damage full.
An unscoped outgoing modifier risks changing unrelated item/proc damage. Keeping
a custom recipient reduction beside native Anchor risks double reduction.
Neither a full native reactive cast advertised as half nor a broad attack/damage
filter rewrite is accepted. Native modifier reuse/internal dispatcher evidence
is the next research step; otherwise document an isolated extension with explicit
non-stacking reduction and reflected damage. Current production E and the verified
W half/reflection adapter remain unchanged while that dependency is resolved.
No new gameplay acceptance, Dota control or engine PASS is claimed.

## E implementation decision before mutation

Installed server.dll contains exact null-terminated native recipient name
modifier_tidehunter_anchor_smash at offset50473776; SHA256
8ec4b6a9b9bb35ec8d1cd27f383d9a681e592bd07c5296208112c6411461aa92.
This establishes identifier existence, not successful modifier construction or
non-stacking behavior. [Built-in modifier reuse](https://moddota.com/abilities/reutilizing-built-in-modifiers)
uses AddNewModifier and the supplying ability's exposed values. Source adopts
that pattern, with native recipient reuse/refresh/read-path owner tests pending.

Manual E becomes the native alias, preserving authored10-rank costs/bonus/STR
and reduction magnitudes, restoring native cast point0.4, attack-range-plus225
and non-piercing immunity. Exact native attack_damage/damage_reduction/duration
fields are explicit; no talents/building attacks/on-attack casts are granted.
The existing capped Shard helper remains an explicit reflected flat-damage
extension, not a claimed native attack: half of average attack plus tuned bonus,
no attack-item procs/lifesteal. It reuses native recipient reduction instead of
keeping a second custom debuff. No native full cast is dispatched for Shard.
Use server native GetAOERadius for the reactive query and CP2 presentation;
actual radius, modifier creation and refresh remain owner cases. Remove custom
manual cast/recipient class and their localization. No shared damage filter,
outgoing modifier, attack hooks, extra providers, managers or timers.

E source implemented: manual native alias with all native exposed keys explicit,
ten-rank authored costs/bonus/reduction and live0.75STR attack_damage bridge.
Restored0.4 cast point, native attack-range geometry and ENEMIES_NO immunity.
Native owns actual attacks/item mechanics, animation, effects and recipient.
Shard uses a server-only bounded helper, native GetAOERadius for query/CP2,
half average attack plus overridden bonus, reflection flag and native recipient
name. It neither invokes native OnSpellStart nor performs item-proccing attacks.
Source/caster/target deletion and death after damage stop debuff/remaining work.
No cloned recipient class, extra provider, modifier link, timer or filter remains.
Four-language E descriptions and Shard no-attack-proc/no-lifesteal wording updated.
Old E mocks exercising retired manual Lua were removed; native contract/ten-rank
bridge and isolated helper eligibility/radius/flags/invalidations replace them.
113 affected checks and333 remaining hero mocks pass; full suite pending.
Owner full restart, ranks1/10, attack effects, actual STR bonus, native radius,
immunity, overlapping manual/reactive recipient refresh, dispel/status resistance,
death/reconnect/Break, Shard VFX/SFX and VConsole all remain PENDING.
Next source unit: R Ravage damage read-path and ordinary native control.

E validation boundary: full `node tools/checks.mjs` completed with zero failed
checks, including333 mock-engine hero regressions and49 native/diagnostic tests.
All source checks passed; engine acceptance remains PENDING OWNER TEST.

## R implementation decision before mutation

R remains TUNE: native alias owns wave, hits, stun, immunity, VFX/SFX and cleanup.
Remove bespoke five-band timer/recipient and skill-specific boss stun cap; do not
change boss AI, stats, waves or global classification. Retain authored radius1000,
base200..450, stun2.4..3.2, costs and ten-rank level5/interval5 gates. Restore
native cast point0.3 and speed725; explicit AbilityDamage top-level and native
duration/AbilityCooldown keys, no talents/Shard active.

Do not assert GetLevelSpecialValueNoOverride reads top-level AbilityDamage.
Use an ability-scoped total outgoing percentage extension: for owned learned R
only, percentage =100 * liveSTR * strength_factor / native GetAbilityDamage().
This intends the factor (base+2STR)/base without copying hits or adding another
ApplyDamage event. GetAbilityDamage is server-only; callback returns0 before
any getter on client. Guard missing/removed/wrong-owner/untrained/illusion and
nonpositive denominator. Do not disable the active R extension under Break or
after caster death: native launched waves retain native lifetime. No outgoing
bonus applies to Q/W/E/D, items or attacks. No new modifier/provider/timer/filter.

Installed indexed enum verifies TOTALDAMAGEOUTGOING_PERCENTAGE and callback.
[ModDota declaration source](https://github.com/ModDota/API/blob/master/examples/vscript/declarations/dota-modifier-properties.d.ts)
defines optional inflictor in ModifierAttackEvent; it is a shape reference, not
current engine certification. Corpus World of Dota2880603428 Bounty Track uses
the outgoing callback for spell-category damage; Earthshaker Totem uses it for
attack-category damage. Neither establishes Ravage pipeline/stacking. Those
files remain REFERENCE_ONLY with license/version not established, no imports.
Native hash reverified unchanged. Actual AbilityDamage curve consumption,
callback inflictor, applied multiplier, spell amplification/outgoing stacking,
mitigation/reflect/lifesteal and rank10 remain explicit owner tests.

R source implemented: explicit native alias, header AbilityDamage200..450,
native duration/speed/cooldown keys and authored radius1000/costs/gates retained.
Custom band timers, hit set, VFX emission and stun class/links/localization removed;
native owns wave and controls under ordinary engine rules without a boss cap.
One existing persistent modifier supplies the server-only owned-R outgoing
STR ratio. No top-level special override, duplicate ApplyDamage, provider,
manager, modifier grant, timer or filter is added. Client returns before server
getters; Break/caster death do not cancel the already native-owned wave.
Existing default-off bounded R Trace reports outgoing query values, not final
applied damage. Four-language R tooltip uses the canonical header damage curve;
localization generator now resolves AbilityDamage headers without duplicate KV.
Focused115 checks passed before trace/mirror guard additions;22 native/client
checks and327 remaining hero mocks pass afterward. Retired custom R mocks are
replaced by native contracts and scoped callback arithmetic/source/client guards.
Full source validation pending; all engine/rank/VFX/SFX/lifecycle/stacking cases
remain owner pending. Next source unit: D Catch native-provider/wave conversion.

R validation boundary: full `node tools/checks.mjs` completed with zero failed
checks, including327 mock-engine hero regressions and51 native/diagnostic tests.
This proves source contracts, scoped callback math/guards and canonical-header
localization generation, not actual native damage, stacking or motor acceptance.
All owner runtime cases remain pending.
