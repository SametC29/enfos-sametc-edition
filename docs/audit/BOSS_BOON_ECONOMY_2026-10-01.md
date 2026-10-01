# Boss boon cadence and 60-wave Ascended economy — 2026-10-01

Status: **PARTIAL — BOON/ECONOMY, PHASE REMOVAL, AND NATIVE HERO-BOSS IMPLEMENTATION; ENGINE PLAYTEST OPEN**.

## Problems and causes

- Bosses spawn every five waves, but `BalanceConfig.Snapshot` set `boonEvery=10`.
  `WaveManager:OnEntityKilled` only opened a team vote when the Boss wave number
  was divisible by that value, so the first Boss at wave 5 could not grant its
  Boon vote.
- Boss Lumber used `5 + floor(wave / 5)`. Across Boss waves 5–60 that awarded
  only 138 Lumber per player, enough for two Tier-I Ascended purchases and 28
  Lumber, without Gold conversion.
- The old economy CSV tracked kill bounty, but omitted cumulative Gold,
  Boss-Lumber income, conversion needed for four Tier-III upgrades, and their
  underlying native item costs.
- Bosses had health-threshold floors at 70% and 35%, with temporary
  invulnerability between floors and a general 4%-max-HP-per-hit cap. Stonebreaker
  enrage and Brood Matron add-spawns were also tied to health thresholds. The
  current implementation copied Boss phase state into the wave HUD data.

## Changes

- Boss Boon votes now occur every five waves, matching the authored Boss cadence.
  The match config version was advanced so a match snapshots the new rule.
- Boss Lumber now uses `9 + floor(wave / 5)`: 10 at wave 5, scaling to 21 at
  wave 60; all twelve Bosses award 186 per active player (+35% over the old total).
- The production economy audit now derives wave plans and unit bounty from the
  live project data, includes the 600 starting Gold, 20% killer bonus model, Boss
  Lumber, current four-item Tier-III costs, and Gold→Lumber conversion. It fails
  if its modeled 1–5-player cases cannot afford four Tier-III Ascended upgrades.
- The installed-Valve-item snapshot records stat increases for all 30
  native-derived launch Ascended items (no item is a pure name reskin). The
  regular-wave schedule ramps from 20 units per player at wave 1 to 136 at wave
  59. `tools/wave_pressure.mjs` measures all 52 normal waves from the production
  planner: six-act averages rise from 28 to 128 units, 9,651 to 58,826 authored
  HP, and 559 to 3,409 raw base attack output/s. Act averages rise consistently,
  although individual waves vary with archetype composition. Bosses are excluded
  from these normal-wave metrics. This establishes an authored early/late
  pressure trend; it is not actual combat DPS or proof of live difficulty. Exact
  feel and Ascended strength remain owner playtest questions.
- Current model at wave 60: per-player gross Gold ranges from 93,639 (five players)
  to 121,612 (solo). Four Tier-III purchases need 340 Lumber; the revised Boss
  awards provide 186, so the remaining conversion costs 15,400 Gold. Four base
  items cost 10,225–25,350 Gold, for a modeled total of 25,625–40,750. This leaves
  headroom in the model. Therefore the per-creep Gold bounty was not increased;
  its live balance remains subject to playtest.
- Removed the health-threshold floors, temporary invulnerability, general
  per-hit damage cap, health-triggered enrage/add-spawn transitions, and phase
  values from the wave net table. The reflect safety cap remains. Signature
  damage and target count scale modestly from authored wave number.
- Removed the now-unreachable legacy Boss telegraph dispatcher, four themed
  custom attack routines, and their toxic/blood modifiers. Registration fails
  closed unless native hero setup succeeded, so the Boss framework no longer
  retains a callable custom-attack fallback.
- Each of the twelve Boss waves now maps to a distinct hero in the 40-hero
  roster. The server spawns the hero model, preserves the former themed unit as
  the reward/durability template, and loads that hero's current Valve
  `AbilityDraftAbilities` QWER order and `Bot.Build` skill-up sequence from its
  mounted native hero KV. A bounded server thinker issues native cast orders
  against heroes on the defended team, while the creep route continues to move
  the Boss toward that team's Core.
- Boss level is the rounded mean level of connected/selected defenders, clamped
  to 1–50; wave 60 forces level 50. The first native Valve `Bot.Build` core
  items are granted as level milestones, reaching all six inventory slots at
  level 50 (and explicitly on wave 60). No authored health phases or legacy
  signature attacks are used when native setup succeeds. Setup failure is
  logged and the malformed Boss is removed instead of silently falling back.
- `Rewards:Estimate` now uses the preserved themed reward template for native
  Boss plans, so the wave UI can still estimate Boss bounties after the spawn
  name changes to a hero ID.

## Verification

- `npm run check`: PASS, zero failures, including all 60 authored wave plans,
  economy regressions, and the Boss-boon cadence assertions.
- `node tools/wave_economy.mjs --check`: PASS across 300 wave/team-size cases;
  model asserts four Tier-III affordability for team sizes 1–5.
- `node tools/wave_pressure.mjs`: PASS across 52 production-planned normal
  waves; count, authored HP, and theoretical base attack output all rise by act.
- MCP addon audit: PASS after the economy edit, 34 VScript and 11 Panorama files,
  zero findings.
- Boss regression tests assert that phase health gates, damage caps, and
  health-threshold add/enrage state are absent.
- Native target-selection regression verifies neutral-team Bosses query the
  defending team's FRIENDLY units, filter the exact team, and issue a native
  unit-target order. The same mock also checks point-target orders land at the
  selected defender position and no-target orders are issued when a defender is
  in range; the runtime harness rejects unprepared legacy Bosses without
  requiring the real engine entity handle. This covers the static AI order path
  only, not actual cast legality or engine targeting.
- Wave plan regression checks all twelve 5th-wave Bosses spawn exactly one
  distinct roster hero and retain the themed reward template. Native ability
  assembly and AI orders remain unverified by the Dota engine.
- Fengari mock setup test feeds the current Valve-KV shape for Sven, then checks
  a wave-5 Boss follows the defending team level and early item milestone and a
  wave-60 Boss reaches level 50 with six items. This is script logic evidence,
  not proof that the mounted engine KV or in-game orders behave identically.
- Current Drow hero KV identifies Frost Arrows as `UNIT_TARGET | AUTOCAST |
  ATTACK`; Boss preparation enables autocast so the native lane attack order
  uses the skill. The mock test asserts this behavior flag path.
- Engine Boss spawn/model, QWER ability casts, build items, movement/attack AI,
  Boon UI, Gold income, kill rates, and purchase timing: **PENDING OWNER TEST**.
  Per owner direction, Codex does not launch or interact with Dota.

## Native/runtime references

- Installed base-game VPK records inspected through the Workshop MCP:
  `scripts/npc/heroes/npc_dota_hero_<name>.txt` (`AbilityDraftAbilities` and
  `Bot.Build`) and `scripts/npc/bot_loadouts.txt` (Valve core item order).
- Current Workshop Lua API metadata confirmed `CDOTA_BaseNPC:IsHero`,
  `HeroLevelUp` on `CDOTA_BaseNPC_Hero`, `AddAbility`, `RemoveAbility`,
  `AddItemByName`, `CDOTABaseAbility:GetAbilityTargetTeam/Type/Flags`,
  `GetCastRange`, and `ExecuteOrderFromTable` signatures.
- A downloaded Workshop enemy-unit AI example was read as an architecture
  reference for bounded server-side thinkers and ability-order selection. No
  source code was copied; this implementation is project-authored.

## Model limits

The model assumes every scheduled hostile and Boss is killed, all five-player
slots stay connected, the standard 20% killer bonus distribution applies, and
the four underlying items are bought from the projected bounty income. It does
not subtract a complete normal-item build, Tomes, or uncollected/leaked creeps.
The numbers prove the authored economy can support the target under those
assumptions; they do not certify that a player will earn four upgrades in a live
run. Check solo and team runs before final balance sign-off.

The pressure model similarly reads custom NPC base health, mean base attack
damage, and `AttackRate`. Its aggregate attack-output figure assumes every unit
can sustain attacks against valid targets; it excludes armor, attack animation,
pathing, ability damage, target selection, player damage/clear speed, difficulty
multiplier choice, and Boss native-hero stats. Treat it as a reproducible roster
trend check only, not a combat simulator or balance certification.

## Follow-up: cast and inventory-order conflicts

Static review found two independently scheduled AI loops issuing nonqueued
orders. Route AI did not guard the native cast-point phase; the Boss loop only
checked the candidate ability, so another slot/item could interrupt a spell
already preparing. Both now defer while GetCurrentActiveAbility returns an
ability in IsInAbilityPhase. Channel guards remain, and ordinary route/leak
handling resumes when casting ends. No skill identities or values changed.

Current installed item KV identifies Power Treads as IMMEDIATE | NO_TARGET,
without an ordinary cast cooldown. Treating its attribute switch as a combat
active every 0.4 seconds starved subsequent inventory slots. Boss item AI skips
that switch and retains the spawn attribute. Silence previously stopped all
items; it now stops abilities only, while IsMuted gates item orders separately.
Native Armlet now changes state only when nearby combat starts/ends; it does
not repeatedly toggle while a defender remains nearby. Actual native effects
remain pending owner testing.

MCP API metadata confirms GetCurrentActiveAbility, IsInAbilityPhase and IsMuted.
Installed base item KV for item_power_treads and item_black_king_bar provides
the behavior evidence. Mock tests verify cast-phase route/leak deferral,
resumption, no competing Boss order, Treads followed by BKB under silence, and
no item order under mute, and Armlet activation/stability/deactivation. Tests/audit_regressions.lua now has 20 passing cases;
tests/run.lua retains 44 with expanded Boss checks. Owner runtime verification
of cast completion and item effects remains pending.

## Installed-data kit assembly follow-up

See [Native Boss kit assembly](NATIVE_BOSS_KIT_ASSEMBLY_2026-10-01.md). Lina
has nonconsecutive Draft slots, CM omits its bot-trained aura, and Luna Orbit
is not trained by the current Valve bot list. Production preparation now
handles these shapes and spends unused ordinary rank budget under native
rank/hero-level gates. All twelve recorded installed-data kits pass preparation
and final item-grant mocks. The owner clarified that original kits retain
passives; four active-only spells are not required. Runtime remains pending.
