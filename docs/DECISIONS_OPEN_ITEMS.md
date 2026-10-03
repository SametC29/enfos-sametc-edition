## 2026-09-30 owner decision — remove talent tree and persistent progression (supersedes earlier decisions below)
- Remove native/custom talent trees and all custom bonus talent slots for every hero. Keep Ability10–Ability17, Ability19 and Ability25 hidden. Do not award talent-gate ability points. The match level 2–50 budget of 49 points funds 49 paid Enfos skill ranks; the fifth passive first rank remains free.
- Remove account profiles, account XP, Legacy, Hero Mastery, permanent passive trees, unlocks, persistent rewards, profile storage and their HUD/localization. Keep match-local hero levels, kills/XP, Gold/Lumber, Boons, difficulty selection and match rewards that do not persist.
- This supersedes prior “keep progression” and talent-tree decisions in this historical file.

# DECISIONS AND OPEN ITEMS

## 2026-10-02 hero upgrade source findings — follow-up remains open
- Witch Doctor source review confirms Support Shard healing25% plus unique Switcheroo, but Scepter still supplies generic ultimate40%amplification/25%cooldown. Native build6943 Death Ward bounce radius575/lifesteal10 are absent. Unique Scepter/PvE mechanics remain OPEN; Support pulse_heal200 is configuration without a handler, not a completed ability. Individual source closure and passing mocks do not resolve this requested implementation.
- Zeus's current Mage Shard provides15%spell amplification. The shared Mage configuration also lists5%mana restoration but has no runtime mana handler. Zeus's four-language tooltip now describes implemented behavior; no mana mechanic was removed. The earlier unique hero Shard/Scepter request is not satisfied by these generic role/ultimate bonuses. Keep that design/implementation follow-up open while individual hero audits continue; do not count corrected text or generic acquisition checks as completing it.

## 2026-10-01 balance update — first eight Desktop items
- Every 5th wave Boss grants a Boon vote; the match snapshot cadence is 5 waves.
- Increase Boss Lumber rewards and keep the Gold→Lumber exchange in the four
  Ascended by wave 60 affordability target. Current implementation is a candidate;
  local Dota playtest still owns balance acceptance.
- Boss phases/signature attacks are removed in the native-hero Boss candidate.
  The server selects a distinct roster hero, reads Valve-native QWER and bot
  build data, scales level from defenders, and grants the final six-item
  milestone. These paths are implemented but not engine-verified; native cast
  usability, AI, item behavior and live late-wave pressure remain open.

## Owner clarification — 2026-10-01, Desktop item 7

Bosses retain their original native Q/W/E/R kit, including its passive abilities.
The owner chose this explicitly over restricting Boss selection to heroes with
four active spells. Do not invent active replacements for native passives.
Ability Draft metadata is not guaranteed contiguous or complete: resolve native
slots and bot-trained omissions from the installed hero record. Engine acceptance
of Boss casts, passives and native items remains pending owner playtest.

This file exists so Codex does not "helpfully" redesign locked decisions.

## 2026-09-27 live-test follow-up (provisional / blocked)
- Latest 40-wave test supersedes the earlier general-easier request: keep progression
  systems, reduce bonus magnitude/frequency; bosses must survive bursts and use their mapped native hero abilities without custom health phases.
  Exact ordinary count is 20 + 2*(wave-1) per hero; timed overlapping normal waves,
  on-kill payouts, lane-head spawns and no courier. See
  [local candidate and unresolved content](audit/PLAYTEST_40_WAVES_2026-09-27.md).
- Latest clarification: strengthen nearly all hero kits and lower general
  difficulty across solo/co-op/PvEvP, not just solo. Carry/Fighter/Mage emphasize
  wave clearing and synergies; Tank/Support partially preserve utility/defense.
  [Antigravity handoff](ANTIGRAVITY_KAHRAMAN_YENILEME_PROMPTU.md) records scope and
  acceptance. The user performs live tests; agent work is code/offline validation.
- User-directed balance change: strengthen heroes and skill uptime instead of
  weakening enemies for solo. [Hero power seed](audit/HERO_POWER_2026-09-27.md)
  supersedes the prior solo enemy reductions. Values are provisional; individual
  kit synergies and live solo viability remain unproven. Wave 1 still has 20 enemies.
- All 30 native-derived Ascended upgrades are currently exposed, but distinct PvE
  mechanics remain incomplete. Availability is not completion. Launch target stays 30.
- Legacy compiled Survival map currently loads, but future compatibility is open.
  Retired flat VMAPs are not the correct rebuild source and must remain archived.

## 2026-09-28 hero tree candidate (superseded)
- 40 per-hero Evolution profiles replace shared global stat choices. Six distinct
  focuses per hero recur across six two-choice tiers; 480 offered choices total.
  Balance is provisional pending local gameplay; Shard/Scepter and distinct Ascended
  mechanics remain open. See [tree audit](audit/HERO_TREES_2026-09-28.md).

## 2026-09-30 Native Enfos talent tree (superseded by removal decision above)
- Historical decision: use the engine-owned talent panel with four paired tiers at levels 10/15/20/25.
  Each hero offers eight options and the player chooses one from each pair, for
  four picks total. This replaces the provisional six custom milestones.
- Keep all six authored ability-focus effects per hero represented across the
  four pairs using profile indices `[0,1]`, `[2,3]`, `[4,5]`, `[3,4]`. The last
  pair repeats two effects so no distinct focus is lost. This yields 320 native
  talent abilities across the 40-hero roster.
- Bind each pair into native hero slots `Ability10`–`Ability17`; hide Dota's
  attribute ability in `Ability25` (`generic_hidden`) because attribute Tomes
  are sold in the Enfos shop. Keep legacy `Ability19` hidden as well. The
  Evolution modifier remains
  server-authoritative and applies the selected option when Dota reports the
  learned talent ability. The custom Panorama drawer is not loaded.
- Native talents spend ordinary ability points. The level-2-through-50 budget is
  49; reaching rank 10 in all five skills uses 49 paid ranks because the fifth
  Enfos passive's first rank is free. Grant one additional point at each native
  talent gate, for 53 total points: 49 skill ranks plus four talent picks. Level
  6 still starts with five spendable points. No points remain after the complete
  build; players may spend in any order.
- Automated KV, generator, localization, mock Lua and content-compile checks do
  not establish engine behavior. The native talent UI, `Ability25` suppression,
  point award timing, and four selected effects remain PENDING owner Dota testing.
  Do not launch or restart Dota for this work.
- Owner screenshots from the V1.0.3 live test show extra talent icons on the
  regular ability bar, blank options in the native tree, and the `+2 all
  attributes` control. Root cause confirmed for the extra icons: talent KV used
  visible `PASSIVE`; generator now emits `PASSIVE | HIDDEN` and `MaxLevel 1` for
  all 320 talent abilities. The `+2` control is Dota's newer `Ability25`
  attribute ability (introduced in 7.29); the prior generator hid only legacy
  `Ability19`, so it now sets both slots to `generic_hidden`. Offline tests and
  content compilation pass. Installed VPK localization uses lowercase
  `DOTA_Tooltip_ability_`; tests now assert all 320 title/description pairs in
  all four resource and Panorama locales. Blank tree labels and attribute
  suppression remain PENDING runtime retest; do not claim fixed until the owner
  tests a fresh map using the local candidate.

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
- Elites were removed from scheduling, NPC definitions, runtime framework, and Boons; the eight former Elite slots are normal waves (owner-directed 2026-10-01).
- 2026-09-28: scheduled hostiles are uncapped; population never directly costs Life.
- Timed batches and temporary summon bounds remain; crowding requires engine performance testing.
- Wave 1 starts immediately when the match enters `GAME_IN_PROGRESS`; later wave preparation remains.
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
- direct inventory delivery; no courier (latest user instruction).
- Gold and Lumber transferable.
- normal creep bounty shared; killer gets +20% of own equal share.
- Aghanim Shard/Scepter per hero.
- Aghanim Blessing frees slot.

### Boons
- Every second Boss kill (waves divisible by 10) gives a two-card team vote.
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
- Removed by the owner decision at the top of this file. Difficulty is per-match;
  match XP, Gold and rewards do not persist after the match.

### Localization/live
- English, Turkish, Russian, Simplified Chinese mandatory.
- opening panel includes bug/development suggestion email.
- telemetry-based balancing.
- DEV/BETA and LIVE separation.
- architecture must scale to 100 heroes.

### References
- The owner removed the blanket custom-game code prohibition on 2026-09-29.
- Verified licensed code reuse follows REFERENCE_ANALYSIS_POLICY.md; custom asset rights are separate.
- Unclear permission means concept reference and independent implementation.
- All hero skills may be replaced if justified; preserve identity, classify changes and validate pilots/hero rollout. No import or skill rewrite was performed by this policy update.

## PROVISIONAL BALANCE SEEDS
May change without reopening core design (legacy persistent XP formulas are retired):
- leak normal -1 / Boss -5,
- cap 30×player,
- Boss HP formula 1+0.75*(players-1),
- 1000G→10L and 10L→900G,
- Ascended ~55/70/85 Lumber tiers,
- Tome same-type price growth ~10%,
- difficulty stat multipliers,
- XP formulas/amounts,
- Boon numbers,
- Spellbringer costs,
- creep threat costs.

## Owner respawn and publication decision — 2026-10-01
Owner decision (2026-10-01): player hero normal death respawn starts at 30 seconds
at match start level 6, rises linearly with level (rounded to nearest second),
and caps at 50 seconds at level 50. Native Aegis/Reincarnation are preserved;
neutral Bosses never receive player respawn timers. Supersedes the old 5–20s seed.
Live/Workshop publication now requires a new explicit owner instruction.

## BLOCKED PENDING WATCHER ZIP
Do not finalize remaining reference-led hero/Shard/Scepter work. Talent trees and
persistent Hero Passive Trees were removed by the owner and are not open items.

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
3. current Workshop APIs assumed by UI/shop/selection.

## 2026-09-27 player feedback audit — provisional implementation

- Fifth authored ability is the innate for each hero, starting with one free rank;
  native legacy talent/extra ability slots 7–17 are suppressed. Final eight-rank
  curves and level-30 point allocation were unresolved at that milestone. The
  2026-09-29 target below supersedes that provisional design; do not label migration complete.
- Shared Evolution has functioning modifiers as an interim repair. It does not
  fulfill the locked hero-specific choice requirement or establish Watcher parity.
- Ascended interim implementation uses current native base item classes and +20%
  selected flat bonuses, starred native names/icons and current base costs. Snapshot:
  audit/ASCENDED_NATIVE_SNAPSHOT.json. This does not replace the target unique PvE
  mechanics in GAME_DESIGN_MASTER §23. Engine acceptance of all 30 derivatives is open.
- Existing role-based Shard and generic ultimate Scepter bonuses are now exposed in
  tooltips, not represented as completed hero-specific evolutions. Passive/buff-only
  ultimate coverage still needs individual design work.
- Recipe fix hypothesis: overlapping HOME/SECRET triggers and insufficient height.
  A universal HOME volume replaces them; user's actual purchase result is required.
- See audit/PLAYER_FEEDBACK_2026-09-27.md for evidence and remaining release gates.

## 2026-09-27 all-hero follow-up

- Authored KV values now take precedence over fixed values in 74 repaired ability
  sections. This changes some rank curves; engine/balance acceptance remains open.
- Ground-effect thinkers are limited to three live entities per ability, oldest
  replaced first, with explicit expiry cleanup. Summoned illusions have a four-unit
  cap to permit Chaos Knight's authored maximum. These are local candidate rules.
- All hero entrypoints were inventoried and mocked across ranks; semantic review
  of 63 remaining unreferenced-special candidates is still required. See
  audit/HERO_REVIEW_2026-09-27.md. Hero-specific trees, Shard/Scepter and distinct
  Ascended extensions remain unresolved implementation work, not completed content.

## 2026-09-29 hero progression and reference infrastructure

- LOCKED user-directed target: in-match max hero level50; Q/W/E/R and the fifth
  Enfos passive each reach10 total ranks. No automatic additional talent milestones.
  This supersedes the provisional level30/attribute7/innate8 allocation.
- DESIGN DECISION: keep the fifth Enfos passive at rank1 for free at hero level1.
  Levels2–50 grant exactly49 spendable points, for exactly50 total ranks across
  five abilities. On the first real-hero spawn only, clear any native level-1
  ability point after granting the free passive. Preserve unspent points on later
  respawns/reconnects; never reset the budget on every `npc_spawned` event.
- DESIGN DECISION: retain the authored per-creep `BountyXP` kill reward and team
  sharing. The game design explicitly removed any separate wave-completion XP
  award; the `xp_bounty` fields in `wave_definitions.lua` are currently unused and
  must not be repurposed without a product decision. Exact static replay of all
  60 spawn plans using current NPC `BountyXP`, including current single-Boss
  counts and per-team sharing, estimates full-clear XP per player at about115,116
  (solo),109,170 (2 players),107,248 (3),106,240 (4) and105,617 (5). These are
  content estimates, not telemetry; leaks, disconnects and match outcomes lower
  or shift them.
- DESIGN DECISION: use an increasing XP cost of `900 + 45*(L-1)` to move from
  hero level L to L+1, for L=1..49. The sum is97,020 XP to reach level50. Encode
  the Dota table as cumulative XP thresholds: table[1]=0 for level1, then add each
  transition cost to create table[2]..table[50]. This leaves roughly8% headroom
  beneath the current five-player full-clear estimate, so some missed kills do
  not automatically prevent reaching the cap, while early finishes remain below
  it. Revisit this candidate after match telemetry; do not add a wave award.
- DESIGN DECISION: regular ranks become available at hero levels1–10. The Enfos
  passive's free rank1 is granted at hero level1; its remaining ranks are
  learnable from levels2–10. Ultimate ranks unlock at levels5,10,15,20,25,30,35,
  40,45,50. This deliberately moves the first ultimate rank one level earlier
  than native Dota's standard level6 so a uniform five-level KV interval can make
  all ten ranks reachable by the level50 cap; starting heroes are level6, so the
  first rank is already available when a match begins. The earlier 6,11,...,51
  schedule was internally inconsistent with max level50 and is superseded.
  Rank availability is separate from ability-specific rank values.
- IMPLEMENTATION / ENGINE POC REQUIRED: confirm max-level50, custom XP threshold
  indexing, actual skill-point award at level1, ten-rank KV/UI behavior, custom
  `RequiredLevel`, initial free-passive sequencing, talent suppression and
  reconnect persistence in the current Dota build. Do not ship the proposed
  curve or gates until this POC passes. Preserve kill-based XP and ensure
  preview/UI estimates continue to use per-unit `BountyXP` rather than the unused
  wave-level field.
- ENGINE ATTEMPT 2026-09-29: the tools-mode launch was blocked before map load by
  a hidden Dota startup dialog reporting NVIDIA `NVAPI_ACCESS_DENIED`. The dialog
  was safely dismissed; Dota then exited. No level-cap or skill-point engine
  result was obtained. Retry after the local graphics-driver startup issue is
  resolved; retain ENGINE PENDING status until then.
- API evidence: current VScript catalog exposes server methods
  `CDOTABaseGameMode:SetCustomXPRequiredToReachNextLevel(table)` and
  `SetUseCustomHeroLevels(bool)` (define the table before enabling custom levels),
  plus `CDOTA_BaseNPC_Hero:SetAbilityPoints(int)`. API availability does not
  prove this addon's level-50 cap, table indexing or skill UI behavior; verify in
  the current engine before rollout.
- IMPLEMENTATION IN PROGRESS: `heroes/match_levels.lua` defines the level-50
  cumulative XP curve and starts each player at level 6 with five spendable
  points once per player after granting the free Enfos passive.
  `enfos_sametc.lua` installs it at game-mode startup and hero spawn. All 40
  roster heroes now have KV gates for Q/W/E/Enfos passive (level 1, interval 1)
  and R (level 5, interval 5); each has a focused contract test confirming rank
  10 by level 50 and that slot 5 is not native innate metadata. Static content
  checks pass. Runtime point behavior, free-passive point accounting, and the
  10-rank HUD remain PENDING owner playtest.
- SLOT 5 CONTRACT AUDIT: current KV inventory identifies three non-passive
  fifth-slot kits: Wraith King Skeleton Army (passive charge + active summon),
  Bristleback Hairball (active point cast) and Luna Lunar Orbit (active self-buff).
  Keep these flagged while auditing; they do not yet satisfy the Enfos passive
  slot contract, even though the separate start-rank grant is wired.
  Wraith King's rank-10 count mismatch (KV 12 versus helper cap 8) is repaired;
  the helper keeps its default cap for other summon callers and supports a
  per-ability bound of at most 20. The passive-slot design question remains open.
- REFERENCE READY / ENGINE ACCEPTANCE PENDING: docs/heroes contains 40 work
  instructions and 200 separate evidence ledgers. Native slots/models/SoundSet
  were extracted from installed Dota build 6941; per-skill classifications and
  mapping evidence are recorded to varying depth and continue to be reviewed.
  Static callbacks, modifiers, resources and PvE behavior are not uniformly
  certified. File presence and mocks are not runtime pass.
- All 40 heroes now have the level-50 KV rank gates and focused contract tests.
  Continue the hero-by-hero static kit audit; keep every Dota gameplay, VFX, SFX,
  HUD and VConsole acceptance item pending until owner live testing.
- See audit/HERO_ABILITY_RESEARCH_2026-09-29.md and HERO_ABILITY_REFERENCE.md.


## Lion Mana Drain recipient economy decision — owner answer pending, 2026-10-03

The current authored E damages every eligible hostile recipient and produces equal mana, even when that recipient has mana. Native Mana Drain is a mana-transfer ability. Owner preference was requested: use actual target mana drain on mana-bearing enemies with a defined conversion fallback on mana-less PvE creeps, or explicitly retain the authored damage/mana conversion for all recipients. No dependent mana-economy implementation is authorized by an unanswered preference; source/cleanup/Shard work can continue independently. Also review native allied mana-transfer targeting, empty-mana effects and final partial/channel-expiry timing before closing E. Lion remains OPEN; no mock or source check constitutes owner engine acceptance.


## Lion E economy implementation default, 2026-10-03

The earlier unanswered question requested a preference, not permission. No owner answer is claimed. Proceeding under the existing native-first hero mandate with a stated implementation default: mana-bearing hostile recipients lose actual mana, and Lion receives only the observed amount lost; zero-maximum-mana PvE recipients retain the authored damage/mana conversion. A mana-bearing recipient at zero current mana is not a mana-less recipient and cannot generate fallback mana. Primary and Shard recipients use one policy with ordinary targeting/resistance rules and source/revision guards. This supersedes the prior inferred requirement to wait for permission before any economy work. Balance, ally transfer and exact engine timing remain separately recorded; no runtime acceptance from mocks.


## Owner native-first rollout extension, 2026-10-04

After Shadow Fiend, continue the eighteen heroes in the exact order recorded
in [the rollout goal](audit/NATIVE_FIRST_HERO_ROLLOUT_GOAL_2026-10-04.md),
using Luna lessons and separate owner engine acceptance. This supersedes the
previous stop-after-SF instruction. The additional hero is confirmed as Dota2
Necrophos (npc_dota_hero_necrolyte). Preserve the existing40 and expand to41
when implementing the addition; update count/role checks rather than disabling
them. This owner request supersedes the prior40-only roster constraint for
local development, without authorizing remote publication. No new hero is
implemented or runtime-certified by this plan.

## Shadow Fiend native Scepter cooldown floor — provisional, 2026-10-04

Installed native Requiem Scepter subtracts30 seconds, while authored ENFOS
ranks8–10 have29/26/23-second cooldowns. The pilot clamps the paid cast to a
minimum1 second rather than allowing a negative cooldown. This is a reversible
source default, not owner balance acceptance. Owner rank10/Scepter testing must
review this potentially strong interaction before marking SF complete. Native
returning lines/heal replace the previous generic40% damage/25% cooldown bonus.

## Owner defers live hero testing, 2026-10-04

Owner requests overnight completion of the already ordered hero source rollout
and Necrophos addition while postponing live validation. This supersedes the
SF engine-acceptance-before-next-source-unit gate. Continue source units
sequentially with full native-first research and tests; record all remaining
engine/VFX/SFX/damage/lifecycle acceptance pending. No Dota control or publishing
authorization is added. SF Q remains its verified native directional no-target
cast. Selected-hero diagnostics now run automatically once on initial real hero
spawn, after point initialization, without gameplay modification.

## Owner cancels automatic external collection, 2026-10-04

Owner decides local/remote collection is unnecessary and will save console logs
and provide them manually. The optional loopback receiver and HTTP sender were
removed by reverting the agent-only collector unit. Keep automatic selected-hero
Health console reports and the offline analyzer for voluntarily supplied logs.
No collector, upload, public endpoint or HTTP diagnostic transmission remains.
Nine automatic-health/SF integration checks pass after removal. Do not restore
collection services without a new owner request. Overnight hero source rollout
and deferred owner engine validation remain unchanged.

## Owner replaces scheduled continuation with sequential goal work, 2026-10-04

The scheduled Enfos hero heartbeat is deleted at owner's request. Continue the
owner-listed native-first hero source work in this chat, starting Bristleback,
without waiting for live tests; keep pending runtime fields separate. The latest
rollout goal contract supersedes the old SF-only stop gate. Automatic selected
hero Health remains; owner shares logs manually. No collector/publication is
restored. Goal API objective editing is unavailable; do not fabricate completion
of the old SF goal to create a replacement.
