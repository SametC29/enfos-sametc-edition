# Boss focus and pressure — 2026-10-04

Status: IMPLEMENTED BUT NOT ENGINE-VERIFIED. Owner Dota/VConsole acceptance pending.

## Problem and root cause

Owner reports that Bosses sometimes ignore the player among creeps and asks for harder, smarter encounters. The route thinker returned immediately for any living attack target, including a basic defender; native spell/item searches chose the nearest defender without hero priority. The separate `enfos_test` arena registers a neutral Sven Boss without attaching a Core route thinker. Its Boss thinker previously issued only spell/item orders, leaving ordinary attack acquisition to the engine.

The production-code mock reproduced the first failure before implementation: a Boss already attacking a nearer defender creep did not switch to the real hero behind it. This is a controller defect, not evidence that any native ability needs replacing.

## Research and scope

- Dota custom MCP: installed build 6943 / revision 11069754; native 12-hero sources reviewed against the existing native-kit snapshot. API lookup verified `IsRealHero`, `IsAttackImmune`, `IsOutOfGame` and `IsCommandRestricted` contracts (no asset identifiers added).
- API reference: https://docs.moddota.com/lua_server/ and https://docs.moddota.com/lua_server/declaration .
- MCP reference library: Aghanim's Pathfinders, Workshop 2208582400, `scripts/vscripts/ai/ai_core.lua`, inspected 2026-10-04. Hero-specific acquisition and avoiding unchanged repeated orders informed the diagnosis. Reference only; no copied code/assets and no claim of licensed/version-certified reuse or current engine verification.
- Native bot entry point `GameRules:AddBotPlayerWithEntityScript` exists, but needs a player/entity script and custom objective logic. It does not establish that native lane bots can directly drive ownerless neutral Core-bound Bosses. Existing native heroes, QWER, passives, builds and presentation remain KEEP; only controller targeting changes.

## Implemented behavior

- Real heroes outrank nearer basic defenders/illusions for hostile targeted abilities/items and ordinary attacks. Friendly native spells continue to target self.
- Keep an eligible current hero instead of restarting attacks every 0.4 seconds. Acquisition remains bounded to 750 for attacks; native spell ranges remain unchanged.
- Exclude dead, wrong-team, invisible, invulnerable, out-of-game targets; attack selection additionally excludes attack-immune targets. Basic defenders remain eligible when no attackable player is nearby.
- Routed attack targets must remain inside the existing 1100-unit lane corridor. Expired/stale focus returns to the Core route immediately. Cast/channel handoff and native/custom command restrictions retain control.
- Unrouted test arena Bosses explicitly issue ordinary attack orders when no spell/item is used. Normal creep acquisition remains unchanged.
- New match balance snapshot `2026-10-04-boss-pressure-4` applies Boss-only HP x1.20 and base attack damage x1.15, on top of existing wave/difficulty/solo curves. Native spell damage is unchanged. Legacy snapshots without new fields retain their original multipliers. This is provisional tuning pending owner balance tests.

## Validation and remaining acceptance

Focused automated regressions cover creep-to-player switching, stable hero focus, dead-target replacement, invisible/immune fallback, wrong-team/corridor rejection, command restrictions, empty-lane route resumption, arena attacks, native targeted spell priority, toggle resource gates, cast/channel navigation, resource prewarm, all twelve Boss identities/rewards/death/leak pipelines and all 60 wave curves. Boss pressure checks cover all five difficulties, solo on both teams, multiplayer, all twelve Boss wave slots and legacy snapshots. Automated results certify controller logic only.

MCP status: Dota not running; VConsole unreachable. No game was launched or controlled, following the owner-only runtime workflow in `HERO_ABILITY_DEVELOPMENT_GUIDELINES.md`. New VConsole error absence, VFX/SFX/animation and actual attack acquisition remain unverified.

Check results: focused Boss regressions PASS; 44 existing Lua behavior cases PASS; both broad Node suites PASS (210 and 150 cases); Lua/KV syntax and native 12-kit audit PASS; normal-wave pressure audit PASS. Full `npm run check` has one unrelated workspace failure: concurrently edited `content/panorama/layout/custom_game/boon_vote.xml` has not yet been mirrored to `game`. All 39 committed Panorama source/runtime mirrors were independently checked and match. Those concurrent UI edits are excluded from this Boss commit; no known Boss failure remains in automated checks.

Owner runtime pilots: Sven, Axe and Crystal Maiden. In `enfos_test`, stand behind/among the ten creeps, verify hero acquisition when spells are on cooldown and stable attacks during silence. In normal `enfos`, verify hero focus with allied summons/illusions, then leave acquisition range and observe uninterrupted Core movement and exactly one five-Life leak. Check taunt/channel preservation, dead/invisible/immune targets and cast/impact/channel effects and audio. Compare early/mid/final Boss survivability and damage at normal/solo difficulty before accepting the added pressure. Restart the match for the new snapshot. Record revision and VConsole output with PASS/FAIL per case.

Files changed: `bosses/native_hero_bosses.lua`, `waves/creep_ai.lua`, `waves/balance_config.lua`; focused Lua/Node regressions and existing Boss fixture updates. No native skill definitions, VFX/SFX assets or Workshop publication changed.
