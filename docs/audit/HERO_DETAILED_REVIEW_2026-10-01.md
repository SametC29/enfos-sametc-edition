# Items 14–16: detailed offline review

This is an investigation record, not acceptance of all 40 hero kits.
Owner performs Dota tests; Codex did not start the game or publish Workshop.

## Native source comparison

Read the installed 6942 / SourceRevision 11055158 split hero definitions.
Out of 200 release skills, 136 have explicit dossier counterpart IDs that
resolve in that hero's native AbilityDefinitions. Remaining 64 are unresolved
or custom-only mappings; icons and slot numbers were not used to guess IDs.
`HERO_NATIVE_PRESENTATION_2026-10-01.json` records each hero source hash,
counterpart and native/custom behavior, sound, cast and channel metadata.

There are extensive explicit animation-metadata differences. These cannot all
be treated as broken animations: passive/native defaults, Lua gestures and
intentional conversions need individual review. Two remaining native channel
animation gaps are Crystal Maiden Freezing Field and Pudge Dismember. Witch
Doctor's W/E/R/Shard metadata was repaired from its exact current native values.
No blanket animation insertion was performed.

## Audio findings

Decoded all 128 installed hero sound banks with Source2Viewer CLI 19.2. Initial
158 literal events had 16 names absent from those banks and 3 case-only matches.
The Witch Doctor missing Death_Ward reference is now replaced and its silent
Restoration has explicit on/loop/off ownership. Other missing names remain
review candidates until the relevant native skill, full bank corpus and hero
dossier are examined; missing in the hero directory is not proof of absence
from the whole game.

Known remaining leads include Axe call; Legion odds/courage; Sniper ultimate;
Tide gush/ravage; Troll stance; Zeus jump; Pudge hook; Lich armor/impact;
Invoker Sun Strike; Leshrac Edict impact and Void Time Lock. The JSON report
contains exact event names and call sites, not guessed replacement names.

`tools/audit_projectile_sound.mjs` is not acceptance evidence: its fixed-length
source slices and presence tests can miss modifiers/helpers and cannot resolve
events, actual playback, asset lifetime or presentation semantics.

## Behavior and effects

The existing all-hero harness executes production Lua and real KV rank values
1–10. It covers all 200 skills and 223 modifiers, but permissive mocked engine
operations cannot establish rendering/audio/immunity/pathing correctness.
Existing focused regressions cover Troll stance/axes/trance, PA projectile
impact, finite Medusa mana shield, interrupted target channels, bounded ground
entities and several Boss control limits. Those are mock results only.

196 literal particle paths exist in the installed VPK. CP meanings, attachment,
native parent/child effects, precache on another player's client and visible
radius versus gameplay radius still require individual asset/runtime evidence.
Wraith King skeleton summoning, PA Blur and Shadow Shaman wards have no particle
signal in the contract inventory; summons/model effects or helper chains may
explain this, so they are not automatically missing VFX bugs.

## Focused repair and validation

Witch Doctor repair addresses W audio/toggle lifecycle and E/R/Shard native
animation metadata; R/Shard used an event absent from the native bank and now
use the verified WardBuild event with modifier-owned teardown. Decoded ward
attack particle requires a moving projectile/destination CP and an end-cap;
the previous target-attached `effect()` call supplied neither. R/Shard now use
engine-owned tracking projectiles at the installed native unit's speed 1000,
with damage on impact. Physical damage amounts/scaling and rank gates are
preserved; travel introduces the intended delay. This remains an Enfos
adaptation, not the native ward's pure-damage/attack-proc implementation.
Its dossier records classification, source, precache ownership and unresolved
visual/animation gaps.

Reproducible commands:

- `node tools/audit_heroes_deep.mjs` verifies contract inventory freshness.
- `node tools/hero_presentation_review.mjs` checks static review-queue freshness.
- `node tools/hero_native_presentation_audit.mjs --dota-root <Dota root> --vpk-module <existing reader module>` compares the installed hero sources to explicit dossier mappings.
- `node tools/hero_sound_event_audit.mjs --banks <decoded hero bank directory> --build-file <installed game/dota/steam.inf>` checks event lookup and records bank hashes/build.
- `node node_modules/fengari-node-cli/src/lua-cli.js tests/hero_kit_regressions.lua`: 205 focused mocked regressions pass, including audio lifecycle, R/Shard projectile launch/impact and rejected lost/dead/allied targets.
- `npm run check`: PASS, zero failures; all 200 skills / 223 modifiers and ranks 1–10 remain covered by the mocked production-Lua harness, plus content, waves and native Boss checks. Engine checks remain pending.

Primary authoring research: [ModDota ability metadata](https://moddota.com/abilities/ability-keyvalues)
and [precache lifecycle](https://moddota.com/scripting/precache-fixing-and-avoiding-issues).
These explain the separate metadata/resource contracts; installed sources and
real runtime remain the authority. No external code or asset was imported.

## Owner acceptance still required

Fresh local restart: toggle Witch Doctor W on/off twice, run out of mana and
die while W is on; confirm visible aura, healing and on/loop/off audio with no
stuck sound. While R channels, toggle W without interrupting R. Cast E and R,
confirm the actual native cast/channel gestures. Interrupt R and cast Shard;
confirm WardBuild sound ends with the effect. Check that R/Shard shots travel
from the ward/caster to the target and damage arrives on impact, including
after the ward disappears. Check VConsole and a second player's cold-start
client. Ward attack gestures, actual projectile rendering/termination and
Shard transformation remain open; do not mark the whole hero DONE.
