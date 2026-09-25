# TECHNICAL ARCHITECTURE — Dota 2 Custom Game

Adapt concrete paths/API calls to the actual repository and current Workshop Tools. Do not create duplicate infrastructure if equivalent systems exist.

## 1. Core architecture principles
- Server owns gameplay truth.
- Content definitions are data-driven.
- Stable internal IDs are separate from localized names.
- Gameplay logic does not depend on Panorama implementation.
- UI sends requests; server validates and broadcasts authoritative state.
- Persistent storage is an adapter, never a direct dependency spread across gameplay code.
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
- Boss incoming cleanup.

`UnitCapService`
- counts active hostiles,
- cap formula,
- overflow decisions,
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
- Runner,
- stuck recovery.

`EliteService`
- Elite definitions/modifiers,
- difficulty augmentation.

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

`ProgressionService`
- Account XP,
- Mastery XP,
- difficulty unlock,
- hero unlocks,
- reward IDs/idempotency.

`ProgressionStorage`
- interface only.
Adapters:
  - Mock/local dev
  - production backend if available
  - unavailable/disabled safe mode

No gameplay service calls raw HTTP for progression.

`LocalizationPipeline`
- key registry,
- fallback,
- static validation.

`TelemetryService`
- structured aggregate event schema,
- never blocks gameplay.

`CourierService`
- flying courier,
- own-arena restriction,
- delivery buffer,
- PvE untargetability.

`DotaCompatibilityAudit`
- base item IDs,
- relevant APIs,
- selection/shop/courier assumptions.

## 3. Stable data definitions

Prefer structured definitions for:
- heroes/role tags,
- abilities/Innates,
- in-match build choices,
- Mastery tree,
- waves,
- creep archetypes,
- Elites,
- Bosses,
- difficulty modifiers,
- Spellbringer abilities,
- Boons/Pacts,
- Ascended items,
- progression curves,
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
- current cap,
- active entities by category,
- pending spawn queue,
- overflow leaks,
- current wave,
- optional performance indicators available to the environment.

## 8. Overflow algorithm

For a scheduled leakable unit:
1. WaveDirector asks UnitCapService for capacity.
2. Capacity available → spawn normally.
3. Capacity full → no entity is created.
4. LifeService applies the definition's leak amount once.
5. Emit telemetry/log.

Boss bypasses ordinary cap block.

Temporary ability summons do not turn into Life damage.

Spellbringer offensive extra units:
- either wait in a short bounded queue,
- or cast fails/refunds as specified,
- never become automatic leak damage.

Prevent double resolution: a unit cannot both overflow-leak and later leak physically.

## 9. Boss transition

Before Boss:
- cancel remaining prior-wave scheduling,
- transition timer,
- resolve remaining leakable scheduled units once,
- remove/expire non-leakable temporary entities,
- assert prior scheduled wave cleared,
- then spawn Boss.

Test:
- full cap,
- huge backlog,
- player disconnect,
- simultaneous Spellbringer cast,
- summoned minions,
- Life reaches zero during cleanup.

## 10. Persistence model

### Account
- schema version,
- Account XP/Level,
- Legacy allocation,
- difficulty unlocks,
- hero tokens/unlocked heroes,
- relevant durable settings.

### Hero Mastery
- stable hero ID,
- XP/rank,
- Passive Tree allocation,
- unlocked build-choice alternatives.

Requirements:
- explicit schema migrations,
- removed node safely refunds point,
- idempotent reward IDs,
- same match/checkpoint cannot grant twice.

If backend unavailable:
- match still runs,
- do not claim permanent save succeeded,
- show localized status,
- retry only within guarantees that cannot duplicate rewards,
- log failure.

## 11. Reconnect

On reconnect rebuild from authoritative state:
- hero control/entity,
- level and skills,
- inventory,
- courier,
- Gold/Lumber,
- Spellbringer mana/cooldowns,
- queued build choices,
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
- `elite.*`
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
- overflow_leak
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
- spawn creep/Elite/Boss,
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
