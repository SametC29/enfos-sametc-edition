# Hero power — 2026-09-27

The user still finds solo too difficult and explicitly prefers powerful heroes,
wave clearing and skill combinations in the spirit of Enfo/Watcher of Samsara
over weakening enemies. Live testing belongs to the user; no game was launched
or controlled for this change.

## Implemented seed

`heroes/power_config.lua` defines the common seed; `waves/balance_config.lua`
snapshots exact values with version `2026-09-27-hero-power-1` before wave 1.
The base component applies on hero spawn. Solo totals apply when exactly one
playing-team member is present at the match snapshot, symmetrically on either
arena. Disconnects do not change power. Values do not fade at wave 20.

| Bonus | Team play | Solo total (including base) |
|---|---:|---:|
| Maximum health | 250 | 600 |
| Maximum mana | 75 | 225 |
| Attack damage | 25 | 45 |
| Attack speed | 25 | 45 |
| Spell amplification | 20% | 35% |
| Health regeneration / second | 4 | 8 |
| Mana regeneration / second | 2 | 4 |
| Hero skill cooldown reduction | 15% | 25% |

This is match power, not purchased persistent progression. Both teams receive
the same baseline in multiplayer. Bonus persists through death, is not purgable,
does not duplicate on respawn/reconnect, and excludes illusions/Meepo clones/
Tempest Doubles. Capacity increases fill only their added amount; reapplying the
same values cannot heal/refill a player. Dead heroes are not resurrected.
Cooldown reduction excludes items and abilities cast by other entities.
Spellbringer's separate mana and timers are unchanged. Native modifier data is
transmitted to clients. The buff and solo HUD descriptions exist in EN/TR/RU/zh-CN.

The earlier solo enemy HP x0.65 / base attack x0.60 factors are removed. Difficulty
still scales enemies: Casual 0.75/0.80, Normal 1/1, Hard 1.25/1.10, Nightmare
1.5/1.20, Hell 2/1.35. Enemy counts, bounties, Boss-only waves and Life rules are
unchanged. The longer early solo preparation and batch pacing remain.

## Limits and acceptance

This is the first power pass, not a replacement of all 40 kits with Watcher skills.
No third-party gameplay code/assets were imported or analyzed for this change.
Existing project-owned skills benefit from more mana, spell amplification and
uptime; individual hero mechanics still require separate work and playtests.
Cooldown bonuses can combine with existing Aghanim/item effects via Dota rules;
late-game stacking and completion times need actual balance testing.

Nine new mock-engine tests cover all-roster baseline application, solo upgrades,
repeat-event safety, later spawns, both multiplayer teams, exclusions, cooldown
scope, client stat transmission, snapshot copies and death behavior. Full checks:
87 Lua behavior tests plus 11 JavaScript tests, zero failures. Map manifest
integrity passes; neither map files nor UI layouts were rebuilt.

User fresh-match acceptance: Drow/Luna should spawn in their own base without an
origin assertion; Enfo Power appears on the hero; solo totals appear by the first
preparation; skill/mana uptime and the first five waves should feel stronger.
Respawning must preserve one copy of the bonus. Native execution and overall
solo viability remain unverified until the user's playtest.
