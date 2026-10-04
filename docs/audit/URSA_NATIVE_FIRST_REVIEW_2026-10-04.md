# Ursa native-first migration

Status: Q/E/R SOURCE IMPLEMENTED; W/D DISCOVERED / OWNER_RUNTIME PENDING.
Latest owner rollout permits continuing source work without live acceptance.

## Sources and boundaries

Installed build6943/revision11069754, Oct01 2026. Hero source
`scripts/npc/heroes/npc_dota_hero_ursa.txt` SHA256
`613c2cefe0a70e0a5582c5dd9def317fb93da2a346d0da650070a147b4faad9a`
is unchanged from the older6941 dossier; build and semantics are freshly read.
[Snapshot](URSA_NATIVE_SOURCE_2026-10-04.json) holds all six native definitions,
hero assignments, installed English tokens and resource hashes. File presence
is not native constructor, targeting, audio or engine acceptance.

Production at discovery: five Lua implementations in pve_kits, all10 ranks.
Q lacks native hop, uses physical instead of magical damage and Boss-only slow
cap. W consumes charges only on landed living-enemy hits, unlike native miss
consumption; adds attack healing but lacks native slow resistance. E replicates
native per-target stacks/damage with separate Boss cap and radial cleave.
R copies native purge/buff but lacks native disabled-cast Scepter behavior.
D is numeric movement speed; native Maul is absent from custom hero slots.

Native alias exposed-variable pattern: [ModDota](https://moddota.com/abilities/ability-keyvalues).
C++ internal cross-ability lookups are not mutable by ScriptFile. Valve Lua
Abilities page could not be fetched; do not claim its contents verified.
Pathfinders2208582400 scripts/npc/heroes/ursa/npc_abilities_ursa.txt is
REFERENCE_ONLY: it uses Lua Earthshock impact_damage, outdated Shard talents
and4-rank dependent Maul1.2..1.5. Installed Q uses top AbilityDamage, Shard3
Fury stacks; Maul is rank1 currentHP1.75%. No external code imported; reference
version/license/distribution permission not established.

## Decisions before mutation

| Slot | Primary class | Ownership | Decision / implementation gate |
| --- | --- | --- | --- |
| Q enfos_ursa_earthshock | TUNE | NATIVE + minimal STR bridge | Native250-unit facing hop and magical impact/slow/immunity/VFX/SFX. Retain authored120..660+STR1.5,385 radius, costs/cooldowns and duration; remove Boss-only slow. Exact top AbilityDamage pipeline required. Shard3 native Fury stacks depends on native-linked E/R identity; inspect before exposing it. |
| W enfos_ursa_overpower | TUNE | NATIVE + minimal heal extension | Native cast/buff/charge consumption including misses, slow resistance25; retain ten-rank attacks/AS/duration. Preserve authored10..28% landed-damage healing as independent extension, no copied charge decrement or particle. Determine actual native buff/readpath and killing-hit eligibility. |
| E enfos_ursa_fury_swipes | TUNE | NATIVE + minimal AGI/cleave extension | Native per-caster stacks/reset/attack damage/Break existing-stack behavior; tune damage20..92+AGI.15 and reset6..10. Retire bespoke normal/Boss stack caps, native stack progression remains. Investigate exact native linked provider before Q Shard. The conditional cleave lead is resolved below: restore native focused attacks, retire custom radial cleave. |
| R enfos_ursa_enrage | TUNE | NATIVE | Native strong dispel, mitigation/status resistance and disabled-cast Scepter; preserve authored60..90% reduction20..60% resistance4.5..8s duration/costs. Explicit ten-rank Scepter cooldown30..18 using installed endpoint interpolation. Retire generic ultimate40% spell amp/25% CDR only for owned Enfos Ursa kit, retaining item stats. No copied purge/buff/wrapper. |
| D enfos_ursa_ursa_minor | TUNE | NATIVE Maul + minimal Enfos mobility | Keep paid stableD/free1/ranks10/49points. Native rank1 Maul separately owns1.75% currentHP attack bonus; D retains8..30 movement speed, no duplicateHP damage. Verify provider grant/hidden slot/Break/client/restore before mutation. No deprecated Bear Down facet or talents. |

Rows record pre-mutation decisions. Q/E/R are now source-implemented; the remaining
slots are planned work. None is engine-certified. Preserve
Luna and contributor Lich work; no shared Boss/wave/respawn rewrite. Source
changes are isolated atomic local commits, no remote push/deploy/Workshop.

## Required owner evidence

Full restart for structural KV/bootstrap. Automatic selected-hero Health only.
Initial level6/five ordinary points/separateD1; all5 ranks1..10 and level50
49 ordinary spendable points; no talent/profile grants. Q native facing hop
position/impact geometry/actual magical+STR damage; W misses/charges/healing
including killing hits; E per-caster stacks/reset/Break retention/actual AGI
scaling and Shard interaction; R strong dispel/disabled Scepter/mitigation/CD
with normal/consumed Scepter/Blessing; Maul currentHP versusmaxHP. ColdVFX/SFX,
repeated use, death/respawn/reconnect/no duplicatepoints/modifiers, dense waves,
allfour tooltips and VConsole. All remain PENDING OWNER TEST.

## R source implementation

Native Enrage alias owns strong dispel, mitigation/status resistance,
Scepter disabled-cast behavior and VFX/SFX/lifetime. No Lua ability class or
modifier replica remains. Existing hero slot/10ranks/5-by5 gate/costs and
ordinary50..30 cooldown preserved. Native values use authored mitigation,
resistance and duration arrays; native zeroAoE/facet damage defaults explicit.
Scepter replacements30,28.7,27.3,26,24.7,23.3,22,20.7,19.3,18 seconds are an
explicit ten-rank interpolation of installed30..18 endpoints; native24 is
a three-rank midpoint, not silently indexed into rank10. Actual special-bonus
readpath at all ranks remains owner pending. Generic40% ultimate amp/25% CDR
returns0 only for Ursa with the stable owned Enrage ability; item stats and
other heroes retain their current behavior. Client-safe ownership module uses
verified both-context GetUnitName/FindAbilityByName, no state mutations,
server manager loading, timers or scans. Pure native needs no empty wrapper
or added modifier/client class. Existing Enrage particle and Ursa sound-bank
precache retained. Four languages and12mirrors describe strong dispel and
native Scepter instead of the old generic bonuses.

4 focused native contract/ownership/localization regressions pass. Old mocked
LuaEnrage assertions removed, remainingD assertions retained; actual engine
strong dispel/disabled-cast, damage reduction, status resistance, native
Scepter cooldown/Blessing/refresh/coldVFX/SFX are PENDING OWNER TEST.
Full source checks pass with0 failures, including324 hero mock regressions.
All native aliases remain explicitly allowlisted; no blanket class exemption. Next source dependency: native Fury Swipes E
and Q Shard identity before migrating Q; no unrelated heroes.

## E final decision before source mutation

TUNE, NATIVE + minimal paid-value/AGI bridge. Exact native Fury Swipes
rank0 until paid E learned, then rank1; stable paid E keeps10rank/gates.
No second native alias intrinsic: paid controller only supplies tuning.
Native owns attack damage, target stacks/reset/multiple casters and Break
retaining existing-stack effects. No exposed cleave/cap fields in current
native definition. Retire radial extra damage and custom normal/Boss caps
to restore focused Ursa identity instead of duplicating a native attack with
unverified damage attribution/event ordering. This resolves the provisional
cleave investigation in the original matrix; no partial cleave dispatcher.
AGI bridge and rank-refresh use existing shared restoration entry, no interval,
attack listener, new manager or forced target stack writes. Native intrinsic
ForceRefresh on rank changes only; no target debuff refresh or count mutation.
Actual cached damage/AGI and QShard lookup remain owner evidence gates.

## E source implementation and acceptance

Stable paidE ability_lua under abilities/heroes/ursa/e controls10ranks; one
exact native ursa_fury_swipes provider is hidden/active/rank1 when trained,
rank0 otherwise. No duplicate native alias with another attack intrinsic.
Existing Innates restoration installs tuning first, adds provider once and
preserves existing handles/target state/points on repeated death/reconnect
restore. OnUpgrade invokes server-only intrinsic name lookup/ForceRefresh
for the caster cache, never target stacks; client rank-up returns before
loading integration. One persistent hidden non-purgable bridge class is
registered and linked on both contexts through existing client entry; total
15 reviewed client classes, no server managers imported by that entry.
Raw rank damage20..92 +AGI.15, reset6..10, nativeRoshan8/stun0 are scoped to
the native provider of this parent and exact keys. Break is not checked by
the numeric bridge because native retains existing-stack damage; native
controls new-stack/illusion eligibility. No IsAlive in client getters.
Custom stack/debuff/attack handler, max/Boss caps and radial damage removed.
Native attack/target/modifier/immunity/feedback/expiry own these semantics;
asset existence does not establish live behavior. Native hit/debuff resources
are hash-verified and existing precache retained. Four languages/12mirrors
match native reset/Break and the authored AGI curve, no old cleave/cap claims.
Automatic Health reports native provider/intrinsic and damage query without
restoration or mutation; query is not actual measured attack damage.

115 affected checks and323 hero mock regressions pass. Full source checks
pass with0 failures. The progression-only fixture now allows the exactUrsa
E lookup while preserving all free-rank/respawn/49point assertions. Actual native cached damage, changing AGI without rank-up, rank
refresh preserving target stacks, killing hits, two Ursas, Break existing
stacks, QShard and cold native VFX/SFX remain PENDING OWNER TEST. Next: Q
Earthshock native linked identities and damage pipeline; W/D pending too.

## Q final decision before mutation

TUNE, native Earthshock alias with authored ten-rank header damage/duration/
costs/CD, negative slow, native facing250 hop/.25duration/83height,385 radius
withAoE metadata, magical/immunity/dispellable/instant/native animation and
feedback. Remove physical Lua damage, manual slow/particle and Boss-only cap.
Native Shard field supplies3 Fury stacks and old shard_enrage_duration remains
installed empty/default0; no invented Enrage duration. Existing exactFury
provider handles its linked identity. Installed English AbilityDraft note
requires Enrage; current nativeShard token namesFury instead. Their actual
C++ relation cannot be proved from text/API. A hidden inactive exactEnrage
rank1 compatibility provider is added only for owned Q/R to satisfy identity,
with scoped raw paidR fields (0untillearned); no manualcast, grant, event,
replica or second displayed R. This is an explicit compatibility decision,
not proof of a current C++ required lookup or abilitydraftnote freshness.
Native aliasR remains the sole player cast; actual native linkage is pending.

Q topAbilityDamage is not a special-block override. Add STR1.5 as a scoped
server-only outgoing percentage against GetAbilityDamage, like the reviewed
TideR source pattern; no second damage event. This is additive numerator
math, not proof of engine property stacking/mitigation/damage attribution.
Client returns0 before nativegetter. Native effects remain engine-owned.
Read-only Health exposes Q header query/association and compatibility rank.
No new timer, scan, cast wrapper or gameplay diagnostic mutations.

## Q source implementation and acceptance

Native Earthshock now owns hop/impact/slow/Shard/immunity/cleanup. Authored
headerDamage120..660,Duration2.5..4.5,negativeSlow-20..-56,CD11..5,mana75..150
retained; native250/.25/83hop,385radius/AoE,immediatecast,magical/dispellable
metadata explicit. No talent/charge grant; charges0,restoretime10rank complete.
Old LuaQ class/manualeffect/damage/debuff and Boss-only slowcap retired.
Existing native-scoped persistent bridge supplies server-only STR1.5 ratio
against headerGetAbilityDamage; client returns0 beforegetter, no duplicate hit.
Live STR at native impact replaces oldcast-time STRsnapshot. Header duration
localization support renders canonical curve with no duplicate specialdata.
Four languages/12mirrors describe native facing hop/magical/slow/Shard3Fury.
Existing particle/soundbank retained; no resource/runtime certification.

ExactFury identity and optionalownedQ/R hidden inactive rank1Enrage identity
restore once; rawnativeR helper keys read paidR rank (0untrained). No player
R replacement/secondcast, no directPurge/OnSpellStart/targetstack calls/points.
CurrentShard enrageDuration remains installedempty(default0), no invented
Enrage grant. The native note/code linkage and zero-untrained nofreepurge
condition require owner evidence; compatibility constructor is not proof
of those outcomes. Health prints QdamageGetter/serversecondaryassociation
and exactR rank read-only. Query outputs are not measured damage/Shard proof.

120 affected source/client/locale regressions and322 hero mock regressions
pass. Fullsourcechecks pass with0failures. Owner: native hop centre/root/path/immunity,
actualSTR damage/mitigation/itemamp/property stacking, learned/unlearnedR/E
Shard3Fury and no undescribedEnrage/purge, r1/r10 cost/CD/slow, coldVFX/SFX/
lifecycle/reconnect/densewaveVConsole. W/D source work remains; nextW Overpower.
