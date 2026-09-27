# All-hero review: local candidate, 2026-09-27

This is a defect-repair candidate, not a claim that the remaining content roadmap
is complete. No Workshop upload or engine gameplay session was performed.

## Coverage and fixes

All 40 heroes / 200 ability entrypoints were inventoried. Changes touch 74 ability
sections across 32 heroes, plus shared damage and ground-effect lifecycle helpers.

- Replaced 41 fixed modifier-property values with the owning ability's authored
  values. Rank-dependent critical multipliers, lifesteal, summon counts/duration,
  attack coefficients and several radii/ranges now also read their data.
- Wraith King Reincarnation now supplies the engine reincarnation property when
  learned and ready. Only an actual reincarnating death spends its rank-dependent
  cooldown and applies the death burst/slow. An ordinary death supplies no override.
- Medusa Mana Shield now consumes mana proportional to absorbed damage, capped by
  available mana. Split Shot now respects its toggle.
- Jakiro Liquid Fire has a manual cast and cooldown-respecting autocast; it applies
  the authored attack-speed slow. Previously it was an unconditional attack proc.
- Leshrac's spell lifesteal uses actual damage events instead of an unsupported
  modifier-property constant; reflected/self damage cannot heal him.
- Sven's reactive damage is marked as reflection to stop reactive damage loops.
- Dazzle's cooldown reduction reads its authored rank value and excludes items.
- Dragon Knight/Terrorblade attack-mode mutations and critical-roll mutations run
  on the server. Chaos Knight can summon the four illusions defined by his top rank;
  summons remain replaced on recast and bounded.
- Chronosphere applies its shortened boss freeze once per cast, rather than
  refreshing it every 0.1 seconds and effectively ignoring boss CC resistance.
- Interrupted Pudge/Shadow Shaman/Lion channels release their own target debuff.
- Juggernaut ward, Sniper Shrapnel, Monkey King ring, Chronosphere and Storm remnant
  remove their thinker entity on expiry. Each ability permits at most three live
  areas; a fourth replaces its oldest area. Hero-attached modifiers are not removed
  by this cleanup. The limit is described in EN/TR/RU/zh-CN.

## Evidence

- `node tools/checks.mjs`: zero failures, including existing 45 hero scenarios.
- `node tools/test_real_abilities.mjs`: eight rank passes with each ability clamped
  to its actual maximum. All 200 abilities and 212 owned modifiers pass each pass.
  Modifier fixtures now use the owning ability's KV instead of returning 100 for
  every special. Unknown requested specials fail. Projectile impacts and attack
  events are exercised in addition to cast entrypoints.
- Added outcome assertions for mana exhaustion/partial absorption, first/top-rank
  crits, reincarnation eligibility/cooldown, spell lifesteal exclusions, interrupted
  channels, area caps/cleanup, toggle/autocast state and boss CC refresh prevention.
- `node tools/audit_heroes_deep.mjs`: checks active/passive/toggle entrypoints and
  verifies the checked-in 40-hero inventory is current.
- Workshop MCP static audit: 38 VScript / 11 Panorama files; zero warnings.
- Resource audit: 216 ability icons and 151 literal runtime resource paths present.
- All 10 protected map/theme files retain their recorded hashes.

These are mocked/static checks. They do not establish engine timing, rendered
effects, sound event playback, Dota native item purchase behavior or 60-wave balance.
The desktop Antigravity report was read as historical context; its “DONE” labels
and old universal-value mock results were not treated as engine acceptance.

## Remaining work — explicitly not completed here

The machine-readable inventory is [HERO_ABILITY_CONTRACTS.json](HERO_ABILITY_CONTRACTS.json).
63 ability sections still have unreferenced special-field candidates. These need
semantic review: some are legacy aliases (for example Gush damage); others reflect
real incomplete behavior. Passing the rank matrix does not erase this queue.

In particular, delayed/persistent effects (Firestorm, Macropyre, Sun Strike/EMP),
several innate descriptions, and a number of old radius/stat aliases still need
agreement between behavior and UI. This inventory is not a list of 63 certified bugs.

The 40 individual Evolution trees, 80 individual Shard/Scepter designs, and 30
distinct Ascended PvE extensions are still open. The shared/generic implementations
remain and must not be advertised as completed hero-specific mechanics. Later boss
encounters still share a phase pattern rather than all having unique encounters.

## Local engine acceptance by the user

Start a fresh local match so Lua modules and localization reload. Prioritize:

1. Wraith King: ready ultimate → death → 3-second reincarnation; death on cooldown
   must be ordinary. Confirm the tooltip's rank cooldown and slow/burst.
2. Medusa: turn Split Shot off/on, take a small and a large hit with limited mana.
3. Jakiro: manual Liquid Fire with autocast off, then autocast attacks; further
   attacks during cooldown must not repeatedly proc it.
4. Pudge/Shaman/Lion: interrupt a channel and verify the target is released.
5. Void: regular enemies stay frozen; a boss resumes acting after the short freeze.
6. PA/WK rank-one and maximum crits, Luna bounces, CK rank-three illusion count;
   compare against displayed values. Repeat the prior recipe purchase test separately.

Publish only after local acceptance. The Steam download-delivery verification from
V1.0.1 remains an independent unresolved release gate.
