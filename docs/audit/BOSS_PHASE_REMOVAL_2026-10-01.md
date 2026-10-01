# Boss health lock and phase removal — 2026-10-01

Status: **HEALTH PHASES REMOVED; native hero Boss candidate implemented; OWNER TEST PENDING**.

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
- The later item-7 pass now maps all twelve Boss waves to distinct roster heroes,
  installs each hero's native QWER and Valve bot build, scales to defending-team
  level, and removes the old themed telegraph/attack implementation entirely.
  Native targeting has mock coverage, but model, ability casts, builds and
  movement still need the owner's in-game verification.

## Verification

- `npm run check`: PASS; mock regression tests verify the old health floors and
  ordinary damage cap are gone. This is not a gameplay simulation.
- MCP addon audit: PASS; 34 VScript and 11 Panorama files scanned, zero findings.
- Dota runtime checks are **PENDING OWNER TEST**. Per owner direction, Codex
  must not launch or interact with Dota.

Required owner check: spawn each native Boss, confirm ordinary damage can take it
through its full health range without a phase lock, then verify native QWER casts,
build progression, death/reward behavior, and absence of new VConsole errors.
