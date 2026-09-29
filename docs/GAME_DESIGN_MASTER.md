# GAME DESIGN MASTER — Modern Enfo-Inspired Dota 2 PvEvP Survival

Status: product source of truth.

## Latest playtest revision — 2026-09-27

The user's 40-wave feedback supersedes earlier courier, fixed-count and unlimited
wave-wait assumptions: no courier (direct inventory delivery); ordinary waves have
`(20 + 2*(wave-1))*players` scheduled units, and advance on a deadline even if uncleared.
Boss-only transition Life rules remain; population overflow Life loss was removed on 2026-09-28. Gold/XP payouts are on kills;
the extra wave-completion award is removed. Systems stay, but baseline offensive
bonuses and Boon/Pact frequency are reduced (vote every second Boss).
Hero-specific trees must replace shared Evolution choices rather than stack on top.
Provisional timing, implementation boundaries and engine acceptance:
[40-wave follow-up](audit/PLAYTEST_40_WAVES_2026-09-27.md).

## 1. Product vision

Create an original Dota 2 Custom Game centered on authored PvE survival, team composition, itemization, strategic PvEvP interference through Spellbringer, readable Boss/Elite encounters, and long-term account/hero progression.

Reference inspirations such as Enfo's, Watcher of Samsara, Aghanim's Labyrinth and other successful custom maps may inform mechanics and pacing. Since the owner's 2026-09-29 update, code reuse is permitted with verified source, license, compatibility and notices under REFERENCE_ANALYSIS_POLICY.md. Custom assets and other authored material require separately established rights; existing map authorization remains specific.

Long-term product target:
- release with 40 heroes,
- grow to 100 heroes,
- maintain four mandatory languages,
- support a real recurring player base,
- balance through telemetry plus playtest,
- keep normal runs understandable and close to 30 minutes.

## 2. Modes

### Standard PvEvP
Two teams defend separate mirrored arenas while interfering with the opponent's PvE environment through Spellbringer.

Standard matchmaking uses equal team sizes:
- 1v1
- 2v2
- 3v3
- 4v4
- 5v5

Teams cannot physically enter one another's arena. They may see the opponent arena and relevant state.

After wave 60, Standard PvEvP automatically enters Endless until one team's Life reaches 0. There is no "claim rewards and quit" vote in PvEvP.

### Co-op
1–5 players defend one arena.

After wave 60:
- normal completion rewards are secured,
- team votes `Claim Rewards` or `Enter Endless`,
- Endless checkpoint bonuses occur every 5 waves.

### Custom / Experimental PvEvP
Unequal team sizes may be allowed privately. It is not considered standard competitive balance. Future-wave budget, Boss scaling and Spellbringer regen may normalize around current active players.

## 3. Match structure

Wave 1 starts as soon as the match enters `GAME_IN_PROGRESS`; there is no opening
preparation countdown. Preparation remains between later waves, and Boss waves
retain their incoming warning.

Normal run:
- 60 authored waves,
- target ~30 minutes,
- core wave compositions are learnable,
- randomness comes mainly from builds, Boons/Pacts, difficulty modifiers and player choices.

Boss waves:
5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60

Elite waves:
6, 12, 18, 24, 36, 42, 48, 54

Totals:
- 12 Boss waves
- 8 Elite waves
- 40 Normal waves

### Boss-only rule
Boss waves contain only the Boss. No normal wave budget spawns during that wave.

Before Boss spawn:
1. show a short `BOSS INCOMING` transition,
2. stop scheduling the prior wave,
3. resolve remaining leakable scheduled prior-wave units once,
4. apply normal Life loss to those unresolved leakable units,
5. clean non-leakable temporary units without Life loss,
6. begin Boss on a clean battlefield.

This keeps Boss fights readable and prevents leftover-wave chaos.

## 4. Map

Each team arena:
- two normal lanes,
- one shorter central Boss lane,
- merge/split geometry,
- one Life Core.

Normal routes should:
- begin separately,
- create at least one meaningful shared combat zone,
- diverge or create a second rotation decision,
- reconverge toward Life Core.

Players:
- rotate freely between own lanes,
- are not lane-locked,
- cannot cross into enemy arena by walking, Blink, TP or force movement,
- may move camera to and observe enemy arena.

TP is permitted inside own arena. Prefer fixed tactical destinations such as Core and lane anchors.

### Life Core
Portal/objective, not a fighting tower:
- no ordinary HP/armor/attack loop,
- units entering its leak trigger are resolved and removed.

Starting Life: 100

Starting leak values:
- normal scheduled creep: -1
- Elite: -2
- Boss: -5

Late Endless may increase leak severity.

## 5. Wave threat budget and spawning

Baseline non-Boss threat budget:
`20 basic-creep equivalents × current active players`

Do not require every special wave to contain exactly 20 physical entities per player. Special units may cost more threat.

Example conceptual costs:
- basic melee/ranged: 1.0
- Runner/simple special: 1.1–1.4
- defensive/support special: 1.5–2.0
- Summoner/controller/high-impact special: 2.0–2.5

This controls entity count while preserving difficulty.

Spawn normal/Elite waves in multiple batches over roughly 12–15 seconds.

### Scheduled hostile population (2026-09-28 user revision)
Scheduled wave units have no simultaneous population cap. Every scheduled unit
spawns in its normal timed batch even when earlier waves remain alive. Population
alone never suppresses a spawn or deducts Team Life. This supersedes the old
30-per-player cap and overflow rule.

Temporary summons retain their separate lifespan/count limits. Physical Core
leaks and the existing Boss-only transition/deadline rules remain separate.
Crowded-lane engine performance must be measured in local gameplay; uncapped
population is not a guarantee of unlimited engine capacity.

## 6. Creep AI

Default objective: Life Core.

Standard creep:
1. follow authored lane waypoints,
2. attack eligible hero entering acquisition range,
3. return to route when target invalid/leaves leash.

Runner:
- ignores heroes,
- heads directly toward Core,
- Taunt immune.

Most standard creeps can be Taunted.

Implement anti-block/path recovery:
- stuck detection,
- waypoint reacquisition,
- temporary collision/pathing recovery,
- no permanent body-block exploit.

## 7. Core creep archetypes

Initial set:
1. Soldier — baseline melee.
2. Archer — baseline ranged.
3. Runner — ignores heroes, rushes Core.
4. Assassin — invisibility identity.
5. Mindstealer — mana pressure.
6. Frostguard — defensive/armor support.
7. Conqueror — telegraphed short control.
8. Summoner — strictly limited temporary adds.
9. Shieldbearer — physical durability.
10. Spellguard — magic resistance.
11. Bloodbeast — lifesteal/regeneration.
12. Reflector — controlled damage reflection.
13. Venomous — stacking poison/DoT.
14. Healer — heals nearby hostiles.

Possible later types:
- Splitter
- Exploder
- Curse Caster
- Dispel Caster
- Silence
- Knockback/control

Readability: a unit's key mechanic must be evident through silhouette/VFX/icon/name/wave preview. Avoid loading every creep with many unrelated abilities.

Summoned minions:
- no meaningful Gold farming,
- no or negligible XP,
- normally no Life leak,
- strict simultaneous caps.

## 8. 60-wave content skeleton

Exact percentages and stats are tuning data. This table defines teaching/pacing.

### 1–10: onboarding
1. Soldier + Archer
2. stronger ranged mix
3. simple fast assault
4. Frostguard/support introduction
5. Boss — Stonebreaker
6. Runner + Elite Vanguard/Runner
7. Venomous
8. Healer + basics
9. mechanically simple durable wave
10. Boss — Brood Matron

### 11–20: control/resource pressure
11. Invisible Assassin
12. Assassin + Elite Assassin
13. Mindstealer
14. Conqueror
15. Boss — Bloodfang Alpha
16. simple high-stat recovery wave
17. Shieldbearer
18. Summoner + Elite Necromancer/Summoner
19. Runner + Archer
20. Boss — Frost Warden

### 21–30: build checks
21. physical/projectile-defense theme
22. Spellguard
23. Healer + durable melee
24. Reflector + Elite Reflector
25. Boss — Mind Devourer
26. Venomous pressure
27. Curse/dispel-style caster
28. Splitter
29. Runner + Shieldbearer
30. Boss — Iron Colossus

### 31–40: combinations
31. Invisible + Runner
32. Summoner + Mindstealer
33. Shieldbearer + Healer
34. Exploder
35. Boss — Gravecaller
36. ranged burst + Elite Stormcaster
37. simple high-stat recovery wave
38. Conqueror + fast creeps
39. Reflector + Mindstealer
40. Boss — Storm Tyrant

### 41–50: coordination
41. regeneration + Spellguard
42. Invisible + Poison + Elite Assassin
43. Runner + Frostguard
44. Summoner + Shieldbearer
45. Boss — Shadow Huntress
46. simple strong melee/ranged recovery wave
47. Curse + armor reduction
48. Splitter/Exploder + Elite Bomber
49. Runner + Mindstealer + Shieldbearer
50. Boss — Plague Behemoth

### 51–60: final exam
51. Invisible + Runner
52. Armored + Spellguard
53. Healer + Summoner
54. Conqueror + Mindstealer + Elite Controller
55. Boss — Rift Lord
56. fast basic assault
57. Reflector + Venomous
58. Runner + Invisible + Mindstealer + Healer
59. Shieldbearer + Summoner + Spellguard
60. Final Boss — Ascendant Gatekeeper

Rhythm goals:
- early game teaches one idea at a time,
- midgame combines known ideas,
- deliberate recovery waves reduce fatigue,
- late game combines learned mechanics rather than endlessly adding gimmicks.

## 9. Elite system

Elite is not "same creep with more HP."

Elite has:
- clear special nameplate/health presentation,
- one meaningful mechanic augmentation,
- normal leak penalty -2.

Examples:
- Elite Assassin — invisibility plus limited ally movement support.
- Elite Mindstealer — telegraphed AoE mana pressure.
- Elite Summoner — limited periodic adds.
- Elite Bloodbeast — localized lifesteal aura.
- Elite Conqueror — stronger readable control.
- Elite Reflector — capped reflect.
- Elite Bomber — delayed visible explosions.

Nightmare/Torment can add another modifier carefully, never unreadable stacks.

## 10. Boss system

Bosses enter through the central Boss lane.

General:
- one Boss per team,
- Boss-only wave,
- HP scales with active player count,
- strong readable telegraphs,
- avoid long hard-invulnerability periods,
- prefer shields/damage reduction/vulnerability windows,
- Boss CC is reduced/capped rather than completely invalidating Tank/control heroes,
- HP-percent damage, reflect and hard control have Boss-specific caps.

Initial HP scaling seed:
`1 + 0.75 × (players - 1)`

### Working Boss identities
5 — Stonebreaker
- large telegraphed Ground Slam
- teaches movement/telegraph

10 — Brood Matron
- lays eggs/adds
- teaches add priority

15 — Bloodfang Alpha
- lifesteal
- low-HP enrage
- teaches burst timing

20 — Frost Warden
- frost zones
- defensive support effect
- teaches positioning/priority

25 — Mind Devourer
- mana-drain zones
- telegraphed high-mana-target attack
- teaches resource positioning

30 — Iron Colossus
- physical reflect/damage-reduction phase
- teaches attack restraint/timing

35 — Gravecaller
- raises strictly capped temporary fallen minions
- teaches boss/add split attention

40 — Storm Tyrant
- Chain Lightning spacing
- delayed charged ground zones

45 — Shadow Huntress
- brief stealth/reposition
- marks hero before heavy strike
- detection has value

50 — Plague Behemoth
- temporary poison zones
- capped poison stacks

55 — Rift Lord
- opens side portals
- creates limited lane pressure
- uses the two-lane geometry

60 — Ascendant Gatekeeper
Three-phase final exam:
1. clear telegraph/slam foundation,
2. portals/adds plus shield/vulnerability,
3. selected earlier mechanics in authored sequence,
4. low-HP final enrage.

Names are working titles. Final visual identity and lore must be original.

## 11. Difficulty

Five tiers:
Easy / Normal / Hard / Nightmare / Torment

Sequential unlock.

Standard PvEvP difficulty is voted; do not force a player into a difficulty they have not unlocked. The selectable maximum is constrained by the lowest relevant unlock.

Difficulty changes mechanics, not just stats.

Seed multipliers:
- Easy ~0.75 HP / 0.80 damage / simplified mechanics
- Normal 1.00
- Hard ~1.30 HP / 1.10 damage + more special pressure
- Nightmare ~1.70 HP / 1.20 damage + enhanced Elite/Boss behavior
- Torment ~2.20 HP / 1.35 damage + advanced readable mechanics

Higher tiers may:
- enable extra Boss behavior,
- shift threat budget toward specials,
- augment Elites,
- shorten safe windows.

Never make high difficulty unreadable particle spam.

## 12. Spellbringer

Core PvEvP system.

Each player:
- separate Spellbringer Mana,
- separate from hero Mana,
- starting mana,
- max mana,
- passive time regeneration,
- does NOT reset each wave.

In Standard equal-team PvEvP, no player-count normalization is required. In custom unequal PvEvP or after confirmed abandonment, normalization may compensate total team potential.

Offensive Spellbringer affects opponent PvE, not enemy heroes directly.
Co-op disables offensive abilities.

### Initial 8 abilities

Offensive:
1. Arcane Barrier — temporary spell-resistance/shielding on opponent creeps.
2. War Standard — stationary summon buffing opponent creeps' attack/movement.
3. Thorn Idol — stationary summon granting controlled reflect to opponent creeps.
4. Rift Surge — adds limited extra hostile pressure; no reward farming; cannot become guaranteed cap-leak damage.

Defensive:
5. Whole Displacement — return eligible non-Boss hostile toward lane start.
6. Reveal — reveal invisible enemies in an area.
7. Purification — remove hostile Spellbringer buffs, cleanse defined ally effects, counter hostile Spellbringer summons.
8. Future Reinforcements — summon exactly 5 allied fighters at approximately current-wave+4 power.

Future Reinforcements:
- no Boss,
- no Elite,
- safe reinforcement pool or safely adapted normal archetypes,
- defend/fight, never leak,
- no economy exploit.

Numeric costs/durations are balance data.

Keep all 8 launch abilities. Use a dedicated Spellbringer UI rather than overcrowding hero ability hotkeys.

## 13. Hero roster

Roles:
Tank / Fighter / Carry / Mage / Support

Release:
- 8 per role
- 40 total
- all first 40 open

Long-term:
- 20 per role
- 100 total

Future 60 may be progression-unlocked.

Selection:
- no ban phase,
- no same-team duplicate,
- opposing teams may pick same hero,
- prefer Dota's native hero-selection experience if robustly possible,
- prove technically early; only use custom fallback if necessary.

Every hero, including Tank and Support, requires at least one viable solo PvE-clear build.

User direction, 2026-09-27: Enfo's appeal includes deliberately powerful heroes.
Clarification: lower overall difficulty through stronger kits in solo, multiplayer
co-op and PvEvP PvE combat; do not scope this direction to solo assistance. Audit
nearly all kits, especially Carry/Fighter/Mage, for wave-clear mechanics inspired
by Watcher and similar games. Tank/Support partially retain their role-specific
utility and defense, with a viable solo-clear path. See the current
`ANTIGRAVITY_KAHRAMAN_YENILEME_PROMPTU.md` handoff.
Prefer stronger wave-clearing kits, spell uptime and ability synergies over
reducing enemy stats to solve solo difficulty. Preserve threats and readable Boss
mechanics. Watcher of Samsara remains a mechanics/feel reference for independently
authored skills, not imported code or custom assets. The provisional common hero
power seed is documented in `audit/HERO_POWER_2026-09-27.md`; it is not a substitute
for individual hero kit acceptance or proof of 60-wave balance.

## 14. In-match hero progression

User-directed target (2026-09-29): max hero level **50**; Q/W/E/R and the fifth
Enfos passive each have **10 total ranks**. The fifth passive is project-specific,
not the modern native Dota innate. This supersedes the provisional level-30
Q4/W4/E4/R3/attribute7/innate8 plan; match-level migration is partially implemented.

Testing start (2026-09-29): every selected hero begins the match at level **6**,
with five spendable ability points from levels 2–6. The fifth Enfos passive is
still granted separately at rank 1. This is a temporary testability baseline;
the level-50 cap and XP thresholds remain unchanged. The level and point grant
occur once per player and do not repeat on respawn or reconnect.

The current automatic free passive rank is separate from spent points. Five skills
at rank10 require 49 purchased ranks. The proposed allocation preserves the free
passive at hero level1 and uses the 49 points from levels2–50. With the level-6
testing start, five points are granted immediately and 44 remain across levels
7–50. The match XP curve and starting-level point budget are implemented in
`heroes/match_levels.lua`, but
still need in-engine confirmation. Ten-rank ability definitions, rank unlocks and
native UI/tooltip behavior remain migration work. Special talents and Shard/Scepter
remain separate systems. See DECISIONS_OPEN_ITEMS and HERO_ABILITY_REFERENCE for
the migration acceptance contract.

Manual skill points.

Use Dota-style STR/AGI/INT baseline; role and primary attribute are separate. Universal can be supported when appropriate.

### Important consolidation rule
Do not ship two overlapping in-match talent/card systems.

The current Evolution Card concept and Watcher-style in-match Talent Tree must be compared after Watcher files arrive and unified into one coherent in-match build-choice system.

Persistent Hero Mastery Passive Tree remains separate.

## 15. Evolution / build-choice requirements

Current milestone targets:
levels 4 / 7 / 10 / 13 / 16 / 19

At each:
- present 2 hero-specific choices,
- match never pauses,
- no forced random timeout,
- player may defer; choices queue,
- no skill-point cost,
- choices alter build direction,
- choices are not tied rigidly to "Q then W then E".

Mastery can unlock additional alternatives into the candidate pool while each choice remains manageable.

## 16. Shard and Scepter

Every hero ultimately gets:
- unique Aghanim's Shard mechanic,
- unique Aghanim's Scepter mechanic.

Shard: smaller mechanic evolution.
Scepter: major mechanic evolution.

Aghanim's Blessing:
- special/Ascended surface,
- consumes Scepter as appropriate,
- retains Scepter upgrade,
- frees inventory slot,
- Lumber price is balance data.

Shard/Scepter are never Mastery-gated.

## 17. Five reference heroes

Prototype role targets, not final lore/names.

Tank — Bulwark
- Shield Slam
- Challenge/Taunt
- Iron Guard
- Fortress
- Innate Unbreakable
- requires solo damage branch

Fighter — Vanguard
- Cleaving Strike
- Rush
- Battle Hunger
- Warpath
- Innate Momentum

Carry — Ranger
- Piercing Arrow
- Multishot
- Hunter's Mark
- Arrow Storm
- Innate Predator
- Poison/Crit/Projectile paths

Mage — Arcanist
- Arc Bolt
- Gravity Well
- Arcane Overflow
- Cataclysm
- Innate Arcane Mastery

Support — Oracle
- Radiant Pulse heal+damage
- Blessing
- Sanctuary
- Divine Intervention
- Innate Benevolence
- requires viable offensive solo-clear path

Revise after clean-room Watcher analysis if useful concepts improve them.

## 18. Normal Dota shop

Keep the full familiar normal Dota shop:
- items,
- components,
- recipes,
- consumables,
- normal categories.

Do not simplify the normal Dota catalog merely for this mode.

Add a separate Ascended Shop.

Normal Dota items generally follow current upstream Dota behavior. Build compatibility audits around Dota patches.

## 19. Inventory and courier

Hero combat inventory:
- 6 primary item slots,
- do not make backpack juggling a core mode mechanic.

Courier:
- one fast flying courier per player,
- delivery/utility role,
- cannot enter enemy arena,
- cannot trigger Life,
- not targeted by ordinary PvE creeps,
- preferably untargetable/invulnerable to avoid punitive courier micro.

Earlier design avoided a traditional long-term stash. Preserve that intention with a minimal delivery buffer/courier flow rather than encouraging hoarding outside the 6 hero slots.

Exact integration with normal Dota purchase/stash behavior must be proven early.

## 20. Economy

Separate player currencies:
- Gold
- Lumber

Normal creep Gold:
- automatically team-shared,
- not last-hit-exclusive.

Reference:
- total bounty divided equally among active teammates,
- killer gets +20% of their equal share.

Example 100 bounty / 5 players:
20 each, killer 24.

XP:
- shared evenly among appropriate active teammates to avoid huge last-hit level gaps.

Transfers:
- Gold and Lumber to teammates,
- no tax initially,
- server-authoritative,
- presets plus custom amount,
- do not redistribute abandoned player's economy.

## 21. Gold ↔ Lumber

UI conversion.

Starting seed:
- 1000 Gold → 10 Lumber
- 10 Lumber → 900 Gold

Reverse conversion has ~10% loss.

These are alpha values, not sacred.

## 22. Tomes

Available from match start.

- STR Tome
- AGI Tome
- INT Tome

Consumed immediately for match-only permanent stat.

Same-type purchase price escalates; starting concept +10% per purchase.

Purpose:
- alternative scaling,
- tradeoff against item progression,
- Endless stat sink.

Do not wave-lock Tomes.

## 23. Ascended Shop

Launch count: 30.

No role lock. Role tags are recommendations only.

Formula:
required normal Dota item + Lumber → Ascended version.

Rules:
- base item consumed/replaced,
- base identity remains recognizable,
- usually one major new PvE mechanic plus tuning,
- one identical Ascended copy per hero,
- team-wide debuffs use explicit cap/highest-value stacking rules,
- sellback ≈90% underlying Gold and ≈90% Lumber.

Economy targets:
- typical wave-60 player: 1–2 Ascended,
- economy focus: 2–3,
- deep Endless: eventually 6.

### Initial 30
1. Heart of Tarrasque → Worldheart — burst threshold grants capped max-HP shield.
2. Crimson Guard → Bastion Guard — Guard adds temporary HP-scaled physical barrier.
3. Pipe of Insight → Aegis of Insight — barrier grants temporary status resistance.
4. Blade Mail → Thornplate — capped reflected damage heals owner; Boss cap.
5. Abyssal Blade → Abyssal Dominion — control creates capped Elite/Boss vulnerability.
6. Harpoon → Leviathan Harpoon — pull grants temporary cleave/splash.
7. Satanic → Blood Oath — kills during active sustain extend duration within cap.
8. Sange and Yasha → Warstride — after slow/stun gain temporary MS/AS with ICD.
9. Daedalus → Starforged Daedalus — crits build capped Physical Fracture.
10. Butterfly → Phantomwing — successful evade grants short stacking AS.
11. Monkey King Bar → Heavenpiercer — proc chains some bonus damage to second creep.
12. Mjollnir → Stormfather — periodic overcharged chain lightning.
13. Octarine Core → Chronocore — after N casts reduce non-Ult cooldowns by capped amount.
14. Bloodstone → Arc Bloodstone — capped spell-lifesteal overheal becomes barrier.
15. Refresher Orb → Eternity Orb — after Refresher temporary mana-cost reduction; never refresh Spellbringer/Ascended ICDs.
16. Scythe of Vyse → Grand Vyse — stronger Elite interaction; Boss gets short vulnerability instead of full Hex.
17. Guardian Greaves → Seraphic Greaves — Mend leaves short team HP/Mana regen.
18. Holy Locket → Sacred Reliquary — portion of heal splashes to lowest-HP nearby ally.
19. Lotus Orb → Mirror Lotus — successful Echo Shell trigger gives small capped heal.
20. Solar Crest → Sunward Crest — reduced portion of buff splashes to nearby allies.
21. Assault Cuirass → Legion Cuirass — aura builds capped extra armor reduction.
22. Shiva's Guard → Absolute Zero — Arctic Blast leaves short slowing field.
23. Eye of Skadi → Eye of Deep Winter — attack sequence causes capped PvE Frost Shatter.
24. Gleipnir → World Chain — rooted creeps share capped portion of incoming damage.
25. Wind Waker → Tempest Waker — cyclone end creates ally-speed/enemy-slow field.
26. Boots of Bearing → War Drums of Ascension — active grants temporary PvE damage.
27. Black King Bar → Sovereign King Bar — active gives additional capped Elite/Boss damage reduction.
28. Aeon Disk → Chrono Disk — Combo Breaker gives nearby allies short damage reduction.
29. Linken's Sphere → Astral Sphere — Spellblock gives temporary status resistance + MS.
30. Bloodthorn → Soulpiercer — Soul Rend release splashes capped stored damage nearby.

Starting Lumber tiers:
Tier I ~55
Tier II ~70
Tier III ~85

Prices are simulator/playtest variables.

## 24. Boss rewards, Team Boons, Pacts

Every Boss kill gives:
- automatic Lumber to each active team member,
- a 2-card team Boon vote.

Vote:
- ~10 seconds,
- game continues,
- non-voters ignored,
- majority wins,
- tie random,
- ordinary Boon generally max 3 stacks,
- Unique once.

Candidate generation:
- prefer meaningfully different categories,
- reduce recent-card weights,
- opponent can inspect chosen Boons.

Initial Boons:
1 War Training — PvE damage
2 Quickening — attack speed
3 Arcane Knowledge — spell damage
4 Execution Training — low-HP normal creep damage
5 Elite Hunters — Elite damage
6 Boss Slayers — Boss damage
7 Battle Rhythm — early-wave burst, Unique
8 Vitality — max HP
9 Reinforced Armor — armor
10 Arcane Protection — magic resistance
11 Recovery — end-wave HP/Mana restoration
12 Second Wind — respawn reduction
13 Emergency Seal — restore Team Life, Unique
14 Resilience — shorter harmful effects
15 Prosperity — creep Gold
16 Boss Dividend — Boss Lumber
17 Efficient Exchange — Gold→Lumber efficiency
18 Tome Knowledge — slower Tome price growth, Unique
19 Merchant's Favor — better sellback, Unique
20 Mana Spring — Spellbringer regen
21 Deep Reservoir — max Spellbringer mana
22 Efficient Invocation — Spellbringer cost reduction
23 Reinforcement Mastery — Future Reinforcements +1 ally, Unique
24 Swift Response — movement speed
25 Field Medicine — healing/regeneration effectiveness

Pacts remain.

Initial Pact concepts:
- Blood Pact: significant damage up, max HP down.
- Greed Pact: significant Gold up, hostile wave HP up.
- Arcane Pact: strong Spellbringer regen up, max Spellbringer mana down.

Pacts should not appear in the earliest onboarding section; starting concept after wave 20.

## 25. Hero death

Respawn target ~5–20 sec depending on level.

No direct Gold loss, XP loss or Life loss from hero death.

Penalty is lost defensive uptime and resulting leaks.

## 26. Surrender / disconnect / abandon

Surrender:
- normally after wave 20,
- target ~75% team approval,
- partial legitimate progression remains.

If confirmed abandonment makes Standard PvEvP structurally unfair, early surrender may be unlocked for disadvantaged team.

Disconnect:
- reconnect window,
- do not instantly rescale temporary disconnect.

Confirmed abandon:
- remove/disable hero appropriately,
- future wave budget recalculates for active players,
- Spellbringer unequal-team normalization may update,
- no resource redistribution,
- do not delete existing units merely because player count changes.

Reconnect restores:
- hero,
- items,
- levels/skills,
- queued build choices,
- Boon display,
- Spellbringer state,
- Gold/Lumber,
- current match/UI state,
without duplication.

## 27. Persistent progression

Systems:
1. Account XP / Level
2. Legacy Tree
3. Hero Mastery XP / Rank
4. Persistent Hero Passive Tree
5. future hero unlocks

Avoid unnecessary extra currencies by default.

### Account Level
1–100.

Starting XP curve:
`next XP = 500 + 35 × (current level - 1)`

Raw account-power growth stops around Level 48; later levels focus more on unlock/prestige.

### Legacy
Starting:
- ~1 point every 2 Account Levels through ~48
- ~24 spendable points
- four branches, ~12 ranks each
- free respec outside matches

Branches:
Offense / Defense / Economy / Spellbringer

Reference rank scaling:
- Offense: ~0.5% PvE damage/rank plus milestones.
- Defense: ~0.5% max HP/rank plus armor/MR/respawn/shield milestones.
- Economy: intentionally conservative Gold/exchange/Boss-Lumber/Tome efficiency.
- Spellbringer: regen/max/start mana/cost efficiency/duration.

### PvEvP normalization
Co-op/Endless: numerical Legacy/Mastery bonuses at 100%.
Standard PvEvP: numerical persistent bonuses at about 50%.

Unlocked build options remain fully available.

### Hero Mastery
Per hero 1–20.

Starting XP curve:
`100 + 35 × (current mastery rank - 1)`

Starting rewards:
- every even rank +1 Persistent Hero Passive Point,
- ~10 points by rank 20,
- Mastery 5/10/15/20 unlock extra in-match build-choice alternatives.

Shard/Scepter not Mastery-gated.

Persistent Hero Passive Tree final nodes are BLOCKED pending Watcher reference analysis.

Combined raw persistent power budget:
- ~20–25% equivalent max in full Co-op context,
- Standard PvEvP numerical advantage roughly halved,
- build choice unlocks can add flexibility without raw stat inflation.

## 28. Match rewards

Starting full Normal wave-60 clear target:
- ~1500 Account XP
- ~500 Hero Mastery XP

Partial starting concepts:
Account:
`1200 × (completed waves/60)^1.30` plus clear bonus.

Hero:
`400 × (completed waves/60)^1.20` plus clear bonus.

Difficulty XP:
Easy .85
Normal 1.00
Hard 1.15
Nightmare 1.35
Torment 1.60

PvEvP winner:
+15% Account XP
+15% Hero Mastery XP

Loser still earns legitimate progression.

Surrender gets partial progression.
Abandon gets reduced legitimate progress only and never gains later team progress.

## 29. Endless

Co-op:
- normal rewards secured at 60,
- checkpoint every 5 waves.

Seed checkpoint:
+80 Account XP
+30 Hero XP
× difficulty

Deep Endless may diminish after ~100.

PvEvP:
- automatic after 60,
- scaling rises until defeat,
- may increase HP, damage, movement, special share and later leak severity to avoid infinite stalemate.

## 30. Future hero unlocks

First 40 open.

Future 60 may use transparent Hero Unlock Tokens:
- player chooses hero,
- no random unlock,
- token sources can include Account milestones, first difficulty clears and broad account-wide Mastery achievements.

Cadence must ultimately permit all 60 without one mandatory grind route.

Locked heroes can be tested in Training Mode before unlock.

## 31. Localization

Mandatory:
- English (`en`) — fallback/source
- Turkish (`tr`)
- Russian (`ru`)
- Simplified Chinese (`zh-CN`)

No user-visible hard-coded strings.

Localize all:
heroes, skills, Innates, Evolution, Shard/Scepter, Passive Tree, creeps, waves, Elite/Boss, Spellbringer, Boons/Pacts, Ascended items, progression, errors, onboarding, patch notices.

Validation:
- missing keys,
- orphan keys,
- duplicate keys,
- placeholder mismatch,
- suspicious hard-coded visible strings when practical.

QA:
- Russian expansion,
- Chinese wrapping/font,
- variables/numbers.

## 32. Opening/community message

First launch and optionally each major version:
- dismissible localized welcome panel,
- game version,
- concise onboarding,
- "For bug reports and development suggestions, contact: [SUPPORT_EMAIL]",
- optional copy-diagnostics button.

Do not show every match once dismissed for that version.

Diagnostics:
- build/version,
- match ID if available,
- language,
- error/reference code,
- never secrets.

Support email is central configuration.

## 33. Telemetry

Aggregate privacy-conscious metrics:
- game/config version,
- mode/difficulty/team size,
- hero pick,
- win/loss/clear/surrender/abandon,
- wave failures and leaks,
- crowded-lane spawn completion without population Life loss,
- Boss kill time,
- deaths,
- damage/heal/tanking aggregates,
- Spellbringer casts,
- Boon/Pact picks,
- Ascended purchase timing,
- Gold/Lumber conversions,
- Tome usage,
- match duration.

No unnecessary PII.

## 34. Accessibility/readability

Never communicate critical danger by color alone.

Use combinations of:
- icon,
- shape,
- motion,
- text,
- sound,
- telegraph.

Special creeps remain distinguishable in crowds.
Support a lower-VFX/readability option if practical.

## 35. Clean-room reference rule

Watcher of Samsara, Enfo's and other maps can teach:
- mechanic ideas,
- pacing,
- role/build patterns,
- map flow,
- boss telegraphs,
- progression concepts.

Do not take:
- code,
- custom models,
- textures,
- particles,
- audio,
- icons,
- UI,
- map geometry,
- custom names/lore,
- data tables/tooltips.

If a reference is itself a revised Dota ability:
- identify the underlying Dota/gameplay concept,
- decide whether it fits this game,
- design our own version,
- implement from scratch.

## 36. Design north stars

When unspecified, optimize for:
1. readable pressure, not chaos;
2. cooperation without making solo Co-op impossible;
3. PvEvP through PvE manipulation, not direct enemy-hero grief;
4. real build variety without duplicate upgrade systems;
5. performance failure becomes Life pressure, not server collapse;
6. progression gives growth/options without infinite stat inflation;
7. player can understand why they failed;
8. veteran can learn wave timing and plan;
9. systems scale cleanly to 100 heroes;
10. major features are testable, observable and reversible.
