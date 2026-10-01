# Progressive native waves and special mechanics

Implementation status: wave spawning integration ready for automated review;
actual Dota/VConsole validation is pending. No live or Workshop publication.
The curve and resource evidence are in `WAVE_CURVE_ROSTER_2026-10-01.md`,
`NATIVE_WAVE_ROSTER_2026-10-01.json`, and `NATIVE_WAVE_SKILLS_2026-10-01.json`.

## Root cause and final behavior

The old normal-wave compositions reused generic archetypes and mixed models.
Difficulty multipliers were constant; there was no authored shared stat curve.
Normal spawn plans now resolve exactly one native-model profile for each of the
48 normal waves. Batch timing, uncapped scheduled counts, two normal lanes,
12 Boss-only waves and Team Life rules remain intact. The old composition data
is retained as historical data but is not used for normal spawn plans.

Stats are generated from the shared curve. Solo opening attenuation and the
Boss progression factors are applied through the versioned match snapshot.
Native Boss spells retain their own native damage values. No Elite spawning,
hero progression, talent tree, account storage or hero kit changes are included.

## Ability classification and limits

Native creep skills are KEEP at rank 1 with TUNE for cast frequency and specialist
counts. The 29 installed native definitions used here are recorded verbatim in
the skill snapshot. Native identifiers missing from the installed ability table
are not assumed removed from the engine: they are avoided where an explicit
current definition or a bounded existing/custom adaptation is available.

PVE-CONVERT adaptations retain recognizable mechanics: Ghost and Lycan units
use true invisibility; Harpy Scouts silence, trolls root on attack; the late
Prowler reflects damage. Existing addon frost, armor, magic ward, mana burn,
poison and explosion abilities are reused on suitable native appearances.
The Centaur Conqueror stomps, Mud/Frost-Earth golems throw boulders and the
stone Familiar uses a bounded stomp adaptation. Dark Troll summoning is REPLACE
with a bounded no-target ability instead of an unverified native summon ID.

Only two specialists per defended team/wave receive most skills. One quarter
of Ghost wave 11 and Lycan wave 21 units receive invisibility. Per-ability casts
share a three-second team/wave gate. Attack silence/root last 1.5 seconds and
have a seven-second per-target gate, preventing mass repeated control.
Reflection is 20%, capped at 75 per event, and does not reflect reflection.
Allied Spellbringer future units receive the corresponding special kit.

Each Dark Troll has at most four living children and creates at most two per
cast. Children last 20 seconds, use 30% of parent health/attack, cannot summon,
grant no gold or XP, and cause no Team Life loss on arrival. Hostile children
are registered for authoritative hostile targeting and follow a route from
their spawn position. Allied children retain player control and never follow
hostile leak routes. The existing route-from-position helper is reused as an
integration dependency; unrelated AI taunt changes are excluded.

The existing asynchronous resource gate warms the bounded 48 native sources
and 48 custom profiles once per match. Current-wave and future-summon resource
callbacks gate creation. Sources load native skill resources as well as models;
the custom profile loads its projectile presentation. Missing callbacks block
creation and log an error rather than spawn an ERROR model or partially loaded
unit. Spellbringer rolls back a failed cast while resources are pending.

## Validation and remaining acceptance

Production planner measurements show rising scheduled counts, raw health and
raw base attack output over all six acts. This proxy excludes native spells,
armor, player builds and kill speed; it does not prove all heroes are balanced.

Relevant automated checks cover all 60 curve steps, all 48 profile/model/stat
matches, all future boundaries, specialist distribution, attack-control spacing,
child caps, death slot reuse, ownership, zero rewards and recursion prevention.
Four-language source and generated wave/ability tokens are compared directly.
The isolated index also passes 14 runtime mock regressions and native Boss
preparation/resource/toggle mocks. Engine acceptance remains separate.

The full working-tree `npm run check` passes. A clean HEAD/index snapshot has
pre-existing unrelated failures in hero AbilityValues/tooltips, hero inventories,
retired evolution/nettable references and absent ignored local map artifacts.
The same failures were reproduced in the foundation-only HEAD snapshot. Those
unrelated contributor changes are intentionally preserved outside this commit;
scoped wave checks establish the integration evidence, not a clean full-release
baseline. No full release certification is claimed.

Owner runtime checklist: start a fresh match; inspect waves 1, 11, 12, 21, 31,
36, 49 and 59 plus each Boss; verify paths, native animation/projectiles,
stun/silence/root, resource callbacks and bounded summons in VConsole; use
Reveal on Ghost/Lycan units; assess solo opening and late pressure. Spellbringer
+5 power, target area and accepted-cast effects are a separate pending commit.
