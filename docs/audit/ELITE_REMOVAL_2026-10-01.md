# Elite wave removal — 2026-10-01

Status: **IMPLEMENTED BUT NOT ENGINE-VERIFIED**.

## Problem and cause

Eight authored waves (6, 12, 18, 24, 36, 42, 48 and 54) still had
`wave_type = elite` and scheduled `enfos_elite_*` units. The wave planner therefore
continued to spawn Elites despite the owner's request to remove them.

## Change

Those eight slots use normal creep equivalents. The eight custom Elite NPC
definitions and the unused `elite_framework.lua` were removed; the wave manager
no longer loads an Elite framework, publishes an Elite marker, or classifies
Elite waves. The Elite Hunters Boon and leak classification were removed.
Loading-screen text now uses localized, accurate wave and Core rules. Four-
language wave titles no longer label these slots as Elite. The production wave
economy CSV reflects the normal compositions.

## Verification

- `npm run check`: PASS, zero failed checks.
- `node tools/wave_economy.mjs --check`: PASS through the full check suite.
- `mcp__dota2_workshop__addon_audit`: PASS; 34 VScript and 11 Panorama files,
  zero findings.
- Mock regression: all eight retired slots report `normal`, and their plans
  contain no `enfos_elite_*` IDs.
- Content regression asserts there are no Elite unit definitions, runtime
  framework hooks, or Elite Hunters Boon.
- Dota runtime spawn/VConsole verification: PENDING; Dota 2 was not running and
  VConsole was unavailable during this pass.

## Remaining check

## Focused delivery follow-up

The Elite-only changes were isolated from the existing native-Boss and other
contributor edits. The isolated index copy passes
`tools/tests/elite_retirement.test.mjs`: all 60 plans at 1..5 players contain
48 normal and 12 Boss-only waves, with no Elite NPCs/framework/Boon. The sixteen
former-Elite title/description tokens and loading rules are updated in all four
source/output locales. The old Elite leak/framework assertions were retired
from the existing Lua suite. Its Elite, normal/Boss schedule and Life checks
pass before it reaches an already stale Boss %-HP-cap assertion, which belongs
to the remaining Boss integration work; do not call that isolated whole suite
green. The isolated production economy CSV was regenerated and its 300-case
check passes. `.gitattributes` pins generated CSV to LF so Windows checkout
does not invalidate exact generated-file comparisons. The full current
candidate check remains separate from this isolated delivery check.

## Runtime acceptance still pending

Open a fresh local match and confirm waves 6, 12, 18, 24, 36, 42, 48 and 54
contain only normal creeps, and the loading screen text matches the active
48-normal/12-Boss schedule. Runtime confirmation remains outstanding; there is
no active Elite model/nameplate that should appear.
