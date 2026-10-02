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

## Verification

- `node tools/localization.mjs` — PASS; all four language outputs regenerated across resource and Panorama targets.
- `node tools/checks.mjs` — PASS; 0 failed checks. This includes mock Lua execution and static content checks, not a Dota engine playtest.
- `node tools/hero_reference_docs.mjs --check` — PASS.
- `git diff --check` — PASS.
- Dota runtime, VConsole, icon presentation, particles, animation, and audio were not tested in this pass. Owner live test is pending.

## Remaining individual audit

All five skills remain pending for full cast/targeting, rank-up UI, gameplay balance, boss effects, modifiers and dispels, visual/audio presentation, precache, cleanup, reconnect, and in-engine validation. The native reference snapshot is build 6941 / source revision 11041083 from 2026-09-29; re-verify against the current installed build before drawing new engine-behavior conclusions.
