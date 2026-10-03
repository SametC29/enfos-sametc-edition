# TECHNICAL ARCHITECTURE — Dota 2 Custom Game

Adapt concrete paths/API calls to the actual repository and current Workshop Tools. Do not create duplicate infrastructure if equivalent systems exist.

## 1. Core architecture principles
- Server owns gameplay truth.
- Content definitions are data-driven.
- Stable internal IDs are separate from localized names.
- Gameplay logic does not depend on Panorama implementation.
- UI sends requests; server validates and broadcasts authoritative state.
- No player profile or cross-match progression service is loaded; all game progression is match-local.
- Runtime config is versioned and snapshotted at match start.
- Reference-map analysis never becomes a source-code dependency.
- Balance values live in config/data rather than scattered constants.

## 2. Suggested service boundaries

`GameStateService`
- mode, difficulty, phase, teams, wave, Endless, build/config version.

`WaveDirector`
- authored wave definitions,
- threat budget,
- batching,
- scheduling,
- Boss incoming transition without removing prior scheduled hostiles.

`UnitCapService`
- counts active hostiles,
- cap formula,
- complete scheduled spawn delivery,
- exemptions,
- metrics.

`LifeService`
- Life total,
- leak validation,
- Life damage,
- defeat,
- Endless leak escalation.

`CreepAIService`
- waypoints,
- aggro/leash,
- flying mana-drain and ground control variants,
- stuck recovery.

`BossDirector`
- phases,
- telegraphs,
- scaling,
- CC/HP-percent/reflect caps,
- completion events.

`SpellbringerService`
- personal mana/regen,
- availability,
- cast validation,
- target legality,
- custom unequal-team normalization,
- cap-safe extra-unit behavior.

`EconomyService`
- Gold share,
- killer bonus,
- XP sharing,
- Lumber,
- transfers,
- conversion,
- Tome escalation.

`AscendedItemService`
- eligibility,
- item consumption,
- Lumber charge,
- one-copy rule,
- sellback,
- stacking policy,
- Aghanim Blessing.

`BoonService`
- card candidates,
- recent-choice weighting,
- voting,
- stack/Unique,
- Pacts.

`HeroBuildService`
- manual skill points,
- Innate,
- in-match build-choice queue,
- Shard/Scepter interactions,
- Mastery-unlocked alternatives.

`PlayerStateService`
- connected/disconnected/abandoned,
- respawn,
- authoritative per-match resources.

Progression and rewards are match-scoped. Do not load account profiles, store permanent unlocks, or apply cross-match stat bonuses.

`LocalizationPipeline`
- key registry,
- fallback,
- static validation.

`TelemetryService`
- structured aggregate event schema,
- never blocks gameplay.

Couriers are removed by owner decision; purchases use native shop/direct
inventory delivery. Do not implement the former CourierService boundary.
The approved compiled map still contains retired wood TreeShop/CourierZone I/O.
`map/retired_triggers` removes only their exact-name `trigger_dota` entities once
at startup; two entity-script retirement adapters resolve pre-Activate loads.
Native `trigger_shop` and Ascended access are preserved. Owner confirms market
functionality; runtime log confirms three retired triggers and cleared related
errors. Separate Ascended transaction coverage remains unspecified; see
[retirement evidence](audit/RETIRED_MAP_TRIGGERS_2026-10-04.md).

`DotaCompatibilityAudit`
- base item IDs,
- relevant APIs,
- selection/shop/courier assumptions.

## 3. Stable data definitions

Prefer structured definitions for:
- heroes/role tags,
- abilities/Innates,
- in-match build choices,
- waves,
- creep archetypes,
- Bosses,
- difficulty modifiers,
- Spellbringer abilities,
- Boons/Pacts,
- Ascended items,
- localization keys.

Example stable IDs:
- `hero_ranger_001`
- `wave_024`
- `boss_iron_colossus`
- `spell_future_reinforcements`
- `boon_prosperity`
- `ascended_worldheart`

Never persist translated display text as IDs.

## 4. Match config snapshot

At match start:
1. load/validate config,
2. compute version/hash,
3. snapshot values used by the match.

Log build + config hash. A running match must not reinterpret rules mid-session because config changed elsewhere.

## 5. Client/server trust

Client may request:
- purchase,
- Ascension,
- conversion,
- transfer,
- vote,
- Spellbringer cast,
- settings/state query.

Server validates:
- player identity/team,
- ownership,
- currency,
- cooldown/mana,
- target legality,
- match phase,
- item presence,
- Unique/stack rules,
- rate limits.

Never accept client-supplied final:
- currency totals,
- Life result,
- damage truth,
- progression XP,
- item grants.

## 6. RNG

Use match-seeded RNG when feasible for:
- Boon candidates,
- vote tie resolution,
- intended randomized modifiers.

Record seed/config for reproducibility. Avoid unrelated global random calls in core systems.

## 7. Performance budget

Track separately:
- scheduled hostiles,
- temporary ability minions,
- Spellbringer summons,
- allied reinforcements,
- particles/thinkers where feasible.

Rules:
- no unbounded summon recursion,
- do not give every creep an independent high-frequency timer when batched/event logic works,
- avoid repeated whole-map scans,
- cache waypoints/regions,
- spawn across timers/frames,
- deterministically expire temporary units.

Developer diagnostic overlay/command should expose:
- scheduled-hostile cap disabled,
- active entities by category,
- pending spawn queue,
- crowded-lane spawn completion,
- current wave,
- optional performance indicators available to the environment.

## 8. Uncapped scheduled hostiles (2026-09-28)
WaveDirector creates every scheduled hostile in timed batches, independent of
current live population. No capacity check suppresses scheduled spawns or
converts them to Life damage. Temporary summon limits remain independent.
Physical leaks are resolved exactly once. Boss-only transitions remain below.
Profile crowded lanes in the engine before release.

## 9. Boss transition

Before Boss, stop scheduling the prior wave and show the transition timer.
Existing scheduled hostiles remain tracked and alive while the Boss spawns.
Neither the transition nor a wave deadline removes hostiles or charges Life;
only the physical Core leak callback resolves a scheduled hostile and applies
its Life penalty. Temporary summons retain their independent expiry rules.

Test:
- surviving prior-wave hostiles during Boss spawn,
- hostiles remaining alive after a wave deadline,
- player disconnect,
- simultaneous Spellbringer cast,
- summoned minions,
- Life reaches zero through actual Core leaks.

## 10. Persistence model
No account or hero progression is persisted. Match reconnect uses server-authoritative in-memory state; it must not create permanent profiles, rewards or unlocks.

## 11. Reconnect

On reconnect rebuild from authoritative state:
- hero control/entity,
- level and skills,
- inventory,
- courier,
- Gold/Lumber,
- Spellbringer mana/cooldowns,
- queued match choices,
- team Boons,
- wave/Boss state,
- UI model.

Reconnect must not duplicate:
- items,
- votes,
- build choices,
- skill points,
- rewards.

## 12. Localization namespaces

Suggested:
- `hero.*`
- `ability.*`
- `wave.*`
- `creep.*`
- `boss.*`
- `spellbringer.*`
- `boon.*`
- `pact.*`
- `item.ascended.*`
- `progression.*`
- `ui.*`
- `error.*`
- `onboarding.*`

English fallback.

Validators:
- missing mandatory-language key,
- duplicate key,
- placeholder mismatch,
- orphan report,
- suspicious hard-coded visible strings when practical.

## 13. Telemetry events

Version event schemas.

Examples:
- match_started/completed
- wave_started/completed
- unit_leaked
- scheduled_spawn
- boss_started/completed
- hero_death
- spellbringer_cast
- boon_offered/selected
- pact_selected
- ascended_purchased
- tome_purchased
- currency_converted
- resource_transferred
- surrender_vote
- progression_grant_result

No unnecessary PII.

## 14. Dota patch compatibility

Because normal shop is intentionally vanilla:
- do not custom-clone the entire item ecosystem,
- run compatibility audit after major Dota patches.

Audit:
- all 30 Ascended parent item IDs still exist,
- assumed item behavior changes,
- Aghanim APIs,
- courier assumptions,
- shop purchase flow,
- hero-selection integration,
- TP behavior,
- events/modifier APIs.

Default policy:
normal Dota item follows current Dota; rebalance custom Ascended layer if needed.

## 15. Reference files

When Watcher ZIP and Enfo map arrive:
1. keep them isolated as reference inputs,
2. do not merge their production code/assets,
3. write `docs/reference-analysis/...` reports,
4. inventory concepts only,
5. classify `REFERENCE_ONLY`, `ADAPT_CONCEPT`, `REJECT`,
6. reimplement selected mechanics under this architecture.

## 16. Error handling

Sensitive mutation order:
1. validate all preconditions,
2. reserve/charge if required,
3. perform atomic state change,
4. confirm result,
5. broadcast UI/telemetry.

On error, state must remain coherent.

Structured error context:
- subsystem,
- stable content ID,
- team/player,
- match build/config,
- error code.

Visible error is localized and concise.

## 17. Developer tools

Development-only commands:
- jump to wave,
- set Life,
- spawn creep/Boss,
- set difficulty,
- add Gold/Lumber,
- grant Ascended,
- set hero level,
- trigger build-choice milestone,
- set Spellbringer mana,
- inspect cap/queues,
- dump match state/config hash.

Gate/remove unsafe commands in production.

## 18. Abuse/security

Validate finite positive values and bounds for:
- transfer,
- conversion,
- purchase.

Guard:
- custom-event spam,
- NaN/overflow,
- invalid/stale entity handles,
- repeated votes,
- repeated progression grant,
- arbitrary item IDs.

## 19. UI separation

Panorama consumes authoritative state. Never put real economy/wave/progression truth in UI scripts.

UI surfaces later:
- Life/wave/difficulty,
- Boss bar,
- Spellbringer panel,
- opponent summary,
- Boon vote/history,
- build-choice queue,
- Gold/Lumber,
- Ascended Shop,
- results/progression,
- opening/support message.
