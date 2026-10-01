# Desktop update items 1–8 — verification ledger (2026-10-01)

Scope is limited to the first eight entries of `Güncellemeler.txt`. These are
implementation findings, not runtime certification. Per owner direction, Dota
live testing is reserved for the owner; Codex must not launch or interact with
the game. Runtime acceptance remains explicitly pending where listed.

| # | Request | Current evidence | Result |
|---:|---|---|---|
| 1 | Spellbringer Glyph activation, point-target summons and eight-skill audit | Native Glyph is re-enabled and routes to the Spellbringer panel; point targeting, cancellation, mana/cooldown, co-op restrictions, all summon locations, reveal, displacement, purification, reinforcements, barrier mitigation, War Standard aura values and non-recursive Thorn Idol reflect have client/Lua mock regressions. | **Implemented; engine use of all eight abilities pending.** |
| 2 | Remove ERROR models | All 35 unique model paths in the current 37 Enfos NPC definitions resolve to compiled models in the installed base-game VPK; content checks reject missing/ERROR model paths. | **Static asset check pass; rendered unit check pending.** |
| 3 | True Sight reveals invisible wave units | Server reveal grants caster-team FOW and refreshes `modifier_truesight` on registered hostiles within radius; defending-team, radius and thinker/FOW call regressions pass. | **Code-path pass; actual invisibility, visibility and targetability pending.** |
| 4 | Remove Elites | Elite framework, definitions, scheduling, modifiers, reward hook and Elite Boon were removed; former slots are normal waves. Full content checks cover the retired identifiers and all wave plans. | **Implemented; live waves 6/12/18/24/36/42/48/54 pending.** |
| 5 | Strengthen Ascended and make early game easier/later game harder | Snapshot compares 30 native-derived items and records a 20% increase to every selected flat bonus (67 numeric fields). A production-planner audit now measures 52 normal waves per player: six-act means rise from 28 to 128 units, 9,651 to 58,826 authored HP, and 559 to 3,409 raw base attack output/s. Every act mean increases; individual waves intentionally vary by composition. | **Static early/late pressure trend passes; exact feel, Ascended strength, and live pacing require owner playtest.** |
| 6 | Make map health/mana refill locations work | Compiled entity extraction proves two authored team fountains referenced undefined npc_dota_custom_fountain. Added localized native ent_dota_fountain compatibility definition; regression checks the active map hash and both team dependencies without editing geometry. | **Missing unit dependency repaired; actual native healing/team initialization pending owner test.** |
| 7 | Boon every Boss; native hero Bosses using native skills/builds, scaled by team level, no custom phases | Boon cadence is 5 waves. Twelve unique roster heroes map to the twelve Boss templates; original QWER includes passives per owner clarification. All twelve installed-data kit shapes pass production preparation, including Lina/CM sparse Draft slots and Luna unused-rank recovery; wave 60 is level 50 with six core-item milestones. Mocks verify Boss preparation, defended-team FRIENDLY target lookup and native cast-order issuance. Legacy custom telegraphs, attacks and modifiers are removed; registration rejects unprepared templates. | **Implemented in scripts; model, cast AI, item use, rewards and Boon vote require engine test.** |
| 8 | Gold/Lumber allows four Ascended by the end | Economy model passes 300 combinations. At wave 60, modeled gross Gold is 93,639–121,612; four Tier-III items require 340 Lumber, with 186 Boss Lumber and modeled conversion of the remaining 154 Lumber costing 15,400 Gold. Assumes all units are killed and does not subtract a full normal build. | **Model target passes; live purchase timing/balance pending.** |

## Verification performed

- `npm run check`: PASS, zero failed checks; includes content/KV/Lua validation,
  retired-Elite checks, model path contracts, wave plans, all-hero mocks and
  Spellbringer behavior regressions.
- `node tools/wave_economy.mjs --check`: PASS, 300 production wave/player
  configurations.
- `node tools/wave_pressure.mjs`: PASS, the production planner's normal-wave
  unit count, authored health, and raw base attack output increase across all
  six acts. This is a KV-derived proxy, not actual combat DPS or engine balance.
- `node tools/tests/spellbringer.test.mjs`: PASS, world-point target/cancel.
- `node tools/tests/native_hud_controls.test.mjs`: PASS, 4 HUD controls.
- `node_modules/.bin/fengari tests/audit_regressions.lua`: PASS, 20 mocked
  regressions.
- `node_modules/.bin/fengari tests/run.lua`: PASS, 44 mocked behavior tests,
  including Boss unit-target, point-target and no-target cast orders.
- Dota Workshop `addon_audit`: PASS, 34 VScript and 11 Panorama files, no
  findings.
- `git diff --check`: PASS apart from existing line-ending conversion notices.

The target is not complete until every pending runtime check is performed in
Dota Tools and the local working changes are reviewed and committed without
including unrelated pre-existing contributor work. No Workshop upload was
performed.

## Owner runtime acceptance checklist

Run these checks in a fresh local match after a full restart where KV or asset
changes are involved. Record PASS/FAIL and the VConsole log for each item; a
mock test is not a substitute for these observations.

| # | Runtime check | PASS criterion |
|---:|---|---|
| 1 | Open Spellbringer from Fortification Glyph both while ready and while unavailable; use all eight abilities, including point-target summons and the three world-point casts. Test a valid lane position and an invalid/blocking position. | Panel opens without firing Glyph. Valid casts spend the listed mana, start cooldown, and apply the intended effect at the selected point; invalid/cancelled casts spend neither. Each of the eight effects is visible/functional and co-op restrictions match the UI. |
| 2 | Advance through normal waves and inspect every distinct custom creep model, including former Elite wave slots. | No unit renders as `ERROR`; each scheduled unit uses the intended visible model. |
| 3 | Use Reveal on an invisible wave unit with an observer in range. | The unit becomes visible to the defending team and targetable for the reveal duration; confirm it becomes hidden again after the effect expires. |
| 4 | Observe former Elite slots (6, 12, 18, 24, 36, 42, 48, 54) and their transitions. | They spawn normal wave composition only; no Elite model, modifier, Elite reward or Elite Boon appears. |
| 5 | Compare early, middle and late normal acts and purchase representative Ascended upgrades. | Early upgrades are obtainable at the intended pace; later scheduled waves apply greater pressure; Ascended bonuses exceed their base item values and do not create an early-game spike. |
| 6 | Enter each authored health/mana refill location with missing health and mana; test each team separately. | The intended zone restores both health and mana to eligible living heroes, only for the correct team, and does not heal dead/out-of-zone heroes. Record the exact map location if any zone is absent. |
| 7 | Defeat Bosses at waves 5 and 60 and complete the Boon vote. | One roster-hero Boss spawns alone, uses its prepared native QWER build/items and attacks the defending team; Boss 5 follows the current defender-level scaling and Boss 60 reaches the final build; each Boss kill grants the configured Boon vote and Lumber. |
| 8 | Track Gold/Lumber from wave 1 through the final waves and purchase four Tier-III Ascended items, including a recipe-based item. | Kill rewards arrive per kill, Lumber/reward conversion follows the displayed costs, recipes combine correctly, and the intended endgame route can fund four Tier-III items under the documented all-kills assumption. |
