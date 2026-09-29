# DECISIONS AND OPEN ITEMS

This file exists so Codex does not "helpfully" redesign locked decisions.

## 2026-09-27 live-test follow-up (provisional / blocked)
- Latest 40-wave test supersedes the earlier general-easier request: keep progression
  systems, reduce bonus magnitude/frequency; bosses must survive bursts and have phases.
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

## 2026-09-28 hero tree candidate
- 40 per-hero Evolution profiles replace shared global stat choices. Six distinct
  focuses per hero recur across six two-choice tiers; 480 offered choices total.
  Balance is provisional pending local gameplay; Shard/Scepter and distinct Ascended
  mechanics remain open. See [tree audit](audit/HERO_TREES_2026-09-28.md).

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
- 2026-09-28: scheduled hostiles are uncapped; population never directly costs Life.
- Timed batches and temporary summon bounds remain; crowding requires engine performance testing.
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
- The owner removed the blanket custom-game code prohibition on 2026-09-29.
- Verified licensed code reuse follows REFERENCE_ANALYSIS_POLICY.md; custom asset rights are separate.
- Unclear permission means concept reference and independent implementation.
- All hero skills may be replaced if justified; preserve identity, classify changes and validate pilots/hero rollout. No import or skill rewrite was performed by this policy update.

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
- DESIGN DECISION: regular ranks become available in order at hero levels1–10;
  ultimate ranks unlock at levels6,11,16,21,26,31,36,41,46,50. This preserves an
  early ultimate identity while distributing ten ranks over the new cap. Rank
  availability is separate from rank value curves; all200 curves still need
  ability-specific design and tuning.
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
  cumulative XP curve and clears the initial level-1 point once per player after
  granting the free Enfos passive. `enfos_sametc.lua` installs it at game-mode
  startup and hero spawn. Actual runtime level/point behavior remains PENDING;
  ten-rank KV curves, unlock enforcement and HUD validation are not implemented.
- REFERENCE READY / ENGINE ACCEPTANCE PENDING: docs/heroes contains40 instructions
  and200 separate evidence ledgers. Native slots/models/SoundSet were extracted
  from installed Dota build6941; custom skill counterpart/classification remain
  UNASSESSED until per-skill evidence is collected. File presence is not runtime pass.
- Proposed pilot: Sven first, then Lina/Juggernaut/Dazzle subject to actual kit
  pattern coverage; no unrelated hero repair is authorized by this docs rollout.
- See audit/HERO_ABILITY_RESEARCH_2026-09-29.md and HERO_ABILITY_REFERENCE.md.
