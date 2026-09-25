# DECISIONS AND OPEN ITEMS

This file exists so Codex does not "helpfully" redesign locked decisions.

## LOCKED

### Core
- Dota 2 Custom Game.
- Original modern Enfo-inspired PvEvP survival.
- 60 authored waves.
- Normal run target ~30 minutes.
- Standard PvEvP equal team sizes.
- Co-op 1–5.
- Unequal PvEvP only custom/experimental.

### Map
- 2 normal lanes per team.
- 1 shorter central Boss lane.
- free rotation inside own arena.
- no physical crossing into opponent arena.
- opponent arena observable.
- Life starts 100.
- Core is not a normal attackable tower.

### Waves
- Boss every 5 waves.
- Boss wave = Boss only.
- Elite every 6 waves excluding Boss overlap.
- scheduled hostile overflow at cap directly costs Life.
- initial cap seed = 30 × active players, configurable.
- Boss not suppressed by ordinary cap.
- ability summons cannot cause free cap-based Life damage.

### Spellbringer
- core system remains.
- separate mana persists across waves.
- 8 launch abilities, 4 offensive / 4 defensive.
- offensive affects opponent PvE, not enemy heroes directly.
- Co-op offensive disabled.
- Future Reinforcements = 5 allied units around wave+4 power.

### Shop/economy
- full normal Dota shop remains.
- separate Ascended Shop.
- 30 launch Ascended items.
- normal item + Lumber upgrade.
- Tomes available from match start.
- six hero combat slots.
- fast flying courier.
- Gold and Lumber transferable.
- normal creep bounty shared; killer gets +20% of own equal share.
- Aghanim Shard/Scepter per hero.
- Aghanim Blessing frees slot.

### Boons
- Boss gives two-card team vote.
- Pacts remain.
- Boons last rest of match.
- normal Boon generally max 3 stacks; Unique once.

### Heroes
- roles: Tank/Fighter/Carry/Mage/Support.
- release 40 = 8 each.
- long-term 100 = 20 each.
- first 40 open.
- no ban phase.
- same-team duplicate forbidden; opposing duplicate allowed.
- every hero requires solo PvE build.
- prefer Dota native selection if technically viable.

### Progression
- Account XP/Level.
- Legacy.
- Hero Mastery.
- Persistent Hero Passive Tree.
- sequential difficulty unlock.
- permanent power exists.
- Standard PvEvP uses roughly 50% numerical persistent-bonus effectiveness.
- Co-op/Endless uses 100%.
- loser still earns progression.
- winner XP bonus target +15%.
- free out-of-match respec.

### Localization/live
- English, Turkish, Russian, Simplified Chinese mandatory.
- opening panel includes bug/development suggestion email.
- telemetry-based balancing.
- DEV/BETA and LIVE separation.
- architecture must scale to 100 heroes.

### References
- Watcher, Enfo's and other custom maps are references only.
- never copy their code/custom assets/UI/map data/text.
- suitable mechanics are independently reimplemented.

## PROVISIONAL BALANCE SEEDS
May change without reopening core design:
- leak normal -1 / Elite -2 / Boss -5,
- cap 30×player,
- Boss HP formula 1+0.75*(players-1),
- 1000G→10L and 10L→900G,
- Ascended ~55/70/85 Lumber tiers,
- Tome same-type price growth ~10%,
- difficulty stat multipliers,
- XP formulas/amounts,
- respawn ~5–20 sec,
- Boon numbers,
- Spellbringer costs,
- creep threat costs.

## BLOCKED PENDING WATCHER ZIP
Do not finalize:
1. exact unified Evolution/Talent framework,
2. exact Persistent Hero Passive Tree architecture/nodes,
3. whether provisional Attribute Bonus + Innate 30-point allocation remains,
4. final revisions to the five reference hero skills,
5. any additional courier progression/utility beyond flying delivery,
6. any Watcher-inspired Shard/Scepter mechanic.

Analysis is clean-room concept extraction only.

## BLOCKED PENDING ENFO MAP
Do not finalize:
1. exact terrain/path distances,
2. final merge/split geometry,
3. spawn/waypoint spacing,
4. additional Enfo-inspired wave/Spellbringer ideas.

## OPEN TECHNICAL POCs
Prove early:
1. can current Dota custom-game tooling reliably provide desired native hero-selection experience for 40–100 custom heroes?
2. best integration of normal Dota Shop + six-slot/no-backpack intent + flying courier/minimal delivery buffer.
3. production persistence backend availability/reliability.
4. current Workshop APIs assumed by UI/shop/selection.
