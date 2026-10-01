# Active Desktop update goal: 1–8 and 14–16

Owner scope extension on 2026-10-01 adds Desktop `Güncellemeler.txt` items
14, 15 and 16 to the unfinished first-eight goal. The earlier restriction
against items after 8 is superseded only for these three entries. Items
17 onward remain outside this task.

The application goal tool cannot edit an unfinished goal's objective. Its
old blocked objective has not been falsely completed or replaced. This file
records the newly authorized scope while offline work continues. The original
[first-eight ledger](FIRST_EIGHT_UPDATES_2026-10-01.md) remains applicable.

## Added acceptance units

| Item | Scope | Completion evidence |
|---:|---|---|
| 14 | All 40 heroes / 200 abilities: cast, projectile, impact, persistent effects | Installed-build asset identity; attachment/control-point review; precache path; interruption/death cleanup; owner observation of rendered effects. |
| 15 | Targeting, damage/healing/buffs, passive triggers, toggles, channels, summons | Actual KV/Lua contract; ranks 1–10; allied/enemy/creep/Boss handling; cancellation, invalid target and immunity cases; observed in-engine result. |
| 16 | Cast/impact/loop sounds and cast/channel/attack animations | Installed native counterpart/event/resource evidence; cast animation and channel sequence; loop stop on interruption/death; actual owner audio/animation check. |

Follow `RESEARCH_AND_RUNTIME_VERIFICATION.md` and hero dossiers before any
skill change. Classify KEEP/TUNE/PVE-CONVERT/REPLACE with evidence; preserve
native identity. Audit globally, repair proven shared causes, verify 2–4 pilots,
then continue hero by hero. Do not bulk-fill guessed animation/event names.

## Initial offline review performed

- Structural inventory: 40 heroes / 200 entrypoints PASS; zero unreferenced
  special-field candidates and zero legacy-only Lua value candidates.
- Real production Lua in mocked execution: all 200 abilities and 223 modifiers
  PASS; rank checks 1–10 PASS. This does not certify targeting, VFX or audio
  in Dota.
- Installed Valve VPK: all 196 literal particle references scanned by
  `tools/verify_particles.mjs` exist. Asset existence does not prove correct
  control points, attachment, client precache or cleanup.
- Existing `tools/audit_projectile_sound.mjs` uses a 1,500-character slice and
  Boolean source tests. Its OK/ALERT labels are not detailed acceptance evidence.
- Added reproducible review queue: `node tools/hero_presentation_review.mjs`.
  Missing explicit animation fields and absent sound/particle signals are
  candidates, not certified bugs: toggles, passive/attack-triggered effects and
  inherited/native behavior can legitimately differ.
- Global explicit soundfile precache currently lists five hero files. Audit
  ability-level precache and native hero loading before diagnosing other
  heroes' sounds as missing; do not restore synchronous loading of all heroes,
  which previously stalled game setup.

## Research and evening owner test

Reviewed the primary authoring reference
[ModDota Ability KeyValues](https://moddota.com/abilities/ability-keyvalues):
cast-animation and behavior fields are separate contracts; precache deserves
client verification. Its historical warnings require installed-build/runtime
confirmation, not automatic application. The Valve Lua abilities page was
unavailable during this review; no claims were derived from its inaccessible
contents. No external implementation or asset was copied.

Start the owner test with Sven (known W feedback issue), Troll Warlord (stance,
axes and trance), Phantom Assassin (projectile impact), and Witch Doctor
(toggle and interrupted channel). For Q/W/E/R/passive, record effect, audio,
animation, result and VConsole errors; use ranks 1 and 10 and a Boss target.
Then expand hero by hero. Passing four pilots does not accept the other 36.

Codex must not launch or control Dota; owner performs live tests. VConsole is
reviewed when accessible test output is supplied/available. No unattended
evening monitoring or Workshop publishing was scheduled by this scope update.
Items 1–8 and 14–16 remain unfinished wherever owner runtime evidence is pending.
