# Shadow Shaman — owner runtime checklist

Status: NOT RUN. Code/mocks are separate evidence. Restart the local addon fully after these KV/new modifier/localization changes. Use the local version, not the older Workshop package. Record date, Dota build and relevant VConsole messages for each failure.

## Quick first pass

1. Select Shadow Shaman. Confirm five skills, free first passive rank, level-6 start and five spendable points. No talent tree or persistent progression.
2. Q on a crowded group: the selected enemy must be hit even when more enemies than the target limit surround it. Beams connect from the hero to actual recipients; selected target has impact audio. No repeated hits on one recipient.
3. W on a creep: chicken model, no attacks/spells/items, base movement 140. The original model returns on expiry/death/strong dispel. Basic dispel must not remove Hex. Boss control lasts 35% of the listed duration before applicable engine resistance; verify original Boss model/scale returns.
4. E: visible continuous hand-to-target ropes, one channel sound loop, damage and self-healing each 0.5s. Stop, kill the target or strongly dispel its stun: damage/healing and loop must end. Cast again to confirm no old rope/sound persists. Boss channel uses 35% duration.
5. R at the chosen ground point: eight player-controlled stationary serpent wards, 30s life, native attack projectiles/audio. Select and order them to attack another enemy. Recast with refreshed cooldown: old group dies and only the new bounded group remains. Killing friendly summons as an opposing player must give zero gold/XP.
6. Passive: take a lethal hit with the ability ready. Survive at 1 HP, remove debuffs, transform briefly into a fast chicken; gain 0.1s invulnerability and 1s full damage reduction. Repeated damage must not retrigger while on cooldown. Break disables the save; illusions do not inherit it. After respawn the cooldown resets. Model returns after the buff.

## Rank and upgrade pass

- Compare rank 1 and rank 10 tooltips and observed damage/cooldown/mana/target limits. Ult ranks unlock at levels 5,10,...,50; each other skill has ten ranks. No extra talent points.
- Q damage is configured base + Intelligence; Boss raw damage is capped at 6% max HP before mitigation.
- E damage per tick is (configured DPS + 0.6 Intelligence) × 0.5; current heal uses this raw amount. Do not infer heal from enemy health lost after resistance.
- R damage is configured ward damage + 0.4 Intelligence. Existing Scepter adds 40% ward attack damage and the shared 25% ultimate cooldown reduction; Blessing must retain it. Test attack damage, not only tooltip values.
- Buy Shard: Hex should transform the primary plus up to two additional enemies within 325. Check Boss shortened duration on a secondary, immunity, strong dispel, primary spell absorption preventing spread, and exactly one effect/sound per transformed enemy. Generic Support healing amplification should no longer stack on Shadow Shaman. Other supports retain their existing bonus.
- This Shard is an authored Enfos Hex evolution, not native Urnaconda. Native confusion chickens and a unique hero Scepter evolution remain open development items, not passed tests.
- Repeat channel/purge/recast cases with two Shadow Shamans on opposing teams where possible; one caster's cleanup must not remove the other's effects.

## Evidence to capture

For each numbered step record PASS/FAIL, expected/observed result and VConsole errors/resource warnings. A screenshot proves appearance, not sound. Watch for Lua traceback, unknown modifier, missing particle/model/sound and repeated messages. Reconnect should preserve ranks, cooldowns and owned effects without duplication. Dense-wave performance remains a separate gameplay run.
