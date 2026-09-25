# REFERENCE ANALYSIS POLICY

Watcher of Samsara, Enfo's and other custom games are design references, not source libraries.

## Allowed
Analyze:
- player-facing mechanics,
- pacing,
- role/build patterns,
- number/shape of choices,
- boss design ideas,
- progression concepts,
- high-level map/pathing flow,
- what appears fun, confusing or unsuitable.

## Never transplant
Do not copy into production:
- source code,
- KV/data tables,
- models,
- textures,
- icons,
- particles,
- audio/music/voice,
- Panorama files,
- map geometry/data,
- custom names/lore,
- custom strings/tooltips.

## Clean-room workflow
For each interesting feature:
1. describe behavior neutrally,
2. identify design purpose,
3. decide if it fits this game,
4. if yes, write a new project-native design,
5. implement from scratch under our architecture,
6. use original project art/identity or valid Valve/Dota resources.

Classify:
- `REFERENCE_ONLY`
- `ADAPT_CONCEPT`
- `REJECT`

## Familiar Dota abilities
If a reference map modifies a normal Dota ability:
- compare the abstract concept against current Dota,
- choose what fits our PvE/PvEvP mode,
- create our own mechanic/tuning,
- never copy the reference's custom implementation.

## When files arrive
Create:
- `docs/reference-analysis/watcher-of-samsara.md`
- `docs/reference-analysis/enfo-map.md`

Each report:
- relevant system inventory,
- concepts worth adapting,
- concepts rejected,
- consequences for current design,
- production systems that would change,
- explicit confirmation no code/assets were copied.
