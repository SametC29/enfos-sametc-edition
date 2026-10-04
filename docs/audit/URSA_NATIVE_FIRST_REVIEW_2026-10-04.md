# Ursa native-first migration

Status: R SOURCE IMPLEMENTED; Q/W/E/D DISCOVERED / OWNER_RUNTIME PENDING.
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
| E enfos_ursa_fury_swipes | TUNE | NATIVE + minimal AGI/cleave extension | Native per-caster stacks/reset/attack damage/Break existing-stack behavior; tune damage20..92+AGI.15 and reset6..10. Retire bespoke normal/Boss stack caps, native stack progression remains. Investigate exact native linked provider before Q Shard. Minimal bounded wave cleave only if native damage event can be identified without double hits or recursion. |
| R enfos_ursa_enrage | TUNE | NATIVE | Native strong dispel, mitigation/status resistance and disabled-cast Scepter; preserve authored60..90% reduction20..60% resistance4.5..8s duration/costs. Explicit ten-rank Scepter cooldown30..18 using installed endpoint interpolation. Retire generic ultimate40% spell amp/25% CDR only for owned Enfos Ursa kit, retaining item stats. No copied purge/buff/wrapper. |
| D enfos_ursa_ursa_minor | TUNE | NATIVE Maul + minimal Enfos mobility | Keep paid stableD/free1/ranks10/49points. Native rank1 Maul separately owns1.75% currentHP attack bonus; D retains8..30 movement speed, no duplicateHP damage. Verify provider grant/hidden slot/Break/client/restore before mutation. No deprecated Bear Down facet or talents. |

Rows record pre-mutation decisions. R is now source-implemented; the remaining
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
