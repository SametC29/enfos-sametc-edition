# Sniper: hero work instructions

Hero ID: `npc_dota_hero_sniper`. Project role: Carry.

Read [the shared hero contract](../AGENTS.md), [technical reference](../../HERO_ABILITY_REFERENCE.md) and [this hero's dossier](ABILITIES.md) before each skill task. The root AGENTS.md explicitly applies this reading requirement to shared gameplay/KV edits.

- Work only on the requested skill or coherent hero unit; shared helper changes require regressions for other affected heroes.
- Preserve this hero's recognizable Dota identity; verify its original kit in the installed source shown in ABILITIES.md.
- KEEP/TUNE/PVE-CONVERT/REPLACE needs evidence before implementation; UNASSESSED is discovery only.
- Current five stable IDs and their KV/Lua mappings are in the generated inventory. Do not guess native counterparts from slot order or icon.
- Use the per-skill review leads; verify callbacks, assets, CPs, sounds, animation and native modifiers against the exact build.
- Target is 50 hero levels and 10 total ranks per skill; keep current and target values separate until migrated.
- Update each affected acceptance row; gameplay, VFX, SFX, modifier, precache, cleanup and tooltip are one acceptance unit.
- PASS requires the relevant evidence; absent Dota/VConsole/audio/visual tests remain PENDING. A documented N/A must be justified.
- Restore/reconnect must not duplicate ranks, points, modifiers, items or choices.
- Reuse other custom-game code only under REFERENCE_ANALYSIS_POLICY.md: verify exact source/version, license, distribution compatibility, notices and dependencies; document imports. Asset rights are separate. Do not publish to Workshop from a dossier update.
