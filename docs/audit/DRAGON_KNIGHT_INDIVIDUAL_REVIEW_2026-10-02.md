# Dragon Knight individual review — 2026-10-02

## Scope of this pass

This pass repaired user-visible localization and tooltip accuracy. It is not a full runtime certification of Dragon Knight's kit.

## Verified findings and changes

- Compared the five project abilities with their stable IDs, generated inventory, native installed hero KV snapshot, and current project KV/Lua definitions.
- English, Russian, and Simplified Chinese were missing Dragon Knight's project ability tooltip tokens. The localization generator filled those gaps with Turkish source text, so the localized client showed Turkish skill descriptions. Added translated names and full descriptions for Q/W/E/R and the Enfos passive in all three locales, including the compact tooltip aliases generated from those descriptions.
- Replaced the generic Tank Scepter/Shard wording for Dragon Knight with explicit upgrade labels in English, Russian, and Simplified Chinese. Behavior remains the shared Tank Scepter/Shard behavior; no upgrade mechanics changed.
- Dragon Blood Lua adds `Strength * 0.05` to its constant health regeneration in addition to the KV regeneration. Updated the skill and passive-modifier descriptions in all four locales to disclose the extra 5% Strength-based regeneration.
- Fixed the localization generator's modifier-owner lookup so it resolves Dragon Blood's `{{bonus_armor}}` and `{{bonus_hp_regen}}` placeholders for the passive modifier tooltip as well as the ability tooltip.
- Added a content-contract regression test for all five localized skill descriptions and the Dragon Blood Strength scaling.
- The fifth Enfos passive `enfos_dk_wyrm_vigor` was using the Dragon Blood icon. The exact installed VPK contains `panorama/images/spellicons/dragon_knight_wyrms_wrath_png.vtex_c`, which matches its documented native counterpart (`dragon_knight_wyrms_wrath`, installed Ability3). Changed its `AbilityTextureName` and added a regression asserting the distinct icon mapping. The other four assigned icon files were also found in the installed VPK.
- Q/W/R emit the installed bank's `Hero_DragonKnight.BreathFire`, `Hero_DragonKnight.DragonTail.Target`, and `Hero_DragonKnight.ElderDragonForm` events. The native hero KV names `soundevents/game_sounds_heroes/game_sounds_dragon_knight.vsndevts`, and the recorded sound-event scan confirms all three event definitions. The addon's shared explicit sound-bank precache list omitted `dragon_knight`; added it using the same established path rule as the other heroes and added a regression. Event reachability is statically verified; audible playback and timing remain an engine test.
- Native `dragon_knight_elder_dragon_form` explicitly sets `AbilityCastAnimation` to `ACT_INVALID`; the custom R slot had no explicit override. Because the Enfos ability occupies slot 4 while the native ability is slot 6, relying on the engine's slot-based cast animation default could produce a cast gesture before the scripted model swap. Set `ACT_INVALID` explicitly to retain the native transform presentation and added a KV regression. Confirm actual gesture/model transition in-game.

## Verification

- `node tools/localization.mjs` — PASS; all four language outputs regenerated across resource and Panorama targets.
- `node tools/checks.mjs` — PASS; 0 failed checks. This includes mock Lua execution and static content checks, not a Dota engine playtest.
- `node tools/hero_reference_docs.mjs --check` — PASS.
- `node --test tools/tests/content_contracts.test.mjs` — PASS; all 90 tests, including icon, sound-bank precache, and transformation-animation regressions.
- `git diff --check` — PASS.
- Dota runtime, VConsole, icon presentation, particles, animation, and audio were not tested in this pass. Owner live test is pending.

## Remaining individual audit

All five skills remain pending for full cast/targeting, rank-up UI, gameplay balance, boss effects, modifiers and dispels, visual/audio presentation, precache, cleanup, reconnect, and in-engine validation. Icon path existence is verified, but actual HUD presentation is not. The native reference snapshot is build 6941 / source revision 11041083 from 2026-09-29; re-verify against the current installed build before drawing new engine-behavior conclusions.
