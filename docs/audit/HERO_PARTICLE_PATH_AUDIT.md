# Hero particle path audit

Date: 2026-09-30. Installed Dota snapshot: ClientVersion 6941 / SourceRevision
11041083 (Sep 25 2026).

`node tools/verify_particles.mjs` checks the historical curated resource list and
extracts every literal `.vpcf` path in `game/scripts/vscripts/abilities/pve_kits.lua`
and `game/scripts/vscripts/addon_game_mode.lua`. It then confirms that each
logical path has a compiled `_c` entry in the installed `pak01_dir.vpk`.

Current result: 196 unique literal Lua/precache paths were found, and all 196
were present in Valve's installed VPK. This confirms resource-file existence
only. It does not establish correct particle purpose, control-point semantics,
attachment, scene placement, size, cold-start loading, or visibility in a live
match. Those acceptance rows remain pending until the owner checks them in Dota.

Follow-up repair, 2026-09-30: Zeus `enfos_zeus_heavenly_jump` had no particle
call, and its 450-unit movement was incorrectly conditional on the caster
already moving. It now always moves and calls the installed Zeus Shard launch
and landing ring resources; both are explicitly precached. A Lua regression
covers standing-still use and both calls. The live scene, animation, and sound
remain pending owner verification.
