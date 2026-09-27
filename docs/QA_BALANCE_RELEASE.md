# QA, BALANCE, PERFORMANCE AND RELEASE

## 1. One checks command
Maintain a top-level command/script that runs applicable:
- Lua/static validation,
- Panorama JS/TS lint,
- KV/data parsing,
- duplicate stable IDs,
- cross references,
- localization coverage/placeholders,
- wave schedule validation,
- Ascended parent validation,
- progression schema validation,
- economy simulation,
- deterministic logic tests.

## 2. Wave validator
Assert:
- exactly 60 waves,
- Boss exactly every 5,
- Boss wave has no ordinary spawn budget,
- Elite exactly every 6 excluding Boss overlaps,
- all referenced creep/Boss/Elite IDs valid,
- threat budget sane,
- no impossible spawn.

## 3. Hero validator
Assert:
- stable ID,
- valid role,
- required ability data,
- localization keys,
- Shard/Scepter,
- build-choice data,
- Mastery data when finalized,
- explicit solo-clear design path.

## 4. Ascended validator
Assert:
- expected launch count 30,
- valid base item,
- Lumber tier,
- stable IDs,
- sellback metadata,
- duplicate policy,
- effect stack policy,
- Boss cap policy where necessary.

## 5. Economy simulator
Inputs:
- player count,
- difficulty,
- all 60 wave definitions,
- actual entities/threat costs,
- Gold bounties,
- killer bonus,
- Boss Lumber,
- conversion,
- normal item spending assumptions,
- Tome spending,
- Ascended tiers,
- Boon/Legacy economy modifiers.

Outputs:
- Gold/player by wave,
- Lumber/player by wave,
- first major item timing,
- first Ascended timing,
- Ascended count at 60,
- sensitivity by team size,
- economy-build sensitivity,
- runaway cases.

Targets:
- normal 1–2 Ascended,
- economy 2–3,
- 6 mainly deep Endless.

## 6. Combat benchmarks
Per hero/build measure:
- single-target DPS,
- AoE clear,
- effective HP,
- sustained healing,
- control uptime,
- movement,
- mana sustain.

Maintain role envelopes, not one universal number.

Tank/Support solo builds may clear slower, but must progress independently.

## 7. Boss matrix
Test every Boss:
- 1–5 players,
- 5 difficulties,
- melee-heavy,
- ranged-heavy,
- spell-heavy,
- high sustain,
- high control,
- low/high persistent progression,
- relevant Ascended interactions.

Assert:
- no permanent CC lock,
- no reflect suicide loop,
- no HP-percent trivialization,
- readable telegraph,
- add cap,
- no path skip,
- one leak resolution.

## 8. Spellbringer tests
For each:
- valid PvEvP target,
- invalid direct hero target,
- Co-op availability,
- insufficient mana,
- reconnect,
- cap full,
- target dies mid-cast,
- simultaneous casts,
- Purification counter,
- Future Reinforcements no Boss/Elite,
- no Gold/XP farming.

## 9. Unit-cap stress
Stress with:
- weak 5-player team,
- Summoners,
- Spellbringer extra units,
- Future Reinforcements,
- mass VFX,
- disconnect/abandon,
- Boss transition.

Watch:
- max active units,
- overflow count,
- stale units/thinkers after many waves,
- server/frame hitch indicators.

No steadily increasing stale entity/thinker count.

## 10. Progression tests
Cases:
- new account,
- max account,
- partial,
- loss,
- win,
- surrender,
- abandon,
- Endless,
- duplicate reward,
- backend timeout,
- schema migration,
- removed Passive node refund,
- hero unlock consistency,
- Standard PvEvP reduced numerical effectiveness.

## 11. Reconnect tests
Reconnect during:
- normal wave,
- Boss,
- Boon vote,
- queued build choice,
- Ascended transaction,
- Spellbringer cooldown,
- surrender,
- Endless transition.

No duplicate/missing state.

## 12. Accessibility/readability
Test:
- common resolutions,
- all four languages,
- Russian expansion,
- Chinese wrapping,
- color-vision scenarios,
- lower VFX mode if implemented.

Critical mechanic cannot depend on hue alone.

## 13. Dota patch compatibility
After major Dota update verify:
- 30 base item IDs/behaviors,
- Aghanim,
- courier,
- normal shop flow,
- hero selection,
- TP,
- relevant API/events/modifiers.

## 14. Git/release
Each logical unit:
status → safe sync → focused change → tests → diff → docs → atomic commit → push.

Never push known broken code to satisfy automation.

Pushed regression:
fix-forward or revert; never force history rewrite.

## 15. DEV/BETA and LIVE
Risky changes land in DEV/BETA first.

LIVE promotion requires:
- smoke,
- compatibility,
- economy,
- localization,
- performance,
- migration,
- rollback plan.

## 16. Definition of done
A gameplay feature is done when it is:
- authoritative,
- data-driven where appropriate,
- localized,
- reconnect-safe where relevant,
- observable,
- tested/validated,
- performance-safe,
- documented,
- committed atomically and pushed.

## Player feedback acceptance — 2026-09-27

Release workflow agreed with the user: change -> automated checks -> user-run
local gameplay test -> only after the user reports success, upload to the existing
Workshop item 3809160125 -> verify public access and downloaded archive. A failed
local test returns to repair/retest; do not publish the candidate prematurely.

See [audit and live sequence](audit/PLAYER_FEEDBACK_2026-09-27.md).
Run node tools/checks.mjs and node tools/verify_models.mjs before handing over.
Compile only the changed Panorama layouts; never compile archived placeholder maps.
The native-derived Ascended catalog needs engine checks for every item's active,
passive, charges, shared cooldown, backpack/stash behavior, upgrade and sellback.
The hand-authored DPS estimator and mock Lua entrypoint execution are not a combat
simulation of the production skills and cannot close balance or engine release gates.
