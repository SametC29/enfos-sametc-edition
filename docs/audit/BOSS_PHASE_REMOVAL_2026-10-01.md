# Boss health lock and phase removal — 2026-10-01

Status: **IMPLEMENTED, NOT ENGINE-VERIFIED; native hero boss replacement remains open**.

## Root cause

The boss base modifier clamped health to 70% and then 35% of maximum health.
Releasing each floor depended on a damage event advancing the phase; a later
think tick was only a fallback. Each phase change also made the boss rooted,
disarmed, and invulnerable for two seconds. A separate 4%-max-health damage cap
made large hits disproportionately weak. This matches the reported first-boss
lock at 2,800 HP when maximum health was 4,000.

## Change

- Removed phase state, health-floor handling, phase guard modifier, and the
  health-threshold enrage/add-spawn transitions.
- Removed the general per-hit damage cap; the 150-point reflection safety cap
  and 60% boss status resistance remain.
- Removed phase values from the wave status net table.
- Existing signature attack strength and target count now scale modestly with
  wave number, so encounter pressure progresses without health lock phases.

This does not yet convert custom bosses into native hero units, give them four
native abilities, or apply player-level scaling and item builds. Those parts of
Desktop update item 7 remain incomplete.

## Verification

- `npm run check`: PASS; mock regression tests verify the old health floors and
  ordinary damage cap are gone. This is not a gameplay simulation.
- MCP addon audit: PASS; 34 VScript and 11 Panorama files scanned, zero findings.
- Dota Tools/VConsole: unavailable. Launch is blocked by `NVAPI_ACCESS_DENIED`,
  so the boss damage, deaths, and logs have not been observed in-engine.

Required engine check: spawn a boss with 4,000 maximum health, deal a hit above
2,800, verify health goes below 2,800 and the boss can die; then inspect VConsole
for Lua errors and verify the wave HUD has no phase data dependency.
