# Health and mana refill zones — 2026-10-01

Status: **MISSING MAP UNIT DEFINITION REPAIRED — OWNER RUNTIME CHECK PENDING**.

## Diagnosis and evidence

The active compiled map uses two npc_dota_base entities with MapUnitName
`npc_dota_custom_fountain`. That ID had no definition in this addon. The
reference map supplies a custom creature plus its own Lua aura; importing the
map alone did not import those dependencies. This proves a missing dependency;
it does not prove that no other runtime issue exists.

Source2Viewer-CLI 19.2 extracted `maps/enfos/entities/default_ents.vents_c`
directly from `game/maps/enfos.vpk`. The active dump matches the historical
reference dump byte for byte (SHA256
`5a30cf2b18348d85f013ecbd82307b88ddf16b7921fc1e1eee71c17b3e2d36c9`).
The small evidence snapshot is [HEALING_MAP_ENTITIES.json](HEALING_MAP_ENTITIES.json).

| Team | Authored origin | Hammer ID |
|---|---|---|
| Dire (3) | -7768.491211, -2388.374023, 128.000122 | 171 |
| Radiant (2) | 7716.493164, -2386.61792, 128.339386 | 170 |

The earlier claim that missing editable .vmap prevented a static entity audit
was incorrect: the compiled VPK can be decompiled without launching Dota.
Editable source remains missing; archived broken flat-map prototypes must not
be restored. No map, geometry, coordinates, materials or team assignments changed.

## Native-first repair and provenance

Added the exact missing unit ID using Valve's current `ent_dota_fountain`
class. Current installed native `dota_fountain` KV provided class/structure
fields; the installed VPK resolves the effigy model already used by the map's
reference fountain. Native class supplies recovery behavior; no custom Lua aura,
new regeneration manager, duplicated fountain or guessed location was added.
The compatibility unit cannot attack, move or grant kill rewards. The authored
map team assignment is expected to override its default Radiant team.

[Valve's map guide](https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Level_Design/Creating_A_Dota-Style_Map)
uses team-bound native fountains. The alias's initialization and correct
team-specific healing still need actual engine verification.

Reference: Enfos Survival Workshop 3591082091, NPC unit definition inspected
only to identify the missing dependency. Code license unresolved:
**REFERENCE_ONLY**, no reference aura/implementation copied. Existing owner
permission covers reused map placement. Effigy is a current Valve asset.
Visible unit name added in EN/TR/RU/zh-CN.

## Verification and owner acceptance

- Content contract checks both map teams, exact unit dependency resolution,
  native class, non-attacking behavior, model path, localization and active map
  SHA256. This is static verification, not a regeneration simulation.
- All 84 content tests pass; all ten approved map/theme files match their hashes.
- Dota was not launched or controlled, per owner instruction.

In a fresh match after restarting for KV reload, test each team separately:
stand a living damaged/mana-depleted hero beside its authored effigy, record
health and mana before/after, leave the zone, and repeat using the opposite
team. Require both resources to increase only in the intended allied area.
Check VConsole for missing-unit/class errors. If either effigy is absent or
both spawn on Radiant, report that before adding any alternative aura.
