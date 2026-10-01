# Authored wave pressure trend — 2026-10-01

Status: **STATIC TREND CHECK PASS — LIVE DIFFICULTY NOT CERTIFIED**.

## Method

`tools/wave_pressure.mjs` runs the production `WaveDefinitions:GetSpawnPlan`
for one defending player, reads each scheduled normal unit's `StatusHealth`,
`AttackDamageMin`, `AttackDamageMax`, and `AttackRate` from
`npc_units_custom.txt`, and aggregates each of the six ten-wave acts. Boss-only
waves are excluded. The generated CSV lists all 52 normal waves.

The attack-output proxy is `scheduled count × mean base attack damage ÷ attack
rate`. It is not actual DPS: it assumes all scheduled units can continuously
attack a valid target. It does not account for attack animation, armor,
resistance, pathing, target selection, ability damage, player clear speed,
difficulty multiplier, or Boss native-hero stats. This is a reproducible roster
trend check, not a combat simulator.

## Results per defending player

| Act | Mean scheduled units | Mean authored HP | Mean raw base attack output/s |
|---:|---:|---:|---:|
| 1 | 28 | 9,651 | 559 |
| 2 | 48 | 18,478 | 1,330 |
| 3 | 68 | 28,279 | 1,547 |
| 4 | 88 | 35,500 | 2,085 |
| 5 | 108 | 47,466 | 2,874 |
| 6 | 128 | 58,826 | 3,409 |

All three metrics increase from each act to the next. Individual waves are not
monotonic because the authored enemy composition changes; the runtime team
should still watch for sharp within-act spikes and dips during owner playtests.

## Validation

- `node tools/wave_pressure.mjs`: PASS; asserts all three act averages rise.
- `npm run check`: includes the generated CSV freshness and monotonic-act check.
- Runtime damage taken, kill times, leak counts, and player survival remain
  **PENDING OWNER TEST**. This tool does not establish live balance.
