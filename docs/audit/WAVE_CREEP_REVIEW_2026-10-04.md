# Wave-creep ability and presentation review — 2026-10-04

Scope: the 48 authored normal waves in `NATIVE_WAVE_ROSTER_2026-10-01.json` and
`WAVE_SPECIAL_CONTRACTS_2026-10-01.json`. Waves 1–4 intentionally have no special
ability; the remaining 44 have a kit on every authored creep. Boss-only waves
are a separate acceptance scope. This review compares production Lua/KV with
the installed Valve unit/ability snapshot and runs offline regressions. The owner
will run the Dota match; no new engine or VConsole result exists for this change.

## Defects and changes

| Waves | Classification | Evidence and correction | Owner engine check |
| --- | --- | --- | --- |
| 18, 31, 42, 47, 54 | TUNE cast trigger | Native no-target wolf howl, stomp, clap and slam definitions expose their effect radius as `AbilityValues.radius`. The AI used a 750-unit fallback when `GetAOERadius()` returned zero, so it could spend the cast while defenders were outside the effect. It now reads the radius special before falling back. | Stand inside then outside each native effect radius; confirm damage/control or buff, visible effect, sound and animation occur only on a useful cast. |
| 24 | TUNE cast trigger | Installed Ogre Smash is a self-centered point ability with no cast range and a 200-unit radius. The AI previously searched 128 units and ordered a point at the target's position. It now searches the native radius and orders the cast at the caster's position. | Confirm a target about 150–200 units away is hit and a target outside is not; observe cast effect/sound/animation. |
| 44 | TUNE native ability | Installed `enraged_wildkin_hurricane` requires vector targeting, while creep AI issues one target/position order. Use installed native `enraged_wildkin_tornado` (unit/point targeting, rank 1, 500 cast range) so the existing AI can issue a complete order. The ability belongs to the related Wildkin native family; the wave retains its Wildkin model. Static audit now rejects vector abilities in wave kits. | Confirm Tornado is actually cast, follows its target, completes/ends channel, and has valid effect, sound and cast animation on the Enraged Wildkin model. |

The production kit contract and installed Valve snapshot cover all 48 normal
profiles, their rank-1 ability identifiers, target teams/types and model/sound
metadata. `node tools/verify_models.mjs` validates resource paths. Offline Lua
regressions reproduce the two cast-trigger faults and exercise the Tornado order.
These checks cannot establish in-engine damage, native particles, audio playback,
animation sequences or cleanup. No replacement particle/sound identifiers were
invented from asset names, and all other native ability classifications remain
KEEP pending observation.

## Runtime acceptance queue

For each normal wave, confirm the authored creep appears, attacks and routes;
its special mechanic has the expected target/effect; its cast, hit and expiry
show the right visual and audible cues; the model animates and returns to idle;
no lingering particle, sound or modifier remains; and VConsole has no Lua,
missing-resource or invalid-order error. For passive kits, provoke the passive
instead of expecting a cast animation. The per-wave identifiers and manual
questions are in `WAVE_SPECIAL_CONTRACTS_2026-10-01.json` and
`MANUAL_TEST_QUEUE_2026-10-01.md`. Prioritize waves 18, 24, 31, 42, 44, 47 and
54 because this patch changes their cast decisions. Also inspect invisibility
and Reveal on 11/21/49, capped summons on 36, and death burst on 51.

Status: **offline candidate only**. VFX/SFX/animation and gameplay acceptance
await the owner's new-match test and VConsole evidence. Per
`QA_BALANCE_RELEASE.md`, Workshop LIVE promotion follows a successful local
gameplay report, smoke and release checks; a GitHub push alone is not promotion.
