# Health and mana refill zones — 2026-10-01

Status: **DIAGNOSIS INCOMPLETE — NO GAMEPLAY FIX CLAIMED**.

## Request

Make the map's health and mana recovery locations work for living heroes.

## Evidence gathered

- The addon's active map is `enfos`; `addoninfo.txt` points to it. MCP reports
  `game/dota_addons/enfos_sametc/maps/enfos.vpk` is compiled, but its editable
  `content/maps/enfos.vmap` source is missing. The quarantined `.vmap.disabled`
  prototypes are retired placeholder maps and are not safe substitutes.
- The project scripts contain hero-specific regeneration and the separate
  Spellbringer mana loop, but no map recovery-zone manager or authored recovery
  trigger definitions were found. Hero regeneration values do not prove that
  map zones restore health/mana.
- The current MCP entity catalog lists `ent_dota_fountain` as the team fountain
  heal/regen entity with a `teamnumber` key. Valve's Dota-style map guide says
  its fountain prefab works when its team is set to Good Guys and its unit name
  is `dota_fountain` ([Valve Developer Community: Creating a Dota-Style Map](https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Level_Design/Creating_A_Dota-Style_Map)).
- A downloaded Dota Run reference had no Lua handling for `ent_dota_fountain`,
  `GiveMana`, or `modifier_fountain_aura`; it therefore did not provide a
  reusable implementation for this project's unknown custom refill points.
- A local Tools launch was attempted. Dota opened a modal “Oyun Başlatılamadı”
  dialog reporting `NVAPI_ACCESS_DENIED` and then exited. The actual Windows
  account reports the RTX 3060 Ti and driver status `OK`, `nvidia-smi` reports
  driver 617.14, and the requested temporary DRS write/remove test succeeds.
  This rules out a simple DRS-directory write failure but does not explain the
  driver's profile API denial.

## Root cause and limit

The gameplay root cause is **not yet proven**. Without a running game, the
compiled map's actual fountain/trigger classnames, positions, teams, and hero
heal/mana deltas cannot be observed. The missing map source also prevents a
reliable static entity audit. Guessing coordinates or overriding native fountain
behavior would risk healing the wrong area/team, so no such change was made.

## Verification

- `npm run check`: PASS (automated/static/mocked checks only; no zone behavior
  is covered by this result).
- MCP addon audit: PASS, 34 VScript and 11 Panorama files, zero findings.
- Engine acceptance: **BLOCKED** by the NVIDIA modal; no map was rendered and
  no runtime entity query or VConsole gameplay log was available.

## Required next evidence

Provide a Tools launch that reaches the map, or restore the authoritative
`enfos.vmap` source. Then enumerate `ent_dota_fountain` and custom trigger
entities with team and origin, stand a damaged/mana-depleted living hero inside
each intended zone, and confirm both current health and mana increase while
outside heroes and enemies do not receive the refill. Keep this item open until
those tests pass.
